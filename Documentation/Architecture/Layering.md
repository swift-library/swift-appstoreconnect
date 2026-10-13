# Layering

## Scope / Purpose

This document defines the SwiftPM target boundaries for `swift-appstoreconnect`.
Target internals and source layout are defined in `TechnicalDesign.md`.

## Current Structure

`AppStoreConnectCore` is the only foundation layer. It must not depend on package-local higher layers.

`AppStoreConnectPublicAPI` depends on `AppStoreConnectCore` and will hold public App Store Connect API bindings and typed clients. Its generated binding strategy is defined in `Codegen.md`.

`AppStoreConnectWebSession` depends on `AppStoreConnectCore` and owns provider-oriented web sessions, cookies, environment/session-file/browser-cookie inputs, and session-cache policy. The `Experimental` trait enables this module; it is empty by default. Live Apple Account login and 2FA are unavailable.

`AppStoreConnectIrisAPI` depends on `AppStoreConnectCore` and `AppStoreConnectWebSession`. The default-off `Experimental` trait enables its API. It owns private `/iris/v1` endpoint ledgers, request building, response fixtures, and fail-closed diagnostics, and calls Iris endpoints only after a session provider supplies usable web credentials.

`AppStoreConnectWorkflow` depends on `AppStoreConnectCore`, `AppStoreConnectPublicAPI`, `AppStoreConnectWebSession`, and `AppStoreConnectIrisAPI`. It coordinates multi-step operations, workflow-file execution, runtime construction, command-shaped read/write facades over lower library clients, file-backed outputs such as report/certificate/profile downloads, auth/session status commands over WebSession providers, and local Xcode/Transporter handoff commands, and does not own endpoint model definitions or live session-login implementation. Auth/session APIs compile with `Experimental`. Local process execution requires macOS; injectable tool runners and plans are available on every declared platform.

`AppStoreConnectCLI` depends on `AppStoreConnectWorkflow`. It is the command-line composition boundary and stays thin: parse intent, call workflow APIs, render output, and map exit codes.

## Key Principles

- `WebSession` and `IrisAPI` remain separate because acquiring a session and calling private endpoints are different responsibilities.
- `Workflow` is not a single endpoint layer; it composes public API calls, Iris calls, local Xcode steps, and state transitions.
- `CLI` is not a workflow or endpoint layer; it parses command intent and delegates to workflow APIs.
- Package behavior is implemented in Swift at the library boundary.
- Each public module has a target-local DocC catalog. `Scripts/check-docs` compiles and merges the catalogs with warnings as errors.

## Related Decisions

No decision records exist yet.
