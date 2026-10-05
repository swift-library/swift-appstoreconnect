// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

#if ASC_EXPERIMENTAL
  import Foundation

  public struct SessionFileWebSessionProvider: WebSessionProvider {
    public var store: WebSessionFileStore

    public init(fileURL: URL) {
      self.store = WebSessionFileStore(fileURL: fileURL)
    }

    public init(store: WebSessionFileStore) {
      self.store = store
    }

    public func session(now: Date) async throws -> WebSession {
      let session = try store.loadRequired()
      return try session.withSource(.sessionFile).validated(now: now)
    }
  }

#endif
