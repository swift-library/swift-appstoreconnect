// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import AppStoreConnectCore
import CryptoKit
import Foundation
import Testing

@Test func requestBuildsURLAgainstEnvironment() throws {
  let request = AppStoreConnectRequest(
    method: .get,
    path: "/v1/apps",
    queryItems: [
      AppStoreConnectQueryItem(name: "limit", value: "10"),
      AppStoreConnectQueryItem(name: "filter[name]", value: "Example"),
    ],
    headers: ["Accept": "application/json"]
  )

  let urlRequest = try URLSessionAppStoreConnectTransport()
    .makeURLRequest(request, in: .publicAPI)

  #expect(urlRequest.httpMethod == "GET")
  #expect(urlRequest.value(forHTTPHeaderField: "Accept") == "application/json")
  #expect(
    urlRequest.url?.absoluteString
      == "https://api.appstoreconnect.apple.com/v1/apps?limit=10&filter%5Bname%5D=Example")
}

@Test func bearerTokenProducesAuthorizationHeader() async throws {
  let credential = AppStoreConnectBearerToken(token: "token")

  let value = try await credential.authorizationHeaderValue()

  #expect(value == "Bearer token")
}

@Test func teamJWTUsesIssuerAudienceAndTwentyMinuteLifetime() throws {
  let privateKey = P256.Signing.PrivateKey()
  let signingKey = try AppStoreConnectJWTSigningKey(
    keyID: "ABC123DEFG",
    pemRepresentation: privateKey.pemRepresentation
  )
  let signer = try AppStoreConnectJWTSigner(
    signingKey: signingKey,
    subject: .team(issuerID: "00000000-0000-0000-0000-000000000000"),
    clock: AppStoreConnectFixedClock(now: Date(timeIntervalSince1970: 1_700_000_000))
  )

  let token = try signer.token()
  let parts = tokenParts(token)
  let header = try jsonObject(fromBase64URL: parts.header)
  let payload = try jsonObject(fromBase64URL: parts.payload)

  #expect(header["alg"] as? String == "ES256")
  #expect(header["kid"] as? String == "ABC123DEFG")
  #expect(header["typ"] as? String == "JWT")
  #expect(payload["iss"] as? String == "00000000-0000-0000-0000-000000000000")
  #expect(payload["aud"] as? String == "appstoreconnect-v1")
  #expect(payload["iat"] as? Int == 1_700_000_000)
  #expect(payload["exp"] as? Int == 1_700_001_200)
  #expect(payload["sub"] == nil)
  #expect(try verifiesSignature(parts: parts, publicKey: privateKey.publicKey))
}

@Test func individualJWTUsesSubjectAndOptionalScope() throws {
  let privateKey = P256.Signing.PrivateKey()
  let signer = try AppStoreConnectJWTSigner(
    signingKey: AppStoreConnectJWTSigningKey(
      keyID: "INDIVIDUAL",
      pemRepresentation: privateKey.pemRepresentation
    ),
    subject: .individualUser,
    lifetime: 600,
    clock: AppStoreConnectFixedClock(now: Date(timeIntervalSince1970: 2_000_000_000))
  )

  let token = try signer.token(scope: ["GET /v1/apps"])
  let payload = try jsonObject(fromBase64URL: tokenParts(token).payload)

  #expect(payload["iss"] == nil)
  #expect(payload["sub"] as? String == "user")
  #expect(payload["exp"] as? Int == 2_000_000_600)
  #expect(payload["scope"] as? [String] == ["GET /v1/apps"])
}

@Test func jwtSigningKeyLoadsP8DataAndRejectsLongLifetime() throws {
  let privateKey = P256.Signing.PrivateKey()
  let signingKey = try AppStoreConnectJWTSigningKey(
    keyID: "KEY",
    p8Data: Data(privateKey.pemRepresentation.utf8)
  )

  #expect(
    throws: AppStoreConnectError.authenticationFailed(
      "JWT lifetime 1201 seconds exceeds maximum 1200 seconds."
    )
  ) {
    _ = try AppStoreConnectJWTSigner(
      signingKey: signingKey,
      subject: .team(issuerID: "issuer"),
      lifetime: AppStoreConnectJWTSigner.maximumStandardLifetime + 1,
      clock: AppStoreConnectFixedClock(now: Date(timeIntervalSince1970: 0))
    )
  }
}

@Test func cachedJWTCredentialReusesTokenUntilRefreshWindow() async throws {
  let privateKey = P256.Signing.PrivateKey()
  let clock = MutableClock(now: Date(timeIntervalSince1970: 1_700_000_000))
  let signer = try AppStoreConnectJWTSigner(
    signingKey: AppStoreConnectJWTSigningKey(
      keyID: "CACHED",
      pemRepresentation: privateKey.pemRepresentation
    ),
    subject: .team(issuerID: "issuer"),
    lifetime: 120,
    clock: clock
  )
  let credential = AppStoreConnectCachedJWTCredential(
    signer: signer,
    scope: ["GET /v1/apps"],
    refreshSkew: 10
  )

  let first = try await credential.token()
  clock.now = Date(timeIntervalSince1970: 1_700_000_060)
  let cached = try await credential.token()
  clock.now = Date(timeIntervalSince1970: 1_700_000_115)
  let refreshed = try await credential.token()

  #expect(cached == first)
  #expect(refreshed != first)
  #expect(
    try jsonObject(fromBase64URL: tokenParts(refreshed).payload)["iat"] as? Int == 1_700_000_115)
}

@Test func authenticatedTransportAddsAuthorizationHeaderAndRecordsRequest() async throws {
  let fixture = AppStoreConnectTransportFixture(responses: [
    AppStoreConnectResponse(
      statusCode: 200, headers: ["X-Rate-Limit": "user-hour-lim:3500;user-hour-rem:499;"])
  ])
  let transport = AppStoreConnectAuthenticatedTransport(
    base: AppStoreConnectFixtureTransport(fixture: fixture),
    credential: AppStoreConnectBearerToken(token: "runtime-token")
  )

  let response = try await transport.send(
    AppStoreConnectRequest(method: .get, path: "/v1/apps"),
    in: .publicAPI
  )
  let recorded = await fixture.requests()

  #expect(response.statusCode == 200)
  #expect(response.rateLimit == AppStoreConnectRateLimit(limitPerHour: 3500, remainingPerHour: 499))
  #expect(recorded.count == 1)
  #expect(recorded[0].request.headers["Authorization"] == "Bearer runtime-token")
  #expect(recorded[0].environment == .publicAPI)
}

@Test func rateLimitParserReadsHeaderCaseInsensitively() {
  let response = AppStoreConnectResponse(
    statusCode: 429,
    headers: [
      "x-rate-limit": "user-hour-lim:3500;user-hour-rem:0;",
      "retry-after": "3",
    ]
  )

  #expect(response.isRateLimited)
  #expect(response.rateLimit?.limitPerHour == 3500)
  #expect(response.rateLimit?.remainingPerHour == 0)
  #expect(response.retryAfterDelay == 3)
}

@Test func rateLimitParserAcceptsCommaSeparatedEntries() {
  let response = AppStoreConnectResponse(
    statusCode: 200,
    headers: ["X-Rate-Limit": "user-hour-lim:3500, user-hour-rem:42"]
  )

  #expect(response.rateLimit == AppStoreConnectRateLimit(limitPerHour: 3500, remainingPerHour: 42))
}

@Test func retryingTransportRetriesRateLimitedGetAndRespectsRetryAfter() async throws {
  let fixture = AppStoreConnectTransportFixture(responses: [
    AppStoreConnectResponse(statusCode: 429, headers: ["Retry-After": "2"]),
    AppStoreConnectResponse(statusCode: 200),
  ])
  let sleepRecorder = RetrySleepRecorder()
  let transport = AppStoreConnectRetryingTransport(
    base: AppStoreConnectFixtureTransport(fixture: fixture),
    policy: .fixed(maxRetries: 1, delay: 0.25),
    sleep: { await sleepRecorder.record($0) }
  )

  let response = try await transport.send(
    AppStoreConnectRequest(method: .get, path: "/v1/apps"),
    in: .publicAPI
  )
  let recorded = await fixture.requests()

  #expect(response.statusCode == 200)
  #expect(recorded.count == 2)
  #expect(await sleepRecorder.delays() == [2])
}

@Test func retryingTransportDoesNotRetryMutationsByDefault() async throws {
  let fixture = AppStoreConnectTransportFixture(responses: [
    AppStoreConnectResponse(statusCode: 503),
    AppStoreConnectResponse(statusCode: 200),
  ])
  let sleepRecorder = RetrySleepRecorder()
  let transport = AppStoreConnectRetryingTransport(
    base: AppStoreConnectFixtureTransport(fixture: fixture),
    policy: .fixed(maxRetries: 1, delay: 0.25),
    sleep: { await sleepRecorder.record($0) }
  )

  let response = try await transport.send(
    AppStoreConnectRequest(method: .post, path: "/v1/appScreenshots"),
    in: .publicAPI
  )
  let recorded = await fixture.requests()

  #expect(response.statusCode == 503)
  #expect(recorded.count == 1)
  #expect(await sleepRecorder.delays().isEmpty)
}

@Test func retryPolicyCanOptIntoMutationRetriesWithBackoff() async throws {
  let fixture = AppStoreConnectTransportFixture(responses: [
    AppStoreConnectResponse(statusCode: 500),
    AppStoreConnectResponse(statusCode: 502),
    AppStoreConnectResponse(statusCode: 200),
  ])
  let sleepRecorder = RetrySleepRecorder()
  let transport = AppStoreConnectRetryingTransport(
    base: AppStoreConnectFixtureTransport(fixture: fixture),
    policy: .exponentialBackoff(
      maxRetries: 2,
      initialDelay: 0.5,
      retryableMethods: ["POST"]
    ),
    sleep: { await sleepRecorder.record($0) }
  )

  let response = try await transport.send(
    AppStoreConnectRequest(method: .post, path: "/v1/appScreenshots"),
    in: .publicAPI
  )
  let recorded = await fixture.requests()

  #expect(response.statusCode == 200)
  #expect(recorded.count == 3)
  #expect(await sleepRecorder.delays() == [0.5, 1.0])
}

@Test func retryingDownloadTransportRetriesAndRemovesFailedTemporaryFile() async throws {
  let failedURL = try temporaryFile(contents: "failed")
  let successURL = try temporaryFile(contents: "downloaded")
  defer {
    try? FileManager.default.removeItem(at: failedURL)
    try? FileManager.default.removeItem(at: successURL)
  }

  let fixture = DownloadFixtureTransport(responses: [
    AppStoreConnectDownloadResponse(
      fileURL: failedURL,
      response: AppStoreConnectResponse(statusCode: 503)
    ),
    AppStoreConnectDownloadResponse(
      fileURL: successURL,
      response: AppStoreConnectResponse(statusCode: 200)
    ),
  ])
  let sleepRecorder = RetrySleepRecorder()
  let transport = AppStoreConnectRetryingDownloadTransport(
    base: fixture,
    policy: .fixed(maxRetries: 1, delay: 0.25),
    sleep: { await sleepRecorder.record($0) }
  )

  let response = try await transport.download(
    AppStoreConnectRequest(method: .get, path: "/v1/salesReports"),
    in: .publicAPI
  )
  let recorded = await fixture.downloads()

  #expect(response.response.statusCode == 200)
  #expect(try String(contentsOf: response.fileURL, encoding: .utf8) == "downloaded")
  #expect(FileManager.default.fileExists(atPath: failedURL.path) == false)
  #expect(recorded.count == 2)
  #expect(await sleepRecorder.delays() == [0.25])
}

@Test func paginatorCreatesNextRequestFromAbsoluteURL() throws {
  let original = AppStoreConnectRequest(
    method: .get,
    path: "/v1/apps",
    headers: ["Authorization": "Bearer token"]
  )
  let links = AppStoreConnectPaginationLinks(
    next: URL(string: "https://api.appstoreconnect.apple.com/v1/apps?cursor=next")!
  )

  let next = try #require(AppStoreConnectPaginator().nextRequest(after: original, links: links))

  #expect(next.method == "GET")
  #expect(next.path == "https://api.appstoreconnect.apple.com/v1/apps?cursor=next")
  #expect(next.headers["Authorization"] == "Bearer token")
}

@Test(arguments: [
  "https://unrelated.invalid/v1/apps",
  "http://api.appstoreconnect.apple.com/v1/apps",
  "https://api.appstoreconnect.apple.com:444/v1/apps",
  "https://token@api.appstoreconnect.apple.com/v1/apps",
])
func authenticatedPaginationRejectsUntrustedDestinations(nextURL: String) async throws {
  let fixture = AppStoreConnectTransportFixture(responses: [.init(statusCode: 200)])
  let credential = RecordingCredential()
  let transport = AppStoreConnectAuthenticatedTransport(
    base: AppStoreConnectFixtureTransport(fixture: fixture), credential: credential)
  let request = try #require(
    AppStoreConnectPaginator().nextRequest(
      after: .init(method: .get, path: "/v1/apps", headers: ["Authorization": "Bearer previous"]),
      links: .init(next: try #require(URL(string: nextURL)))))

  await #expect(
    throws: AppStoreConnectError.authenticationFailed(
      "Authenticated request must use the environment's HTTP origin.")
  ) {
    try await transport.send(request, in: .publicAPI)
  }
  #expect(await credential.calls == 0)
  #expect(await fixture.requests().isEmpty)
}

@Test(arguments: [
  "/v1/apps",
  "https://api.appstoreconnect.apple.com/v1/apps?cursor=next",
  "https://API.APPSTORECONNECT.APPLE.COM:443/v1/apps?cursor=next",
])
func authenticatedTransportAcceptsEquivalentOrigins(path: String) async throws {
  let fixture = AppStoreConnectTransportFixture(responses: [.init(statusCode: 200)])
  let transport = AppStoreConnectAuthenticatedTransport(
    base: AppStoreConnectFixtureTransport(fixture: fixture),
    credential: AppStoreConnectBearerToken(token: "fixture"))
  _ = try await transport.send(.init(method: .get, path: path), in: .publicAPI)
  let requests = await fixture.requests()
  #expect(requests.count == 1)
  #expect(requests.first?.request.headers["Authorization"] == "Bearer fixture")
}

private actor RecordingCredential: AppStoreConnectCredential {
  private(set) var calls = 0
  func authorizationHeaderValue() async throws -> String {
    calls += 1
    return "Bearer fixture"
  }
}

@Test func uploadOperationKeepsChunkMetadata() throws {
  let operation = AppStoreConnectUploadOperation(
    method: .put,
    url: try #require(URL(string: "https://example.com/upload")),
    headers: ["Content-Type": "application/octet-stream"],
    offset: 10,
    length: 20
  )

  #expect(operation.method == .put)
  #expect(operation.offset == 10)
  #expect(operation.length == 20)
  #expect(operation.headers["Content-Type"] == "application/octet-stream")

  let uploadRequest = try operation.request(from: Data("012345678901234567890123456789".utf8))
  #expect(uploadRequest.method == "PUT")
  #expect(uploadRequest.path == "https://example.com/upload")
  #expect(uploadRequest.headers["Content-Type"] == "application/octet-stream")
  #expect(String(data: try #require(uploadRequest.body), encoding: .utf8) == "01234567890123456789")
}

@Test(arguments: [(Int64.max, 1), (1, Int64.max), (4, 1), (-1, 1), (0, -1)] as [(Int64, Int64)])
func uploadRejectsInvalidBounds(bounds: (Int64, Int64)) throws {
  let operation = AppStoreConnectUploadOperation(
    method: .put, url: try #require(URL(string: "https://example.com/upload")),
    offset: bounds.0, length: bounds.1)
  #expect(throws: AppStoreConnectError.self) {
    try operation.bodyChunk(from: Data([0, 1, 2, 3]))
  }
}

@Test func uploadOffsetsAreRelativeToSlicedData() throws {
  let data = Data([0, 1, 2, 3, 4, 5])[2..<6]
  var operation = AppStoreConnectUploadOperation(
    method: .put, url: try #require(URL(string: "https://example.com/upload")),
    offset: 1, length: 2)
  #expect(try operation.bodyChunk(from: data) == Data([3, 4]))
  operation.offset = 4
  operation.length = 0
  #expect(try operation.bodyChunk(from: data).isEmpty)
}

private func tokenParts(_ token: String) -> (header: String, payload: String, signature: String) {
  let parts = token.split(separator: ".").map(String.init)
  #expect(parts.count == 3)
  return (parts[0], parts[1], parts[2])
}

private func jsonObject(fromBase64URL value: String) throws -> [String: Any] {
  let data = try #require(Data(appStoreConnectBase64URL: value))
  return try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
}

private func verifiesSignature(
  parts: (header: String, payload: String, signature: String),
  publicKey: P256.Signing.PublicKey
) throws -> Bool {
  let signatureData = try #require(Data(appStoreConnectBase64URL: parts.signature))
  let signature = try P256.Signing.ECDSASignature(rawRepresentation: signatureData)
  return publicKey.isValidSignature(signature, for: Data("\(parts.header).\(parts.payload)".utf8))
}

private func temporaryFile(contents: String) throws -> URL {
  let url = FileManager.default.temporaryDirectory
    .appendingPathComponent("swift-appstoreconnect-\(UUID().uuidString)")
  try contents.write(to: url, atomically: true, encoding: .utf8)
  return url
}

extension Data {
  fileprivate init?(appStoreConnectBase64URL value: String) {
    var base64 =
      value
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")

    let padding = base64.count % 4
    if padding > 0 {
      base64.append(String(repeating: "=", count: 4 - padding))
    }

    self.init(base64Encoded: base64)
  }
}

private actor RetrySleepRecorder {
  private var recordedDelays: [TimeInterval] = []

  func record(_ delay: TimeInterval) {
    recordedDelays.append(delay)
  }

  func delays() -> [TimeInterval] {
    recordedDelays
  }
}

private final class MutableClock: AppStoreConnectClock, @unchecked Sendable {
  var now: Date

  init(now: Date) {
    self.now = now
  }
}

private actor DownloadFixtureTransport: AppStoreConnectDownloadTransport {
  private var responses: [AppStoreConnectDownloadResponse]
  private var recordedDownloads: [AppStoreConnectRecordedRequest] = []

  init(responses: [AppStoreConnectDownloadResponse]) {
    self.responses = responses
  }

  func send(
    _ request: AppStoreConnectRequest,
    in environment: AppStoreConnectEnvironment
  ) async throws -> AppStoreConnectResponse {
    let download = try await self.download(request, in: environment)
    return download.response
  }

  func download(
    _ request: AppStoreConnectRequest,
    in environment: AppStoreConnectEnvironment
  ) async throws -> AppStoreConnectDownloadResponse {
    recordedDownloads.append(
      AppStoreConnectRecordedRequest(request: request, environment: environment))

    guard !responses.isEmpty else {
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "No fixture response is available.")
    }

    return responses.removeFirst()
  }

  func downloads() -> [AppStoreConnectRecordedRequest] {
    recordedDownloads
  }
}

@Test func privateKeyLoadingChecksPermissionsAndFileIdentity() throws {
  let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
  try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
  defer { try? FileManager.default.removeItem(at: directory) }
  let url = directory.appendingPathComponent("AuthKey.p8")
  let key = P256.Signing.PrivateKey()
  try Data(key.pemRepresentation.utf8).write(to: url)
  try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
  let loaded = try AppStoreConnectJWTSigningKey.load(keyID: "TESTKEY", from: url)
  #expect(loaded.keyID == "TESTKEY")
  try FileManager.default.setAttributes([.posixPermissions: 0o640], ofItemAtPath: url.path)
  #expect(throws: AppStoreConnectError.self) {
    try AppStoreConnectJWTSigningKey.load(keyID: "TESTKEY", from: url)
  }
  let link = directory.appendingPathComponent("link.p8")
  try FileManager.default.createSymbolicLink(at: link, withDestinationURL: url)
  #expect(throws: AppStoreConnectError.self) {
    try AppStoreConnectJWTSigningKey.load(keyID: "TESTKEY", from: link)
  }
  do {
    _ = try AppStoreConnectJWTSigningKey.load(
      keyID: "TESTKEY", from: directory.appendingPathComponent("missing.p8"))
    Issue.record("Missing private key should fail")
  } catch {
    #expect(!String(describing: error).contains(directory.path))
    #expect(!String(describing: error).contains("missing.p8"))
  }
}
