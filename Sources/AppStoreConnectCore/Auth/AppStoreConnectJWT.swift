import CryptoKit
import Foundation

public protocol AppStoreConnectClock: Sendable {
    var now: Date { get }
}

public struct AppStoreConnectSystemClock: AppStoreConnectClock, Sendable, Equatable {
    public init() {}

    public var now: Date {
        Date()
    }
}

public struct AppStoreConnectFixedClock: AppStoreConnectClock, Sendable, Equatable {
    public var now: Date

    public init(now: Date) {
        self.now = now
    }
}

public enum AppStoreConnectJWTSubject: Sendable, Equatable {
    case team(issuerID: String)
    case individualUser
}

public struct AppStoreConnectJWTSigningKey: Sendable {
    public var keyID: String

    private var privateKey: P256.Signing.PrivateKey

    public init(keyID: String, pemRepresentation: String) throws {
        guard !keyID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AppStoreConnectError.authenticationFailed("API key ID is empty.")
        }

        do {
            self.keyID = keyID
            self.privateKey = try P256.Signing.PrivateKey(pemRepresentation: pemRepresentation)
        } catch {
            throw AppStoreConnectError.authenticationFailed("Could not load App Store Connect private key: \(error)")
        }
    }

    public init(keyID: String, p8Data: Data) throws {
        guard let pem = String(data: p8Data, encoding: .utf8) else {
            throw AppStoreConnectError.authenticationFailed("Private key data is not valid UTF-8 PEM.")
        }

        try self.init(keyID: keyID, pemRepresentation: pem)
    }

    public static func load(keyID: String, from url: URL) throws -> AppStoreConnectJWTSigningKey {
        try AppStoreConnectJWTSigningKey(keyID: keyID, p8Data: Data(contentsOf: url))
    }

    func signature(for signingInput: Data) throws -> Data {
        try privateKey.signature(for: signingInput).rawRepresentation
    }
}

public struct AppStoreConnectJWTSigner: Sendable {
    public static let defaultAudience = "appstoreconnect-v1"
    public static let maximumStandardLifetime: TimeInterval = 20 * 60

    public var signingKey: AppStoreConnectJWTSigningKey
    public var subject: AppStoreConnectJWTSubject
    public var audience: String
    public var lifetime: TimeInterval
    public var maximumLifetime: TimeInterval
    public var clock: any AppStoreConnectClock

    public init(
        signingKey: AppStoreConnectJWTSigningKey,
        subject: AppStoreConnectJWTSubject,
        audience: String = AppStoreConnectJWTSigner.defaultAudience,
        lifetime: TimeInterval = AppStoreConnectJWTSigner.maximumStandardLifetime,
        maximumLifetime: TimeInterval = AppStoreConnectJWTSigner.maximumStandardLifetime,
        clock: any AppStoreConnectClock = AppStoreConnectSystemClock()
    ) throws {
        self.signingKey = signingKey
        self.subject = subject
        self.audience = audience
        self.lifetime = lifetime
        self.maximumLifetime = maximumLifetime
        self.clock = clock

        try validate()
    }

    public func token(scope: [String] = []) throws -> String {
        try validate()

        let issuedAt = Int(clock.now.timeIntervalSince1970.rounded(.down))
        let expiresAt = issuedAt + Int(lifetime.rounded(.down))
        let header = JWTHeader(kid: signingKey.keyID)
        let payload = try JWTPayload(
            subject: subject,
            issuedAt: issuedAt,
            expiresAt: expiresAt,
            audience: audience,
            scope: scope
        )

        let encodedHeader = try encodeJWTPart(header)
        let encodedPayload = try encodeJWTPart(payload)
        let signingInput = "\(encodedHeader).\(encodedPayload)"
        let signature = try signingKey.signature(for: Data(signingInput.utf8))
        return "\(signingInput).\(signature.appStoreConnectBase64URLString())"
    }

    private func validate() throws {
        guard !audience.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AppStoreConnectError.authenticationFailed("JWT audience is empty.")
        }

        guard lifetime > 0 else {
            throw AppStoreConnectError.authenticationFailed("JWT lifetime must be greater than zero.")
        }

        guard lifetime <= maximumLifetime else {
            throw AppStoreConnectError.authenticationFailed(
                "JWT lifetime \(Int(lifetime)) seconds exceeds maximum \(Int(maximumLifetime)) seconds."
            )
        }

        if case let .team(issuerID) = subject {
            guard !issuerID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw AppStoreConnectError.authenticationFailed("Issuer ID is empty.")
            }
        }
    }
}

public struct AppStoreConnectJWTCredential: AppStoreConnectCredential, Sendable {
    public var signer: AppStoreConnectJWTSigner
    public var scope: [String]

    public init(signer: AppStoreConnectJWTSigner, scope: [String] = []) {
        self.signer = signer
        self.scope = scope
    }

    public func token() throws -> String {
        try signer.token(scope: scope)
    }

    public func authorizationHeaderValue() async throws -> String {
        "Bearer \(try token())"
    }
}

public actor AppStoreConnectCachedJWTCredential: AppStoreConnectCredential {
    public var signer: AppStoreConnectJWTSigner
    public var scope: [String]
    public var refreshSkew: TimeInterval

    private var cachedToken: String?
    private var cachedExpiresAt: Date?

    public init(
        signer: AppStoreConnectJWTSigner,
        scope: [String] = [],
        refreshSkew: TimeInterval = 30
    ) {
        self.signer = signer
        self.scope = scope
        self.refreshSkew = max(0, refreshSkew)
    }

    public func token() throws -> String {
        let now = signer.clock.now

        if let cachedToken,
            let cachedExpiresAt,
            now.addingTimeInterval(refreshSkew) < cachedExpiresAt
        {
            return cachedToken
        }

        let token = try signer.token(scope: scope)
        cachedToken = token
        cachedExpiresAt = now.addingTimeInterval(signer.lifetime)
        return token
    }

    public func authorizationHeaderValue() async throws -> String {
        "Bearer \(try token())"
    }

    public func invalidate() {
        cachedToken = nil
        cachedExpiresAt = nil
    }
}

private struct JWTHeader: Encodable {
    var alg = "ES256"
    var kid: String
    var typ = "JWT"
}

private struct JWTPayload: Encodable {
    var aud: String
    var exp: Int
    var iat: Int
    var iss: String?
    var scope: [String]?
    var sub: String?

    init(
        subject: AppStoreConnectJWTSubject,
        issuedAt: Int,
        expiresAt: Int,
        audience: String,
        scope: [String]
    ) throws {
        self.aud = audience
        self.exp = expiresAt
        self.iat = issuedAt
        self.scope = scope.isEmpty ? nil : scope

        switch subject {
        case let .team(issuerID):
            self.iss = issuerID
            self.sub = nil
        case .individualUser:
            self.iss = nil
            self.sub = "user"
        }
    }
}

private func encodeJWTPart<T: Encodable>(_ value: T) throws -> String {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
    return try encoder.encode(value).appStoreConnectBase64URLString()
}

private extension Data {
    func appStoreConnectBase64URLString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
