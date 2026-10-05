// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

#if ASC_EXPERIMENTAL
  import AppStoreConnectCore
  import AppStoreConnectWebSession
  import Foundation
  import Testing

  @Test func environmentProviderParsesCookieHeaderAndAccount() async throws {
    let provider = EnvironmentWebSessionProvider(environment: [
      "ASC_WEB_SESSION_COOKIES": "myacinfo=token; itctx=context",
      "ASC_WEB_SESSION_EXPIRES_AT": "2030-01-01T00:00:00Z",
      "ASC_WEB_SESSION_ACCOUNT_ID": "account-1",
      "ASC_WEB_SESSION_ACCOUNT_EMAIL": "dev@example.com",
    ])

    let session = try await provider.session(now: Date(timeIntervalSince1970: 1_700_000_000))

    #expect(session.source == .environment)
    #expect(session.cookieValues == ["itctx": "context", "myacinfo": "token"])
    #expect(
      try session.cookieHeader(now: Date(timeIntervalSince1970: 1_700_000_000))
        == "itctx=context; myacinfo=token")
    #expect(session.account?.identifier == "account-1")
    #expect(session.account?.email == "dev@example.com")
    #expect(session.diagnostics.map(\.code) == ["environment-cookie-header"])
  }

  @Test func sessionFileProviderLoadsSerializableSession() async throws {
    let fileURL = temporaryFileURL("web-session.json")
    let store = WebSessionFileStore(fileURL: fileURL)
    let expected = WebSession(
      cookies: ["myacinfo": "cached-token"],
      expiresAt: Date(timeIntervalSince1970: 2_000_000_000),
      account: WebSessionAccount(email: "cached@example.com"),
      source: .environment
    )
    try store.save(expected)

    let session = try await SessionFileWebSessionProvider(store: store)
      .session(now: Date(timeIntervalSince1970: 1_700_000_000))

    #expect(session.source == .sessionFile)
    #expect(session.cookieValues == ["myacinfo": "cached-token"])
    #expect(session.account?.email == "cached@example.com")
  }

  @Test func browserCookieFileProviderParsesNetscapeExport() async throws {
    let fileURL = temporaryFileURL("cookies.txt")
    try """
    # Netscape HTTP Cookie File
    #HttpOnly_.apple.com\tTRUE\t/\tTRUE\t2000000000\tmyacinfo\tbrowser-token
    .example.com\tTRUE\t/\tFALSE\t2000000000\tignored\tvalue
    appstoreconnect.apple.com\tFALSE\t/\tTRUE\t2000000000\titctx\tbrowser-context
    """.write(to: fileURL, atomically: true, encoding: .utf8)

    let session = try await BrowserCookieFileWebSessionProvider(fileURL: fileURL)
      .session(now: Date(timeIntervalSince1970: 1_700_000_000))

    #expect(session.source == .browserCookies)
    #expect(
      session.cookieValues == [
        "itctx": "browser-context",
        "myacinfo": "browser-token",
      ])
    #expect(
      try session.cookieHeader(now: Date(timeIntervalSince1970: 1_700_000_000))
        == "itctx=browser-context; myacinfo=browser-token")
    #expect(session.cookies.first { $0.name == "myacinfo" }?.isHTTPOnly == true)
    #expect(session.diagnostics.map(\.code) == ["browser-cookie-file"])
  }

  @Test func cachedProviderReturnsFreshCacheBeforeUpstream() async throws {
    let fileURL = temporaryFileURL("cached-web-session.json")
    let store = WebSessionFileStore(fileURL: fileURL)
    try store.save(
      WebSession(
        cookies: ["cached": "value"],
        expiresAt: Date(timeIntervalSince1970: 2_000_000_000),
        source: .environment
      ))

    let provider = CachedWebSessionProvider(
      store: store,
      policy: .writeThrough,
      upstream: StaticWebSessionProvider(
        WebSession(
          cookies: ["fresh": "value"],
          expiresAt: Date(timeIntervalSince1970: 2_000_000_000),
          source: .environment
        ))
    )

    let session = try await provider.session(now: Date(timeIntervalSince1970: 1_700_000_000))

    #expect(session.source == .cachedSession)
    #expect(session.cookieValues == ["cached": "value"])
  }

  @Test func cachedProviderWritesThroughWhenCacheIsExpired() async throws {
    let fileURL = temporaryFileURL("write-through-web-session.json")
    let store = WebSessionFileStore(fileURL: fileURL)
    try store.save(
      WebSession(
        cookies: ["expired": "value"],
        expiresAt: Date(timeIntervalSince1970: 1_000),
        source: .environment
      ))

    let provider = CachedWebSessionProvider(
      store: store,
      policy: .writeThrough,
      upstream: StaticWebSessionProvider(
        WebSession(
          cookies: ["fresh": "value"],
          expiresAt: Date(timeIntervalSince1970: 2_000_000_000),
          source: .environment
        ))
    )

    let session = try await provider.session(now: Date(timeIntervalSince1970: 1_700_000_000))
    let saved = try #require(try store.load())

    #expect(session.source == .staticSession)
    #expect(session.cookieValues == ["fresh": "value"])
    #expect(saved.cookieValues == ["fresh": "value"])
  }

  @Test func expiredSessionFailsClosed() async {
    let provider = StaticWebSessionProvider(
      WebSession(
        cookies: ["myacinfo": "expired"],
        expiresAt: Date(timeIntervalSince1970: 1_000),
        source: .environment
      ))

    await #expect(throws: AppStoreConnectError.authenticationFailed("Web session is expired.")) {
      _ = try await provider.session(now: Date(timeIntervalSince1970: 1_700_000_000))
    }
  }

  private func temporaryFileURL(_ name: String) -> URL {
    let directory = FileManager.default.temporaryDirectory
      .appendingPathComponent("swift-appstoreconnect-websession-tests", isDirectory: true)
      .appendingPathComponent(UUID().uuidString, isDirectory: true)
    try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory.appendingPathComponent(name)
  }

#endif
