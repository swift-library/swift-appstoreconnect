import AppStoreConnectCore

@available(*, deprecated, renamed: "AppStoreConnectPublicClient")
public typealias PublicAPIClient = AppStoreConnectPublicClient

public struct RawPublicAPIClient: Sendable {
    public var environment: AppStoreConnectEnvironment
    public var transport: any AppStoreConnectTransport

    public init(
        environment: AppStoreConnectEnvironment = .publicAPI,
        transport: any AppStoreConnectTransport
    ) {
        self.environment = environment
        self.transport = transport
    }
}

public enum PublicAPICapability: String, Sendable, CaseIterable {
    case apps
    case builds
    case testFlight = "testflight"
    case mediaAssets = "media-assets"
    case reports
    case users
    case certificatesProfiles = "certificates-profiles"
}
