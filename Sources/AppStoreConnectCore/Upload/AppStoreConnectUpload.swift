// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import Foundation

public enum AppStoreConnectUploadMethod: String, Codable, Sendable, Equatable {
  case put = "PUT"
  case post = "POST"
}

public struct AppStoreConnectUploadOperation: Codable, Sendable, Equatable {
  public var method: AppStoreConnectUploadMethod
  public var url: URL
  public var headers: [String: String]
  public var offset: Int64?
  public var length: Int64?

  public init(
    method: AppStoreConnectUploadMethod,
    url: URL,
    headers: [String: String] = [:],
    offset: Int64? = nil,
    length: Int64? = nil
  ) {
    self.method = method
    self.url = url
    self.headers = headers
    self.offset = offset
    self.length = length
  }

  public func bodyChunk(from data: Data) throws -> Data {
    guard let offset, let length else {
      throw AppStoreConnectError.uploadFailed(
        "Upload operation is missing chunk bounds: offset=\(String(describing: offset)), length=\(String(describing: length))."
      )
    }

    guard offset >= 0, length >= 0 else {
      throw AppStoreConnectError.uploadFailed(
        "Upload operation has negative chunk bounds: offset=\(offset), length=\(length)."
      )
    }

    guard let start = Int(exactly: offset), let count = Int(exactly: length) else {
      throw AppStoreConnectError.uploadFailed(
        "Upload operation chunk bounds exceed this platform's addressable memory range."
      )
    }

    let end = start + count
    guard start <= data.count, end <= data.count else {
      throw AppStoreConnectError.uploadFailed(
        "Upload operation chunk range \(start)..<\(end) exceeds data size \(data.count)."
      )
    }

    return Data(data[start..<end])
  }

  public func request(from data: Data) throws -> AppStoreConnectRequest {
    try AppStoreConnectRequest(
      method: method.rawValue,
      path: url.absoluteString,
      headers: headers,
      body: bodyChunk(from: data)
    )
  }
}

public struct AppStoreConnectUpload: Codable, Sendable, Equatable {
  public var operations: [AppStoreConnectUploadOperation]

  public init(operations: [AppStoreConnectUploadOperation]) {
    self.operations = operations
  }
}
