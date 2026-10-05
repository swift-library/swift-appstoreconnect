import AppStoreConnectCore
import AppStoreConnectWebSession
import Foundation

public struct AppStoreConnectAuthStatusInput: Sendable, Equatable {
    public var sessionFileURL: URL?
    public var requireSessionFile: Bool
    public var browserCookieFileURL: URL?
    public var includeCookieNames: Bool

    public init(
        sessionFileURL: URL? = nil,
        requireSessionFile: Bool = false,
        browserCookieFileURL: URL? = nil,
        includeCookieNames: Bool = false
    ) {
        self.sessionFileURL = sessionFileURL
        self.requireSessionFile = requireSessionFile
        self.browserCookieFileURL = browserCookieFileURL
        self.includeCookieNames = includeCookieNames
    }
}

public struct AppStoreConnectAuthLogoutInput: Sendable, Equatable {
    public var sessionFileURL: URL

    public init(sessionFileURL: URL) {
        self.sessionFileURL = sessionFileURL
    }
}

public struct AppStoreConnectAuthSessionSummary: Codable, Sendable, Equatable {
    public var authenticated: Bool
    public var source: String?
    public var accountID: String?
    public var accountEmail: String?
    public var teamID: String?
    public var teamName: String?
    public var expiresAt: Date?
    public var cookieCount: Int
    public var cookieNames: [String]
    public var diagnostics: [String]
    public var message: String

    public init(
        authenticated: Bool,
        source: String? = nil,
        accountID: String? = nil,
        accountEmail: String? = nil,
        teamID: String? = nil,
        teamName: String? = nil,
        expiresAt: Date? = nil,
        cookieCount: Int = 0,
        cookieNames: [String] = [],
        diagnostics: [String] = [],
        message: String
    ) {
        self.authenticated = authenticated
        self.source = source
        self.accountID = accountID
        self.accountEmail = accountEmail
        self.teamID = teamID
        self.teamName = teamName
        self.expiresAt = expiresAt
        self.cookieCount = cookieCount
        self.cookieNames = cookieNames
        self.diagnostics = diagnostics
        self.message = message
    }
}

public typealias AppStoreConnectAuthStatusResult = AppStoreConnectAuthSessionSummary

public struct AppStoreConnectAuthCheckResult: Codable, Sendable, Equatable {
    public var name: String
    public var source: String
    public var passed: Bool
    public var message: String

    public init(name: String, source: String, passed: Bool, message: String) {
        self.name = name
        self.source = source
        self.passed = passed
        self.message = message
    }
}

public struct AppStoreConnectAuthDoctorResult: Codable, Sendable, Equatable {
    public var healthy: Bool
    public var checks: [AppStoreConnectAuthCheckResult]
    public var status: AppStoreConnectAuthSessionSummary

    public init(
        healthy: Bool,
        checks: [AppStoreConnectAuthCheckResult],
        status: AppStoreConnectAuthSessionSummary
    ) {
        self.healthy = healthy
        self.checks = checks
        self.status = status
    }
}

public struct AppStoreConnectAuthLogoutPlan: Codable, Sendable, Equatable {
    public var sessionFilePath: String
    public var willRemove: Bool
    public var message: String

    public init(sessionFilePath: String, willRemove: Bool, message: String) {
        self.sessionFilePath = sessionFilePath
        self.willRemove = willRemove
        self.message = message
    }
}

public struct AppStoreConnectAuthLogoutResult: Codable, Sendable, Equatable {
    public var sessionFilePath: String
    public var removed: Bool
    public var message: String

    public init(sessionFilePath: String, removed: Bool, message: String) {
        self.sessionFilePath = sessionFilePath
        self.removed = removed
        self.message = message
    }
}

public struct AppStoreConnectAuthCommands: Sendable {
    public var environment: [String: String]

    public init(environment: [String: String] = ProcessInfo.processInfo.environment) {
        self.environment = environment
    }

    public func status(
        _ input: AppStoreConnectAuthStatusInput = AppStoreConnectAuthStatusInput(),
        now: Date = Date()
    ) async -> AppStoreConnectAuthStatusResult {
        await resolveSession(input, now: now)
    }

    public func doctor(
        _ input: AppStoreConnectAuthStatusInput = AppStoreConnectAuthStatusInput(),
        now: Date = Date()
    ) async -> AppStoreConnectAuthDoctorResult {
        let checks = await authChecks(input, now: now)
        let status = await resolveSession(input, now: now)
        return AppStoreConnectAuthDoctorResult(
            healthy: status.authenticated,
            checks: checks,
            status: status
        )
    }

    public static func planLogout(_ input: AppStoreConnectAuthLogoutInput) -> AppStoreConnectAuthLogoutPlan {
        let path = input.sessionFileURL.path
        let exists = FileManager.default.fileExists(atPath: path)
        return AppStoreConnectAuthLogoutPlan(
            sessionFilePath: path,
            willRemove: exists,
            message: exists
                ? "Dry run: web session file would be removed."
                : "Dry run: web session file does not exist."
        )
    }

    public func logout(_ input: AppStoreConnectAuthLogoutInput) throws -> AppStoreConnectAuthLogoutResult {
        let path = input.sessionFileURL.path
        guard FileManager.default.fileExists(atPath: path) else {
            return AppStoreConnectAuthLogoutResult(
                sessionFilePath: path,
                removed: false,
                message: "Web session file does not exist."
            )
        }

        try FileManager.default.removeItem(at: input.sessionFileURL)
        return AppStoreConnectAuthLogoutResult(
            sessionFilePath: path,
            removed: true,
            message: "Removed web session file."
        )
    }

    private func resolveSession(
        _ input: AppStoreConnectAuthStatusInput,
        now: Date
    ) async -> AppStoreConnectAuthStatusResult {
        var diagnostics: [String] = []

        if let sessionFileURL = input.sessionFileURL {
            let exists = FileManager.default.fileExists(atPath: sessionFileURL.path)
            if input.requireSessionFile || exists {
                do {
                    let session = try await SessionFileWebSessionProvider(fileURL: sessionFileURL)
                        .session(now: now)
                    return Self.summary(
                        session,
                        includeCookieNames: input.includeCookieNames,
                        message: "Authenticated with web session file."
                    )
                } catch {
                    diagnostics.append("session-file: \(error)")
                    if input.requireSessionFile {
                        return Self.unauthenticated(diagnostics: diagnostics)
                    }
                }
            }
        }

        if environment["ASC_WEB_SESSION_COOKIES"]?.isEmpty == false {
            do {
                let session = try await EnvironmentWebSessionProvider(environment: environment)
                    .session(now: now)
                return Self.summary(
                    session,
                    includeCookieNames: input.includeCookieNames,
                    message: "Authenticated with environment web session cookies."
                )
            } catch {
                diagnostics.append("environment: \(error)")
            }
        }

        if let browserCookieFileURL = input.browserCookieFileURL {
            do {
                let session = try await BrowserCookieFileWebSessionProvider(fileURL: browserCookieFileURL)
                    .session(now: now)
                return Self.summary(
                    session,
                    includeCookieNames: input.includeCookieNames,
                    message: "Authenticated with browser cookie file."
                )
            } catch {
                diagnostics.append("browser-cookie-file: \(error)")
            }
        }

        if diagnostics.isEmpty {
            diagnostics.append(
                "No usable web session source configured. Set ASC_WEB_SESSION_COOKIES, pass --session-file, or pass --browser-cookie-file."
            )
        }
        return Self.unauthenticated(diagnostics: diagnostics)
    }

    private func authChecks(
        _ input: AppStoreConnectAuthStatusInput,
        now: Date
    ) async -> [AppStoreConnectAuthCheckResult] {
        var checks: [AppStoreConnectAuthCheckResult] = []

        if let sessionFileURL = input.sessionFileURL {
            checks.append(await check(
                name: "session-file",
                source: sessionFileURL.path
            ) {
                _ = try await SessionFileWebSessionProvider(fileURL: sessionFileURL)
                    .session(now: now)
            })
        }

        checks.append(await check(
            name: "environment",
            source: "ASC_WEB_SESSION_COOKIES"
        ) {
            _ = try await EnvironmentWebSessionProvider(environment: environment)
                .session(now: now)
        })

        if let browserCookieFileURL = input.browserCookieFileURL {
            checks.append(await check(
                name: "browser-cookie-file",
                source: browserCookieFileURL.path
            ) {
                _ = try await BrowserCookieFileWebSessionProvider(fileURL: browserCookieFileURL)
                    .session(now: now)
            })
        }

        return checks
    }

    private func check(
        name: String,
        source: String,
        probe: () async throws -> Void
    ) async -> AppStoreConnectAuthCheckResult {
        do {
            try await probe()
            return AppStoreConnectAuthCheckResult(
                name: name,
                source: source,
                passed: true,
                message: "Usable."
            )
        } catch {
            return AppStoreConnectAuthCheckResult(
                name: name,
                source: source,
                passed: false,
                message: "\(error)"
            )
        }
    }

    private static func summary(
        _ session: WebSession,
        includeCookieNames: Bool,
        message: String
    ) -> AppStoreConnectAuthSessionSummary {
        AppStoreConnectAuthSessionSummary(
            authenticated: true,
            source: session.source.rawValue,
            accountID: session.account?.identifier,
            accountEmail: session.account?.email,
            teamID: session.account?.teamID,
            teamName: session.account?.teamName,
            expiresAt: session.expiresAt,
            cookieCount: session.cookies.count,
            cookieNames: includeCookieNames ? session.cookies.map(\.name).sorted() : [],
            diagnostics: session.diagnostics.map { "\($0.code): \($0.message)" },
            message: message
        )
    }

    private static func unauthenticated(diagnostics: [String]) -> AppStoreConnectAuthSessionSummary {
        AppStoreConnectAuthSessionSummary(
            authenticated: false,
            diagnostics: diagnostics,
            message: "No usable web session is available."
        )
    }
}
