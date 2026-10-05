// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import AppStoreConnectCore
import Foundation

public struct AppStoreConnectLocalToolInvocation: Codable, Sendable, Equatable {
  public var executablePath: String
  public var arguments: [String]
  public var environment: [String: String]
  public var currentDirectoryPath: String?

  public init(
    executablePath: String,
    arguments: [String],
    environment: [String: String] = [:],
    currentDirectoryPath: String? = nil
  ) {
    self.executablePath = executablePath
    self.arguments = arguments
    self.environment = environment
    self.currentDirectoryPath = currentDirectoryPath
  }
}

public struct AppStoreConnectLocalToolResult: Codable, Sendable, Equatable {
  public var exitCode: Int32
  public var stdout: String
  public var stderr: String

  public init(exitCode: Int32, stdout: String = "", stderr: String = "") {
    self.exitCode = exitCode
    self.stdout = stdout
    self.stderr = stderr
  }
}

public struct AppStoreConnectLocalToolRunner: Sendable {
  public var run:
    @Sendable (AppStoreConnectLocalToolInvocation) async throws -> AppStoreConnectLocalToolResult

  public init(
    run:
      @escaping @Sendable (AppStoreConnectLocalToolInvocation) async throws ->
      AppStoreConnectLocalToolResult
  ) {
    self.run = run
  }

  public static var live: Self {
    Self { invocation in
      try await runLocalTool(invocation)
    }
  }
}

public struct AppStoreConnectXcodeVersionInput: Codable, Sendable, Equatable {
  public var xcodebuildPath: String
  public var developerDirectoryPath: String?
  public var currentDirectoryPath: String?

  public init(
    xcodebuildPath: String = "xcodebuild",
    developerDirectoryPath: String? = nil,
    currentDirectoryPath: String? = nil
  ) {
    self.xcodebuildPath = xcodebuildPath
    self.developerDirectoryPath = developerDirectoryPath
    self.currentDirectoryPath = currentDirectoryPath
  }
}

public struct AppStoreConnectXcodeArchiveInput: Codable, Sendable, Equatable {
  public var workspacePath: String?
  public var projectPath: String?
  public var scheme: String
  public var configuration: String?
  public var destination: String?
  public var archivePath: String
  public var derivedDataPath: String?
  public var resultBundlePath: String?
  public var allowProvisioningUpdates: Bool
  public var xcodebuildPath: String
  public var developerDirectoryPath: String?
  public var currentDirectoryPath: String?

  public init(
    workspacePath: String? = nil,
    projectPath: String? = nil,
    scheme: String,
    configuration: String? = nil,
    destination: String? = nil,
    archivePath: String,
    derivedDataPath: String? = nil,
    resultBundlePath: String? = nil,
    allowProvisioningUpdates: Bool = false,
    xcodebuildPath: String = "xcodebuild",
    developerDirectoryPath: String? = nil,
    currentDirectoryPath: String? = nil
  ) {
    self.workspacePath = workspacePath
    self.projectPath = projectPath
    self.scheme = scheme
    self.configuration = configuration
    self.destination = destination
    self.archivePath = archivePath
    self.derivedDataPath = derivedDataPath
    self.resultBundlePath = resultBundlePath
    self.allowProvisioningUpdates = allowProvisioningUpdates
    self.xcodebuildPath = xcodebuildPath
    self.developerDirectoryPath = developerDirectoryPath
    self.currentDirectoryPath = currentDirectoryPath
  }
}

public struct AppStoreConnectXcodeExportInput: Codable, Sendable, Equatable {
  public var archivePath: String
  public var exportPath: String
  public var exportOptionsPlistPath: String
  public var xcodebuildPath: String
  public var developerDirectoryPath: String?
  public var currentDirectoryPath: String?

  public init(
    archivePath: String,
    exportPath: String,
    exportOptionsPlistPath: String,
    xcodebuildPath: String = "xcodebuild",
    developerDirectoryPath: String? = nil,
    currentDirectoryPath: String? = nil
  ) {
    self.archivePath = archivePath
    self.exportPath = exportPath
    self.exportOptionsPlistPath = exportOptionsPlistPath
    self.xcodebuildPath = xcodebuildPath
    self.developerDirectoryPath = developerDirectoryPath
    self.currentDirectoryPath = currentDirectoryPath
  }
}

public enum AppStoreConnectUploadTransport: String, Codable, Sendable, Equatable {
  case transporter
  case altool
}

public struct AppStoreConnectXcodeUploadInput: Codable, Sendable, Equatable {
  public var assetPath: String
  public var apiKeyID: String?
  public var apiIssuerID: String?
  public var toolPath: String
  public var transport: AppStoreConnectUploadTransport
  public var currentDirectoryPath: String?

  public init(
    assetPath: String,
    apiKeyID: String? = nil,
    apiIssuerID: String? = nil,
    toolPath: String = "xcrun",
    transport: AppStoreConnectUploadTransport = .transporter,
    currentDirectoryPath: String? = nil
  ) {
    self.assetPath = assetPath
    self.apiKeyID = apiKeyID
    self.apiIssuerID = apiIssuerID
    self.toolPath = toolPath
    self.transport = transport
    self.currentDirectoryPath = currentDirectoryPath
  }
}

public struct AppStoreConnectXcodeToolPlan: Codable, Sendable, Equatable {
  public var operation: String
  public var mutatesLocalFileSystem: Bool
  public var contactsAppleServices: Bool
  public var invocation: AppStoreConnectLocalToolInvocation
  public var message: String

  public init(
    operation: String,
    mutatesLocalFileSystem: Bool,
    contactsAppleServices: Bool,
    invocation: AppStoreConnectLocalToolInvocation,
    message: String
  ) {
    self.operation = operation
    self.mutatesLocalFileSystem = mutatesLocalFileSystem
    self.contactsAppleServices = contactsAppleServices
    self.invocation = invocation
    self.message = message
  }
}

public struct AppStoreConnectXcodeToolRunResult: Codable, Sendable, Equatable {
  public var plan: AppStoreConnectXcodeToolPlan
  public var result: AppStoreConnectLocalToolResult

  public init(plan: AppStoreConnectXcodeToolPlan, result: AppStoreConnectLocalToolResult) {
    self.plan = plan
    self.result = result
  }

  public var succeeded: Bool {
    result.exitCode == 0
  }
}

public enum AppStoreConnectXcodeCommandError: Error, Sendable, Equatable, CustomStringConvertible {
  case workspaceAndProjectAreMutuallyExclusive
  case workspaceOrProjectRequired

  public var description: String {
    switch self {
    case .workspaceAndProjectAreMutuallyExclusive:
      "Pass either a workspace path or a project path, not both."
    case .workspaceOrProjectRequired:
      "Pass --workspace or --project for xcode archive."
    }
  }
}

public struct AppStoreConnectXcodeCommands: Sendable {
  public var runner: AppStoreConnectLocalToolRunner

  public init(runner: AppStoreConnectLocalToolRunner = .live) {
    self.runner = runner
  }

  public static func planVersion(_ input: AppStoreConnectXcodeVersionInput = .init())
    -> AppStoreConnectXcodeToolPlan
  {
    AppStoreConnectXcodeToolPlan(
      operation: "xcode-version",
      mutatesLocalFileSystem: false,
      contactsAppleServices: false,
      invocation: AppStoreConnectLocalToolInvocation(
        executablePath: input.xcodebuildPath,
        arguments: ["-version"],
        environment: developerDirectoryEnvironment(input.developerDirectoryPath),
        currentDirectoryPath: input.currentDirectoryPath
      ),
      message: "Reads the selected xcodebuild version."
    )
  }

  public static func planArchive(_ input: AppStoreConnectXcodeArchiveInput) throws
    -> AppStoreConnectXcodeToolPlan
  {
    if input.workspacePath != nil, input.projectPath != nil {
      throw AppStoreConnectXcodeCommandError.workspaceAndProjectAreMutuallyExclusive
    }
    guard input.workspacePath != nil || input.projectPath != nil else {
      throw AppStoreConnectXcodeCommandError.workspaceOrProjectRequired
    }

    var arguments: [String] = []
    if let workspacePath = input.workspacePath {
      arguments += ["-workspace", workspacePath]
    }
    if let projectPath = input.projectPath {
      arguments += ["-project", projectPath]
    }
    arguments += ["-scheme", input.scheme]
    if let configuration = input.configuration {
      arguments += ["-configuration", configuration]
    }
    if let destination = input.destination {
      arguments += ["-destination", destination]
    }
    if let derivedDataPath = input.derivedDataPath {
      arguments += ["-derivedDataPath", derivedDataPath]
    }
    if let resultBundlePath = input.resultBundlePath {
      arguments += ["-resultBundlePath", resultBundlePath]
    }
    if input.allowProvisioningUpdates {
      arguments.append("-allowProvisioningUpdates")
    }
    arguments += ["-archivePath", input.archivePath, "archive"]

    return AppStoreConnectXcodeToolPlan(
      operation: "xcode-archive",
      mutatesLocalFileSystem: true,
      contactsAppleServices: input.allowProvisioningUpdates,
      invocation: AppStoreConnectLocalToolInvocation(
        executablePath: input.xcodebuildPath,
        arguments: arguments,
        environment: developerDirectoryEnvironment(input.developerDirectoryPath),
        currentDirectoryPath: input.currentDirectoryPath
      ),
      message: "Archives through local xcodebuild. Dry-run is the default CLI behavior."
    )
  }

  public static func planExport(_ input: AppStoreConnectXcodeExportInput)
    -> AppStoreConnectXcodeToolPlan
  {
    AppStoreConnectXcodeToolPlan(
      operation: "xcode-export",
      mutatesLocalFileSystem: true,
      contactsAppleServices: false,
      invocation: AppStoreConnectLocalToolInvocation(
        executablePath: input.xcodebuildPath,
        arguments: [
          "-exportArchive",
          "-archivePath", input.archivePath,
          "-exportPath", input.exportPath,
          "-exportOptionsPlist", input.exportOptionsPlistPath,
        ],
        environment: developerDirectoryEnvironment(input.developerDirectoryPath),
        currentDirectoryPath: input.currentDirectoryPath
      ),
      message: "Exports a local archive through xcodebuild. Dry-run is the default CLI behavior."
    )
  }

  public static func planUpload(_ input: AppStoreConnectXcodeUploadInput)
    -> AppStoreConnectXcodeToolPlan
  {
    var arguments: [String]
    switch input.transport {
    case .transporter:
      arguments = ["iTMSTransporter", "-m", "upload", "-assetFile", input.assetPath]
      if let apiKeyID = input.apiKeyID {
        arguments += ["-apiKey", apiKeyID]
      }
      if let apiIssuerID = input.apiIssuerID {
        arguments += ["-apiIssuer", apiIssuerID]
      }
    case .altool:
      arguments = ["altool", "--upload-app", "-f", input.assetPath]
      if let apiKeyID = input.apiKeyID {
        arguments += ["--apiKey", apiKeyID]
      }
      if let apiIssuerID = input.apiIssuerID {
        arguments += ["--apiIssuer", apiIssuerID]
      }
    }

    return AppStoreConnectXcodeToolPlan(
      operation: "xcode-upload",
      mutatesLocalFileSystem: false,
      contactsAppleServices: true,
      invocation: AppStoreConnectLocalToolInvocation(
        executablePath: input.toolPath,
        arguments: arguments,
        currentDirectoryPath: input.currentDirectoryPath
      ),
      message:
        "Uploads an IPA/package through the selected local Apple upload tool. Dry-run is the default CLI behavior."
    )
  }

  public func version(_ input: AppStoreConnectXcodeVersionInput = .init()) async throws
    -> AppStoreConnectXcodeToolRunResult
  {
    try await run(Self.planVersion(input))
  }

  public func archive(_ input: AppStoreConnectXcodeArchiveInput) async throws
    -> AppStoreConnectXcodeToolRunResult
  {
    try await run(Self.planArchive(input))
  }

  public func export(_ input: AppStoreConnectXcodeExportInput) async throws
    -> AppStoreConnectXcodeToolRunResult
  {
    try await run(Self.planExport(input))
  }

  public func upload(_ input: AppStoreConnectXcodeUploadInput) async throws
    -> AppStoreConnectXcodeToolRunResult
  {
    try await run(Self.planUpload(input))
  }

  private func run(_ plan: AppStoreConnectXcodeToolPlan) async throws
    -> AppStoreConnectXcodeToolRunResult
  {
    AppStoreConnectXcodeToolRunResult(
      plan: plan,
      result: try await runner.run(plan.invocation)
    )
  }

  private static func developerDirectoryEnvironment(_ path: String?) -> [String: String] {
    guard let path, !path.isEmpty else {
      return [:]
    }
    return ["DEVELOPER_DIR": path]
  }
}

#if os(macOS)
  private final class AppStoreConnectLockedData: @unchecked Sendable {
    private let lock = NSLock()
    private var data = Data()

    func append(_ newData: Data) {
      guard !newData.isEmpty else {
        return
      }
      lock.lock()
      data.append(newData)
      lock.unlock()
    }

    func string() -> String {
      lock.lock()
      let snapshot = data
      lock.unlock()
      return String(decoding: snapshot, as: UTF8.self)
    }
  }

  private func runLocalTool(
    _ invocation: AppStoreConnectLocalToolInvocation
  ) async throws -> AppStoreConnectLocalToolResult {
    try await withCheckedThrowingContinuation { continuation in
      let process = Process()
      if invocation.executablePath.contains("/") {
        process.executableURL = URL(fileURLWithPath: invocation.executablePath)
        process.arguments = invocation.arguments
      } else {
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [invocation.executablePath] + invocation.arguments
      }
      if let currentDirectoryPath = invocation.currentDirectoryPath {
        process.currentDirectoryURL = URL(fileURLWithPath: currentDirectoryPath)
      }

      var environment = ProcessInfo.processInfo.environment
      for (key, value) in invocation.environment {
        environment[key] = value
      }
      process.environment = environment

      let stdoutPipe = Pipe()
      let stderrPipe = Pipe()
      let stdout = AppStoreConnectLockedData()
      let stderr = AppStoreConnectLockedData()

      stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
        stdout.append(handle.availableData)
      }
      stderrPipe.fileHandleForReading.readabilityHandler = { handle in
        stderr.append(handle.availableData)
      }

      process.standardOutput = stdoutPipe
      process.standardError = stderrPipe

      process.terminationHandler = { process in
        stdoutPipe.fileHandleForReading.readabilityHandler = nil
        stderrPipe.fileHandleForReading.readabilityHandler = nil
        stdout.append(stdoutPipe.fileHandleForReading.readDataToEndOfFile())
        stderr.append(stderrPipe.fileHandleForReading.readDataToEndOfFile())
        continuation.resume(
          returning: AppStoreConnectLocalToolResult(
            exitCode: process.terminationStatus,
            stdout: stdout.string(),
            stderr: stderr.string()
          ))
      }

      do {
        try process.run()
      } catch {
        stdoutPipe.fileHandleForReading.readabilityHandler = nil
        stderrPipe.fileHandleForReading.readabilityHandler = nil
        continuation.resume(throwing: error)
      }
    }
  }

#else
  private func runLocalTool(_ invocation: AppStoreConnectLocalToolInvocation) async throws
    -> AppStoreConnectLocalToolResult
  {
    throw AppStoreConnectError.unsupportedCapability("Local Xcode tools require macOS.")
  }
#endif
