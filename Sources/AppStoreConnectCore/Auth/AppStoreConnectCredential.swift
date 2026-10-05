public protocol AppStoreConnectCredential: Sendable {
    func authorizationHeaderValue() async throws -> String
}

public struct AppStoreConnectBearerToken: AppStoreConnectCredential, Sendable, Equatable {
    public var token: String

    public init(token: String) {
        self.token = token
    }

    public func authorizationHeaderValue() async throws -> String {
        "Bearer \(token)"
    }
}

public struct AppStoreConnectStaticCredential: AppStoreConnectCredential, Sendable, Equatable {
    public var headerValue: String

    public init(headerValue: String) {
        self.headerValue = headerValue
    }

    public func authorizationHeaderValue() async throws -> String {
        headerValue
    }
}
