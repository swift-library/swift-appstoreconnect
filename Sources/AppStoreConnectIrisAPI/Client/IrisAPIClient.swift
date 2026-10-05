// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

#if ASC_EXPERIMENTAL
  import AppStoreConnectCore
  import AppStoreConnectWebSession
  import Foundation

  public struct IrisAPIClient: Sendable {
    public var environment: AppStoreConnectEnvironment
    public var sessionProvider: any WebSessionProvider
    public var transport: any AppStoreConnectTransport

    public init(
      environment: AppStoreConnectEnvironment = .irisAPI,
      sessionProvider: any WebSessionProvider,
      transport: any AppStoreConnectTransport
    ) {
      self.environment = environment
      self.sessionProvider = sessionProvider
      self.transport = transport
    }

    public func appStoreVersionStateChanges(
      appStoreVersionID: String,
      now: Date = Date()
    ) async throws -> AppStoreVersionStateChangesResponse {
      let endpoint = IrisEndpointLedger.appStoreVersionStateChanges
      let response = try await send(
        endpoint,
        pathParameters: ["appStoreVersionID": appStoreVersionID],
        now: now
      )

      do {
        return try JSONDecoder().decode(
          AppStoreVersionStateChangesResponse.self, from: response.body)
      } catch {
        throw AppStoreConnectError.decodingFailed(
          "Could not decode Iris \(endpoint.id.rawValue) response: \(error)."
        )
      }
    }

    public func send(
      _ endpoint: IrisEndpointDescriptor,
      pathParameters: [String: String] = [:],
      now: Date = Date()
    ) async throws -> AppStoreConnectResponse {
      let session = try await sessionProvider.session(now: now)
      let request = try request(
        for: endpoint,
        pathParameters: pathParameters,
        session: session,
        now: now
      )
      let response = try await transport.send(request, in: environment)

      guard (200..<300).contains(response.statusCode) else {
        throw mapFailure(response, endpoint: endpoint)
      }

      return response
    }

    public func request(
      for endpoint: IrisEndpointDescriptor,
      pathParameters: [String: String] = [:],
      session: WebSession,
      now: Date = Date()
    ) throws -> AppStoreConnectRequest {
      let path = try endpoint.path(parameters: pathParameters)
      let cookieHeader = try session.validated(now: now).cookieHeader(now: now)

      return AppStoreConnectRequest(
        method: endpoint.method,
        path: path,
        headers: [
          "Accept": "application/json",
          "Cookie": cookieHeader,
          "Origin": "https://appstoreconnect.apple.com",
          "Referer": "https://appstoreconnect.apple.com/",
          "X-Requested-With": "XMLHttpRequest",
        ]
      )
    }

    private func mapFailure(
      _ response: AppStoreConnectResponse,
      endpoint: IrisEndpointDescriptor
    ) -> AppStoreConnectError {
      if response.statusCode == 401 || response.statusCode == 403 {
        return .authenticationFailed("Iris web session is unauthorized or expired.")
      }

      return .requestFailed(
        statusCode: response.statusCode,
        message: "Iris endpoint \(endpoint.id.rawValue) failed closed."
      )
    }
  }

#endif
