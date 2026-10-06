// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

#if ASC_EXPERIMENTAL
  import AppStoreConnectCore
  import Foundation

  public enum WebSessionSource: String, Codable, Sendable, CaseIterable, Equatable {
    case srpLogin
    case browserCookies
    case cachedSession
    case environment
    case sessionFile
    case staticSession
  }

  public struct WebSessionDiagnostic: Codable, Sendable, Equatable {
    public var source: WebSessionSource
    public var code: String
    public var message: String

    public init(source: WebSessionSource, code: String, message: String) {
      self.source = source
      self.code = code
      self.message = message
    }
  }

  public struct WebSessionAccount: Codable, Sendable, Equatable {
    public var identifier: String?
    public var email: String?
    public var teamID: String?
    public var teamName: String?

    public init(
      identifier: String? = nil,
      email: String? = nil,
      teamID: String? = nil,
      teamName: String? = nil
    ) {
      self.identifier = identifier
      self.email = email
      self.teamID = teamID
      self.teamName = teamName
    }
  }

  /// Explicit cookies and optional expiry/account metadata for an experimental web session.
  /// Cookie values and encoded session data are credentials and must be stored privately.
  public struct WebSession: Codable, Sendable, Equatable {
    public var cookies: [WebSessionCookie]
    public var expiresAt: Date?
    public var account: WebSessionAccount?
    public var source: WebSessionSource
    public var diagnostics: [WebSessionDiagnostic]

    public init(
      cookies: [String: String],
      expiresAt: Date? = nil,
      account: WebSessionAccount? = nil,
      source: WebSessionSource = .environment,
      diagnostics: [WebSessionDiagnostic] = []
    ) {
      self.init(
        cookieStore:
          cookies
          .sorted { $0.key < $1.key }
          .map { WebSessionCookie(name: $0.key, value: $0.value) },
        expiresAt: expiresAt,
        account: account,
        source: source,
        diagnostics: diagnostics
      )
    }

    public init(
      cookieStore: [WebSessionCookie],
      expiresAt: Date? = nil,
      account: WebSessionAccount? = nil,
      source: WebSessionSource,
      diagnostics: [WebSessionDiagnostic] = []
    ) {
      self.cookies = cookieStore
      self.expiresAt = expiresAt
      self.account = account
      self.source = source
      self.diagnostics = diagnostics
    }

    public var isEmpty: Bool {
      cookies.isEmpty
    }

    /// A name-to-value view; the last cookie with a duplicate name wins.
    public var cookieValues: [String: String] {
      cookies.reduce(into: [String: String]()) { result, cookie in
        result[cookie.name] = cookie.value
      }
    }

    /// Joins unexpired cookies by name; throws when none remain.
    /// This method does not select cookies for a destination or check session-level expiry.
    public func cookieHeader(now: Date = Date()) throws -> String {
      let usableCookies = cookies.filter { !$0.isExpired(now: now) }

      guard !usableCookies.isEmpty else {
        throw AppStoreConnectError.authenticationFailed("Web session has no usable cookies.")
      }

      return
        usableCookies
        .sorted { $0.name < $1.name }
        .map { "\($0.name)=\($0.value)" }
        .joined(separator: "; ")
    }

    public func isExpired(now: Date = Date()) -> Bool {
      if let expiresAt, expiresAt <= now {
        return true
      }

      guard !cookies.isEmpty else {
        return false
      }

      return cookies.allSatisfy { $0.isExpired(now: now) }
    }

    /// Rejects empty or expired sessions without contacting the service or refreshing cookies.
    public func validated(now: Date = Date()) throws -> WebSession {
      guard !isEmpty else {
        throw AppStoreConnectError.authenticationFailed("Web session has no cookies.")
      }

      guard !isExpired(now: now) else {
        throw AppStoreConnectError.authenticationFailed("Web session is expired.")
      }

      return self
    }

    public func withSource(
      _ source: WebSessionSource,
      diagnostic: WebSessionDiagnostic? = nil
    ) -> WebSession {
      var copy = self
      copy.source = source
      if let diagnostic {
        copy.diagnostics.append(diagnostic)
      }
      return copy
    }
  }

#endif
