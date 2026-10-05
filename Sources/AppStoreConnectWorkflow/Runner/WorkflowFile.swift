// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import AppStoreConnectCore
import Foundation

public struct WorkflowFile: Codable, Sendable, Equatable {
  public var workflow: BuiltinWorkflow
  public var input: WorkflowInputPayload
  public var hooks: [WorkflowHook]
  public var subworkflows: [WorkflowFile]

  private enum CodingKeys: String, CodingKey {
    case workflow
    case input
    case hooks
    case subworkflows
  }

  public init(
    workflow: BuiltinWorkflow,
    input: WorkflowInputPayload = WorkflowInputPayload(),
    hooks: [WorkflowHook] = [],
    subworkflows: [WorkflowFile] = []
  ) {
    self.workflow = workflow
    self.input = input
    self.hooks = hooks
    self.subworkflows = subworkflows
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    workflow = try container.decode(BuiltinWorkflow.self, forKey: .workflow)
    input =
      try container.decodeIfPresent(WorkflowInputPayload.self, forKey: .input)
      ?? WorkflowInputPayload()
    hooks = try container.decodeIfPresent([WorkflowHook].self, forKey: .hooks) ?? []
    subworkflows = try container.decodeIfPresent([WorkflowFile].self, forKey: .subworkflows) ?? []
  }
}

public struct WorkflowInputPayload: Codable, Sendable, Equatable {
  public var appID: String?
  public var appStoreVersionID: String?
  public var screenshotSetID: String?
  public var includeBuilds: Bool?
  public var includeTestFlightGroups: Bool?

  public init(
    appID: String? = nil,
    appStoreVersionID: String? = nil,
    screenshotSetID: String? = nil,
    includeBuilds: Bool? = nil,
    includeTestFlightGroups: Bool? = nil
  ) {
    self.appID = appID
    self.appStoreVersionID = appStoreVersionID
    self.screenshotSetID = screenshotSetID
    self.includeBuilds = includeBuilds
    self.includeTestFlightGroups = includeTestFlightGroups
  }

  public func publicReleaseReadinessInput(
    interpolating outputs: [String: WorkflowOutputValue] = [:]
  ) throws -> PublicReleaseReadinessInput {
    guard let appID else {
      throw AppStoreConnectError.invalidConfiguration(
        "publicReleaseReadiness workflow input requires input.appID."
      )
    }

    return PublicReleaseReadinessInput(
      appID: WorkflowValueInterpolator.interpolate(appID, outputs: outputs),
      appStoreVersionID: appStoreVersionID.map {
        WorkflowValueInterpolator.interpolate($0, outputs: outputs)
      },
      screenshotSetID: screenshotSetID.map {
        WorkflowValueInterpolator.interpolate($0, outputs: outputs)
      },
      includeBuilds: includeBuilds ?? true,
      includeTestFlightGroups: includeTestFlightGroups ?? true
    )
  }
}

public enum WorkflowHookTrigger: String, Codable, Sendable, CaseIterable, Equatable {
  case beforeRun
  case afterRun
  case onFailure
}

public struct WorkflowHook: Codable, Sendable, Equatable {
  public var id: String
  public var trigger: WorkflowHookTrigger
  public var command: [String]

  public init(id: String, trigger: WorkflowHookTrigger, command: [String]) {
    self.id = id
    self.trigger = trigger
    self.command = command
  }
}

public struct WorkflowHookRecord: Codable, Sendable, Equatable {
  public var hookID: String
  public var trigger: WorkflowHookTrigger
  public var status: WorkflowStepStatus
  public var diagnostics: [String]

  public init(
    hookID: String,
    trigger: WorkflowHookTrigger,
    status: WorkflowStepStatus,
    diagnostics: [String] = []
  ) {
    self.hookID = hookID
    self.trigger = trigger
    self.status = status
    self.diagnostics = diagnostics
  }
}

public struct WorkflowValidationIssue: Codable, Sendable, Equatable {
  public var path: String
  public var message: String

  public init(path: String, message: String) {
    self.path = path
    self.message = message
  }
}

public struct WorkflowResumeState: Codable, Sendable, Equatable {
  public var completedStepIDs: [String]
  public var outputs: [String: WorkflowOutputValue]

  public init(
    completedStepIDs: [String] = [],
    outputs: [String: WorkflowOutputValue] = [:]
  ) {
    self.completedStepIDs = completedStepIDs
    self.outputs = outputs
  }
}

public struct WorkflowFileDryRunResult: Codable, Sendable, Equatable {
  public var plan: WorkflowPlan
  public var hooks: [WorkflowHookRecord]
  public var subworkflows: [WorkflowFileDryRunResult]
  public var validationIssues: [WorkflowValidationIssue]

  public init(
    plan: WorkflowPlan,
    hooks: [WorkflowHookRecord] = [],
    subworkflows: [WorkflowFileDryRunResult] = [],
    validationIssues: [WorkflowValidationIssue] = []
  ) {
    self.plan = plan
    self.hooks = hooks
    self.subworkflows = subworkflows
    self.validationIssues = validationIssues
  }
}

public struct WorkflowFileRunResult: Codable, Sendable, Equatable {
  public var result: WorkflowRunResult
  public var hooks: [WorkflowHookRecord]
  public var subworkflows: [WorkflowFileRunResult]
  public var outputs: [String: WorkflowOutputValue]

  public init(
    result: WorkflowRunResult,
    hooks: [WorkflowHookRecord] = [],
    subworkflows: [WorkflowFileRunResult] = [],
    outputs: [String: WorkflowOutputValue] = [:]
  ) {
    self.result = result
    self.hooks = hooks
    self.subworkflows = subworkflows
    self.outputs = outputs
  }
}

public enum WorkflowValueInterpolator {
  public static func interpolate(
    _ value: String,
    outputs: [String: WorkflowOutputValue]
  ) -> String {
    outputs.reduce(value) { partial, element in
      partial.replacingOccurrences(
        of: "${outputs.\(element.key)}",
        with: element.value.interpolationValue
      )
    }
  }
}

extension WorkflowOutputValue {
  public var interpolationValue: String {
    switch self {
    case .string(let value):
      return value
    case .integer(let value):
      return String(value)
    case .bool(let value):
      return String(value)
    case .strings(let value):
      return value.joined(separator: ",")
    }
  }
}
