# ``AppStoreConnectCLI``

@Metadata {
  @PageImage(purpose: icon, source: "appstoreconnectcli-icon", alt: "swift-appstoreconnect icon")
  @PageColor(yellow)
}

Command parsing, output, and exit status.

Run `appstoreconnect --help`, `--version`, and `commands list --json` to inspect the executable. Public API execution uses the caller-provided `ASC_API_TOKEN` JWT. Supported mutations default to a dry-run plan and require `--confirm` to execute. Iris and Apple Account session paths require the default-off `Experimental` package trait.

## Topics

### Guides

- <doc:CommandGuide>

### API

- ``AppStoreConnectCommand``
- ``AppStoreConnectCLIResult``
- ``AppStoreConnectCLICommandRegistry``
- ``AppStoreConnectCLICommandDescriptor``
