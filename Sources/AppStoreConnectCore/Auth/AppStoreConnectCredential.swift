// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

/// Supplies a complete Authorization header for each authenticated request.
/// Implementations own refresh and storage; failures prevent the request from being sent.
public protocol AppStoreConnectCredential: Sendable {
  func authorizationHeaderValue() async throws -> String
}

/// Wraps a caller-provided token with the Bearer scheme, without validating or refreshing it.
public struct AppStoreConnectBearerToken: AppStoreConnectCredential, Sendable, Equatable {
  public var token: String

  public init(token: String) {
    self.token = token
  }

  public func authorizationHeaderValue() async throws -> String {
    "Bearer \(token)"
  }
}

/// Returns a caller-provided Authorization header verbatim, without refresh or validation.
public struct AppStoreConnectStaticCredential: AppStoreConnectCredential, Sendable, Equatable {
  public var headerValue: String

  public init(headerValue: String) {
    self.headerValue = headerValue
  }

  public func authorizationHeaderValue() async throws -> String {
    headerValue
  }
}
