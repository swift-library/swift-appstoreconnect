# ``AppStoreConnectWebSession``

@Metadata {
  @PageImage(purpose: icon, source: "appstoreconnectwebsession-icon", alt: "swift-appstoreconnect icon")
  @PageColor(yellow)
}

Experimental cookie providers and session storage.

Enable the default-off `Experimental` package trait to import cookies from explicit environment, session-file, or browser-cookie-file inputs. `WebSessionFileStore` persists JSON sessions. Store those files in a private directory because they contain authentication cookies. Live Apple Account login and 2FA are unavailable. When the trait is disabled, this module has no experimental declarations.

Saving creates a file with owner-only read/write permissions (`0600`) and
atomically replaces the destination. The parent directory must belong to the
current user and must not allow group or other users to write. New directories
use owner-only access. An existing destination symlink is replaced without
writing its target. Loading an explicitly supplied session file does not change
that file's permissions.

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
