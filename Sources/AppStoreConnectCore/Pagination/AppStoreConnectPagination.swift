import Foundation

public struct AppStoreConnectPaginationLinks: Codable, Sendable, Equatable {
    public var first: URL?
    public var next: URL?
    public var selfURL: URL?

    public init(first: URL? = nil, next: URL? = nil, selfURL: URL? = nil) {
        self.first = first
        self.next = next
        self.selfURL = selfURL
    }
}

public struct AppStoreConnectPage<Resource: Sendable>: Sendable {
    public var data: [Resource]
    public var links: AppStoreConnectPaginationLinks

    public init(data: [Resource], links: AppStoreConnectPaginationLinks = AppStoreConnectPaginationLinks()) {
        self.data = data
        self.links = links
    }
}

public struct AppStoreConnectPaginator: Sendable {
    public init() {}

    public func nextRequest(after request: AppStoreConnectRequest, links: AppStoreConnectPaginationLinks) -> AppStoreConnectRequest? {
        guard let next = links.next else {
            return nil
        }

        return AppStoreConnectRequest(
            method: .get,
            path: next.absoluteString,
            headers: request.headers
        )
    }
}
