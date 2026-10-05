# ``AppStoreConnectWebSession``

Experimental cookie providers and session storage.

Enable the `Experimental` package trait to use this module. Its product compiles empty when the trait is disabled. Live Apple Account login, 2FA, and Iris mutations are unavailable.

## Topics

### API

- ``WebSession``
- ``WebSessionProvider``
- ``StaticWebSessionProvider``
- ``WebSessionFileStore``

### Usage

```swift
import AppStoreConnectWebSession

let session = WebSession(cookies: ["myacinfo": "example-cookie"])
let provider = StaticWebSessionProvider(session)
```
