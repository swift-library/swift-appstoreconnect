import AppStoreConnectCore
import AppStoreConnectPublicAPI
import Foundation

public struct AppStoreConnectPublicAPIMutationPlan: Codable, Sendable, Equatable {
    public var operationID: String
    public var commandDescription: String
    public var source: WorkflowStepSource
    public var mutates: Bool
    public var dryRun: Bool
    public var inputs: [String: String]

    public init(
        operationID: String,
        commandDescription: String,
        source: WorkflowStepSource = .publicAPIBacked,
        mutates: Bool = true,
        dryRun: Bool = true,
        inputs: [String: String] = [:]
    ) {
        self.operationID = operationID
        self.commandDescription = commandDescription
        self.source = source
        self.mutates = mutates
        self.dryRun = dryRun
        self.inputs = inputs
    }
}

public struct AppStoreConnectBetaTesterInvitationCreateInput: Codable, Sendable, Equatable {
    public var appID: String

    public init(appID: String) {
        self.appID = appID
    }
}

public struct AppStoreConnectBetaGroupCreateInput: Codable, Sendable, Equatable {
    public var appID: String
    public var name: String
    public var feedbackEnabled: Bool?
    public var hasAccessToAllBuilds: Bool?
    public var isInternalGroup: Bool?
    public var publicLinkEnabled: Bool?
    public var publicLinkLimit: Int?
    public var publicLinkLimitEnabled: Bool?
    public var betaTesterIDs: [String]
    public var buildIDs: [String]

    public init(
        appID: String,
        name: String,
        feedbackEnabled: Bool? = nil,
        hasAccessToAllBuilds: Bool? = nil,
        isInternalGroup: Bool? = nil,
        publicLinkEnabled: Bool? = nil,
        publicLinkLimit: Int? = nil,
        publicLinkLimitEnabled: Bool? = nil,
        betaTesterIDs: [String] = [],
        buildIDs: [String] = []
    ) {
        self.appID = appID
        self.name = name
        self.feedbackEnabled = feedbackEnabled
        self.hasAccessToAllBuilds = hasAccessToAllBuilds
        self.isInternalGroup = isInternalGroup
        self.publicLinkEnabled = publicLinkEnabled
        self.publicLinkLimit = publicLinkLimit
        self.publicLinkLimitEnabled = publicLinkLimitEnabled
        self.betaTesterIDs = betaTesterIDs
        self.buildIDs = buildIDs
    }
}

public struct AppStoreConnectBetaGroupUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var name: String?
    public var feedbackEnabled: Bool?
    public var publicLinkEnabled: Bool?
    public var publicLinkLimit: Int?
    public var publicLinkLimitEnabled: Bool?
    public var iosBuildsAvailableForAppleSiliconMac: Bool?
    public var iosBuildsAvailableForAppleVision: Bool?

    public init(
        id: String,
        name: String? = nil,
        feedbackEnabled: Bool? = nil,
        publicLinkEnabled: Bool? = nil,
        publicLinkLimit: Int? = nil,
        publicLinkLimitEnabled: Bool? = nil,
        iosBuildsAvailableForAppleSiliconMac: Bool? = nil,
        iosBuildsAvailableForAppleVision: Bool? = nil
    ) {
        self.id = id
        self.name = name
        self.feedbackEnabled = feedbackEnabled
        self.publicLinkEnabled = publicLinkEnabled
        self.publicLinkLimit = publicLinkLimit
        self.publicLinkLimitEnabled = publicLinkLimitEnabled
        self.iosBuildsAvailableForAppleSiliconMac = iosBuildsAvailableForAppleSiliconMac
        self.iosBuildsAvailableForAppleVision = iosBuildsAvailableForAppleVision
    }
}

public struct AppStoreConnectBetaGroupDeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectBetaTesterCreateInput: Codable, Sendable, Equatable {
    public var email: String
    public var firstName: String?
    public var lastName: String?
    public var betaGroupIDs: [String]
    public var buildIDs: [String]

    public init(
        email: String,
        firstName: String? = nil,
        lastName: String? = nil,
        betaGroupIDs: [String] = [],
        buildIDs: [String] = []
    ) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.betaGroupIDs = betaGroupIDs
        self.buildIDs = buildIDs
    }
}

public struct AppStoreConnectBetaTesterDeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectBetaAppReviewDetailUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var contactEmail: String?
    public var contactFirstName: String?
    public var contactLastName: String?
    public var contactPhone: String?
    public var demoAccountName: String?
    public var demoAccountPassword: String?
    public var demoAccountRequired: Bool?
    public var notes: String?

    public init(
        id: String,
        contactEmail: String? = nil,
        contactFirstName: String? = nil,
        contactLastName: String? = nil,
        contactPhone: String? = nil,
        demoAccountName: String? = nil,
        demoAccountPassword: String? = nil,
        demoAccountRequired: Bool? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.contactEmail = contactEmail
        self.contactFirstName = contactFirstName
        self.contactLastName = contactLastName
        self.contactPhone = contactPhone
        self.demoAccountName = demoAccountName
        self.demoAccountPassword = demoAccountPassword
        self.demoAccountRequired = demoAccountRequired
        self.notes = notes
    }
}

public struct AppStoreConnectBetaAppReviewSubmissionCreateInput: Codable, Sendable, Equatable {
    public var buildID: String

    public init(buildID: String) {
        self.buildID = buildID
    }
}

public struct AppStoreConnectAppUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var primaryLocale: String?
    public var contentRightsDeclaration: String?
    public var accessibilityURL: String?
    public var subscriptionStatusURL: String?
    public var subscriptionStatusURLForSandbox: String?
    public var streamlinedPurchasingEnabled: Bool?

    public init(
        id: String,
        primaryLocale: String? = nil,
        contentRightsDeclaration: String? = nil,
        accessibilityURL: String? = nil,
        subscriptionStatusURL: String? = nil,
        subscriptionStatusURLForSandbox: String? = nil,
        streamlinedPurchasingEnabled: Bool? = nil
    ) {
        self.id = id
        self.primaryLocale = primaryLocale
        self.contentRightsDeclaration = contentRightsDeclaration
        self.accessibilityURL = accessibilityURL
        self.subscriptionStatusURL = subscriptionStatusURL
        self.subscriptionStatusURLForSandbox = subscriptionStatusURLForSandbox
        self.streamlinedPurchasingEnabled = streamlinedPurchasingEnabled
    }
}

public struct AppStoreConnectAppStoreVersionCreateInput: Codable, Sendable, Equatable {
    public var appID: String
    public var versionString: String
    public var platform: String
    public var buildID: String?
    public var copyright: String?
    public var earliestReleaseDate: Date?
    public var releaseType: String?
    public var reviewType: String?

    public init(
        appID: String,
        versionString: String,
        platform: String,
        buildID: String? = nil,
        copyright: String? = nil,
        earliestReleaseDate: Date? = nil,
        releaseType: String? = nil,
        reviewType: String? = nil
    ) {
        self.appID = appID
        self.versionString = versionString
        self.platform = platform
        self.buildID = buildID
        self.copyright = copyright
        self.earliestReleaseDate = earliestReleaseDate
        self.releaseType = releaseType
        self.reviewType = reviewType
    }
}

public struct AppStoreConnectAppStoreVersionUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var versionString: String?
    public var buildID: String?
    public var copyright: String?
    public var downloadable: Bool?
    public var earliestReleaseDate: Date?
    public var releaseType: String?
    public var reviewType: String?

    public init(
        id: String,
        versionString: String? = nil,
        buildID: String? = nil,
        copyright: String? = nil,
        downloadable: Bool? = nil,
        earliestReleaseDate: Date? = nil,
        releaseType: String? = nil,
        reviewType: String? = nil
    ) {
        self.id = id
        self.versionString = versionString
        self.buildID = buildID
        self.copyright = copyright
        self.downloadable = downloadable
        self.earliestReleaseDate = earliestReleaseDate
        self.releaseType = releaseType
        self.reviewType = reviewType
    }
}

public struct AppStoreConnectAppStoreVersionDeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectAppStoreVersionReleaseRequestCreateInput: Codable, Sendable, Equatable {
    public var appStoreVersionID: String

    public init(appStoreVersionID: String) {
        self.appStoreVersionID = appStoreVersionID
    }
}

public struct AppStoreConnectReviewSubmissionCreateInput: Codable, Sendable, Equatable {
    public var appID: String
    public var platform: String?

    public init(appID: String, platform: String? = nil) {
        self.appID = appID
        self.platform = platform
    }
}

public struct AppStoreConnectReviewSubmissionUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var submitted: Bool?
    public var canceled: Bool?
    public var platform: String?

    public init(
        id: String,
        submitted: Bool? = nil,
        canceled: Bool? = nil,
        platform: String? = nil
    ) {
        self.id = id
        self.submitted = submitted
        self.canceled = canceled
        self.platform = platform
    }
}

public struct AppStoreConnectReviewSubmissionItemCreateInput: Codable, Sendable, Equatable {
    public var reviewSubmissionID: String
    public var appStoreVersionID: String

    public init(reviewSubmissionID: String, appStoreVersionID: String) {
        self.reviewSubmissionID = reviewSubmissionID
        self.appStoreVersionID = appStoreVersionID
    }
}

public struct AppStoreConnectReviewSubmissionItemUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var removed: Bool?
    public var resolved: Bool?

    public init(id: String, removed: Bool? = nil, resolved: Bool? = nil) {
        self.id = id
        self.removed = removed
        self.resolved = resolved
    }
}

public struct AppStoreConnectReviewSubmissionItemDeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectCustomerReviewResponseCreateInput: Codable, Sendable, Equatable {
    public var reviewID: String
    public var responseBody: String

    public init(reviewID: String, responseBody: String) {
        self.reviewID = reviewID
        self.responseBody = responseBody
    }
}

public struct AppStoreConnectCustomerReviewResponseDeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectAppEventCreateInput: Codable, Sendable, Equatable {
    public var appID: String
    public var referenceName: String
    public var badge: String?
    public var deepLink: String?
    public var primaryLocale: String?
    public var priority: String?
    public var purchaseRequirement: String?
    public var purpose: String?

    public init(
        appID: String,
        referenceName: String,
        badge: String? = nil,
        deepLink: String? = nil,
        primaryLocale: String? = nil,
        priority: String? = nil,
        purchaseRequirement: String? = nil,
        purpose: String? = nil
    ) {
        self.appID = appID
        self.referenceName = referenceName
        self.badge = badge
        self.deepLink = deepLink
        self.primaryLocale = primaryLocale
        self.priority = priority
        self.purchaseRequirement = purchaseRequirement
        self.purpose = purpose
    }
}

public struct AppStoreConnectAppEventUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var referenceName: String?
    public var badge: String?
    public var deepLink: String?
    public var primaryLocale: String?
    public var priority: String?
    public var purchaseRequirement: String?
    public var purpose: String?

    public init(
        id: String,
        referenceName: String? = nil,
        badge: String? = nil,
        deepLink: String? = nil,
        primaryLocale: String? = nil,
        priority: String? = nil,
        purchaseRequirement: String? = nil,
        purpose: String? = nil
    ) {
        self.id = id
        self.referenceName = referenceName
        self.badge = badge
        self.deepLink = deepLink
        self.primaryLocale = primaryLocale
        self.priority = priority
        self.purchaseRequirement = purchaseRequirement
        self.purpose = purpose
    }
}

public struct AppStoreConnectAppEventDeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectAppCategoryUpdateInput: Codable, Sendable, Equatable {
    public var appInfoID: String
    public var primaryCategoryID: String?
    public var secondaryCategoryID: String?
    public var primarySubcategoryOneID: String?
    public var primarySubcategoryTwoID: String?
    public var secondarySubcategoryOneID: String?
    public var secondarySubcategoryTwoID: String?

    public init(
        appInfoID: String,
        primaryCategoryID: String? = nil,
        secondaryCategoryID: String? = nil,
        primarySubcategoryOneID: String? = nil,
        primarySubcategoryTwoID: String? = nil,
        secondarySubcategoryOneID: String? = nil,
        secondarySubcategoryTwoID: String? = nil
    ) {
        self.appInfoID = appInfoID
        self.primaryCategoryID = primaryCategoryID
        self.secondaryCategoryID = secondaryCategoryID
        self.primarySubcategoryOneID = primarySubcategoryOneID
        self.primarySubcategoryTwoID = primarySubcategoryTwoID
        self.secondarySubcategoryOneID = secondarySubcategoryOneID
        self.secondarySubcategoryTwoID = secondarySubcategoryTwoID
    }
}

public struct AppStoreConnectAgeRatingUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var frequencyRatings: [String: String]
    public var booleanRatings: [String: Bool]
    public var kidsAgeBand: String?
    public var ageRatingOverrideV2: String?
    public var koreaAgeRatingOverride: String?
    public var developerAgeRatingInfoURL: String?
    public var allNone: Bool

    public init(
        id: String,
        frequencyRatings: [String: String] = [:],
        booleanRatings: [String: Bool] = [:],
        kidsAgeBand: String? = nil,
        ageRatingOverrideV2: String? = nil,
        koreaAgeRatingOverride: String? = nil,
        developerAgeRatingInfoURL: String? = nil,
        allNone: Bool = false
    ) {
        self.id = id
        self.frequencyRatings = frequencyRatings
        self.booleanRatings = booleanRatings
        self.kidsAgeBand = kidsAgeBand
        self.ageRatingOverrideV2 = ageRatingOverrideV2
        self.koreaAgeRatingOverride = koreaAgeRatingOverride
        self.developerAgeRatingInfoURL = developerAgeRatingInfoURL
        self.allNone = allNone
    }
}

public struct AppStoreConnectAppCategoryAssignmentSummary: Codable, Sendable, Equatable {
    public var appInfoID: String
    public var primaryCategoryID: String?
    public var secondaryCategoryID: String?
    public var primarySubcategoryOneID: String?
    public var primarySubcategoryTwoID: String?
    public var secondarySubcategoryOneID: String?
    public var secondarySubcategoryTwoID: String?

    public init(
        appInfoID: String,
        primaryCategoryID: String? = nil,
        secondaryCategoryID: String? = nil,
        primarySubcategoryOneID: String? = nil,
        primarySubcategoryTwoID: String? = nil,
        secondarySubcategoryOneID: String? = nil,
        secondarySubcategoryTwoID: String? = nil
    ) {
        self.appInfoID = appInfoID
        self.primaryCategoryID = primaryCategoryID
        self.secondaryCategoryID = secondaryCategoryID
        self.primarySubcategoryOneID = primarySubcategoryOneID
        self.primarySubcategoryTwoID = primarySubcategoryTwoID
        self.secondarySubcategoryOneID = secondarySubcategoryOneID
        self.secondarySubcategoryTwoID = secondarySubcategoryTwoID
    }
}

public struct AppStoreConnectWebhookCreateInput: Codable, Sendable, Equatable {
    public var appID: String
    public var name: String
    public var url: String
    public var secret: String
    public var eventTypes: [String]
    public var enabled: Bool

    public init(
        appID: String,
        name: String,
        url: String,
        secret: String,
        eventTypes: [String],
        enabled: Bool
    ) {
        self.appID = appID
        self.name = name
        self.url = url
        self.secret = secret
        self.eventTypes = eventTypes
        self.enabled = enabled
    }
}

public struct AppStoreConnectWebhookUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var name: String?
    public var url: String?
    public var secret: String?
    public var eventTypes: [String]
    public var enabled: Bool?

    public init(
        id: String,
        name: String? = nil,
        url: String? = nil,
        secret: String? = nil,
        eventTypes: [String] = [],
        enabled: Bool? = nil
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.secret = secret
        self.eventTypes = eventTypes
        self.enabled = enabled
    }
}

public struct AppStoreConnectWebhookDeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectWebhookDeliveryRedeliverInput: Codable, Sendable, Equatable {
    public var deliveryID: String

    public init(deliveryID: String) {
        self.deliveryID = deliveryID
    }
}

public struct AppStoreConnectWebhookPingInput: Codable, Sendable, Equatable {
    public var webhookID: String

    public init(webhookID: String) {
        self.webhookID = webhookID
    }
}

public struct AppStoreConnectEULACreateInput: Codable, Sendable, Equatable {
    public var appID: String
    public var agreementText: String
    public var territoryIDs: [String]

    public init(appID: String, agreementText: String, territoryIDs: [String]) {
        self.appID = appID
        self.agreementText = agreementText
        self.territoryIDs = territoryIDs
    }
}

public struct AppStoreConnectEULAUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var agreementText: String?
    public var territoryIDs: [String]

    public init(id: String, agreementText: String? = nil, territoryIDs: [String] = []) {
        self.id = id
        self.agreementText = agreementText
        self.territoryIDs = territoryIDs
    }
}

public struct AppStoreConnectEULADeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectBundleIDCreateInput: Codable, Sendable, Equatable {
    public var identifier: String
    public var name: String
    public var platform: String
    public var seedID: String?

    public init(identifier: String, name: String, platform: String, seedID: String? = nil) {
        self.identifier = identifier
        self.name = name
        self.platform = platform
        self.seedID = seedID
    }
}

public struct AppStoreConnectBundleIDUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var name: String?

    public init(id: String, name: String? = nil) {
        self.id = id
        self.name = name
    }
}

public struct AppStoreConnectBundleIDDeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectBundleIDCapabilityCreateInput: Codable, Sendable, Equatable {
    public var bundleID: String
    public var capabilityType: String
    public var settingsJSON: String?

    public init(bundleID: String, capabilityType: String, settingsJSON: String? = nil) {
        self.bundleID = bundleID
        self.capabilityType = capabilityType
        self.settingsJSON = settingsJSON
    }
}

public struct AppStoreConnectBundleIDCapabilityUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var capabilityType: String?
    public var settingsJSON: String?

    public init(id: String, capabilityType: String? = nil, settingsJSON: String? = nil) {
        self.id = id
        self.capabilityType = capabilityType
        self.settingsJSON = settingsJSON
    }
}

public struct AppStoreConnectBundleIDCapabilityDeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectCertificateCreateInput: Codable, Sendable, Equatable {
    public var certificateType: String
    public var csrContent: String
    public var merchantID: String?
    public var passTypeID: String?

    public init(
        certificateType: String,
        csrContent: String,
        merchantID: String? = nil,
        passTypeID: String? = nil
    ) {
        self.certificateType = certificateType
        self.csrContent = csrContent
        self.merchantID = merchantID
        self.passTypeID = passTypeID
    }
}

public struct AppStoreConnectCertificateUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var activated: Bool?

    public init(id: String, activated: Bool? = nil) {
        self.id = id
        self.activated = activated
    }
}

public struct AppStoreConnectCertificateDeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectDeviceCreateInput: Codable, Sendable, Equatable {
    public var name: String
    public var udid: String
    public var platform: String

    public init(name: String, udid: String, platform: String) {
        self.name = name
        self.udid = udid
        self.platform = platform
    }
}

public struct AppStoreConnectDeviceUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var name: String?
    public var status: String?

    public init(id: String, name: String? = nil, status: String? = nil) {
        self.id = id
        self.name = name
        self.status = status
    }
}

public struct AppStoreConnectProfileCreateInput: Codable, Sendable, Equatable {
    public var name: String
    public var profileType: String
    public var bundleID: String
    public var certificateIDs: [String]
    public var deviceIDs: [String]

    public init(
        name: String,
        profileType: String,
        bundleID: String,
        certificateIDs: [String],
        deviceIDs: [String] = []
    ) {
        self.name = name
        self.profileType = profileType
        self.bundleID = bundleID
        self.certificateIDs = certificateIDs
        self.deviceIDs = deviceIDs
    }
}

public struct AppStoreConnectProfileDeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectUserInvitationCreateInput: Codable, Sendable, Equatable {
    public var email: String
    public var firstName: String
    public var lastName: String
    public var roles: [String]
    public var allAppsVisible: Bool?
    public var provisioningAllowed: Bool?
    public var visibleAppIDs: [String]

    public init(
        email: String,
        firstName: String,
        lastName: String,
        roles: [String],
        allAppsVisible: Bool? = nil,
        provisioningAllowed: Bool? = nil,
        visibleAppIDs: [String] = []
    ) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.roles = roles
        self.allAppsVisible = allAppsVisible
        self.provisioningAllowed = provisioningAllowed
        self.visibleAppIDs = visibleAppIDs
    }
}

public struct AppStoreConnectUserInvitationDeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectUserUpdateInput: Codable, Sendable, Equatable {
    public var id: String
    public var roles: [String]
    public var allAppsVisible: Bool?
    public var provisioningAllowed: Bool?
    public var visibleAppIDs: [String]

    public init(
        id: String,
        roles: [String] = [],
        allAppsVisible: Bool? = nil,
        provisioningAllowed: Bool? = nil,
        visibleAppIDs: [String] = []
    ) {
        self.id = id
        self.roles = roles
        self.allAppsVisible = allAppsVisible
        self.provisioningAllowed = provisioningAllowed
        self.visibleAppIDs = visibleAppIDs
    }
}

public struct AppStoreConnectUserDeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectBetaTesterInvitationSummary: Codable, Sendable, Equatable {
    public var id: String
    public var appID: String

    public init(id: String, appID: String) {
        self.id = id
        self.appID = appID
    }
}

public struct AppStoreConnectAppStoreVersionReleaseRequestSummary: Codable, Sendable, Equatable {
    public var id: String
    public var appStoreVersionID: String?

    public init(id: String, appStoreVersionID: String? = nil) {
        self.id = id
        self.appStoreVersionID = appStoreVersionID
    }
}

public struct AppStoreConnectReviewSubmissionItemSummary: Codable, Sendable, Equatable {
    public var id: String
    public var state: String?
    public var reviewSubmissionID: String?
    public var appStoreVersionID: String?

    public init(
        id: String,
        state: String? = nil,
        reviewSubmissionID: String? = nil,
        appStoreVersionID: String? = nil
    ) {
        self.id = id
        self.state = state
        self.reviewSubmissionID = reviewSubmissionID
        self.appStoreVersionID = appStoreVersionID
    }
}

public struct AppStoreConnectWebhookPingSummary: Codable, Sendable, Equatable {
    public var id: String
    public var webhookID: String

    public init(id: String, webhookID: String) {
        self.id = id
        self.webhookID = webhookID
    }
}

public struct AppStoreConnectMutationAcknowledgement: Codable, Sendable, Equatable {
    public var operationID: String
    public var resourceType: String
    public var id: String
    public var status: String

    public init(operationID: String, resourceType: String, id: String, status: String) {
        self.operationID = operationID
        self.resourceType = resourceType
        self.id = id
        self.status = status
    }
}

public typealias AppStoreConnectBetaTesterInvitationResult = AppStoreConnectResourceResult<AppStoreConnectBetaTesterInvitationSummary>
public typealias AppStoreConnectAppStoreVersionReleaseRequestResult = AppStoreConnectResourceResult<AppStoreConnectAppStoreVersionReleaseRequestSummary>
public typealias AppStoreConnectReviewSubmissionItemResult = AppStoreConnectResourceResult<AppStoreConnectReviewSubmissionItemSummary>
public typealias AppStoreConnectAppEventMutationResult = AppStoreConnectResourceResult<AppStoreConnectAppEventSummary>
public typealias AppStoreConnectCustomerReviewResponseMutationResult = AppStoreConnectResourceResult<AppStoreConnectCustomerReviewResponseSummary>
public typealias AppStoreConnectAppCategoryAssignmentResult = AppStoreConnectResourceResult<AppStoreConnectAppCategoryAssignmentSummary>
public typealias AppStoreConnectWebhookMutationResult = AppStoreConnectResourceResult<AppStoreConnectWebhookSummary>
public typealias AppStoreConnectWebhookDeliveryMutationResult = AppStoreConnectResourceResult<AppStoreConnectWebhookDeliverySummary>
public typealias AppStoreConnectWebhookPingResult = AppStoreConnectResourceResult<AppStoreConnectWebhookPingSummary>
public typealias AppStoreConnectMutationAcknowledgementResult = AppStoreConnectResourceResult<AppStoreConnectMutationAcknowledgement>

public struct PublicAPIWriteCommands: Sendable {
    public let client: AppStoreConnectPublicClient

    public init(client: AppStoreConnectPublicClient) {
        self.client = client
    }

    public static func planCreateBetaTesterInvitation(
        _ input: AppStoreConnectBetaTesterInvitationCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.BetaTesterInvitationsCreateInstance.id,
            commandDescription: "Create a TestFlight beta tester invitation for app \(input.appID).",
            inputs: ["appID": input.appID]
        )
    }

    public static func planCreateBetaGroup(
        _ input: AppStoreConnectBetaGroupCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.BetaGroupsCreateInstance.id,
            commandDescription: "Create TestFlight beta group \(input.name) for app \(input.appID).",
            inputs: compactInputs([
                ("appID", input.appID),
                ("name", input.name),
                ("feedbackEnabled", input.feedbackEnabled.map(String.init)),
                ("hasAccessToAllBuilds", input.hasAccessToAllBuilds.map(String.init)),
                ("isInternalGroup", input.isInternalGroup.map(String.init)),
                ("publicLinkEnabled", input.publicLinkEnabled.map(String.init)),
                ("publicLinkLimit", input.publicLinkLimit.map(String.init)),
                ("publicLinkLimitEnabled", input.publicLinkLimitEnabled.map(String.init)),
                ("betaTesterIDs", joined(input.betaTesterIDs)),
                ("buildIDs", joined(input.buildIDs)),
            ])
        )
    }

    public static func planUpdateBetaGroup(
        _ input: AppStoreConnectBetaGroupUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.BetaGroupsUpdateInstance.id,
            commandDescription: "Update TestFlight beta group \(input.id).",
            inputs: compactInputs([
                ("id", input.id),
                ("name", input.name),
                ("feedbackEnabled", input.feedbackEnabled.map(String.init)),
                ("publicLinkEnabled", input.publicLinkEnabled.map(String.init)),
                ("publicLinkLimit", input.publicLinkLimit.map(String.init)),
                ("publicLinkLimitEnabled", input.publicLinkLimitEnabled.map(String.init)),
                ("iosBuildsAvailableForAppleSiliconMac", input.iosBuildsAvailableForAppleSiliconMac.map(String.init)),
                ("iosBuildsAvailableForAppleVision", input.iosBuildsAvailableForAppleVision.map(String.init)),
            ])
        )
    }

    public static func planDeleteBetaGroup(
        _ input: AppStoreConnectBetaGroupDeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.BetaGroupsDeleteInstance.id,
            commandDescription: "Delete TestFlight beta group \(input.id).",
            inputs: ["id": input.id]
        )
    }

    public static func planCreateBetaTester(
        _ input: AppStoreConnectBetaTesterCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.BetaTestersCreateInstance.id,
            commandDescription: "Create TestFlight beta tester \(input.email).",
            inputs: compactInputs([
                ("email", input.email),
                ("firstName", input.firstName),
                ("lastName", input.lastName),
                ("betaGroupIDs", joined(input.betaGroupIDs)),
                ("buildIDs", joined(input.buildIDs)),
            ])
        )
    }

    public static func planDeleteBetaTester(
        _ input: AppStoreConnectBetaTesterDeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.BetaTestersDeleteInstance.id,
            commandDescription: "Delete TestFlight beta tester \(input.id).",
            inputs: ["id": input.id]
        )
    }

    public static func planUpdateBetaAppReviewDetail(
        _ input: AppStoreConnectBetaAppReviewDetailUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.BetaAppReviewDetailsUpdateInstance.id,
            commandDescription: "Update TestFlight beta app review detail \(input.id).",
            inputs: compactInputs([
                ("id", input.id),
                ("contactEmail", input.contactEmail),
                ("contactFirstName", input.contactFirstName),
                ("contactLastName", input.contactLastName),
                ("contactPhone", input.contactPhone),
                ("demoAccountName", input.demoAccountName),
                ("demoAccountRequired", input.demoAccountRequired.map(String.init)),
                ("notes", input.notes),
            ])
        )
    }

    public static func planCreateBetaAppReviewSubmission(
        _ input: AppStoreConnectBetaAppReviewSubmissionCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.BetaAppReviewSubmissionsCreateInstance.id,
            commandDescription: "Create TestFlight beta app review submission for build \(input.buildID).",
            inputs: ["buildID": input.buildID]
        )
    }

    public static func planUpdateApp(
        _ input: AppStoreConnectAppUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.AppsUpdateInstance.id,
            commandDescription: "Update app \(input.id).",
            inputs: compactInputs([
                ("id", input.id),
                ("primaryLocale", input.primaryLocale),
                ("contentRightsDeclaration", input.contentRightsDeclaration),
                ("accessibilityURL", input.accessibilityURL),
                ("subscriptionStatusURL", input.subscriptionStatusURL),
                ("subscriptionStatusURLForSandbox", input.subscriptionStatusURLForSandbox),
                ("streamlinedPurchasingEnabled", input.streamlinedPurchasingEnabled.map(String.init)),
            ])
        )
    }

    public static func planCreateAppStoreVersion(
        _ input: AppStoreConnectAppStoreVersionCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.AppStoreVersionsCreateInstance.id,
            commandDescription: "Create App Store version \(input.versionString) for app \(input.appID).",
            inputs: compactInputs([
                ("appID", input.appID),
                ("versionString", input.versionString),
                ("platform", input.platform),
                ("buildID", input.buildID),
                ("copyright", input.copyright),
                ("earliestReleaseDate", input.earliestReleaseDate.map(iso8601String)),
                ("releaseType", input.releaseType),
                ("reviewType", input.reviewType),
            ])
        )
    }

    public static func planUpdateAppStoreVersion(
        _ input: AppStoreConnectAppStoreVersionUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.AppStoreVersionsUpdateInstance.id,
            commandDescription: "Update App Store version \(input.id).",
            inputs: compactInputs([
                ("id", input.id),
                ("versionString", input.versionString),
                ("buildID", input.buildID),
                ("copyright", input.copyright),
                ("downloadable", input.downloadable.map(String.init)),
                ("earliestReleaseDate", input.earliestReleaseDate.map(iso8601String)),
                ("releaseType", input.releaseType),
                ("reviewType", input.reviewType),
            ])
        )
    }

    public static func planDeleteAppStoreVersion(
        _ input: AppStoreConnectAppStoreVersionDeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.AppStoreVersionsDeleteInstance.id,
            commandDescription: "Delete App Store version \(input.id).",
            inputs: ["id": input.id]
        )
    }

    public static func planCreateAppStoreVersionReleaseRequest(
        _ input: AppStoreConnectAppStoreVersionReleaseRequestCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.AppStoreVersionReleaseRequestsCreateInstance.id,
            commandDescription: "Request release for App Store version \(input.appStoreVersionID).",
            inputs: ["appStoreVersionID": input.appStoreVersionID]
        )
    }

    public static func planCreateReviewSubmission(
        _ input: AppStoreConnectReviewSubmissionCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.ReviewSubmissionsCreateInstance.id,
            commandDescription: "Create App Review submission for app \(input.appID).",
            inputs: compactInputs([
                ("appID", input.appID),
                ("platform", input.platform),
            ])
        )
    }

    public static func planUpdateReviewSubmission(
        _ input: AppStoreConnectReviewSubmissionUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.ReviewSubmissionsUpdateInstance.id,
            commandDescription: "Update App Review submission \(input.id).",
            inputs: compactInputs([
                ("id", input.id),
                ("submitted", input.submitted.map(String.init)),
                ("canceled", input.canceled.map(String.init)),
                ("platform", input.platform),
            ])
        )
    }

    public static func planCreateReviewSubmissionItem(
        _ input: AppStoreConnectReviewSubmissionItemCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.ReviewSubmissionItemsCreateInstance.id,
            commandDescription: "Add App Store version \(input.appStoreVersionID) to review submission \(input.reviewSubmissionID).",
            inputs: [
                "appStoreVersionID": input.appStoreVersionID,
                "reviewSubmissionID": input.reviewSubmissionID,
            ]
        )
    }

    public static func planUpdateReviewSubmissionItem(
        _ input: AppStoreConnectReviewSubmissionItemUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.ReviewSubmissionItemsUpdateInstance.id,
            commandDescription: "Update review submission item \(input.id).",
            inputs: compactInputs([
                ("id", input.id),
                ("removed", input.removed.map(String.init)),
                ("resolved", input.resolved.map(String.init)),
            ])
        )
    }

    public static func planDeleteReviewSubmissionItem(
        _ input: AppStoreConnectReviewSubmissionItemDeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.ReviewSubmissionItemsDeleteInstance.id,
            commandDescription: "Delete review submission item \(input.id).",
            inputs: ["id": input.id]
        )
    }

#if ASC_PUBLIC_API_RELEASE
    public static func planCreateCustomerReviewResponse(
        _ input: AppStoreConnectCustomerReviewResponseCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.CustomerReviewResponsesCreateInstance.id,
            commandDescription: "Create response for customer review \(input.reviewID).",
            inputs: [
                "reviewID": input.reviewID,
                "responseBody": input.responseBody,
            ]
        )
    }

    public static func planDeleteCustomerReviewResponse(
        _ input: AppStoreConnectCustomerReviewResponseDeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.CustomerReviewResponsesDeleteInstance.id,
            commandDescription: "Delete customer review response \(input.id).",
            inputs: ["id": input.id]
        )
    }
#endif

#if ASC_PUBLIC_API_RELEASE
    public static func planCreateAppEvent(
        _ input: AppStoreConnectAppEventCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.AppEventsCreateInstance.id,
            commandDescription: "Create app event \(input.referenceName) for app \(input.appID).",
            inputs: compactInputs([
                ("appID", input.appID),
                ("referenceName", input.referenceName),
                ("badge", input.badge),
                ("deepLink", input.deepLink),
                ("primaryLocale", input.primaryLocale),
                ("priority", input.priority),
                ("purchaseRequirement", input.purchaseRequirement),
                ("purpose", input.purpose),
            ])
        )
    }

    public static func planUpdateAppEvent(
        _ input: AppStoreConnectAppEventUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.AppEventsUpdateInstance.id,
            commandDescription: "Update app event \(input.id).",
            inputs: compactInputs([
                ("id", input.id),
                ("referenceName", input.referenceName),
                ("badge", input.badge),
                ("deepLink", input.deepLink),
                ("primaryLocale", input.primaryLocale),
                ("priority", input.priority),
                ("purchaseRequirement", input.purchaseRequirement),
                ("purpose", input.purpose),
            ])
        )
    }

    public static func planDeleteAppEvent(
        _ input: AppStoreConnectAppEventDeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.AppEventsDeleteInstance.id,
            commandDescription: "Delete app event \(input.id).",
            inputs: ["id": input.id]
        )
    }

    public static func planUpdateAppCategory(
        _ input: AppStoreConnectAppCategoryUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.AppInfosUpdateInstance.id,
            commandDescription: "Update app categories for app info \(input.appInfoID).",
            inputs: compactInputs([
                ("appInfoID", input.appInfoID),
                ("primaryCategoryID", input.primaryCategoryID),
                ("secondaryCategoryID", input.secondaryCategoryID),
                ("primarySubcategoryOneID", input.primarySubcategoryOneID),
                ("primarySubcategoryTwoID", input.primarySubcategoryTwoID),
                ("secondarySubcategoryOneID", input.secondarySubcategoryOneID),
                ("secondarySubcategoryTwoID", input.secondarySubcategoryTwoID),
            ])
        )
    }

    public static func planUpdateAgeRating(
        _ input: AppStoreConnectAgeRatingUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.AgeRatingDeclarationsUpdateInstance.id,
            commandDescription: "Update age rating declaration \(input.id).",
            inputs: compactInputs([
                ("id", input.id),
                ("frequencyRatings", joined(input.frequencyRatings.keys.sorted())),
                ("booleanRatings", joined(input.booleanRatings.keys.sorted())),
                ("kidsAgeBand", input.kidsAgeBand),
                ("ageRatingOverrideV2", input.ageRatingOverrideV2),
                ("koreaAgeRatingOverride", input.koreaAgeRatingOverride),
                ("developerAgeRatingInfoURL", input.developerAgeRatingInfoURL),
                ("allNone", input.allNone ? "true" : nil),
            ])
        )
    }
#endif

#if ASC_PUBLIC_API_DISTRIBUTION
    public static func planCreateWebhook(
        _ input: AppStoreConnectWebhookCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.WebhooksCreateInstance.id,
            commandDescription: "Create webhook \(input.name) for app \(input.appID).",
            inputs: compactInputs([
                ("appID", input.appID),
                ("name", input.name),
                ("url", input.url),
                ("secretLength", String(input.secret.count)),
                ("eventTypes", joined(input.eventTypes)),
                ("enabled", String(input.enabled)),
            ])
        )
    }

    public static func planUpdateWebhook(
        _ input: AppStoreConnectWebhookUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.WebhooksUpdateInstance.id,
            commandDescription: "Update webhook \(input.id).",
            inputs: compactInputs([
                ("id", input.id),
                ("name", input.name),
                ("url", input.url),
                ("secretLength", input.secret.map { String($0.count) }),
                ("eventTypes", joined(input.eventTypes)),
                ("enabled", input.enabled.map(String.init)),
            ])
        )
    }

    public static func planDeleteWebhook(
        _ input: AppStoreConnectWebhookDeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.WebhooksDeleteInstance.id,
            commandDescription: "Delete webhook \(input.id).",
            inputs: ["id": input.id]
        )
    }

    public static func planRedeliverWebhookDelivery(
        _ input: AppStoreConnectWebhookDeliveryRedeliverInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.WebhookDeliveriesCreateInstance.id,
            commandDescription: "Redeliver webhook delivery \(input.deliveryID).",
            inputs: ["deliveryID": input.deliveryID]
        )
    }

    public static func planPingWebhook(
        _ input: AppStoreConnectWebhookPingInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.WebhookPingsCreateInstance.id,
            commandDescription: "Create a test ping for webhook \(input.webhookID).",
            inputs: ["webhookID": input.webhookID]
        )
    }

    public static func planCreateEULA(
        _ input: AppStoreConnectEULACreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.EndUserLicenseAgreementsCreateInstance.id,
            commandDescription: "Create custom EULA for app \(input.appID).",
            inputs: compactInputs([
                ("appID", input.appID),
                ("agreementTextLength", String(input.agreementText.count)),
                ("territoryIDs", joined(input.territoryIDs)),
            ])
        )
    }

    public static func planUpdateEULA(
        _ input: AppStoreConnectEULAUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.EndUserLicenseAgreementsUpdateInstance.id,
            commandDescription: "Update custom EULA \(input.id).",
            inputs: compactInputs([
                ("id", input.id),
                ("agreementTextLength", input.agreementText.map { String($0.count) }),
                ("territoryIDs", joined(input.territoryIDs)),
            ])
        )
    }

    public static func planDeleteEULA(
        _ input: AppStoreConnectEULADeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.EndUserLicenseAgreementsDeleteInstance.id,
            commandDescription: "Delete custom EULA \(input.id).",
            inputs: ["id": input.id]
        )
    }
#endif

    public static func planCreateBundleID(
        _ input: AppStoreConnectBundleIDCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.BundleIdsCreateInstance.id,
            commandDescription: "Create bundle ID \(input.identifier).",
            inputs: compactInputs([
                ("identifier", input.identifier),
                ("name", input.name),
                ("platform", input.platform),
                ("seedID", input.seedID),
            ])
        )
    }

    public static func planUpdateBundleID(
        _ input: AppStoreConnectBundleIDUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.BundleIdsUpdateInstance.id,
            commandDescription: "Update bundle ID \(input.id).",
            inputs: compactInputs([
                ("id", input.id),
                ("name", input.name),
            ])
        )
    }

    public static func planDeleteBundleID(
        _ input: AppStoreConnectBundleIDDeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.BundleIdsDeleteInstance.id,
            commandDescription: "Delete bundle ID \(input.id).",
            inputs: ["id": input.id]
        )
    }

    public static func planCreateBundleIDCapability(
        _ input: AppStoreConnectBundleIDCapabilityCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.BundleIdCapabilitiesCreateInstance.id,
            commandDescription: "Enable \(input.capabilityType) for bundle ID \(input.bundleID).",
            inputs: compactInputs([
                ("bundleID", input.bundleID),
                ("capabilityType", input.capabilityType),
                ("settingsJSONLength", input.settingsJSON.map { String($0.count) }),
            ])
        )
    }

    public static func planUpdateBundleIDCapability(
        _ input: AppStoreConnectBundleIDCapabilityUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.BundleIdCapabilitiesUpdateInstance.id,
            commandDescription: "Update bundle ID capability \(input.id).",
            inputs: compactInputs([
                ("id", input.id),
                ("capabilityType", input.capabilityType),
                ("settingsJSONLength", input.settingsJSON.map { String($0.count) }),
            ])
        )
    }

    public static func planDeleteBundleIDCapability(
        _ input: AppStoreConnectBundleIDCapabilityDeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.BundleIdCapabilitiesDeleteInstance.id,
            commandDescription: "Disable bundle ID capability \(input.id).",
            inputs: ["id": input.id]
        )
    }

    public static func planCreateCertificate(
        _ input: AppStoreConnectCertificateCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.CertificatesCreateInstance.id,
            commandDescription: "Create certificate of type \(input.certificateType).",
            inputs: compactInputs([
                ("certificateType", input.certificateType),
                ("csrContentLength", String(input.csrContent.count)),
                ("merchantID", input.merchantID),
                ("passTypeID", input.passTypeID),
            ])
        )
    }

    public static func planUpdateCertificate(
        _ input: AppStoreConnectCertificateUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.CertificatesUpdateInstance.id,
            commandDescription: "Update certificate \(input.id).",
            inputs: compactInputs([
                ("id", input.id),
                ("activated", input.activated.map(String.init)),
            ])
        )
    }

    public static func planDeleteCertificate(
        _ input: AppStoreConnectCertificateDeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.CertificatesDeleteInstance.id,
            commandDescription: "Delete certificate \(input.id).",
            inputs: ["id": input.id]
        )
    }

    public static func planCreateDevice(
        _ input: AppStoreConnectDeviceCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.DevicesCreateInstance.id,
            commandDescription: "Register device \(input.name).",
            inputs: compactInputs([
                ("name", input.name),
                ("udid", input.udid),
                ("platform", input.platform),
            ])
        )
    }

    public static func planUpdateDevice(
        _ input: AppStoreConnectDeviceUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.DevicesUpdateInstance.id,
            commandDescription: "Update device \(input.id).",
            inputs: compactInputs([
                ("id", input.id),
                ("name", input.name),
                ("status", input.status),
            ])
        )
    }

    public static func planCreateProfile(
        _ input: AppStoreConnectProfileCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.ProfilesCreateInstance.id,
            commandDescription: "Create provisioning profile \(input.name).",
            inputs: compactInputs([
                ("name", input.name),
                ("profileType", input.profileType),
                ("bundleID", input.bundleID),
                ("certificateIDs", joined(input.certificateIDs)),
                ("deviceIDs", joined(input.deviceIDs)),
            ])
        )
    }

    public static func planDeleteProfile(
        _ input: AppStoreConnectProfileDeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.ProfilesDeleteInstance.id,
            commandDescription: "Delete provisioning profile \(input.id).",
            inputs: ["id": input.id]
        )
    }

    public static func planCreateUserInvitation(
        _ input: AppStoreConnectUserInvitationCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.UserInvitationsCreateInstance.id,
            commandDescription: "Invite App Store Connect user \(input.email).",
            inputs: compactInputs([
                ("email", input.email),
                ("firstName", input.firstName),
                ("lastName", input.lastName),
                ("roles", joined(input.roles)),
                ("allAppsVisible", input.allAppsVisible.map(String.init)),
                ("provisioningAllowed", input.provisioningAllowed.map(String.init)),
                ("visibleAppIDs", joined(input.visibleAppIDs)),
            ])
        )
    }

    public static func planDeleteUserInvitation(
        _ input: AppStoreConnectUserInvitationDeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.UserInvitationsDeleteInstance.id,
            commandDescription: "Delete user invitation \(input.id).",
            inputs: ["id": input.id]
        )
    }

    public static func planUpdateUser(
        _ input: AppStoreConnectUserUpdateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.UsersUpdateInstance.id,
            commandDescription: "Update App Store Connect user \(input.id).",
            inputs: compactInputs([
                ("id", input.id),
                ("roles", joined(input.roles)),
                ("allAppsVisible", input.allAppsVisible.map(String.init)),
                ("provisioningAllowed", input.provisioningAllowed.map(String.init)),
                ("visibleAppIDs", joined(input.visibleAppIDs)),
            ])
        )
    }

    public static func planDeleteUser(
        _ input: AppStoreConnectUserDeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.UsersDeleteInstance.id,
            commandDescription: "Delete App Store Connect user \(input.id).",
            inputs: ["id": input.id]
        )
    }

    public func createBetaTesterInvitation(
        _ input: AppStoreConnectBetaTesterInvitationCreateInput
    ) async throws -> AppStoreConnectBetaTesterInvitationResult {
        let output = try await client.testFlight.createBetaTesterInvitation(
            body: betaTesterInvitationCreateBody(from: input)
        )

        switch output {
        case let .created(response):
            let body = try response.body.json
            return AppStoreConnectBetaTesterInvitationResult(
                data: AppStoreConnectBetaTesterInvitationSummary(
                    id: body.data.id,
                    appID: input.appID
                )
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected beta tester invitation creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Beta tester invitation creation did not return 201 created.")
        }
    }

    public func createBetaGroup(
        _ input: AppStoreConnectBetaGroupCreateInput
    ) async throws -> AppStoreConnectBetaGroupResult {
        let output = try await client.testFlight.createBetaGroup(body: betaGroupCreateBody(from: input))

        switch output {
        case let .created(response):
            return AppStoreConnectBetaGroupResult(data: Self.betaGroupSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected beta group creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Beta group creation did not return 201 created.")
        }
    }

    public func updateBetaGroup(
        _ input: AppStoreConnectBetaGroupUpdateInput
    ) async throws -> AppStoreConnectBetaGroupResult {
        let output = try await client.testFlight.updateBetaGroup(
            id: input.id,
            body: betaGroupUpdateBody(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectBetaGroupResult(data: Self.betaGroupSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected beta group update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Beta group update did not return 200 ok.")
        }
    }

    public func deleteBetaGroup(
        _ input: AppStoreConnectBetaGroupDeleteInput
    ) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.testFlight.deleteBetaGroup(id: input.id)

        switch output {
        case .noContent:
            return acknowledgement(
                operationID: Operations.BetaGroupsDeleteInstance.id,
                resourceType: "betaGroups",
                id: input.id,
                status: "deleted"
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected beta group deletion response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Beta group deletion did not return 204 no content.")
        }
    }

    public func createBetaTester(
        _ input: AppStoreConnectBetaTesterCreateInput
    ) async throws -> AppStoreConnectBetaTesterResult {
        let output = try await client.testFlight.createBetaTester(body: betaTesterCreateBody(from: input))

        switch output {
        case let .created(response):
            return AppStoreConnectBetaTesterResult(data: Self.betaTesterSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected beta tester creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Beta tester creation did not return 201 created.")
        }
    }

    public func deleteBetaTester(
        _ input: AppStoreConnectBetaTesterDeleteInput
    ) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.testFlight.deleteBetaTester(id: input.id)

        switch output {
        case .accepted, .noContent:
            return acknowledgement(
                operationID: Operations.BetaTestersDeleteInstance.id,
                resourceType: "betaTesters",
                id: input.id,
                status: "deleted"
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected beta tester deletion response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Beta tester deletion did not return 202 accepted or 204 no content.")
        }
    }

    public func updateBetaAppReviewDetail(
        _ input: AppStoreConnectBetaAppReviewDetailUpdateInput
    ) async throws -> AppStoreConnectBetaAppReviewDetailResult {
        let output = try await client.testFlight.updateBetaAppReviewDetail(
            id: input.id,
            body: betaAppReviewDetailUpdateBody(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectBetaAppReviewDetailResult(data: Self.betaAppReviewDetailSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected beta app review detail update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Beta app review detail update did not return 200 ok.")
        }
    }

    public func createBetaAppReviewSubmission(
        _ input: AppStoreConnectBetaAppReviewSubmissionCreateInput
    ) async throws -> AppStoreConnectBetaAppReviewSubmissionResult {
        let output = try await client.testFlight.createBetaAppReviewSubmission(
            body: betaAppReviewSubmissionCreateBody(from: input)
        )

        switch output {
        case let .created(response):
            return AppStoreConnectBetaAppReviewSubmissionResult(data: Self.betaAppReviewSubmissionSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected beta app review submission creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Beta app review submission creation did not return 201 created.")
        }
    }

    public func updateApp(
        _ input: AppStoreConnectAppUpdateInput
    ) async throws -> AppStoreConnectAppResult {
        let output = try await client.apps.updateApp(
            id: input.id,
            body: try appUpdateBody(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectAppResult(data: Self.appSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected app update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "App update did not return 200 ok.")
        }
    }

    public func createAppStoreVersion(
        _ input: AppStoreConnectAppStoreVersionCreateInput
    ) async throws -> AppStoreConnectAppStoreVersionResult {
        let output = try await client.apps.createAppStoreVersion(
            body: try appStoreVersionCreateBody(from: input)
        )

        switch output {
        case let .created(response):
            return AppStoreConnectAppStoreVersionResult(data: Self.appStoreVersionSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected App Store version creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "App Store version creation did not return 201 created.")
        }
    }

    public func updateAppStoreVersion(
        _ input: AppStoreConnectAppStoreVersionUpdateInput
    ) async throws -> AppStoreConnectAppStoreVersionResult {
        let output = try await client.apps.updateAppStoreVersion(
            id: input.id,
            body: try appStoreVersionUpdateBody(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectAppStoreVersionResult(data: Self.appStoreVersionSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected App Store version update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "App Store version update did not return 200 ok.")
        }
    }

    public func deleteAppStoreVersion(
        _ input: AppStoreConnectAppStoreVersionDeleteInput
    ) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.apps.deleteAppStoreVersion(id: input.id)

        switch output {
        case .noContent:
            return acknowledgement(
                operationID: Operations.AppStoreVersionsDeleteInstance.id,
                resourceType: "appStoreVersions",
                id: input.id,
                status: "deleted"
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected App Store version deletion response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "App Store version deletion did not return 204 no content.")
        }
    }

    public func createAppStoreVersionReleaseRequest(
        _ input: AppStoreConnectAppStoreVersionReleaseRequestCreateInput
    ) async throws -> AppStoreConnectAppStoreVersionReleaseRequestResult {
        let output = try await client.apps.createAppStoreVersionReleaseRequest(
            body: appStoreVersionReleaseRequestCreateBody(from: input)
        )

        switch output {
        case let .created(response):
            return AppStoreConnectAppStoreVersionReleaseRequestResult(
                data: Self.appStoreVersionReleaseRequestSummary(
                    try response.body.json.data,
                    appStoreVersionID: input.appStoreVersionID
                )
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected App Store version release request creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "App Store version release request creation did not return 201 created.")
        }
    }

    public func createReviewSubmission(
        _ input: AppStoreConnectReviewSubmissionCreateInput
    ) async throws -> AppStoreConnectReviewSubmissionResult {
        let output = try await client.apps.createReviewSubmission(
            body: try reviewSubmissionCreateBody(from: input)
        )

        switch output {
        case let .created(response):
            return AppStoreConnectReviewSubmissionResult(data: Self.reviewSubmissionSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected review submission creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Review submission creation did not return 201 created.")
        }
    }

    public func updateReviewSubmission(
        _ input: AppStoreConnectReviewSubmissionUpdateInput
    ) async throws -> AppStoreConnectReviewSubmissionResult {
        let output = try await client.apps.updateReviewSubmission(
            id: input.id,
            body: try reviewSubmissionUpdateBody(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectReviewSubmissionResult(data: Self.reviewSubmissionSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected review submission update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Review submission update did not return 200 ok.")
        }
    }

    public func createReviewSubmissionItem(
        _ input: AppStoreConnectReviewSubmissionItemCreateInput
    ) async throws -> AppStoreConnectReviewSubmissionItemResult {
        let output = try await client.apps.createReviewSubmissionItem(
            body: reviewSubmissionItemCreateBody(from: input)
        )

        switch output {
        case let .created(response):
            return AppStoreConnectReviewSubmissionItemResult(data: Self.reviewSubmissionItemSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected review submission item creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Review submission item creation did not return 201 created.")
        }
    }

    public func updateReviewSubmissionItem(
        _ input: AppStoreConnectReviewSubmissionItemUpdateInput
    ) async throws -> AppStoreConnectReviewSubmissionItemResult {
        let output = try await client.apps.updateReviewSubmissionItem(
            id: input.id,
            body: reviewSubmissionItemUpdateBody(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectReviewSubmissionItemResult(data: Self.reviewSubmissionItemSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected review submission item update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Review submission item update did not return 200 ok.")
        }
    }

    public func deleteReviewSubmissionItem(
        _ input: AppStoreConnectReviewSubmissionItemDeleteInput
    ) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.apps.deleteReviewSubmissionItem(id: input.id)

        switch output {
        case .noContent:
            return acknowledgement(
                operationID: Operations.ReviewSubmissionItemsDeleteInstance.id,
                resourceType: "reviewSubmissionItems",
                id: input.id,
                status: "deleted"
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected review submission item deletion response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Review submission item deletion did not return 204 no content.")
        }
    }

#if ASC_PUBLIC_API_RELEASE
    public func createCustomerReviewResponse(
        _ input: AppStoreConnectCustomerReviewResponseCreateInput
    ) async throws -> AppStoreConnectCustomerReviewResponseMutationResult {
        let output = try await client.openAPI.customerReviewResponsesCreateInstance(
            body: customerReviewResponseCreateBody(from: input)
        )

        switch output {
        case let .created(response):
            return AppStoreConnectCustomerReviewResponseMutationResult(
                data: PublicAPIReadCommands.customerReviewResponseSummary(try response.body.json.data)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected customer review response creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Customer review response creation did not return 201 created.")
        }
    }

    public func deleteCustomerReviewResponse(
        _ input: AppStoreConnectCustomerReviewResponseDeleteInput
    ) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.openAPI.customerReviewResponsesDeleteInstance(path: .init(id: input.id))

        switch output {
        case .noContent:
            return acknowledgement(
                operationID: Operations.CustomerReviewResponsesDeleteInstance.id,
                resourceType: "customerReviewResponses",
                id: input.id,
                status: "deleted"
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected customer review response deletion response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Customer review response deletion did not return 204 no content.")
        }
    }

    public func createAppEvent(
        _ input: AppStoreConnectAppEventCreateInput
    ) async throws -> AppStoreConnectAppEventMutationResult {
        let output = try await client.openAPI.appEventsCreateInstance(
            body: try appEventCreateBody(from: input)
        )

        switch output {
        case let .created(response):
            return AppStoreConnectAppEventMutationResult(
                data: PublicAPIReadCommands.appEventSummary(try response.body.json.data)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected app event creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "App event creation did not return 201 created.")
        }
    }

    public func updateAppEvent(
        _ input: AppStoreConnectAppEventUpdateInput
    ) async throws -> AppStoreConnectAppEventMutationResult {
        let output = try await client.openAPI.appEventsUpdateInstance(
            path: .init(id: input.id),
            body: try appEventUpdateBody(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectAppEventMutationResult(
                data: PublicAPIReadCommands.appEventSummary(try response.body.json.data)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected app event update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "App event update did not return 200 ok.")
        }
    }

    public func deleteAppEvent(
        _ input: AppStoreConnectAppEventDeleteInput
    ) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.openAPI.appEventsDeleteInstance(path: .init(id: input.id))

        switch output {
        case .noContent:
            return acknowledgement(
                operationID: Operations.AppEventsDeleteInstance.id,
                resourceType: "appEvents",
                id: input.id,
                status: "deleted"
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected app event deletion response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "App event deletion did not return 204 no content.")
        }
    }

    public func updateAppCategory(
        _ input: AppStoreConnectAppCategoryUpdateInput
    ) async throws -> AppStoreConnectAppCategoryAssignmentResult {
        let output = try await client.openAPI.appInfosUpdateInstance(
            path: .init(id: input.appInfoID),
            body: try appCategoryUpdateBody(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectAppCategoryAssignmentResult(
                data: Self.appCategoryAssignmentSummary(try response.body.json.data, fallback: input)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected app category update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "App category update did not return 200 ok.")
        }
    }

    public func updateAgeRating(
        _ input: AppStoreConnectAgeRatingUpdateInput
    ) async throws -> AppStoreConnectAgeRatingResult {
        let output = try await client.openAPI.ageRatingDeclarationsUpdateInstance(
            path: .init(id: input.id),
            body: try ageRatingUpdateBody(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectAgeRatingResult(data: PublicAPIReadCommands.ageRatingSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected age rating update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Age rating update did not return 200 ok.")
        }
    }
#endif

#if ASC_PUBLIC_API_DISTRIBUTION
    public func createWebhook(
        _ input: AppStoreConnectWebhookCreateInput
    ) async throws -> AppStoreConnectWebhookMutationResult {
        let output = try await client.openAPI.webhooksCreateInstance(
            body: try webhookCreateBody(from: input)
        )

        switch output {
        case let .created(response):
            return AppStoreConnectWebhookMutationResult(
                data: PublicAPIReadCommands.webhookSummary(try response.body.json.data)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected webhook creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Webhook creation did not return 201 created.")
        }
    }

    public func updateWebhook(
        _ input: AppStoreConnectWebhookUpdateInput
    ) async throws -> AppStoreConnectWebhookMutationResult {
        let output = try await client.openAPI.webhooksUpdateInstance(
            path: .init(id: input.id),
            body: try webhookUpdateBody(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectWebhookMutationResult(
                data: PublicAPIReadCommands.webhookSummary(try response.body.json.data)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected webhook update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Webhook update did not return 200 ok.")
        }
    }

    public func deleteWebhook(
        _ input: AppStoreConnectWebhookDeleteInput
    ) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.openAPI.webhooksDeleteInstance(path: .init(id: input.id))

        switch output {
        case .noContent:
            return acknowledgement(
                operationID: Operations.WebhooksDeleteInstance.id,
                resourceType: "webhooks",
                id: input.id,
                status: "deleted"
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected webhook deletion response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Webhook deletion did not return 204 no content.")
        }
    }

    public func redeliverWebhookDelivery(
        _ input: AppStoreConnectWebhookDeliveryRedeliverInput
    ) async throws -> AppStoreConnectWebhookDeliveryMutationResult {
        let output = try await client.openAPI.webhookDeliveriesCreateInstance(
            body: webhookDeliveryRedeliverBody(from: input)
        )

        switch output {
        case let .created(response):
            return AppStoreConnectWebhookDeliveryMutationResult(
                data: PublicAPIReadCommands.webhookDeliverySummary(try response.body.json.data)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected webhook delivery redelivery response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Webhook delivery redelivery did not return 201 created.")
        }
    }

    public func pingWebhook(
        _ input: AppStoreConnectWebhookPingInput
    ) async throws -> AppStoreConnectWebhookPingResult {
        let output = try await client.openAPI.webhookPingsCreateInstance(
            body: webhookPingBody(from: input)
        )

        switch output {
        case let .created(response):
            return AppStoreConnectWebhookPingResult(
                data: AppStoreConnectWebhookPingSummary(
                    id: try response.body.json.data.id,
                    webhookID: input.webhookID
                )
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected webhook ping response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Webhook ping did not return 201 created.")
        }
    }

    public func createEULA(
        _ input: AppStoreConnectEULACreateInput
    ) async throws -> AppStoreConnectEULAResult {
        let output = try await client.openAPI.endUserLicenseAgreementsCreateInstance(
            body: eulaCreateBody(from: input)
        )

        switch output {
        case let .created(response):
            return AppStoreConnectEULAResult(
                data: PublicAPIReadCommands.eulaSummary(try response.body.json.data)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected EULA creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "EULA creation did not return 201 created.")
        }
    }

    public func updateEULA(
        _ input: AppStoreConnectEULAUpdateInput
    ) async throws -> AppStoreConnectEULAResult {
        let output = try await client.openAPI.endUserLicenseAgreementsUpdateInstance(
            path: .init(id: input.id),
            body: eulaUpdateBody(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectEULAResult(
                data: PublicAPIReadCommands.eulaSummary(try response.body.json.data)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected EULA update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "EULA update did not return 200 ok.")
        }
    }

    public func deleteEULA(
        _ input: AppStoreConnectEULADeleteInput
    ) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.openAPI.endUserLicenseAgreementsDeleteInstance(path: .init(id: input.id))

        switch output {
        case .noContent:
            return acknowledgement(
                operationID: Operations.EndUserLicenseAgreementsDeleteInstance.id,
                resourceType: "endUserLicenseAgreements",
                id: input.id,
                status: "deleted"
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected EULA deletion response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "EULA deletion did not return 204 no content.")
        }
    }
#endif

    public func createBundleID(
        _ input: AppStoreConnectBundleIDCreateInput
    ) async throws -> AppStoreConnectBundleIDResult {
        let output = try await client.certificatesProfiles.createBundleId(
            body: try bundleIDCreateBody(from: input)
        )

        switch output {
        case let .created(response):
            return AppStoreConnectBundleIDResult(data: Self.bundleIDSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected bundle ID creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Bundle ID creation did not return 201 created.")
        }
    }

    public func updateBundleID(
        _ input: AppStoreConnectBundleIDUpdateInput
    ) async throws -> AppStoreConnectBundleIDResult {
        let output = try await client.certificatesProfiles.updateBundleId(
            id: input.id,
            body: bundleIDUpdateBody(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectBundleIDResult(data: Self.bundleIDSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected bundle ID update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Bundle ID update did not return 200 ok.")
        }
    }

    public func deleteBundleID(
        _ input: AppStoreConnectBundleIDDeleteInput
    ) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.certificatesProfiles.deleteBundleId(id: input.id)

        switch output {
        case .noContent:
            return acknowledgement(
                operationID: Operations.BundleIdsDeleteInstance.id,
                resourceType: "bundleIds",
                id: input.id,
                status: "deleted"
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected bundle ID deletion response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Bundle ID deletion did not return 204 no content.")
        }
    }

    public func createBundleIDCapability(
        _ input: AppStoreConnectBundleIDCapabilityCreateInput
    ) async throws -> AppStoreConnectBundleIDCapabilityResult {
        let output = try await client.certificatesProfiles.createBundleIdCapability(
            body: try bundleIDCapabilityCreateBody(from: input)
        )

        switch output {
        case let .created(response):
            return AppStoreConnectBundleIDCapabilityResult(
                data: PublicAPIReadCommands.bundleIDCapabilitySummary(try response.body.json.data)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected bundle ID capability creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Bundle ID capability creation did not return 201 created.")
        }
    }

    public func updateBundleIDCapability(
        _ input: AppStoreConnectBundleIDCapabilityUpdateInput
    ) async throws -> AppStoreConnectBundleIDCapabilityResult {
        let output = try await client.certificatesProfiles.updateBundleIdCapability(
            id: input.id,
            body: try bundleIDCapabilityUpdateBody(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectBundleIDCapabilityResult(
                data: PublicAPIReadCommands.bundleIDCapabilitySummary(try response.body.json.data)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected bundle ID capability update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Bundle ID capability update did not return 200 ok.")
        }
    }

    public func deleteBundleIDCapability(
        _ input: AppStoreConnectBundleIDCapabilityDeleteInput
    ) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.certificatesProfiles.deleteBundleIdCapability(id: input.id)

        switch output {
        case .noContent:
            return acknowledgement(
                operationID: Operations.BundleIdCapabilitiesDeleteInstance.id,
                resourceType: "bundleIdCapabilities",
                id: input.id,
                status: "deleted"
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected bundle ID capability deletion response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Bundle ID capability deletion did not return 204 no content.")
        }
    }

    public func createCertificate(
        _ input: AppStoreConnectCertificateCreateInput
    ) async throws -> AppStoreConnectCertificateResult {
        let output = try await client.certificatesProfiles.createCertificate(
            body: try certificateCreateBody(from: input)
        )

        switch output {
        case let .created(response):
            return AppStoreConnectCertificateResult(data: Self.certificateSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected certificate creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Certificate creation did not return 201 created.")
        }
    }

    public func updateCertificate(
        _ input: AppStoreConnectCertificateUpdateInput
    ) async throws -> AppStoreConnectCertificateResult {
        let output = try await client.certificatesProfiles.updateCertificate(
            id: input.id,
            body: certificateUpdateBody(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectCertificateResult(data: Self.certificateSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected certificate update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Certificate update did not return 200 ok.")
        }
    }

    public func deleteCertificate(
        _ input: AppStoreConnectCertificateDeleteInput
    ) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.certificatesProfiles.deleteCertificate(id: input.id)

        switch output {
        case .noContent:
            return acknowledgement(
                operationID: Operations.CertificatesDeleteInstance.id,
                resourceType: "certificates",
                id: input.id,
                status: "deleted"
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected certificate deletion response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Certificate deletion did not return 204 no content.")
        }
    }

    public func createDevice(
        _ input: AppStoreConnectDeviceCreateInput
    ) async throws -> AppStoreConnectDeviceResult {
        let output = try await client.certificatesProfiles.createDevice(
            body: try deviceCreateBody(from: input)
        )

        switch output {
        case let .created(response):
            return AppStoreConnectDeviceResult(data: Self.deviceSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected device creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Device creation did not return 201 created.")
        }
    }

    public func updateDevice(
        _ input: AppStoreConnectDeviceUpdateInput
    ) async throws -> AppStoreConnectDeviceResult {
        let output = try await client.certificatesProfiles.updateDevice(
            id: input.id,
            body: try deviceUpdateBody(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectDeviceResult(data: Self.deviceSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected device update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Device update did not return 200 ok.")
        }
    }

    public func createProfile(
        _ input: AppStoreConnectProfileCreateInput
    ) async throws -> AppStoreConnectProfileResult {
        let output = try await client.certificatesProfiles.createProfile(
            body: try profileCreateBody(from: input)
        )

        switch output {
        case let .created(response):
            return AppStoreConnectProfileResult(data: Self.profileSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected profile creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Profile creation did not return 201 created.")
        }
    }

    public func deleteProfile(
        _ input: AppStoreConnectProfileDeleteInput
    ) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.certificatesProfiles.deleteProfile(id: input.id)

        switch output {
        case .noContent:
            return acknowledgement(
                operationID: Operations.ProfilesDeleteInstance.id,
                resourceType: "profiles",
                id: input.id,
                status: "deleted"
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected profile deletion response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Profile deletion did not return 204 no content.")
        }
    }

    public func createUserInvitation(
        _ input: AppStoreConnectUserInvitationCreateInput
    ) async throws -> AppStoreConnectUserInvitationResult {
        let output = try await client.users.createUserInvitation(
            body: try userInvitationCreateBody(from: input)
        )

        switch output {
        case let .created(response):
            return AppStoreConnectUserInvitationResult(data: Self.userInvitationSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected user invitation creation response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "User invitation creation did not return 201 created.")
        }
    }

    public func deleteUserInvitation(
        _ input: AppStoreConnectUserInvitationDeleteInput
    ) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.users.deleteUserInvitation(id: input.id)

        switch output {
        case .noContent:
            return acknowledgement(
                operationID: Operations.UserInvitationsDeleteInstance.id,
                resourceType: "userInvitations",
                id: input.id,
                status: "deleted"
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected user invitation deletion response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "User invitation deletion did not return 204 no content.")
        }
    }

    public func updateUser(
        _ input: AppStoreConnectUserUpdateInput
    ) async throws -> AppStoreConnectUserResult {
        let output = try await client.users.updateUser(
            id: input.id,
            body: try userUpdateBody(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectUserResult(data: Self.userSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected user update response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "User update did not return 200 ok.")
        }
    }

    public func deleteUser(
        _ input: AppStoreConnectUserDeleteInput
    ) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.users.deleteUser(id: input.id)

        switch output {
        case .noContent:
            return acknowledgement(
                operationID: Operations.UsersDeleteInstance.id,
                resourceType: "users",
                id: input.id,
                status: "deleted"
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected user deletion response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "User deletion did not return 204 no content.")
        }
    }

    private func betaTesterInvitationCreateBody(
        from input: AppStoreConnectBetaTesterInvitationCreateInput
    ) -> Operations.BetaTesterInvitationsCreateInstance.Input.Body {
        .json(Components.Schemas.BetaTesterInvitationCreateRequest(
            data: .init(
                relationships: .init(
                    app: .init(data: .init(id: input.appID, _type: .apps))
                ),
                _type: .betaTesterInvitations
            )
        ))
    }

    private func betaGroupCreateBody(
        from input: AppStoreConnectBetaGroupCreateInput
    ) -> Operations.BetaGroupsCreateInstance.Input.Body {
        .json(Components.Schemas.BetaGroupCreateRequest(
            data: .init(
                attributes: .init(
                    feedbackEnabled: input.feedbackEnabled,
                    hasAccessToAllBuilds: input.hasAccessToAllBuilds,
                    isInternalGroup: input.isInternalGroup,
                    name: input.name,
                    publicLinkEnabled: input.publicLinkEnabled,
                    publicLinkLimit: input.publicLinkLimit,
                    publicLinkLimitEnabled: input.publicLinkLimitEnabled
                ),
                relationships: .init(
                    app: .init(data: .init(id: input.appID, _type: .apps)),
                    betaTesters: betaGroupCreateBetaTestersPayload(input.betaTesterIDs),
                    builds: betaGroupCreateBuildsPayload(input.buildIDs)
                ),
                _type: .betaGroups
            )
        ))
    }

    private func betaGroupUpdateBody(
        from input: AppStoreConnectBetaGroupUpdateInput
    ) -> Operations.BetaGroupsUpdateInstance.Input.Body {
        .json(Components.Schemas.BetaGroupUpdateRequest(
            data: .init(
                attributes: .init(
                    feedbackEnabled: input.feedbackEnabled,
                    iosBuildsAvailableForAppleSiliconMac: input.iosBuildsAvailableForAppleSiliconMac,
                    iosBuildsAvailableForAppleVision: input.iosBuildsAvailableForAppleVision,
                    name: input.name,
                    publicLinkEnabled: input.publicLinkEnabled,
                    publicLinkLimit: input.publicLinkLimit,
                    publicLinkLimitEnabled: input.publicLinkLimitEnabled
                ),
                id: input.id,
                _type: .betaGroups
            )
        ))
    }

    private func betaTesterCreateBody(
        from input: AppStoreConnectBetaTesterCreateInput
    ) -> Operations.BetaTestersCreateInstance.Input.Body {
        .json(Components.Schemas.BetaTesterCreateRequest(
            data: .init(
                attributes: .init(
                    email: input.email,
                    firstName: input.firstName,
                    lastName: input.lastName
                ),
                relationships: betaTesterCreateRelationshipsPayload(input),
                _type: .betaTesters
            )
        ))
    }

    private func betaAppReviewDetailUpdateBody(
        from input: AppStoreConnectBetaAppReviewDetailUpdateInput
    ) -> Operations.BetaAppReviewDetailsUpdateInstance.Input.Body {
        .json(Components.Schemas.BetaAppReviewDetailUpdateRequest(
            data: .init(
                attributes: .init(
                    contactEmail: input.contactEmail,
                    contactFirstName: input.contactFirstName,
                    contactLastName: input.contactLastName,
                    contactPhone: input.contactPhone,
                    demoAccountName: input.demoAccountName,
                    demoAccountPassword: input.demoAccountPassword,
                    demoAccountRequired: input.demoAccountRequired,
                    notes: input.notes
                ),
                id: input.id,
                _type: .betaAppReviewDetails
            )
        ))
    }

    private func betaAppReviewSubmissionCreateBody(
        from input: AppStoreConnectBetaAppReviewSubmissionCreateInput
    ) -> Operations.BetaAppReviewSubmissionsCreateInstance.Input.Body {
        .json(Components.Schemas.BetaAppReviewSubmissionCreateRequest(
            data: .init(
                relationships: .init(
                    build: .init(data: .init(id: input.buildID, _type: .builds))
                ),
                _type: .betaAppReviewSubmissions
            )
        ))
    }

    private func appUpdateBody(
        from input: AppStoreConnectAppUpdateInput
    ) throws -> Operations.AppsUpdateInstance.Input.Body {
        .json(Components.Schemas.AppUpdateRequest(
            data: .init(
                attributes: .init(
                    accessibilityUrl: input.accessibilityURL,
                    contentRightsDeclaration: try optionalContentRightsDeclaration(input.contentRightsDeclaration),
                    primaryLocale: input.primaryLocale,
                    streamlinedPurchasingEnabled: input.streamlinedPurchasingEnabled,
                    subscriptionStatusUrl: input.subscriptionStatusURL,
                    subscriptionStatusUrlForSandbox: input.subscriptionStatusURLForSandbox
                ),
                id: input.id,
                _type: .apps
            )
        ))
    }

    private func appStoreVersionCreateBody(
        from input: AppStoreConnectAppStoreVersionCreateInput
    ) throws -> Operations.AppStoreVersionsCreateInstance.Input.Body {
        .json(Components.Schemas.AppStoreVersionCreateRequest(
            data: .init(
                attributes: .init(
                    copyright: input.copyright,
                    earliestReleaseDate: input.earliestReleaseDate,
                    platform: try requiredPlatform(input.platform),
                    releaseType: try optionalCreateReleaseType(input.releaseType),
                    reviewType: try optionalCreateReviewType(input.reviewType),
                    versionString: input.versionString
                ),
                relationships: .init(
                    app: .init(data: .init(id: input.appID, _type: .apps)),
                    build: appStoreVersionCreateBuildPayload(input.buildID)
                ),
                _type: .appStoreVersions
            )
        ))
    }

    private func appStoreVersionUpdateBody(
        from input: AppStoreConnectAppStoreVersionUpdateInput
    ) throws -> Operations.AppStoreVersionsUpdateInstance.Input.Body {
        .json(Components.Schemas.AppStoreVersionUpdateRequest(
            data: .init(
                attributes: .init(
                    copyright: input.copyright,
                    downloadable: input.downloadable,
                    earliestReleaseDate: input.earliestReleaseDate,
                    releaseType: try optionalUpdateReleaseType(input.releaseType),
                    reviewType: try optionalUpdateReviewType(input.reviewType),
                    versionString: input.versionString
                ),
                id: input.id,
                relationships: appStoreVersionUpdateRelationshipsPayload(input),
                _type: .appStoreVersions
            )
        ))
    }

    private func appStoreVersionReleaseRequestCreateBody(
        from input: AppStoreConnectAppStoreVersionReleaseRequestCreateInput
    ) -> Operations.AppStoreVersionReleaseRequestsCreateInstance.Input.Body {
        .json(Components.Schemas.AppStoreVersionReleaseRequestCreateRequest(
            data: .init(
                relationships: .init(
                    appStoreVersion: .init(data: .init(id: input.appStoreVersionID, _type: .appStoreVersions))
                ),
                _type: .appStoreVersionReleaseRequests
            )
        ))
    }

    private func reviewSubmissionCreateBody(
        from input: AppStoreConnectReviewSubmissionCreateInput
    ) throws -> Operations.ReviewSubmissionsCreateInstance.Input.Body {
        .json(Components.Schemas.ReviewSubmissionCreateRequest(
            data: .init(
                attributes: .init(platform: try optionalPlatform(input.platform)),
                relationships: .init(app: .init(data: .init(id: input.appID, _type: .apps))),
                _type: .reviewSubmissions
            )
        ))
    }

    private func reviewSubmissionUpdateBody(
        from input: AppStoreConnectReviewSubmissionUpdateInput
    ) throws -> Operations.ReviewSubmissionsUpdateInstance.Input.Body {
        .json(Components.Schemas.ReviewSubmissionUpdateRequest(
            data: .init(
                attributes: .init(
                    canceled: input.canceled,
                    platform: try optionalPlatform(input.platform),
                    submitted: input.submitted
                ),
                id: input.id,
                _type: .reviewSubmissions
            )
        ))
    }

    private func reviewSubmissionItemCreateBody(
        from input: AppStoreConnectReviewSubmissionItemCreateInput
    ) -> Operations.ReviewSubmissionItemsCreateInstance.Input.Body {
        .json(Components.Schemas.ReviewSubmissionItemCreateRequest(
            data: .init(
                relationships: .init(
                    appStoreVersion: .init(data: .init(id: input.appStoreVersionID, _type: .appStoreVersions)),
                    reviewSubmission: .init(data: .init(id: input.reviewSubmissionID, _type: .reviewSubmissions))
                ),
                _type: .reviewSubmissionItems
            )
        ))
    }

    private func reviewSubmissionItemUpdateBody(
        from input: AppStoreConnectReviewSubmissionItemUpdateInput
    ) -> Operations.ReviewSubmissionItemsUpdateInstance.Input.Body {
        .json(Components.Schemas.ReviewSubmissionItemUpdateRequest(
            data: .init(
                attributes: .init(removed: input.removed, resolved: input.resolved),
                id: input.id,
                _type: .reviewSubmissionItems
            )
        ))
    }

#if ASC_PUBLIC_API_RELEASE
    private func customerReviewResponseCreateBody(
        from input: AppStoreConnectCustomerReviewResponseCreateInput
    ) -> Operations.CustomerReviewResponsesCreateInstance.Input.Body {
        .json(Components.Schemas.CustomerReviewResponseV1CreateRequest(
            data: .init(
                attributes: .init(responseBody: input.responseBody),
                relationships: .init(review: .init(data: .init(
                    id: input.reviewID,
                    _type: .customerReviews
                ))),
                _type: .customerReviewResponses
            )
        ))
    }

    private func appEventCreateBody(
        from input: AppStoreConnectAppEventCreateInput
    ) throws -> Operations.AppEventsCreateInstance.Input.Body {
        .json(Components.Schemas.AppEventCreateRequest(
            data: .init(
                attributes: .init(
                    badge: try optionalAppEventCreateBadge(input.badge),
                    deepLink: input.deepLink,
                    primaryLocale: input.primaryLocale,
                    priority: try optionalAppEventCreatePriority(input.priority),
                    purchaseRequirement: input.purchaseRequirement,
                    purpose: try optionalAppEventCreatePurpose(input.purpose),
                    referenceName: input.referenceName
                ),
                relationships: .init(
                    app: .init(data: .init(id: input.appID, _type: .apps))
                ),
                _type: .appEvents
            )
        ))
    }

    private func appEventUpdateBody(
        from input: AppStoreConnectAppEventUpdateInput
    ) throws -> Operations.AppEventsUpdateInstance.Input.Body {
        .json(Components.Schemas.AppEventUpdateRequest(
            data: .init(
                attributes: .init(
                    badge: try optionalAppEventUpdateBadge(input.badge),
                    deepLink: input.deepLink,
                    primaryLocale: input.primaryLocale,
                    priority: try optionalAppEventUpdatePriority(input.priority),
                    purchaseRequirement: input.purchaseRequirement,
                    purpose: try optionalAppEventUpdatePurpose(input.purpose),
                    referenceName: input.referenceName
                ),
                id: input.id,
                _type: .appEvents
            )
        ))
    }

    private func appCategoryUpdateBody(
        from input: AppStoreConnectAppCategoryUpdateInput
    ) throws -> Operations.AppInfosUpdateInstance.Input.Body {
        guard appCategoryUpdateHasRelationship(input) else {
            throw AppStoreConnectError.invalidConfiguration("At least one category relationship must be provided.")
        }
        return .json(Components.Schemas.AppInfoUpdateRequest(
            data: .init(
                id: input.appInfoID,
                relationships: .init(
                    primaryCategory: appInfoPrimaryCategoryPayload(input.primaryCategoryID),
                    primarySubcategoryOne: appInfoPrimarySubcategoryOnePayload(input.primarySubcategoryOneID),
                    primarySubcategoryTwo: appInfoPrimarySubcategoryTwoPayload(input.primarySubcategoryTwoID),
                    secondaryCategory: appInfoSecondaryCategoryPayload(input.secondaryCategoryID),
                    secondarySubcategoryOne: appInfoSecondarySubcategoryOnePayload(input.secondarySubcategoryOneID),
                    secondarySubcategoryTwo: appInfoSecondarySubcategoryTwoPayload(input.secondarySubcategoryTwoID)
                ),
                _type: .appInfos
            )
        ))
    }

    private func ageRatingUpdateBody(
        from input: AppStoreConnectAgeRatingUpdateInput
    ) throws -> Operations.AgeRatingDeclarationsUpdateInstance.Input.Body {
        let frequencyRatings = try Self.canonicalAgeRatingFrequencyRatings(input)
        let booleanRatings = try Self.canonicalAgeRatingBooleanRatings(input)
        let allNoneOverride = input.allNone ? "NONE" : nil

        guard input.allNone
            || !frequencyRatings.isEmpty
            || !booleanRatings.isEmpty
            || input.kidsAgeBand != nil
            || input.ageRatingOverrideV2 != nil
            || input.koreaAgeRatingOverride != nil
            || input.developerAgeRatingInfoURL != nil
        else {
            throw AppStoreConnectError.invalidConfiguration("At least one age rating update field must be provided.")
        }

        typealias Attributes = Components.Schemas.AgeRatingDeclarationUpdateRequest.DataPayload.AttributesPayload
        let attributes = try Attributes(
            advertising: booleanRatings["advertising"],
            ageAssurance: booleanRatings["ageAssurance"],
            ageRatingOverrideV2: optionalEnum(
                input.ageRatingOverrideV2 ?? allNoneOverride,
                fieldName: "ageRatingOverrideV2",
                as: Attributes.AgeRatingOverrideV2Payload.self
            ),
            alcoholTobaccoOrDrugUseOrReferences: optionalEnum(
                frequencyRatings["alcoholTobaccoOrDrugUseOrReferences"],
                fieldName: "alcoholTobaccoOrDrugUseOrReferences",
                as: Attributes.AlcoholTobaccoOrDrugUseOrReferencesPayload.self
            ),
            contests: optionalEnum(
                frequencyRatings["contests"],
                fieldName: "contests",
                as: Attributes.ContestsPayload.self
            ),
            developerAgeRatingInfoUrl: input.developerAgeRatingInfoURL,
            gambling: booleanRatings["gambling"],
            gamblingSimulated: optionalEnum(
                frequencyRatings["gamblingSimulated"],
                fieldName: "gamblingSimulated",
                as: Attributes.GamblingSimulatedPayload.self
            ),
            gunsOrOtherWeapons: optionalEnum(
                frequencyRatings["gunsOrOtherWeapons"],
                fieldName: "gunsOrOtherWeapons",
                as: Attributes.GunsOrOtherWeaponsPayload.self
            ),
            healthOrWellnessTopics: booleanRatings["healthOrWellnessTopics"],
            horrorOrFearThemes: optionalEnum(
                frequencyRatings["horrorOrFearThemes"],
                fieldName: "horrorOrFearThemes",
                as: Attributes.HorrorOrFearThemesPayload.self
            ),
            kidsAgeBand: optionalEnum(input.kidsAgeBand, fieldName: "kidsAgeBand", as: Components.Schemas.KidsAgeBand.self),
            koreaAgeRatingOverride: optionalEnum(
                input.koreaAgeRatingOverride ?? allNoneOverride,
                fieldName: "koreaAgeRatingOverride",
                as: Attributes.KoreaAgeRatingOverridePayload.self
            ),
            lootBox: booleanRatings["lootBox"],
            matureOrSuggestiveThemes: optionalEnum(
                frequencyRatings["matureOrSuggestiveThemes"],
                fieldName: "matureOrSuggestiveThemes",
                as: Attributes.MatureOrSuggestiveThemesPayload.self
            ),
            medicalOrTreatmentInformation: optionalEnum(
                frequencyRatings["medicalOrTreatmentInformation"],
                fieldName: "medicalOrTreatmentInformation",
                as: Attributes.MedicalOrTreatmentInformationPayload.self
            ),
            messagingAndChat: booleanRatings["messagingAndChat"],
            parentalControls: booleanRatings["parentalControls"],
            profanityOrCrudeHumor: optionalEnum(
                frequencyRatings["profanityOrCrudeHumor"],
                fieldName: "profanityOrCrudeHumor",
                as: Attributes.ProfanityOrCrudeHumorPayload.self
            ),
            sexualContentGraphicAndNudity: optionalEnum(
                frequencyRatings["sexualContentGraphicAndNudity"],
                fieldName: "sexualContentGraphicAndNudity",
                as: Attributes.SexualContentGraphicAndNudityPayload.self
            ),
            sexualContentOrNudity: optionalEnum(
                frequencyRatings["sexualContentOrNudity"],
                fieldName: "sexualContentOrNudity",
                as: Attributes.SexualContentOrNudityPayload.self
            ),
            unrestrictedWebAccess: booleanRatings["unrestrictedWebAccess"],
            userGeneratedContent: booleanRatings["userGeneratedContent"],
            violenceCartoonOrFantasy: optionalEnum(
                frequencyRatings["violenceCartoonOrFantasy"],
                fieldName: "violenceCartoonOrFantasy",
                as: Attributes.ViolenceCartoonOrFantasyPayload.self
            ),
            violenceRealistic: optionalEnum(
                frequencyRatings["violenceRealistic"],
                fieldName: "violenceRealistic",
                as: Attributes.ViolenceRealisticPayload.self
            ),
            violenceRealisticProlongedGraphicOrSadistic: optionalEnum(
                frequencyRatings["violenceRealisticProlongedGraphicOrSadistic"],
                fieldName: "violenceRealisticProlongedGraphicOrSadistic",
                as: Attributes.ViolenceRealisticProlongedGraphicOrSadisticPayload.self
            )
        )

        return .json(Components.Schemas.AgeRatingDeclarationUpdateRequest(
            data: .init(
                attributes: attributes,
                id: input.id,
                _type: .ageRatingDeclarations
            )
        ))
    }
#endif

#if ASC_PUBLIC_API_DISTRIBUTION
    private func webhookCreateBody(
        from input: AppStoreConnectWebhookCreateInput
    ) throws -> Operations.WebhooksCreateInstance.Input.Body {
        .json(Components.Schemas.WebhookCreateRequest(
            data: .init(
                attributes: .init(
                    enabled: input.enabled,
                    eventTypes: try requiredWebhookEventTypes(input.eventTypes),
                    name: input.name,
                    secret: input.secret,
                    url: input.url
                ),
                relationships: .init(
                    app: .init(data: .init(id: input.appID, _type: .apps))
                ),
                _type: .webhooks
            )
        ))
    }

    private func webhookUpdateBody(
        from input: AppStoreConnectWebhookUpdateInput
    ) throws -> Operations.WebhooksUpdateInstance.Input.Body {
        .json(Components.Schemas.WebhookUpdateRequest(
            data: .init(
                attributes: .init(
                    enabled: input.enabled,
                    eventTypes: try optionalWebhookEventTypes(input.eventTypes),
                    name: input.name,
                    secret: input.secret,
                    url: input.url
                ),
                id: input.id,
                _type: .webhooks
            )
        ))
    }

    private func webhookDeliveryRedeliverBody(
        from input: AppStoreConnectWebhookDeliveryRedeliverInput
    ) -> Operations.WebhookDeliveriesCreateInstance.Input.Body {
        .json(Components.Schemas.WebhookDeliveryCreateRequest(
            data: .init(
                relationships: .init(
                    template: .init(data: .init(id: input.deliveryID, _type: .webhookDeliveries))
                ),
                _type: .webhookDeliveries
            )
        ))
    }

    private func webhookPingBody(
        from input: AppStoreConnectWebhookPingInput
    ) -> Operations.WebhookPingsCreateInstance.Input.Body {
        .json(Components.Schemas.WebhookPingCreateRequest(
            data: .init(
                relationships: .init(
                    webhook: .init(data: .init(id: input.webhookID, _type: .webhooks))
                ),
                _type: .webhookPings
            )
        ))
    }

    private func eulaCreateBody(
        from input: AppStoreConnectEULACreateInput
    ) -> Operations.EndUserLicenseAgreementsCreateInstance.Input.Body {
        .json(Components.Schemas.EndUserLicenseAgreementCreateRequest(
            data: .init(
                attributes: .init(agreementText: input.agreementText),
                relationships: .init(
                    app: .init(data: .init(id: input.appID, _type: .apps)),
                    territories: .init(data: input.territoryIDs.map { .init(id: $0, _type: .territories) })
                ),
                _type: .endUserLicenseAgreements
            )
        ))
    }

    private func eulaUpdateBody(
        from input: AppStoreConnectEULAUpdateInput
    ) -> Operations.EndUserLicenseAgreementsUpdateInstance.Input.Body {
        .json(Components.Schemas.EndUserLicenseAgreementUpdateRequest(
            data: .init(
                attributes: input.agreementText.map { .init(agreementText: $0) },
                id: input.id,
                relationships: input.territoryIDs.isEmpty
                    ? nil
                    : .init(territories: .init(data: input.territoryIDs.map { .init(id: $0, _type: .territories) })),
                _type: .endUserLicenseAgreements
            )
        ))
    }
#endif

    private func bundleIDCreateBody(
        from input: AppStoreConnectBundleIDCreateInput
    ) throws -> Operations.BundleIdsCreateInstance.Input.Body {
        .json(Components.Schemas.BundleIdCreateRequest(
            data: .init(
                attributes: .init(
                    identifier: input.identifier,
                    name: input.name,
                    platform: try requiredBundleIDPlatform(input.platform),
                    seedId: input.seedID
                ),
                _type: .bundleIds
            )
        ))
    }

    private func bundleIDUpdateBody(
        from input: AppStoreConnectBundleIDUpdateInput
    ) -> Operations.BundleIdsUpdateInstance.Input.Body {
        .json(Components.Schemas.BundleIdUpdateRequest(
            data: .init(
                attributes: .init(name: input.name),
                id: input.id,
                _type: .bundleIds
            )
        ))
    }

    private func bundleIDCapabilityCreateBody(
        from input: AppStoreConnectBundleIDCapabilityCreateInput
    ) throws -> Operations.BundleIdCapabilitiesCreateInstance.Input.Body {
        .json(Components.Schemas.BundleIdCapabilityCreateRequest(
            data: .init(
                attributes: .init(
                    capabilityType: try requiredBundleIDCapabilityType(input.capabilityType),
                    settings: try bundleIDCapabilitySettings(from: input.settingsJSON)
                ),
                relationships: .init(
                    bundleId: .init(data: .init(id: input.bundleID, _type: .bundleIds))
                ),
                _type: .bundleIdCapabilities
            )
        ))
    }

    private func bundleIDCapabilityUpdateBody(
        from input: AppStoreConnectBundleIDCapabilityUpdateInput
    ) throws -> Operations.BundleIdCapabilitiesUpdateInstance.Input.Body {
        .json(Components.Schemas.BundleIdCapabilityUpdateRequest(
            data: .init(
                attributes: .init(
                    capabilityType: try input.capabilityType.map(requiredBundleIDCapabilityType),
                    settings: try bundleIDCapabilitySettings(from: input.settingsJSON)
                ),
                id: input.id,
                _type: .bundleIdCapabilities
            )
        ))
    }

    private func certificateCreateBody(
        from input: AppStoreConnectCertificateCreateInput
    ) throws -> Operations.CertificatesCreateInstance.Input.Body {
        .json(Components.Schemas.CertificateCreateRequest(
            data: .init(
                attributes: .init(
                    certificateType: try requiredCertificateType(input.certificateType),
                    csrContent: input.csrContent
                ),
                relationships: certificateCreateRelationshipsPayload(input),
                _type: .certificates
            )
        ))
    }

    private func certificateUpdateBody(
        from input: AppStoreConnectCertificateUpdateInput
    ) -> Operations.CertificatesUpdateInstance.Input.Body {
        .json(Components.Schemas.CertificateUpdateRequest(
            data: .init(
                attributes: .init(activated: input.activated),
                id: input.id,
                _type: .certificates
            )
        ))
    }

    private func deviceCreateBody(
        from input: AppStoreConnectDeviceCreateInput
    ) throws -> Operations.DevicesCreateInstance.Input.Body {
        .json(Components.Schemas.DeviceCreateRequest(
            data: .init(
                attributes: .init(
                    name: input.name,
                    platform: try requiredBundleIDPlatform(input.platform),
                    udid: input.udid
                ),
                _type: .devices
            )
        ))
    }

    private func deviceUpdateBody(
        from input: AppStoreConnectDeviceUpdateInput
    ) throws -> Operations.DevicesUpdateInstance.Input.Body {
        .json(Components.Schemas.DeviceUpdateRequest(
            data: .init(
                attributes: .init(
                    name: input.name,
                    status: try optionalDeviceStatus(input.status)
                ),
                id: input.id,
                _type: .devices
            )
        ))
    }

    private func profileCreateBody(
        from input: AppStoreConnectProfileCreateInput
    ) throws -> Operations.ProfilesCreateInstance.Input.Body {
        .json(Components.Schemas.ProfileCreateRequest(
            data: .init(
                attributes: .init(
                    name: input.name,
                    profileType: try requiredProfileType(input.profileType)
                ),
                relationships: .init(
                    bundleId: .init(data: .init(id: input.bundleID, _type: .bundleIds)),
                    certificates: .init(data: input.certificateIDs.map { .init(id: $0, _type: .certificates) }),
                    devices: profileCreateDevicesPayload(input.deviceIDs)
                ),
                _type: .profiles
            )
        ))
    }

    private func userInvitationCreateBody(
        from input: AppStoreConnectUserInvitationCreateInput
    ) throws -> Operations.UserInvitationsCreateInstance.Input.Body {
        .json(Components.Schemas.UserInvitationCreateRequest(
            data: .init(
                attributes: .init(
                    allAppsVisible: input.allAppsVisible,
                    email: input.email,
                    firstName: input.firstName,
                    lastName: input.lastName,
                    provisioningAllowed: input.provisioningAllowed,
                    roles: try requiredUserRoles(input.roles)
                ),
                relationships: userInvitationCreateRelationshipsPayload(input.visibleAppIDs),
                _type: .userInvitations
            )
        ))
    }

    private func userUpdateBody(
        from input: AppStoreConnectUserUpdateInput
    ) throws -> Operations.UsersUpdateInstance.Input.Body {
        let hasAttributes = !input.roles.isEmpty
            || input.allAppsVisible != nil
            || input.provisioningAllowed != nil
        let attributes = hasAttributes
            ? Components.Schemas.UserUpdateRequest.DataPayload.AttributesPayload(
                allAppsVisible: input.allAppsVisible,
                provisioningAllowed: input.provisioningAllowed,
                roles: try optionalUserRoles(input.roles)
            )
            : nil

        return .json(Components.Schemas.UserUpdateRequest(
            data: .init(
                attributes: attributes,
                id: input.id,
                relationships: userUpdateRelationshipsPayload(input.visibleAppIDs),
                _type: .users
            )
        ))
    }

    private func betaGroupCreateBetaTestersPayload(
        _ ids: [String]
    ) -> Components.Schemas.BetaGroupCreateRequest.DataPayload.RelationshipsPayload.BetaTestersPayload? {
        guard !ids.isEmpty else { return nil }
        return .init(data: ids.map { .init(id: $0, _type: .betaTesters) })
    }

    private func betaGroupCreateBuildsPayload(
        _ ids: [String]
    ) -> Components.Schemas.BetaGroupCreateRequest.DataPayload.RelationshipsPayload.BuildsPayload? {
        guard !ids.isEmpty else { return nil }
        return .init(data: ids.map { .init(id: $0, _type: .builds) })
    }

    private func betaTesterCreateRelationshipsPayload(
        _ input: AppStoreConnectBetaTesterCreateInput
    ) -> Components.Schemas.BetaTesterCreateRequest.DataPayload.RelationshipsPayload? {
        let betaGroups = betaTesterCreateBetaGroupsPayload(input.betaGroupIDs)
        let builds = betaTesterCreateBuildsPayload(input.buildIDs)
        guard betaGroups != nil || builds != nil else { return nil }
        return .init(betaGroups: betaGroups, builds: builds)
    }

    private func betaTesterCreateBetaGroupsPayload(
        _ ids: [String]
    ) -> Components.Schemas.BetaTesterCreateRequest.DataPayload.RelationshipsPayload.BetaGroupsPayload? {
        guard !ids.isEmpty else { return nil }
        return .init(data: ids.map { .init(id: $0, _type: .betaGroups) })
    }

    private func betaTesterCreateBuildsPayload(
        _ ids: [String]
    ) -> Components.Schemas.BetaTesterCreateRequest.DataPayload.RelationshipsPayload.BuildsPayload? {
        guard !ids.isEmpty else { return nil }
        return .init(data: ids.map { .init(id: $0, _type: .builds) })
    }

    private func appStoreVersionCreateBuildPayload(
        _ id: String?
    ) -> Components.Schemas.AppStoreVersionCreateRequest.DataPayload.RelationshipsPayload.BuildPayload? {
        guard let id else { return nil }
        return .init(data: .init(id: id, _type: .builds))
    }

    private func appStoreVersionUpdateRelationshipsPayload(
        _ input: AppStoreConnectAppStoreVersionUpdateInput
    ) -> Components.Schemas.AppStoreVersionUpdateRequest.DataPayload.RelationshipsPayload? {
        guard let buildID = input.buildID else { return nil }
        return .init(build: .init(data: .init(id: buildID, _type: .builds)))
    }

    private func certificateCreateRelationshipsPayload(
        _ input: AppStoreConnectCertificateCreateInput
    ) -> Components.Schemas.CertificateCreateRequest.DataPayload.RelationshipsPayload? {
        let merchantID = certificateCreateMerchantIDPayload(input.merchantID)
        let passTypeID = certificateCreatePassTypeIDPayload(input.passTypeID)
        guard merchantID != nil || passTypeID != nil else { return nil }
        return .init(merchantId: merchantID, passTypeId: passTypeID)
    }

    private func certificateCreateMerchantIDPayload(
        _ id: String?
    ) -> Components.Schemas.CertificateCreateRequest.DataPayload.RelationshipsPayload.MerchantIdPayload? {
        guard let id else { return nil }
        return .init(data: .init(id: id, _type: .merchantIds))
    }

    private func certificateCreatePassTypeIDPayload(
        _ id: String?
    ) -> Components.Schemas.CertificateCreateRequest.DataPayload.RelationshipsPayload.PassTypeIdPayload? {
        guard let id else { return nil }
        return .init(data: .init(id: id, _type: .passTypeIds))
    }

    private func profileCreateDevicesPayload(
        _ ids: [String]
    ) -> Components.Schemas.ProfileCreateRequest.DataPayload.RelationshipsPayload.DevicesPayload? {
        guard !ids.isEmpty else { return nil }
        return .init(data: ids.map { .init(id: $0, _type: .devices) })
    }

    private func userInvitationCreateRelationshipsPayload(
        _ visibleAppIDs: [String]
    ) -> Components.Schemas.UserInvitationCreateRequest.DataPayload.RelationshipsPayload? {
        guard !visibleAppIDs.isEmpty else { return nil }
        return .init(visibleApps: .init(data: visibleAppIDs.map { .init(id: $0, _type: .apps) }))
    }

    private func userUpdateRelationshipsPayload(
        _ visibleAppIDs: [String]
    ) -> Components.Schemas.UserUpdateRequest.DataPayload.RelationshipsPayload? {
        guard !visibleAppIDs.isEmpty else { return nil }
        return .init(visibleApps: .init(data: visibleAppIDs.map { .init(id: $0, _type: .apps) }))
    }

    private func acknowledgement(
        operationID: String,
        resourceType: String,
        id: String,
        status: String
    ) -> AppStoreConnectMutationAcknowledgementResult {
        AppStoreConnectMutationAcknowledgementResult(data: .init(
            operationID: operationID,
            resourceType: resourceType,
            id: id,
            status: status
        ))
    }

    private static func betaGroupSummary(_ group: Components.Schemas.BetaGroup) -> AppStoreConnectBetaGroupSummary {
        AppStoreConnectBetaGroupSummary(
            id: group.id,
            name: group.attributes?.name,
            isInternalGroup: group.attributes?.isInternalGroup,
            publicLinkEnabled: group.attributes?.publicLinkEnabled,
            publicLinkLimit: group.attributes?.publicLinkLimit,
            feedbackEnabled: group.attributes?.feedbackEnabled,
            appID: group.relationships?.app?.data?.id
        )
    }

    private static func betaTesterSummary(_ tester: Components.Schemas.BetaTester) -> AppStoreConnectBetaTesterSummary {
        AppStoreConnectBetaTesterSummary(
            id: tester.id,
            email: tester.attributes?.email,
            firstName: tester.attributes?.firstName,
            lastName: tester.attributes?.lastName,
            state: tester.attributes?.state?.rawValue,
            inviteType: tester.attributes?.inviteType?.rawValue,
            appIDs: tester.relationships?.apps?.data?.map(\.id) ?? [],
            betaGroupIDs: tester.relationships?.betaGroups?.data?.map(\.id) ?? []
        )
    }

    private static func betaAppReviewDetailSummary(
        _ detail: Components.Schemas.BetaAppReviewDetail
    ) -> AppStoreConnectBetaAppReviewDetailSummary {
        AppStoreConnectBetaAppReviewDetailSummary(
            id: detail.id,
            contactEmail: detail.attributes?.contactEmail,
            contactFirstName: detail.attributes?.contactFirstName,
            contactLastName: detail.attributes?.contactLastName,
            contactPhone: detail.attributes?.contactPhone,
            demoAccountName: detail.attributes?.demoAccountName,
            demoAccountRequired: detail.attributes?.demoAccountRequired,
            notes: detail.attributes?.notes,
            appID: detail.relationships?.app?.data?.id
        )
    }

    private static func betaAppReviewSubmissionSummary(
        _ submission: Components.Schemas.BetaAppReviewSubmission
    ) -> AppStoreConnectBetaAppReviewSubmissionSummary {
        AppStoreConnectBetaAppReviewSubmissionSummary(
            id: submission.id,
            betaReviewState: submission.attributes?.betaReviewState?.rawValue,
            submittedDate: submission.attributes?.submittedDate,
            buildID: submission.relationships?.build?.data?.id
        )
    }

#if ASC_PUBLIC_API_RELEASE
    private static func appCategoryAssignmentSummary(
        _ appInfo: Components.Schemas.AppInfo,
        fallback input: AppStoreConnectAppCategoryUpdateInput
    ) -> AppStoreConnectAppCategoryAssignmentSummary {
        AppStoreConnectAppCategoryAssignmentSummary(
            appInfoID: appInfo.id,
            primaryCategoryID: appInfo.relationships?.primaryCategory?.data?.id ?? input.primaryCategoryID,
            secondaryCategoryID: appInfo.relationships?.secondaryCategory?.data?.id ?? input.secondaryCategoryID,
            primarySubcategoryOneID: appInfo.relationships?.primarySubcategoryOne?.data?.id ?? input.primarySubcategoryOneID,
            primarySubcategoryTwoID: appInfo.relationships?.primarySubcategoryTwo?.data?.id ?? input.primarySubcategoryTwoID,
            secondarySubcategoryOneID: appInfo.relationships?.secondarySubcategoryOne?.data?.id ?? input.secondarySubcategoryOneID,
            secondarySubcategoryTwoID: appInfo.relationships?.secondarySubcategoryTwo?.data?.id ?? input.secondarySubcategoryTwoID
        )
    }
#endif

    private static func appSummary(_ app: Components.Schemas.App) -> AppStoreConnectAppSummary {
        AppStoreConnectAppSummary(
            id: app.id,
            name: app.attributes?.name,
            bundleID: app.attributes?.bundleId,
            sku: app.attributes?.sku,
            primaryLocale: app.attributes?.primaryLocale,
            contentRightsDeclaration: app.attributes?.contentRightsDeclaration?.rawValue
        )
    }

    private static func appStoreVersionSummary(
        _ version: Components.Schemas.AppStoreVersion
    ) -> AppStoreConnectAppStoreVersionSummary {
        AppStoreConnectAppStoreVersionSummary(
            id: version.id,
            versionString: version.attributes?.versionString,
            platform: version.attributes?.platform?.rawValue,
            appStoreState: version.attributes?.appStoreState?.rawValue,
            appVersionState: version.attributes?.appVersionState?.rawValue,
            releaseType: version.attributes?.releaseType?.rawValue,
            earliestReleaseDate: version.attributes?.earliestReleaseDate
        )
    }

    private static func appStoreVersionReleaseRequestSummary(
        _ request: Components.Schemas.AppStoreVersionReleaseRequest,
        appStoreVersionID: String?
    ) -> AppStoreConnectAppStoreVersionReleaseRequestSummary {
        AppStoreConnectAppStoreVersionReleaseRequestSummary(
            id: request.id,
            appStoreVersionID: appStoreVersionID
        )
    }

    private static func reviewSubmissionSummary(
        _ submission: Components.Schemas.ReviewSubmission
    ) -> AppStoreConnectReviewSubmissionSummary {
        AppStoreConnectReviewSubmissionSummary(
            id: submission.id,
            platform: submission.attributes?.platform?.rawValue,
            state: submission.attributes?.state?.rawValue,
            submittedDate: submission.attributes?.submittedDate,
            appID: submission.relationships?.app?.data?.id,
            appStoreVersionID: submission.relationships?.appStoreVersionForReview?.data?.id
        )
    }

    private static func reviewSubmissionItemSummary(
        _ item: Components.Schemas.ReviewSubmissionItem
    ) -> AppStoreConnectReviewSubmissionItemSummary {
        AppStoreConnectReviewSubmissionItemSummary(
            id: item.id,
            state: item.attributes?.state?.rawValue,
            appStoreVersionID: item.relationships?.appStoreVersion?.data?.id
        )
    }

    private static func bundleIDSummary(_ bundleID: Components.Schemas.BundleId) -> AppStoreConnectBundleIDSummary {
        AppStoreConnectBundleIDSummary(
            id: bundleID.id,
            identifier: bundleID.attributes?.identifier,
            name: bundleID.attributes?.name,
            platform: bundleID.attributes?.platform?.rawValue,
            seedID: bundleID.attributes?.seedId,
            appID: bundleID.relationships?.app?.data?.id,
            profileIDs: bundleID.relationships?.profiles?.data?.map(\.id) ?? []
        )
    }

    private static func certificateSummary(
        _ certificate: Components.Schemas.Certificate
    ) -> AppStoreConnectCertificateSummary {
        AppStoreConnectCertificateSummary(
            id: certificate.id,
            name: certificate.attributes?.name,
            displayName: certificate.attributes?.displayName,
            certificateType: certificate.attributes?.certificateType?.rawValue,
            serialNumber: certificate.attributes?.serialNumber,
            platform: certificate.attributes?.platform?.rawValue,
            expirationDate: certificate.attributes?.expirationDate,
            activated: certificate.attributes?.activated
        )
    }

    private static func deviceSummary(_ device: Components.Schemas.Device) -> AppStoreConnectDeviceSummary {
        AppStoreConnectDeviceSummary(
            id: device.id,
            name: device.attributes?.name,
            udid: device.attributes?.udid,
            platform: device.attributes?.platform?.rawValue,
            status: device.attributes?.status?.rawValue,
            deviceClass: device.attributes?.deviceClass?.rawValue,
            model: device.attributes?.model,
            addedDate: device.attributes?.addedDate
        )
    }

    private static func profileSummary(_ profile: Components.Schemas.Profile) -> AppStoreConnectProfileSummary {
        AppStoreConnectProfileSummary(
            id: profile.id,
            name: profile.attributes?.name,
            platform: profile.attributes?.platform?.rawValue,
            profileType: profile.attributes?.profileType?.rawValue,
            profileState: profile.attributes?.profileState?.rawValue,
            uuid: profile.attributes?.uuid,
            createdDate: profile.attributes?.createdDate,
            expirationDate: profile.attributes?.expirationDate,
            bundleID: profile.relationships?.bundleId?.data?.id,
            certificateIDs: profile.relationships?.certificates?.data?.map(\.id) ?? [],
            deviceIDs: profile.relationships?.devices?.data?.map(\.id) ?? []
        )
    }

    private static func userSummary(_ user: Components.Schemas.User) -> AppStoreConnectUserSummary {
        AppStoreConnectUserSummary(
            id: user.id,
            username: user.attributes?.username,
            firstName: user.attributes?.firstName,
            lastName: user.attributes?.lastName,
            roles: user.attributes?.roles?.map(\.rawValue) ?? [],
            allAppsVisible: user.attributes?.allAppsVisible,
            provisioningAllowed: user.attributes?.provisioningAllowed,
            visibleAppIDs: user.relationships?.visibleApps?.data?.map(\.id) ?? []
        )
    }

    private static func userInvitationSummary(
        _ invitation: Components.Schemas.UserInvitation
    ) -> AppStoreConnectUserInvitationSummary {
        AppStoreConnectUserInvitationSummary(
            id: invitation.id,
            email: invitation.attributes?.email,
            firstName: invitation.attributes?.firstName,
            lastName: invitation.attributes?.lastName,
            roles: invitation.attributes?.roles?.map(\.rawValue) ?? [],
            allAppsVisible: invitation.attributes?.allAppsVisible,
            provisioningAllowed: invitation.attributes?.provisioningAllowed,
            expirationDate: invitation.attributes?.expirationDate,
            visibleAppIDs: invitation.relationships?.visibleApps?.data?.map(\.id) ?? []
        )
    }

    private func requiredPlatform(_ value: String) throws -> Components.Schemas.Platform {
        guard let platform = Components.Schemas.Platform(rawValue: value.uppercased()) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported platform: \(value).")
        }
        return platform
    }

    private func optionalPlatform(_ value: String?) throws -> Components.Schemas.Platform? {
        guard let value else { return nil }
        return try requiredPlatform(value)
    }

    private func optionalCreateReleaseType(
        _ value: String?
    ) throws -> Components.Schemas.AppStoreVersionCreateRequest.DataPayload.AttributesPayload.ReleaseTypePayload? {
        guard let value else { return nil }
        guard let releaseType = Components.Schemas.AppStoreVersionCreateRequest.DataPayload.AttributesPayload.ReleaseTypePayload(rawValue: value.uppercased()) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported release type: \(value).")
        }
        return releaseType
    }

    private func optionalUpdateReleaseType(
        _ value: String?
    ) throws -> Components.Schemas.AppStoreVersionUpdateRequest.DataPayload.AttributesPayload.ReleaseTypePayload? {
        guard let value else { return nil }
        guard let releaseType = Components.Schemas.AppStoreVersionUpdateRequest.DataPayload.AttributesPayload.ReleaseTypePayload(rawValue: value.uppercased()) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported release type: \(value).")
        }
        return releaseType
    }

    private func optionalCreateReviewType(
        _ value: String?
    ) throws -> Components.Schemas.AppStoreVersionCreateRequest.DataPayload.AttributesPayload.ReviewTypePayload? {
        guard let value else { return nil }
        guard let reviewType = Components.Schemas.AppStoreVersionCreateRequest.DataPayload.AttributesPayload.ReviewTypePayload(rawValue: value.uppercased()) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported review type: \(value).")
        }
        return reviewType
    }

    private func optionalUpdateReviewType(
        _ value: String?
    ) throws -> Components.Schemas.AppStoreVersionUpdateRequest.DataPayload.AttributesPayload.ReviewTypePayload? {
        guard let value else { return nil }
        guard let reviewType = Components.Schemas.AppStoreVersionUpdateRequest.DataPayload.AttributesPayload.ReviewTypePayload(rawValue: value.uppercased()) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported review type: \(value).")
        }
        return reviewType
    }

    private func optionalContentRightsDeclaration(
        _ value: String?
    ) throws -> Components.Schemas.AppUpdateRequest.DataPayload.AttributesPayload.ContentRightsDeclarationPayload? {
        guard let value else { return nil }
        guard let declaration = Components.Schemas.AppUpdateRequest.DataPayload.AttributesPayload.ContentRightsDeclarationPayload(rawValue: value.uppercased()) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported content rights declaration: \(value).")
        }
        return declaration
    }

#if ASC_PUBLIC_API_RELEASE
    private func optionalAppEventCreateBadge(
        _ value: String?
    ) throws -> Components.Schemas.AppEventCreateRequest.DataPayload.AttributesPayload.BadgePayload? {
        guard let value else { return nil }
        guard let badge = Components.Schemas.AppEventCreateRequest.DataPayload.AttributesPayload.BadgePayload(rawValue: value.uppercased()) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported app event badge: \(value).")
        }
        return badge
    }

    private func optionalAppEventUpdateBadge(
        _ value: String?
    ) throws -> Components.Schemas.AppEventUpdateRequest.DataPayload.AttributesPayload.BadgePayload? {
        guard let value else { return nil }
        guard let badge = Components.Schemas.AppEventUpdateRequest.DataPayload.AttributesPayload.BadgePayload(rawValue: value.uppercased()) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported app event badge: \(value).")
        }
        return badge
    }

    private func optionalAppEventCreatePriority(
        _ value: String?
    ) throws -> Components.Schemas.AppEventCreateRequest.DataPayload.AttributesPayload.PriorityPayload? {
        guard let value else { return nil }
        guard let priority = Components.Schemas.AppEventCreateRequest.DataPayload.AttributesPayload.PriorityPayload(rawValue: value.uppercased()) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported app event priority: \(value).")
        }
        return priority
    }

    private func optionalAppEventUpdatePriority(
        _ value: String?
    ) throws -> Components.Schemas.AppEventUpdateRequest.DataPayload.AttributesPayload.PriorityPayload? {
        guard let value else { return nil }
        guard let priority = Components.Schemas.AppEventUpdateRequest.DataPayload.AttributesPayload.PriorityPayload(rawValue: value.uppercased()) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported app event priority: \(value).")
        }
        return priority
    }

    private func optionalAppEventCreatePurpose(
        _ value: String?
    ) throws -> Components.Schemas.AppEventCreateRequest.DataPayload.AttributesPayload.PurposePayload? {
        guard let value else { return nil }
        guard let purpose = Components.Schemas.AppEventCreateRequest.DataPayload.AttributesPayload.PurposePayload(rawValue: value.uppercased()) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported app event purpose: \(value).")
        }
        return purpose
    }

    private func optionalAppEventUpdatePurpose(
        _ value: String?
    ) throws -> Components.Schemas.AppEventUpdateRequest.DataPayload.AttributesPayload.PurposePayload? {
        guard let value else { return nil }
        guard let purpose = Components.Schemas.AppEventUpdateRequest.DataPayload.AttributesPayload.PurposePayload(rawValue: value.uppercased()) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported app event purpose: \(value).")
        }
        return purpose
    }

    private func appCategoryUpdateHasRelationship(_ input: AppStoreConnectAppCategoryUpdateInput) -> Bool {
        input.primaryCategoryID != nil
            || input.secondaryCategoryID != nil
            || input.primarySubcategoryOneID != nil
            || input.primarySubcategoryTwoID != nil
            || input.secondarySubcategoryOneID != nil
            || input.secondarySubcategoryTwoID != nil
    }

    private func appInfoPrimaryCategoryPayload(
        _ id: String?
    ) -> Components.Schemas.AppInfoUpdateRequest.DataPayload.RelationshipsPayload.PrimaryCategoryPayload? {
        guard let id else { return nil }
        return .init(data: .init(id: id, _type: .appCategories))
    }

    private func appInfoPrimarySubcategoryOnePayload(
        _ id: String?
    ) -> Components.Schemas.AppInfoUpdateRequest.DataPayload.RelationshipsPayload.PrimarySubcategoryOnePayload? {
        guard let id else { return nil }
        return .init(data: .init(id: id, _type: .appCategories))
    }

    private func appInfoPrimarySubcategoryTwoPayload(
        _ id: String?
    ) -> Components.Schemas.AppInfoUpdateRequest.DataPayload.RelationshipsPayload.PrimarySubcategoryTwoPayload? {
        guard let id else { return nil }
        return .init(data: .init(id: id, _type: .appCategories))
    }

    private func appInfoSecondaryCategoryPayload(
        _ id: String?
    ) -> Components.Schemas.AppInfoUpdateRequest.DataPayload.RelationshipsPayload.SecondaryCategoryPayload? {
        guard let id else { return nil }
        return .init(data: .init(id: id, _type: .appCategories))
    }

    private func appInfoSecondarySubcategoryOnePayload(
        _ id: String?
    ) -> Components.Schemas.AppInfoUpdateRequest.DataPayload.RelationshipsPayload.SecondarySubcategoryOnePayload? {
        guard let id else { return nil }
        return .init(data: .init(id: id, _type: .appCategories))
    }

    private func appInfoSecondarySubcategoryTwoPayload(
        _ id: String?
    ) -> Components.Schemas.AppInfoUpdateRequest.DataPayload.RelationshipsPayload.SecondarySubcategoryTwoPayload? {
        guard let id else { return nil }
        return .init(data: .init(id: id, _type: .appCategories))
    }

    private func optionalEnum<T>(
        _ value: String?,
        fieldName: String,
        as type: T.Type
    ) throws -> T? where T: RawRepresentable, T.RawValue == String {
        guard let value else { return nil }
        let normalized = Self.normalizedOpenAPIEnum(value)
        guard let typedValue = T(rawValue: normalized) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported \(fieldName) value: \(value).")
        }
        return typedValue
    }

    private static func canonicalAgeRatingFrequencyRatings(
        _ input: AppStoreConnectAgeRatingUpdateInput
    ) throws -> [String: String] {
        var values = try canonicalAgeRatingValues(
            input.frequencyRatings,
            allowedFields: ageRatingFrequencyFields,
            kind: "frequency rating"
        )
        if input.allNone {
            ageRatingFrequencyFields.forEach { values[$0] = "NONE" }
        }
        return values
    }

    private static func canonicalAgeRatingBooleanRatings(
        _ input: AppStoreConnectAgeRatingUpdateInput
    ) throws -> [String: Bool] {
        var values = try canonicalAgeRatingValues(
            input.booleanRatings,
            allowedFields: ageRatingBooleanFields,
            kind: "boolean rating"
        )
        if input.allNone {
            ageRatingBooleanFields.forEach { values[$0] = false }
        }
        return values
    }

    private static func canonicalAgeRatingValues<Value>(
        _ values: [String: Value],
        allowedFields: [String],
        kind: String
    ) throws -> [String: Value] {
        let keyMap = Dictionary(uniqueKeysWithValues: allowedFields.map { (normalizedAgeRatingFieldName($0), $0) })
        return try Dictionary(uniqueKeysWithValues: values.map { key, value in
            let normalized = normalizedAgeRatingFieldName(key)
            guard let canonical = keyMap[normalized] else {
                throw AppStoreConnectError.invalidConfiguration("Unsupported age rating \(kind) field: \(key).")
            }
            return (canonical, value)
        })
    }

    private static func normalizedAgeRatingFieldName(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: " ", with: "")
            .lowercased()
    }

    private static func normalizedOpenAPIEnum(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: " ", with: "_")
            .uppercased()
    }

    private static let ageRatingFrequencyFields = [
        "alcoholTobaccoOrDrugUseOrReferences",
        "contests",
        "gamblingSimulated",
        "gunsOrOtherWeapons",
        "horrorOrFearThemes",
        "matureOrSuggestiveThemes",
        "medicalOrTreatmentInformation",
        "profanityOrCrudeHumor",
        "sexualContentGraphicAndNudity",
        "sexualContentOrNudity",
        "violenceCartoonOrFantasy",
        "violenceRealistic",
        "violenceRealisticProlongedGraphicOrSadistic",
    ]

    private static let ageRatingBooleanFields = [
        "advertising",
        "ageAssurance",
        "gambling",
        "healthOrWellnessTopics",
        "lootBox",
        "messagingAndChat",
        "parentalControls",
        "unrestrictedWebAccess",
        "userGeneratedContent",
    ]
#endif

#if ASC_PUBLIC_API_DISTRIBUTION
    private func requiredWebhookEventTypes(_ values: [String]) throws -> [Components.Schemas.WebhookEventType] {
        let eventTypes = try webhookEventTypes(values)
        guard !eventTypes.isEmpty else {
            throw AppStoreConnectError.invalidConfiguration("At least one webhook event type is required.")
        }
        return eventTypes
    }

    private func optionalWebhookEventTypes(_ values: [String]) throws -> [Components.Schemas.WebhookEventType]? {
        let eventTypes = try webhookEventTypes(values)
        return eventTypes.isEmpty ? nil : eventTypes
    }

    private func webhookEventTypes(_ values: [String]) throws -> [Components.Schemas.WebhookEventType] {
        try values.map { value in
            let normalized = value
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "-", with: "_")
                .replacingOccurrences(of: ".", with: "_")
                .replacingOccurrences(of: " ", with: "_")
                .uppercased()
            guard let eventType = Components.Schemas.WebhookEventType(rawValue: normalized) else {
                throw AppStoreConnectError.invalidConfiguration("Unsupported webhook event type: \(value).")
            }
            return eventType
        }
    }
#endif

    private func requiredBundleIDPlatform(_ value: String) throws -> Components.Schemas.BundleIdPlatform {
        guard let platform = Components.Schemas.BundleIdPlatform(rawValue: value.uppercased()) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported bundle ID platform: \(value).")
        }
        return platform
    }

    private func requiredBundleIDCapabilityType(_ value: String) throws -> Components.Schemas.CapabilityType {
        let normalized = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: " ", with: "_")
            .uppercased()
        guard let capabilityType = Components.Schemas.CapabilityType(rawValue: normalized) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported bundle ID capability type: \(value).")
        }
        return capabilityType
    }

    private func bundleIDCapabilitySettings(
        from json: String?
    ) throws -> [Components.Schemas.CapabilitySetting]? {
        guard let json, !json.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        let data = Data(json.utf8)
        do {
            return try JSONDecoder().decode([Components.Schemas.CapabilitySetting].self, from: data)
        } catch {
            throw AppStoreConnectError.decodingFailed("Invalid bundle ID capability settings JSON: \(error).")
        }
    }

    private func requiredCertificateType(_ value: String) throws -> Components.Schemas.CertificateType {
        guard let certificateType = Components.Schemas.CertificateType(rawValue: value.uppercased()) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported certificate type: \(value).")
        }
        return certificateType
    }

    private func optionalDeviceStatus(
        _ value: String?
    ) throws -> Components.Schemas.DeviceUpdateRequest.DataPayload.AttributesPayload.StatusPayload? {
        guard let value else { return nil }
        guard let status = Components.Schemas.DeviceUpdateRequest.DataPayload.AttributesPayload.StatusPayload(rawValue: value.uppercased()) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported device status: \(value).")
        }
        return status
    }

    private func requiredProfileType(
        _ value: String
    ) throws -> Components.Schemas.ProfileCreateRequest.DataPayload.AttributesPayload.ProfileTypePayload {
        guard let profileType = Components.Schemas.ProfileCreateRequest.DataPayload.AttributesPayload.ProfileTypePayload(rawValue: value.uppercased()) else {
            throw AppStoreConnectError.invalidConfiguration("Unsupported profile type: \(value).")
        }
        return profileType
    }

    private func requiredUserRoles(_ values: [String]) throws -> [Components.Schemas.UserRole] {
        let roles = try userRoles(values)
        guard !roles.isEmpty else {
            throw AppStoreConnectError.invalidConfiguration("At least one user role is required.")
        }
        return roles
    }

    private func optionalUserRoles(_ values: [String]) throws -> [Components.Schemas.UserRole]? {
        let roles = try userRoles(values)
        return roles.isEmpty ? nil : roles
    }

    private func userRoles(_ values: [String]) throws -> [Components.Schemas.UserRole] {
        try values.map { value in
            let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            guard let role = Components.Schemas.UserRole(rawValue: normalized) else {
                throw AppStoreConnectError.invalidConfiguration("Unsupported user role: \(value).")
            }
            return role
        }
    }

    private static func compactInputs(_ pairs: [(String, String?)]) -> [String: String] {
        Dictionary(uniqueKeysWithValues: pairs.compactMap { key, value in
            value.map { (key, $0) }
        })
    }

    private static func joined(_ values: [String]) -> String? {
        values.isEmpty ? nil : values.joined(separator: ",")
    }

    private static func iso8601String(from date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }
}
