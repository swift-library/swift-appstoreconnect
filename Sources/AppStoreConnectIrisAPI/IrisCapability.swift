// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

#if ASC_EXPERIMENTAL
  public enum IrisCapability: String, Codable, Sendable, CaseIterable, Equatable {
    case appBundles
    case appPrivacy
    case appStoreVersionHistory
    case inAppPurchaseSubmissionQueue
    case webOnlyMetadata
  }

#endif
