// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import AppStoreConnectCore
import Foundation
import HTTPTypes
import OpenAPIRuntime

public struct AppStoreConnectOpenAPIRetryMiddleware: ClientMiddleware {
  public var policy: AppStoreConnectRetryPolicy
  public var sleep: AppStoreConnectRetrySleep

  public init(
    policy: AppStoreConnectRetryPolicy,
    sleep: @escaping AppStoreConnectRetrySleep = AppStoreConnectRetryingTransport.defaultSleep
  ) {
    self.policy = policy
    self.sleep = sleep
  }

  public func intercept(
    _ request: HTTPRequest,
    body: HTTPBody?,
    baseURL: URL,
    operationID: String,
    next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
  ) async throws -> (HTTPResponse, HTTPBody?) {
    var retryIndex = 0
    let coreRequest = AppStoreConnectRequest(
      method: request.method.rawValue,
      path: request.path ?? "",
      headers: request.headerFields.appStoreConnectDictionary
    )

    while true {
      do {
        let (response, responseBody) = try await next(request, body, baseURL)
        let coreResponse = AppStoreConnectResponse(
          statusCode: response.status.code,
          headers: response.headerFields.appStoreConnectDictionary
        )

        guard body?.iterationBehavior != .single,
          let delay = policy.retryDelay(
            after: coreResponse, for: coreRequest, retryIndex: retryIndex)
        else {
          return (response, responseBody)
        }

        try await sleep(delay)
        retryIndex += 1
      } catch {
        guard body?.iterationBehavior != .single,
          let delay = policy.retryDelay(after: error, for: coreRequest, retryIndex: retryIndex)
        else {
          throw error
        }

        try await sleep(delay)
        retryIndex += 1
      }
    }
  }
}

extension HTTPFields {
  fileprivate var appStoreConnectDictionary: [String: String] {
    reduce(into: [String: String]()) { result, field in
      result[field.name.rawName] = field.value
    }
  }
}
