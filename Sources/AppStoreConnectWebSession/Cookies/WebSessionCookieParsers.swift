// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

#if ASC_EXPERIMENTAL
  import AppStoreConnectCore
  import Foundation

  public enum WebSessionCookieHeaderParser {
    public static func parse(_ header: String) throws -> [WebSessionCookie] {
      let cookies =
        header
        .split(separator: ";", omittingEmptySubsequences: true)
        .compactMap { segment -> WebSessionCookie? in
          let pair = segment.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
          guard pair.count == 2 else {
            return nil
          }

          let name = pair[0].trimmingCharacters(in: .whitespacesAndNewlines)
          let value = pair[1].trimmingCharacters(in: .whitespacesAndNewlines)
          guard !name.isEmpty else {
            return nil
          }

          return WebSessionCookie(name: name, value: value)
        }

      guard !cookies.isEmpty else {
        throw AppStoreConnectError.authenticationFailed(
          "Cookie header did not contain any cookies.")
      }

      return cookies
    }
  }

  public enum NetscapeCookieFileParser {
    public static func parse(_ text: String) throws -> [WebSessionCookie] {
      let cookies =
        text
        .split(whereSeparator: \.isNewline)
        .compactMap { line -> WebSessionCookie? in
          parseLine(String(line))
        }

      guard !cookies.isEmpty else {
        throw AppStoreConnectError.authenticationFailed("Cookie file did not contain any cookies.")
      }

      return cookies
    }

    private static func parseLine(_ rawLine: String) -> WebSessionCookie? {
      var line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !line.isEmpty else {
        return nil
      }

      var isHTTPOnly = false
      if line.hasPrefix("#HttpOnly_") {
        isHTTPOnly = true
        line.removeFirst("#HttpOnly_".count)
      } else if line.hasPrefix("#") {
        return nil
      }

      let fields: [String]
      if line.contains("\t") {
        fields = line.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
      } else {
        fields = line.split(separator: " ", maxSplits: 6, omittingEmptySubsequences: true).map(
          String.init)
      }

      guard fields.count >= 7 else {
        return nil
      }

      let domain = fields[0]
      let path = fields[2]
      let isSecure = fields[3].uppercased() == "TRUE"
      let expiration = TimeInterval(fields[4]).map(Date.init(timeIntervalSince1970:))
      let name = fields[5]
      let value = fields[6]

      guard !name.isEmpty else {
        return nil
      }

      return WebSessionCookie(
        name: name,
        value: value,
        domain: domain,
        path: path,
        expiresAt: expiration,
        isSecure: isSecure,
        isHTTPOnly: isHTTPOnly
      )
    }
  }

#endif
