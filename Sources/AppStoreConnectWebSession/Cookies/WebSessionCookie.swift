import Foundation

public struct WebSessionCookie: Codable, Sendable, Equatable {
    public var name: String
    public var value: String
    public var domain: String?
    public var path: String?
    public var expiresAt: Date?
    public var isSecure: Bool
    public var isHTTPOnly: Bool

    public init(
        name: String,
        value: String,
        domain: String? = nil,
        path: String? = nil,
        expiresAt: Date? = nil,
        isSecure: Bool = false,
        isHTTPOnly: Bool = false
    ) {
        self.name = name
        self.value = value
        self.domain = domain
        self.path = path
        self.expiresAt = expiresAt
        self.isSecure = isSecure
        self.isHTTPOnly = isHTTPOnly
    }

    public func isExpired(now: Date = Date()) -> Bool {
        guard let expiresAt else {
            return false
        }

        return expiresAt <= now
    }
}
