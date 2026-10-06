# ``AppStoreConnectWorkflow``

@Metadata {
  @PageImage(purpose: icon, source: "appstoreconnectworkflow-icon", alt: "swift-appstoreconnect icon")
  @PageColor(yellow)
}

Command facades and deterministic workflow planning.

Create serializable plans with `WorkflowRunner`, or execute the public API readiness inspection with `PublicReleaseReadinessWorkflow`. Domain command facades expose supported reads and writes. App Store/TestFlight publishing and metadata pull/push remain plan-only. `WorkflowFileRunner` records hooks without executing them.

Readiness resolves the requested app and fetches the first page of builds and
TestFlight groups visible to the credential. Those two collections are
account-wide. Set `includeBuilds` or `includeTestFlightGroups` to `false` to omit
them. Optional version and screenshot-set identifiers select individual
resources directly.

## Topics

### API

- ``BuiltinWorkflow``
- ``WorkflowRunner``
- ``WorkflowRuntime``
- ``PublicAPIReadCommands``
- ``PublicAPIWriteCommands``

### Usage

```swift
import AppStoreConnectWorkflow

let workflow = WorkflowRunner().dryRun(.publishAppStore)
let steps = workflow.steps
```
