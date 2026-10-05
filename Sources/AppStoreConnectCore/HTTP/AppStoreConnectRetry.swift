import Foundation

public struct AppStoreConnectRetryPolicy: Sendable, Equatable {
    public static let transientStatusCodes: Set<Int> = [429, 500, 502, 503, 504]
    public static let idempotentMethods: Set<String> = ["GET", "HEAD", "OPTIONS"]

    public var maxRetries: Int
    public var initialDelay: TimeInterval
    public var backoffMultiplier: Double
    public var maximumDelay: TimeInterval?
    public var retryableStatusCodes: Set<Int>
    public var retryableMethods: Set<String>
    public var respectsRetryAfterHeader: Bool
    public var retriesTransportErrors: Bool

    public init(
        maxRetries: Int,
        initialDelay: TimeInterval,
        backoffMultiplier: Double = 1,
        maximumDelay: TimeInterval? = nil,
        retryableStatusCodes: Set<Int> = Self.transientStatusCodes,
        retryableMethods: Set<String> = Self.idempotentMethods,
        respectsRetryAfterHeader: Bool = true,
        retriesTransportErrors: Bool = true
    ) {
        self.maxRetries = max(0, maxRetries)
        self.initialDelay = max(0, initialDelay)
        self.backoffMultiplier = max(1, backoffMultiplier)
        self.maximumDelay = maximumDelay.map { max(0, $0) }
        self.retryableStatusCodes = retryableStatusCodes
        self.retryableMethods = Set(retryableMethods.map { $0.uppercased() })
        self.respectsRetryAfterHeader = respectsRetryAfterHeader
        self.retriesTransportErrors = retriesTransportErrors
    }

    public static var never: AppStoreConnectRetryPolicy {
        AppStoreConnectRetryPolicy(maxRetries: 0, initialDelay: 0)
    }

    public static func fixed(
        maxRetries: Int,
        delay: TimeInterval,
        retryableStatusCodes: Set<Int> = Self.transientStatusCodes,
        retryableMethods: Set<String> = Self.idempotentMethods,
        respectsRetryAfterHeader: Bool = true,
        retriesTransportErrors: Bool = true
    ) -> AppStoreConnectRetryPolicy {
        AppStoreConnectRetryPolicy(
            maxRetries: maxRetries,
            initialDelay: delay,
            retryableStatusCodes: retryableStatusCodes,
            retryableMethods: retryableMethods,
            respectsRetryAfterHeader: respectsRetryAfterHeader,
            retriesTransportErrors: retriesTransportErrors
        )
    }

    public static func exponentialBackoff(
        maxRetries: Int,
        initialDelay: TimeInterval,
        multiplier: Double = 2,
        maximumDelay: TimeInterval? = nil,
        retryableStatusCodes: Set<Int> = Self.transientStatusCodes,
        retryableMethods: Set<String> = Self.idempotentMethods,
        respectsRetryAfterHeader: Bool = true,
        retriesTransportErrors: Bool = true
    ) -> AppStoreConnectRetryPolicy {
        AppStoreConnectRetryPolicy(
            maxRetries: maxRetries,
            initialDelay: initialDelay,
            backoffMultiplier: multiplier,
            maximumDelay: maximumDelay,
            retryableStatusCodes: retryableStatusCodes,
            retryableMethods: retryableMethods,
            respectsRetryAfterHeader: respectsRetryAfterHeader,
            retriesTransportErrors: retriesTransportErrors
        )
    }

    public static func upload(
        maxRetries: Int,
        delay: TimeInterval,
        retryableStatusCodes: Set<Int> = Self.transientStatusCodes,
        respectsRetryAfterHeader: Bool = true,
        retriesTransportErrors: Bool = true
    ) -> AppStoreConnectRetryPolicy {
        AppStoreConnectRetryPolicy(
            maxRetries: maxRetries,
            initialDelay: delay,
            retryableStatusCodes: retryableStatusCodes,
            retryableMethods: ["POST", "PUT"],
            respectsRetryAfterHeader: respectsRetryAfterHeader,
            retriesTransportErrors: retriesTransportErrors
        )
    }

    public func retryDelay(
        after response: AppStoreConnectResponse,
        for request: AppStoreConnectRequest,
        retryIndex: Int
    ) -> TimeInterval? {
        guard retryIndex < maxRetries else {
            return nil
        }

        guard retryableStatusCodes.contains(response.statusCode) else {
            return nil
        }

        guard retriesMethod(request.method) else {
            return nil
        }

        if respectsRetryAfterHeader, let retryAfter = response.retryAfterDelay {
            return retryAfter
        }

        return computedDelay(for: retryIndex)
    }

    public func retryDelay(
        after error: any Error,
        for request: AppStoreConnectRequest,
        retryIndex: Int
    ) -> TimeInterval? {
        guard retryIndex < maxRetries else {
            return nil
        }

        guard retriesMethod(request.method) else {
            return nil
        }

        if case let AppStoreConnectError.requestFailed(statusCode, _) = error {
            guard retryableStatusCodes.contains(statusCode) else {
                return nil
            }
            return computedDelay(for: retryIndex)
        }

        guard retriesTransportErrors else {
            return nil
        }

        return computedDelay(for: retryIndex)
    }

    private func retriesMethod(_ method: String) -> Bool {
        retryableMethods.contains(method.uppercased())
    }

    private func computedDelay(for retryIndex: Int) -> TimeInterval {
        let exponentialDelay = initialDelay * pow(backoffMultiplier, Double(retryIndex))

        if let maximumDelay {
            return min(exponentialDelay, maximumDelay)
        }

        return exponentialDelay
    }
}

public typealias AppStoreConnectRetrySleep = @Sendable (TimeInterval) async throws -> Void

public struct AppStoreConnectRetryingTransport: AppStoreConnectTransport {
    public var base: any AppStoreConnectTransport
    public var policy: AppStoreConnectRetryPolicy
    public var sleep: AppStoreConnectRetrySleep

    public init(
        base: any AppStoreConnectTransport,
        policy: AppStoreConnectRetryPolicy,
        sleep: @escaping AppStoreConnectRetrySleep = AppStoreConnectRetryingTransport.defaultSleep
    ) {
        self.base = base
        self.policy = policy
        self.sleep = sleep
    }

    public func send(
        _ request: AppStoreConnectRequest,
        in environment: AppStoreConnectEnvironment
    ) async throws -> AppStoreConnectResponse {
        var retryIndex = 0

        while true {
            do {
                let response = try await base.send(request, in: environment)

                guard let delay = policy.retryDelay(after: response, for: request, retryIndex: retryIndex) else {
                    return response
                }

                try await sleep(delay)
                retryIndex += 1
            } catch {
                guard let delay = policy.retryDelay(after: error, for: request, retryIndex: retryIndex) else {
                    throw error
                }

                try await sleep(delay)
                retryIndex += 1
            }
        }
    }

    public static func defaultSleep(_ seconds: TimeInterval) async throws {
        guard seconds > 0 else {
            return
        }

        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}

public struct AppStoreConnectRetryingDownloadTransport: AppStoreConnectDownloadTransport {
    public var base: any AppStoreConnectDownloadTransport
    public var policy: AppStoreConnectRetryPolicy
    public var sleep: AppStoreConnectRetrySleep

    public init(
        base: any AppStoreConnectDownloadTransport,
        policy: AppStoreConnectRetryPolicy,
        sleep: @escaping AppStoreConnectRetrySleep = AppStoreConnectRetryingTransport.defaultSleep
    ) {
        self.base = base
        self.policy = policy
        self.sleep = sleep
    }

    public func send(
        _ request: AppStoreConnectRequest,
        in environment: AppStoreConnectEnvironment
    ) async throws -> AppStoreConnectResponse {
        try await AppStoreConnectRetryingTransport(
            base: base,
            policy: policy,
            sleep: sleep
        ).send(request, in: environment)
    }

    public func download(
        _ request: AppStoreConnectRequest,
        in environment: AppStoreConnectEnvironment
    ) async throws -> AppStoreConnectDownloadResponse {
        var retryIndex = 0

        while true {
            do {
                let response = try await base.download(request, in: environment)

                guard let delay = policy.retryDelay(after: response.response, for: request, retryIndex: retryIndex) else {
                    return response
                }

                try? FileManager.default.removeItem(at: response.fileURL)
                try await sleep(delay)
                retryIndex += 1
            } catch {
                guard let delay = policy.retryDelay(after: error, for: request, retryIndex: retryIndex) else {
                    throw error
                }

                try await sleep(delay)
                retryIndex += 1
            }
        }
    }
}

public extension AppStoreConnectResponse {
    var retryAfterDelay: TimeInterval? {
        guard let value = headers.caseInsensitiveValue(for: "Retry-After") else {
            return nil
        }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let seconds = TimeInterval(trimmed), seconds >= 0 else {
            return nil
        }

        return seconds
    }
}

extension Dictionary where Key == String, Value == String {
    func caseInsensitiveValue(for name: String) -> String? {
        first { $0.key.caseInsensitiveCompare(name) == .orderedSame }?.value
    }
}
