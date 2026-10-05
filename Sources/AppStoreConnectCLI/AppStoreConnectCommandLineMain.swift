// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import ArgumentParser
import Foundation

@main
struct AppStoreConnectCommandLineMain: AsyncParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "appstoreconnect",
    abstract: "App Store Connect public API and workflow commands.",
    discussion: AppStoreConnectCommand.helpText,
    version: AppStoreConnectVersion.value
  )

  @Argument(parsing: .unconditionalRemaining, help: "Command and command-specific options.")
  var arguments: [String] = []

  static func main() async {
    do {
      var command = try parseAsRoot()
      if var asynchronous = command as? any AsyncParsableCommand {
        try await asynchronous.run()
      } else {
        try command.run()
      }
    } catch {
      let result = renderedError(
        error, arguments: Array(CommandLine.arguments.dropFirst()),
        environment: ProcessInfo.processInfo.environment
      )
      if !result.stdout.isEmpty { print(result.stdout, terminator: "") }
      if !result.stderr.isEmpty {
        FileHandle.standardError.write(Data(result.stderr.utf8))
      }
      exit(withError: ExitCode(result.exitCode))
    }
  }

  static func renderedError(
    _ error: any Error, arguments: [String], environment: [String: String]
  ) -> AppStoreConnectCLIResult {
    let status = exitCode(for: error).rawValue
    let message = fullMessage(for: error)
    if status == 0 {
      return AppStoreConnectCLIResult(exitCode: status, stdout: message)
    }
    return AppStoreConnectCLIResult(
      exitCode: status,
      stderr: AppStoreConnectCommand.redacted(
        message, arguments: arguments, environment: environment)
    )
  }

  mutating func run() async throws {
    let result = await AppStoreConnectCommand.run(arguments: arguments)
    if !result.stdout.isEmpty {
      print(result.stdout, terminator: "")
    }
    if !result.stderr.isEmpty {
      FileHandle.standardError.write(Data(result.stderr.utf8))
    }
    throw ExitCode(result.exitCode)
  }
}
