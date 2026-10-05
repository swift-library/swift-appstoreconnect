import AppStoreConnectCore
import AppStoreConnectPublicAPI
import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing

@Test func selectedTypedOpenAPIModelsAreUsable() {
    #expect(AppStoreConnectSelectedOpenAPI.schemaVersion == "4.3")
    #expect(AppStoreConnectSelectedOpenAPI.capabilityIDs == [
        "apps",
        "builds",
        "testflight",
        "media-assets",
        "reports",
        "users",
        "certificates-profiles",
    ])
    #expect(AppStoreConnectSelectedOpenAPI.pathCount == 86)
    #expect(AppStoreConnectSelectedOpenAPI.schemaCount == 255)
    #expect(Components.Schemas.App._TypePayload.apps.rawValue == "apps")

    let response = Components.Schemas.AppsResponse(
        data: [
            Components.Schemas.App(
                id: "123",
                _type: .apps
            )
        ],
        links: Components.Schemas.PagedDocumentLinks(_self: "https://api.appstoreconnect.apple.com/v1/apps")
    )

    #expect(response.data.first?.id == "123")
}

@Test func selectedTypedOpenAPIClientIsGenerated() {
    #expect(AppStoreConnectSelectedOpenAPI.schemaVersion == "4.3")
    #expect(AppStoreConnectSelectedOpenAPI.operationIDs.count == 140)
    #expect(Operations.AppsGetCollection.id == "apps_getCollection")
    #expect(Operations.AppsAppStoreVersionsGetToManyRelated.id == "apps_appStoreVersions_getToManyRelated")
    #expect(Operations.BuildUploadsCreateInstance.id == "buildUploads_createInstance")
    #expect(Operations.AppsBetaTesterUsagesGetMetrics.id == "apps_betaTesterUsages_getMetrics")
    #expect(Operations.BuildsBetaBuildUsagesGetMetrics.id == "builds_betaBuildUsages_getMetrics")
    #expect(Operations.BetaGroupsGetCollection.id == "betaGroups_getCollection")
    #expect(Operations.BetaGroupsPublicLinkUsagesGetMetrics.id == "betaGroups_publicLinkUsages_getMetrics")
    #expect(Operations.AppPreviewsCreateInstance.id == "appPreviews_createInstance")
    #expect(Operations.SalesReportsGetCollection.id == "salesReports_getCollection")
    #expect(Operations.ProfilesGetInstance.id == "profiles_getInstance")

    let client = Client.appStoreConnectURLSession()
    _ = client
}

@Test func selectedTypedOpenAPIClientCanBeConstructedWithCredentialMiddleware() {
    let client = Client.appStoreConnectURLSession(
        credential: AppStoreConnectBearerToken(token: "test-token")
    )

    _ = client
}

@Test func generatedPublicFacadeRoutesCapabilityCallsThroughOpenAPIClient() async throws {
    let transport = RecordingOpenAPITransport()
    let generatedClient = Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    )
    let client = AppStoreConnectPublicClient(client: generatedClient)

    let appsOutput = try await client.apps.listApps()
    #expect(try appsOutput.ok.body.json.data.isEmpty)

    let appOutput = try await client.apps.getApp(id: "123")
    #expect(try appOutput.ok.body.json.data.id == "123")

    let requests = await transport.requests()
    #expect(requests.map(\.operationID) == ["apps_getCollection", "apps_getInstance"])
    #expect(requests.map(\.path) == ["/v1/apps", "/v1/apps/123"])
}

@Test func generatedPublicFacadeExposesSelectedCapabilities() {
    let generatedClient = Client.appStoreConnectURLSession()
    let client = AppStoreConnectPublicClient(client: generatedClient)

    _ = client.apps
    _ = client.builds
    _ = client.testFlight
    _ = client.mediaAssets
    _ = client.reports
    _ = client.users
    _ = client.certificatesProfiles

    #expect(PublicAPICapability.allCases.map(\.rawValue) == [
        "apps",
        "builds",
        "testflight",
        "media-assets",
        "reports",
        "users",
        "certificates-profiles",
    ])
}

@Test func openAPIRetryMiddlewareRetriesRateLimitedGeneratedCall() async throws {
    let transport = RateLimitedOpenAPITransport()
    let generatedClient = Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport,
        middlewares: [
            AppStoreConnectOpenAPIRetryMiddleware(
                policy: .fixed(maxRetries: 1, delay: 0),
                sleep: { _ in }
            ),
        ]
    )
    let client = AppStoreConnectPublicClient(client: generatedClient)

    let appsOutput = try await client.apps.listApps()
    let requestCount = await transport.requestCount()

    #expect(try appsOutput.ok.body.json.data.isEmpty)
    #expect(requestCount == 2)
}

@Test func rawPublicAPIClientUploadsOperationThroughRetryingTransport() async throws {
    let fixture = AppStoreConnectTransportFixture(responses: [
        AppStoreConnectResponse(statusCode: 500),
        AppStoreConnectResponse(statusCode: 200),
    ])
    let client = RawPublicAPIClient(transport: AppStoreConnectFixtureTransport(fixture: fixture))
    let operation = AppStoreConnectUploadOperation(
        method: .put,
        url: try #require(URL(string: "https://example.com/upload")),
        headers: ["Content-Type": "application/octet-stream"],
        offset: 1,
        length: 3
    )

    let response = try await client.upload(
        operation,
        from: Data("abcdef".utf8),
        retryPolicy: .upload(maxRetries: 1, delay: 0)
    )
    let recorded = await fixture.requests()

    #expect(response.statusCode == 200)
    #expect(recorded.count == 2)
    #expect(recorded[0].request.path == "https://example.com/upload")
    #expect(String(data: try #require(recorded[0].request.body), encoding: .utf8) == "bcd")
}

@Test func rawPublicAPIClientDownloadsResponseBodyToFile() async throws {
    let fixture = AppStoreConnectTransportFixture(responses: [
        AppStoreConnectResponse(statusCode: 200, body: Data("report-data".utf8)),
    ])
    let client = RawPublicAPIClient(transport: AppStoreConnectFixtureTransport(fixture: fixture))
    let outputURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("swift-appstoreconnect-download-\(UUID().uuidString)")
    defer {
        try? FileManager.default.removeItem(at: outputURL)
    }

    let downloadedURL = try await client.download(
        AppStoreConnectRequest(method: .get, path: "/v1/salesReports"),
        to: outputURL
    )
    let recorded = await fixture.requests()

    #expect(downloadedURL == outputURL)
    #expect(try String(contentsOf: downloadedURL, encoding: .utf8) == "report-data")
    #expect(recorded.map(\.request.path) == ["/v1/salesReports"])
}

@Test func publicPaginationExtractsGeneratedPageLinks() throws {
    let page = Components.Schemas.AppsResponse(
        data: [],
        links: Components.Schemas.PagedDocumentLinks(
            first: "https://api.appstoreconnect.apple.com/v1/apps",
            next: "https://api.appstoreconnect.apple.com/v1/apps?cursor=next",
            _self: "https://api.appstoreconnect.apple.com/v1/apps"
        )
    )

    let links = try #require(AppStoreConnectOpenAPIPagination.links(from: page))

    #expect(links.first?.absoluteString == "https://api.appstoreconnect.apple.com/v1/apps")
    #expect(links.next?.absoluteString == "https://api.appstoreconnect.apple.com/v1/apps?cursor=next")
    #expect(links.selfURL?.absoluteString == "https://api.appstoreconnect.apple.com/v1/apps")
}

@Test func rawPublicAPIClientFetchesNextGeneratedPage() async throws {
    let fixture = AppStoreConnectTransportFixture(responses: [
        AppStoreConnectResponse(
            statusCode: 200,
            body: Data("""
            {
              "data": [
                { "type": "apps", "id": "next-app" }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/apps?cursor=next"
              }
            }
            """.utf8)
        ),
    ])
    let client = RawPublicAPIClient(transport: AppStoreConnectFixtureTransport(fixture: fixture))
    let firstPage = Components.Schemas.AppsResponse(
        data: [
            Components.Schemas.App(id: "first-app", _type: .apps),
        ],
        links: Components.Schemas.PagedDocumentLinks(
            next: "https://api.appstoreconnect.apple.com/v1/apps?cursor=next",
            _self: "https://api.appstoreconnect.apple.com/v1/apps"
        )
    )

    let nextPage: Components.Schemas.AppsResponse? = try await client.nextPage(after: firstPage)
    let recorded = await fixture.requests()

    #expect(nextPage?.data.first?.id == "next-app")
    #expect(recorded.count == 1)
    #expect(recorded[0].request.method == "GET")
    #expect(recorded[0].request.path == "https://api.appstoreconnect.apple.com/v1/apps?cursor=next")
}

@Test func rawPublicAPIClientPagesSequenceYieldsFirstAndNextPage() async throws {
    let fixture = AppStoreConnectTransportFixture(responses: [
        AppStoreConnectResponse(
            statusCode: 200,
            body: Data("""
            {
              "data": [
                { "type": "apps", "id": "next-app" }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/apps?cursor=next"
              }
            }
            """.utf8)
        ),
    ])
    let client = RawPublicAPIClient(transport: AppStoreConnectFixtureTransport(fixture: fixture))
    let firstPage = Components.Schemas.AppsResponse(
        data: [
            Components.Schemas.App(id: "first-app", _type: .apps),
        ],
        links: Components.Schemas.PagedDocumentLinks(
            next: "https://api.appstoreconnect.apple.com/v1/apps?cursor=next",
            _self: "https://api.appstoreconnect.apple.com/v1/apps"
        )
    )
    var ids: [String] = []

    for try await page in client.pages(startingWith: firstPage) {
        ids.append(contentsOf: page.data.map(\.id))
    }

    #expect(ids == ["first-app", "next-app"])
}

@Test func openAPIErrorMiddlewareDecodesStructuredErrorBody() async throws {
    let generatedClient = Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: ErrorOpenAPITransport(),
        middlewares: [
            AppStoreConnectOpenAPIErrorMiddleware(),
        ]
    )
    let client = AppStoreConnectPublicClient(client: generatedClient)
    var capturedError: AppStoreConnectPublicAPIError?

    do {
        _ = try await client.apps.listApps()
    } catch let error as ClientError {
        capturedError = error.underlyingError as? AppStoreConnectPublicAPIError
    } catch let error as AppStoreConnectPublicAPIError {
        capturedError = error
    }

    let error = try #require(capturedError)
    #expect(error.operationID == Operations.AppsGetCollection.id)
    #expect(error.statusCode == 409)
    #expect(error.requestPath == "/v1/apps")
    #expect(error.errors.first?.code == "ENTITY_ERROR")
    #expect(error.errors.first?.detail == "The request cannot be completed.")
    #expect(error.errors.first?.source?.parameter == "filter[name]")
}

private struct RecordedOpenAPIRequest: Sendable, Equatable {
    var operationID: String
    var path: String?
}

private actor RecordingOpenAPITransport: ClientTransport {
    private var recordedRequests: [RecordedOpenAPIRequest] = []

    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        recordedRequests.append(RecordedOpenAPIRequest(
            operationID: operationID,
            path: request.path
        ))

        var response = HTTPResponse(status: .ok)
        response.headerFields[.contentType] = "application/json"

        switch operationID {
        case Operations.AppsGetCollection.id:
            return (response, HTTPBody("""
            {"data":[],"links":{"self":"https://api.appstoreconnect.apple.com/v1/apps"}}
            """))
        case Operations.AppsGetInstance.id:
            return (response, HTTPBody("""
            {"data":{"type":"apps","id":"123"},"links":{"self":"https://api.appstoreconnect.apple.com/v1/apps/123"}}
            """))
        default:
            return (HTTPResponse(status: .internalServerError), nil)
        }
    }

    func requests() -> [RecordedOpenAPIRequest] {
        recordedRequests
    }
}

private actor RateLimitedOpenAPITransport: ClientTransport {
    private var count = 0

    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        count += 1

        guard count > 1 else {
            var response = HTTPResponse(status: .tooManyRequests)
            response.headerFields[.retryAfter] = "0"
            return (response, nil)
        }

        var response = HTTPResponse(status: .ok)
        response.headerFields[.contentType] = "application/json"

        switch operationID {
        case Operations.AppsGetCollection.id:
            return (response, HTTPBody("""
            {"data":[],"links":{"self":"https://api.appstoreconnect.apple.com/v1/apps"}}
            """))
        default:
            return (HTTPResponse(status: .internalServerError), nil)
        }
    }

    func requestCount() -> Int {
        count
    }
}

private struct ErrorOpenAPITransport: ClientTransport {
    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var response = HTTPResponse(status: .init(code: 409))
        response.headerFields[.contentType] = "application/json"
        return (response, HTTPBody("""
        {
          "errors": [
            {
              "status": "409",
              "code": "ENTITY_ERROR",
              "title": "Conflict",
              "detail": "The request cannot be completed.",
              "source": {
                "parameter": "filter[name]"
              }
            }
          ]
        }
        """))
    }
}
