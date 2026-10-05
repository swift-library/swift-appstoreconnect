import Foundation

public enum OpenAPISelectionError: Error, CustomStringConvertible, Equatable {
    case emptySelection
    case emptyCapability(String)
    case duplicateCapability(String)
    case duplicateOperation(String)

    public var description: String {
        switch self {
        case .emptySelection:
            "selection must contain at least one operation"
        case let .emptyCapability(capability):
            "capability \(capability) must contain at least one operation"
        case let .duplicateCapability(capability):
            "capability \(capability) is declared more than once"
        case let .duplicateOperation(operation):
            "operation \(operation) is declared more than once"
        }
    }
}

public struct OpenAPISelection: Codable, Equatable, Sendable {
    public var schemaVersion: String
    public var operations: [String]

    public init(schemaVersion: String, operations: [String]) {
        self.schemaVersion = schemaVersion
        self.operations = operations
    }

    public static func load(from url: URL) throws -> OpenAPISelection {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(OpenAPISelection.self, from: data)
    }

    public func operationIDs() throws -> [String] {
        try Self.validateOperations(operations)
    }

    static func validateOperations(_ operations: [String]) throws -> [String] {
        if operations.isEmpty {
            throw OpenAPISelectionError.emptySelection
        }

        var seen: Set<String> = []
        var result: [String] = []

        for operation in operations {
            if !seen.insert(operation).inserted {
                throw OpenAPISelectionError.duplicateOperation(operation)
            }
            result.append(operation)
        }

        return result
    }
}

public struct OpenAPICapabilityManifest: Codable, Equatable, Sendable {
    public var schemaVersion: String
    public var capabilities: [OpenAPICapability]

    public init(schemaVersion: String, capabilities: [OpenAPICapability]) {
        self.schemaVersion = schemaVersion
        self.capabilities = capabilities
    }

    public static func load(from url: URL) throws -> OpenAPICapabilityManifest {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(OpenAPICapabilityManifest.self, from: data)
    }

    public func operationIDs() throws -> [String] {
        if capabilities.isEmpty {
            throw OpenAPISelectionError.emptySelection
        }

        var seenCapabilities: Set<String> = []
        var operations: [String] = []

        for capability in capabilities {
            if !seenCapabilities.insert(capability.id).inserted {
                throw OpenAPISelectionError.duplicateCapability(capability.id)
            }

            if capability.operations.isEmpty {
                throw OpenAPISelectionError.emptyCapability(capability.id)
            }

            operations.append(contentsOf: capability.operations)
        }

        return try OpenAPISelection.validateOperations(operations)
    }
}

public struct OpenAPICapability: Codable, Equatable, Sendable {
    public var id: String
    public var title: String
    public var operations: [String]

    public init(id: String, title: String, operations: [String]) {
        self.id = id
        self.title = title
        self.operations = operations
    }
}
