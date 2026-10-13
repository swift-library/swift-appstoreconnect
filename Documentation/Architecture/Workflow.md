# Workflow

## Scope / Purpose

`AppStoreConnectWorkflow` owns high-level App Store Connect automation in Swift.

## Context / Boundaries

The package distinguishes built-in workflows from the workflow-file runner.

Built-in workflows are typed Swift APIs for known tasks such as publishing, TestFlight distribution, screenshots, metadata, subscriptions, and reports.

The workflow-file runner loads a workflow definition, validates step wiring, supports dry-run, executes supported built-ins through an injected execution context, extracts outputs, interpolates later steps, records hooks, and produces resume-plan decisions.

## Current Structure

The current code exposes a typed workflow planning and result surface:

- `BuiltinWorkflow`: package-owned built-in workflow identifiers.
- `WorkflowStepSource`: the declared source backing each step.
- `WorkflowStepStatus`: planned, running, skipped, succeeded, failed, and
  needs-input state.
- `WorkflowOutputValue`: serializable machine-readable output values.
- `WorkflowStep`: stable step ID, label, dependencies, source, mutation flag,
  and output keys.
- `WorkflowPlan`: serializable dry-run plan.
- `WorkflowStepResult` and `WorkflowRunResult`: serializable execution output.
- `WorkflowRunner.dryRun(_:)`: built-in dry-run planning.
- `WorkflowFileRunner`: `.asc/workflow.json` load, validate, dry-run, run,
  interpolation, hook recording, sub-workflow execution, and resume-plan
  decisions.

`PublicReleaseReadinessWorkflow` is the first executable built-in workflow
slice. It composes the generated `AppStoreConnectPublicClient` facade and fake
OpenAPI transports in tests, so it is callable from Swift without CLI wiring or
live Apple credentials.

## Step Source Classification

Every workflow step must declare its backing source before implementation:

- public API-backed: Apple generated public API clients and package facades;
- upload-tool-backed: a documented external upload handoff, not a public API
  endpoint;
- Iris-backed: private web behavior guarded by endpoint ledgers, fixtures, and
  private capability flags;
- local-only: package-local validation, formatting, file IO, or output
  transformation.

Mutating workflow steps cannot land until their source classification, input
contract, output contract, and dry-run representation are documented in code or
tests.

## Execution Model

Workflow execution has three layers:

- plan: resolve inputs, dependencies, and expected mutations without side
  effects;
- run: execute steps, collect outputs, and return resumable state;
- resume: restart from persisted state without repeating completed mutating
  steps.

`WorkflowStep` should carry a stable identifier, dependency identifiers,
human-readable label, mutation flag, and output contract. `WorkflowPlan` should
be serializable so CLI and tests can snapshot dry-run behavior.

The first executable slice implements only the built-in
`publicReleaseReadiness` path:

- resolve an app by ID through `client.apps.getApp(id:)`;
- inspect builds through `client.builds.listBuilds()`;
- record the app-binary upload boundary as an upload-tool-backed skipped step;
- inspect TestFlight beta groups through `client.testFlight.listBetaGroups()`;
- optionally inspect a screenshot set through
  `client.mediaAssets.getAppScreenshotSet(id:)`;
- optionally inspect an App Store version through
  `client.apps.getAppStoreVersion(id:)`.

This workflow is read-oriented. It does not upload binaries, mutate App Store
Connect state, or call Iris. Binary upload remains a documented Xcode or
Transporter handoff until a workflow explicitly adopts a public Build Uploads
resource or external-tool boundary.

The workflow-file runner accepts a JSON file shaped like:

```json
{
  "workflow": "publicReleaseReadiness",
  "input": {
    "appID": "1234567890",
    "appStoreVersionID": "version-id",
    "includeBuilds": true
  },
  "hooks": [],
  "subworkflows": []
}
```

Hooks are recorded as structured plan/run output; the library runner does not
execute shell commands. Sub-workflow input strings can interpolate prior output
values using `${outputs.stepID.outputKey}`.

## Output Model

Workflow output is machine-readable first. Each step should emit:

- step identifier;
- status: planned, running, skipped, succeeded, failed, or needs-input;
- structured output values used by later interpolation;
- diagnostics suitable for CLI rendering;
- resumability metadata when the step fails after partial progress.

Human-readable CLI output must be derived from this structured output instead
of becoming a separate source of workflow truth.

## Key Principles

- Keep workflow output machine-readable.
- Preserve dry-run before mutating execution.
- Make failures resumable when step state is persisted.
- Keep shell or CLI execution optional; Swift API workflows should be directly callable.

## Risks / Known Gaps

- Most built-in workflows still expose plan skeletons only.
- `publicReleaseReadiness` currently uses selected list/get operations and does
  not yet implement filtered pagination, release submission, or resume storage.
- Resume state is a plan-decision format only; persistent mutation-safe resume
  execution is not implemented yet.
