// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import AppStoreConnectCore
import Foundation

public struct WorkflowExecutionContext: Sendable {
  public var runPublicReleaseReadiness:
    @Sendable (PublicReleaseReadinessInput) async throws -> WorkflowRunResult

  public init(
    runPublicReleaseReadiness:
      @escaping @Sendable (PublicReleaseReadinessInput) async throws -> WorkflowRunResult
  ) {
    self.runPublicReleaseReadiness = runPublicReleaseReadiness
  }
}

public struct WorkflowFileRunner: Sendable {
  public init() {}

  public func load(from url: URL) throws -> WorkflowFile {
    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    return try decoder.decode(WorkflowFile.self, from: data)
  }

  public func validate(_ file: WorkflowFile, path: String = "$") -> [WorkflowValidationIssue] {
    var issues: [WorkflowValidationIssue] = []

    if file.workflow == .publicReleaseReadiness, file.input.appID == nil {
      issues.append(
        WorkflowValidationIssue(
          path: "\(path).input.appID",
          message: "publicReleaseReadiness requires appID."
        ))
    }

    for hook in file.hooks where hook.command.isEmpty {
      issues.append(
        WorkflowValidationIssue(
          path: "\(path).hooks.\(hook.id).command",
          message: "Hook command must not be empty."
        ))
    }

    for (index, subworkflow) in file.subworkflows.enumerated() {
      issues.append(contentsOf: validate(subworkflow, path: "\(path).subworkflows[\(index)]"))
    }

    return issues
  }

  public func dryRun(
    _ file: WorkflowFile,
    resumeState: WorkflowResumeState = WorkflowResumeState()
  ) throws -> WorkflowFileDryRunResult {
    let issues = validate(file)
    guard issues.isEmpty else {
      return WorkflowFileDryRunResult(
        plan: WorkflowPlan(workflow: file.workflow, steps: []),
        validationIssues: issues
      )
    }

    let plan = try plan(for: file, outputs: resumeState.outputs)
    return WorkflowFileDryRunResult(
      plan: plan,
      hooks: hookRecords(file.hooks, status: .planned),
      subworkflows: try file.subworkflows.map {
        try dryRun($0, resumeState: resumeState)
      }
    )
  }

  public func run(
    _ file: WorkflowFile,
    context: WorkflowExecutionContext,
    resumeState: WorkflowResumeState = WorkflowResumeState()
  ) async throws -> WorkflowFileRunResult {
    let issues = validate(file)
    guard issues.isEmpty else {
      throw AppStoreConnectError.invalidConfiguration(
        issues.map { "\($0.path): \($0.message)" }.joined(separator: "\n")
      )
    }

    let result: WorkflowRunResult
    switch file.workflow {
    case .publicReleaseReadiness:
      result = try await context.runPublicReleaseReadiness(
        file.input.publicReleaseReadinessInput(interpolating: resumeState.outputs)
      )
    default:
      result = resumePlan(
        WorkflowRunner().dryRun(file.workflow),
        state: resumeState
      )
    }

    let outputs = aggregateOutputs(result)
    let subworkflowResults = try await runSubworkflows(
      file.subworkflows,
      context: context,
      outputs: outputs
    )
    let hookStatus: WorkflowStepStatus =
      result.steps.contains { $0.status == .failed } ? .needsInput : .skipped
    let hookDiagnostics =
      hookStatus == .needsInput
      ? ["Hook execution is deferred because workflow failed."]
      : ["Hook execution is recorded but not executed by the library runner."]

    return WorkflowFileRunResult(
      result: result,
      hooks: hookRecords(file.hooks, status: hookStatus, diagnostics: hookDiagnostics),
      subworkflows: subworkflowResults,
      outputs: outputs
    )
  }

  public func resumePlan(
    _ plan: WorkflowPlan,
    state: WorkflowResumeState
  ) -> WorkflowRunResult {
    let completed = Set(state.completedStepIDs)
    return WorkflowRunResult(
      workflow: plan.workflow,
      steps: plan.steps.map { step in
        WorkflowStepResult(
          stepID: step.id,
          status: completed.contains(step.id) ? .skipped : .planned,
          source: step.source,
          mutates: step.mutates,
          diagnostics: completed.contains(step.id)
            ? ["Already completed in resume state."]
            : []
        )
      }
    )
  }

  private func plan(
    for file: WorkflowFile,
    outputs: [String: WorkflowOutputValue]
  ) throws -> WorkflowPlan {
    switch file.workflow {
    case .publicReleaseReadiness:
      return PublicReleaseReadinessWorkflow.dryRun(
        try file.input.publicReleaseReadinessInput(interpolating: outputs)
      )
    default:
      return WorkflowRunner().dryRun(file.workflow)
    }
  }

  private func hookRecords(
    _ hooks: [WorkflowHook],
    status: WorkflowStepStatus,
    diagnostics: [String] = []
  ) -> [WorkflowHookRecord] {
    hooks.map {
      WorkflowHookRecord(
        hookID: $0.id,
        trigger: $0.trigger,
        status: status,
        diagnostics: diagnostics
      )
    }
  }

  private func aggregateOutputs(_ result: WorkflowRunResult) -> [String: WorkflowOutputValue] {
    result.steps.reduce(into: [String: WorkflowOutputValue]()) { outputs, step in
      for (key, value) in step.outputs {
        outputs["\(step.stepID).\(key)"] = value
      }
    }
  }

  private func runSubworkflows(
    _ subworkflows: [WorkflowFile],
    context: WorkflowExecutionContext,
    outputs: [String: WorkflowOutputValue]
  ) async throws -> [WorkflowFileRunResult] {
    var results: [WorkflowFileRunResult] = []
    let resumeState = WorkflowResumeState(outputs: outputs)

    for subworkflow in subworkflows {
      results.append(try await run(subworkflow, context: context, resumeState: resumeState))
    }

    return results
  }
}
