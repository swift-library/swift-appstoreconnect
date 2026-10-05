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
