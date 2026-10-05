# ``AppStoreConnectWorkflow``

Command facades and deterministic workflow planning.

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
