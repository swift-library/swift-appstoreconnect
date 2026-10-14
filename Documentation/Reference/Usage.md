# Usage guide

## Overview

Build App Store Connect integrations with typed requests, explicit credentials,
and serializable workflow plans. The Public API client is generated from the
locked Apple OpenAPI specification. Domain traits select the API surface your
application needs.

| Product | Purpose |
| --- | --- |
| `AppStoreConnectCore` | Requests, transports, JWT credentials, retries, pagination, and upload primitives. |
| `AppStoreConnectPublicAPI` | Generated typed clients and capability facades. |
| `AppStoreConnectWorkflow` | Domain commands, built-in plans, and the workflow-file runner. |
| `AppStoreConnectWebSession` | Experimental cookie inputs, providers, and JSON session storage. |
| `AppStoreConnectIrisAPI` | Experimental read-only Iris endpoint access. |
| `appstoreconnect` | Command-line interface over Workflow. |

Supported Public API commands include app and build reads, TestFlight,
signing and provisioning, review submissions, commerce, reports, and
trait-selected domain operations. Implemented CLI writes are dry-run by default.
App Store/TestFlight publishing and metadata pull/push currently produce plans;
end-to-end publishing, metadata apply, resumable media upload, live Apple Account
login, and Iris writes are unavailable. See the
[command guide](../../Sources/AppStoreConnectCLI/AppStoreConnectCLI.docc/CommandGuide.md)
for command-specific behavior.

## Quick start

Construct a typed client with an existing JWT. This example creates the client
without sending a request; replace the example token through your application's
credential input before making live calls.

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

To sign tokens in your application, use `AppStoreConnectJWTSigningKey` with
`AppStoreConnectJWTSigner` and `AppStoreConnectCachedJWTCredential`. The key-file
loader requires an owned regular file with no group or other permissions.

Create a workflow plan without credentials or network access:

```swift
import AppStoreConnectWorkflow

let workflow = WorkflowRunner().dryRun(.publishAppStore)
let steps = workflow.steps
```

## CLI

From a source checkout, inspect the command registry and preview a workflow:

```sh
swift run appstoreconnect commands list --json
swift run appstoreconnect workflow dry-run public-release-readiness --app-id example-app
swift run appstoreconnect publish testflight --dry-run
```


Live Public API reads and supported writes use the caller-provided JWT in
`ASC_API_TOKEN`. For example, `swift run appstoreconnect apps list --limit 10`
reads apps visible to that credential. Supported mutations require `--confirm`;
plan-only commands return an unsupported result when asked to execute.

`commands list --json` distinguishes implemented commands, aliases, blocked
commands, and commands outside the package's scope. An implemented command may
provide planning only. Local Xcode archive, export, and upload commands require
macOS to execute and also require `--confirm`.

## Traits

`PublicAPIBase` is enabled by default. Disabling default traits still retains the
baseline needed by Workflow and CLI. Choose domain traits for additional typed
operations; `PublicAPIFull` enables all Public API domains and increases generated
source and compilation work. It does not enable `Experimental`.

| Trait | Additional API domain |
| --- | --- |
| `PublicAPIRelease` | Release, metadata, review, availability, and app events. |
| `PublicAPITestFlight` | Builds and TestFlight. |
| `PublicAPIMetadataMedia` | Localizations, screenshots, previews, custom product pages, and App Clips. |
| `PublicAPICommerce` | Purchases, subscriptions, prices, and offers. |
| `PublicAPIReports` | Analytics, metrics, sales, and finance reports. |
| `PublicAPISigningAccess` | Signing, provisioning, users, and access. |
| `PublicAPICloud` | Xcode Cloud and source-control integration. |
| `PublicAPIGameCenter` | Game Center. |
| `PublicAPIDistribution` | Alternative distribution, marketplaces, webhooks, and territories. |

For example, enable commerce while keeping defaults:

```sh
swift run --traits PublicAPICommerce,default appstoreconnect iap list --app example-app
```

`Experimental` is default-off. It enables WebSession, Iris, and their Workflow/CLI
paths; the WebSession and Iris products have no experimental declarations without
it. Session providers consume explicit cookie, session-file, or
browser-cookie-file input. They do not perform interactive account login.
