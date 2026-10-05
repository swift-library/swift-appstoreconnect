import AppStoreConnectCore
import Foundation
import HTTPTypes
import OpenAPIRuntime
import OpenAPIURLSession

public struct AppStoreConnectOpenAPIAuthenticationMiddleware: ClientMiddleware {
    public var credential: any AppStoreConnectCredential

    public init(credential: any AppStoreConnectCredential) {
        self.credential = credential
    }

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        request.headerFields[.authorization] = try await credential.authorizationHeaderValue()
        return try await next(request, body, baseURL)
    }
}

public extension Client {
    static func appStoreConnectURLSession(
        credential: any AppStoreConnectCredential,
        serverURL: URL = URL(string: "https://api.appstoreconnect.apple.com")!,
        retryPolicy: AppStoreConnectRetryPolicy = .never
    ) -> Client {
        Client(
            serverURL: serverURL,
            transport: URLSessionTransport(),
            middlewares: [
                AppStoreConnectOpenAPIErrorMiddleware(),
                AppStoreConnectOpenAPIRetryMiddleware(policy: retryPolicy),
                AppStoreConnectOpenAPIAuthenticationMiddleware(credential: credential),
            ]
        )
    }
}
