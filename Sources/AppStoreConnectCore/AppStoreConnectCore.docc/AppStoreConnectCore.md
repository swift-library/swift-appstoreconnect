# ``AppStoreConnectCore``

@Metadata {
  @PageImage(purpose: icon, source: "appstoreconnectcore-icon", alt: "swift-appstoreconnect icon")
  @PageColor(yellow)
}

HTTP, credentials, retries, pagination, and upload primitives.

Build requests and credentials, inject transports, and control retries, pagination, and uploads. The default typed client does not retry requests; opt into a retry policy for the operations that can be repeated safely.

`AppStoreConnectAuthenticatedTransport` checks the request's scheme, host, and
effective port against the supplied environment before asking for credentials.
Use it when following pagination links with API credentials. Upload operations
may use a separate storage origin; send those through an unauthenticated
transport with the operation's own headers.

## Topics

### API

- ``AppStoreConnectRequest``
- ``AppStoreConnectTransport``
- ``AppStoreConnectAuthenticatedTransport``
- ``AppStoreConnectJWTSigner``
- ``AppStoreConnectJWTSigningKey``

### Usage

```swift
import AppStoreConnectCore

let request = AppStoreConnectRequest(method: .get, path: "/v1/apps")
let credential = AppStoreConnectBearerToken(token: "example-token")
```
