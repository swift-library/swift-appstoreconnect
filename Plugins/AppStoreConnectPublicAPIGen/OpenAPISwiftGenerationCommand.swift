// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import Foundation
import _OpenAPIGeneratorCore

enum OpenAPISwiftGenerationError: Error, CustomStringConvertible {
  case missingRequiredOption(String)
  case missingValue(String)
  case invalidConfig(String)

  var description: String {
    switch self {
    case .missingRequiredOption(let option):
      "missing required option \(option)"
    case .missingValue(let option):
      "missing value for option \(option)"
    case .invalidConfig(let message):
      "invalid OpenAPI generator config: \(message)"
    }
  }
}

struct OpenAPISwiftGenerationCommand {
  func run(arguments: [String]) throws -> String? {
    let options = try parseOptions(arguments)
    let documentURL = try requiredURL("--document", in: options)
    let configURL = try requiredURL("--config", in: options)
    let outputURL = try requiredURL("--output", in: options)
    let config = try OpenAPISwiftGenerationConfig.load(from: configURL)
    let generatedFiles = try generate(
      documentURL: documentURL, outputURL: outputURL, config: config)

    return
      "generated OpenAPI Swift \(generatedFiles.map(\.lastPathComponent).joined(separator: ", "))"
  }

  private func generate(
    documentURL: URL,
    outputURL: URL,
    config: OpenAPISwiftGenerationConfig
  ) throws -> [URL] {
    let data = try Data(contentsOf: documentURL)
    let diagnostics = ErrorThrowingDiagnosticCollector(
      upstream: StdErrPrintingDiagnosticCollector())
    var generatedFiles: [URL] = []

    try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true)

    for mode in config.modes.sorted() {
      let generatorConfig = Config(
        mode: mode,
        access: config.accessModifier,
        namingStrategy: config.namingStrategy
      )
      let output = try _OpenAPIGeneratorCore.runGenerator(
        input: InMemoryInputFile(absolutePath: documentURL, contents: data),
        config: generatorConfig,
        diagnostics: diagnostics
      )
      let outputFile = outputURL.appendingPathComponent(mode.outputFileName)
      try write(output.contents, to: outputFile)
      generatedFiles.append(outputFile)
    }

    let missingModes = Set(GeneratorMode.allCases).subtracting(config.modes)
    for mode in missingModes.sorted() {
      let outputFile = outputURL.appendingPathComponent(mode.outputFileName)
      try write(Data(), to: outputFile)
      generatedFiles.append(outputFile)
    }

    return generatedFiles.sorted { $0.lastPathComponent < $1.lastPathComponent }
  }

  private func write(_ data: Data, to url: URL) throws {
    if let existing = try? Data(contentsOf: url), existing == data {
      print("File \(url.lastPathComponent) already up to date.")
      return
    }

    print("Writing data to file \(url.lastPathComponent)...")
    try data.write(to: url)
  }

  private func parseOptions(_ arguments: [String]) throws -> [String: String] {
    var options: [String: String] = [:]
    var index = arguments.startIndex

    while index < arguments.endIndex {
      let option = arguments[index]
      let valueIndex = arguments.index(after: index)

      guard valueIndex < arguments.endIndex else {
        throw OpenAPISwiftGenerationError.missingValue(option)
      }

      options[option] = arguments[valueIndex]
      index = arguments.index(after: valueIndex)
    }

    return options
  }

  private func requiredURL(_ option: String, in options: [String: String]) throws -> URL {
    guard let value = options[option] else {
      throw OpenAPISwiftGenerationError.missingRequiredOption(option)
    }

    return URL(fileURLWithPath: value)
  }
}

struct OpenAPISwiftGenerationConfig {
  var modes: Set<GeneratorMode>
  var accessModifier: AccessModifier
  var namingStrategy: NamingStrategy

  static func load(from url: URL) throws -> OpenAPISwiftGenerationConfig {
    let text = try String(contentsOf: url, encoding: .utf8)
    var modes: Set<GeneratorMode> = []
    var accessModifier: AccessModifier = .internal
    var namingStrategy: NamingStrategy = .defensive
    var section: String?

    for rawLine in text.split(whereSeparator: \.isNewline) {
      let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)

      if line.isEmpty || line.hasPrefix("#") {
        continue
      }

      if line == "generate:" {
        section = "generate"
        continue
      }

      if line.hasPrefix("-") {
        guard section == "generate" else {
          throw OpenAPISwiftGenerationError.invalidConfig(
            "list item outside generate section: \(line)")
        }

        let value = String(line.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
        guard let mode = GeneratorMode(rawValue: value) else {
          throw OpenAPISwiftGenerationError.invalidConfig("unknown generator mode \(value)")
        }
        modes.insert(mode)
        continue
      }

      section = nil

      if let value = scalarValue(for: "accessModifier", in: line) {
        guard let access = AccessModifier(rawValue: value) else {
          throw OpenAPISwiftGenerationError.invalidConfig("unknown access modifier \(value)")
        }
        accessModifier = access
        continue
      }

      if let value = scalarValue(for: "namingStrategy", in: line) {
        guard let naming = NamingStrategy(rawValue: value) else {
          throw OpenAPISwiftGenerationError.invalidConfig("unknown naming strategy \(value)")
        }
        namingStrategy = naming
        continue
      }

      throw OpenAPISwiftGenerationError.invalidConfig("unsupported line: \(line)")
    }

    if modes.isEmpty {
      throw OpenAPISwiftGenerationError.invalidConfig("generate must contain at least one mode")
    }

    return OpenAPISwiftGenerationConfig(
      modes: modes,
      accessModifier: accessModifier,
      namingStrategy: namingStrategy
    )
  }

  private static func scalarValue(for key: String, in line: String) -> String? {
    let prefix = "\(key):"
    guard line.hasPrefix(prefix) else {
      return nil
    }

    return line.dropFirst(prefix.count)
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
