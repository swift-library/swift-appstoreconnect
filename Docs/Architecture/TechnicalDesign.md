# Technical Design

## Scope / Purpose

This document is the implementation contract for `swift-appstoreconnect`.
It defines the package-owned types, target responsibilities, source layout, and
cross-target rules that future source changes should follow.


## Current Stage

The package currently contains a compilable Core/PublicAPI foundation,
trait-aligned Apple typed PublicAPI generation, generated capability facades, a
first executable PublicAPI-backed Workflow slice, retry-aware PublicAPI client
plumbing, a deterministic WebSession provider/cache baseline, a fixture-backed
Iris client baseline, a workflow-file runner, the first PublicAPI-backed read
command facade for apps/builds/App Store versions plus build processing-state
polling, TestFlight build namespace aliases and beta
group/tester/localization/review metadata/license agreement reads, and
signing/provisioning
bundle ID/certificate/device/profile reads, certificate/profile content
download/export,
plus user/user-invitation,
build-beta-detail, prerelease-version, and review-submission reads, and a thin
CLI boundary with TestFlight beta tester invitation dry-run/confirmed create,
TestFlight group/tester core mutations, beta review detail update/submission
create, app update, App Store version create/update/delete/release-request
mutations, review submission create/update/submit/cancel mutations, review item
create/update/delete mutations, signing/provisioning bundle ID create/update/
delete, certificate create/update/delete/revoke alias, device register/update/
enable/disable, and profile create/delete mutations, snapshot status reads,
trait-gated actor reads, trait-gated app category and age-rating read/write
commands, local schema introspection over the tracked official/selected OpenAPI
files, registry-backed shell completion generation, and local Xcode handoff
commands for version/archive/export/upload planning and execution, publish
appstore/testflight workflow dry-run planners, trait-gated customer review
list/view/rating-summary/response commands over Apple generated CustomerReview
operations, plus trait-gated App Clips and Game Center read command facades
over Apple generated OpenAPI operations, and metadata/media command facades
for local metadata validation, dry-run metadata planners, screenshot set/asset
reads, and app-preview set/asset reads. This design records the target
internals so future
implementation can proceed without inventing boundaries during source intake.

## Definition Gates

Implementation should not expand a target from an unverified reference:

- PublicAPI starts from a locked official schema snapshot, schema audit, and
  generator validation path.
- Core public API primitives start from the locked schema and official public
  API documentation for authentication, upload, pagination, rate-limit, and
  error semantics.
- Codegen tooling follows SwiftPM build tool plugin APIs; third-party generator
  implementations may inform ergonomics but do not define package behavior.
- WebSession starts from a provider contract, deterministic cookie/session
  fixtures, and cache fixtures. SRP login, 2FA, and trusted-device handling are
  Phase 2 work. It is private-flow support, not an official public App Store
  Connect API auth mechanism.
- Iris starts from a per-endpoint ledger and fixtures after a `WebSession`
  provider exists.
- Workflow steps declare whether their backing operation is public API-backed,
  upload-tool-backed, or Iris-backed before mutating execution.
- CLI starts from stable workflow APIs, structured output contracts, and an
  explicit parser strategy. ArgumentParser owns the process entry, version/help flags and shell completion generation; the package command dispatcher owns command-specific parsing.

Iris endpoint drift is an accepted external constraint. The implementation
response is isolation: fail closed in Iris clients, expose diagnostics, and keep
private capability flags at the Iris/Workflow boundary.

## Target Graph

| Target | Depends on | Owns | Must not own |
| --- | --- | --- | --- |
| `AppStoreConnectCore` | none | shared HTTP, environment, errors, auth primitives, pagination, upload primitives, transport seams | endpoint-specific payload models, web-session login, private Iris calls, workflows, CLI parsing |
| `AppStoreConnectPublicAPI` | `AppStoreConnectCore` | Apple generated public API models/operations/clients, generated capability facades, handwritten ergonomic wrappers | web-session acquisition, private Iris models, workflow state |
| `AppStoreConnectWebSession` | `AppStoreConnectCore` | Apple Account web-session providers, cookie sources, session cache, and future SRP/2FA provider implementations | Iris endpoint calls, public API JWT auth, workflow orchestration |
| `AppStoreConnectIrisAPI` | `AppStoreConnectCore`, `AppStoreConnectWebSession` | private Iris request building, Iris response models, Iris client facades | session acquisition, public API generated models, workflows |
| `AppStoreConnectWorkflow` | `AppStoreConnectCore`, `AppStoreConnectPublicAPI`, `AppStoreConnectWebSession`, `AppStoreConnectIrisAPI` | multi-step workflow planning, dry-run, execution, resume state, PublicAPI-backed read/write command facades with dry-run-first mutation outputs, WebSession auth/status command facades, local Xcode/Transporter handoff command facades, machine-readable outputs | endpoint payload definitions, live session login implementation, CLI parsing |
| `AppStoreConnectCLI` | `AppStoreConnectWorkflow` | command parsing, process exit behavior, stdout/stderr formatting | business logic, endpoint models, generated code, session storage |

No target may depend on `AppStoreConnectCLI`.

## Source Layout Contract

Implementation should split placeholder files into directories only when the
first real code for that responsibility lands.

```text
Sources/
  AppStoreConnectCore/
    Environment/
    HTTP/
    Auth/
    Pagination/
    Upload/
    Diagnostics/
  AppStoreConnectPublicAPI/
    Client/
    GeneratedSupport/
    Handwritten/
  AppStoreConnectWebSession/
    Login/
    TwoFactor/
    Cookies/
    Cache/
    Providers/
  AppStoreConnectIrisAPI/
    Client/
    Endpoints/
    Models/
  AppStoreConnectWorkflow/
    Builtins/
    Runner/
    State/
    Output/
  AppStoreConnectCLI/
    Command/
```

Generated public API Swift is not tracked under `Sources/`. The build plugin
emits it into SwiftPM's plugin work directory.

## Core Contract

`AppStoreConnectCore` is the only shared foundation. It should expose small
value types and protocols rather than endpoint clients.

Core owns:

- `AppStoreConnectEnvironment`: service identity and base URL.
- `AppStoreConnectRequest`: method, path, query, headers, body, and request
  metadata needed by transports.
- `AppStoreConnectResponse`: status, headers, body, and decoded diagnostic
  context.
- `AppStoreConnectTransport`: async request execution seam.
- `AppStoreConnectDownloadTransport`: optional streaming download execution seam
  for report/file endpoints, with body-buffer fallback kept at higher layers.
- `AppStoreConnectEndpoint`: endpoint descriptor protocol used by generated
  and handwritten clients.
- `AppStoreConnectCredential`: public API bearer/JWT credential abstraction.
- `AppStoreConnectJWTSigner`: App Store Connect ES256 JWT creation with API
  key ID, Team issuer ID or Individual subject, `.p8` private-key loading,
  `appstoreconnect-v1` audience, bounded lifetime, optional scope, and clock
  injection.
- `AppStoreConnectCachedJWTCredential`: actor-backed JWT credential cache that
  refreshes inside a configurable skew window.
- `AppStoreConnectAuthenticatedTransport`: transport decorator that injects
  `Authorization` headers without making Core know the caller target.
- `AppStoreConnectRetryPolicy` and `AppStoreConnectRetryingTransport`:
  deterministic retry policy and transport decoration for retryable status
  codes, `Retry-After`, rate-limit responses, explicitly enabled transport
  errors, and method safety gating. Defaults stay conservative: idempotent
  methods only unless a caller opts into mutation/upload retry.
- `AppStoreConnectTransportFixture`: deterministic request capture and response
  replay support for tests.
- `AppStoreConnectRateLimit`: parser for the documented `X-Rate-Limit` response
  header and 429 detection.
- `AppStoreConnectPaginator`: pagination helper for list endpoints.
- `AppStoreConnectUpload`: upload operation primitives, chunk extraction, and
  request materialization shared by public API clients and workflows.
- `AppStoreConnectRetryingDownloadTransport`: retry decoration for download
  transports that removes failed temporary files before retrying.
- `AppStoreConnectError`: deterministic error taxonomy for configuration,
  authentication, request, decoding, upload, and unsupported-capability
  failures.

Core does not know whether a request came from PublicAPI, Iris, Workflow, or
CLI. It also does not know how Apple Account web sessions are acquired.

## Public API Contract

`AppStoreConnectPublicAPI` has four code paths:

- locked official schema audit plus trait-aligned generation manifests;
- Apple typed OpenAPI generated clients for default, domain, and full trait
  slices;
- generated capability facades over enabled Apple typed clients;
- handwritten Swift clients and convenience wrappers.

Apple generated code owns `Components`, `Operations`, `APIProtocol`, and async
`Client` methods for allowlisted operations. The default slice is selected for
CLI/Workflow/facade needs. Optional domain and full API slices compile only
through SwiftPM traits. `Package.swift` maps those traits to generated
compilation conditions, and the PublicAPI build plugin reads those conditions to
select and merge API-slice manifests before invoking Apple's OpenAPI filter and
generator once for the active trait set. The same PublicAPI trait compilation
conditions are propagated to `AppStoreConnectWorkflow`, `AppStoreConnectCLI`,
and their tests so command/workflow slices compile only when the Apple generated
operations they depend on are present. Slice manifests describe official
operation/tag/path/schema selectors and generation depth; they are not
hand-trimmed OpenAPI documents. `PublicAPIFull` is the aggregate full typed
route; generated source size is tracked but is not a blocker for the first
trait-aligned Apple route. Apple `typeOverrides` remain available as an
explicit JSON value replacement policy for named component schemas, not as a
silent change to existing facade method return types. Handwritten code owns
ergonomic clients, credential injection, OpenAPI retry middleware, transport
calls, pagination loops, upload orchestration, and compatibility wrappers.

Generated capability facades own the first stable user-facing PublicAPI entry
point. `AppStoreConnectPublicClient` wraps any generated `APIProtocol`
implementation and exposes capability-shaped subclients, such as `apps`,
`builds`, `testFlight`, `mediaAssets`, `reports`, `users`, and
`certificatesProfiles`. Facade methods are generated from
`openapi-capabilities.json` and the selected OpenAPI input, normalize common
operation suffixes into `list/get/create/update/delete` resource methods, map
selected relationship-read operations into explicit names such as
`listAppStoreVersionsForApp`, pass through generated `Operations.*.Input`
parts, return generated `Operations.*.Output` values, and preserve generated
deprecation state. They do not define duplicate schema models.

`AppStoreConnectOpenAPIRetryMiddleware` adapts Core retry policy to Apple's
generated `Client` pipeline. It retries only replayable OpenAPI request bodies
and only for methods/status codes allowed by the policy.
`AppStoreConnectOpenAPIErrorMiddleware` maps final non-2xx generated-client
responses into `AppStoreConnectPublicAPIError` with decoded JSON:API error
objects when the response body matches Apple's error shape. `RawPublicAPIClient`
is a bounded escape hatch for schema-covered operations, diagnostics, and upload
operations that are not yet promoted into ergonomic facades. Raw requests still
use Core transport, retry, download, upload, credential, and error primitives;
they are not a second schema model surface.

Typed pagination follows the generated response type, not a parallel model.
`AppStoreConnectOpenAPIPagination` extracts generated `PagedDocumentLinks`, and
`RawPublicAPIClient.nextPage` follows `links.next` absolute URLs before decoding
back into the same Apple generated page response type. This keeps pagination
usable for operations whose OpenAPI operation input does not expose cursor
parameters directly.

The stable public client surface should prefer typed clients by capability
area, such as apps, builds, TestFlight, metadata, screenshots, subscriptions,
reports, and Xcode Cloud. New typed operations should first enter the selected
OpenAPI input, then receive handwritten ergonomic wrappers only when the
generated shape is build/test stable.

Domain traits may temporarily route through `AppStoreConnectPublicClient.openAPI`
directly when the generated capability facade has not yet grown a domain-shaped
wrapper. That route is still Apple generated and typed; it must stay behind the
matching trait condition and receive Workflow/CLI tests before the command is
marked executable.

Report commands use the default `PublicAPIBase` reports slice. Analytics
report/request/segment/instance commands call Apple generated OpenAPI
operations through Workflow, while sales and finance report downloads collect
the generated binary HTTP body and write it to a caller-selected output path.
The report download path does not introduce a separate schema model surface or
decompress Apple's gzip body.

Performance metric commands are trait-gated behind `PublicAPIReports`.
Workflow calls Apple's generated `apps_perfPowerMetrics_getToManyRelated` and
`builds_perfPowerMetrics_getToManyRelated` operations directly through
`AppStoreConnectPublicClient.openAPI`, because the official schema tags these
paths under Apps/Builds rather than a Reports tag. The command contract exposes
app-or-build selection, metric type, platform, device type, JSON summary
rendering, and optional raw metrics JSON download without creating a separate
package-owned metrics schema.

App category commands are trait-gated behind `PublicAPIRelease`. Workflow calls
Apple's generated `appCategories_getCollection`,
`appCategories_getInstance`, `appCategories_parent_getToOneRelated`,
`appCategories_subcategories_getToManyRelated`, and
`appInfos_updateInstance` operations directly through
`AppStoreConnectPublicClient.openAPI` until the release/app-info facade is
promoted. The command contract exposes platform filtering, parent filtering,
relationship includes, limits, category relationship assignment, summary
rendering, dry-run plans, and explicit confirm for live mutation without
creating duplicate category schema models.

Age-rating commands are trait-gated behind `PublicAPIRelease`. Workflow calls
Apple's generated `appInfos_ageRatingDeclaration_getToOneRelated` and
`ageRatingDeclarations_updateInstance` operations directly through
`AppStoreConnectPublicClient.openAPI`. The command contract exposes app-info
selection, age-rating declaration identity, frequency and boolean ratings,
kids age band, rating overrides, developer-info URL, `--all-none` defaults,
summary rendering, dry-run plans, and explicit confirm for live mutation.

App event core commands are also trait-gated behind `PublicAPIRelease`.
Workflow calls Apple's generated `apps_appEvents_getToManyRelated`,
`appEvents_getInstance`, `appEvents_createInstance`,
`appEvents_updateInstance`, and `appEvents_deleteInstance` operations directly
through `AppStoreConnectPublicClient.openAPI`. The command contract exposes app
selection, event identity/state filters, field and localization include
selectors, reference name, badge, deep link, primary locale, priority, purchase
requirement, purpose, dry-run plans, explicit confirm for live mutation, and
summary rendering. App event localizations and deeper schedule helpers remain
metadata/media follow-up slices.

Metadata commands are Workflow-owned file-contract commands, not endpoint
clients. `metadata validate` checks local JSON files without Apple credentials.
`metadata pull`, `metadata push`, and `metadata keywords` currently emit
serializable dry-run plans; live pull/push/apply remains blocked until the
package metadata directory contract chooses canonical app-info versus App Store
version localization mappings. The narrow keyword planner records the official
`appStoreVersionLocalizations_updateInstance` operation as its intended public
API backing without claiming a live mutation path.

Screenshot and video-preview read commands are PublicAPI-backed media commands.
Workflow calls Apple's generated `appScreenshotSets_getInstance`,
`appScreenshots_getInstance`, `appPreviewSets_getInstance`, and
`appPreviews_getInstance` operations through the generated media facade and
returns package-owned summary DTOs. Upload, download, replace/reorder, and
poster-frame updates remain blocked until resumable asset upload/finalization
and file fixture contracts are added above Core upload primitives.

App Clips read commands are trait-gated behind `PublicAPIMetadataMedia`.
Workflow calls Apple's generated `apps_appClips_getToManyRelated`,
`appClips_getInstance`,
`appClips_appClipDefaultExperiences_getToManyRelated`,
`appClipDefaultExperiences_getInstance`,
`appClipDefaultExperiences_appClipDefaultExperienceLocalizations_getToManyRelated`,
and `appClipDefaultExperienceLocalizations_getInstance` operations directly
through `AppStoreConnectPublicClient.openAPI`. The command contract exposes app
and App Clip selectors, default-experience selectors, locale filters, common
relationship includes, limits, JSON summary rendering, and CLI compatibility
aliases for `experiences` over Apple's default-experience resource naming.
Mutation and media-card asset helpers remain metadata/media follow-up slices.

Game Center read commands are trait-gated behind `PublicAPIGameCenter`.
Workflow calls Apple's generated `apps_gameCenterDetail_getToOneRelated`,
`gameCenterDetails_getInstance`,
`gameCenterDetails_gameCenterAchievementsV2_getToManyRelated`,
`gameCenterAchievementsV2_getInstance`,
`gameCenterDetails_gameCenterLeaderboardsV2_getToManyRelated`,
`gameCenterLeaderboardsV2_getInstance`,
`gameCenterDetails_gameCenterLeaderboardSetsV2_getToManyRelated`,
`gameCenterLeaderboardSetsV2_getInstance`,
`gameCenterDetails_gameCenterChallenges_getToManyRelated`, and
`gameCenterChallenges_getInstance` operations directly through
`AppStoreConnectPublicClient.openAPI`. The command contract exposes app/detail
selectors, achievement/leaderboard/leaderboard-set/challenge selectors,
reference-name filters, limits, common relationship includes, and JSON summary
rendering. Game Center localization, release, and mutation helpers remain
explicit follow-up scope rather than hidden broad-family completion.

Actor read commands are trait-gated behind `PublicAPISigningAccess`. Workflow
calls Apple's generated `actors_getCollection` and `actors_getInstance`
operations directly through `AppStoreConnectPublicClient.openAPI` until an
access facade is promoted. The command contract exposes actor identity filters,
field selection, pagination limit, and summary rendering. WebSession login and
Apple Account command behavior remain separate from public actor reads.

Distribution commands are trait-gated behind `PublicAPIDistribution`.
Workflow calls Apple's generated alternative distribution domain/key,
marketplace webhook, webhook, webhook delivery linkage/redelivery/ping,
territory, and EULA operations directly through
`AppStoreConnectPublicClient.openAPI`. The webhook list operation is selected
explicitly because Apple tags it under `Apps` even though it is required for
the distribution/webhooks CLI family. The command contract exposes alternative
distribution domain/key field filters, marketplace webhook field filters,
webhook field/relationship/date filters, webhook create/update/delete payloads,
delivery linkage and redelivery controls, ping creation, territory field/limit
selection, plus EULA identity, field selection, app/territory relationship
includes, territory include limit, create/update app and territory
relationships, agreement text payloads, delete identity, and summary rendering.
Webhook and EULA writes use serializable dry-run plans and require explicit
confirm for live mutation; dry-run plans record webhook secret length and EULA
agreement text length instead of secret values or full agreement text. Generic
`agreements` commands are not mapped to EULA because Apple's official
schema has no generic agreements list/view operation.

The first Apple-only route does not attach a package-owned full-schema catalog
or descriptor emitter to `AppStoreConnectPublicAPI`. Bounded raw request support
remains allowed only for diagnostics, fixtures, and schema-covered endpoints
that do not yet have ergonomic wrappers. Raw request support must still use
`AppStoreConnectCore` transport, credentials, retry, upload, and error mapping.

## WebSession Contract

The default-off `Experimental` trait enables all declarations in this module.

`AppStoreConnectWebSession` supplies web credentials for private web-backed
surfaces. Its public boundary is provider-oriented.

WebSession owns:

- `WebSession`: cookies, expiry, account identity when available, source, and
  diagnostics.
- `WebSessionCookie`: cookie name, value, domain, path, expiry, secure flag,
  and HTTP-only flag.
- `WebSessionAccount`: optional account and team identity.
- `WebSessionSource` and `WebSessionDiagnostic`: machine-readable provenance
  and provider diagnostics.
- `WebSessionProvider`: async provider that returns a usable session or a
  deterministic failure.
- `StaticWebSessionProvider`: fixture and fake-provider support for downstream
  Iris tests.
- `EnvironmentWebSessionProvider`: deterministic cookie-header input from
  process environment or injected environment dictionaries.
- `SessionFileWebSessionProvider` and `WebSessionFileStore`: JSON session-file
  loading/saving.
- `BrowserCookieFileWebSessionProvider`: deterministic Netscape-format browser
  cookie import.
- `CachedWebSessionProvider` and `WebSessionCachePolicy`: disabled, read-only,
  and write-through cache behavior.

SRP login orchestration, 2FA challenge handling, and trusted-device flow state
are future live-login layers. They must build on `WebSessionProvider` and must
not become prerequisites for default tests.

WebSession must not import `AppStoreConnectIrisAPI`. A provider may be used by
Iris, but it does not know which Iris endpoint will be called.

## Iris API Contract

The default-off `Experimental` trait enables all declarations in this module.

`AppStoreConnectIrisAPI` calls private `/iris/v1` endpoints only after receiving
a usable `WebSession` from a provider.

Iris owns:

- Iris request descriptors and response models.
- `IrisEndpointDescriptor`, `IrisEndpointID`, `IrisEndpointLedger`, and
  `IrisDriftPolicy` for per-endpoint method, path, host, required headers,
  payload expectations, observation identifier, mutation flag, and fail-closed
  policy.
- a client facade that combines `WebSessionProvider` and
  `AppStoreConnectTransport`;
- cookie/header adaptation from `WebSession` into private API requests;
- generic Iris JSON/JSON:API models for private response fixtures that are not
  public API schema models;
- Iris-specific error mapping and private capability flags.

Iris models stay separate from public API generated models unless a shared type
is stable enough to move into Core. Moving a shared type into Core requires the
same task to update `Layering.md`.

The first Iris baseline endpoint is read-only app-store-version state-change
inspection. It proves the session-provider seam, request headers, fixture
response decoding, unauthorized failure mapping, and response-shape drift
failure path. Mutating Iris endpoints remain deferred until their payload
ledgers and fixtures are explicit.

## Workflow Contract

`AppStoreConnectWorkflow` composes clients and state transitions. It does not
define endpoint payload models.

Workflow owns:

- built-in workflow identifiers and typed input structs;
- `WorkflowStepSource` classification for public API-backed,
  upload-tool-backed, Iris-backed, and local-only steps;
- `WorkflowStep` identity, display label, dependencies, source, mutation flag,
  and output keys;
- `WorkflowPlan` for dry-run output;
- `WorkflowStepStatus`, `WorkflowStepResult`, and `WorkflowRunResult` for
  started/completed/failed/skipped/resumable step output;
- `WorkflowOutputValue` for machine-readable command and API output;
- `WorkflowFile`, `WorkflowInputPayload`, `WorkflowHook`, `WorkflowResumeState`,
  `WorkflowFileRunner`, and `WorkflowExecutionContext` for `.asc/workflow.json`
  load, validate, dry-run, run, interpolation, hook recording, sub-workflows,
  and resume-plan decisions;
- `WorkflowRuntime` for constructing executable workflow contexts from
  environment-provided credentials without making CLI import endpoint targets;
- `PublicAPIReadCommands` for stable command-shaped read DTOs over generated
  PublicAPI facades, currently apps/builds/version/TestFlight/signing
  provisioning/user/review-submission/status read and polling command families,
  analytics report/request/segment/instance reads, sales/finance report
  downloads, trait-gated actor reads, trait-gated performance metric reads/
  downloads, trait-gated app category, age-rating, app-event, and customer
  review reads, screenshot and app-preview set/asset reads, and trait-gated
  commerce reads over Apple generated OpenAPI operations;
- `PublicAPIWriteCommands` for stable command-shaped mutation DTOs over
  generated PublicAPI facades; each write command must expose a serializable
  mutation plan before live execution, and live CLI mutation requires explicit
  confirmation; analytics report-request create/delete, trait-gated app
  category, age-rating, app-event, customer-review-response, and trait-gated
  commerce mutations follow the same dry-run-first contract while calling Apple
  generated OpenAPI operations directly until domain facades are promoted;
- `AppStoreConnectXcodeCommands` for local Xcode/Transporter handoffs.
  Version is read-only; archive/export/upload emit serializable
  `AppStoreConnectXcodeToolPlan` values by default and execute local tools only
  after CLI `--confirm`. These commands are Workflow-owned local handoffs, not
  PublicAPI endpoint clients;
- `WorkflowRunner` for built-in skeleton dry-run planning while individual
  built-in workflows and `WorkflowFileRunner` own execution behavior.

Every mutating workflow path must have a dry-run representation before the
mutation path lands.

The first executable built-in workflow is `PublicReleaseReadinessWorkflow`.
It takes `PublicReleaseReadinessInput`, composes the generated
`AppStoreConnectPublicClient` facade, emits serializable step output, and keeps
the app-binary upload boundary as an upload-tool-backed handoff. It must not
call WebSession, Iris, or CLI code.

## CLI Contract

`AppStoreConnectCLI` is a process boundary. It should stay thin:

- parse command intent;
- construct workflow input values;
- call workflow APIs;
- render machine-readable and human-readable output;
- map deterministic errors to exit codes.

CLI must not construct endpoint requests directly. If a CLI command needs a new
operation, add or expose it through Workflow or a lower library target first.

ArgumentParser owns the executable entry, root flags and completion generation.
The package-owned dispatcher in `AppStoreConnectCLI` handles command-specific options. It also owns a command
registry that records command status, parameter semantics, and backend
ownership. Registered but non-executable commands return structured unsupported
output instead of being treated as unknown commands.

It exposes these current command families:

- `commands list`;
- `workflows list`;
- `workflow list`;
- `workflow dry-run public-release-readiness`;
- `workflow run public-release-readiness`;
- `workflow validate`;
- `workflow-file dry-run`;
- `workflow-file run`;
- `apps list`;
- `apps view`;
- `apps get`;
- `builds` list/info/get/wait and beta-detail reads;
- `prerelease` list/view/get;
- `versions` list/view/get;
- `testflight` build/group/tester/localization/review/license/feedback/crash
  read commands, group/tester core mutations, review-detail update, and
  review-submission create;
- `testflight metrics` beta-tester/public-link/beta-build usage reads;
- `testflight invitations create`;
- `bundle-ids`, `certificates`, `devices`, and `profiles` list/view/get, with
  `certificates download/export` writing decoded official `certificateContent`
  and `profiles download/export` writing decoded official `profileContent`;
- `users` and `users invitations` list/view/get plus user role, visibility,
  delete, and invitation create/delete mutations;
- with `PublicAPISigningAccess` enabled, `actors` list/view and `actors get`
  compatibility commands over Apple actor operations;
- with `PublicAPICommerce` enabled, `iap` list/view/get/create/update/delete/submit,
  IAP localizations list/view/get/create/update/delete,
  `subscription-groups` view/get/create/update/delete, subscription-group
  localizations list/view/get/create/update/delete, `subscriptions`
  list/view/get/create/update/delete/submit, subscription localizations
  list/view/get/create/update/delete, `promoted-purchases`
  list/view/get/create/update/delete, `win-back-offers`
  list/view/get/create/update/delete, and `pricing` tiers/current reads over
  Apple IAP, subscription, localization, promoted-purchase, win-back offer,
  app price point, and current schedule relationship operations;
- `analytics` report/request/segment/instance commands;
- `finance` reports/download and `reports sales`/`sales reports` binary
  download commands;
- with `PublicAPIReports` enabled, `performance` list/download and
  `insights performance` compatibility commands over Apple perf power metrics;
- with `PublicAPIRelease` enabled, `categories`
  list/view/get/parent/subcategories/set/edit/update over Apple app category
  and app-info category relationship operations, `age-rating`
  view/get/update/edit/set over Apple age-rating declaration operations, plus
  `app-events` list/view/get/create/update/delete over Apple app-event
  operations, and `reviews` list/view/get/rating summaries/response view plus
  response create/delete/reply commands over Apple customer review operations;
- with `PublicAPIDistribution` enabled, `alternative-distribution`
  domain/key list/view/get commands, `marketplace webhooks list`, `webhooks`
  list/view/get/create/update/delete/remove/deliveries/delivery links/delivery
  redelivery/ping, `territories` list, plus `eula` view/get/create/update/edit/
  delete/remove commands over Apple distribution operations;
- with `PublicAPICloud` enabled, `xcode-cloud` product/workflow/run/action/
  artifact read commands plus log aliases over Apple generated `ci*` Xcode
  Cloud operations; Apple exposes logs as `ciArtifacts` with `LOG_BUNDLE`, so
  the CLI keeps logs as an alias instead of introducing a second data model;
- `auth status`, `auth doctor`, and dry-run-first `auth logout` over
  deterministic `AppStoreConnectWebSession` providers;
- `xcode version`, `xcode archive`, `xcode export`, and `xcode upload` over
  Workflow-owned local tool plans and injected local process execution;
- `publish appstore` and `publish testflight` as executable Workflow dry-run
  planners; live end-to-end publish remains a workflow execution follow-up;
- `metadata validate`, `metadata pull`, `metadata push`, and
  `metadata keywords`, where validation is local and pull/push/keyword
  commands produce Workflow-owned dry-run plans until the metadata directory
  contract is finalized;
- `screenshots` list/view/get and `video-previews` list/view/get over Apple
  generated screenshot and app-preview operations; upload/download and
  poster-frame mutations are blocked with explicit registry reasons;
- `review submissions` list/view/get;
- `submit status`;
- `review status`;
- `status`;
- `validate`.

Run commands, PublicAPI-backed read commands, and confirmed PublicAPI-backed
write commands use `WorkflowRuntime` and require `ASC_API_TOKEN` before live
public API execution. Dry-run commands remain deterministic and do not require
live network or credentials.

Auth commands use `WorkflowRuntime.authCommands` and do not require
`ASC_API_TOKEN`, Iris, or PublicAPI. They inspect deterministic WebSession
sources only: environment cookie headers, JSON session files, and optional
browser cookie exports. Live Apple Account login remains a future
`AppStoreConnectWebSession` provider and is blocked rather than emulated in
Workflow or CLI.

## Testing Contract

Tests should follow the target boundary they protect:

- Core tests cover request normalization, pagination, upload primitives, error
  mapping, retry policy, and transport fixtures.
- PublicAPI generator tests cover schema inventory, file layout, construct
  mapping, duplicate output paths, and representative emitted Swift.
- PublicAPI client tests use transport fixtures and generated endpoint
  descriptors.
- WebSession tests use deterministic provider, cookie, session-file, and cache
  fixtures. Live login, SRP, and 2FA tests must remain opt-in until those
  flows are fixture-backed.
- Iris tests use fake `WebSessionProvider` values, endpoint ledgers, request
  fixtures, response fixtures, failure fixtures, and transport fixtures.
- Workflow tests cover dry-run, dependency ordering, output extraction, failure
  state, and resume decisions.
- CLI tests cover argument parsing, output formatting, workflow-file dry-run,
  and exit mapping only.
- Trait-gated command slices must be tested under the trait that enables their
  Apple generated OpenAPI symbols, in addition to the default `swift test`
  baseline.

Network integration tests must be opt-in and separated from default
`swift test`.
