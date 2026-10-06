// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import Foundation

/// Attaches credentials only to requests within the supplied environment's HTTP origin.
/// Requests to another scheme, host, or port fail before credentials or transport are invoked.
public struct AppStoreConnectAuthenticatedTransport: AppStoreConnectTransport {
  public var base: any AppStoreConnectTransport
  public var credential: any AppStoreConnectCredential

  public init(
    base: any AppStoreConnectTransport,
    credential: any AppStoreConnectCredential
  ) {
    self.base = base
    self.credential = credential
  }

  public func send(
    _ request: AppStoreConnectRequest,
    in environment: AppStoreConnectEnvironment
  ) async throws -> AppStoreConnectResponse {
    let destination = try request.resolvedURL(in: environment)
    let origin = environment.baseURL
    guard let scheme = destination.scheme?.lowercased(),
      ["http", "https"].contains(scheme),
      scheme == origin.scheme?.lowercased(),
      let host = destination.host?.lowercased(), host == origin.host?.lowercased(),
      destination.port ?? defaultPort(scheme) == origin.port ?? defaultPort(scheme),
      destination.user == nil, destination.password == nil
    else {
      throw AppStoreConnectError.authenticationFailed(
        "Authenticated request must use the environment's HTTP origin.")
    }
    return try await base.send(request.authorized(using: credential), in: environment)
  }

  private func defaultPort(_ scheme: String) -> Int { scheme == "https" ? 443 : 80 }
}

extension AppStoreConnectRequest {
  /// Returns a copy with the credential header, without checking or sending its destination.
  /// Use `AppStoreConnectAuthenticatedTransport` to enforce the environment's origin at send time.
  public func authorized(using credential: any AppStoreConnectCredential) async throws
    -> AppStoreConnectRequest
  {
    var request = self
    request.headers["Authorization"] = try await credential.authorizationHeaderValue()
    return request
  }
}

public struct AppStoreConnectRecordedRequest: Sendable, Equatable {
  public var request: AppStoreConnectRequest
  public var environment: AppStoreConnectEnvironment

  public init(request: AppStoreConnectRequest, environment: AppStoreConnectEnvironment) {
    self.request = request
    self.environment = environment
  }
}

public actor AppStoreConnectTransportFixture {
  private var responses: [AppStoreConnectResponse]
  private var recordedRequests: [AppStoreConnectRecordedRequest] = []

  public init(responses: [AppStoreConnectResponse]) {
    self.responses = responses
  }

  public func enqueue(_ response: AppStoreConnectResponse) {
    responses.append(response)
  }

  public func requests() -> [AppStoreConnectRecordedRequest] {
    recordedRequests
  }

  func send(
    _ request: AppStoreConnectRequest,
    in environment: AppStoreConnectEnvironment
  ) throws -> AppStoreConnectResponse {
    recordedRequests.append(
      AppStoreConnectRecordedRequest(request: request, environment: environment))

    guard !responses.isEmpty else {
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "No fixture response is available.")
    }

    return responses.removeFirst()
  }
}

public struct AppStoreConnectFixtureTransport: AppStoreConnectTransport {
  public var fixture: AppStoreConnectTransportFixture

  public init(fixture: AppStoreConnectTransportFixture) {
    self.fixture = fixture
  }

  public func send(
    _ request: AppStoreConnectRequest,
    in environment: AppStoreConnectEnvironment
  ) async throws -> AppStoreConnectResponse {
    try await fixture.send(request, in: environment)
  }
}
