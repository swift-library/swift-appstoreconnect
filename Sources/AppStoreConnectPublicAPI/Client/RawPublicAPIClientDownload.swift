// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import AppStoreConnectCore
import Foundation

extension RawPublicAPIClient {
  public func download(
    _ request: AppStoreConnectRequest,
    to destinationURL: URL? = nil,
    retryPolicy: AppStoreConnectRetryPolicy = .never
  ) async throws -> URL {
    let outputURL =
      destinationURL
      ?? FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString)

    if let downloadTransport = transport as? any AppStoreConnectDownloadTransport {
      let selectedTransport: any AppStoreConnectDownloadTransport

      if retryPolicy.maxRetries > 0 {
        selectedTransport = AppStoreConnectRetryingDownloadTransport(
          base: downloadTransport,
          policy: retryPolicy
        )
      } else {
        selectedTransport = downloadTransport
      }

      let download = try await selectedTransport.download(request, in: environment)
      guard (200...299).contains(download.response.statusCode) else {
        try? FileManager.default.removeItem(at: download.fileURL)
        throw AppStoreConnectError.requestFailed(
          statusCode: download.response.statusCode, message: nil)
      }

      if FileManager.default.fileExists(atPath: outputURL.path) {
        try FileManager.default.removeItem(at: outputURL)
      }
      try FileManager.default.moveItem(at: download.fileURL, to: outputURL)
      return outputURL
    }

    let response = try await send(request, retryPolicy: retryPolicy)
    guard (200...299).contains(response.statusCode) else {
      throw AppStoreConnectError.requestFailed(statusCode: response.statusCode, message: nil)
    }

    try response.body.write(to: outputURL, options: [.atomic])
    return outputURL
  }
}
