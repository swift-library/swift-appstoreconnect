import Foundation
import HTTPTypes
import OpenAPIRuntime

public struct AppStoreConnectPublicErrorDocument: Decodable, Sendable, Equatable {
    public var errors: [AppStoreConnectPublicError]

    public init(errors: [AppStoreConnectPublicError]) {
        self.errors = errors
    }
}

public struct AppStoreConnectPublicError: Decodable, Sendable, Equatable {
    public var id: String?
    public var status: String?
    public var code: String?
    public var title: String?
    public var detail: String?
    public var source: AppStoreConnectPublicErrorSource?

    public init(
        id: String? = nil,
        status: String? = nil,
        code: String? = nil,
        title: String? = nil,
        detail: String? = nil,
        source: AppStoreConnectPublicErrorSource? = nil
    ) {
        self.id = id
        self.status = status
        self.code = code
        self.title = title
        self.detail = detail
        self.source = source
    }
}

public struct AppStoreConnectPublicErrorSource: Decodable, Sendable, Equatable {
    public var pointer: String?
    public var parameter: String?

    public init(pointer: String? = nil, parameter: String? = nil) {
        self.pointer = pointer
        self.parameter = parameter
    }
}

public struct AppStoreConnectPublicAPIError: Error, Sendable, Equatable, CustomStringConvertible {
    public var operationID: String
    public var statusCode: Int
    public var requestPath: String?
    public var errors: [AppStoreConnectPublicError]
    public var bodyPreview: String?

    public init(
        operationID: String,
        statusCode: Int,
        requestPath: String?,
        errors: [AppStoreConnectPublicError] = [],
        bodyPreview: String? = nil
    ) {
        self.operationID = operationID
        self.statusCode = statusCode
        self.requestPath = requestPath
        self.errors = errors
        self.bodyPreview = bodyPreview
    }

    public var description: String {
        let firstError = errors.first
        let code = firstError?.code.map { " \($0)" } ?? ""
        let detail = firstError?.detail.map { ": \($0)" } ?? ""
        return "App Store Connect \(operationID) failed with status \(statusCode)\(code)\(detail)"
    }
}

public struct AppStoreConnectOpenAPIErrorMiddleware: ClientMiddleware {
    public var maximumBodyBytes: Int

    public init(maximumBodyBytes: Int = 128 * 1024) {
        self.maximumBodyBytes = maximumBodyBytes
    }

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        let (response, responseBody) = try await next(request, body, baseURL)
        guard !(200...299).contains(response.status.code) else {
            return (response, responseBody)
        }

        let bodyData: Data?
        if let responseBody {
            bodyData = try await Data(collecting: responseBody, upTo: maximumBodyBytes)
        } else {
            bodyData = nil
        }
        let decoder = AppStoreConnectPublicJSONCoding.makeDecoder()
        let errorDocument = bodyData.flatMap {
            try? decoder.decode(AppStoreConnectPublicErrorDocument.self, from: $0)
        }

        throw AppStoreConnectPublicAPIError(
            operationID: operationID,
            statusCode: response.status.code,
            requestPath: request.path,
            errors: errorDocument?.errors ?? [],
            bodyPreview: bodyData.flatMap { String(data: $0, encoding: .utf8) }
        )
    }
}
