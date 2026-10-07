// swift-tools-version: 6.3
// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import PackageDescription

let publicAPITraitSwiftSettings: [SwiftSetting] = [
  .define("ASC_PUBLIC_API_BASE", .when(traits: ["PublicAPIBase"])),
  .define("ASC_PUBLIC_API_RELEASE", .when(traits: ["PublicAPIRelease"])),
  .define("ASC_PUBLIC_API_TESTFLIGHT", .when(traits: ["PublicAPITestFlight"])),
  .define("ASC_PUBLIC_API_METADATA_MEDIA", .when(traits: ["PublicAPIMetadataMedia"])),
  .define("ASC_PUBLIC_API_COMMERCE", .when(traits: ["PublicAPICommerce"])),
  .define("ASC_PUBLIC_API_REPORTS", .when(traits: ["PublicAPIReports"])),
  .define("ASC_PUBLIC_API_SIGNING_ACCESS", .when(traits: ["PublicAPISigningAccess"])),
  .define("ASC_PUBLIC_API_CLOUD", .when(traits: ["PublicAPICloud"])),
  .define("ASC_PUBLIC_API_GAME_CENTER", .when(traits: ["PublicAPIGameCenter"])),
  .define("ASC_PUBLIC_API_DISTRIBUTION", .when(traits: ["PublicAPIDistribution"])),
  .define("ASC_PUBLIC_API_FULL", .when(traits: ["PublicAPIFull"])),
]

let experimentalSwiftSettings: [SwiftSetting] = [
  .define("ASC_EXPERIMENTAL", .when(traits: ["Experimental"]))
]

let package = Package(
  name: "swift-appstoreconnect",
  platforms: [
    .iOS(.v18),
    .macOS(.v15),
    .tvOS(.v18),
    .watchOS(.v11),
    .visionOS(.v2),
  ],
  products: [
    .library(name: "AppStoreConnectCore", targets: ["AppStoreConnectCore"]),
    .library(name: "AppStoreConnectPublicAPI", targets: ["AppStoreConnectPublicAPI"]),
    .library(name: "AppStoreConnectWebSession", targets: ["AppStoreConnectWebSession"]),
    .library(name: "AppStoreConnectIrisAPI", targets: ["AppStoreConnectIrisAPI"]),
    .library(name: "AppStoreConnectWorkflow", targets: ["AppStoreConnectWorkflow"]),
    .executable(name: "appstoreconnect", targets: ["AppStoreConnectCLI"]),
  ],
  traits: [
    .default(enabledTraits: ["PublicAPIBase"]),
    .trait(
      name: "Experimental", description: "Experimental Iris API and Apple Account web sessions."),
    .trait(
      name: "PublicAPIBase",
      description: "Default typed App Store Connect Public API slice used by Workflow and CLI."
    ),
    .trait(
      name: "PublicAPIRelease",
      description: "Typed release, app metadata, review, availability, and app event API slice."
    ),
    .trait(
      name: "PublicAPITestFlight",
      description: "Typed builds and TestFlight API slice."
    ),
    .trait(
      name: "PublicAPIMetadataMedia",
      description:
        "Typed metadata localization, screenshots, previews, and custom product page API slice."
    ),
    .trait(
      name: "PublicAPICommerce",
      description: "Typed in-app purchase, subscription, price, offer, and commerce API slice."
    ),
    .trait(
      name: "PublicAPIReports",
      description: "Typed analytics, metrics, sales, and finance report API slice."
    ),
    .trait(
      name: "PublicAPISigningAccess",
      description: "Typed signing, provisioning, user, and access API slice."
    ),
    .trait(
      name: "PublicAPICloud",
      description: "Typed Xcode Cloud and source-control integration API slice."
    ),
    .trait(
      name: "PublicAPIGameCenter",
      description: "Typed Game Center API slice."
    ),
    .trait(
      name: "PublicAPIDistribution",
      description:
        "Typed alternative distribution, marketplace, webhook, territory, and agreement API slice."
    ),
    .trait(
      name: "PublicAPIFull",
      description: "Aggregate typed App Store Connect Public API coverage.",
      enabledTraits: [
        "PublicAPIBase",
        "PublicAPIRelease",
        "PublicAPITestFlight",
        "PublicAPIMetadataMedia",
        "PublicAPICommerce",
        "PublicAPIReports",
        "PublicAPISigningAccess",
        "PublicAPICloud",
        "PublicAPIGameCenter",
        "PublicAPIDistribution",
      ]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.7.0"),
    // Pin the generator so resolved consumers produce the reviewed Swift source.
    .package(url: "https://github.com/apple/swift-openapi-generator", exact: "1.12.0"),
    .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.11.0"),
    .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.3.0"),
    .package(url: "https://github.com/apple/swift-http-types", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "AppStoreConnectCore"
    ),
    .target(
      name: "AppStoreConnectPublicAPI",
      dependencies: [
        "AppStoreConnectCore",
        .product(name: "HTTPTypes", package: "swift-http-types"),
        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
        .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
      ],
      exclude: [
        "OpenAPISlices",
        "openapi-generation.json",
        "openapi.json",
      ],
      swiftSettings: publicAPITraitSwiftSettings + experimentalSwiftSettings,
      plugins: [
        .plugin(name: "AppStoreConnectOpenAPIGen")
      ]
    ),
    .target(
      name: "AppStoreConnectWebSession",
      dependencies: ["AppStoreConnectCore"],
      swiftSettings: experimentalSwiftSettings
    ),
    .target(
      name: "AppStoreConnectIrisAPI",
      dependencies: [
        "AppStoreConnectCore",
        "AppStoreConnectWebSession",
      ],
      swiftSettings: experimentalSwiftSettings
    ),
    .target(
      name: "AppStoreConnectWorkflow",
      dependencies: [
        "AppStoreConnectCore",
        "AppStoreConnectPublicAPI",
        "AppStoreConnectWebSession",
        "AppStoreConnectIrisAPI",
      ],
      swiftSettings: publicAPITraitSwiftSettings + experimentalSwiftSettings
    ),
    .executableTarget(
      name: "AppStoreConnectCLI",
      dependencies: [
        "AppStoreConnectWorkflow",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ],
      swiftSettings: publicAPITraitSwiftSettings + experimentalSwiftSettings,
      plugins: [.plugin(name: "AppStoreConnectVersionGen")]
    ),
    .target(
      name: "AppStoreConnectPublicAPIGenCore",
      path: "Plugins/AppStoreConnectPublicAPIGenCore"
    ),
    .executableTarget(
      name: "AppStoreConnectPublicAPIGen",
      dependencies: [
        "AppStoreConnectPublicAPIGenCore"
      ],
      path: "Plugins/AppStoreConnectPublicAPIGen"
    ),
    .plugin(
      name: "AppStoreConnectVersionGen",
      capability: .buildTool(),
      dependencies: ["AppStoreConnectPublicAPIGen"]
    ),
    .plugin(
      name: "AppStoreConnectOpenAPIGen",
      capability: .buildTool(),
      dependencies: [
        "AppStoreConnectPublicAPIGen",
        .product(name: "swift-openapi-generator", package: "swift-openapi-generator"),
      ]
    ),
    .testTarget(
      name: "AppStoreConnectWorkflowTests",
      dependencies: [
        "AppStoreConnectCore",
        "AppStoreConnectPublicAPI",
        "AppStoreConnectWebSession",
        "AppStoreConnectIrisAPI",
        "AppStoreConnectWorkflow",
        .product(name: "HTTPTypes", package: "swift-http-types"),
        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
      ],
      swiftSettings: publicAPITraitSwiftSettings + experimentalSwiftSettings
    ),
    .testTarget(
      name: "AppStoreConnectCoreTests",
      dependencies: ["AppStoreConnectCore"]
    ),
    .testTarget(
      name: "AppStoreConnectPublicAPITests",
      dependencies: [
        "AppStoreConnectCore",
        "AppStoreConnectPublicAPI",
        .product(name: "HTTPTypes", package: "swift-http-types"),
        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
      ]
    ),
    .testTarget(
      name: "AppStoreConnectCLITests",
      dependencies: ["AppStoreConnectCLI"],
      swiftSettings: publicAPITraitSwiftSettings + experimentalSwiftSettings
    ),
    .testTarget(
      name: "AppStoreConnectIrisAPITests",
      dependencies: [
        "AppStoreConnectCore",
        "AppStoreConnectWebSession",
        "AppStoreConnectIrisAPI",
      ],
      resources: [
        .process("Fixtures")
      ],
      swiftSettings: experimentalSwiftSettings
    ),
    .testTarget(
      name: "AppStoreConnectWebSessionTests",
      dependencies: ["AppStoreConnectWebSession"],
      swiftSettings: experimentalSwiftSettings
    ),
    .testTarget(
      name: "AppStoreConnectPublicAPIGenTests",
      dependencies: ["AppStoreConnectPublicAPIGenCore"]
    ),
  ],
  swiftLanguageModes: [.v6]
)
