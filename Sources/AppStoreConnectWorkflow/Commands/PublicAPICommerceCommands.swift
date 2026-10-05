#if ASC_PUBLIC_API_COMMERCE
import AppStoreConnectCore
import AppStoreConnectPublicAPI
import Foundation

public struct AppStoreConnectInAppPurchaseViewInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectInAppPurchaseListInput: Codable, Sendable, Equatable {
    public var appID: String
    public var productIDs: [String]
    public var names: [String]
    public var states: [String]
    public var inAppPurchaseTypes: [String]
    public var sort: String?
    public var fields: [String]
    public var includes: [String]
    public var limit: Int?

    public init(
        appID: String,
        productIDs: [String] = [],
        names: [String] = [],
        states: [String] = [],
        inAppPurchaseTypes: [String] = [],
        sort: String? = nil,
        fields: [String] = [],
        includes: [String] = [],
        limit: Int? = nil
    ) {
        self.appID = appID
        self.productIDs = productIDs
        self.names = names
        self.states = states
        self.inAppPurchaseTypes = inAppPurchaseTypes
        self.sort = sort
        self.fields = fields
        self.includes = includes
        self.limit = limit
    }
}

public struct AppStoreConnectInAppPurchaseCreateInput: Codable, Sendable, Equatable {
    public var appID: String
    public var name: String
    public var productID: String
    public var inAppPurchaseType: String
    public var familySharable: Bool?
    public var reviewNote: String?

    public init(
        appID: String,
        name: String,
        productID: String,
        inAppPurchaseType: String,
        familySharable: Bool? = nil,
        reviewNote: String? = nil
    ) {
        self.appID = appID
        self.name = name
        self.productID = productID
        self.inAppPurchaseType = inAppPurchaseType
        self.familySharable = familySharable
        self.reviewNote = reviewNote
    }
}

public struct AppStoreConnectInAppPurchaseUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var name: String?
    public var familySharable: Bool?
    public var reviewNote: String?

    public init(id: String, name: String? = nil, familySharable: Bool? = nil, reviewNote: String? = nil) {
        self.id = id
        self.name = name
        self.familySharable = familySharable
        self.reviewNote = reviewNote
    }
}

public struct AppStoreConnectInAppPurchaseDeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectInAppPurchaseSubmitInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectPromotedPurchaseListInput: Codable, Sendable, Equatable {
    public var appID: String
    public var fields: [String]
    public var includes: [String]
    public var limit: Int?

    public init(
        appID: String,
        fields: [String] = [],
        includes: [String] = [],
        limit: Int? = nil
    ) {
        self.appID = appID
        self.fields = fields
        self.includes = includes
        self.limit = limit
    }
}

public struct AppStoreConnectPromotedPurchaseViewInput: Codable, Sendable, Equatable {
    public var id: String
    public var fields: [String]
    public var includes: [String]

    public init(id: String, fields: [String] = [], includes: [String] = []) {
        self.id = id
        self.fields = fields
        self.includes = includes
    }
}

public struct AppStoreConnectPromotedPurchaseCreateInput: Codable, Sendable, Equatable {
    public var appID: String
    public var inAppPurchaseID: String?
    public var subscriptionID: String?
    public var visibleForAllUsers: Bool
    public var enabled: Bool?

    public init(
        appID: String,
        inAppPurchaseID: String? = nil,
        subscriptionID: String? = nil,
        visibleForAllUsers: Bool,
        enabled: Bool? = nil
    ) {
        self.appID = appID
        self.inAppPurchaseID = inAppPurchaseID
        self.subscriptionID = subscriptionID
        self.visibleForAllUsers = visibleForAllUsers
        self.enabled = enabled
    }
}

public struct AppStoreConnectPromotedPurchaseUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var visibleForAllUsers: Bool?
    public var enabled: Bool?

    public init(id: String, visibleForAllUsers: Bool? = nil, enabled: Bool? = nil) {
        self.id = id
        self.visibleForAllUsers = visibleForAllUsers
        self.enabled = enabled
    }
}

public struct AppStoreConnectPromotedPurchaseDeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectSubscriptionGroupViewInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectSubscriptionGroupCreateInput: Codable, Sendable, Equatable {
    public var appID: String
    public var referenceName: String

    public init(appID: String, referenceName: String) {
        self.appID = appID
        self.referenceName = referenceName
    }
}

public struct AppStoreConnectSubscriptionGroupUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var referenceName: String?

    public init(id: String, referenceName: String? = nil) {
        self.id = id
        self.referenceName = referenceName
    }
}

public struct AppStoreConnectSubscriptionGroupDeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectSubscriptionListInput: Codable, Sendable, Equatable {
    public var groupID: String
    public var productIDs: [String]
    public var names: [String]
    public var states: [String]
    public var sort: String?
    public var limit: Int?

    public init(
        groupID: String,
        productIDs: [String] = [],
        names: [String] = [],
        states: [String] = [],
        sort: String? = nil,
        limit: Int? = nil
    ) {
        self.groupID = groupID
        self.productIDs = productIDs
        self.names = names
        self.states = states
        self.sort = sort
        self.limit = limit
    }
}

public struct AppStoreConnectSubscriptionViewInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectSubscriptionCreateInput: Codable, Sendable, Equatable {
    public var groupID: String
    public var name: String
    public var productID: String
    public var subscriptionPeriod: String?
    public var groupLevel: Int?
    public var familySharable: Bool?
    public var reviewNote: String?

    public init(
        groupID: String,
        name: String,
        productID: String,
        subscriptionPeriod: String? = nil,
        groupLevel: Int? = nil,
        familySharable: Bool? = nil,
        reviewNote: String? = nil
    ) {
        self.groupID = groupID
        self.name = name
        self.productID = productID
        self.subscriptionPeriod = subscriptionPeriod
        self.groupLevel = groupLevel
        self.familySharable = familySharable
        self.reviewNote = reviewNote
    }
}

public struct AppStoreConnectSubscriptionUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var name: String?
    public var subscriptionPeriod: String?
    public var groupLevel: Int?
    public var familySharable: Bool?
    public var reviewNote: String?

    public init(
        id: String,
        name: String? = nil,
        subscriptionPeriod: String? = nil,
        groupLevel: Int? = nil,
        familySharable: Bool? = nil,
        reviewNote: String? = nil
    ) {
        self.id = id
        self.name = name
        self.subscriptionPeriod = subscriptionPeriod
        self.groupLevel = groupLevel
        self.familySharable = familySharable
        self.reviewNote = reviewNote
    }
}

public struct AppStoreConnectSubscriptionDeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectSubscriptionSubmitInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectInAppPurchaseLocalizationListInput: Codable, Sendable, Equatable {
    public var inAppPurchaseID: String
    public var limit: Int?

    public init(inAppPurchaseID: String, limit: Int? = nil) {
        self.inAppPurchaseID = inAppPurchaseID
        self.limit = limit
    }
}

public struct AppStoreConnectInAppPurchaseLocalizationViewInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectInAppPurchaseLocalizationCreateInput: Codable, Sendable, Equatable {
    public var inAppPurchaseID: String
    public var locale: String
    public var name: String
    public var description: String?

    public init(inAppPurchaseID: String, locale: String, name: String, description: String? = nil) {
        self.inAppPurchaseID = inAppPurchaseID
        self.locale = locale
        self.name = name
        self.description = description
    }
}

public struct AppStoreConnectInAppPurchaseLocalizationUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var name: String?
    public var description: String?

    public init(id: String, name: String? = nil, description: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
    }
}

public struct AppStoreConnectInAppPurchaseLocalizationDeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectSubscriptionLocalizationListInput: Codable, Sendable, Equatable {
    public var subscriptionID: String
    public var limit: Int?

    public init(subscriptionID: String, limit: Int? = nil) {
        self.subscriptionID = subscriptionID
        self.limit = limit
    }
}

public struct AppStoreConnectSubscriptionLocalizationViewInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectSubscriptionLocalizationCreateInput: Codable, Sendable, Equatable {
    public var subscriptionID: String
    public var locale: String
    public var name: String
    public var description: String?

    public init(subscriptionID: String, locale: String, name: String, description: String? = nil) {
        self.subscriptionID = subscriptionID
        self.locale = locale
        self.name = name
        self.description = description
    }
}

public struct AppStoreConnectSubscriptionLocalizationUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var name: String?
    public var description: String?

    public init(id: String, name: String? = nil, description: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
    }
}

public struct AppStoreConnectSubscriptionLocalizationDeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectSubscriptionGroupLocalizationListInput: Codable, Sendable, Equatable {
    public var groupID: String
    public var limit: Int?

    public init(groupID: String, limit: Int? = nil) {
        self.groupID = groupID
        self.limit = limit
    }
}

public struct AppStoreConnectSubscriptionGroupLocalizationViewInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectSubscriptionGroupLocalizationCreateInput: Codable, Sendable, Equatable {
    public var groupID: String
    public var locale: String
    public var name: String
    public var customAppName: String?

    public init(groupID: String, locale: String, name: String, customAppName: String? = nil) {
        self.groupID = groupID
        self.locale = locale
        self.name = name
        self.customAppName = customAppName
    }
}

public struct AppStoreConnectSubscriptionGroupLocalizationUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var name: String?
    public var customAppName: String?

    public init(id: String, name: String? = nil, customAppName: String? = nil) {
        self.id = id
        self.name = name
        self.customAppName = customAppName
    }
}

public struct AppStoreConnectSubscriptionGroupLocalizationDeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectWinBackOfferListInput: Codable, Sendable, Equatable {
    public var subscriptionID: String
    public var limit: Int?

    public init(subscriptionID: String, limit: Int? = nil) {
        self.subscriptionID = subscriptionID
        self.limit = limit
    }
}

public struct AppStoreConnectWinBackOfferViewInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectWinBackOfferCreateInput: Codable, Sendable, Equatable {
    public var subscriptionID: String
    public var referenceName: String
    public var offerID: String
    public var duration: String
    public var offerMode: String
    public var periodCount: Int
    public var paidSubscriptionDurationMonths: Int
    public var lastSubscribedMinMonths: Int
    public var lastSubscribedMaxMonths: Int
    public var waitBetweenOffersMonths: Int?
    public var startDate: String
    public var endDate: String?
    public var priority: String
    public var promotionIntent: String?
    public var priceIDs: [String]

    public init(
        subscriptionID: String,
        referenceName: String,
        offerID: String,
        duration: String,
        offerMode: String,
        periodCount: Int,
        paidSubscriptionDurationMonths: Int,
        lastSubscribedMinMonths: Int,
        lastSubscribedMaxMonths: Int,
        waitBetweenOffersMonths: Int? = nil,
        startDate: String,
        endDate: String? = nil,
        priority: String,
        promotionIntent: String? = nil,
        priceIDs: [String]
    ) {
        self.subscriptionID = subscriptionID
        self.referenceName = referenceName
        self.offerID = offerID
        self.duration = duration
        self.offerMode = offerMode
        self.periodCount = periodCount
        self.paidSubscriptionDurationMonths = paidSubscriptionDurationMonths
        self.lastSubscribedMinMonths = lastSubscribedMinMonths
        self.lastSubscribedMaxMonths = lastSubscribedMaxMonths
        self.waitBetweenOffersMonths = waitBetweenOffersMonths
        self.startDate = startDate
        self.endDate = endDate
        self.priority = priority
        self.promotionIntent = promotionIntent
        self.priceIDs = priceIDs
    }
}

public struct AppStoreConnectWinBackOfferUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var paidSubscriptionDurationMonths: Int?
    public var lastSubscribedMinMonths: Int?
    public var lastSubscribedMaxMonths: Int?
    public var waitBetweenOffersMonths: Int?
    public var startDate: String?
    public var endDate: String?
    public var priority: String?
    public var promotionIntent: String?

    public init(
        id: String,
        paidSubscriptionDurationMonths: Int? = nil,
        lastSubscribedMinMonths: Int? = nil,
        lastSubscribedMaxMonths: Int? = nil,
        waitBetweenOffersMonths: Int? = nil,
        startDate: String? = nil,
        endDate: String? = nil,
        priority: String? = nil,
        promotionIntent: String? = nil
    ) {
        self.id = id
        self.paidSubscriptionDurationMonths = paidSubscriptionDurationMonths
        self.lastSubscribedMinMonths = lastSubscribedMinMonths
        self.lastSubscribedMaxMonths = lastSubscribedMaxMonths
        self.waitBetweenOffersMonths = waitBetweenOffersMonths
        self.startDate = startDate
        self.endDate = endDate
        self.priority = priority
        self.promotionIntent = promotionIntent
    }
}

public struct AppStoreConnectWinBackOfferDeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectAppPricePointListInput: Codable, Sendable, Equatable {
    public var appID: String
    public var territories: [String]
    public var fields: [String]
    public var territoryFields: [String]
    public var includeApp: Bool
    public var includeTerritory: Bool
    public var limit: Int?

    public init(
        appID: String,
        territories: [String] = [],
        fields: [String] = [],
        territoryFields: [String] = [],
        includeApp: Bool = false,
        includeTerritory: Bool = false,
        limit: Int? = nil
    ) {
        self.appID = appID
        self.territories = territories
        self.fields = fields
        self.territoryFields = territoryFields
        self.includeApp = includeApp
        self.includeTerritory = includeTerritory
        self.limit = limit
    }
}

public struct AppStoreConnectAppPriceScheduleCurrentInput: Codable, Sendable, Equatable {
    public var appID: String
    public var fields: [String]
    public var priceFields: [String]
    public var territoryFields: [String]
    public var includeApp: Bool
    public var includeBaseTerritory: Bool
    public var includeManualPrices: Bool
    public var includeAutomaticPrices: Bool
    public var manualPricesLimit: Int?
    public var automaticPricesLimit: Int?

    public init(
        appID: String,
        fields: [String] = [],
        priceFields: [String] = [],
        territoryFields: [String] = [],
        includeApp: Bool = false,
        includeBaseTerritory: Bool = false,
        includeManualPrices: Bool = false,
        includeAutomaticPrices: Bool = false,
        manualPricesLimit: Int? = nil,
        automaticPricesLimit: Int? = nil
    ) {
        self.appID = appID
        self.fields = fields
        self.priceFields = priceFields
        self.territoryFields = territoryFields
        self.includeApp = includeApp
        self.includeBaseTerritory = includeBaseTerritory
        self.includeManualPrices = includeManualPrices
        self.includeAutomaticPrices = includeAutomaticPrices
        self.manualPricesLimit = manualPricesLimit
        self.automaticPricesLimit = automaticPricesLimit
    }
}

public struct AppStoreConnectInAppPurchaseSummary: Codable, Sendable, Equatable {
    public var id: String
    public var name: String?
    public var productID: String?
    public var inAppPurchaseType: String?
    public var state: String?
    public var familySharable: Bool?

    public init(
        id: String,
        name: String? = nil,
        productID: String? = nil,
        inAppPurchaseType: String? = nil,
        state: String? = nil,
        familySharable: Bool? = nil
    ) {
        self.id = id
        self.name = name
        self.productID = productID
        self.inAppPurchaseType = inAppPurchaseType
        self.state = state
        self.familySharable = familySharable
    }
}

public struct AppStoreConnectPromotedPurchaseSummary: Codable, Sendable, Equatable {
    public var id: String
    public var visibleForAllUsers: Bool?
    public var enabled: Bool?
    public var state: String?
    public var inAppPurchaseID: String?
    public var subscriptionID: String?

    public init(
        id: String,
        visibleForAllUsers: Bool? = nil,
        enabled: Bool? = nil,
        state: String? = nil,
        inAppPurchaseID: String? = nil,
        subscriptionID: String? = nil
    ) {
        self.id = id
        self.visibleForAllUsers = visibleForAllUsers
        self.enabled = enabled
        self.state = state
        self.inAppPurchaseID = inAppPurchaseID
        self.subscriptionID = subscriptionID
    }
}

public struct AppStoreConnectSubscriptionGroupSummary: Codable, Sendable, Equatable {
    public var id: String
    public var referenceName: String?

    public init(id: String, referenceName: String? = nil) {
        self.id = id
        self.referenceName = referenceName
    }
}

public struct AppStoreConnectSubscriptionSummary: Codable, Sendable, Equatable {
    public var id: String
    public var name: String?
    public var productID: String?
    public var subscriptionPeriod: String?
    public var state: String?
    public var groupLevel: Int?
    public var familySharable: Bool?

    public init(
        id: String,
        name: String? = nil,
        productID: String? = nil,
        subscriptionPeriod: String? = nil,
        state: String? = nil,
        groupLevel: Int? = nil,
        familySharable: Bool? = nil
    ) {
        self.id = id
        self.name = name
        self.productID = productID
        self.subscriptionPeriod = subscriptionPeriod
        self.state = state
        self.groupLevel = groupLevel
        self.familySharable = familySharable
    }
}

public struct AppStoreConnectCommerceSubmissionSummary: Codable, Sendable, Equatable {
    public var id: String
    public var resourceType: String
    public var targetID: String

    public init(id: String, resourceType: String, targetID: String) {
        self.id = id
        self.resourceType = resourceType
        self.targetID = targetID
    }
}

public struct AppStoreConnectCommerceLocalizationSummary: Codable, Sendable, Equatable {
    public var id: String
    public var resourceType: String
    public var locale: String?
    public var name: String?
    public var description: String?
    public var customAppName: String?
    public var parentResourceType: String?
    public var parentID: String?

    public init(
        id: String,
        resourceType: String,
        locale: String? = nil,
        name: String? = nil,
        description: String? = nil,
        customAppName: String? = nil,
        parentResourceType: String? = nil,
        parentID: String? = nil
    ) {
        self.id = id
        self.resourceType = resourceType
        self.locale = locale
        self.name = name
        self.description = description
        self.customAppName = customAppName
        self.parentResourceType = parentResourceType
        self.parentID = parentID
    }
}

public struct AppStoreConnectAppPricePointSummary: Codable, Sendable, Equatable {
    public var id: String
    public var customerPrice: String?
    public var proceeds: String?
    public var appID: String?
    public var territoryID: String?

    public init(
        id: String,
        customerPrice: String? = nil,
        proceeds: String? = nil,
        appID: String? = nil,
        territoryID: String? = nil
    ) {
        self.id = id
        self.customerPrice = customerPrice
        self.proceeds = proceeds
        self.appID = appID
        self.territoryID = territoryID
    }
}

public struct AppStoreConnectWinBackOfferSummary: Codable, Sendable, Equatable {
    public var id: String
    public var referenceName: String?
    public var offerID: String?
    public var duration: String?
    public var offerMode: String?
    public var periodCount: Int?
    public var paidSubscriptionDurationMonths: Int?
    public var lastSubscribedMinMonths: Int?
    public var lastSubscribedMaxMonths: Int?
    public var waitBetweenOffersMonths: Int?
    public var startDate: String?
    public var endDate: String?
    public var priority: String?
    public var promotionIntent: String?
    public var priceIDs: [String]

    public init(
        id: String,
        referenceName: String? = nil,
        offerID: String? = nil,
        duration: String? = nil,
        offerMode: String? = nil,
        periodCount: Int? = nil,
        paidSubscriptionDurationMonths: Int? = nil,
        lastSubscribedMinMonths: Int? = nil,
        lastSubscribedMaxMonths: Int? = nil,
        waitBetweenOffersMonths: Int? = nil,
        startDate: String? = nil,
        endDate: String? = nil,
        priority: String? = nil,
        promotionIntent: String? = nil,
        priceIDs: [String] = []
    ) {
        self.id = id
        self.referenceName = referenceName
        self.offerID = offerID
        self.duration = duration
        self.offerMode = offerMode
        self.periodCount = periodCount
        self.paidSubscriptionDurationMonths = paidSubscriptionDurationMonths
        self.lastSubscribedMinMonths = lastSubscribedMinMonths
        self.lastSubscribedMaxMonths = lastSubscribedMaxMonths
        self.waitBetweenOffersMonths = waitBetweenOffersMonths
        self.startDate = startDate
        self.endDate = endDate
        self.priority = priority
        self.promotionIntent = promotionIntent
        self.priceIDs = priceIDs
    }
}

public struct AppStoreConnectAppPriceScheduleSummary: Codable, Sendable, Equatable {
    public var id: String
    public var appID: String?
    public var baseTerritoryID: String?
    public var manualPriceIDs: [String]
    public var automaticPriceIDs: [String]

    public init(
        id: String,
        appID: String? = nil,
        baseTerritoryID: String? = nil,
        manualPriceIDs: [String] = [],
        automaticPriceIDs: [String] = []
    ) {
        self.id = id
        self.appID = appID
        self.baseTerritoryID = baseTerritoryID
        self.manualPriceIDs = manualPriceIDs
        self.automaticPriceIDs = automaticPriceIDs
    }
}

public typealias AppStoreConnectInAppPurchaseListResult = AppStoreConnectListResult<AppStoreConnectInAppPurchaseSummary>
public typealias AppStoreConnectInAppPurchaseResult = AppStoreConnectResourceResult<AppStoreConnectInAppPurchaseSummary>
public typealias AppStoreConnectPromotedPurchaseListResult = AppStoreConnectListResult<AppStoreConnectPromotedPurchaseSummary>
public typealias AppStoreConnectPromotedPurchaseResult = AppStoreConnectResourceResult<AppStoreConnectPromotedPurchaseSummary>
public typealias AppStoreConnectSubscriptionGroupResult = AppStoreConnectResourceResult<AppStoreConnectSubscriptionGroupSummary>
public typealias AppStoreConnectSubscriptionListResult = AppStoreConnectListResult<AppStoreConnectSubscriptionSummary>
public typealias AppStoreConnectSubscriptionResult = AppStoreConnectResourceResult<AppStoreConnectSubscriptionSummary>
public typealias AppStoreConnectCommerceSubmissionResult = AppStoreConnectResourceResult<AppStoreConnectCommerceSubmissionSummary>
public typealias AppStoreConnectCommerceLocalizationListResult = AppStoreConnectListResult<AppStoreConnectCommerceLocalizationSummary>
public typealias AppStoreConnectCommerceLocalizationResult = AppStoreConnectResourceResult<AppStoreConnectCommerceLocalizationSummary>
public typealias AppStoreConnectWinBackOfferListResult = AppStoreConnectListResult<AppStoreConnectWinBackOfferSummary>
public typealias AppStoreConnectWinBackOfferResult = AppStoreConnectResourceResult<AppStoreConnectWinBackOfferSummary>
public typealias AppStoreConnectAppPricePointListResult = AppStoreConnectListResult<AppStoreConnectAppPricePointSummary>
public typealias AppStoreConnectAppPriceScheduleResult = AppStoreConnectResourceResult<AppStoreConnectAppPriceScheduleSummary>

public extension PublicAPIReadCommands {
    func listInAppPurchases(_ input: AppStoreConnectInAppPurchaseListInput) async throws -> AppStoreConnectInAppPurchaseListResult {
        let output = try await client.openAPI.appsInAppPurchasesV2GetToManyRelated(.init(
            path: .init(id: input.appID),
            query: try inAppPurchaseListQuery(from: input)
        ))

        switch output {
        case let .ok(response):
            let body = try response.body.json
            return AppStoreConnectInAppPurchaseListResult(
                data: body.data.map(Self.inAppPurchaseSummary),
                next: body.links.next
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected in-app purchases response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "In-app purchases list did not return 200 ok.")
        }
    }

    func getInAppPurchase(_ input: AppStoreConnectInAppPurchaseViewInput) async throws -> AppStoreConnectInAppPurchaseResult {
        let output = try await client.openAPI.inAppPurchasesV2GetInstance(.init(path: .init(id: input.id)))

        switch output {
        case let .ok(response):
            return AppStoreConnectInAppPurchaseResult(data: Self.inAppPurchaseSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected in-app purchase response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "In-app purchase lookup did not return 200 ok.")
        }
    }

    func listPromotedPurchases(_ input: AppStoreConnectPromotedPurchaseListInput) async throws -> AppStoreConnectPromotedPurchaseListResult {
        let output = try await client.openAPI.appsPromotedPurchasesGetToManyRelated(.init(
            path: .init(id: input.appID),
            query: try promotedPurchaseListQuery(from: input)
        ))

        switch output {
        case let .ok(response):
            let body = try response.body.json
            return AppStoreConnectPromotedPurchaseListResult(
                data: body.data.map(Self.promotedPurchaseSummary),
                next: body.links.next
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected promoted purchases response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Promoted purchases list did not return 200 ok.")
        }
    }

    func getPromotedPurchase(_ input: AppStoreConnectPromotedPurchaseViewInput) async throws -> AppStoreConnectPromotedPurchaseResult {
        let output = try await client.openAPI.promotedPurchasesGetInstance(.init(
            path: .init(id: input.id),
            query: try promotedPurchaseViewQuery(from: input)
        ))

        switch output {
        case let .ok(response):
            return AppStoreConnectPromotedPurchaseResult(data: Self.promotedPurchaseSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected promoted purchase response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Promoted purchase lookup did not return 200 ok.")
        }
    }

    func getSubscriptionGroup(_ input: AppStoreConnectSubscriptionGroupViewInput) async throws -> AppStoreConnectSubscriptionGroupResult {
        let output = try await client.openAPI.subscriptionGroupsGetInstance(.init(path: .init(id: input.id)))

        switch output {
        case let .ok(response):
            return AppStoreConnectSubscriptionGroupResult(data: Self.subscriptionGroupSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected subscription group response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Subscription group lookup did not return 200 ok.")
        }
    }

    func listSubscriptions(_ input: AppStoreConnectSubscriptionListInput) async throws -> AppStoreConnectSubscriptionListResult {
        let output = try await client.openAPI.subscriptionGroupsSubscriptionsGetToManyRelated(.init(
            path: .init(id: input.groupID),
            query: try subscriptionListQuery(from: input)
        ))

        switch output {
        case let .ok(response):
            let body = try response.body.json
            return AppStoreConnectSubscriptionListResult(
                data: body.data.map(Self.subscriptionSummary),
                next: body.links.next
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected subscriptions response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Subscriptions list did not return 200 ok.")
        }
    }

    func getSubscription(_ input: AppStoreConnectSubscriptionViewInput) async throws -> AppStoreConnectSubscriptionResult {
        let output = try await client.openAPI.subscriptionsGetInstance(.init(path: .init(id: input.id)))

        switch output {
        case let .ok(response):
            return AppStoreConnectSubscriptionResult(data: Self.subscriptionSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected subscription response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Subscription lookup did not return 200 ok.")
        }
    }

    func listInAppPurchaseLocalizations(
        _ input: AppStoreConnectInAppPurchaseLocalizationListInput
    ) async throws -> AppStoreConnectCommerceLocalizationListResult {
        var query = Operations.InAppPurchasesV2InAppPurchaseLocalizationsGetToManyRelated.Input.Query()
        query.limit = input.limit
        let output = try await client.openAPI.inAppPurchasesV2InAppPurchaseLocalizationsGetToManyRelated(.init(
            path: .init(id: input.inAppPurchaseID),
            query: query
        ))

        switch output {
        case let .ok(response):
            let body = try response.body.json
            return AppStoreConnectCommerceLocalizationListResult(
                data: body.data.map(Self.inAppPurchaseLocalizationSummary),
                next: body.links.next
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected IAP localizations response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "IAP localizations list did not return 200 ok.")
        }
    }

    func getInAppPurchaseLocalization(
        _ input: AppStoreConnectInAppPurchaseLocalizationViewInput
    ) async throws -> AppStoreConnectCommerceLocalizationResult {
        let output = try await client.openAPI.inAppPurchaseLocalizationsGetInstance(.init(
            path: .init(id: input.id),
            query: .init()
        ))

        switch output {
        case let .ok(response):
            return AppStoreConnectCommerceLocalizationResult(data: Self.inAppPurchaseLocalizationSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected IAP localization response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "IAP localization lookup did not return 200 ok.")
        }
    }

    func listSubscriptionLocalizations(
        _ input: AppStoreConnectSubscriptionLocalizationListInput
    ) async throws -> AppStoreConnectCommerceLocalizationListResult {
        var query = Operations.SubscriptionsSubscriptionLocalizationsGetToManyRelated.Input.Query()
        query.limit = input.limit
        let output = try await client.openAPI.subscriptionsSubscriptionLocalizationsGetToManyRelated(.init(
            path: .init(id: input.subscriptionID),
            query: query
        ))

        switch output {
        case let .ok(response):
            let body = try response.body.json
            return AppStoreConnectCommerceLocalizationListResult(
                data: body.data.map(Self.subscriptionLocalizationSummary),
                next: body.links.next
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected subscription localizations response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Subscription localizations list did not return 200 ok.")
        }
    }

    func getSubscriptionLocalization(
        _ input: AppStoreConnectSubscriptionLocalizationViewInput
    ) async throws -> AppStoreConnectCommerceLocalizationResult {
        let output = try await client.openAPI.subscriptionLocalizationsGetInstance(.init(
            path: .init(id: input.id),
            query: .init()
        ))

        switch output {
        case let .ok(response):
            return AppStoreConnectCommerceLocalizationResult(data: Self.subscriptionLocalizationSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected subscription localization response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Subscription localization lookup did not return 200 ok.")
        }
    }

    func listSubscriptionGroupLocalizations(
        _ input: AppStoreConnectSubscriptionGroupLocalizationListInput
    ) async throws -> AppStoreConnectCommerceLocalizationListResult {
        var query = Operations.SubscriptionGroupsSubscriptionGroupLocalizationsGetToManyRelated.Input.Query()
        query.limit = input.limit
        let output = try await client.openAPI.subscriptionGroupsSubscriptionGroupLocalizationsGetToManyRelated(.init(
            path: .init(id: input.groupID),
            query: query
        ))

        switch output {
        case let .ok(response):
            let body = try response.body.json
            return AppStoreConnectCommerceLocalizationListResult(
                data: body.data.map(Self.subscriptionGroupLocalizationSummary),
                next: body.links.next
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected subscription group localizations response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Subscription group localizations list did not return 200 ok.")
        }
    }

    func getSubscriptionGroupLocalization(
        _ input: AppStoreConnectSubscriptionGroupLocalizationViewInput
    ) async throws -> AppStoreConnectCommerceLocalizationResult {
        let output = try await client.openAPI.subscriptionGroupLocalizationsGetInstance(.init(
            path: .init(id: input.id),
            query: .init()
        ))

        switch output {
        case let .ok(response):
            return AppStoreConnectCommerceLocalizationResult(data: Self.subscriptionGroupLocalizationSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected subscription group localization response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Subscription group localization lookup did not return 200 ok.")
        }
    }

    func listWinBackOffers(_ input: AppStoreConnectWinBackOfferListInput) async throws -> AppStoreConnectWinBackOfferListResult {
        var query = Operations.SubscriptionsWinBackOffersGetToManyRelated.Input.Query()
        query.limit = input.limit
        let output = try await client.openAPI.subscriptionsWinBackOffersGetToManyRelated(.init(
            path: .init(id: input.subscriptionID),
            query: query
        ))

        switch output {
        case let .ok(response):
            let body = try response.body.json
            return AppStoreConnectWinBackOfferListResult(
                data: body.data.map(Self.winBackOfferSummary),
                next: body.links.next
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected win-back offers response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Win-back offers list did not return 200 ok.")
        }
    }

    func getWinBackOffer(_ input: AppStoreConnectWinBackOfferViewInput) async throws -> AppStoreConnectWinBackOfferResult {
        let output = try await client.openAPI.winBackOffersGetInstance(.init(
            path: .init(id: input.id),
            query: .init()
        ))

        switch output {
        case let .ok(response):
            return AppStoreConnectWinBackOfferResult(data: Self.winBackOfferSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected win-back offer response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Win-back offer lookup did not return 200 ok.")
        }
    }

    func listAppPricePoints(_ input: AppStoreConnectAppPricePointListInput) async throws -> AppStoreConnectAppPricePointListResult {
        let output = try await client.openAPI.appsAppPricePointsGetToManyRelated(.init(
            path: .init(id: input.appID),
            query: try appPricePointListQuery(from: input)
        ))

        switch output {
        case let .ok(response):
            let body = try response.body.json
            return AppStoreConnectAppPricePointListResult(
                data: body.data.map(Self.appPricePointSummary),
                next: body.links.next
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected app price points response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "App price points list did not return 200 ok.")
        }
    }

    func getCurrentAppPriceSchedule(
        _ input: AppStoreConnectAppPriceScheduleCurrentInput
    ) async throws -> AppStoreConnectAppPriceScheduleResult {
        let output = try await client.openAPI.appsAppPriceScheduleGetToOneRelated(.init(
            path: .init(id: input.appID),
            query: try appPriceScheduleCurrentQuery(from: input)
        ))

        switch output {
        case let .ok(response):
            return AppStoreConnectAppPriceScheduleResult(data: Self.appPriceScheduleSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected app price schedule response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "App price schedule lookup did not return 200 ok.")
        }
    }

    fileprivate static func inAppPurchaseSummary(_ resource: Components.Schemas.InAppPurchaseV2) -> AppStoreConnectInAppPurchaseSummary {
        AppStoreConnectInAppPurchaseSummary(
            id: resource.id,
            name: resource.attributes?.name,
            productID: resource.attributes?.productId,
            inAppPurchaseType: resource.attributes?.inAppPurchaseType?.rawValue,
            state: resource.attributes?.state?.rawValue,
            familySharable: resource.attributes?.familySharable
        )
    }

    fileprivate static func promotedPurchaseSummary(_ resource: Components.Schemas.PromotedPurchase) -> AppStoreConnectPromotedPurchaseSummary {
        AppStoreConnectPromotedPurchaseSummary(
            id: resource.id,
            visibleForAllUsers: resource.attributes?.visibleForAllUsers,
            enabled: resource.attributes?.enabled,
            state: resource.attributes?.state?.rawValue,
            inAppPurchaseID: resource.relationships?.inAppPurchaseV2?.data?.id,
            subscriptionID: resource.relationships?.subscription?.data?.id
        )
    }

    fileprivate static func appPricePointSummary(_ resource: Components.Schemas.AppPricePointV3) -> AppStoreConnectAppPricePointSummary {
        AppStoreConnectAppPricePointSummary(
            id: resource.id,
            customerPrice: resource.attributes?.customerPrice,
            proceeds: resource.attributes?.proceeds,
            appID: resource.relationships?.app?.data?.id,
            territoryID: resource.relationships?.territory?.data?.id
        )
    }

    fileprivate static func appPriceScheduleSummary(_ resource: Components.Schemas.AppPriceSchedule) -> AppStoreConnectAppPriceScheduleSummary {
        AppStoreConnectAppPriceScheduleSummary(
            id: resource.id,
            appID: resource.relationships?.app?.data?.id,
            baseTerritoryID: resource.relationships?.baseTerritory?.data?.id,
            manualPriceIDs: resource.relationships?.manualPrices?.data?.map(\.id) ?? [],
            automaticPriceIDs: resource.relationships?.automaticPrices?.data?.map(\.id) ?? []
        )
    }

    fileprivate static func subscriptionGroupSummary(_ resource: Components.Schemas.SubscriptionGroup) -> AppStoreConnectSubscriptionGroupSummary {
        AppStoreConnectSubscriptionGroupSummary(
            id: resource.id,
            referenceName: resource.attributes?.referenceName
        )
    }

    fileprivate static func subscriptionSummary(_ resource: Components.Schemas.Subscription) -> AppStoreConnectSubscriptionSummary {
        AppStoreConnectSubscriptionSummary(
            id: resource.id,
            name: resource.attributes?.name,
            productID: resource.attributes?.productId,
            subscriptionPeriod: resource.attributes?.subscriptionPeriod?.rawValue,
            state: resource.attributes?.state?.rawValue,
            groupLevel: resource.attributes?.groupLevel,
            familySharable: resource.attributes?.familySharable
        )
    }

    fileprivate static func inAppPurchaseLocalizationSummary(
        _ resource: Components.Schemas.InAppPurchaseLocalization
    ) -> AppStoreConnectCommerceLocalizationSummary {
        AppStoreConnectCommerceLocalizationSummary(
            id: resource.id,
            resourceType: "inAppPurchaseLocalizations",
            locale: resource.attributes?.locale,
            name: resource.attributes?.name,
            description: resource.attributes?.description,
            parentResourceType: "inAppPurchases",
            parentID: resource.relationships?.inAppPurchaseV2?.data?.id
        )
    }

    fileprivate static func subscriptionLocalizationSummary(
        _ resource: Components.Schemas.SubscriptionLocalization
    ) -> AppStoreConnectCommerceLocalizationSummary {
        AppStoreConnectCommerceLocalizationSummary(
            id: resource.id,
            resourceType: "subscriptionLocalizations",
            locale: resource.attributes?.locale,
            name: resource.attributes?.name,
            description: resource.attributes?.description,
            parentResourceType: "subscriptions",
            parentID: resource.relationships?.subscription?.data?.id
        )
    }

    fileprivate static func subscriptionGroupLocalizationSummary(
        _ resource: Components.Schemas.SubscriptionGroupLocalization
    ) -> AppStoreConnectCommerceLocalizationSummary {
        AppStoreConnectCommerceLocalizationSummary(
            id: resource.id,
            resourceType: "subscriptionGroupLocalizations",
            locale: resource.attributes?.locale,
            name: resource.attributes?.name,
            customAppName: resource.attributes?.customAppName,
            parentResourceType: "subscriptionGroups",
            parentID: resource.relationships?.subscriptionGroup?.data?.id
        )
    }

    fileprivate static func winBackOfferSummary(_ resource: Components.Schemas.WinBackOffer) -> AppStoreConnectWinBackOfferSummary {
        AppStoreConnectWinBackOfferSummary(
            id: resource.id,
            referenceName: resource.attributes?.referenceName,
            offerID: resource.attributes?.offerId,
            duration: resource.attributes?.duration?.rawValue,
            offerMode: resource.attributes?.offerMode?.rawValue,
            periodCount: resource.attributes?.periodCount,
            paidSubscriptionDurationMonths: resource.attributes?.customerEligibilityPaidSubscriptionDurationInMonths,
            lastSubscribedMinMonths: resource.attributes?.customerEligibilityTimeSinceLastSubscribedInMonths?.minimum,
            lastSubscribedMaxMonths: resource.attributes?.customerEligibilityTimeSinceLastSubscribedInMonths?.maximum,
            waitBetweenOffersMonths: resource.attributes?.customerEligibilityWaitBetweenOffersInMonths,
            startDate: resource.attributes?.startDate,
            endDate: resource.attributes?.endDate,
            priority: resource.attributes?.priority?.rawValue,
            promotionIntent: resource.attributes?.promotionIntent?.rawValue,
            priceIDs: resource.relationships?.prices?.data?.map(\.id) ?? []
        )
    }

    private func inAppPurchaseListQuery(
        from input: AppStoreConnectInAppPurchaseListInput
    ) throws -> Operations.AppsInAppPurchasesV2GetToManyRelated.Input.Query {
        var query = Operations.AppsInAppPurchasesV2GetToManyRelated.Input.Query()
        query.filter_lbrack_productId_rbrack_ = input.productIDs.nilIfEmpty
        query.filter_lbrack_name_rbrack_ = input.names.nilIfEmpty
        query.filter_lbrack_state_rbrack_ = try optionalInAppPurchaseListStates(input.states)
        query.filter_lbrack_inAppPurchaseType_rbrack_ = try optionalInAppPurchaseTypes(input.inAppPurchaseTypes)
        query.sort = try optionalInAppPurchaseSort(input.sort)
        query.fields_lbrack_inAppPurchases_rbrack_ = try inAppPurchaseFields(input.fields)
        query.include = try inAppPurchaseIncludes(input.includes)
        query.limit = input.limit
        return query
    }

    private func promotedPurchaseListQuery(
        from input: AppStoreConnectPromotedPurchaseListInput
    ) throws -> Operations.AppsPromotedPurchasesGetToManyRelated.Input.Query {
        var query = Operations.AppsPromotedPurchasesGetToManyRelated.Input.Query()
        query.fields_lbrack_promotedPurchases_rbrack_ = try promotedPurchaseListFields(input.fields)
        query.include = try promotedPurchaseListIncludes(input.includes)
        query.limit = input.limit
        return query
    }

    private func promotedPurchaseViewQuery(
        from input: AppStoreConnectPromotedPurchaseViewInput
    ) throws -> Operations.PromotedPurchasesGetInstance.Input.Query {
        var query = Operations.PromotedPurchasesGetInstance.Input.Query()
        query.fields_lbrack_promotedPurchases_rbrack_ = try promotedPurchaseViewFields(input.fields)
        query.include = try promotedPurchaseViewIncludes(input.includes)
        return query
    }

    private func appPricePointListQuery(
        from input: AppStoreConnectAppPricePointListInput
    ) throws -> Operations.AppsAppPricePointsGetToManyRelated.Input.Query {
        var query = Operations.AppsAppPricePointsGetToManyRelated.Input.Query()
        query.filter_lbrack_territory_rbrack_ = input.territories.nilIfEmpty
        query.fields_lbrack_appPricePoints_rbrack_ = try appPricePointFields(input.fields)
        query.fields_lbrack_territories_rbrack_ = try appPricePointTerritoryFields(input.territoryFields)
        query.include = appPricePointIncludes(app: input.includeApp, territory: input.includeTerritory)
        query.limit = input.limit
        return query
    }

    private func appPriceScheduleCurrentQuery(
        from input: AppStoreConnectAppPriceScheduleCurrentInput
    ) throws -> Operations.AppsAppPriceScheduleGetToOneRelated.Input.Query {
        var query = Operations.AppsAppPriceScheduleGetToOneRelated.Input.Query()
        query.fields_lbrack_appPriceSchedules_rbrack_ = try appPriceScheduleFields(input.fields)
        query.fields_lbrack_appPrices_rbrack_ = try appPriceSchedulePriceFields(input.priceFields)
        query.fields_lbrack_territories_rbrack_ = try appPriceScheduleTerritoryFields(input.territoryFields)
        query.include = appPriceScheduleIncludes(
            app: input.includeApp,
            baseTerritory: input.includeBaseTerritory,
            manualPrices: input.includeManualPrices,
            automaticPrices: input.includeAutomaticPrices
        )
        query.limit_lbrack_manualPrices_rbrack_ = input.manualPricesLimit
        query.limit_lbrack_automaticPrices_rbrack_ = input.automaticPricesLimit
        return query
    }

    private func appPricePointFields(
        _ values: [String]
    ) throws -> Operations.AppsAppPricePointsGetToManyRelated.Input.Query.Fields_lbrack_appPricePoints_rbrack_Payload? {
        let fields = try values.map { value in
            guard let field = Operations.AppsAppPricePointsGetToManyRelated.Input.Query
                .FieldsLbrackAppPricePointsRbrackPayloadPayload(rawValue: value)
            else {
                throw AppStoreConnectError.invalidConfiguration("Unsupported app price point field: \(value)")
            }
            return field
        }
        return fields.nilIfEmpty
    }

    private func appPricePointTerritoryFields(
        _ values: [String]
    ) throws -> Operations.AppsAppPricePointsGetToManyRelated.Input.Query.Fields_lbrack_territories_rbrack_Payload? {
        let fields = try values.map { value in
            guard let field = Operations.AppsAppPricePointsGetToManyRelated.Input.Query
                .FieldsLbrackTerritoriesRbrackPayloadPayload(rawValue: value)
            else {
                throw AppStoreConnectError.invalidConfiguration("Unsupported price point territory field: \(value)")
            }
            return field
        }
        return fields.nilIfEmpty
    }

    private func appPricePointIncludes(
        app: Bool,
        territory: Bool
    ) -> Operations.AppsAppPricePointsGetToManyRelated.Input.Query.IncludePayload? {
        var include: Operations.AppsAppPricePointsGetToManyRelated.Input.Query.IncludePayload = []
        if app {
            include.append(.app)
        }
        if territory {
            include.append(.territory)
        }
        return include.nilIfEmpty
    }

    private func appPriceScheduleFields(
        _ values: [String]
    ) throws -> Operations.AppsAppPriceScheduleGetToOneRelated.Input.Query.Fields_lbrack_appPriceSchedules_rbrack_Payload? {
        let fields = try values.map { value in
            guard let field = Operations.AppsAppPriceScheduleGetToOneRelated.Input.Query
                .FieldsLbrackAppPriceSchedulesRbrackPayloadPayload(rawValue: value)
            else {
                throw AppStoreConnectError.invalidConfiguration("Unsupported app price schedule field: \(value)")
            }
            return field
        }
        return fields.nilIfEmpty
    }

    private func appPriceSchedulePriceFields(
        _ values: [String]
    ) throws -> Operations.AppsAppPriceScheduleGetToOneRelated.Input.Query.Fields_lbrack_appPrices_rbrack_Payload? {
        let fields = try values.map { value in
            guard let field = Operations.AppsAppPriceScheduleGetToOneRelated.Input.Query
                .FieldsLbrackAppPricesRbrackPayloadPayload(rawValue: value)
            else {
                throw AppStoreConnectError.invalidConfiguration("Unsupported app price field: \(value)")
            }
            return field
        }
        return fields.nilIfEmpty
    }

    private func appPriceScheduleTerritoryFields(
        _ values: [String]
    ) throws -> Operations.AppsAppPriceScheduleGetToOneRelated.Input.Query.Fields_lbrack_territories_rbrack_Payload? {
        let fields = try values.map { value in
            guard let field = Operations.AppsAppPriceScheduleGetToOneRelated.Input.Query
                .FieldsLbrackTerritoriesRbrackPayloadPayload(rawValue: value)
            else {
                throw AppStoreConnectError.invalidConfiguration("Unsupported app price schedule territory field: \(value)")
            }
            return field
        }
        return fields.nilIfEmpty
    }

    private func appPriceScheduleIncludes(
        app: Bool,
        baseTerritory: Bool,
        manualPrices: Bool,
        automaticPrices: Bool
    ) -> Operations.AppsAppPriceScheduleGetToOneRelated.Input.Query.IncludePayload? {
        var include: Operations.AppsAppPriceScheduleGetToOneRelated.Input.Query.IncludePayload = []
        if app {
            include.append(.app)
        }
        if baseTerritory {
            include.append(.baseTerritory)
        }
        if manualPrices {
            include.append(.manualPrices)
        }
        if automaticPrices {
            include.append(.automaticPrices)
        }
        return include.nilIfEmpty
    }

    private func optionalInAppPurchaseListStates(
        _ values: [String]
    ) throws -> Operations.AppsInAppPurchasesV2GetToManyRelated.Input.Query.Filter_lbrack_state_rbrack_Payload? {
        let states = try values.map { value in
            guard let state = Operations.AppsInAppPurchasesV2GetToManyRelated.Input.Query
                .FilterLbrackStateRbrackPayloadPayload(rawValue: value)
            else {
                throw AppStoreConnectError.invalidConfiguration("Unsupported in-app purchase state: \(value)")
            }
            return state
        }
        return states.nilIfEmpty
    }

    private func optionalInAppPurchaseTypes(
        _ values: [String]
    ) throws -> Operations.AppsInAppPurchasesV2GetToManyRelated.Input.Query.Filter_lbrack_inAppPurchaseType_rbrack_Payload? {
        let types = try values.map { value in
            guard let type = Operations.AppsInAppPurchasesV2GetToManyRelated.Input.Query
                .FilterLbrackInAppPurchaseTypeRbrackPayloadPayload(rawValue: value)
            else {
                throw AppStoreConnectError.invalidConfiguration("Unsupported in-app purchase type: \(value)")
            }
            return type
        }
        return types.nilIfEmpty
    }

    private func optionalInAppPurchaseSort(
        _ value: String?
    ) throws -> Operations.AppsInAppPurchasesV2GetToManyRelated.Input.Query.SortPayload? {
        guard let value else { return nil }
        guard let sort = Operations.AppsInAppPurchasesV2GetToManyRelated.Input.Query.SortPayloadPayload(rawValue: value) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported in-app purchase sort: \(value)")
        }
        return [sort]
    }

    private func inAppPurchaseFields(
        _ values: [String]
    ) throws -> Operations.AppsInAppPurchasesV2GetToManyRelated.Input.Query.Fields_lbrack_inAppPurchases_rbrack_Payload? {
        let fields = try values.map { value in
            guard let field = Operations.AppsInAppPurchasesV2GetToManyRelated.Input.Query
                .FieldsLbrackInAppPurchasesRbrackPayloadPayload(rawValue: value)
            else {
                throw AppStoreConnectError.invalidConfiguration("Unsupported in-app purchase field: \(value)")
            }
            return field
        }
        return fields.nilIfEmpty
    }

    private func inAppPurchaseIncludes(
        _ values: [String]
    ) throws -> Operations.AppsInAppPurchasesV2GetToManyRelated.Input.Query.IncludePayload? {
        let includes = try values.map { value in
            guard let include = Operations.AppsInAppPurchasesV2GetToManyRelated.Input.Query
                .IncludePayloadPayload(rawValue: value)
            else {
                throw AppStoreConnectError.invalidConfiguration("Unsupported in-app purchase include: \(value)")
            }
            return include
        }
        return includes.nilIfEmpty
    }

    private func promotedPurchaseListFields(
        _ values: [String]
    ) throws -> Operations.AppsPromotedPurchasesGetToManyRelated.Input.Query.Fields_lbrack_promotedPurchases_rbrack_Payload? {
        let fields = try values.map { value in
            guard let field = Operations.AppsPromotedPurchasesGetToManyRelated.Input.Query
                .FieldsLbrackPromotedPurchasesRbrackPayloadPayload(rawValue: value)
            else {
                throw AppStoreConnectError.invalidConfiguration("Unsupported promoted purchase field: \(value)")
            }
            return field
        }
        return fields.nilIfEmpty
    }

    private func promotedPurchaseListIncludes(
        _ values: [String]
    ) throws -> Operations.AppsPromotedPurchasesGetToManyRelated.Input.Query.IncludePayload? {
        let includes = try values.map { value in
            guard let include = Operations.AppsPromotedPurchasesGetToManyRelated.Input.Query
                .IncludePayloadPayload(rawValue: value)
            else {
                throw AppStoreConnectError.invalidConfiguration("Unsupported promoted purchase include: \(value)")
            }
            return include
        }
        return includes.nilIfEmpty
    }

    private func promotedPurchaseViewFields(
        _ values: [String]
    ) throws -> Operations.PromotedPurchasesGetInstance.Input.Query.Fields_lbrack_promotedPurchases_rbrack_Payload? {
        let fields = try values.map { value in
            guard let field = Operations.PromotedPurchasesGetInstance.Input.Query
                .FieldsLbrackPromotedPurchasesRbrackPayloadPayload(rawValue: value)
            else {
                throw AppStoreConnectError.invalidConfiguration("Unsupported promoted purchase field: \(value)")
            }
            return field
        }
        return fields.nilIfEmpty
    }

    private func promotedPurchaseViewIncludes(
        _ values: [String]
    ) throws -> Operations.PromotedPurchasesGetInstance.Input.Query.IncludePayload? {
        let includes = try values.map { value in
            guard let include = Operations.PromotedPurchasesGetInstance.Input.Query
                .IncludePayloadPayload(rawValue: value)
            else {
                throw AppStoreConnectError.invalidConfiguration("Unsupported promoted purchase include: \(value)")
            }
            return include
        }
        return includes.nilIfEmpty
    }

    private func subscriptionListQuery(
        from input: AppStoreConnectSubscriptionListInput
    ) throws -> Operations.SubscriptionGroupsSubscriptionsGetToManyRelated.Input.Query {
        .init(
            filter_lbrack_productId_rbrack_: input.productIDs.isEmpty ? nil : input.productIDs,
            filter_lbrack_name_rbrack_: input.names.isEmpty ? nil : input.names,
            filter_lbrack_state_rbrack_: try optionalSubscriptionListStates(input.states),
            sort: try optionalSubscriptionSort(input.sort),
            limit: input.limit
        )
    }

    private func optionalSubscriptionListStates(
        _ values: [String]
    ) throws -> Operations.SubscriptionGroupsSubscriptionsGetToManyRelated.Input.Query.Filter_lbrack_state_rbrack_Payload? {
        guard !values.isEmpty else { return nil }
        return try values.map { value in
            guard let state = Operations.SubscriptionGroupsSubscriptionsGetToManyRelated.Input.Query.FilterLbrackStateRbrackPayloadPayload(rawValue: value) else {
                throw AppStoreConnectError.invalidConfiguration("Unsupported subscription state: \(value)")
            }
            return state
        }
    }

    private func optionalSubscriptionSort(
        _ value: String?
    ) throws -> Operations.SubscriptionGroupsSubscriptionsGetToManyRelated.Input.Query.SortPayload? {
        guard let value else { return nil }
        guard let sort = Operations.SubscriptionGroupsSubscriptionsGetToManyRelated.Input.Query.SortPayloadPayload(rawValue: value) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported subscription sort: \(value)")
        }
        return [sort]
    }
}

public extension PublicAPIWriteCommands {
    static func planCreateInAppPurchase(
        _ input: AppStoreConnectInAppPurchaseCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.InAppPurchasesV2CreateInstance.id,
            commandDescription: "Create in-app purchase \(input.productID) for app \(input.appID).",
            inputs: [
                "appID": input.appID,
                "productID": input.productID,
                "inAppPurchaseType": input.inAppPurchaseType,
                "name": input.name,
            ]
        )
    }

    static func planUpdateInAppPurchase(
        _ input: AppStoreConnectInAppPurchaseUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.InAppPurchasesV2UpdateInstance.id,
            commandDescription: "Update in-app purchase \(input.id).",
            inputs: compactInputs([
                "id": input.id,
                "name": input.name,
                "familySharable": input.familySharable.map(String.init),
            ])
        )
    }

    static func planDeleteInAppPurchase(
        _ input: AppStoreConnectInAppPurchaseDeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.InAppPurchasesV2DeleteInstance.id,
            commandDescription: "Delete in-app purchase \(input.id).",
            inputs: ["id": input.id]
        )
    }

    static func planSubmitInAppPurchase(
        _ input: AppStoreConnectInAppPurchaseSubmitInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.InAppPurchaseSubmissionsCreateInstance.id,
            commandDescription: "Submit in-app purchase \(input.id) for review.",
            inputs: ["id": input.id]
        )
    }

    static func planCreatePromotedPurchase(
        _ input: AppStoreConnectPromotedPurchaseCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.PromotedPurchasesCreateInstance.id,
            commandDescription: "Create promoted purchase for app \(input.appID).",
            inputs: compactInputs([
                "appID": input.appID,
                "inAppPurchaseID": input.inAppPurchaseID,
                "subscriptionID": input.subscriptionID,
                "visibleForAllUsers": String(input.visibleForAllUsers),
                "enabled": input.enabled.map(String.init),
            ])
        )
    }

    static func planUpdatePromotedPurchase(
        _ input: AppStoreConnectPromotedPurchaseUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.PromotedPurchasesUpdateInstance.id,
            commandDescription: "Update promoted purchase \(input.id).",
            inputs: compactInputs([
                "id": input.id,
                "visibleForAllUsers": input.visibleForAllUsers.map(String.init),
                "enabled": input.enabled.map(String.init),
            ])
        )
    }

    static func planDeletePromotedPurchase(
        _ input: AppStoreConnectPromotedPurchaseDeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.PromotedPurchasesDeleteInstance.id,
            commandDescription: "Delete promoted purchase \(input.id).",
            inputs: ["id": input.id]
        )
    }

    static func planCreateSubscriptionGroup(
        _ input: AppStoreConnectSubscriptionGroupCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.SubscriptionGroupsCreateInstance.id,
            commandDescription: "Create subscription group \(input.referenceName) for app \(input.appID).",
            inputs: ["appID": input.appID, "referenceName": input.referenceName]
        )
    }

    static func planUpdateSubscriptionGroup(
        _ input: AppStoreConnectSubscriptionGroupUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.SubscriptionGroupsUpdateInstance.id,
            commandDescription: "Update subscription group \(input.id).",
            inputs: compactInputs(["id": input.id, "referenceName": input.referenceName])
        )
    }

    static func planDeleteSubscriptionGroup(
        _ input: AppStoreConnectSubscriptionGroupDeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.SubscriptionGroupsDeleteInstance.id,
            commandDescription: "Delete subscription group \(input.id).",
            inputs: ["id": input.id]
        )
    }

    static func planCreateSubscription(
        _ input: AppStoreConnectSubscriptionCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.SubscriptionsCreateInstance.id,
            commandDescription: "Create subscription \(input.productID) in group \(input.groupID).",
            inputs: compactInputs([
                "groupID": input.groupID,
                "productID": input.productID,
                "name": input.name,
                "subscriptionPeriod": input.subscriptionPeriod,
            ])
        )
    }

    static func planUpdateSubscription(
        _ input: AppStoreConnectSubscriptionUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.SubscriptionsUpdateInstance.id,
            commandDescription: "Update subscription \(input.id).",
            inputs: compactInputs([
                "id": input.id,
                "name": input.name,
                "subscriptionPeriod": input.subscriptionPeriod,
                "groupLevel": input.groupLevel.map(String.init),
            ])
        )
    }

    static func planDeleteSubscription(
        _ input: AppStoreConnectSubscriptionDeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.SubscriptionsDeleteInstance.id,
            commandDescription: "Delete subscription \(input.id).",
            inputs: ["id": input.id]
        )
    }

    static func planSubmitSubscription(
        _ input: AppStoreConnectSubscriptionSubmitInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.SubscriptionSubmissionsCreateInstance.id,
            commandDescription: "Submit subscription \(input.id) for review.",
            inputs: ["id": input.id]
        )
    }

    static func planCreateInAppPurchaseLocalization(
        _ input: AppStoreConnectInAppPurchaseLocalizationCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.InAppPurchaseLocalizationsCreateInstance.id,
            commandDescription: "Create localization \(input.locale) for in-app purchase \(input.inAppPurchaseID).",
            inputs: compactInputs([
                "inAppPurchaseID": input.inAppPurchaseID,
                "locale": input.locale,
                "name": input.name,
                "description": input.description,
            ])
        )
    }

    static func planUpdateInAppPurchaseLocalization(
        _ input: AppStoreConnectInAppPurchaseLocalizationUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.InAppPurchaseLocalizationsUpdateInstance.id,
            commandDescription: "Update in-app purchase localization \(input.id).",
            inputs: compactInputs([
                "id": input.id,
                "name": input.name,
                "description": input.description,
            ])
        )
    }

    static func planDeleteInAppPurchaseLocalization(
        _ input: AppStoreConnectInAppPurchaseLocalizationDeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.InAppPurchaseLocalizationsDeleteInstance.id,
            commandDescription: "Delete in-app purchase localization \(input.id).",
            inputs: ["id": input.id]
        )
    }

    static func planCreateSubscriptionLocalization(
        _ input: AppStoreConnectSubscriptionLocalizationCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.SubscriptionLocalizationsCreateInstance.id,
            commandDescription: "Create localization \(input.locale) for subscription \(input.subscriptionID).",
            inputs: compactInputs([
                "subscriptionID": input.subscriptionID,
                "locale": input.locale,
                "name": input.name,
                "description": input.description,
            ])
        )
    }

    static func planUpdateSubscriptionLocalization(
        _ input: AppStoreConnectSubscriptionLocalizationUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.SubscriptionLocalizationsUpdateInstance.id,
            commandDescription: "Update subscription localization \(input.id).",
            inputs: compactInputs([
                "id": input.id,
                "name": input.name,
                "description": input.description,
            ])
        )
    }

    static func planDeleteSubscriptionLocalization(
        _ input: AppStoreConnectSubscriptionLocalizationDeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.SubscriptionLocalizationsDeleteInstance.id,
            commandDescription: "Delete subscription localization \(input.id).",
            inputs: ["id": input.id]
        )
    }

    static func planCreateSubscriptionGroupLocalization(
        _ input: AppStoreConnectSubscriptionGroupLocalizationCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.SubscriptionGroupLocalizationsCreateInstance.id,
            commandDescription: "Create localization \(input.locale) for subscription group \(input.groupID).",
            inputs: compactInputs([
                "groupID": input.groupID,
                "locale": input.locale,
                "name": input.name,
                "customAppName": input.customAppName,
            ])
        )
    }

    static func planUpdateSubscriptionGroupLocalization(
        _ input: AppStoreConnectSubscriptionGroupLocalizationUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.SubscriptionGroupLocalizationsUpdateInstance.id,
            commandDescription: "Update subscription group localization \(input.id).",
            inputs: compactInputs([
                "id": input.id,
                "name": input.name,
                "customAppName": input.customAppName,
            ])
        )
    }

    static func planDeleteSubscriptionGroupLocalization(
        _ input: AppStoreConnectSubscriptionGroupLocalizationDeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.SubscriptionGroupLocalizationsDeleteInstance.id,
            commandDescription: "Delete subscription group localization \(input.id).",
            inputs: ["id": input.id]
        )
    }

    static func planCreateWinBackOffer(
        _ input: AppStoreConnectWinBackOfferCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.WinBackOffersCreateInstance.id,
            commandDescription: "Create win-back offer \(input.referenceName) for subscription \(input.subscriptionID).",
            inputs: compactInputs([
                "subscriptionID": input.subscriptionID,
                "referenceName": input.referenceName,
                "offerID": input.offerID,
                "duration": input.duration,
                "offerMode": input.offerMode,
                "periodCount": String(input.periodCount),
                "paidSubscriptionDurationMonths": String(input.paidSubscriptionDurationMonths),
                "lastSubscribedMinMonths": String(input.lastSubscribedMinMonths),
                "lastSubscribedMaxMonths": String(input.lastSubscribedMaxMonths),
                "waitBetweenOffersMonths": input.waitBetweenOffersMonths.map(String.init),
                "startDate": input.startDate,
                "endDate": input.endDate,
                "priority": input.priority,
                "promotionIntent": input.promotionIntent,
                "priceIDs": joined(input.priceIDs),
            ])
        )
    }

    static func planUpdateWinBackOffer(
        _ input: AppStoreConnectWinBackOfferUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.WinBackOffersUpdateInstance.id,
            commandDescription: "Update win-back offer \(input.id).",
            inputs: compactInputs([
                "id": input.id,
                "paidSubscriptionDurationMonths": input.paidSubscriptionDurationMonths.map(String.init),
                "lastSubscribedMinMonths": input.lastSubscribedMinMonths.map(String.init),
                "lastSubscribedMaxMonths": input.lastSubscribedMaxMonths.map(String.init),
                "waitBetweenOffersMonths": input.waitBetweenOffersMonths.map(String.init),
                "startDate": input.startDate,
                "endDate": input.endDate,
                "priority": input.priority,
                "promotionIntent": input.promotionIntent,
            ])
        )
    }

    static func planDeleteWinBackOffer(
        _ input: AppStoreConnectWinBackOfferDeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.WinBackOffersDeleteInstance.id,
            commandDescription: "Delete win-back offer \(input.id).",
            inputs: ["id": input.id]
        )
    }

    func createInAppPurchase(_ input: AppStoreConnectInAppPurchaseCreateInput) async throws -> AppStoreConnectInAppPurchaseResult {
        let output = try await client.openAPI.inAppPurchasesV2CreateInstance(
            .init(body: try inAppPurchaseCreateBody(from: input))
        )

        switch output {
        case let .created(response):
            return AppStoreConnectInAppPurchaseResult(data: PublicAPIReadCommands.inAppPurchaseSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected in-app purchase creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "In-app purchase creation did not return 201 created.")
        }
    }

    func updateInAppPurchase(_ input: AppStoreConnectInAppPurchaseUpdateInput) async throws -> AppStoreConnectInAppPurchaseResult {
        let output = try await client.openAPI.inAppPurchasesV2UpdateInstance(.init(
            path: .init(id: input.id),
            body: inAppPurchaseUpdateBody(from: input)
        ))

        switch output {
        case let .ok(response):
            return AppStoreConnectInAppPurchaseResult(data: PublicAPIReadCommands.inAppPurchaseSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected in-app purchase update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "In-app purchase update did not return 200 ok.")
        }
    }

    func deleteInAppPurchase(_ input: AppStoreConnectInAppPurchaseDeleteInput) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.openAPI.inAppPurchasesV2DeleteInstance(.init(path: .init(id: input.id)))

        switch output {
        case .noContent:
            return mutationAcknowledgement(
                operationID: Operations.InAppPurchasesV2DeleteInstance.id,
                resourceType: "inAppPurchases",
                id: input.id
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected in-app purchase deletion response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "In-app purchase deletion did not return 204 no content.")
        }
    }

    func submitInAppPurchase(_ input: AppStoreConnectInAppPurchaseSubmitInput) async throws -> AppStoreConnectCommerceSubmissionResult {
        let output = try await client.openAPI.inAppPurchaseSubmissionsCreateInstance(
            .init(body: inAppPurchaseSubmissionCreateBody(from: input))
        )

        switch output {
        case let .created(response):
            return AppStoreConnectCommerceSubmissionResult(data: .init(
                id: try response.body.json.data.id,
                resourceType: "inAppPurchaseSubmissions",
                targetID: input.id
            ))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected in-app purchase submission response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "In-app purchase submission did not return 201 created.")
        }
    }

    func createPromotedPurchase(_ input: AppStoreConnectPromotedPurchaseCreateInput) async throws -> AppStoreConnectPromotedPurchaseResult {
        let output = try await client.openAPI.promotedPurchasesCreateInstance(
            .init(body: try promotedPurchaseCreateBody(from: input))
        )

        switch output {
        case let .created(response):
            return AppStoreConnectPromotedPurchaseResult(data: PublicAPIReadCommands.promotedPurchaseSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected promoted purchase creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Promoted purchase creation did not return 201 created.")
        }
    }

    func updatePromotedPurchase(_ input: AppStoreConnectPromotedPurchaseUpdateInput) async throws -> AppStoreConnectPromotedPurchaseResult {
        let output = try await client.openAPI.promotedPurchasesUpdateInstance(.init(
            path: .init(id: input.id),
            body: promotedPurchaseUpdateBody(from: input)
        ))

        switch output {
        case let .ok(response):
            return AppStoreConnectPromotedPurchaseResult(data: PublicAPIReadCommands.promotedPurchaseSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected promoted purchase update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Promoted purchase update did not return 200 ok.")
        }
    }

    func deletePromotedPurchase(_ input: AppStoreConnectPromotedPurchaseDeleteInput) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.openAPI.promotedPurchasesDeleteInstance(.init(path: .init(id: input.id)))

        switch output {
        case .noContent:
            return mutationAcknowledgement(
                operationID: Operations.PromotedPurchasesDeleteInstance.id,
                resourceType: "promotedPurchases",
                id: input.id
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected promoted purchase deletion response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Promoted purchase deletion did not return 204 no content.")
        }
    }

    func createSubscriptionGroup(_ input: AppStoreConnectSubscriptionGroupCreateInput) async throws -> AppStoreConnectSubscriptionGroupResult {
        let output = try await client.openAPI.subscriptionGroupsCreateInstance(
            .init(body: subscriptionGroupCreateBody(from: input))
        )

        switch output {
        case let .created(response):
            return AppStoreConnectSubscriptionGroupResult(data: PublicAPIReadCommands.subscriptionGroupSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected subscription group creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Subscription group creation did not return 201 created.")
        }
    }

    func updateSubscriptionGroup(_ input: AppStoreConnectSubscriptionGroupUpdateInput) async throws -> AppStoreConnectSubscriptionGroupResult {
        let output = try await client.openAPI.subscriptionGroupsUpdateInstance(.init(
            path: .init(id: input.id),
            body: subscriptionGroupUpdateBody(from: input)
        ))

        switch output {
        case let .ok(response):
            return AppStoreConnectSubscriptionGroupResult(data: PublicAPIReadCommands.subscriptionGroupSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected subscription group update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Subscription group update did not return 200 ok.")
        }
    }

    func deleteSubscriptionGroup(_ input: AppStoreConnectSubscriptionGroupDeleteInput) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.openAPI.subscriptionGroupsDeleteInstance(.init(path: .init(id: input.id)))

        switch output {
        case .noContent:
            return mutationAcknowledgement(
                operationID: Operations.SubscriptionGroupsDeleteInstance.id,
                resourceType: "subscriptionGroups",
                id: input.id
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected subscription group deletion response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Subscription group deletion did not return 204 no content.")
        }
    }

    func createSubscription(_ input: AppStoreConnectSubscriptionCreateInput) async throws -> AppStoreConnectSubscriptionResult {
        let output = try await client.openAPI.subscriptionsCreateInstance(
            .init(body: try subscriptionCreateBody(from: input))
        )

        switch output {
        case let .created(response):
            return AppStoreConnectSubscriptionResult(data: PublicAPIReadCommands.subscriptionSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected subscription creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Subscription creation did not return 201 created.")
        }
    }

    func updateSubscription(_ input: AppStoreConnectSubscriptionUpdateInput) async throws -> AppStoreConnectSubscriptionResult {
        let output = try await client.openAPI.subscriptionsUpdateInstance(.init(
            path: .init(id: input.id),
            body: try subscriptionUpdateBody(from: input)
        ))

        switch output {
        case let .ok(response):
            return AppStoreConnectSubscriptionResult(data: PublicAPIReadCommands.subscriptionSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected subscription update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Subscription update did not return 200 ok.")
        }
    }

    func deleteSubscription(_ input: AppStoreConnectSubscriptionDeleteInput) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.openAPI.subscriptionsDeleteInstance(.init(path: .init(id: input.id)))

        switch output {
        case .noContent:
            return mutationAcknowledgement(
                operationID: Operations.SubscriptionsDeleteInstance.id,
                resourceType: "subscriptions",
                id: input.id
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected subscription deletion response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Subscription deletion did not return 204 no content.")
        }
    }

    func submitSubscription(_ input: AppStoreConnectSubscriptionSubmitInput) async throws -> AppStoreConnectCommerceSubmissionResult {
        let output = try await client.openAPI.subscriptionSubmissionsCreateInstance(
            .init(body: subscriptionSubmissionCreateBody(from: input))
        )

        switch output {
        case let .created(response):
            return AppStoreConnectCommerceSubmissionResult(data: .init(
                id: try response.body.json.data.id,
                resourceType: "subscriptionSubmissions",
                targetID: input.id
            ))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected subscription submission response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Subscription submission did not return 201 created.")
        }
    }

    func createInAppPurchaseLocalization(
        _ input: AppStoreConnectInAppPurchaseLocalizationCreateInput
    ) async throws -> AppStoreConnectCommerceLocalizationResult {
        let output = try await client.openAPI.inAppPurchaseLocalizationsCreateInstance(
            .init(body: inAppPurchaseLocalizationCreateBody(from: input))
        )

        switch output {
        case let .created(response):
            return AppStoreConnectCommerceLocalizationResult(
                data: PublicAPIReadCommands.inAppPurchaseLocalizationSummary(try response.body.json.data)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected IAP localization creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "IAP localization creation did not return 201 created.")
        }
    }

    func updateInAppPurchaseLocalization(
        _ input: AppStoreConnectInAppPurchaseLocalizationUpdateInput
    ) async throws -> AppStoreConnectCommerceLocalizationResult {
        let output = try await client.openAPI.inAppPurchaseLocalizationsUpdateInstance(.init(
            path: .init(id: input.id),
            body: inAppPurchaseLocalizationUpdateBody(from: input)
        ))

        switch output {
        case let .ok(response):
            return AppStoreConnectCommerceLocalizationResult(
                data: PublicAPIReadCommands.inAppPurchaseLocalizationSummary(try response.body.json.data)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected IAP localization update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "IAP localization update did not return 200 ok.")
        }
    }

    func deleteInAppPurchaseLocalization(
        _ input: AppStoreConnectInAppPurchaseLocalizationDeleteInput
    ) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.openAPI.inAppPurchaseLocalizationsDeleteInstance(.init(path: .init(id: input.id)))

        switch output {
        case .noContent:
            return mutationAcknowledgement(
                operationID: Operations.InAppPurchaseLocalizationsDeleteInstance.id,
                resourceType: "inAppPurchaseLocalizations",
                id: input.id
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected IAP localization deletion response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "IAP localization deletion did not return 204 no content.")
        }
    }

    func createSubscriptionLocalization(
        _ input: AppStoreConnectSubscriptionLocalizationCreateInput
    ) async throws -> AppStoreConnectCommerceLocalizationResult {
        let output = try await client.openAPI.subscriptionLocalizationsCreateInstance(
            .init(body: subscriptionLocalizationCreateBody(from: input))
        )

        switch output {
        case let .created(response):
            return AppStoreConnectCommerceLocalizationResult(
                data: PublicAPIReadCommands.subscriptionLocalizationSummary(try response.body.json.data)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected subscription localization creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Subscription localization creation did not return 201 created.")
        }
    }

    func updateSubscriptionLocalization(
        _ input: AppStoreConnectSubscriptionLocalizationUpdateInput
    ) async throws -> AppStoreConnectCommerceLocalizationResult {
        let output = try await client.openAPI.subscriptionLocalizationsUpdateInstance(.init(
            path: .init(id: input.id),
            body: subscriptionLocalizationUpdateBody(from: input)
        ))

        switch output {
        case let .ok(response):
            return AppStoreConnectCommerceLocalizationResult(
                data: PublicAPIReadCommands.subscriptionLocalizationSummary(try response.body.json.data)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected subscription localization update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Subscription localization update did not return 200 ok.")
        }
    }

    func deleteSubscriptionLocalization(
        _ input: AppStoreConnectSubscriptionLocalizationDeleteInput
    ) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.openAPI.subscriptionLocalizationsDeleteInstance(.init(path: .init(id: input.id)))

        switch output {
        case .noContent:
            return mutationAcknowledgement(
                operationID: Operations.SubscriptionLocalizationsDeleteInstance.id,
                resourceType: "subscriptionLocalizations",
                id: input.id
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected subscription localization deletion response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Subscription localization deletion did not return 204 no content.")
        }
    }

    func createSubscriptionGroupLocalization(
        _ input: AppStoreConnectSubscriptionGroupLocalizationCreateInput
    ) async throws -> AppStoreConnectCommerceLocalizationResult {
        let output = try await client.openAPI.subscriptionGroupLocalizationsCreateInstance(
            .init(body: subscriptionGroupLocalizationCreateBody(from: input))
        )

        switch output {
        case let .created(response):
            return AppStoreConnectCommerceLocalizationResult(
                data: PublicAPIReadCommands.subscriptionGroupLocalizationSummary(try response.body.json.data)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected subscription group localization creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Subscription group localization creation did not return 201 created.")
        }
    }

    func updateSubscriptionGroupLocalization(
        _ input: AppStoreConnectSubscriptionGroupLocalizationUpdateInput
    ) async throws -> AppStoreConnectCommerceLocalizationResult {
        let output = try await client.openAPI.subscriptionGroupLocalizationsUpdateInstance(.init(
            path: .init(id: input.id),
            body: subscriptionGroupLocalizationUpdateBody(from: input)
        ))

        switch output {
        case let .ok(response):
            return AppStoreConnectCommerceLocalizationResult(
                data: PublicAPIReadCommands.subscriptionGroupLocalizationSummary(try response.body.json.data)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected subscription group localization update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Subscription group localization update did not return 200 ok.")
        }
    }

    func deleteSubscriptionGroupLocalization(
        _ input: AppStoreConnectSubscriptionGroupLocalizationDeleteInput
    ) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.openAPI.subscriptionGroupLocalizationsDeleteInstance(.init(path: .init(id: input.id)))

        switch output {
        case .noContent:
            return mutationAcknowledgement(
                operationID: Operations.SubscriptionGroupLocalizationsDeleteInstance.id,
                resourceType: "subscriptionGroupLocalizations",
                id: input.id
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected subscription group localization deletion response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Subscription group localization deletion did not return 204 no content.")
        }
    }

    func createWinBackOffer(_ input: AppStoreConnectWinBackOfferCreateInput) async throws -> AppStoreConnectWinBackOfferResult {
        let output = try await client.openAPI.winBackOffersCreateInstance(
            .init(body: try winBackOfferCreateBody(from: input))
        )

        switch output {
        case let .created(response):
            return AppStoreConnectWinBackOfferResult(data: PublicAPIReadCommands.winBackOfferSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected win-back offer creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Win-back offer creation did not return 201 created.")
        }
    }

    func updateWinBackOffer(_ input: AppStoreConnectWinBackOfferUpdateInput) async throws -> AppStoreConnectWinBackOfferResult {
        let output = try await client.openAPI.winBackOffersUpdateInstance(.init(
            path: .init(id: input.id),
            body: try winBackOfferUpdateBody(from: input)
        ))

        switch output {
        case let .ok(response):
            return AppStoreConnectWinBackOfferResult(data: PublicAPIReadCommands.winBackOfferSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected win-back offer update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Win-back offer update did not return 200 ok.")
        }
    }

    func deleteWinBackOffer(_ input: AppStoreConnectWinBackOfferDeleteInput) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.openAPI.winBackOffersDeleteInstance(.init(path: .init(id: input.id)))

        switch output {
        case .noContent:
            return mutationAcknowledgement(
                operationID: Operations.WinBackOffersDeleteInstance.id,
                resourceType: "winBackOffers",
                id: input.id
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected win-back offer deletion response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Win-back offer deletion did not return 204 no content.")
        }
    }

    private static func compactInputs(_ values: [String: String?]) -> [String: String] {
        values.compactMapValues { $0 }
    }

    private func mutationAcknowledgement(
        operationID: String,
        resourceType: String,
        id: String
    ) -> AppStoreConnectMutationAcknowledgementResult {
        AppStoreConnectMutationAcknowledgementResult(data: .init(
            operationID: operationID,
            resourceType: resourceType,
            id: id,
            status: "deleted"
        ))
    }

    private func inAppPurchaseCreateBody(
        from input: AppStoreConnectInAppPurchaseCreateInput
    ) throws -> Operations.InAppPurchasesV2CreateInstance.Input.Body {
        .json(.init(data: .init(
            attributes: .init(
                familySharable: input.familySharable,
                inAppPurchaseType: try requiredInAppPurchaseType(input.inAppPurchaseType),
                name: input.name,
                productId: input.productID,
                reviewNote: input.reviewNote
            ),
            relationships: .init(app: .init(data: .init(id: input.appID, _type: .apps))),
            _type: .inAppPurchases
        )))
    }

    private func inAppPurchaseUpdateBody(
        from input: AppStoreConnectInAppPurchaseUpdateInput
    ) -> Operations.InAppPurchasesV2UpdateInstance.Input.Body {
        .json(.init(data: .init(
            attributes: .init(
                familySharable: input.familySharable,
                name: input.name,
                reviewNote: input.reviewNote
            ),
            id: input.id,
            _type: .inAppPurchases
        )))
    }

    private func inAppPurchaseSubmissionCreateBody(
        from input: AppStoreConnectInAppPurchaseSubmitInput
    ) -> Operations.InAppPurchaseSubmissionsCreateInstance.Input.Body {
        .json(.init(data: .init(
            relationships: .init(
                inAppPurchaseV2: .init(data: .init(id: input.id, _type: .inAppPurchases))
            ),
            _type: .inAppPurchaseSubmissions
        )))
    }

    private func promotedPurchaseCreateBody(
        from input: AppStoreConnectPromotedPurchaseCreateInput
    ) throws -> Operations.PromotedPurchasesCreateInstance.Input.Body {
        guard (input.inAppPurchaseID == nil) != (input.subscriptionID == nil) else {
            throw AppStoreConnectError.invalidConfiguration("Specify exactly one of inAppPurchaseID or subscriptionID.")
        }

        return .json(.init(data: .init(
            attributes: .init(
                enabled: input.enabled,
                visibleForAllUsers: input.visibleForAllUsers
            ),
            relationships: .init(
                app: .init(data: .init(id: input.appID, _type: .apps)),
                inAppPurchaseV2: input.inAppPurchaseID.map { .init(data: .init(id: $0, _type: .inAppPurchases)) },
                subscription: input.subscriptionID.map { .init(data: .init(id: $0, _type: .subscriptions)) }
            ),
            _type: .promotedPurchases
        )))
    }

    private func promotedPurchaseUpdateBody(
        from input: AppStoreConnectPromotedPurchaseUpdateInput
    ) -> Operations.PromotedPurchasesUpdateInstance.Input.Body {
        .json(.init(data: .init(
            attributes: .init(
                enabled: input.enabled,
                visibleForAllUsers: input.visibleForAllUsers
            ),
            id: input.id,
            _type: .promotedPurchases
        )))
    }

    private func subscriptionGroupCreateBody(
        from input: AppStoreConnectSubscriptionGroupCreateInput
    ) -> Operations.SubscriptionGroupsCreateInstance.Input.Body {
        .json(.init(data: .init(
            attributes: .init(referenceName: input.referenceName),
            relationships: .init(app: .init(data: .init(id: input.appID, _type: .apps))),
            _type: .subscriptionGroups
        )))
    }

    private func subscriptionGroupUpdateBody(
        from input: AppStoreConnectSubscriptionGroupUpdateInput
    ) -> Operations.SubscriptionGroupsUpdateInstance.Input.Body {
        .json(.init(data: .init(
            attributes: .init(referenceName: input.referenceName),
            id: input.id,
            _type: .subscriptionGroups
        )))
    }

    private func subscriptionCreateBody(
        from input: AppStoreConnectSubscriptionCreateInput
    ) throws -> Operations.SubscriptionsCreateInstance.Input.Body {
        .json(.init(data: .init(
            attributes: .init(
                familySharable: input.familySharable,
                groupLevel: input.groupLevel,
                name: input.name,
                productId: input.productID,
                reviewNote: input.reviewNote,
                subscriptionPeriod: try optionalCreateSubscriptionPeriod(input.subscriptionPeriod)
            ),
            relationships: .init(group: .init(data: .init(id: input.groupID, _type: .subscriptionGroups))),
            _type: .subscriptions
        )))
    }

    private func subscriptionUpdateBody(
        from input: AppStoreConnectSubscriptionUpdateInput
    ) throws -> Operations.SubscriptionsUpdateInstance.Input.Body {
        .json(.init(data: .init(
            attributes: .init(
                familySharable: input.familySharable,
                groupLevel: input.groupLevel,
                name: input.name,
                reviewNote: input.reviewNote,
                subscriptionPeriod: try optionalUpdateSubscriptionPeriod(input.subscriptionPeriod)
            ),
            id: input.id,
            _type: .subscriptions
        )))
    }

    private func subscriptionSubmissionCreateBody(
        from input: AppStoreConnectSubscriptionSubmitInput
    ) -> Operations.SubscriptionSubmissionsCreateInstance.Input.Body {
        .json(.init(data: .init(
            relationships: .init(
                subscription: .init(data: .init(id: input.id, _type: .subscriptions))
            ),
            _type: .subscriptionSubmissions
        )))
    }

    private func inAppPurchaseLocalizationCreateBody(
        from input: AppStoreConnectInAppPurchaseLocalizationCreateInput
    ) -> Operations.InAppPurchaseLocalizationsCreateInstance.Input.Body {
        .json(.init(data: .init(
            attributes: .init(
                description: input.description,
                locale: input.locale,
                name: input.name
            ),
            relationships: .init(
                inAppPurchaseV2: .init(data: .init(id: input.inAppPurchaseID, _type: .inAppPurchases))
            ),
            _type: .inAppPurchaseLocalizations
        )))
    }

    private func inAppPurchaseLocalizationUpdateBody(
        from input: AppStoreConnectInAppPurchaseLocalizationUpdateInput
    ) -> Operations.InAppPurchaseLocalizationsUpdateInstance.Input.Body {
        .json(.init(data: .init(
            attributes: .init(
                description: input.description,
                name: input.name
            ),
            id: input.id,
            _type: .inAppPurchaseLocalizations
        )))
    }

    private func subscriptionLocalizationCreateBody(
        from input: AppStoreConnectSubscriptionLocalizationCreateInput
    ) -> Operations.SubscriptionLocalizationsCreateInstance.Input.Body {
        .json(.init(data: .init(
            attributes: .init(
                description: input.description,
                locale: input.locale,
                name: input.name
            ),
            relationships: .init(
                subscription: .init(data: .init(id: input.subscriptionID, _type: .subscriptions))
            ),
            _type: .subscriptionLocalizations
        )))
    }

    private func subscriptionLocalizationUpdateBody(
        from input: AppStoreConnectSubscriptionLocalizationUpdateInput
    ) -> Operations.SubscriptionLocalizationsUpdateInstance.Input.Body {
        .json(.init(data: .init(
            attributes: .init(
                description: input.description,
                name: input.name
            ),
            id: input.id,
            _type: .subscriptionLocalizations
        )))
    }

    private func subscriptionGroupLocalizationCreateBody(
        from input: AppStoreConnectSubscriptionGroupLocalizationCreateInput
    ) -> Operations.SubscriptionGroupLocalizationsCreateInstance.Input.Body {
        .json(.init(data: .init(
            attributes: .init(
                customAppName: input.customAppName,
                locale: input.locale,
                name: input.name
            ),
            relationships: .init(
                subscriptionGroup: .init(data: .init(id: input.groupID, _type: .subscriptionGroups))
            ),
            _type: .subscriptionGroupLocalizations
        )))
    }

    private func subscriptionGroupLocalizationUpdateBody(
        from input: AppStoreConnectSubscriptionGroupLocalizationUpdateInput
    ) -> Operations.SubscriptionGroupLocalizationsUpdateInstance.Input.Body {
        .json(.init(data: .init(
            attributes: .init(
                customAppName: input.customAppName,
                name: input.name
            ),
            id: input.id,
            _type: .subscriptionGroupLocalizations
        )))
    }

    private func winBackOfferCreateBody(
        from input: AppStoreConnectWinBackOfferCreateInput
    ) throws -> Operations.WinBackOffersCreateInstance.Input.Body {
        guard !input.priceIDs.isEmpty else {
            throw AppStoreConnectError.invalidConfiguration("Specify at least one win-back offer price ID.")
        }

        return .json(.init(data: .init(
            attributes: .init(
                customerEligibilityPaidSubscriptionDurationInMonths: input.paidSubscriptionDurationMonths,
                customerEligibilityTimeSinceLastSubscribedInMonths: .init(
                    maximum: input.lastSubscribedMaxMonths,
                    minimum: input.lastSubscribedMinMonths
                ),
                customerEligibilityWaitBetweenOffersInMonths: input.waitBetweenOffersMonths,
                duration: try requiredSubscriptionOfferDuration(input.duration),
                endDate: input.endDate,
                offerId: input.offerID,
                offerMode: try requiredSubscriptionOfferMode(input.offerMode),
                periodCount: input.periodCount,
                priority: try requiredWinBackOfferPriority(input.priority),
                promotionIntent: try optionalWinBackOfferPromotionIntent(input.promotionIntent),
                referenceName: input.referenceName,
                startDate: input.startDate
            ),
            relationships: .init(
                prices: .init(data: input.priceIDs.map { .init(id: $0, _type: .winBackOfferPrices) }),
                subscription: .init(data: .init(id: input.subscriptionID, _type: .subscriptions))
            ),
            _type: .winBackOffers
        )))
    }

    private func winBackOfferUpdateBody(
        from input: AppStoreConnectWinBackOfferUpdateInput
    ) throws -> Operations.WinBackOffersUpdateInstance.Input.Body {
        .json(.init(data: .init(
            attributes: .init(
                customerEligibilityPaidSubscriptionDurationInMonths: input.paidSubscriptionDurationMonths,
                customerEligibilityTimeSinceLastSubscribedInMonths: optionalIntegerRange(
                    minimum: input.lastSubscribedMinMonths,
                    maximum: input.lastSubscribedMaxMonths
                ),
                customerEligibilityWaitBetweenOffersInMonths: input.waitBetweenOffersMonths,
                endDate: input.endDate,
                priority: try optionalWinBackOfferUpdatePriority(input.priority),
                promotionIntent: try optionalWinBackOfferUpdatePromotionIntent(input.promotionIntent),
                startDate: input.startDate
            ),
            id: input.id,
            _type: .winBackOffers
        )))
    }

    private func optionalIntegerRange(minimum: Int?, maximum: Int?) -> Components.Schemas.IntegerRange? {
        guard minimum != nil || maximum != nil else {
            return nil
        }
        return Components.Schemas.IntegerRange(maximum: maximum, minimum: minimum)
    }

    private func requiredInAppPurchaseType(_ value: String) throws -> Components.Schemas.InAppPurchaseType {
        guard let type = Components.Schemas.InAppPurchaseType(rawValue: value) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported in-app purchase type: \(value)")
        }
        return type
    }

    private func requiredSubscriptionOfferDuration(_ value: String) throws -> Components.Schemas.SubscriptionOfferDuration {
        guard let duration = Components.Schemas.SubscriptionOfferDuration(rawValue: value) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported subscription offer duration: \(value)")
        }
        return duration
    }

    private func requiredSubscriptionOfferMode(_ value: String) throws -> Components.Schemas.SubscriptionOfferMode {
        guard let mode = Components.Schemas.SubscriptionOfferMode(rawValue: value) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported subscription offer mode: \(value)")
        }
        return mode
    }

    private func requiredWinBackOfferPriority(
        _ value: String
    ) throws -> Components.Schemas.WinBackOfferCreateRequest.DataPayload.AttributesPayload.PriorityPayload {
        guard let priority = Components.Schemas.WinBackOfferCreateRequest.DataPayload.AttributesPayload.PriorityPayload(rawValue: value) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported win-back offer priority: \(value)")
        }
        return priority
    }

    private func optionalWinBackOfferPromotionIntent(
        _ value: String?
    ) throws -> Components.Schemas.WinBackOfferCreateRequest.DataPayload.AttributesPayload.PromotionIntentPayload? {
        guard let value else { return nil }
        guard let intent = Components.Schemas.WinBackOfferCreateRequest.DataPayload.AttributesPayload.PromotionIntentPayload(rawValue: value) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported win-back offer promotion intent: \(value)")
        }
        return intent
    }

    private func optionalWinBackOfferUpdatePriority(
        _ value: String?
    ) throws -> Components.Schemas.WinBackOfferUpdateRequest.DataPayload.AttributesPayload.PriorityPayload? {
        guard let value else { return nil }
        guard let priority = Components.Schemas.WinBackOfferUpdateRequest.DataPayload.AttributesPayload.PriorityPayload(rawValue: value) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported win-back offer priority: \(value)")
        }
        return priority
    }

    private func optionalWinBackOfferUpdatePromotionIntent(
        _ value: String?
    ) throws -> Components.Schemas.WinBackOfferUpdateRequest.DataPayload.AttributesPayload.PromotionIntentPayload? {
        guard let value else { return nil }
        guard let intent = Components.Schemas.WinBackOfferUpdateRequest.DataPayload.AttributesPayload.PromotionIntentPayload(rawValue: value) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported win-back offer promotion intent: \(value)")
        }
        return intent
    }

    private func optionalCreateSubscriptionPeriod(
        _ value: String?
    ) throws -> Components.Schemas.SubscriptionCreateRequest.DataPayload.AttributesPayload.SubscriptionPeriodPayload? {
        guard let value else { return nil }
        guard let period = Components.Schemas.SubscriptionCreateRequest.DataPayload.AttributesPayload.SubscriptionPeriodPayload(rawValue: value) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported subscription period: \(value)")
        }
        return period
    }

    private func optionalUpdateSubscriptionPeriod(
        _ value: String?
    ) throws -> Components.Schemas.SubscriptionUpdateRequest.DataPayload.AttributesPayload.SubscriptionPeriodPayload? {
        guard let value else { return nil }
        guard let period = Components.Schemas.SubscriptionUpdateRequest.DataPayload.AttributesPayload.SubscriptionPeriodPayload(rawValue: value) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported subscription period: \(value)")
        }
        return period
    }

    private static func joined(_ values: [String]) -> String? {
        values.isEmpty ? nil : values.joined(separator: ",")
    }

}

private extension Array {
    var nilIfEmpty: [Element]? {
        isEmpty ? nil : self
    }
}
#endif
