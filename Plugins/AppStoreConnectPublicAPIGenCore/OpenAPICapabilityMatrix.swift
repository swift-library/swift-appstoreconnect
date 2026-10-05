// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import Foundation

public struct OpenAPICapabilityMatrix: Codable, Equatable, Sendable {
  public var schema: SchemaIdentity
  public var officialOperationCount: Int
  public var selectedOperationCount: Int
  public var upstreams: [OpenAPIUpstreamSchemaReport]
  public var capabilities: [OpenAPICapabilityMatrixEntry]
  public var unclassifiedOperationCount: Int
  public var unclassifiedTags: [String]

  public init(
    schema: SchemaIdentity,
    officialOperationCount: Int,
    selectedOperationCount: Int,
    upstreams: [OpenAPIUpstreamSchemaReport],
    capabilities: [OpenAPICapabilityMatrixEntry],
    unclassifiedOperationCount: Int,
    unclassifiedTags: [String]
  ) {
    self.schema = schema
    self.officialOperationCount = officialOperationCount
    self.selectedOperationCount = selectedOperationCount
    self.upstreams = upstreams
    self.capabilities = capabilities
    self.unclassifiedOperationCount = unclassifiedOperationCount
    self.unclassifiedTags = unclassifiedTags
  }
}

public struct OpenAPIUpstreamSchemaInput: Equatable, Sendable {
  public var name: String
  public var schemaURL: URL

  public init(name: String, schemaURL: URL) {
    self.name = name
    self.schemaURL = schemaURL
  }
}

public struct OpenAPIUpstreamSchemaReport: Codable, Equatable, Sendable {
  public var name: String
  public var path: String
  public var operationCount: Int
  public var missingOfficialOperationCount: Int
  public var extraOperationCount: Int
  public var missingOfficialOperationIDs: [String]
  public var extraOperationIDs: [String]

  public init(
    name: String,
    path: String,
    operationCount: Int,
    missingOfficialOperationCount: Int,
    extraOperationCount: Int,
    missingOfficialOperationIDs: [String],
    extraOperationIDs: [String]
  ) {
    self.name = name
    self.path = path
    self.operationCount = operationCount
    self.missingOfficialOperationCount = missingOfficialOperationCount
    self.extraOperationCount = extraOperationCount
    self.missingOfficialOperationIDs = missingOfficialOperationIDs
    self.extraOperationIDs = extraOperationIDs
  }
}

public struct OpenAPICapabilityMatrixEntry: Codable, Equatable, Sendable {
  public var id: String
  public var title: String
  public var tags: [String]
  public var officialOperationCount: Int
  public var selectedOperationCount: Int
  public var officialOperationIDs: [String]
  public var selectedOperationIDs: [String]
  public var selectionStatus: String
  public var reason: String
  public var upstreamEvidence: [OpenAPICapabilityUpstreamEvidence]

  public init(
    id: String,
    title: String,
    tags: [String],
    officialOperationCount: Int,
    selectedOperationCount: Int,
    officialOperationIDs: [String],
    selectedOperationIDs: [String],
    selectionStatus: String,
    reason: String,
    upstreamEvidence: [OpenAPICapabilityUpstreamEvidence]
  ) {
    self.id = id
    self.title = title
    self.tags = tags
    self.officialOperationCount = officialOperationCount
    self.selectedOperationCount = selectedOperationCount
    self.officialOperationIDs = officialOperationIDs
    self.selectedOperationIDs = selectedOperationIDs
    self.selectionStatus = selectionStatus
    self.reason = reason
    self.upstreamEvidence = upstreamEvidence
  }
}

public struct OpenAPICapabilityUpstreamEvidence: Codable, Equatable, Sendable {
  public var upstream: String
  public var operationCount: Int
  public var missingOperationIDs: [String]
  public var extraOperationIDs: [String]

  public init(
    upstream: String,
    operationCount: Int,
    missingOperationIDs: [String],
    extraOperationIDs: [String]
  ) {
    self.upstream = upstream
    self.operationCount = operationCount
    self.missingOperationIDs = missingOperationIDs
    self.extraOperationIDs = extraOperationIDs
  }
}

public struct OpenAPICapabilityMatrixReporter: Sendable {
  public init() {}

  public func report(
    schemaURL: URL,
    capabilitiesURL: URL,
    upstreamSchemas: [OpenAPIUpstreamSchemaInput] = []
  ) throws -> OpenAPICapabilityMatrix {
    let audit = try OpenAPISchemaAnalyzer().audit(schemaURL: schemaURL)
    let officialOperations = try OpenAPIOperationIndex(schemaURL: schemaURL)
    let manifest = try OpenAPICapabilityManifest.load(from: capabilitiesURL)
    let selectedOperationIDs = try manifest.operationIDs()
    let selectedOperationSet = Set(selectedOperationIDs)
    let officialOperationSet = Set(officialOperations.operations.map(\.operationID))
    let upstreamIndexes = try upstreamSchemas.map { input in
      (input, try OpenAPIOperationIndex(schemaURL: input.schemaURL))
    }

    let upstreamReports = upstreamIndexes.map { input, index in
      let operationIDs = Set(index.operations.map(\.operationID))
      let missing = officialOperationSet.subtracting(operationIDs).sorted()
      let extra = operationIDs.subtracting(officialOperationSet).sorted()
      return OpenAPIUpstreamSchemaReport(
        name: input.name,
        path: input.schemaURL.path,
        operationCount: operationIDs.count,
        missingOfficialOperationCount: missing.count,
        extraOperationCount: extra.count,
        missingOfficialOperationIDs: missing,
        extraOperationIDs: extra
      )
    }

    let definitions = CapabilityDefinition.defaultDefinitions
    var classifiedOperationIDs: Set<String> = []
    var classifiedTags: Set<String> = []

    let entries = definitions.map { definition -> OpenAPICapabilityMatrixEntry in
      let official = officialOperations.operations(matching: definition)
      let officialIDs = official.map(\.operationID)
      let officialIDSet = Set(officialIDs)
      let selectedIDs = officialIDs.filter { selectedOperationSet.contains($0) }
      classifiedOperationIDs.formUnion(officialIDSet)
      classifiedTags.formUnion(official.flatMap(\.tags))

      let upstreamEvidence = upstreamIndexes.map { input, index in
        let upstreamIDs = Set(index.operations(matching: definition).map(\.operationID))
        return OpenAPICapabilityUpstreamEvidence(
          upstream: input.name,
          operationCount: upstreamIDs.count,
          missingOperationIDs: officialIDSet.subtracting(upstreamIDs).sorted(),
          extraOperationIDs: upstreamIDs.subtracting(officialIDSet).sorted()
        )
      }

      return OpenAPICapabilityMatrixEntry(
        id: definition.id,
        title: definition.title,
        tags: definition.displayTags,
        officialOperationCount: officialIDs.count,
        selectedOperationCount: selectedIDs.count,
        officialOperationIDs: officialIDs,
        selectedOperationIDs: selectedIDs,
        selectionStatus: selectionStatus(
          selectedOperationCount: selectedIDs.count,
          officialOperationCount: officialIDs.count
        ),
        reason: reason(
          definition: definition,
          selectedOperationCount: selectedIDs.count,
          officialOperationCount: officialIDs.count
        ),
        upstreamEvidence: upstreamEvidence
      )
    }

    let unclassifiedOperations = officialOperations.operations
      .filter { !classifiedOperationIDs.contains($0.operationID) }
    let unclassifiedTags = Set(unclassifiedOperations.flatMap(\.tags))
      .subtracting(classifiedTags)
      .sorted()

    return OpenAPICapabilityMatrix(
      schema: audit.schema,
      officialOperationCount: officialOperations.operations.count,
      selectedOperationCount: selectedOperationIDs.count,
      upstreams: upstreamReports,
      capabilities: entries,
      unclassifiedOperationCount: unclassifiedOperations.count,
      unclassifiedTags: unclassifiedTags
    )
  }

  private func selectionStatus(selectedOperationCount: Int, officialOperationCount: Int) -> String {
    if officialOperationCount > 0, selectedOperationCount == officialOperationCount {
      return "selected"
    }
    if selectedOperationCount > 0 {
      return "partial"
    }
    return "deferred"
  }

  private func reason(
    definition: CapabilityDefinition,
    selectedOperationCount: Int,
    officialOperationCount: Int
  ) -> String {
    if officialOperationCount > 0, selectedOperationCount == officialOperationCount {
      return "Selected from the locked official schema for this capability family."
    }
    if selectedOperationCount > 0 {
      return definition.partialReason
    }
    return definition.deferredReason
  }
}

private struct OpenAPIOperationIndex {
  var operations: [IndexedOpenAPIOperation]

  init(schemaURL: URL) throws {
    let data = try Data(contentsOf: schemaURL)
    let object = try JSONSerialization.jsonObject(with: data)

    guard let root = object as? [String: Any] else {
      throw OpenAPISchemaAnalyzerError.invalidTopLevelJSON
    }

    guard let paths = root["paths"] as? [String: Any] else {
      throw OpenAPISchemaAnalyzerError.missingField("paths")
    }

    let methodNames = Set(["get", "put", "post", "delete", "options", "head", "patch", "trace"])
    var operations: [IndexedOpenAPIOperation] = []

    for path in paths.keys.sorted() {
      guard let pathItem = paths[path] as? [String: Any] else {
        continue
      }

      for method in pathItem.keys.sorted() where methodNames.contains(method) {
        guard
          let operation = pathItem[method] as? [String: Any],
          let operationID = operation["operationId"] as? String
        else {
          continue
        }

        operations.append(
          IndexedOpenAPIOperation(
            operationID: operationID,
            method: method,
            path: path,
            tags: (operation["tags"] as? [String] ?? []).sorted()
          ))
      }
    }

    self.operations = operations.sorted { lhs, rhs in
      if lhs.operationID == rhs.operationID {
        return lhs.path < rhs.path
      }
      return lhs.operationID < rhs.operationID
    }
  }

  func operations(matching definition: CapabilityDefinition) -> [IndexedOpenAPIOperation] {
    operations.filter { operation in
      operation.tags.contains { definition.matches(tag: $0) }
    }
  }
}

private struct IndexedOpenAPIOperation: Equatable {
  var operationID: String
  var method: String
  var path: String
  var tags: [String]
}

private struct CapabilityDefinition: Equatable {
  var id: String
  var title: String
  var tagNames: Set<String>
  var tagPrefixes: [String]
  var partialReason: String
  var deferredReason: String

  var displayTags: [String] {
    (tagNames.sorted() + tagPrefixes.map { "\($0)*" }).sorted()
  }

  func matches(tag: String) -> Bool {
    tagNames.contains(tag) || tagPrefixes.contains { tag.hasPrefix($0) }
  }

  static let defaultDefinitions: [CapabilityDefinition] = [
    CapabilityDefinition(
      id: "apps",
      title: "Apps, metadata, review, and release",
      tagNames: [
        "AccessibilityDeclarations",
        "AgeRatingDeclarations",
        "AppAvailabilities",
        "AppCategories",
        "AppEncryptionDeclarationDocuments",
        "AppEncryptionDeclarations",
        "AppInfoLocalizations",
        "AppInfos",
        "AppStoreReviewAttachments",
        "AppStoreReviewDetails",
        "AppStoreVersionLocalizations",
        "AppStoreVersionPhasedReleases",
        "AppStoreVersionReleaseRequests",
        "AppStoreVersionSubmissions",
        "AppStoreVersions",
        "Apps",
        "AppTags",
        "EndUserLicenseAgreements",
        "ReviewSubmissionItems",
        "ReviewSubmissions",
        "Territories",
        "TerritoryAvailabilities",
      ],
      tagPrefixes: [],
      partialReason:
        "Round 2 selects stable CRUD/list/release-metadata operations and defers relationship-heavy expansion until facade and pagination helpers exist.",
      deferredReason: "Deferred until release metadata workflows need this family."
    ),
    CapabilityDefinition(
      id: "builds",
      title: "Builds and build upload resources",
      tagNames: [
        "BuildBetaDetails",
        "BuildBetaNotifications",
        "BuildBundles",
        "BuildUploadFiles",
        "BuildUploads",
        "Builds",
        "DiagnosticSignatures",
        "PreReleaseVersions",
      ],
      tagPrefixes: [],
      partialReason:
        "Round 2 selects build/build-upload CRUD and list operations; relationship and metrics expansion waits for upload/runtime wrappers.",
      deferredReason: "Deferred until build and upload workflows need this family."
    ),
    CapabilityDefinition(
      id: "testflight",
      title: "TestFlight",
      tagNames: [],
      tagPrefixes: ["Beta"],
      partialReason:
        "Round 2 selects TestFlight CRUD/list and submission operations; relationship-heavy operations stay deferred until pagination helpers land.",
      deferredReason: "Deferred until TestFlight workflows need this family."
    ),
    CapabilityDefinition(
      id: "media-assets",
      title: "Screenshots and previews",
      tagNames: [],
      tagPrefixes: ["AppPreview", "AppScreenshot"],
      partialReason:
        "Round 2 selects screenshot and preview asset CRUD operations; relationship replacement operations wait for facade upload ergonomics.",
      deferredReason: "Deferred until media asset workflows need this family."
    ),
    CapabilityDefinition(
      id: "reports",
      title: "Sales, finance, and analytics reports",
      tagNames: [
        "AnalyticsReportInstances",
        "AnalyticsReportRequests",
        "AnalyticsReportSegments",
        "AnalyticsReports",
        "FinanceReports",
        "Metrics",
        "SalesReports",
      ],
      tagPrefixes: [],
      partialReason:
        "Round 2 selects report request and retrieval operations; metrics-specific endpoints stay deferred until report facades define output handling.",
      deferredReason: "Deferred until reporting workflows need this family."
    ),
    CapabilityDefinition(
      id: "certificates-profiles",
      title: "Certificates, identifiers, devices, and profiles",
      tagNames: [
        "BundleIdCapabilities",
        "BundleIds",
        "Certificates",
        "Devices",
        "MerchantIds",
        "PassTypeIds",
        "Profiles",
      ],
      tagPrefixes: [],
      partialReason:
        "Round 2 selects certificate/profile/device CRUD and list operations; relationship expansion waits for provisioning workflow shape.",
      deferredReason: "Deferred until provisioning workflows need this family."
    ),
    CapabilityDefinition(
      id: "users",
      title: "Users and invitations",
      tagNames: ["UserInvitations", "Users"],
      tagPrefixes: [],
      partialReason:
        "Round 2 selects user and invitation CRUD/list operations; visible-app relationship management is deferred.",
      deferredReason: "Deferred until user-management workflows need this family."
    ),
    CapabilityDefinition(
      id: "iap",
      title: "In-app purchases",
      tagNames: ["PromotedPurchases"],
      tagPrefixes: ["InAppPurchase"],
      partialReason: "Partial IAP coverage should only land with public/Iris gap ledgers.",
      deferredReason:
        "Deferred because IAP has known public/private workflow gaps that need explicit Iris separation."
    ),
    CapabilityDefinition(
      id: "subscriptions",
      title: "Subscriptions",
      tagNames: [],
      tagPrefixes: ["Subscription"],
      partialReason: "Partial subscription coverage should only land with commerce facade design.",
      deferredReason: "Deferred until commerce facade and workflow ownership are defined."
    ),
    CapabilityDefinition(
      id: "xcode-cloud",
      title: "Xcode Cloud",
      tagNames: [],
      tagPrefixes: ["Ci", "Scm"],
      partialReason: "Partial Xcode Cloud coverage should only land with workflow ownership.",
      deferredReason: "Deferred until Xcode Cloud workflow ownership is defined."
    ),
    CapabilityDefinition(
      id: "game-center",
      title: "Game Center",
      tagNames: [],
      tagPrefixes: ["GameCenter"],
      partialReason: "Partial Game Center coverage should only land with a dedicated facade.",
      deferredReason: "Deferred until Game Center has a dedicated capability facade."
    ),
    CapabilityDefinition(
      id: "app-clips",
      title: "App Clips",
      tagNames: [],
      tagPrefixes: ["AppClip"],
      partialReason: "Partial App Clips coverage should only land with release workflow needs.",
      deferredReason: "Deferred until App Clips release workflow needs are explicit."
    ),
    CapabilityDefinition(
      id: "custom-product-pages",
      title: "Custom product pages",
      tagNames: [],
      tagPrefixes: ["AppCustomProductPage"],
      partialReason:
        "Partial custom product page coverage should only land with marketing workflow needs.",
      deferredReason: "Deferred until marketing workflow needs are explicit."
    ),
    CapabilityDefinition(
      id: "app-events",
      title: "App events",
      tagNames: [],
      tagPrefixes: ["AppEvent"],
      partialReason: "Partial app event coverage should only land with marketing workflow needs.",
      deferredReason: "Deferred until app event workflow needs are explicit."
    ),
    CapabilityDefinition(
      id: "customer-reviews",
      title: "Customer reviews",
      tagNames: ["CustomerReviewResponses", "CustomerReviews"],
      tagPrefixes: [],
      partialReason:
        "Partial customer review coverage should only land with support workflow needs.",
      deferredReason: "Deferred until support workflow needs are explicit."
    ),
    CapabilityDefinition(
      id: "webhooks",
      title: "Webhooks",
      tagNames: [
        "MarketplaceWebhooks",
        "WebhookDeliveries",
        "WebhookPings",
        "Webhooks",
      ],
      tagPrefixes: [],
      partialReason:
        "Partial webhook coverage should only land with event-processing facade design.",
      deferredReason: "Deferred until event-processing facade design exists."
    ),
    CapabilityDefinition(
      id: "alternative-distribution",
      title: "Alternative distribution and marketplace",
      tagNames: [
        "MarketplaceSearchDetails"
      ],
      tagPrefixes: ["AlternativeDistribution"],
      partialReason:
        "Partial alternative distribution coverage should only land with marketplace workflow design.",
      deferredReason: "Deferred until marketplace workflow design exists."
    ),
  ]
}
