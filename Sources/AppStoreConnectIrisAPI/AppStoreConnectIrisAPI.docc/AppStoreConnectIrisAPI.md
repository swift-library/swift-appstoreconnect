# ``AppStoreConnectIrisAPI``

Experimental read-only Iris client.

Enable the `Experimental` package trait to use this module. Its product compiles empty when the trait is disabled. Live Apple Account login, 2FA, and Iris mutations are unavailable.

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
