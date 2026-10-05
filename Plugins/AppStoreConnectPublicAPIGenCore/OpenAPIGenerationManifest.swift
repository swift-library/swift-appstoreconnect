import Foundation

public struct OpenAPIGenerationRootManifest: Codable, Equatable, Sendable {
    public var version: Int
    public var target: String
    public var module: String
    public var mode: String
    public var schema: String
    public var lock: String
    public var audit: String?
    public var partitionManifest: String
    public var baseCapabilityManifest: String
    public var appleGeneratorConfig: String
    public var activeTraitSource: String?
    public var defaultTraits: [String]
    public var fullTrait: String

    public static func load(from url: URL) throws -> OpenAPIGenerationRootManifest {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(OpenAPIGenerationRootManifest.self, from: data)
    }
}

public struct OpenAPITraitPartitionManifest: Codable, Equatable, Sendable {
    public var version: Int
    public var schema: String
    public var strategy: String
    public var defaultTraits: [String]
    public var fullTrait: String
    public var traits: [OpenAPITraitPartition]

    public static func load(from url: URL) throws -> OpenAPITraitPartitionManifest {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(OpenAPITraitPartitionManifest.self, from: data)
    }
}

public struct OpenAPITraitPartition: Codable, Equatable, Sendable {
    public var name: String
    public var compilationCondition: String
    public var defaultValue: Bool?
    public var aggregate: [String]?
    public var depth: String
    public var typeOverridePolicy: String
    public var selectors: OpenAPIGenerationSelectors

    enum CodingKeys: String, CodingKey {
        case name
        case compilationCondition
        case defaultValue = "default"
        case aggregate
        case depth
        case typeOverridePolicy
        case selectors
    }
}

public struct OpenAPISliceGenerationManifest: Codable, Equatable, Sendable {
    public var version: Int
    public var trait: String
    public var compilationCondition: String
    public var depth: String
    public var typeOverridePolicy: String
    public var selectors: OpenAPIGenerationSelectors
    public var appleGeneratorConfig: String?

    public static func load(from url: URL) throws -> OpenAPISliceGenerationManifest {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(OpenAPISliceGenerationManifest.self, from: data)
    }
}

public struct OpenAPIGenerationSelectors: Codable, Equatable, Sendable {
    public var capabilityManifest: String?
    public var operationIDs: [String]?
    public var tags: [String]?
    public var tagPrefixes: [String]?
    public var paths: [String]?
    public var additionalSchemas: [String]?
    public var allOperations: Bool?

    public init(
        capabilityManifest: String? = nil,
        operationIDs: [String]? = nil,
        tags: [String]? = nil,
        tagPrefixes: [String]? = nil,
        paths: [String]? = nil,
        additionalSchemas: [String]? = nil,
        allOperations: Bool? = nil
    ) {
        self.capabilityManifest = capabilityManifest
        self.operationIDs = operationIDs
        self.tags = tags
        self.tagPrefixes = tagPrefixes
        self.paths = paths
        self.additionalSchemas = additionalSchemas
        self.allOperations = allOperations
    }
}

public struct ActiveOpenAPIGenerationReport: Codable, Equatable, Sendable {
    public var activeTraits: [String]
    public var compilationConditions: [String]
    public var operationCount: Int
    public var pathCount: Int
    public var schemaCount: Int
    public var removedEmptyEnumCount: Int
    public var outputPath: String

    public init(
        activeTraits: [String],
        compilationConditions: [String],
        operationCount: Int,
        pathCount: Int,
        schemaCount: Int,
        removedEmptyEnumCount: Int,
        outputPath: String
    ) {
        self.activeTraits = activeTraits
        self.compilationConditions = compilationConditions
        self.operationCount = operationCount
        self.pathCount = pathCount
        self.schemaCount = schemaCount
        self.removedEmptyEnumCount = removedEmptyEnumCount
        self.outputPath = outputPath
    }
}

public enum OpenAPIGenerationManifestError: Error, CustomStringConvertible, Equatable {
    case missingTrait(String)
    case missingSlice(String)
    case missingTag(String)
    case missingTagPrefix(String)
    case missingPath(String)
    case missingOperation(String)
    case missingSchema(String)
    case invalidTarget(String)

    public var description: String {
        switch self {
        case let .missingTrait(trait):
            "trait \(trait) is not declared in the partition manifest"
        case let .missingSlice(trait):
            "slice manifest for trait \(trait) is missing"
        case let .missingTag(tag):
            "OpenAPI tag \(tag) is not present in the schema"
        case let .missingTagPrefix(prefix):
            "OpenAPI tag prefix \(prefix) did not match any schema operation"
        case let .missingPath(path):
            "OpenAPI path \(path) is not present in the schema"
        case let .missingOperation(operation):
            "OpenAPI operation \(operation) is not present in the schema"
        case let .missingSchema(schema):
            "OpenAPI component schema \(schema) is not present in the schema"
        case let .invalidTarget(target):
            "OpenAPI generation target \(target) is invalid"
        }
    }
}

public struct OpenAPIGenerationPlanner: Sendable {
    public init() {}

    public func writeActiveOpenAPI(
        generationManifestURL: URL,
        conditions: [String],
        outputURL: URL,
        stampURL: URL?
    ) throws -> ActiveOpenAPIGenerationReport {
        let plan = try activePlan(generationManifestURL: generationManifestURL, conditions: conditions)
        let result = try SelectedOpenAPITrimEmitter().writeTrimmedDocument(
            schemaURL: plan.schemaURL,
            operationIDs: plan.operationIDs,
            additionalSchemaNames: plan.additionalSchemas,
            outputURL: outputURL
        )
        let report = ActiveOpenAPIGenerationReport(
            activeTraits: plan.activeTraits,
            compilationConditions: conditions.sorted(),
            operationCount: result.operationCount,
            pathCount: result.pathCount,
            schemaCount: result.schemaCount,
            removedEmptyEnumCount: result.removedEmptyEnumCount,
            outputPath: outputURL.path
        )

        if let stampURL {
            try FileManager.default.createDirectory(
                at: stampURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            try encoder.encode(report).write(to: stampURL, options: .atomic)
        }

        return report
    }

    public func activePlan(
        generationManifestURL: URL,
        conditions: [String]
    ) throws -> ActiveOpenAPIPlan {
        let generation = try OpenAPIGenerationRootManifest.load(from: generationManifestURL)
        guard generation.target == "AppStoreConnectPublicAPI" else {
            throw OpenAPIGenerationManifestError.invalidTarget(generation.target)
        }

        let targetDirectory = generationManifestURL.deletingLastPathComponent()
        let packageRoot = targetDirectory.deletingLastPathComponent().deletingLastPathComponent()
        let schemaURL = resolve(generation.schema, relativeTo: targetDirectory, packageRoot: packageRoot)
        let partitionURL = resolve(generation.partitionManifest, relativeTo: targetDirectory, packageRoot: packageRoot)
        let partition = try OpenAPITraitPartitionManifest.load(from: partitionURL)
        let catalog = try OpenAPIOperationCatalog(schemaURL: schemaURL)
        let sliceDirectory = targetDirectory.appendingPathComponent("OpenAPISlices")
        let slices = try loadSliceManifests(from: sliceDirectory)
        let traitsByName = Dictionary(uniqueKeysWithValues: partition.traits.map { ($0.name, $0) })
        let activeTraits = try resolveActiveTraits(
            conditions: conditions,
            defaultTraits: generation.defaultTraits,
            partition: partition
        )

        var operationIDs: [String] = []
        var additionalSchemas: [String] = []

        for traitName in activeTraits {
            guard let trait = traitsByName[traitName] else {
                throw OpenAPIGenerationManifestError.missingTrait(traitName)
            }

            if let capabilityManifest = trait.selectors.capabilityManifest {
                let url = resolve(capabilityManifest, relativeTo: targetDirectory, packageRoot: packageRoot)
                operationIDs.append(contentsOf: try OpenAPICapabilityManifest.load(from: url).operationIDs())
            } else if let slice = slices[traitName] {
                operationIDs.append(contentsOf: try resolveOperations(
                    selectors: slice.selectors,
                    catalog: catalog
                ))
                additionalSchemas.append(contentsOf: try resolveAdditionalSchemas(
                    selectors: slice.selectors,
                    catalog: catalog
                ))
            } else if trait.selectors.allOperations == true {
                operationIDs.append(contentsOf: catalog.operationIDs)
            } else {
                throw OpenAPIGenerationManifestError.missingSlice(traitName)
            }
        }

        return ActiveOpenAPIPlan(
            schemaURL: schemaURL,
            activeTraits: activeTraits,
            operationIDs: orderedUnique(operationIDs),
            additionalSchemas: orderedUnique(additionalSchemas)
        )
    }

    private func resolveActiveTraits(
        conditions: [String],
        defaultTraits: [String],
        partition: OpenAPITraitPartitionManifest
    ) throws -> [String] {
        let conditionSet = Set(conditions)
        var traits: [String] = defaultTraits
        for trait in partition.traits where conditionSet.contains(trait.compilationCondition) {
            traits.append(trait.name)
        }
        if traits.isEmpty {
            traits = partition.defaultTraits
        }

        return try orderedUnique(expandAggregates(traits, partition: partition))
    }

    private func expandAggregates(
        _ traits: [String],
        partition: OpenAPITraitPartitionManifest
    ) throws -> [String] {
        let traitsByName = Dictionary(uniqueKeysWithValues: partition.traits.map { ($0.name, $0) })
        var result: [String] = []

        func append(_ traitName: String) throws {
            guard let trait = traitsByName[traitName] else {
                throw OpenAPIGenerationManifestError.missingTrait(traitName)
            }
            if let aggregate = trait.aggregate {
                for child in aggregate {
                    try append(child)
                }
            }
            result.append(traitName)
        }

        for trait in traits {
            try append(trait)
        }

        return result
    }

    private func resolveOperations(
        selectors: OpenAPIGenerationSelectors,
        catalog: OpenAPIOperationCatalog
    ) throws -> [String] {
        if selectors.allOperations == true {
            return catalog.operationIDs
        }

        var operations: [String] = []

        for operationID in selectors.operationIDs ?? [] {
            guard catalog.operationIDs.contains(operationID) else {
                throw OpenAPIGenerationManifestError.missingOperation(operationID)
            }
            operations.append(operationID)
        }

        for tag in selectors.tags ?? [] {
            let matches = catalog.operations.filter { $0.tags.contains(tag) }.map(\.operationID)
            if matches.isEmpty {
                throw OpenAPIGenerationManifestError.missingTag(tag)
            }
            operations.append(contentsOf: matches)
        }

        for prefix in selectors.tagPrefixes ?? [] {
            let matches = catalog.operations.filter { operation in
                operation.tags.contains { $0.hasPrefix(prefix) }
            }.map(\.operationID)
            if matches.isEmpty {
                throw OpenAPIGenerationManifestError.missingTagPrefix(prefix)
            }
            operations.append(contentsOf: matches)
        }

        for path in selectors.paths ?? [] {
            let matches = catalog.operations.filter { $0.path == path }.map(\.operationID)
            if matches.isEmpty {
                throw OpenAPIGenerationManifestError.missingPath(path)
            }
            operations.append(contentsOf: matches)
        }

        return operations
    }

    private func resolveAdditionalSchemas(
        selectors: OpenAPIGenerationSelectors,
        catalog: OpenAPIOperationCatalog
    ) throws -> [String] {
        for schema in selectors.additionalSchemas ?? [] where !catalog.schemaNames.contains(schema) {
            throw OpenAPIGenerationManifestError.missingSchema(schema)
        }
        return selectors.additionalSchemas ?? []
    }

    private func loadSliceManifests(from directory: URL) throws -> [String: OpenAPISliceGenerationManifest] {
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: nil
        ) else {
            return [:]
        }

        var slices: [String: OpenAPISliceGenerationManifest] = [:]
        for case let url as URL in enumerator where url.pathExtension == "json" {
            let manifest = try OpenAPISliceGenerationManifest.load(from: url)
            slices[manifest.trait] = manifest
        }
        return slices
    }

    private func resolve(_ path: String, relativeTo baseURL: URL, packageRoot: URL) -> URL {
        let targetRelativeURL = URL(fileURLWithPath: path, relativeTo: baseURL).standardizedFileURL
        if FileManager.default.fileExists(atPath: targetRelativeURL.path) {
            return targetRelativeURL
        }
        return URL(fileURLWithPath: path, relativeTo: packageRoot).standardizedFileURL
    }

    private func orderedUnique(_ values: [String]) -> [String] {
        var seen: Set<String> = []
        return values.filter { seen.insert($0).inserted }
    }
}

public struct ActiveOpenAPIPlan: Equatable, Sendable {
    public var schemaURL: URL
    public var activeTraits: [String]
    public var operationIDs: [String]
    public var additionalSchemas: [String]

    public init(
        schemaURL: URL,
        activeTraits: [String],
        operationIDs: [String],
        additionalSchemas: [String]
    ) {
        self.schemaURL = schemaURL
        self.activeTraits = activeTraits
        self.operationIDs = operationIDs
        self.additionalSchemas = additionalSchemas
    }
}

public struct OpenAPIOperationCatalog: Sendable {
    public var operations: [OpenAPIOperationCatalogEntry]
    public var schemaNames: Set<String>

    public var operationIDs: [String] {
        operations.map(\.operationID)
    }

    public init(schemaURL: URL) throws {
        let data = try Data(contentsOf: schemaURL)
        let object = try JSONSerialization.jsonObject(with: data)

        guard let root = object as? [String: Any] else {
            throw OpenAPISchemaAnalyzerError.invalidTopLevelJSON
        }
        guard let paths = root["paths"] as? [String: Any] else {
            throw OpenAPISchemaAnalyzerError.missingField("paths")
        }

        let schemas = ((root["components"] as? [String: Any])?["schemas"] as? [String: Any]) ?? [:]
        let methodNames = Set(["get", "put", "post", "delete", "options", "head", "patch", "trace"])
        var entries: [OpenAPIOperationCatalogEntry] = []

        for path in paths.keys.sorted() {
            guard let pathItem = paths[path] as? [String: Any] else {
                continue
            }

            for method in pathItem.keys.sorted() where methodNames.contains(method) {
                guard
                    let operation = pathItem[method] as? [String: Any],
                    let operationID = operation["operationId"] as? String
                else {
                    continue
                }

                entries.append(OpenAPIOperationCatalogEntry(
                    operationID: operationID,
                    method: method,
                    path: path,
                    tags: (operation["tags"] as? [String] ?? []).sorted()
                ))
            }
        }

        operations = entries.sorted { lhs, rhs in
            if lhs.operationID == rhs.operationID {
                return lhs.path < rhs.path
            }
            return lhs.operationID < rhs.operationID
        }
        schemaNames = Set(schemas.keys)
    }
}

public struct OpenAPIOperationCatalogEntry: Equatable, Sendable {
    public var operationID: String
    public var method: String
    public var path: String
    public var tags: [String]

    public init(operationID: String, method: String, path: String, tags: [String]) {
        self.operationID = operationID
        self.method = method
        self.path = path
        self.tags = tags
    }
}
