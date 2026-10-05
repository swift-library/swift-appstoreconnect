// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

#if ASC_EXPERIMENTAL
  import AppStoreConnectCore
  import Foundation

  public enum WebSessionCachePolicy: String, Codable, Sendable, CaseIterable, Equatable {
    case disabled
    case readOnly
    case writeThrough
  }

  public struct WebSessionFileStore: Sendable, Equatable {
    public var fileURL: URL

    public init(fileURL: URL) {
      self.fileURL = fileURL
    }

    public func load() throws -> WebSession? {
      guard FileManager.default.fileExists(atPath: fileURL.path) else {
        return nil
      }

      let data = try Data(contentsOf: fileURL)
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      return try decoder.decode(WebSession.self, from: data)
    }

    public func loadRequired() throws -> WebSession {
      guard let session = try load() else {
        throw AppStoreConnectError.authenticationFailed(
          "Web session file does not exist at \(fileURL.path)."
        )
      }

      return session
    }

    public func save(_ session: WebSession) throws {
      let directory = fileURL.deletingLastPathComponent()
      try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

      let encoder = JSONEncoder()
      encoder.dateEncodingStrategy = .iso8601
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
      let data = try encoder.encode(session)
      try data.write(to: fileURL, options: [.atomic])
    }
  }

  public struct CachedWebSessionProvider: WebSessionProvider {
    public var store: WebSessionFileStore
    public var policy: WebSessionCachePolicy
    public var upstream: (any WebSessionProvider)?

    public init(
      store: WebSessionFileStore,
      policy: WebSessionCachePolicy = .writeThrough,
      upstream: (any WebSessionProvider)? = nil
    ) {
      self.store = store
      self.policy = policy
      self.upstream = upstream
    }

    public func session(now: Date) async throws -> WebSession {
      if policy != .disabled, let cachedSession = try store.load(),
        !cachedSession.isExpired(now: now), !cachedSession.isEmpty
      {
        return try cachedSession.withSource(.cachedSession).validated(now: now)
      }

      guard policy != .readOnly else {
        throw AppStoreConnectError.authenticationFailed(
          "No usable cached web session was available.")
      }

      guard let upstream else {
        throw AppStoreConnectError.invalidConfiguration(
          "CachedWebSessionProvider requires an upstream provider.")
      }

      let freshSession = try await upstream.session(now: now)
      if policy == .writeThrough {
        try store.save(freshSession)
      }

      return freshSession
    }
  }

  enum WebSessionDateParser {
    static func parse(_ rawValue: String) -> Date? {
      if let timeInterval = TimeInterval(rawValue) {
        return Date(timeIntervalSince1970: timeInterval)
      }

      return ISO8601DateFormatter().date(from: rawValue)
    }
  }

#endif
