// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import PackagePlugin

@main
struct AppStoreConnectVersionGen: BuildToolPlugin {
  func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
    let generator = try context.tool(named: "AppStoreConnectPublicAPIGen")
    let version = context.package.directoryURL.appendingPathComponent("VERSION")
    let output = context.pluginWorkDirectoryURL.appendingPathComponent(
      "AppStoreConnectVersion.swift")
    return [
      .buildCommand(
        displayName: "Generate executable version",
        executable: generator.url,
        arguments: ["generate-version", "--version-file", version.path, "--output", output.path],
        inputFiles: [version],
        outputFiles: [output]
      )
    ]
  }
}
