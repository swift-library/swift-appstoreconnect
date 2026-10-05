// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import AppStoreConnectCore
import AppStoreConnectPublicAPI

public enum BuiltinWorkflow: String, Codable, Sendable, CaseIterable {
  case publicReleaseReadiness
  case publishAppStore
  case publishTestFlight
  case screenshotsPlan
  case screenshotsApply
  case metadataApply
  case subscriptionsSync
  case reportsExport
}

public enum WorkflowStepSource: String, Codable, Sendable, Equatable {
  case publicAPIBacked
  case uploadToolBacked
  case irisBacked
  case localOnly
}

public enum WorkflowStepStatus: String, Codable, Sendable, Equatable {
  case planned
  case running
  case skipped
  case succeeded
  case failed
  case needsInput
}

public enum WorkflowOutputValue: Codable, Sendable, Equatable {
  case string(String)
  case integer(Int)
  case bool(Bool)
  case strings([String])

  private enum CodingKeys: String, CodingKey {
    case type
    case value
  }

  private enum ValueType: String, Codable {
    case string
    case integer
    case bool
    case strings
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(ValueType.self, forKey: .type)

    switch type {
    case .string:
      self = .string(try container.decode(String.self, forKey: .value))
    case .integer:
      self = .integer(try container.decode(Int.self, forKey: .value))
    case .bool:
      self = .bool(try container.decode(Bool.self, forKey: .value))
    case .strings:
      self = .strings(try container.decode([String].self, forKey: .value))
    }
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .string(let value):
      try container.encode(ValueType.string, forKey: .type)
      try container.encode(value, forKey: .value)
    case .integer(let value):
      try container.encode(ValueType.integer, forKey: .type)
      try container.encode(value, forKey: .value)
    case .bool(let value):
      try container.encode(ValueType.bool, forKey: .type)
      try container.encode(value, forKey: .value)
    case .strings(let value):
      try container.encode(ValueType.strings, forKey: .type)
      try container.encode(value, forKey: .value)
    }
  }
}

public struct WorkflowStep: Codable, Sendable, Equatable {
  public var id: String
  public var name: String
  public var label: String
  public var commandDescription: String
  public var dependencies: [String]
  public var source: WorkflowStepSource
  public var mutates: Bool
  public var outputKeys: [String]

  public init(
    id: String? = nil,
    name: String,
    label: String? = nil,
    commandDescription: String,
    dependencies: [String] = [],
    source: WorkflowStepSource = .localOnly,
    mutates: Bool = false,
    outputKeys: [String] = []
  ) {
    self.id = id ?? name
    self.name = name
    self.label = label ?? name
    self.commandDescription = commandDescription
    self.dependencies = dependencies
    self.source = source
    self.mutates = mutates
    self.outputKeys = outputKeys
  }
}

public struct WorkflowPlan: Codable, Sendable, Equatable {
  public var workflow: BuiltinWorkflow
  public var steps: [WorkflowStep]

  public init(workflow: BuiltinWorkflow, steps: [WorkflowStep]) {
    self.workflow = workflow
    self.steps = steps
  }
}

public struct WorkflowStepResult: Codable, Sendable, Equatable {
  public var stepID: String
  public var status: WorkflowStepStatus
  public var source: WorkflowStepSource
  public var mutates: Bool
  public var outputs: [String: WorkflowOutputValue]
  public var diagnostics: [String]
  public var resumable: Bool

  public init(
    stepID: String,
    status: WorkflowStepStatus,
    source: WorkflowStepSource,
    mutates: Bool,
    outputs: [String: WorkflowOutputValue] = [:],
    diagnostics: [String] = [],
    resumable: Bool = false
  ) {
    self.stepID = stepID
    self.status = status
    self.source = source
    self.mutates = mutates
    self.outputs = outputs
    self.diagnostics = diagnostics
    self.resumable = resumable
  }
}

public struct WorkflowRunResult: Codable, Sendable, Equatable {
  public var workflow: BuiltinWorkflow
  public var steps: [WorkflowStepResult]

  public init(workflow: BuiltinWorkflow, steps: [WorkflowStepResult]) {
    self.workflow = workflow
    self.steps = steps
  }
}

public struct WorkflowRunner: Sendable {
  public init() {}

  public func dryRun(_ workflow: BuiltinWorkflow) -> WorkflowPlan {
    WorkflowPlan(
      workflow: workflow,
      steps: Self.defaultSteps(for: workflow)
    )
  }

  private static func defaultSteps(for workflow: BuiltinWorkflow) -> [WorkflowStep] {
    switch workflow {
    case .publicReleaseReadiness:
      return PublicReleaseReadinessWorkflow.planSteps()
    case .publishAppStore:
      return [
        WorkflowStep(
          name: "resolve-app",
          commandDescription: "Resolve app, version, and platform context.",
          source: .publicAPIBacked,
          outputKeys: ["appID"]
        ),
        WorkflowStep(
          name: "upload-build",
          commandDescription: "Upload or locate the candidate build.",
          source: .uploadToolBacked,
          mutates: true
        ),
        WorkflowStep(
          name: "submit-review",
          commandDescription: "Attach build, validate readiness, and submit for review.",
          source: .publicAPIBacked,
          mutates: true
        ),
      ]
    case .publishTestFlight:
      return [
        WorkflowStep(
          name: "upload-build",
          commandDescription: "Upload or locate the candidate build.",
          source: .uploadToolBacked,
          mutates: true
        ),
        WorkflowStep(
          name: "wait-processing",
          commandDescription: "Wait until App Store Connect finishes build processing.",
          source: .publicAPIBacked
        ),
        WorkflowStep(
          name: "distribute",
          commandDescription: "Assign the build to TestFlight groups.",
          source: .publicAPIBacked,
          mutates: true
        ),
      ]
    case .screenshotsPlan:
      return [
        WorkflowStep(
          name: "inspect-locales",
          commandDescription: "Resolve version localizations and device families.",
          source: .publicAPIBacked
        ),
        WorkflowStep(
          name: "plan-assets",
          commandDescription: "Compare local screenshot files with App Store Connect state.",
          source: .localOnly
        ),
      ]
    case .screenshotsApply:
      return [
        WorkflowStep(
          name: "reserve-assets",
          commandDescription: "Create screenshot set reservations.",
          source: .publicAPIBacked,
          mutates: true
        ),
        WorkflowStep(
          name: "upload-assets",
          commandDescription: "Upload screenshot chunks and commit reservations.",
          source: .publicAPIBacked,
          mutates: true
        ),
      ]
    case .metadataApply:
      return [
        WorkflowStep(
          name: "diff-metadata",
          commandDescription: "Compare local metadata with App Store Connect state.",
          source: .publicAPIBacked
        ),
        WorkflowStep(
          name: "apply-metadata",
          commandDescription: "Create or update version and app-info localizations.",
          source: .publicAPIBacked,
          mutates: true
        ),
      ]
    case .subscriptionsSync:
      return [
        WorkflowStep(
          name: "resolve-products",
          commandDescription: "Resolve IAP and subscription groups.",
          source: .publicAPIBacked
        ),
        WorkflowStep(
          name: "sync-products",
          commandDescription: "Apply pricing, localization, review asset, and submission changes.",
          source: .publicAPIBacked,
          mutates: true
        ),
      ]
    case .reportsExport:
      return [
        WorkflowStep(
          name: "request-report",
          commandDescription: "Create or reuse an analytics or finance report request.",
          source: .publicAPIBacked,
          outputKeys: ["reportRequestID"]
        ),
        WorkflowStep(
          name: "download-report",
          commandDescription: "Poll report instances and download generated files.",
          source: .publicAPIBacked,
          outputKeys: ["reportSegmentID"]
        ),
      ]
    }
  }
}
