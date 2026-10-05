import AppStoreConnectCore
import Foundation

public struct EnvironmentWebSessionProvider: WebSessionProvider {
    public var environment: [String: String]
    public var cookieHeaderVariable: String
    public var expiresAtVariable: String
    public var accountIdentifierVariable: String
    public var accountEmailVariable: String

    public init(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        cookieHeaderVariable: String = "ASC_WEB_SESSION_COOKIES",
        expiresAtVariable: String = "ASC_WEB_SESSION_EXPIRES_AT",
        accountIdentifierVariable: String = "ASC_WEB_SESSION_ACCOUNT_ID",
        accountEmailVariable: String = "ASC_WEB_SESSION_ACCOUNT_EMAIL"
    ) {
        self.environment = environment
        self.cookieHeaderVariable = cookieHeaderVariable
        self.expiresAtVariable = expiresAtVariable
        self.accountIdentifierVariable = accountIdentifierVariable
        self.accountEmailVariable = accountEmailVariable
    }

    public func session(now: Date) async throws -> WebSession {
        guard let cookieHeader = environment[cookieHeaderVariable], !cookieHeader.isEmpty else {
            throw AppStoreConnectError.authenticationFailed(
                "Missing \(cookieHeaderVariable) environment cookie header."
            )
        }

        let cookies = try WebSessionCookieHeaderParser.parse(cookieHeader)
        let account = WebSessionAccount(
            identifier: environment[accountIdentifierVariable],
            email: environment[accountEmailVariable]
        )
        let session = WebSession(
            cookieStore: cookies,
            expiresAt: environment[expiresAtVariable].flatMap(WebSessionDateParser.parse),
            account: account,
            source: .environment,
            diagnostics: [
                WebSessionDiagnostic(
                    source: .environment,
                    code: "environment-cookie-header",
                    message: "Loaded web session cookies from \(cookieHeaderVariable)."
                ),
            ]
        )

        return try session.validated(now: now)
    }
}
