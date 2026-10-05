// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

#if ASC_EXPERIMENTAL
  import AppStoreConnectCore
  import Foundation

  public struct BrowserCookieFileWebSessionProvider: WebSessionProvider {
    public var fileURL: URL
    public var matchingDomains: [String]

    public init(
      fileURL: URL,
      matchingDomains: [String] = ["apple.com", "appstoreconnect.apple.com"]
    ) {
      self.fileURL = fileURL
      self.matchingDomains = matchingDomains
    }

    public func session(now: Date) async throws -> WebSession {
      let text = try String(contentsOf: fileURL, encoding: .utf8)
      let cookies =
        try NetscapeCookieFileParser
        .parse(text)
        .filter { cookie in
          !cookie.isExpired(now: now) && matchesConfiguredDomain(cookie.domain)
        }

      guard !cookies.isEmpty else {
        throw AppStoreConnectError.authenticationFailed(
          "Browser cookie file did not contain usable App Store Connect cookies."
        )
      }

      let expiresAt =
        cookies
        .compactMap(\.expiresAt)
        .min()

      let session = WebSession(
        cookieStore: cookies,
        expiresAt: expiresAt,
        source: .browserCookies,
        diagnostics: [
          WebSessionDiagnostic(
            source: .browserCookies,
            code: "browser-cookie-file",
            message: "Loaded \(cookies.count) cookies from \(fileURL.path)."
          )
        ]
      )

      return try session.validated(now: now)
    }

    private func matchesConfiguredDomain(_ cookieDomain: String?) -> Bool {
      guard !matchingDomains.isEmpty else {
        return true
      }

      guard let cookieDomain else {
        return false
      }

      let normalizedCookieDomain = normalizeDomain(cookieDomain)
      return matchingDomains.contains { domain in
        let normalizedDomain = normalizeDomain(domain)
        return normalizedCookieDomain == normalizedDomain
          || normalizedCookieDomain.hasSuffix(".\(normalizedDomain)")
          || normalizedDomain.hasSuffix(".\(normalizedCookieDomain)")
      }
    }

    private func normalizeDomain(_ domain: String) -> String {
      domain
        .trimmingCharacters(in: CharacterSet(charactersIn: "."))
        .lowercased()
    }
  }

#endif
