// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import AppStoreConnectCore
import Foundation

extension RawPublicAPIClient {
  public func send(
    _ request: AppStoreConnectRequest,
    retryPolicy: AppStoreConnectRetryPolicy = .never
  ) async throws -> AppStoreConnectResponse {
    let selectedTransport: any AppStoreConnectTransport

    if retryPolicy.maxRetries > 0 {
      selectedTransport = AppStoreConnectRetryingTransport(
        base: transport,
        policy: retryPolicy
      )
    } else {
      selectedTransport = transport
    }

    return try await selectedTransport.send(request, in: environment)
  }

  public func upload(
    _ operation: AppStoreConnectUploadOperation,
    from data: Data,
    retryPolicy: AppStoreConnectRetryPolicy = .upload(maxRetries: 2, delay: 1)
  ) async throws -> AppStoreConnectResponse {
    try await send(operation.request(from: data), retryPolicy: retryPolicy)
  }

  public func upload(
    _ upload: AppStoreConnectUpload,
    from data: Data,
    retryPolicy: AppStoreConnectRetryPolicy = .upload(maxRetries: 2, delay: 1)
  ) async throws -> [AppStoreConnectResponse] {
    var responses: [AppStoreConnectResponse] = []
    responses.reserveCapacity(upload.operations.count)

    for operation in upload.operations {
      responses.append(try await self.upload(operation, from: data, retryPolicy: retryPolicy))
    }

    return responses
  }
}
