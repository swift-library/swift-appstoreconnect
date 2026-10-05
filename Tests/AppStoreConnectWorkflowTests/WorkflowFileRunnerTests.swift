// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import AppStoreConnectCore
import AppStoreConnectWorkflow
import Foundation
import Testing

@Test func workflowFileDryRunLoadsAndValidatesPublicReleaseReadiness() throws {
  let file = WorkflowFile(
    workflow: .publicReleaseReadiness,
    input: WorkflowInputPayload(
      appID: "app-1",
      appStoreVersionID: "version-1",
      screenshotSetID: "set-1",
      includeBuilds: false,
      includeTestFlightGroups: true
    ),
    hooks: [
      WorkflowHook(id: "after", trigger: .afterRun, command: ["echo", "done"])
    ]
  )

  let result = try WorkflowFileRunner().dryRun(file)

  #expect(result.validationIssues.isEmpty)
  #expect(result.plan.workflow == .publicReleaseReadiness)
  #expect(
    result.plan.steps.map(\.id) == [
      "resolve-app",
      "inspect-builds",
      "binary-upload-boundary",
      "inspect-testflight-groups",
      "inspect-screenshot-set",
      "inspect-metadata-version",
    ])
  #expect(
    result.plan.steps[1].commandDescription
      == "Skip build inspection because includeBuilds is false.")
  #expect(
    result.hooks == [
      WorkflowHookRecord(hookID: "after", trigger: .afterRun, status: .planned)
    ])
}

@Test func workflowFileValidationReportsMissingInputAndHookCommand() throws {
  let file = WorkflowFile(
    workflow: .publicReleaseReadiness,
    hooks: [
      WorkflowHook(id: "empty", trigger: .beforeRun, command: [])
    ]
  )

  let result = try WorkflowFileRunner().dryRun(file)

  #expect(
    result.validationIssues == [
      WorkflowValidationIssue(
        path: "$.input.appID",
        message: "publicReleaseReadiness requires appID."
      ),
      WorkflowValidationIssue(
        path: "$.hooks.empty.command",
        message: "Hook command must not be empty."
      ),
    ])
}

@Test func workflowValueInterpolationUsesPriorOutputs() throws {
  let value = WorkflowValueInterpolator.interpolate(
    "version-${outputs.resolve-app.appID}",
    outputs: ["resolve-app.appID": .string("123")]
  )

  #expect(value == "version-123")
}

@Test func workflowFileRunnerRecordsResumePlanDecisions() {
  let plan = WorkflowRunner().dryRun(.publicReleaseReadiness)
  let result = WorkflowFileRunner().resumePlan(
    plan,
    state: WorkflowResumeState(completedStepIDs: ["resolve-app"])
  )

  #expect(result.steps.first?.stepID == "resolve-app")
  #expect(result.steps.first?.status == .skipped)
  #expect(result.steps.first?.diagnostics == ["Already completed in resume state."])
  #expect(result.steps.dropFirst().allSatisfy { $0.status == .planned })
}

@Test func workflowFileRunnerRunsInjectedExecutorAndInterpolatedSubworkflow() async throws {
  let file = WorkflowFile(
    workflow: .publicReleaseReadiness,
    input: WorkflowInputPayload(appID: "app-1"),
    subworkflows: [
      WorkflowFile(
        workflow: .publicReleaseReadiness,
        input: WorkflowInputPayload(appID: "${outputs.resolve-app.appID}")
      )
    ]
  )
  let context = WorkflowExecutionContext { input in
    WorkflowRunResult(
      workflow: .publicReleaseReadiness,
      steps: [
        WorkflowStepResult(
          stepID: "resolve-app",
          status: .succeeded,
          source: .publicAPIBacked,
          mutates: false,
          outputs: ["appID": .string(input.appID)]
        )
      ]
    )
  }

  let result = try await WorkflowFileRunner().run(file, context: context)

  #expect(result.outputs["resolve-app.appID"] == .string("app-1"))
  #expect(result.subworkflows.first?.outputs["resolve-app.appID"] == .string("app-1"))
}
