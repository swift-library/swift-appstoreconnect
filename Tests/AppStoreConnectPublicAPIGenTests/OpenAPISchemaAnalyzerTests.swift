// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import AppStoreConnectPublicAPIGenCore
import Foundation
import Testing

@Test func auditReadsLockedOfficialSchema() throws {
  let audit = try OpenAPISchemaAnalyzer().audit(
    schemaURL: packageRoot()
      .appending(path: "Vendor/AppStoreConnectOpenAPI/schema/app-store-connect-openapi.json"))

  #expect(audit.schema.openapi == "3.0.1")
  #expect(audit.schema.title == "App Store Connect API")
  #expect(audit.schema.version == "4.3")
  #expect(audit.inventory.pathCount == 923)
  #expect(audit.inventory.operationCount == 1208)
  #expect(audit.inventory.schemaCount == 1337)
  #expect(audit.inventory.securitySchemes == ["itc-bearer-token"])
  #expect(audit.inventory.uploadRelatedOperationCount == 15)
  #expect(audit.inventory.constructCounts.oneOf == 173)
}

@Test func generatorPlanCoversModelsAndOperations() throws {
  let schemaURL = packageRoot()
    .appending(path: "Vendor/AppStoreConnectOpenAPI/schema/app-store-connect-openapi.json")
  let output = try #require(
    try GeneratorCommand().run(arguments: [
      "plan",
      "--schema", schemaURL.path,
    ]))

  #expect(output.contains("\"relativePath\" : \"AppStoreConnectPublicAPI+Generated.swift\""))
  #expect(output.contains("\"relativePath\" : \"Models\\/AppStoreConnectPublicAPI+Models.swift\""))
  #expect(
    output.contains("\"relativePath\" : \"Operations\\/AppStoreConnectPublicAPI+Operations.swift\"")
  )
  #expect(
    output.contains("1280 object structs, 54 string enums, 1 dictionary aliases, 2 scalar aliases"))
  #expect(output.contains("1208 operation IDs, descriptors, and raw request builders"))
  #expect(output.contains("\"broadEndpointGenerationAllowed\" : true"))
}

@Test func generatorEmitsModelsOperationsAndMappedFallbacks() throws {
  let root = packageRoot()
  let outputDirectory = FileManager.default.temporaryDirectory
    .appending(path: "AppStoreConnectPublicAPIGenTests-\(UUID().uuidString)")
  let schemaURL = root.appending(
    path: "Vendor/AppStoreConnectOpenAPI/schema/app-store-connect-openapi.json")
  let lockURL = root.appending(path: "Vendor/AppStoreConnectOpenAPI/spec.lock.json")

  _ = try GeneratorCommand().run(arguments: [
    "generate",
    "--schema", schemaURL.path,
    "--lock", lockURL.path,
    "--output", outputDirectory.path,
  ])

  let supportSource = try String(
    contentsOf: outputDirectory.appending(path: "AppStoreConnectPublicAPI+Generated.swift"),
    encoding: .utf8
  )
  let modelSource = try String(
    contentsOf: outputDirectory.appending(path: "Models/AppStoreConnectPublicAPI+Models.swift"),
    encoding: .utf8
  )
  let operationSource = try String(
    contentsOf: outputDirectory.appending(
      path: "Operations/AppStoreConnectPublicAPI+Operations.swift"),
    encoding: .utf8
  )

  #expect(supportSource.contains("public enum AppStoreConnectPublicAPIGenerated"))
  #expect(supportSource.contains("public static let schemaVersion = \"4.3\""))
  #expect(supportSource.contains("public static let pathCount = 923"))
  #expect(supportSource.contains("public static let generatedOperationCount = 1208"))
  #expect(supportSource.contains("public static let explicitlyMappedOneOfConstructCount = 173"))
  #expect(supportSource.contains("public indirect enum AppStoreConnectJSONValue"))

  #expect(modelSource.contains("public enum Platform"))
  #expect(modelSource.contains("case macOs = \"MAC_OS\""))
  #expect(modelSource.contains("public typealias StringToStringMap = [String: String]"))
  #expect(modelSource.contains("public var included: [AppStoreConnectJSONValue]?"))
  #expect(modelSource.contains("case selfValue = \"self\""))

  #expect(operationSource.contains("public enum AppStoreConnectPublicAPIOperationID"))
  #expect(operationSource.contains("case appsGetCollection = \"apps_getCollection\""))
  #expect(operationSource.contains("case appsGetInstance = \"apps_getInstance\""))
  #expect(operationSource.contains("public struct AppStoreConnectPublicAPIOperationDescriptor"))
}

@Test func selectedOpenAPITrimKeepsWhitelistedOperationsAndReferencedSchemas() throws {
  let root = packageRoot()
  let outputURL = FileManager.default.temporaryDirectory
    .appending(path: "AppStoreConnectSelectedOpenAPITrim-\(UUID().uuidString).json")
  let schemaURL = root.appending(
    path: "Vendor/AppStoreConnectOpenAPI/schema/app-store-connect-openapi.json")

  let report = try SelectedOpenAPITrimEmitter().writeTrimmedDocument(
    schemaURL: schemaURL,
    operationIDs: [
      "apps_getCollection",
      "apps_getInstance",
      "buildUploads_createInstance",
    ],
    outputURL: outputURL
  )

  let data = try Data(contentsOf: outputURL)
  let document = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
  let paths = try #require(document["paths"] as? [String: Any])
  let components = try #require(document["components"] as? [String: Any])
  let schemas = try #require(components["schemas"] as? [String: Any])
  let text = try #require(String(data: data, encoding: .utf8))

  #expect(report.operationCount == 3)
  #expect(paths["/v1/apps"] != nil)
  #expect(paths["/v1/apps/{id}"] != nil)
  #expect(paths["/v1/buildUploads"] != nil)
  #expect(schemas["AppsResponse"] != nil)
  #expect(schemas["AppResponse"] != nil)
  #expect(schemas["BuildUploadResponse"] != nil)
  #expect(!text.contains(#""enum" : []"#))
}

@Test func capabilityManifestPreservesSelectedOperationOrder() throws {
  let manifestURL = packageRoot()
    .appending(path: "Sources/AppStoreConnectPublicAPI/openapi-capabilities.json")
  let manifest = try OpenAPICapabilityManifest.load(from: manifestURL)
  let operationIDs = try manifest.operationIDs()

  #expect(manifest.schemaVersion == "4.3")
  #expect(
    manifest.capabilities.map(\.id) == [
      "apps",
      "builds",
      "testflight",
      "media-assets",
      "reports",
      "users",
      "certificates-profiles",
    ])
  #expect(operationIDs.count == 144)
  #expect(
    Array(operationIDs.prefix(3)) == [
      "appInfoLocalizations_createInstance",
      "appInfoLocalizations_deleteInstance",
      "appInfoLocalizations_getInstance",
    ])
  #expect(operationIDs.contains("apps_getCollection"))
  #expect(operationIDs.contains("buildUploads_createInstance"))
  #expect(operationIDs.contains("apps_betaFeedbackCrashSubmissions_getToManyRelated"))
  #expect(operationIDs.contains("apps_betaTesterUsages_getMetrics"))
  #expect(operationIDs.contains("betaGroups_publicLinkUsages_getMetrics"))
  #expect(operationIDs.contains("builds_betaBuildUsages_getMetrics"))
  #expect(operationIDs.contains("betaFeedbackScreenshotSubmissions_getInstance"))
  #expect(operationIDs.contains("betaGroups_getCollection"))
  #expect(operationIDs.contains("appPreviews_createInstance"))
  #expect(operationIDs.contains("salesReports_getCollection"))
  #expect(operationIDs.contains("profiles_getInstance"))
  #expect(operationIDs.contains("bundleIds_bundleIdCapabilities_getToManyRelated"))
  #expect(operationIDs.contains("bundleIdCapabilities_createInstance"))
}

@Test func capabilityReportComparesOfficialSelectedAndUpstreamSchemas() throws {
  let root = packageRoot()
  let schemaURL = root.appending(
    path: "Vendor/AppStoreConnectOpenAPI/schema/app-store-connect-openapi.json")
  let capabilitiesURL = root.appending(
    path: "Sources/AppStoreConnectPublicAPI/openapi-capabilities.json")

  let report = try OpenAPICapabilityMatrixReporter().report(
    schemaURL: schemaURL,
    capabilitiesURL: capabilitiesURL,
    upstreamSchemas: [
      OpenAPIUpstreamSchemaInput(name: "official-copy", schemaURL: schemaURL)
    ]
  )

  let apps = try #require(report.capabilities.first { $0.id == "apps" })
  let iap = try #require(report.capabilities.first { $0.id == "iap" })
  let upstream = try #require(report.upstreams.first)

  #expect(report.schema.version == "4.3")
  #expect(report.officialOperationCount == 1208)
  #expect(report.selectedOperationCount == 144)
  #expect(apps.selectionStatus == "partial")
  #expect(apps.selectedOperationIDs.contains("apps_getCollection"))
  #expect(iap.selectionStatus == "deferred")
  #expect(upstream.operationCount == 1208)
  #expect(upstream.missingOfficialOperationCount == 0)
  #expect(upstream.extraOperationCount == 0)
}

@Test func commandVerifiesTrackedOpenAPISelection() throws {
  let root = packageRoot()
  let stampURL = FileManager.default.temporaryDirectory
    .appending(path: "AppStoreConnectSelectedOpenAPI-\(UUID().uuidString).stamp")
  let schemaURL = root.appending(
    path: "Vendor/AppStoreConnectOpenAPI/schema/app-store-connect-openapi.json")
  let lockURL = root.appending(path: "Vendor/AppStoreConnectOpenAPI/spec.lock.json")
  let capabilitiesURL = root.appending(
    path: "Sources/AppStoreConnectPublicAPI/openapi-capabilities.json")
  let selectedURL = root.appending(path: "Sources/AppStoreConnectPublicAPI/openapi.json")

  let output = try #require(
    try GeneratorCommand().run(arguments: [
      "verify-openapi-selection",
      "--schema", schemaURL.path,
      "--lock", lockURL.path,
      "--capabilities", capabilitiesURL.path,
      "--selected", selectedURL.path,
      "--stamp", stampURL.path,
    ]))
  let stamp = try String(contentsOf: stampURL, encoding: .utf8)

  #expect(output.contains("selected OpenAPI input verified"))
  #expect(stamp.contains("\"operationCount\" : 144"))
  #expect(stamp.contains("\"schemaCount\" : 259"))
}

@Test func generationPlannerUsesBaseTraitByDefault() throws {
  let root = packageRoot()
  let generationURL = root.appending(
    path: "Sources/AppStoreConnectPublicAPI/openapi-generation.json")

  let plan = try OpenAPIGenerationPlanner().activePlan(
    generationManifestURL: generationURL,
    conditions: []
  )

  #expect(plan.activeTraits == ["PublicAPIBase"])
  #expect(plan.operationIDs.count == 144)
  #expect(plan.operationIDs.contains("apps_getCollection"))
  #expect(plan.operationIDs.contains("salesReports_getCollection"))
}

@Test func generationPlannerMergesActiveDomainTraitWithBase() throws {
  let root = packageRoot()
  let generationURL = root.appending(
    path: "Sources/AppStoreConnectPublicAPI/openapi-generation.json")

  let plan = try OpenAPIGenerationPlanner().activePlan(
    generationManifestURL: generationURL,
    conditions: ["ASC_PUBLIC_API_COMMERCE"]
  )

  #expect(plan.activeTraits == ["PublicAPIBase", "PublicAPICommerce"])
  #expect(plan.operationIDs.count > 144)
  #expect(plan.operationIDs.contains("apps_getCollection"))
  #expect(plan.operationIDs.contains("inAppPurchasesV2_getInstance"))
  #expect(plan.operationIDs.contains("subscriptionGroups_getInstance"))
}

@Test func commandFiltersActiveTraitOpenAPI() throws {
  let root = packageRoot()
  let generationURL = root.appending(
    path: "Sources/AppStoreConnectPublicAPI/openapi-generation.json")
  let outputURL = FileManager.default.temporaryDirectory
    .appending(path: "AppStoreConnectActiveOpenAPI-\(UUID().uuidString).json")
  let stampURL = FileManager.default.temporaryDirectory
    .appending(path: "AppStoreConnectActiveOpenAPI-\(UUID().uuidString).stamp")

  let output = try #require(
    try GeneratorCommand().run(arguments: [
      "filter-openapi",
      "--generation", generationURL.path,
      "--conditions", "ASC_PUBLIC_API_COMMERCE",
      "--output", outputURL.path,
      "--stamp", stampURL.path,
    ]))
  let document = try String(contentsOf: outputURL, encoding: .utf8)
  let stamp = try String(contentsOf: stampURL, encoding: .utf8)

  #expect(output.contains("filtered"))
  #expect(stamp.contains(#""activeTraits" : ["#))
  #expect(stamp.contains(#""PublicAPICommerce""#))
  #expect(document.contains(#""operationId" : "apps_getCollection""#))
  #expect(document.contains(#""operationId" : "inAppPurchasesV2_getInstance""#))
  #expect(!document.contains(#""enum" : []"#))
}

@Test func facadeEmitterGeneratesCapabilityClientsFromManifest() throws {
  let root = packageRoot()
  let capabilitiesURL = root.appending(
    path: "Sources/AppStoreConnectPublicAPI/openapi-capabilities.json")
  let selectedURL = root.appending(path: "Sources/AppStoreConnectPublicAPI/openapi.json")
  let outputURL = FileManager.default.temporaryDirectory
    .appending(path: "AppStoreConnectPublicAPIFacade-\(UUID().uuidString).swift")

  let report = try PublicAPIFacadeEmitter().writeFacade(
    capabilitiesURL: capabilitiesURL,
    selectedOpenAPIURL: selectedURL,
    outputURL: outputURL
  )
  let source = try String(contentsOf: outputURL, encoding: .utf8)

  #expect(report.capabilityCount == 7)
  #expect(report.operationCount == 144)
  #expect(source.contains("public struct AppStoreConnectPublicClient"))
  #expect(source.contains("public var apps: AppStoreConnectAppsClient"))
  #expect(source.contains("public var testFlight: AppStoreConnectTestFlightClient"))
  #expect(
    source.contains("public var certificatesProfiles: AppStoreConnectCertificatesProfilesClient"))
  #expect(source.contains("public func listApps("))
  #expect(source.contains("try await openAPI.appsGetCollection(.init("))
  #expect(source.contains("public func getApp("))
  #expect(source.contains("public func listAppStoreVersionsForApp("))
  #expect(source.contains("path: .init(id: id)"))
  #expect(source.contains("public func createAppInfoLocalization("))
  #expect(source.contains("public func listSalesReports("))
  #expect(source.contains("public func listBundleIdCapabilitiesForBundleId("))
  #expect(source.contains("public func createBundleIdCapability("))
  #expect(source.contains("query: Operations.SalesReportsGetCollection.Input.Query,"))
  #expect(source.contains("@available(*, deprecated)"))
}

@Test func commandGeneratesOpenAPIFacade() throws {
  let root = packageRoot()
  let capabilitiesURL = root.appending(
    path: "Sources/AppStoreConnectPublicAPI/openapi-capabilities.json")
  let selectedURL = root.appending(path: "Sources/AppStoreConnectPublicAPI/openapi.json")
  let outputURL = FileManager.default.temporaryDirectory
    .appending(path: "AppStoreConnectPublicAPIFacadeCommand-\(UUID().uuidString).swift")

  let output = try #require(
    try GeneratorCommand().run(arguments: [
      "generate-openapi-facade",
      "--capabilities", capabilitiesURL.path,
      "--selected", selectedURL.path,
      "--output", outputURL.path,
    ]))
  let source = try String(contentsOf: outputURL, encoding: .utf8)

  #expect(output.contains("generated OpenAPI facade"))
  #expect(output.contains("\"capabilityCount\" : 7"))
  #expect(output.contains("\"operationCount\" : 144"))
  #expect(source.contains("public struct AppStoreConnectMediaAssetsClient"))
}

@Test func commandWritesCapabilityReport() throws {
  let root = packageRoot()
  let schemaURL = root.appending(
    path: "Vendor/AppStoreConnectOpenAPI/schema/app-store-connect-openapi.json")
  let capabilitiesURL = root.appending(
    path: "Sources/AppStoreConnectPublicAPI/openapi-capabilities.json")
  let outputURL = FileManager.default.temporaryDirectory
    .appending(path: "AppStoreConnectCapabilityReport-\(UUID().uuidString).json")

  let output = try #require(
    try GeneratorCommand().run(arguments: [
      "capability-report",
      "--schema", schemaURL.path,
      "--capabilities", capabilitiesURL.path,
      "--comparison-schema", schemaURL.path,
      "--output", outputURL.path,
    ]))
  let reportText = try String(contentsOf: outputURL, encoding: .utf8)

  #expect(output.contains("wrote capability report"))
  #expect(reportText.contains("\"selectedOperationCount\" : 144"))
  #expect(reportText.contains("\"upstream\" : \"app-store-connect-openapi.json\""))
}

private func packageRoot() -> URL {
  URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .deletingLastPathComponent()
}
