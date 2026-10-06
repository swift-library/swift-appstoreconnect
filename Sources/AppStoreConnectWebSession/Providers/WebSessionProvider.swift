// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

#if ASC_EXPERIMENTAL
  import Foundation

  /// Supplies a session using explicit input; the supplied time supports expiry validation.
  public protocol WebSessionProvider: Sendable {
    func session(now: Date) async throws -> WebSession
  }

  extension WebSessionProvider {
    public func session() async throws -> WebSession {
      try await session(now: Date())
    }
  }

  /// Returns its session after validating it at the requested time; performs no login or refresh.
  public struct StaticWebSessionProvider: WebSessionProvider {
    public var webSession: WebSession

    public init(_ webSession: WebSession) {
      self.webSession = webSession
    }

    public func session(now: Date) async throws -> WebSession {
      try webSession.withSource(.staticSession).validated(now: now)
    }
  }

#endif
