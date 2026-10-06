# ``AppStoreConnectPublicAPI``

@Metadata {
  @PageImage(purpose: icon, source: "appstoreconnectpublicapi-icon", alt: "swift-appstoreconnect icon")
  @PageColor(yellow)
}

Typed clients generated from the locked Apple specification.

`Client`, `Components`, and `Operations` are generated from the locked Apple OpenAPI specification. `AppStoreConnectPublicClient` groups the selected operations behind capability facades. `PublicAPIBase` is enabled by default; domain traits and `PublicAPIFull` expand the generated API. Disabling default traits retains the baseline used by Workflow and CLI.

## Topics

### API

- ``AppStoreConnectPublicClient``
- ``RawPublicAPIClient``
- ``Client``
- ``PublicAPICapability``

### Usage

```swift
import AppStoreConnectCore
import AppStoreConnectPublicAPI

let client = AppStoreConnectPublicClient(
    client: Client.appStoreConnectURLSession(
        credential: AppStoreConnectBearerToken(token: "example-token")
    )
)
let apps = client.apps
```
