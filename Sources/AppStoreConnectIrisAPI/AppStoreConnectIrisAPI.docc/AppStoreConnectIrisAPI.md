# ``AppStoreConnectIrisAPI``

@Metadata {
  @PageImage(purpose: icon, source: "appstoreconnectirisapi-icon", alt: "swift-appstoreconnect icon")
  @PageColor(yellow)
}

Experimental read-only Iris client.

Enable the default-off `Experimental` package trait to use the read-only `appStoreVersionStateChanges-v1` endpoint. Provide an existing `WebSessionProvider`; the client does not acquire Apple Account credentials. Mutating or non-GET descriptors are rejected before loading a session or sending a request. When the trait is disabled, this module has no experimental declarations.

## Topics

### API

- ``IrisAPIClient``
- ``IrisEndpointLedger``
- ``IrisEndpointDescriptor``
- ``IrisDriftPolicy``

### Usage

```swift
import AppStoreConnectCore
import AppStoreConnectWebSession
import AppStoreConnectIrisAPI

let provider = StaticWebSessionProvider(
    WebSession(cookies: ["myacinfo": "example-cookie"])
)
let client = IrisAPIClient(
    sessionProvider: provider,
    transport: AppStoreConnectFixtureTransport(
        fixture: AppStoreConnectTransportFixture(responses: [AppStoreConnectResponse(statusCode: 200)])
    )
)
```
