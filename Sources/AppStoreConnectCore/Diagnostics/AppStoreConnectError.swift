public enum AppStoreConnectError: Error, Sendable, Equatable, CustomStringConvertible {
    case invalidConfiguration(String)
    case authenticationFailed(String)
    case requestFailed(statusCode: Int, message: String?)
    case decodingFailed(String)
    case uploadFailed(String)
    case unsupportedCapability(String)

    public var description: String {
        switch self {
        case let .invalidConfiguration(message):
            "Invalid configuration: \(message)"
        case let .authenticationFailed(message):
            "Authentication failed: \(message)"
        case let .requestFailed(statusCode, message):
            "Request failed with status \(statusCode): \(message ?? "No response message.")"
        case let .decodingFailed(message):
            "Decoding failed: \(message)"
        case let .uploadFailed(message):
            "Upload failed: \(message)"
        case let .unsupportedCapability(message):
            "Unsupported capability: \(message)"
        }
    }
}
