// swift-tools-version: 6.3
// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import PackageDescription

let package = Package(
  name: "ReleaseConsumer",
  platforms: [.iOS(.v18), .macOS(.v15), .tvOS(.v18), .watchOS(.v11), .visionOS(.v2)],
  products: [.library(name: "ReleaseConsumer", targets: ["ReleaseConsumer"])],
  dependencies: [
    .package(
      url: "https://github.com/swift-library/swift-appstoreconnect.git",
      revision: "release-candidate")
  ],
  targets: [
    .target(
      name: "ReleaseConsumer",
      dependencies: [
        .product(name: "AppStoreConnectCore", package: "swift-appstoreconnect"),
        .product(name: "AppStoreConnectPublicAPI", package: "swift-appstoreconnect"),
        .product(name: "AppStoreConnectWorkflow", package: "swift-appstoreconnect"),
        .product(name: "AppStoreConnectWebSession", package: "swift-appstoreconnect"),
        .product(name: "AppStoreConnectIrisAPI", package: "swift-appstoreconnect"),
      ])
  ]
)
