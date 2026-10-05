import Foundation

public enum AppStoreConnectService: Sendable, Equatable {
    case publicAPI
    case irisAPI
}

public struct AppStoreConnectEnvironment: Sendable, Equatable {
    public var service: AppStoreConnectService
    public var baseURL: URL

    public init(service: AppStoreConnectService, baseURL: URL) {
        self.service = service
        self.baseURL = baseURL
    }

    public static let publicAPI = AppStoreConnectEnvironment(
        service: .publicAPI,
        baseURL: URL(string: "https://api.appstoreconnect.apple.com")!
    )

    public static let irisAPI = AppStoreConnectEnvironment(
        service: .irisAPI,
        baseURL: URL(string: "https://appstoreconnect.apple.com/iris/v1")!
    )
}
