// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

#if ASC_EXPERIMENTAL
  import AppStoreConnectCore
  import AppStoreConnectIrisAPI
  import AppStoreConnectWebSession
  import Foundation
  import Testing

  @Test func endpointLedgerRecordsAppStoreVersionStateChanges() throws {
    let endpoint = IrisEndpointLedger.appStoreVersionStateChanges

    #expect(endpoint.id == .appStoreVersionStateChanges)
    #expect(endpoint.capability == .appStoreVersionHistory)
    #expect(endpoint.method == .get)
    #expect(endpoint.host.absoluteString == "https://appstoreconnect.apple.com/iris/v1")
    #expect(
      endpoint.pathTemplate == "/appStoreVersions/{appStoreVersionID}/appStoreVersionStateChanges")
    #expect(
      endpoint.requiredHeaders == [
        "Accept",
        "Cookie",
        "Origin",
        "Referer",
        "X-Requested-With",
      ])
    #expect(endpoint.requestPayload == "None.")
    #expect(endpoint.isMutating == false)
    #expect(endpoint.driftPolicy == .failClosed)
    #expect(
      try endpoint.path(parameters: ["appStoreVersionID": "version 1"])
        == "/appStoreVersions/version%201/appStoreVersionStateChanges")
  }

  @Test func clientSendsIrisRequestWithWebSessionCookieHeaders() async throws {
    let fixture = AppStoreConnectTransportFixture(responses: [
      AppStoreConnectResponse(
        statusCode: 200,
        headers: ["Content-Type": "application/json"],
        body: try fixtureData("app-store-version-state-changes.json")
      )
    ])
    let client = IrisAPIClient(
      sessionProvider: StaticWebSessionProvider(
        WebSession(
          cookies: [
            "itctx": "context",
            "myacinfo": "token",
          ],
          expiresAt: Date(timeIntervalSince1970: 2_000_000_000),
          source: .environment
        )),
      transport: AppStoreConnectFixtureTransport(fixture: fixture)
    )

    let response = try await client.appStoreVersionStateChanges(
      appStoreVersionID: "version-1",
      now: Date(timeIntervalSince1970: 1_700_000_000)
    )
    let recorded = await fixture.requests()

    #expect(response.data.map(\.id) == ["state-change-1"])
    #expect(response.data.first?.type == "appStoreVersionStateChanges")
    #expect(response.data.first?.attributes?["state"]?.stringValue == "PREPARE_FOR_SUBMISSION")
    #expect(recorded.count == 1)
    #expect(recorded[0].environment == .irisAPI)
    #expect(recorded[0].request.method == "GET")
    #expect(recorded[0].request.path == "/appStoreVersions/version-1/appStoreVersionStateChanges")
    #expect(recorded[0].request.headers["Accept"] == "application/json")
    #expect(recorded[0].request.headers["Cookie"] == "itctx=context; myacinfo=token")
    #expect(recorded[0].request.headers["Origin"] == "https://appstoreconnect.apple.com")
    #expect(recorded[0].request.headers["Referer"] == "https://appstoreconnect.apple.com/")
    #expect(recorded[0].request.headers["X-Requested-With"] == "XMLHttpRequest")
    #expect(recorded[0].request.headers["Authorization"] == nil)
  }

  @Test func clientFailsClosedOnUnauthorizedIrisResponse() async {
    let fixture = AppStoreConnectTransportFixture(responses: [
      AppStoreConnectResponse(statusCode: 401)
    ])
    let client = IrisAPIClient(
      sessionProvider: StaticWebSessionProvider(
        WebSession(
          cookies: ["myacinfo": "token"],
          expiresAt: Date(timeIntervalSince1970: 2_000_000_000),
          source: .environment
        )),
      transport: AppStoreConnectFixtureTransport(fixture: fixture)
    )

    await #expect(
      throws: AppStoreConnectError.authenticationFailed(
        "Iris web session is unauthorized or expired.")
    ) {
      _ = try await client.appStoreVersionStateChanges(
        appStoreVersionID: "version-1",
        now: Date(timeIntervalSince1970: 1_700_000_000)
      )
    }
  }

  @Test func clientFailsClosedOnIrisResponseShapeDrift() async {
    let fixture = AppStoreConnectTransportFixture(responses: [
      AppStoreConnectResponse(
        statusCode: 200,
        headers: ["Content-Type": "application/json"],
        body: Data(#"{"data":{"id":"not-a-list"}}"#.utf8)
      )
    ])
    let client = IrisAPIClient(
      sessionProvider: StaticWebSessionProvider(
        WebSession(
          cookies: ["myacinfo": "token"],
          expiresAt: Date(timeIntervalSince1970: 2_000_000_000),
          source: .environment
        )),
      transport: AppStoreConnectFixtureTransport(fixture: fixture)
    )

    do {
      _ = try await client.appStoreVersionStateChanges(
        appStoreVersionID: "version-1",
        now: Date(timeIntervalSince1970: 1_700_000_000)
      )
      Issue.record("Expected Iris response shape drift to fail closed.")
    } catch let AppStoreConnectError.decodingFailed(message) {
      #expect(message.contains("appStoreVersionStateChanges"))
    } catch {
      Issue.record("Expected decodingFailed, got \(error).")
    }
  }

  private func fixtureData(_ name: String) throws -> Data {
    let url = try #require(Bundle.module.url(forResource: name, withExtension: nil))
    return try Data(contentsOf: url)
  }

#endif
