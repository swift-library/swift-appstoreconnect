// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

#if ASC_EXPERIMENTAL
  import AppStoreConnectCore
  import Foundation

  public enum IrisEndpointLedger {
    public static let appStoreVersionStateChanges = IrisEndpointDescriptor(
      id: .appStoreVersionStateChanges,
      capability: .appStoreVersionHistory,
      method: .get,
      host: AppStoreConnectEnvironment.irisAPI.baseURL,
      pathTemplate: "/appStoreVersions/{appStoreVersionID}/appStoreVersionStateChanges",
      requiredHeaders: [
        "Accept",
        "Cookie",
        "Origin",
        "Referer",
        "X-Requested-With",
      ],
      sessionRequirement: "Usable App Store Connect web session cookies from WebSessionProvider.",
      requestPayload: "None.",
      responsePayload: "Observed JSON:API document with appStoreVersionStateChanges resources.",
      observationID: "appStoreVersionStateChanges-v1",
      observedAt: "2026-05-08",
      isMutating: false,
      driftPolicy: .failClosed
    )

    public static let all: [IrisEndpointDescriptor] = [
      appStoreVersionStateChanges
    ]
  }

#endif
