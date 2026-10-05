# ``AppStoreConnectCore``

HTTP, credentials, retries, pagination, and upload primitives.

## Topics

### API

- ``AppStoreConnectRequest``
- ``AppStoreConnectTransport``
- ``AppStoreConnectJWTSigner``
- ``AppStoreConnectJWTSigningKey``

### Usage

```swift
import AppStoreConnectCore

let request = AppStoreConnectRequest(method: .get, path: "/v1/apps")
let credential = AppStoreConnectBearerToken(token: "example-token")
```
