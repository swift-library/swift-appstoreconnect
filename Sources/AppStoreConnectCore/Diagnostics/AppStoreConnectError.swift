// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

public enum AppStoreConnectError: Error, Sendable, Equatable, CustomStringConvertible {
  case invalidConfiguration(String)
  case authenticationFailed(String)
  case requestFailed(statusCode: Int, message: String?)
  case decodingFailed(String)
  case uploadFailed(String)
  case unsupportedCapability(String)

  public var description: String {
    switch self {
    case .invalidConfiguration(let message):
      "Invalid configuration: \(message)"
    case .authenticationFailed(let message):
      "Authentication failed: \(message)"
    case .requestFailed(let statusCode, let message):
      "Request failed with status \(statusCode): \(message ?? "No response message.")"
    case .decodingFailed(let message):
      "Decoding failed: \(message)"
    case .uploadFailed(let message):
      "Upload failed: \(message)"
    case .unsupportedCapability(let message):
      "Unsupported capability: \(message)"
    }
  }
}
