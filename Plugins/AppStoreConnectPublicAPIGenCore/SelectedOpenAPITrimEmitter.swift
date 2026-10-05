import Foundation

public struct SelectedOpenAPITrimReport: Codable, Equatable, Sendable {
    public var operationCount: Int
    public var pathCount: Int
    public var schemaCount: Int
    public var removedEmptyEnumCount: Int

    public init(
        operationCount: Int,
        pathCount: Int,
        schemaCount: Int,
        removedEmptyEnumCount: Int
    ) {
        self.operationCount = operationCount
        self.pathCount = pathCount
        self.schemaCount = schemaCount
        self.removedEmptyEnumCount = removedEmptyEnumCount
    }
}

public struct SelectedOpenAPITrimEmitter: Sendable {
    public init() {}

    public func writeTrimmedDocument(
        schemaURL: URL,
        operationIDs: [String],
        additionalSchemaNames: [String] = [],
        outputURL: URL
    ) throws -> SelectedOpenAPITrimReport {
        let result = try trimmedDocument(
            schemaURL: schemaURL,
            operationIDs: operationIDs,
            additionalSchemaNames: additionalSchemaNames
        )
        try FileManager.default.createDirectory(
            at: outputURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try result.data.write(to: outputURL, options: .atomic)
        return result.report
    }

    public func trimmedDocument(
        schemaURL: URL,
        operationIDs: [String],
        additionalSchemaNames: [String] = []
    ) throws -> (data: Data, report: SelectedOpenAPITrimReport) {
        let data = try Data(contentsOf: schemaURL)
        let object = try JSONSerialization.jsonObject(with: data)

        guard let root = object as? [String: Any] else {
            throw OpenAPISchemaAnalyzerError.invalidTopLevelJSON
        }

        let operationIDSet = Set(operationIDs)
        let methodNames = Set(["get", "put", "post", "delete", "options", "head", "patch", "trace"])
        let paths = (root["paths"] as? [String: Any]) ?? [:]
        let components = (root["components"] as? [String: Any]) ?? [:]
        let componentSchemas = (components["schemas"] as? [String: Any]) ?? [:]
        var selectedOperationIDs: Set<String> = []
        var selectedPaths: [String: Any] = [:]

        for path in paths.keys.sorted() {
            guard let pathItem = paths[path] as? [String: Any] else {
                continue
            }

            var trimmedPathItem: [String: Any] = [:]
            if let parameters = pathItem["parameters"] {
                trimmedPathItem["parameters"] = parameters
            }

            for method in pathItem.keys.sorted() where methodNames.contains(method) {
                guard
                    let operation = pathItem[method] as? [String: Any],
                    let operationID = operation["operationId"] as? String,
                    operationIDSet.contains(operationID)
                else {
                    continue
                }

                trimmedPathItem[method] = operation
                selectedOperationIDs.insert(operationID)
            }

            if trimmedPathItem.contains(where: { methodNames.contains($0.key) }) {
                selectedPaths[path] = trimmedPathItem
            }
        }

        let missingOperationIDs = operationIDSet.subtracting(selectedOperationIDs).sorted()
        if !missingOperationIDs.isEmpty {
            throw GeneratorCommandError.validationFailed(
                "operation IDs not found in schema: \(missingOperationIDs.joined(separator: ", "))"
            )
        }

        let missingAdditionalSchemas = Set(additionalSchemaNames)
            .subtracting(componentSchemas.keys)
            .sorted()
        if !missingAdditionalSchemas.isEmpty {
            throw GeneratorCommandError.validationFailed(
                "additional component schemas not found in schema: \(missingAdditionalSchemas.joined(separator: ", "))"
            )
        }

        var schemaNames = collectComponentSchemaRefs(in: selectedPaths)
        schemaNames.formUnion(additionalSchemaNames)
        var visitedSchemaNames: Set<String> = []

        while let schemaName = schemaNames.subtracting(visitedSchemaNames).sorted().first {
            visitedSchemaNames.insert(schemaName)
            guard let schema = componentSchemas[schemaName] else {
                continue
            }

            schemaNames.formUnion(collectComponentSchemaRefs(in: schema))
        }

        var removedEmptyEnumCount = 0
        let trimmedSchemas = schemaNames.sorted().reduce(into: [String: Any]()) { result, schemaName in
            guard let schema = componentSchemas[schemaName] else {
                return
            }
            result[schemaName] = normalizedForTypedGenerator(schema, removedEmptyEnumCount: &removedEmptyEnumCount)
        }

        var trimmedComponents: [String: Any] = ["schemas": trimmedSchemas]
        if let securitySchemes = components["securitySchemes"] {
            trimmedComponents["securitySchemes"] = normalizedForTypedGenerator(
                securitySchemes,
                removedEmptyEnumCount: &removedEmptyEnumCount
            )
        }

        var trimmedRoot: [String: Any] = [
            "openapi": root["openapi"] ?? "3.0.1",
            "info": root["info"] ?? [:],
            "paths": normalizedForTypedGenerator(selectedPaths, removedEmptyEnumCount: &removedEmptyEnumCount),
            "components": trimmedComponents,
        ]

        if let servers = root["servers"] {
            trimmedRoot["servers"] = servers
        }
        if let security = root["security"] {
            trimmedRoot["security"] = security
        }

        let outputData = try JSONSerialization.data(
            withJSONObject: trimmedRoot,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        )

        return (
            outputData,
            SelectedOpenAPITrimReport(
                operationCount: selectedOperationIDs.count,
                pathCount: selectedPaths.count,
                schemaCount: trimmedSchemas.count,
                removedEmptyEnumCount: removedEmptyEnumCount
            )
        )
    }

    private func collectComponentSchemaRefs(in value: Any) -> Set<String> {
        var refs: Set<String> = []

        walk(value) { item in
            guard
                let object = item as? [String: Any],
                let reference = object["$ref"] as? String,
                reference.hasPrefix("#/components/schemas/")
            else {
                return
            }

            refs.insert(reference.replacingOccurrences(of: "#/components/schemas/", with: ""))
        }

        return refs
    }

    private func normalizedForTypedGenerator(
        _ value: Any,
        removedEmptyEnumCount: inout Int
    ) -> Any {
        if let dictionary = value as? [String: Any] {
            var result: [String: Any] = [:]

            for key in dictionary.keys.sorted() {
                if key == "enum", let values = dictionary[key] as? [Any], values.isEmpty {
                    removedEmptyEnumCount += 1
                    continue
                }

                if let child = dictionary[key] {
                    result[key] = normalizedForTypedGenerator(child, removedEmptyEnumCount: &removedEmptyEnumCount)
                }
            }

            return result
        }

        if let array = value as? [Any] {
            return array.map {
                normalizedForTypedGenerator($0, removedEmptyEnumCount: &removedEmptyEnumCount)
            }
        }

        return value
    }

    private func walk(_ value: Any, visit: (Any) -> Void) {
        visit(value)

        if let dictionary = value as? [String: Any] {
            dictionary.values.forEach { walk($0, visit: visit) }
            return
        }

        if let array = value as? [Any] {
            array.forEach { walk($0, visit: visit) }
        }
    }
}
