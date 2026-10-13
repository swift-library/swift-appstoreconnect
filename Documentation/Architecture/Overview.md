# Architecture Overview

## Scope / Purpose

`swift-appstoreconnect` is a Swift package for App Store Connect API access, private Iris API research, Apple Account web-session handling, and high-level workflow execution.

## Context / Boundaries

The package boundary is library-first. The CLI target is a thin process boundary and must stay behind the package API boundary.

## Constraints

- The implementation remains all Swift.
- Public API clients, private Iris clients, web-session acquisition, and workflow orchestration stay in separate targets.
- The current package state is a compilable Core/PublicAPI codegen and facade
  foundation with one PublicAPI-backed workflow slice and a deterministic
  WebSession provider/cache baseline plus one fixture-backed Iris endpoint;
  the first workflow-file runner and thin CLI surface are also in place.

## Current Structure

- `AppStoreConnectCore` owns shared environment, HTTP request/response,
  transport, credential, pagination, upload, and error primitives.
- `AppStoreConnectPublicAPI` owns public App Store Connect API Apple generated
  typed bindings, trait-aligned capability slices, generated capability
  facades, and handwritten convenience clients.
- `AppStoreConnectWebSession` owns provider-oriented web sessions, cookies,
  environment/session-file/browser-cookie inputs, and cache policy. Live SRP/2FA
  login remains deferred.
- `AppStoreConnectIrisAPI` owns `/iris/v1` private endpoint ledgers, client
  request building, generic private response models, and fail-closed
  diagnostics.
- `AppStoreConnectWorkflow` owns built-in release flows, the first
  PublicAPI-backed readiness workflow, and the workflow-file runner.
- `AppStoreConnectCLI` owns the thin command surface and delegates execution to
  workflow APIs.

## Risks / Known Gaps

- DocC catalogs are intentionally deferred until public APIs stabilize.
- Public API code generation has a locked schema snapshot, schema audit,
  Apple-generator adapter, trait-aligned filter plan, and build tool plugin.
- Public API generated output currently has a selected typed-client lane and
  generated capability facade lane used by the public workflow seed. The next
  route expands Apple typed output through SwiftPM trait-aligned API slices,
  with `PublicAPIFull` reserved for aggregate full typed coverage. Traits map
  to plugin-visible compilation conditions, and slice manifests describe
  operation/tag/path/schema selector intent rather than hand-trimmed OpenAPI
  JSON. A package-owned catalog emitter is deferred.
- Target-level technical design is documented in `TechnicalDesign.md`.
- WebSession and Iris behavior depends on private Apple flows and can change without notice.
