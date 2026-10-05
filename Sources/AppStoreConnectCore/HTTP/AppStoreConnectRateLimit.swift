// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import Foundation

public struct AppStoreConnectRateLimit: Sendable, Equatable {
  public var limitPerHour: Int?
  public var remainingPerHour: Int?

  public init(limitPerHour: Int? = nil, remainingPerHour: Int? = nil) {
    self.limitPerHour = limitPerHour
    self.remainingPerHour = remainingPerHour
  }

  public init?(headerValue: String) {
    let fields =
      headerValue
      .split { $0 == ";" || $0 == "," }
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }

    guard !fields.isEmpty else {
      return nil
    }

    var values: [String: Int] = [:]

    for field in fields {
      let parts = field.split(separator: ":", maxSplits: 1)
      guard parts.count == 2 else {
        continue
      }

      let name = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
      let value = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
      values[name] = Int(value)
    }

    guard values["user-hour-lim"] != nil || values["user-hour-rem"] != nil else {
      return nil
    }

    self.init(
      limitPerHour: values["user-hour-lim"],
      remainingPerHour: values["user-hour-rem"]
    )
  }
}

extension AppStoreConnectResponse {
  public var rateLimit: AppStoreConnectRateLimit? {
    guard let header = headers.caseInsensitiveValue(for: "X-Rate-Limit") else {
      return nil
    }

    return AppStoreConnectRateLimit(headerValue: header)
  }

  public var isRateLimited: Bool {
    statusCode == 429
  }
}
