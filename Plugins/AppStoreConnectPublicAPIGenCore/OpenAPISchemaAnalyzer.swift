import Foundation

public struct SchemaAudit: Codable, Equatable, Sendable {
    public var schema: SchemaIdentity
    public var inventory: SchemaInventory

    public init(schema: SchemaIdentity, inventory: SchemaInventory) {
        self.schema = schema
        self.inventory = inventory
    }
}

public struct SchemaIdentity: Codable, Equatable, Sendable {
    public var openapi: String
    public var title: String
    public var version: String

    public init(openapi: String, title: String, version: String) {
        self.openapi = openapi
        self.title = title
        self.version = version
    }
}

public struct SchemaInventory: Codable, Equatable, Sendable {
    public var pathCount: Int
    public var operationCount: Int
    public var schemaCount: Int
    public var securitySchemes: [String]
    public var methodCounts: [CountByName]
    public var requestBodyContentTypes: [CountByName]
    public var responseContentTypes: [CountByName]
    public var uploadRelatedOperationCount: Int
    public var constructCounts: ConstructCounts
    public var unsupportedConstructCountForFirstGeneratorSlice: Int

    public init(
        pathCount: Int,
        operationCount: Int,
        schemaCount: Int,
        securitySchemes: [String],
        methodCounts: [CountByName],
        requestBodyContentTypes: [CountByName],
        responseContentTypes: [CountByName],
        uploadRelatedOperationCount: Int,
        constructCounts: ConstructCounts,
        unsupportedConstructCountForFirstGeneratorSlice: Int
    ) {
        self.pathCount = pathCount
        self.operationCount = operationCount
        self.schemaCount = schemaCount
        self.securitySchemes = securitySchemes
        self.methodCounts = methodCounts
        self.requestBodyContentTypes = requestBodyContentTypes
        self.responseContentTypes = responseContentTypes
        self.uploadRelatedOperationCount = uploadRelatedOperationCount
        self.constructCounts = constructCounts
        self.unsupportedConstructCountForFirstGeneratorSlice = unsupportedConstructCountForFirstGeneratorSlice
    }
}

public struct CountByName: Codable, Equatable, Sendable {
    public var name: String
    public var count: Int

    public init(name: String, count: Int) {
        self.name = name
        self.count = count
    }
}

public struct ConstructCounts: Codable, Equatable, Sendable {
    public var allOf: Int
    public var oneOf: Int
    public var anyOf: Int
    public var nullable: Int
    public var additionalProperties: Int
    public var binaryFormat: Int

    public init(
        allOf: Int,
        oneOf: Int,
        anyOf: Int,
        nullable: Int,
        additionalProperties: Int,
        binaryFormat: Int
    ) {
        self.allOf = allOf
        self.oneOf = oneOf
        self.anyOf = anyOf
        self.nullable = nullable
        self.additionalProperties = additionalProperties
        self.binaryFormat = binaryFormat
    }
}

public enum OpenAPISchemaAnalyzerError: Error, CustomStringConvertible, Equatable {
    case invalidTopLevelJSON
    case missingField(String)

    public var description: String {
        switch self {
        case .invalidTopLevelJSON:
            "OpenAPI schema must be a JSON object."
        case let .missingField(field):
            "OpenAPI schema is missing required field: \(field)"
        }
    }
}

public struct OpenAPISchemaAnalyzer: Sendable {
    public init() {}

    public func audit(schemaURL: URL) throws -> SchemaAudit {
        let data = try Data(contentsOf: schemaURL)
        let object = try JSONSerialization.jsonObject(with: data)

        guard let root = object as? [String: Any] else {
            throw OpenAPISchemaAnalyzerError.invalidTopLevelJSON
        }

        guard let openapi = root["openapi"] as? String else {
            throw OpenAPISchemaAnalyzerError.missingField("openapi")
        }
        guard
            let info = root["info"] as? [String: Any],
            let title = info["title"] as? String,
            let version = info["version"] as? String
        else {
            throw OpenAPISchemaAnalyzerError.missingField("info.title/version")
        }
        guard let paths = root["paths"] as? [String: Any] else {
            throw OpenAPISchemaAnalyzerError.missingField("paths")
        }

        let schemas = ((root["components"] as? [String: Any])?["schemas"] as? [String: Any]) ?? [:]
        let securitySchemes = ((root["components"] as? [String: Any])?["securitySchemes"] as? [String: Any]) ?? [:]
        let operations = collectOperations(paths: paths)
        let constructCounts = countConstructs(in: object)

        let inventory = SchemaInventory(
            pathCount: paths.count,
            operationCount: operations.count,
            schemaCount: schemas.count,
            securitySchemes: securitySchemes.keys.sorted(),
            methodCounts: countValues(operations.map(\.method)),
            requestBodyContentTypes: countValues(operations.flatMap(\.requestBodyContentTypes)),
            responseContentTypes: countValues(operations.flatMap(\.responseContentTypes)),
            uploadRelatedOperationCount: operations.filter(\.isUploadRelated).count,
            constructCounts: constructCounts,
            unsupportedConstructCountForFirstGeneratorSlice: constructCounts.oneOf
        )

        return SchemaAudit(
            schema: SchemaIdentity(openapi: openapi, title: title, version: version),
            inventory: inventory
        )
    }

    private func collectOperations(paths: [String: Any]) -> [SchemaOperation] {
        let methodNames = Set(["get", "put", "post", "delete", "options", "head", "patch", "trace"])

        return paths.flatMap { path, value -> [SchemaOperation] in
            guard let pathItem = value as? [String: Any] else {
                return []
            }

            return pathItem.compactMap { method, operationValue -> SchemaOperation? in
                guard methodNames.contains(method), let operation = operationValue as? [String: Any] else {
                    return nil
                }

                let operationID = operation["operationId"] as? String
                let summary = operation["summary"] as? String
                let searchable = [method, path, operationID, summary]
                    .compactMap { $0 }
                    .joined(separator: " ")
                    .lowercased()

                return SchemaOperation(
                    method: method,
                    path: path,
                    operationID: operationID,
                    summary: summary,
                    requestBodyContentTypes: contentTypes(fromRequestBody: operation["requestBody"]),
                    responseContentTypes: contentTypes(fromResponses: operation["responses"]),
                    isUploadRelated: searchable.contains("upload")
                )
            }
        }
        .sorted { lhs, rhs in
            if lhs.path == rhs.path {
                return lhs.method < rhs.method
            }
            return lhs.path < rhs.path
        }
    }

    private func contentTypes(fromRequestBody value: Any?) -> [String] {
        guard
            let requestBody = value as? [String: Any],
            let content = requestBody["content"] as? [String: Any]
        else {
            return []
        }

        return content.keys.sorted()
    }

    private func contentTypes(fromResponses value: Any?) -> [String] {
        guard let responses = value as? [String: Any] else {
            return []
        }

        return responses.values.flatMap { response -> [String] in
            guard
                let response = response as? [String: Any],
                let content = response["content"] as? [String: Any]
            else {
                return []
            }

            return Array(content.keys)
        }
        .sorted()
    }

    private func countValues(_ values: [String]) -> [CountByName] {
        Dictionary(grouping: values, by: { $0 })
            .map { CountByName(name: $0.key, count: $0.value.count) }
            .sorted { $0.name < $1.name }
    }

    private func countConstructs(in value: Any) -> ConstructCounts {
        var counts = ConstructCounts(
            allOf: 0,
            oneOf: 0,
            anyOf: 0,
            nullable: 0,
            additionalProperties: 0,
            binaryFormat: 0
        )

        walk(value) { item in
            guard let object = item as? [String: Any] else {
                return
            }

            if object["allOf"] != nil { counts.allOf += 1 }
            if object["oneOf"] != nil { counts.oneOf += 1 }
            if object["anyOf"] != nil { counts.anyOf += 1 }
            if object["nullable"] as? Bool == true { counts.nullable += 1 }
            if object["additionalProperties"] != nil { counts.additionalProperties += 1 }
            if object["format"] as? String == "binary" { counts.binaryFormat += 1 }
        }

        return counts
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

private struct SchemaOperation: Equatable {
    var method: String
    var path: String
    var operationID: String?
    var summary: String?
    var requestBodyContentTypes: [String]
    var responseContentTypes: [String]
    var isUploadRelated: Bool
}
