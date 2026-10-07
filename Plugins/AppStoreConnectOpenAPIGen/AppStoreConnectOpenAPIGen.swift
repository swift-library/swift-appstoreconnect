// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import Foundation
import PackagePlugin

@main
struct AppStoreConnectOpenAPIGen: BuildToolPlugin {
  func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
    guard let swiftTarget = target as? SwiftSourceModuleTarget else {
      throw OpenAPIGenPluginError.unsupportedTarget(target.name)
    }

    let selector = try context.tool(named: "AppStoreConnectPublicAPIGen")
    let generator = try context.tool(named: "swift-openapi-generator")
    let schema = context.package.directoryURL
      .appendingPathComponent("Vendor")
      .appendingPathComponent("AppStoreConnectOpenAPI")
      .appendingPathComponent("schema")
      .appendingPathComponent("app-store-connect-openapi.json")
    let lock = context.package.directoryURL
      .appendingPathComponent("Vendor")
      .appendingPathComponent("AppStoreConnectOpenAPI")
      .appendingPathComponent("spec.lock.json")
    let partitionManifest = context.package.directoryURL
      .appendingPathComponent("Vendor")
      .appendingPathComponent("AppStoreConnectOpenAPI")
      .appendingPathComponent("partitions")
      .appendingPathComponent("public-api-traits.json")
    let capabilities = target.directoryURL.appendingPathComponent("openapi-capabilities.json")
    let generationManifest = target.directoryURL.appendingPathComponent("openapi-generation.json")
    let sliceManifestDirectory = target.directoryURL.appendingPathComponent("OpenAPISlices")
    let sliceManifests = try openAPISliceManifests(in: sliceManifestDirectory)
    let activeOpenAPI = context.pluginWorkDirectoryURL
      .appendingPathComponent("AppStoreConnectOpenAPI.active.json")
    let config = target.directoryURL.appendingPathComponent("openapi-generator-config.yaml")
    let stamp = context.pluginWorkDirectoryURL
      .appendingPathComponent("AppStoreConnectOpenAPISelection.stamp")
    let generatedSources = context.pluginWorkDirectoryURL
      .appendingPathComponent("GeneratedSources")
    let generatedFacade =
      generatedSources
      .appendingPathComponent("AppStoreConnectPublicAPI+Facade.swift")
    let generatedFiles = [
      generatedSources.appendingPathComponent("Types.swift"),
      generatedSources.appendingPathComponent("Client.swift"),
      generatedSources.appendingPathComponent("Server.swift"),
    ]

    return [
      .buildCommand(
        displayName: "Filter AppStoreConnect OpenAPI input",
        executable: selector.url,
        arguments: [
          "filter-openapi",
          "--generation", generationManifest.path,
          "--conditions", swiftTarget.compilationConditions.sorted().joined(separator: ","),
          "--output", activeOpenAPI.path,
          "--stamp", stamp.path,
        ],
        inputFiles: [schema, lock, partitionManifest, generationManifest, capabilities]
          + sliceManifests,
        outputFiles: [activeOpenAPI, stamp]
      ),
      .buildCommand(
        displayName: "Generate AppStoreConnect OpenAPI Swift",
        executable: generator.url,
        arguments: [
          "generate", activeOpenAPI.path,
          "--config", config.path,
          "--output-directory", generatedSources.path,
          "--plugin-source", "build",
        ],
        inputFiles: [stamp, activeOpenAPI, config],
        outputFiles: generatedFiles
      ),
      .buildCommand(
        displayName: "Generate AppStoreConnect PublicAPI facade",
        executable: selector.url,
        arguments: [
          "generate-openapi-facade",
          "--capabilities", capabilities.path,
          "--selected", activeOpenAPI.path,
          "--output", generatedFacade.path,
        ],
        inputFiles: [capabilities, activeOpenAPI],
        outputFiles: [generatedFacade]
      ),
    ]
  }

  private func openAPISliceManifests(in directory: URL) throws -> [URL] {
    guard
      let enumerator = FileManager.default.enumerator(
        at: directory,
        includingPropertiesForKeys: nil
      )
    else {
      return []
    }

    return
      enumerator
      .compactMap { $0 as? URL }
      .filter { $0.pathExtension == "json" }
      .sorted { $0.path < $1.path }
  }
}

enum OpenAPIGenPluginError: Error, CustomStringConvertible {
  case unsupportedTarget(String)

  var description: String {
    switch self {
    case .unsupportedTarget(let target):
      "AppStoreConnectOpenAPIGen requires a Swift source target, got \(target)"
    }
  }
}
