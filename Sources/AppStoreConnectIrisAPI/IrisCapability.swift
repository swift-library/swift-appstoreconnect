public enum IrisCapability: String, Codable, Sendable, CaseIterable, Equatable {
    case appBundles
    case appPrivacy
    case appStoreVersionHistory
    case inAppPurchaseSubmissionQueue
    case webOnlyMetadata
}
