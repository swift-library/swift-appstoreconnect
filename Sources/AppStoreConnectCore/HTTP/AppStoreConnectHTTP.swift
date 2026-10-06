// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public enum AppStoreConnectHTTPMethod: String, Codable, Sendable, Equatable {
  case delete = "DELETE"
  case get = "GET"
  case patch = "PATCH"
  case post = "POST"
  case put = "PUT"
}

public struct AppStoreConnectQueryItem: Codable, Sendable, Equatable {
  public var name: String
  public var value: String?

  public init(name: String, value: String?) {
    self.name = name
    self.value = value
  }
}

public struct AppStoreConnectRequest: Sendable, Equatable {
  public var method: String
  public var path: String
  public var queryItems: [AppStoreConnectQueryItem]
  public var headers: [String: String]
  public var body: Data?

  public init(
    method: String,
    path: String,
    queryItems: [AppStoreConnectQueryItem] = [],
    headers: [String: String] = [:],
    body: Data? = nil
  ) {
    self.method = method
    self.path = path
    self.queryItems = queryItems
    self.headers = headers
    self.body = body
  }

  public init(
    method: AppStoreConnectHTTPMethod,
    path: String,
    queryItems: [AppStoreConnectQueryItem] = [],
    headers: [String: String] = [:],
    body: Data? = nil
  ) {
    self.init(
      method: method.rawValue,
      path: path,
      queryItems: queryItems,
      headers: headers,
      body: body
    )
  }
}

public struct AppStoreConnectResponse: Sendable, Equatable {
  public var statusCode: Int
  public var headers: [String: String]
  public var body: Data

  public init(statusCode: Int, headers: [String: String] = [:], body: Data = Data()) {
    self.statusCode = statusCode
    self.headers = headers
    self.body = body
  }
}

public struct AppStoreConnectDownloadResponse: Sendable, Equatable {
  public var fileURL: URL
  public var response: AppStoreConnectResponse

  public init(fileURL: URL, response: AppStoreConnectResponse) {
    self.fileURL = fileURL
    self.response = response
  }
}

public protocol AppStoreConnectEndpoint: Sendable {
  associatedtype Response: Decodable & Sendable

  var request: AppStoreConnectRequest { get }
}

public protocol AppStoreConnectTransport: Sendable {
  func send(
    _ request: AppStoreConnectRequest,
    in environment: AppStoreConnectEnvironment
  ) async throws -> AppStoreConnectResponse
}

public protocol AppStoreConnectDownloadTransport: AppStoreConnectTransport {
  func download(
    _ request: AppStoreConnectRequest,
    in environment: AppStoreConnectEnvironment
  ) async throws -> AppStoreConnectDownloadResponse
}

public struct URLSessionAppStoreConnectTransport: AppStoreConnectDownloadTransport {
  private let session: URLSession

  public init(session: URLSession = .shared) {
    self.session = session
  }

  public func send(
    _ request: AppStoreConnectRequest,
    in environment: AppStoreConnectEnvironment
  ) async throws -> AppStoreConnectResponse {
    let urlRequest = try makeURLRequest(request, in: environment)
    let (data, response) = try await session.data(for: urlRequest)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Response was not HTTP.")
    }

    return AppStoreConnectResponse(
      statusCode: httpResponse.statusCode,
      headers: httpResponse.normalizedHeaders,
      body: data
    )
  }

  public func download(
    _ request: AppStoreConnectRequest,
    in environment: AppStoreConnectEnvironment
  ) async throws -> AppStoreConnectDownloadResponse {
    let urlRequest = try makeURLRequest(request, in: environment)
    let (fileURL, response) = try await session.download(for: urlRequest)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Response was not HTTP.")
    }

    return AppStoreConnectDownloadResponse(
      fileURL: fileURL,
      response: AppStoreConnectResponse(
        statusCode: httpResponse.statusCode,
        headers: httpResponse.normalizedHeaders
      )
    )
  }

  public func makeURLRequest(
    _ request: AppStoreConnectRequest,
    in environment: AppStoreConnectEnvironment
  ) throws -> URLRequest {
    let url = try request.resolvedURL(in: environment)
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = request.method
    urlRequest.httpBody = request.body

    for (name, value) in request.headers {
      urlRequest.setValue(value, forHTTPHeaderField: name)
    }

    return urlRequest
  }

}

extension AppStoreConnectRequest {
  func resolvedURL(in environment: AppStoreConnectEnvironment) throws -> URL {
    let baseURL: URL

    if let absoluteURL = URL(string: path), absoluteURL.scheme != nil {
      baseURL = absoluteURL
    } else {
      baseURL = environment.baseURL.appendingPathComponent(path.trimmedLeadingSlash)
    }

    guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
      throw AppStoreConnectError.invalidConfiguration(
        "Could not resolve URL for path \(path).")
    }

    if !queryItems.isEmpty {
      components.queryItems = queryItems.map {
        URLQueryItem(name: $0.name, value: $0.value)
      }
    }

    guard let url = components.url else {
      throw AppStoreConnectError.invalidConfiguration(
        "Could not build URL for path \(path).")
    }

    return url
  }
}

extension HTTPURLResponse {
  fileprivate var normalizedHeaders: [String: String] {
    allHeaderFields.reduce(into: [String: String]()) { result, element in
      guard let key = element.key as? String else {
        return
      }

      result[key] = String(describing: element.value)
    }
  }
}

extension String {
  fileprivate var trimmedLeadingSlash: String {
    var value = self

    while value.first == "/" {
      value.removeFirst()
    }

    return value
  }
}
