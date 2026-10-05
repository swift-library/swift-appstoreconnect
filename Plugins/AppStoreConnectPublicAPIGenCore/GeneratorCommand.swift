// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import Foundation

public enum GeneratorCommandError: Error, CustomStringConvertible, Equatable {
  case missingCommand
  case unknownCommand(String)
  case missingValue(String)
  case missingRequiredOption(String)
  case validationFailed(String)

  public var description: String {
    switch self {
    case .missingCommand:
      "missing command: expected plan, validate, generate, capability-report, trim-openapi, filter-openapi, verify-openapi-selection, or generate-openapi-facade"
    case .unknownCommand(let command):
      "unknown command: \(command)"
    case .missingValue(let option):
      "missing value for option \(option)"
    case .missingRequiredOption(let option):
      "missing required option \(option)"
    case .validationFailed(let message):
      "validation failed: \(message)"
    }
  }
}

public struct GeneratorCommand: Sendable {
  public init() {}

  public func run(arguments: [String]) throws -> String? {
    guard let command = arguments.first else {
      throw GeneratorCommandError.missingCommand
    }

    let options = try parseOptions(Array(arguments.dropFirst()))

    switch command {
    case "generate-version":
      let source = try requiredURL("--version-file", in: options)
      let destination = try requiredURL("--output", in: options)
      let version = try String(contentsOf: source, encoding: .utf8)
        .trimmingCharacters(in: .whitespacesAndNewlines)
      guard
        version.range(
          of: #"^[0-9]+\.[0-9]+\.[0-9]+(?:-[A-Za-z0-9.-]+)?$"#, options: .regularExpression) != nil
      else {
        throw GeneratorCommandError.validationFailed("VERSION must contain a semantic version.")
      }
      try FileManager.default.createDirectory(
        at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
      try "enum AppStoreConnectVersion { static let value = \"\(version)\" }\n"
        .write(to: destination, atomically: true, encoding: .utf8)
      return "Generated executable version from VERSION"

    case "plan":
      let schemaURL = try requiredURL("--schema", in: options)
      let audit = try OpenAPISchemaAnalyzer().audit(schemaURL: schemaURL)
      return try encodePlan(schemaURL: schemaURL, audit: audit)

    case "validate":
      let schemaURL = try requiredURL("--schema", in: options)
      _ = try validate(schemaURL: schemaURL, lockURL: optionalURL("--lock", in: options))
      return "validation succeeded"

    case "generate":
      let schemaURL = try requiredURL("--schema", in: options)
      let outputURL = try requiredURL("--output", in: options)
      let audit = try validate(schemaURL: schemaURL, lockURL: optionalURL("--lock", in: options))
      let generatedFiles = try GeneratedPublicAPIEmitter().writeGeneratedPublicAPI(
        schemaURL: schemaURL,
        audit: audit,
        outputDirectory: outputURL
      )
      return "generated \(generatedFiles.map(\.path).joined(separator: ", "))"

    case "capability-report":
      let schemaURL = try requiredURL("--schema", in: options)
      let capabilitiesURL = try requiredURL("--capabilities", in: options)
      let report = try OpenAPICapabilityMatrixReporter().report(
        schemaURL: schemaURL,
        capabilitiesURL: capabilitiesURL,
        upstreamSchemas: upstreamSchemas(in: options)
      )
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
      let data = try encoder.encode(report)
      if let outputURL = optionalURL("--output", in: options) {
        try FileManager.default.createDirectory(
          at: outputURL.deletingLastPathComponent(),
          withIntermediateDirectories: true
        )
        try data.write(to: outputURL, options: .atomic)
        return "wrote capability report \(outputURL.path)"
      }
      return String(data: data, encoding: .utf8) ?? ""

    case "trim-openapi":
      let schemaURL = try requiredURL("--schema", in: options)
      let outputURL = try requiredURL("--output", in: options)
      let operationIDs = try operationIDs(in: options)
      let report = try SelectedOpenAPITrimEmitter().writeTrimmedDocument(
        schemaURL: schemaURL,
        operationIDs: operationIDs,
        outputURL: outputURL
      )
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
      let data = try encoder.encode(report)
      let reportText = String(data: data, encoding: .utf8) ?? ""
      return "trimmed \(outputURL.path)\n\(reportText)"

    case "filter-openapi":
      let generationURL = try requiredURL("--generation", in: options)
      let outputURL = try requiredURL("--output", in: options)
      let stampURL = optionalURL("--stamp", in: options)
      let conditions = optionalList("--conditions", in: options)
      let report = try OpenAPIGenerationPlanner().writeActiveOpenAPI(
        generationManifestURL: generationURL,
        conditions: conditions,
        outputURL: outputURL,
        stampURL: stampURL
      )
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
      let data = try encoder.encode(report)
      let reportText = String(data: data, encoding: .utf8) ?? ""
      return "filtered \(outputURL.path)\n\(reportText)"

    case "verify-openapi-selection":
      let schemaURL = try requiredURL("--schema", in: options)
      let selectedURL = try requiredURL("--selected", in: options)
      let stampURL = try requiredURL("--stamp", in: options)
      let operationIDs = try operationIDs(in: options)
      _ = try validate(schemaURL: schemaURL, lockURL: optionalURL("--lock", in: options))
      let result = try SelectedOpenAPITrimEmitter().trimmedDocument(
        schemaURL: schemaURL,
        operationIDs: operationIDs
      )
      let selectedData = try Data(contentsOf: selectedURL)

      guard selectedData == result.data else {
        throw GeneratorCommandError.validationFailed(
          "selected OpenAPI input is stale; run trim-openapi to refresh \(selectedURL.path)"
        )
      }

      try FileManager.default.createDirectory(
        at: stampURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
      )
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
      let data = try encoder.encode(result.report)
      try data.write(to: stampURL, options: .atomic)
      let reportText = String(data: data, encoding: .utf8) ?? ""
      return "selected OpenAPI input verified\n\(reportText)"

    case "generate-openapi-facade":
      let capabilitiesURL = try requiredURL("--capabilities", in: options)
      let selectedURL = try requiredURL("--selected", in: options)
      let outputURL = try requiredURL("--output", in: options)
      let report = try PublicAPIFacadeEmitter().writeFacade(
        capabilitiesURL: capabilitiesURL,
        selectedOpenAPIURL: selectedURL,
        outputURL: outputURL
      )
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
      let data = try encoder.encode(report)
      let reportText = String(data: data, encoding: .utf8) ?? ""
      return "generated OpenAPI facade \(outputURL.path)\n\(reportText)"

    default:
      throw GeneratorCommandError.unknownCommand(command)
    }
  }

  public func validate(schemaURL: URL, lockURL: URL?) throws -> SchemaAudit {
    let audit = try OpenAPISchemaAnalyzer().audit(schemaURL: schemaURL)

    if audit.schema.title.isEmpty {
      throw GeneratorCommandError.validationFailed("schema title is empty")
    }

    if audit.inventory.pathCount == 0 {
      throw GeneratorCommandError.validationFailed("schema has no paths")
    }

    if audit.inventory.operationCount == 0 {
      throw GeneratorCommandError.validationFailed("schema has no operations")
    }

    if audit.inventory.schemaCount == 0 {
      throw GeneratorCommandError.validationFailed("schema has no component schemas")
    }

    if let lockURL {
      try validateLockFile(lockURL, schemaURL: schemaURL)
    }

    let outputs = try GeneratedPublicAPIEmitter().outputPlan(schemaURL: schemaURL, audit: audit)
    let duplicateOutputPaths = Dictionary(grouping: outputs.map(\.relativePath), by: { $0 })
      .filter { $0.value.count > 1 }
      .keys
      .sorted()

    if !duplicateOutputPaths.isEmpty {
      throw GeneratorCommandError.validationFailed(
        "duplicate generated output paths: \(duplicateOutputPaths.joined(separator: ", "))"
      )
    }

    return audit
  }

  private func validateLockFile(_ lockURL: URL, schemaURL: URL) throws {
    let data = try Data(contentsOf: lockURL)
    let object = try JSONSerialization.jsonObject(with: data)

    guard
      let root = object as? [String: Any],
      let schema = root["schema"] as? [String: Any],
      let lockedPath = schema["path"] as? String,
      schema["sha256"] as? String != nil
    else {
      throw GeneratorCommandError.validationFailed(
        "lock file must contain schema.path and schema.sha256")
    }

    if !schemaURL.path.hasSuffix(lockedPath) {
      throw GeneratorCommandError.validationFailed(
        "schema path does not match lock file path \(lockedPath)")
    }
  }

  private func encodePlan(schemaURL: URL, audit: SchemaAudit) throws -> String {
    let outputs = try GeneratedPublicAPIEmitter().outputPlan(schemaURL: schemaURL, audit: audit)
    let plan = GeneratorPlan(
      schema: audit.schema,
      inventory: audit.inventory,
      outputs: outputs,
      broadEndpointGenerationAllowed: true
    )

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    return String(data: try encoder.encode(plan), encoding: .utf8) ?? ""
  }

  private func parseOptions(_ arguments: [String]) throws -> [String: String] {
    var options: [String: String] = [:]
    var index = arguments.startIndex

    while index < arguments.endIndex {
      let option = arguments[index]
      let valueIndex = arguments.index(after: index)

      guard valueIndex < arguments.endIndex else {
        throw GeneratorCommandError.missingValue(option)
      }

      options[option] = arguments[valueIndex]
      index = arguments.index(after: valueIndex)
    }

    return options
  }

  private func requiredURL(_ option: String, in options: [String: String]) throws -> URL {
    guard let value = options[option] else {
      throw GeneratorCommandError.missingRequiredOption(option)
    }

    return URL(fileURLWithPath: value)
  }

  private func requiredList(_ option: String, in options: [String: String]) throws -> [String] {
    guard let value = options[option] else {
      throw GeneratorCommandError.missingRequiredOption(option)
    }

    let values = parseList(value)
    if values.isEmpty {
      throw GeneratorCommandError.validationFailed("\(option) must contain at least one value")
    }

    return values
  }

  private func optionalList(_ option: String, in options: [String: String]) -> [String] {
    guard let value = options[option] else {
      return []
    }

    return parseList(value)
  }

  private func parseList(_ value: String) -> [String] {
    let values =
      value
      .split(separator: ",")
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }

    return values
  }

  private func operationIDs(in options: [String: String]) throws -> [String] {
    if let capabilitiesURL = optionalURL("--capabilities", in: options) {
      return try OpenAPICapabilityManifest.load(from: capabilitiesURL).operationIDs()
    }

    if let selectionURL = optionalURL("--selection", in: options) {
      let selection = try OpenAPISelection.load(from: selectionURL)
      return try selection.operationIDs()
    }

    return try OpenAPISelection.validateOperations(try requiredList("--operations", in: options))
  }
  private func upstreamSchemas(in options: [String: String]) -> [OpenAPIUpstreamSchemaInput] {
    guard let url = optionalURL("--comparison-schema", in: options) else { return [] }
    return [OpenAPIUpstreamSchemaInput(name: url.lastPathComponent, schemaURL: url)]
  }


  private func optionalURL(_ option: String, in options: [String: String]) -> URL? {
    options[option].map { URL(fileURLWithPath: $0) }
  }
}

public struct GeneratorPlan: Codable, Equatable, Sendable {
  public var schema: SchemaIdentity
  public var inventory: SchemaInventory
  public var outputs: [GeneratedOutput]
  public var broadEndpointGenerationAllowed: Bool
}

public struct GeneratedOutput: Codable, Equatable, Sendable {
  public var relativePath: String
  public var bucket: String
  public var constructSummary: String

  public init(relativePath: String, bucket: String, constructSummary: String) {
    self.relativePath = relativePath
    self.bucket = bucket
    self.constructSummary = constructSummary
  }
}
