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

### Nullable request fields

An optional nullable property uses `T??` to distinguish an omitted key from an
explicit JSON null. Outer `nil` omits the key, `.some(nil)` clears the field,
and `.some(.some(value))` sends a value. Required nullable properties use `T?`,
require an initializer argument, and always encode the key; their decoder
rejects a missing key.

```swift
import AppStoreConnectPublicAPI

let attributes = Components.Schemas.AppUpdateRequest.DataPayload.AttributesPayload(
    accessibilityUrl: .some(nil),
    primaryLocale: .some(.some("en-US"))
)
```

This update clears the accessibility URL, sets the primary locale, and omits
other attributes. When forwarding a `T?` whose `nil` means “leave unchanged,”
use `value.map { .some($0) }` to preserve the missing-key state. Workflow input
optionals retain that omission behavior.
