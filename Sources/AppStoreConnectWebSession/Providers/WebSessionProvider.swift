import Foundation

public protocol WebSessionProvider: Sendable {
    func session(now: Date) async throws -> WebSession
}

public extension WebSessionProvider {
    func session() async throws -> WebSession {
        try await session(now: Date())
    }
}

public struct StaticWebSessionProvider: WebSessionProvider {
    public var webSession: WebSession

    public init(_ webSession: WebSession) {
        self.webSession = webSession
    }

    public func session(now: Date) async throws -> WebSession {
        try webSession.withSource(.staticSession).validated(now: now)
    }
}
