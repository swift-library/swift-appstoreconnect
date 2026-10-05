# ``AppStoreConnectPublicAPI``

Typed clients generated from the locked Apple specification.

`PublicAPIBase` is the default typed slice. Optional domain traits and `PublicAPIFull` select additional generated operations.

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
