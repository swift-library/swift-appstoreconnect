// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import AppStoreConnectCore
import AppStoreConnectPublicAPI
import Foundation

public struct AppStoreConnectAppListInput: Codable, Sendable, Equatable {
  public var ids: [String]
  public var names: [String]
  public var bundleIDs: [String]
  public var skus: [String]
  public var sort: String?
  public var limit: Int?

  public init(
    ids: [String] = [],
    names: [String] = [],
    bundleIDs: [String] = [],
    skus: [String] = [],
    sort: String? = nil,
    limit: Int? = nil
  ) {
    self.ids = ids
    self.names = names
    self.bundleIDs = bundleIDs
    self.skus = skus
    self.sort = sort
    self.limit = limit
  }
}

public struct AppStoreConnectAppViewInput: Codable, Sendable, Equatable {
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectAppCategoryListInput: Codable, Sendable, Equatable {
  public var platforms: [String]
  public var existsParent: Bool?
  public var includeParent: Bool
  public var includeSubcategories: Bool
  public var limit: Int?
  public var subcategoriesLimit: Int?

  public init(
    platforms: [String] = [],
    existsParent: Bool? = nil,
    includeParent: Bool = false,
    includeSubcategories: Bool = false,
    limit: Int? = nil,
    subcategoriesLimit: Int? = nil
  ) {
    self.platforms = platforms
    self.existsParent = existsParent
    self.includeParent = includeParent
    self.includeSubcategories = includeSubcategories
    self.limit = limit
    self.subcategoriesLimit = subcategoriesLimit
  }
}

public struct AppStoreConnectAppCategoryViewInput: Codable, Sendable, Equatable {
  public var id: String
  public var includeParent: Bool
  public var includeSubcategories: Bool
  public var subcategoriesLimit: Int?

  public init(
    id: String,
    includeParent: Bool = false,
    includeSubcategories: Bool = false,
    subcategoriesLimit: Int? = nil
  ) {
    self.id = id
    self.includeParent = includeParent
    self.includeSubcategories = includeSubcategories
    self.subcategoriesLimit = subcategoriesLimit
  }
}

public struct AppStoreConnectAppCategoryParentInput: Codable, Sendable, Equatable {
  public var id: String
  public var fields: [String]

  public init(id: String, fields: [String] = []) {
    self.id = id
    self.fields = fields
  }
}

public struct AppStoreConnectAppCategorySubcategoriesInput: Codable, Sendable, Equatable {
  public var id: String
  public var fields: [String]
  public var limit: Int?

  public init(id: String, fields: [String] = [], limit: Int? = nil) {
    self.id = id
    self.fields = fields
    self.limit = limit
  }
}

public struct AppStoreConnectAgeRatingViewInput: Codable, Sendable, Equatable {
  public var appInfoID: String
  public var fields: [String]

  public init(appInfoID: String, fields: [String] = []) {
    self.appInfoID = appInfoID
    self.fields = fields
  }
}

public struct AppStoreConnectAppEventListInput: Codable, Sendable, Equatable {
  public var appID: String
  public var ids: [String]
  public var eventStates: [String]
  public var fields: [String]
  public var localizationFields: [String]
  public var includeLocalizations: Bool
  public var limit: Int?
  public var localizationsLimit: Int?

  public init(
    appID: String,
    ids: [String] = [],
    eventStates: [String] = [],
    fields: [String] = [],
    localizationFields: [String] = [],
    includeLocalizations: Bool = false,
    limit: Int? = nil,
    localizationsLimit: Int? = nil
  ) {
    self.appID = appID
    self.ids = ids
    self.eventStates = eventStates
    self.fields = fields
    self.localizationFields = localizationFields
    self.includeLocalizations = includeLocalizations
    self.limit = limit
    self.localizationsLimit = localizationsLimit
  }
}

public struct AppStoreConnectAppEventViewInput: Codable, Sendable, Equatable {
  public var id: String
  public var fields: [String]
  public var localizationFields: [String]
  public var includeLocalizations: Bool
  public var localizationsLimit: Int?

  public init(
    id: String,
    fields: [String] = [],
    localizationFields: [String] = [],
    includeLocalizations: Bool = false,
    localizationsLimit: Int? = nil
  ) {
    self.id = id
    self.fields = fields
    self.localizationFields = localizationFields
    self.includeLocalizations = includeLocalizations
    self.localizationsLimit = localizationsLimit
  }
}

#if ASC_PUBLIC_API_METADATA_MEDIA
  public struct AppStoreConnectAppClipListInput: Codable, Sendable, Equatable {
    public var appID: String
    public var bundleIDs: [String]
    public var fields: [String]
    public var defaultExperienceFields: [String]
    public var includeApp: Bool
    public var includeDefaultExperiences: Bool
    public var limit: Int?
    public var defaultExperiencesLimit: Int?

    public init(
      appID: String,
      bundleIDs: [String] = [],
      fields: [String] = [],
      defaultExperienceFields: [String] = [],
      includeApp: Bool = false,
      includeDefaultExperiences: Bool = false,
      limit: Int? = nil,
      defaultExperiencesLimit: Int? = nil
    ) {
      self.appID = appID
      self.bundleIDs = bundleIDs
      self.fields = fields
      self.defaultExperienceFields = defaultExperienceFields
      self.includeApp = includeApp
      self.includeDefaultExperiences = includeDefaultExperiences
      self.limit = limit
      self.defaultExperiencesLimit = defaultExperiencesLimit
    }
  }

  public struct AppStoreConnectAppClipViewInput: Codable, Sendable, Equatable {
    public var id: String
    public var fields: [String]
    public var defaultExperienceFields: [String]
    public var includeApp: Bool
    public var includeDefaultExperiences: Bool
    public var defaultExperiencesLimit: Int?

    public init(
      id: String,
      fields: [String] = [],
      defaultExperienceFields: [String] = [],
      includeApp: Bool = false,
      includeDefaultExperiences: Bool = false,
      defaultExperiencesLimit: Int? = nil
    ) {
      self.id = id
      self.fields = fields
      self.defaultExperienceFields = defaultExperienceFields
      self.includeApp = includeApp
      self.includeDefaultExperiences = includeDefaultExperiences
      self.defaultExperiencesLimit = defaultExperiencesLimit
    }
  }

  public struct AppStoreConnectAppClipDefaultExperienceListInput: Codable, Sendable, Equatable {
    public var appClipID: String
    public var fields: [String]
    public var localizationFields: [String]
    public var includeAppClip: Bool
    public var includeLocalizations: Bool
    public var includeReviewDetail: Bool
    public var limit: Int?
    public var localizationsLimit: Int?
    public var hasReleaseWithAppStoreVersion: Bool?

    public init(
      appClipID: String,
      fields: [String] = [],
      localizationFields: [String] = [],
      includeAppClip: Bool = false,
      includeLocalizations: Bool = false,
      includeReviewDetail: Bool = false,
      limit: Int? = nil,
      localizationsLimit: Int? = nil,
      hasReleaseWithAppStoreVersion: Bool? = nil
    ) {
      self.appClipID = appClipID
      self.fields = fields
      self.localizationFields = localizationFields
      self.includeAppClip = includeAppClip
      self.includeLocalizations = includeLocalizations
      self.includeReviewDetail = includeReviewDetail
      self.limit = limit
      self.localizationsLimit = localizationsLimit
      self.hasReleaseWithAppStoreVersion = hasReleaseWithAppStoreVersion
    }
  }

  public struct AppStoreConnectAppClipDefaultExperienceViewInput: Codable, Sendable, Equatable {
    public var id: String
    public var fields: [String]
    public var localizationFields: [String]
    public var includeAppClip: Bool
    public var includeLocalizations: Bool
    public var includeReviewDetail: Bool
    public var localizationsLimit: Int?

    public init(
      id: String,
      fields: [String] = [],
      localizationFields: [String] = [],
      includeAppClip: Bool = false,
      includeLocalizations: Bool = false,
      includeReviewDetail: Bool = false,
      localizationsLimit: Int? = nil
    ) {
      self.id = id
      self.fields = fields
      self.localizationFields = localizationFields
      self.includeAppClip = includeAppClip
      self.includeLocalizations = includeLocalizations
      self.includeReviewDetail = includeReviewDetail
      self.localizationsLimit = localizationsLimit
    }
  }

  public struct AppStoreConnectAppClipLocalizationListInput: Codable, Sendable, Equatable {
    public var defaultExperienceID: String
    public var locales: [String]
    public var fields: [String]
    public var includeDefaultExperience: Bool
    public var includeHeaderImage: Bool
    public var limit: Int?

    public init(
      defaultExperienceID: String,
      locales: [String] = [],
      fields: [String] = [],
      includeDefaultExperience: Bool = false,
      includeHeaderImage: Bool = false,
      limit: Int? = nil
    ) {
      self.defaultExperienceID = defaultExperienceID
      self.locales = locales
      self.fields = fields
      self.includeDefaultExperience = includeDefaultExperience
      self.includeHeaderImage = includeHeaderImage
      self.limit = limit
    }
  }

  public struct AppStoreConnectAppClipLocalizationViewInput: Codable, Sendable, Equatable {
    public var id: String
    public var fields: [String]
    public var includeDefaultExperience: Bool
    public var includeHeaderImage: Bool

    public init(
      id: String,
      fields: [String] = [],
      includeDefaultExperience: Bool = false,
      includeHeaderImage: Bool = false
    ) {
      self.id = id
      self.fields = fields
      self.includeDefaultExperience = includeDefaultExperience
      self.includeHeaderImage = includeHeaderImage
    }
  }
#endif

#if ASC_PUBLIC_API_GAME_CENTER
  public struct AppStoreConnectGameCenterDetailForAppInput: Codable, Sendable, Equatable {
    public var appID: String
    public var fields: [String]
    public var includeApp: Bool
    public var includeAchievements: Bool
    public var includeLeaderboards: Bool
    public var includeLeaderboardSets: Bool
    public var includeChallenges: Bool
    public var relatedLimit: Int?

    public init(
      appID: String,
      fields: [String] = [],
      includeApp: Bool = false,
      includeAchievements: Bool = false,
      includeLeaderboards: Bool = false,
      includeLeaderboardSets: Bool = false,
      includeChallenges: Bool = false,
      relatedLimit: Int? = nil
    ) {
      self.appID = appID
      self.fields = fields
      self.includeApp = includeApp
      self.includeAchievements = includeAchievements
      self.includeLeaderboards = includeLeaderboards
      self.includeLeaderboardSets = includeLeaderboardSets
      self.includeChallenges = includeChallenges
      self.relatedLimit = relatedLimit
    }
  }

  public struct AppStoreConnectGameCenterDetailViewInput: Codable, Sendable, Equatable {
    public var id: String
    public var fields: [String]
    public var includeApp: Bool
    public var includeAchievements: Bool
    public var includeLeaderboards: Bool
    public var includeLeaderboardSets: Bool
    public var includeChallenges: Bool
    public var relatedLimit: Int?

    public init(
      id: String,
      fields: [String] = [],
      includeApp: Bool = false,
      includeAchievements: Bool = false,
      includeLeaderboards: Bool = false,
      includeLeaderboardSets: Bool = false,
      includeChallenges: Bool = false,
      relatedLimit: Int? = nil
    ) {
      self.id = id
      self.fields = fields
      self.includeApp = includeApp
      self.includeAchievements = includeAchievements
      self.includeLeaderboards = includeLeaderboards
      self.includeLeaderboardSets = includeLeaderboardSets
      self.includeChallenges = includeChallenges
      self.relatedLimit = relatedLimit
    }
  }

  public struct AppStoreConnectGameCenterNamedResourceListInput: Codable, Sendable, Equatable {
    public var detailID: String
    public var ids: [String]
    public var referenceNames: [String]
    public var archived: String?
    public var fields: [String]
    public var limit: Int?

    public init(
      detailID: String,
      ids: [String] = [],
      referenceNames: [String] = [],
      archived: String? = nil,
      fields: [String] = [],
      limit: Int? = nil
    ) {
      self.detailID = detailID
      self.ids = ids
      self.referenceNames = referenceNames
      self.archived = archived
      self.fields = fields
      self.limit = limit
    }
  }

  public struct AppStoreConnectGameCenterResourceViewInput: Codable, Sendable, Equatable {
    public var id: String
    public var fields: [String]

    public init(id: String, fields: [String] = []) {
      self.id = id
      self.fields = fields
    }
  }
#endif

public struct AppStoreConnectEULAViewInput: Codable, Sendable, Equatable {
  public var id: String
  public var fields: [String]
  public var includeApp: Bool
  public var includeTerritories: Bool
  public var territoriesLimit: Int?

  public init(
    id: String,
    fields: [String] = [],
    includeApp: Bool = false,
    includeTerritories: Bool = false,
    territoriesLimit: Int? = nil
  ) {
    self.id = id
    self.fields = fields
    self.includeApp = includeApp
    self.includeTerritories = includeTerritories
    self.territoriesLimit = territoriesLimit
  }
}

public struct AppStoreConnectTerritoryListInput: Codable, Sendable, Equatable {
  public var fields: [String]
  public var limit: Int?

  public init(fields: [String] = [], limit: Int? = nil) {
    self.fields = fields
    self.limit = limit
  }
}

public struct AppStoreConnectAlternativeDistributionDomainListInput: Codable, Sendable, Equatable {
  public var fields: [String]
  public var limit: Int?

  public init(fields: [String] = [], limit: Int? = nil) {
    self.fields = fields
    self.limit = limit
  }
}

public struct AppStoreConnectAlternativeDistributionDomainViewInput: Codable, Sendable, Equatable {
  public var id: String
  public var fields: [String]

  public init(id: String, fields: [String] = []) {
    self.id = id
    self.fields = fields
  }
}

public struct AppStoreConnectAlternativeDistributionKeyListInput: Codable, Sendable, Equatable {
  public var existsApp: Bool?
  public var fields: [String]
  public var limit: Int?

  public init(existsApp: Bool? = nil, fields: [String] = [], limit: Int? = nil) {
    self.existsApp = existsApp
    self.fields = fields
    self.limit = limit
  }
}

public struct AppStoreConnectAlternativeDistributionKeyViewInput: Codable, Sendable, Equatable {
  public var id: String
  public var fields: [String]

  public init(id: String, fields: [String] = []) {
    self.id = id
    self.fields = fields
  }
}

public struct AppStoreConnectMarketplaceWebhookListInput: Codable, Sendable, Equatable {
  public var fields: [String]
  public var limit: Int?

  public init(fields: [String] = [], limit: Int? = nil) {
    self.fields = fields
    self.limit = limit
  }
}

public struct AppStoreConnectWebhookListInput: Codable, Sendable, Equatable {
  public var appID: String
  public var fields: [String]
  public var includeApp: Bool
  public var limit: Int?

  public init(
    appID: String,
    fields: [String] = [],
    includeApp: Bool = false,
    limit: Int? = nil
  ) {
    self.appID = appID
    self.fields = fields
    self.includeApp = includeApp
    self.limit = limit
  }
}

public struct AppStoreConnectWebhookViewInput: Codable, Sendable, Equatable {
  public var id: String
  public var fields: [String]
  public var includeApp: Bool

  public init(id: String, fields: [String] = [], includeApp: Bool = false) {
    self.id = id
    self.fields = fields
    self.includeApp = includeApp
  }
}

public struct AppStoreConnectWebhookDeliveryListInput: Codable, Sendable, Equatable {
  public var webhookID: String
  public var states: [String]
  public var createdDateGreaterThanOrEqualTo: [String]
  public var createdDateLessThan: [String]
  public var fields: [String]
  public var eventFields: [String]
  public var includeEvent: Bool
  public var limit: Int?

  public init(
    webhookID: String,
    states: [String] = [],
    createdDateGreaterThanOrEqualTo: [String] = [],
    createdDateLessThan: [String] = [],
    fields: [String] = [],
    eventFields: [String] = [],
    includeEvent: Bool = false,
    limit: Int? = nil
  ) {
    self.webhookID = webhookID
    self.states = states
    self.createdDateGreaterThanOrEqualTo = createdDateGreaterThanOrEqualTo
    self.createdDateLessThan = createdDateLessThan
    self.fields = fields
    self.eventFields = eventFields
    self.includeEvent = includeEvent
    self.limit = limit
  }
}

public struct AppStoreConnectWebhookDeliveryLinkageListInput: Codable, Sendable, Equatable {
  public var webhookID: String
  public var limit: Int?

  public init(webhookID: String, limit: Int? = nil) {
    self.webhookID = webhookID
    self.limit = limit
  }
}

public struct AppStoreConnectBuildListInput: Codable, Sendable, Equatable {
  public var appID: String?
  public var buildIDs: [String]
  public var buildNumbers: [String]
  public var versions: [String]
  public var platforms: [String]
  public var processingStates: [String]
  public var sort: String?
  public var limit: Int?

  public init(
    appID: String? = nil,
    buildIDs: [String] = [],
    buildNumbers: [String] = [],
    versions: [String] = [],
    platforms: [String] = [],
    processingStates: [String] = [],
    sort: String? = nil,
    limit: Int? = nil
  ) {
    self.appID = appID
    self.buildIDs = buildIDs
    self.buildNumbers = buildNumbers
    self.versions = versions
    self.platforms = platforms
    self.processingStates = processingStates
    self.sort = sort
    self.limit = limit
  }
}

public struct AppStoreConnectBuildInfoInput: Codable, Sendable, Equatable {
  public var id: String?
  public var latestSelector: AppStoreConnectBuildListInput?

  public init(id: String? = nil, latestSelector: AppStoreConnectBuildListInput? = nil) {
    self.id = id
    self.latestSelector = latestSelector
  }
}

public struct AppStoreConnectBuildBetaDetailListInput: Codable, Sendable, Equatable {
  public var ids: [String]
  public var buildIDs: [String]
  public var limit: Int?

  public init(ids: [String] = [], buildIDs: [String] = [], limit: Int? = nil) {
    self.ids = ids
    self.buildIDs = buildIDs
    self.limit = limit
  }
}

public struct AppStoreConnectBuildBetaDetailViewInput: Codable, Sendable, Equatable {
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectPreReleaseVersionListInput: Codable, Sendable, Equatable {
  public var appIDs: [String]
  public var buildIDs: [String]
  public var versions: [String]
  public var buildVersions: [String]
  public var platforms: [String]
  public var buildAudienceTypes: [String]
  public var processingStates: [String]
  public var buildExpired: String?
  public var sort: String?
  public var limit: Int?

  public init(
    appIDs: [String] = [],
    buildIDs: [String] = [],
    versions: [String] = [],
    buildVersions: [String] = [],
    platforms: [String] = [],
    buildAudienceTypes: [String] = [],
    processingStates: [String] = [],
    buildExpired: String? = nil,
    sort: String? = nil,
    limit: Int? = nil
  ) {
    self.appIDs = appIDs
    self.buildIDs = buildIDs
    self.versions = versions
    self.buildVersions = buildVersions
    self.platforms = platforms
    self.buildAudienceTypes = buildAudienceTypes
    self.processingStates = processingStates
    self.buildExpired = buildExpired
    self.sort = sort
    self.limit = limit
  }
}

public struct AppStoreConnectPreReleaseVersionViewInput: Codable, Sendable, Equatable {
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectAppStoreVersionListInput: Codable, Sendable, Equatable {
  public var appID: String
  public var ids: [String]
  public var versionStrings: [String]
  public var platforms: [String]
  public var appStoreStates: [String]
  public var appVersionStates: [String]
  public var limit: Int?

  public init(
    appID: String,
    ids: [String] = [],
    versionStrings: [String] = [],
    platforms: [String] = [],
    appStoreStates: [String] = [],
    appVersionStates: [String] = [],
    limit: Int? = nil
  ) {
    self.appID = appID
    self.ids = ids
    self.versionStrings = versionStrings
    self.platforms = platforms
    self.appStoreStates = appStoreStates
    self.appVersionStates = appVersionStates
    self.limit = limit
  }
}

public struct AppStoreConnectAppStoreVersionViewInput: Codable, Sendable, Equatable {
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectBetaAppLocalizationListInput: Codable, Sendable, Equatable {
  public var appIDs: [String]
  public var locales: [String]
  public var limit: Int?

  public init(appIDs: [String] = [], locales: [String] = [], limit: Int? = nil) {
    self.appIDs = appIDs
    self.locales = locales
    self.limit = limit
  }
}

public struct AppStoreConnectBetaAppLocalizationViewInput: Codable, Sendable, Equatable {
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectBetaBuildLocalizationListInput: Codable, Sendable, Equatable {
  public var buildIDs: [String]
  public var locales: [String]
  public var limit: Int?

  public init(buildIDs: [String] = [], locales: [String] = [], limit: Int? = nil) {
    self.buildIDs = buildIDs
    self.locales = locales
    self.limit = limit
  }
}

public struct AppStoreConnectBetaBuildLocalizationViewInput: Codable, Sendable, Equatable {
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectBetaAppReviewDetailListInput: Codable, Sendable, Equatable {
  public var appID: String
  public var limit: Int?

  public init(appID: String, limit: Int? = nil) {
    self.appID = appID
    self.limit = limit
  }
}

public struct AppStoreConnectBetaAppReviewDetailViewInput: Codable, Sendable, Equatable {
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectBetaAppReviewSubmissionListInput: Codable, Sendable, Equatable {
  public var buildIDs: [String]
  public var betaReviewStates: [String]
  public var limit: Int?

  public init(buildIDs: [String] = [], betaReviewStates: [String] = [], limit: Int? = nil) {
    self.buildIDs = buildIDs
    self.betaReviewStates = betaReviewStates
    self.limit = limit
  }
}

public struct AppStoreConnectBetaAppReviewSubmissionViewInput: Codable, Sendable, Equatable {
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectBetaLicenseAgreementListInput: Codable, Sendable, Equatable {
  public var appIDs: [String]
  public var limit: Int?

  public init(appIDs: [String] = [], limit: Int? = nil) {
    self.appIDs = appIDs
    self.limit = limit
  }
}

public struct AppStoreConnectBetaLicenseAgreementViewInput: Codable, Sendable, Equatable {
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectBetaFeedbackCrashSubmissionListInput: Codable, Sendable, Equatable {
  public var appID: String
  public var deviceModels: [String]
  public var osVersions: [String]
  public var appPlatforms: [String]
  public var devicePlatforms: [String]
  public var buildIDs: [String]
  public var preReleaseVersionIDs: [String]
  public var testerIDs: [String]
  public var sort: String?
  public var limit: Int?

  public init(
    appID: String,
    deviceModels: [String] = [],
    osVersions: [String] = [],
    appPlatforms: [String] = [],
    devicePlatforms: [String] = [],
    buildIDs: [String] = [],
    preReleaseVersionIDs: [String] = [],
    testerIDs: [String] = [],
    sort: String? = nil,
    limit: Int? = nil
  ) {
    self.appID = appID
    self.deviceModels = deviceModels
    self.osVersions = osVersions
    self.appPlatforms = appPlatforms
    self.devicePlatforms = devicePlatforms
    self.buildIDs = buildIDs
    self.preReleaseVersionIDs = preReleaseVersionIDs
    self.testerIDs = testerIDs
    self.sort = sort
    self.limit = limit
  }
}

public struct AppStoreConnectBetaFeedbackCrashSubmissionViewInput: Codable, Sendable, Equatable {
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectBetaFeedbackScreenshotSubmissionListInput: Codable, Sendable, Equatable
{
  public var appID: String
  public var deviceModels: [String]
  public var osVersions: [String]
  public var appPlatforms: [String]
  public var devicePlatforms: [String]
  public var buildIDs: [String]
  public var preReleaseVersionIDs: [String]
  public var testerIDs: [String]
  public var sort: String?
  public var limit: Int?

  public init(
    appID: String,
    deviceModels: [String] = [],
    osVersions: [String] = [],
    appPlatforms: [String] = [],
    devicePlatforms: [String] = [],
    buildIDs: [String] = [],
    preReleaseVersionIDs: [String] = [],
    testerIDs: [String] = [],
    sort: String? = nil,
    limit: Int? = nil
  ) {
    self.appID = appID
    self.deviceModels = deviceModels
    self.osVersions = osVersions
    self.appPlatforms = appPlatforms
    self.devicePlatforms = devicePlatforms
    self.buildIDs = buildIDs
    self.preReleaseVersionIDs = preReleaseVersionIDs
    self.testerIDs = testerIDs
    self.sort = sort
    self.limit = limit
  }
}

public struct AppStoreConnectBetaFeedbackScreenshotSubmissionViewInput: Codable, Sendable, Equatable
{
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectBetaCrashLogViewInput: Codable, Sendable, Equatable {
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectBetaFeedbackCrashSubmissionCrashLogInput: Codable, Sendable, Equatable
{
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectAppBetaTesterUsageMetricsInput: Codable, Sendable, Equatable {
  public var appID: String
  public var betaTesterID: String?
  public var period: String?
  public var groupByBetaTesters: Bool
  public var limit: Int?

  public init(
    appID: String,
    betaTesterID: String? = nil,
    period: String? = nil,
    groupByBetaTesters: Bool = false,
    limit: Int? = nil
  ) {
    self.appID = appID
    self.betaTesterID = betaTesterID
    self.period = period
    self.groupByBetaTesters = groupByBetaTesters
    self.limit = limit
  }
}

public struct AppStoreConnectBetaGroupBetaTesterUsageMetricsInput: Codable, Sendable, Equatable {
  public var groupID: String
  public var betaTesterID: String?
  public var period: String?
  public var groupByBetaTesters: Bool
  public var limit: Int?

  public init(
    groupID: String,
    betaTesterID: String? = nil,
    period: String? = nil,
    groupByBetaTesters: Bool = false,
    limit: Int? = nil
  ) {
    self.groupID = groupID
    self.betaTesterID = betaTesterID
    self.period = period
    self.groupByBetaTesters = groupByBetaTesters
    self.limit = limit
  }
}

public struct AppStoreConnectBetaTesterUsageMetricsInput: Codable, Sendable, Equatable {
  public var testerID: String
  public var appID: String
  public var period: String?
  public var limit: Int?

  public init(
    testerID: String,
    appID: String,
    period: String? = nil,
    limit: Int? = nil
  ) {
    self.testerID = testerID
    self.appID = appID
    self.period = period
    self.limit = limit
  }
}

public struct AppStoreConnectBetaGroupPublicLinkUsageMetricsInput: Codable, Sendable, Equatable {
  public var groupID: String
  public var limit: Int?

  public init(groupID: String, limit: Int? = nil) {
    self.groupID = groupID
    self.limit = limit
  }
}

public struct AppStoreConnectBetaBuildUsageMetricsInput: Codable, Sendable, Equatable {
  public var buildID: String
  public var limit: Int?

  public init(buildID: String, limit: Int? = nil) {
    self.buildID = buildID
    self.limit = limit
  }
}

public struct AppStoreConnectBetaGroupListInput: Codable, Sendable, Equatable {
  public var appID: String?
  public var ids: [String]
  public var names: [String]
  public var buildIDs: [String]
  public var isInternalGroup: String?
  public var publicLinkEnabled: String?
  public var publicLinkLimitEnabled: String?
  public var publicLink: String?
  public var sort: String?
  public var limit: Int?

  public init(
    appID: String? = nil,
    ids: [String] = [],
    names: [String] = [],
    buildIDs: [String] = [],
    isInternalGroup: String? = nil,
    publicLinkEnabled: String? = nil,
    publicLinkLimitEnabled: String? = nil,
    publicLink: String? = nil,
    sort: String? = nil,
    limit: Int? = nil
  ) {
    self.appID = appID
    self.ids = ids
    self.names = names
    self.buildIDs = buildIDs
    self.isInternalGroup = isInternalGroup
    self.publicLinkEnabled = publicLinkEnabled
    self.publicLinkLimitEnabled = publicLinkLimitEnabled
    self.publicLink = publicLink
    self.sort = sort
    self.limit = limit
  }
}

public struct AppStoreConnectBetaGroupViewInput: Codable, Sendable, Equatable {
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectBetaTesterListInput: Codable, Sendable, Equatable {
  public var ids: [String]
  public var appIDs: [String]
  public var betaGroupIDs: [String]
  public var buildIDs: [String]
  public var emails: [String]
  public var firstNames: [String]
  public var lastNames: [String]
  public var inviteTypes: [String]
  public var sort: String?
  public var limit: Int?

  public init(
    ids: [String] = [],
    appIDs: [String] = [],
    betaGroupIDs: [String] = [],
    buildIDs: [String] = [],
    emails: [String] = [],
    firstNames: [String] = [],
    lastNames: [String] = [],
    inviteTypes: [String] = [],
    sort: String? = nil,
    limit: Int? = nil
  ) {
    self.ids = ids
    self.appIDs = appIDs
    self.betaGroupIDs = betaGroupIDs
    self.buildIDs = buildIDs
    self.emails = emails
    self.firstNames = firstNames
    self.lastNames = lastNames
    self.inviteTypes = inviteTypes
    self.sort = sort
    self.limit = limit
  }
}

public struct AppStoreConnectBetaTesterViewInput: Codable, Sendable, Equatable {
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectBundleIDListInput: Codable, Sendable, Equatable {
  public var ids: [String]
  public var names: [String]
  public var identifiers: [String]
  public var seedIDs: [String]
  public var platforms: [String]
  public var sort: String?
  public var limit: Int?

  public init(
    ids: [String] = [],
    names: [String] = [],
    identifiers: [String] = [],
    seedIDs: [String] = [],
    platforms: [String] = [],
    sort: String? = nil,
    limit: Int? = nil
  ) {
    self.ids = ids
    self.names = names
    self.identifiers = identifiers
    self.seedIDs = seedIDs
    self.platforms = platforms
    self.sort = sort
    self.limit = limit
  }
}

public struct AppStoreConnectBundleIDViewInput: Codable, Sendable, Equatable {
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectBundleIDCapabilityListInput: Codable, Sendable, Equatable {
  public var bundleID: String
  public var fields: [String]
  public var limit: Int?

  public init(bundleID: String, fields: [String] = [], limit: Int? = nil) {
    self.bundleID = bundleID
    self.fields = fields
    self.limit = limit
  }
}

public struct AppStoreConnectCertificateListInput: Codable, Sendable, Equatable {
  public var ids: [String]
  public var displayNames: [String]
  public var certificateTypes: [String]
  public var serialNumbers: [String]
  public var sort: String?
  public var limit: Int?

  public init(
    ids: [String] = [],
    displayNames: [String] = [],
    certificateTypes: [String] = [],
    serialNumbers: [String] = [],
    sort: String? = nil,
    limit: Int? = nil
  ) {
    self.ids = ids
    self.displayNames = displayNames
    self.certificateTypes = certificateTypes
    self.serialNumbers = serialNumbers
    self.sort = sort
    self.limit = limit
  }
}

public struct AppStoreConnectCertificateViewInput: Codable, Sendable, Equatable {
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectCertificateDownloadInput: Codable, Sendable, Equatable {
  public var id: String
  public var outputPath: String?

  public init(id: String, outputPath: String? = nil) {
    self.id = id
    self.outputPath = outputPath
  }
}

public struct AppStoreConnectDeviceListInput: Codable, Sendable, Equatable {
  public var ids: [String]
  public var names: [String]
  public var platforms: [String]
  public var udids: [String]
  public var statuses: [String]
  public var sort: String?
  public var limit: Int?

  public init(
    ids: [String] = [],
    names: [String] = [],
    platforms: [String] = [],
    udids: [String] = [],
    statuses: [String] = [],
    sort: String? = nil,
    limit: Int? = nil
  ) {
    self.ids = ids
    self.names = names
    self.platforms = platforms
    self.udids = udids
    self.statuses = statuses
    self.sort = sort
    self.limit = limit
  }
}

public struct AppStoreConnectDeviceViewInput: Codable, Sendable, Equatable {
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectProfileListInput: Codable, Sendable, Equatable {
  public var ids: [String]
  public var names: [String]
  public var profileTypes: [String]
  public var profileStates: [String]
  public var sort: String?
  public var limit: Int?

  public init(
    ids: [String] = [],
    names: [String] = [],
    profileTypes: [String] = [],
    profileStates: [String] = [],
    sort: String? = nil,
    limit: Int? = nil
  ) {
    self.ids = ids
    self.names = names
    self.profileTypes = profileTypes
    self.profileStates = profileStates
    self.sort = sort
    self.limit = limit
  }
}

public struct AppStoreConnectProfileViewInput: Codable, Sendable, Equatable {
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectProfileDownloadInput: Codable, Sendable, Equatable {
  public var id: String
  public var outputPath: String?

  public init(id: String, outputPath: String? = nil) {
    self.id = id
    self.outputPath = outputPath
  }
}

public struct AppStoreConnectUserListInput: Codable, Sendable, Equatable {
  public var usernames: [String]
  public var roles: [String]
  public var visibleAppIDs: [String]
  public var sort: String?
  public var limit: Int?

  public init(
    usernames: [String] = [],
    roles: [String] = [],
    visibleAppIDs: [String] = [],
    sort: String? = nil,
    limit: Int? = nil
  ) {
    self.usernames = usernames
    self.roles = roles
    self.visibleAppIDs = visibleAppIDs
    self.sort = sort
    self.limit = limit
  }
}

public struct AppStoreConnectUserViewInput: Codable, Sendable, Equatable {
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectActorListInput: Codable, Sendable, Equatable {
  public var ids: [String]
  public var fields: [String]
  public var limit: Int?

  public init(
    ids: [String] = [],
    fields: [String] = [],
    limit: Int? = nil
  ) {
    self.ids = ids
    self.fields = fields
    self.limit = limit
  }
}

public struct AppStoreConnectActorViewInput: Codable, Sendable, Equatable {
  public var id: String
  public var fields: [String]

  public init(id: String, fields: [String] = []) {
    self.id = id
    self.fields = fields
  }
}

public struct AppStoreConnectUserInvitationListInput: Codable, Sendable, Equatable {
  public var emails: [String]
  public var roles: [String]
  public var visibleAppIDs: [String]
  public var sort: String?
  public var limit: Int?

  public init(
    emails: [String] = [],
    roles: [String] = [],
    visibleAppIDs: [String] = [],
    sort: String? = nil,
    limit: Int? = nil
  ) {
    self.emails = emails
    self.roles = roles
    self.visibleAppIDs = visibleAppIDs
    self.sort = sort
    self.limit = limit
  }
}

public struct AppStoreConnectUserInvitationViewInput: Codable, Sendable, Equatable {
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectBuildWaitInput: Codable, Sendable, Equatable {
  public var build: AppStoreConnectBuildInfoInput
  public var targetProcessingStates: [String]
  public var failureProcessingStates: [String]
  public var maxAttempts: Int
  public var intervalSeconds: Double

  public init(
    build: AppStoreConnectBuildInfoInput,
    targetProcessingStates: [String] = ["VALID"],
    failureProcessingStates: [String] = ["FAILED", "INVALID"],
    maxAttempts: Int = 60,
    intervalSeconds: Double = 30
  ) {
    self.build = build
    self.targetProcessingStates = targetProcessingStates
    self.failureProcessingStates = failureProcessingStates
    self.maxAttempts = maxAttempts
    self.intervalSeconds = intervalSeconds
  }
}

public struct AppStoreConnectStatusInput: Codable, Sendable, Equatable {
  public var appID: String
  public var appStoreVersionID: String?
  public var reviewSubmissionID: String?
  public var platforms: [String]
  public var reviewStates: [String]
  public var limit: Int?

  public init(
    appID: String,
    appStoreVersionID: String? = nil,
    reviewSubmissionID: String? = nil,
    platforms: [String] = [],
    reviewStates: [String] = [],
    limit: Int? = nil
  ) {
    self.appID = appID
    self.appStoreVersionID = appStoreVersionID
    self.reviewSubmissionID = reviewSubmissionID
    self.platforms = platforms
    self.reviewStates = reviewStates
    self.limit = limit
  }
}

public struct AppStoreConnectReviewSubmissionListInput: Codable, Sendable, Equatable {
  public var appID: String
  public var platforms: [String]
  public var states: [String]
  public var limit: Int?

  public init(
    appID: String,
    platforms: [String] = [],
    states: [String] = [],
    limit: Int? = nil
  ) {
    self.appID = appID
    self.platforms = platforms
    self.states = states
    self.limit = limit
  }
}

public struct AppStoreConnectReviewSubmissionViewInput: Codable, Sendable, Equatable {
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectCustomerReviewListInput: Codable, Sendable, Equatable {
  public var appID: String?
  public var appStoreVersionID: String?
  public var territories: [String]
  public var ratings: [String]
  public var responseExists: Bool?
  public var sort: [String]
  public var includeResponse: Bool
  public var limit: Int?

  public init(
    appID: String? = nil,
    appStoreVersionID: String? = nil,
    territories: [String] = [],
    ratings: [String] = [],
    responseExists: Bool? = nil,
    sort: [String] = [],
    includeResponse: Bool = false,
    limit: Int? = nil
  ) {
    self.appID = appID
    self.appStoreVersionID = appStoreVersionID
    self.territories = territories
    self.ratings = ratings
    self.responseExists = responseExists
    self.sort = sort
    self.includeResponse = includeResponse
    self.limit = limit
  }
}

public struct AppStoreConnectCustomerReviewViewInput: Codable, Sendable, Equatable {
  public var id: String
  public var includeResponse: Bool

  public init(id: String, includeResponse: Bool = false) {
    self.id = id
    self.includeResponse = includeResponse
  }
}

public struct AppStoreConnectCustomerReviewSummarizationListInput: Codable, Sendable, Equatable {
  public var appID: String
  public var platforms: [String]
  public var territories: [String]
  public var includeTerritory: Bool
  public var limit: Int?

  public init(
    appID: String,
    platforms: [String],
    territories: [String] = [],
    includeTerritory: Bool = false,
    limit: Int? = nil
  ) {
    self.appID = appID
    self.platforms = platforms
    self.territories = territories
    self.includeTerritory = includeTerritory
    self.limit = limit
  }
}

public struct AppStoreConnectCustomerReviewResponseViewInput: Codable, Sendable, Equatable {
  public var id: String

  public init(id: String) {
    self.id = id
  }
}

public struct AppStoreConnectCustomerReviewResponseForReviewInput: Codable, Sendable, Equatable {
  public var reviewID: String

  public init(reviewID: String) {
    self.reviewID = reviewID
  }
}

public struct AppStoreConnectAppSummary: Codable, Sendable, Equatable {
  public var id: String
  public var name: String?
  public var bundleID: String?
  public var sku: String?
  public var primaryLocale: String?
  public var contentRightsDeclaration: String?

  public init(
    id: String,
    name: String? = nil,
    bundleID: String? = nil,
    sku: String? = nil,
    primaryLocale: String? = nil,
    contentRightsDeclaration: String? = nil
  ) {
    self.id = id
    self.name = name
    self.bundleID = bundleID
    self.sku = sku
    self.primaryLocale = primaryLocale
    self.contentRightsDeclaration = contentRightsDeclaration
  }
}

public struct AppStoreConnectAppCategorySummary: Codable, Sendable, Equatable {
  public var id: String
  public var platforms: [String]
  public var parentID: String?
  public var subcategoryIDs: [String]

  public init(
    id: String,
    platforms: [String] = [],
    parentID: String? = nil,
    subcategoryIDs: [String] = []
  ) {
    self.id = id
    self.platforms = platforms
    self.parentID = parentID
    self.subcategoryIDs = subcategoryIDs
  }
}

public struct AppStoreConnectAgeRatingSummary: Codable, Sendable, Equatable {
  public var id: String
  public var frequencyRatings: [String: String]
  public var booleanRatings: [String: Bool]
  public var kidsAgeBand: String?
  public var ageRatingOverrideV2: String?
  public var koreaAgeRatingOverride: String?
  public var developerAgeRatingInfoURL: String?

  public init(
    id: String,
    frequencyRatings: [String: String] = [:],
    booleanRatings: [String: Bool] = [:],
    kidsAgeBand: String? = nil,
    ageRatingOverrideV2: String? = nil,
    koreaAgeRatingOverride: String? = nil,
    developerAgeRatingInfoURL: String? = nil
  ) {
    self.id = id
    self.frequencyRatings = frequencyRatings
    self.booleanRatings = booleanRatings
    self.kidsAgeBand = kidsAgeBand
    self.ageRatingOverrideV2 = ageRatingOverrideV2
    self.koreaAgeRatingOverride = koreaAgeRatingOverride
    self.developerAgeRatingInfoURL = developerAgeRatingInfoURL
  }
}

public struct AppStoreConnectAppEventSummary: Codable, Sendable, Equatable {
  public var id: String
  public var referenceName: String?
  public var eventState: String?
  public var badge: String?
  public var priority: String?
  public var purpose: String?
  public var primaryLocale: String?
  public var deepLink: String?
  public var purchaseRequirement: String?
  public var localizationIDs: [String]

  public init(
    id: String,
    referenceName: String? = nil,
    eventState: String? = nil,
    badge: String? = nil,
    priority: String? = nil,
    purpose: String? = nil,
    primaryLocale: String? = nil,
    deepLink: String? = nil,
    purchaseRequirement: String? = nil,
    localizationIDs: [String] = []
  ) {
    self.id = id
    self.referenceName = referenceName
    self.eventState = eventState
    self.badge = badge
    self.priority = priority
    self.purpose = purpose
    self.primaryLocale = primaryLocale
    self.deepLink = deepLink
    self.purchaseRequirement = purchaseRequirement
    self.localizationIDs = localizationIDs
  }
}

public struct AppStoreConnectCustomerReviewSummary: Codable, Sendable, Equatable {
  public var id: String
  public var rating: Int?
  public var title: String?
  public var body: String?
  public var reviewerNickname: String?
  public var createdDate: Date?
  public var territory: String?
  public var responseID: String?

  public init(
    id: String,
    rating: Int? = nil,
    title: String? = nil,
    body: String? = nil,
    reviewerNickname: String? = nil,
    createdDate: Date? = nil,
    territory: String? = nil,
    responseID: String? = nil
  ) {
    self.id = id
    self.rating = rating
    self.title = title
    self.body = body
    self.reviewerNickname = reviewerNickname
    self.createdDate = createdDate
    self.territory = territory
    self.responseID = responseID
  }
}

public struct AppStoreConnectCustomerReviewResponseSummary: Codable, Sendable, Equatable {
  public var id: String
  public var responseBody: String?
  public var state: String?
  public var lastModifiedDate: Date?
  public var reviewID: String?

  public init(
    id: String,
    responseBody: String? = nil,
    state: String? = nil,
    lastModifiedDate: Date? = nil,
    reviewID: String? = nil
  ) {
    self.id = id
    self.responseBody = responseBody
    self.state = state
    self.lastModifiedDate = lastModifiedDate
    self.reviewID = reviewID
  }
}

public struct AppStoreConnectCustomerReviewSummarizationSummary: Codable, Sendable, Equatable {
  public var id: String
  public var platform: String?
  public var locale: String?
  public var text: String?
  public var createdDate: Date?
  public var territoryID: String?

  public init(
    id: String,
    platform: String? = nil,
    locale: String? = nil,
    text: String? = nil,
    createdDate: Date? = nil,
    territoryID: String? = nil
  ) {
    self.id = id
    self.platform = platform
    self.locale = locale
    self.text = text
    self.createdDate = createdDate
    self.territoryID = territoryID
  }
}

#if ASC_PUBLIC_API_METADATA_MEDIA
  public struct AppStoreConnectAppClipSummary: Codable, Sendable, Equatable {
    public var id: String
    public var bundleID: String?
    public var appID: String?
    public var defaultExperienceIDs: [String]

    public init(
      id: String,
      bundleID: String? = nil,
      appID: String? = nil,
      defaultExperienceIDs: [String] = []
    ) {
      self.id = id
      self.bundleID = bundleID
      self.appID = appID
      self.defaultExperienceIDs = defaultExperienceIDs
    }
  }

  public struct AppStoreConnectAppClipDefaultExperienceSummary: Codable, Sendable, Equatable {
    public var id: String
    public var action: String?
    public var appClipID: String?
    public var releaseWithAppStoreVersionID: String?
    public var reviewDetailID: String?
    public var localizationIDs: [String]

    public init(
      id: String,
      action: String? = nil,
      appClipID: String? = nil,
      releaseWithAppStoreVersionID: String? = nil,
      reviewDetailID: String? = nil,
      localizationIDs: [String] = []
    ) {
      self.id = id
      self.action = action
      self.appClipID = appClipID
      self.releaseWithAppStoreVersionID = releaseWithAppStoreVersionID
      self.reviewDetailID = reviewDetailID
      self.localizationIDs = localizationIDs
    }
  }

  public struct AppStoreConnectAppClipLocalizationSummary: Codable, Sendable, Equatable {
    public var id: String
    public var locale: String?
    public var subtitle: String?
    public var defaultExperienceID: String?
    public var headerImageID: String?

    public init(
      id: String,
      locale: String? = nil,
      subtitle: String? = nil,
      defaultExperienceID: String? = nil,
      headerImageID: String? = nil
    ) {
      self.id = id
      self.locale = locale
      self.subtitle = subtitle
      self.defaultExperienceID = defaultExperienceID
      self.headerImageID = headerImageID
    }
  }
#endif

#if ASC_PUBLIC_API_GAME_CENTER
  public struct AppStoreConnectGameCenterDetailSummary: Codable, Sendable, Equatable {
    public var id: String
    public var arcadeEnabled: Bool?
    public var challengeEnabled: Bool?
    public var appID: String?
    public var achievementIDs: [String]
    public var leaderboardIDs: [String]
    public var leaderboardSetIDs: [String]
    public var challengeIDs: [String]

    public init(
      id: String,
      arcadeEnabled: Bool? = nil,
      challengeEnabled: Bool? = nil,
      appID: String? = nil,
      achievementIDs: [String] = [],
      leaderboardIDs: [String] = [],
      leaderboardSetIDs: [String] = [],
      challengeIDs: [String] = []
    ) {
      self.id = id
      self.arcadeEnabled = arcadeEnabled
      self.challengeEnabled = challengeEnabled
      self.appID = appID
      self.achievementIDs = achievementIDs
      self.leaderboardIDs = leaderboardIDs
      self.leaderboardSetIDs = leaderboardSetIDs
      self.challengeIDs = challengeIDs
    }
  }

  public struct AppStoreConnectGameCenterAchievementSummary: Codable, Sendable, Equatable {
    public var id: String
    public var referenceName: String?
    public var vendorIdentifier: String?
    public var points: Int?
    public var archived: Bool?
    public var repeatable: Bool?
    public var detailID: String?
    public var versionIDs: [String]

    public init(
      id: String,
      referenceName: String? = nil,
      vendorIdentifier: String? = nil,
      points: Int? = nil,
      archived: Bool? = nil,
      repeatable: Bool? = nil,
      detailID: String? = nil,
      versionIDs: [String] = []
    ) {
      self.id = id
      self.referenceName = referenceName
      self.vendorIdentifier = vendorIdentifier
      self.points = points
      self.archived = archived
      self.repeatable = repeatable
      self.detailID = detailID
      self.versionIDs = versionIDs
    }
  }

  public struct AppStoreConnectGameCenterLeaderboardSummary: Codable, Sendable, Equatable {
    public var id: String
    public var referenceName: String?
    public var vendorIdentifier: String?
    public var scoreSortType: String?
    public var defaultFormatter: String?
    public var submissionType: String?
    public var archived: Bool?
    public var detailID: String?
    public var leaderboardSetIDs: [String]
    public var versionIDs: [String]

    public init(
      id: String,
      referenceName: String? = nil,
      vendorIdentifier: String? = nil,
      scoreSortType: String? = nil,
      defaultFormatter: String? = nil,
      submissionType: String? = nil,
      archived: Bool? = nil,
      detailID: String? = nil,
      leaderboardSetIDs: [String] = [],
      versionIDs: [String] = []
    ) {
      self.id = id
      self.referenceName = referenceName
      self.vendorIdentifier = vendorIdentifier
      self.scoreSortType = scoreSortType
      self.defaultFormatter = defaultFormatter
      self.submissionType = submissionType
      self.archived = archived
      self.detailID = detailID
      self.leaderboardSetIDs = leaderboardSetIDs
      self.versionIDs = versionIDs
    }
  }

  public struct AppStoreConnectGameCenterLeaderboardSetSummary: Codable, Sendable, Equatable {
    public var id: String
    public var referenceName: String?
    public var vendorIdentifier: String?
    public var detailID: String?
    public var leaderboardIDs: [String]
    public var versionIDs: [String]

    public init(
      id: String,
      referenceName: String? = nil,
      vendorIdentifier: String? = nil,
      detailID: String? = nil,
      leaderboardIDs: [String] = [],
      versionIDs: [String] = []
    ) {
      self.id = id
      self.referenceName = referenceName
      self.vendorIdentifier = vendorIdentifier
      self.detailID = detailID
      self.leaderboardIDs = leaderboardIDs
      self.versionIDs = versionIDs
    }
  }

  public struct AppStoreConnectGameCenterChallengeSummary: Codable, Sendable, Equatable {
    public var id: String
    public var referenceName: String?
    public var vendorIdentifier: String?
    public var challengeType: String?
    public var archived: Bool?
    public var repeatable: Bool?
    public var detailID: String?
    public var leaderboardID: String?
    public var versionIDs: [String]

    public init(
      id: String,
      referenceName: String? = nil,
      vendorIdentifier: String? = nil,
      challengeType: String? = nil,
      archived: Bool? = nil,
      repeatable: Bool? = nil,
      detailID: String? = nil,
      leaderboardID: String? = nil,
      versionIDs: [String] = []
    ) {
      self.id = id
      self.referenceName = referenceName
      self.vendorIdentifier = vendorIdentifier
      self.challengeType = challengeType
      self.archived = archived
      self.repeatable = repeatable
      self.detailID = detailID
      self.leaderboardID = leaderboardID
      self.versionIDs = versionIDs
    }
  }
#endif

public struct AppStoreConnectEULASummary: Codable, Sendable, Equatable {
  public var id: String
  public var agreementText: String?
  public var appID: String?
  public var territoryIDs: [String]

  public init(
    id: String,
    agreementText: String? = nil,
    appID: String? = nil,
    territoryIDs: [String] = []
  ) {
    self.id = id
    self.agreementText = agreementText
    self.appID = appID
    self.territoryIDs = territoryIDs
  }
}

public struct AppStoreConnectTerritorySummary: Codable, Sendable, Equatable {
  public var id: String
  public var currency: String?

  public init(id: String, currency: String? = nil) {
    self.id = id
    self.currency = currency
  }
}

public struct AppStoreConnectAlternativeDistributionDomainSummary: Codable, Sendable, Equatable {
  public var id: String
  public var domain: String?
  public var referenceName: String?
  public var createdDate: Date?

  public init(
    id: String,
    domain: String? = nil,
    referenceName: String? = nil,
    createdDate: Date? = nil
  ) {
    self.id = id
    self.domain = domain
    self.referenceName = referenceName
    self.createdDate = createdDate
  }
}

public struct AppStoreConnectAlternativeDistributionKeySummary: Codable, Sendable, Equatable {
  public var id: String
  public var publicKey: String?

  public init(id: String, publicKey: String? = nil) {
    self.id = id
    self.publicKey = publicKey
  }
}

public struct AppStoreConnectMarketplaceWebhookSummary: Codable, Sendable, Equatable {
  public var id: String
  public var endpointURL: String?

  public init(id: String, endpointURL: String? = nil) {
    self.id = id
    self.endpointURL = endpointURL
  }
}

public struct AppStoreConnectWebhookSummary: Codable, Sendable, Equatable {
  public var id: String
  public var name: String?
  public var url: String?
  public var enabled: Bool?
  public var eventTypes: [String]
  public var appID: String?

  public init(
    id: String,
    name: String? = nil,
    url: String? = nil,
    enabled: Bool? = nil,
    eventTypes: [String] = [],
    appID: String? = nil
  ) {
    self.id = id
    self.name = name
    self.url = url
    self.enabled = enabled
    self.eventTypes = eventTypes
    self.appID = appID
  }
}

public struct AppStoreConnectWebhookDeliverySummary: Codable, Sendable, Equatable {
  public var id: String
  public var deliveryState: String?
  public var createdDate: Date?
  public var sentDate: Date?
  public var redelivery: Bool?
  public var errorMessage: String?
  public var requestURL: String?
  public var responseStatusCode: Int?
  public var eventID: String?

  public init(
    id: String,
    deliveryState: String? = nil,
    createdDate: Date? = nil,
    sentDate: Date? = nil,
    redelivery: Bool? = nil,
    errorMessage: String? = nil,
    requestURL: String? = nil,
    responseStatusCode: Int? = nil,
    eventID: String? = nil
  ) {
    self.id = id
    self.deliveryState = deliveryState
    self.createdDate = createdDate
    self.sentDate = sentDate
    self.redelivery = redelivery
    self.errorMessage = errorMessage
    self.requestURL = requestURL
    self.responseStatusCode = responseStatusCode
    self.eventID = eventID
  }
}

public struct AppStoreConnectWebhookDeliveryLinkageSummary: Codable, Sendable, Equatable {
  public var id: String
  public var type: String

  public init(id: String, type: String) {
    self.id = id
    self.type = type
  }
}

public struct AppStoreConnectBuildSummary: Codable, Sendable, Equatable {
  public var id: String
  public var version: String?
  public var processingState: String?
  public var uploadedDate: Date?
  public var expired: Bool?
  public var minOSVersion: String?
  public var appID: String?

  public init(
    id: String,
    version: String? = nil,
    processingState: String? = nil,
    uploadedDate: Date? = nil,
    expired: Bool? = nil,
    minOSVersion: String? = nil,
    appID: String? = nil
  ) {
    self.id = id
    self.version = version
    self.processingState = processingState
    self.uploadedDate = uploadedDate
    self.expired = expired
    self.minOSVersion = minOSVersion
    self.appID = appID
  }
}

public struct AppStoreConnectBuildBetaDetailSummary: Codable, Sendable, Equatable {
  public var id: String
  public var autoNotifyEnabled: Bool?
  public var internalBuildState: String?
  public var externalBuildState: String?
  public var buildID: String?

  public init(
    id: String,
    autoNotifyEnabled: Bool? = nil,
    internalBuildState: String? = nil,
    externalBuildState: String? = nil,
    buildID: String? = nil
  ) {
    self.id = id
    self.autoNotifyEnabled = autoNotifyEnabled
    self.internalBuildState = internalBuildState
    self.externalBuildState = externalBuildState
    self.buildID = buildID
  }
}

public struct AppStoreConnectPreReleaseVersionSummary: Codable, Sendable, Equatable {
  public var id: String
  public var version: String?
  public var platform: String?
  public var appID: String?
  public var buildIDs: [String]

  public init(
    id: String,
    version: String? = nil,
    platform: String? = nil,
    appID: String? = nil,
    buildIDs: [String] = []
  ) {
    self.id = id
    self.version = version
    self.platform = platform
    self.appID = appID
    self.buildIDs = buildIDs
  }
}

public struct AppStoreConnectAppStoreVersionSummary: Codable, Sendable, Equatable {
  public var id: String
  public var versionString: String?
  public var platform: String?
  public var appStoreState: String?
  public var appVersionState: String?
  public var releaseType: String?
  public var earliestReleaseDate: Date?

  public init(
    id: String,
    versionString: String? = nil,
    platform: String? = nil,
    appStoreState: String? = nil,
    appVersionState: String? = nil,
    releaseType: String? = nil,
    earliestReleaseDate: Date? = nil
  ) {
    self.id = id
    self.versionString = versionString
    self.platform = platform
    self.appStoreState = appStoreState
    self.appVersionState = appVersionState
    self.releaseType = releaseType
    self.earliestReleaseDate = earliestReleaseDate
  }
}

public struct AppStoreConnectReviewSubmissionSummary: Codable, Sendable, Equatable {
  public var id: String
  public var platform: String?
  public var state: String?
  public var submittedDate: Date?
  public var appID: String?
  public var appStoreVersionID: String?

  public init(
    id: String,
    platform: String? = nil,
    state: String? = nil,
    submittedDate: Date? = nil,
    appID: String? = nil,
    appStoreVersionID: String? = nil
  ) {
    self.id = id
    self.platform = platform
    self.state = state
    self.submittedDate = submittedDate
    self.appID = appID
    self.appStoreVersionID = appStoreVersionID
  }
}

public struct AppStoreConnectBetaAppLocalizationSummary: Codable, Sendable, Equatable {
  public var id: String
  public var locale: String?
  public var description: String?
  public var feedbackEmail: String?
  public var marketingURL: String?
  public var privacyPolicyURL: String?
  public var tvOSPrivacyPolicy: String?
  public var appID: String?

  public init(
    id: String,
    locale: String? = nil,
    description: String? = nil,
    feedbackEmail: String? = nil,
    marketingURL: String? = nil,
    privacyPolicyURL: String? = nil,
    tvOSPrivacyPolicy: String? = nil,
    appID: String? = nil
  ) {
    self.id = id
    self.locale = locale
    self.description = description
    self.feedbackEmail = feedbackEmail
    self.marketingURL = marketingURL
    self.privacyPolicyURL = privacyPolicyURL
    self.tvOSPrivacyPolicy = tvOSPrivacyPolicy
    self.appID = appID
  }
}

public struct AppStoreConnectBetaBuildLocalizationSummary: Codable, Sendable, Equatable {
  public var id: String
  public var locale: String?
  public var whatsNew: String?
  public var buildID: String?

  public init(id: String, locale: String? = nil, whatsNew: String? = nil, buildID: String? = nil) {
    self.id = id
    self.locale = locale
    self.whatsNew = whatsNew
    self.buildID = buildID
  }
}

public struct AppStoreConnectBetaAppReviewDetailSummary: Codable, Sendable, Equatable {
  public var id: String
  public var contactEmail: String?
  public var contactFirstName: String?
  public var contactLastName: String?
  public var contactPhone: String?
  public var demoAccountName: String?
  public var demoAccountRequired: Bool?
  public var notes: String?
  public var appID: String?

  public init(
    id: String,
    contactEmail: String? = nil,
    contactFirstName: String? = nil,
    contactLastName: String? = nil,
    contactPhone: String? = nil,
    demoAccountName: String? = nil,
    demoAccountRequired: Bool? = nil,
    notes: String? = nil,
    appID: String? = nil
  ) {
    self.id = id
    self.contactEmail = contactEmail
    self.contactFirstName = contactFirstName
    self.contactLastName = contactLastName
    self.contactPhone = contactPhone
    self.demoAccountName = demoAccountName
    self.demoAccountRequired = demoAccountRequired
    self.notes = notes
    self.appID = appID
  }
}

public struct AppStoreConnectBetaAppReviewSubmissionSummary: Codable, Sendable, Equatable {
  public var id: String
  public var betaReviewState: String?
  public var submittedDate: Date?
  public var buildID: String?

  public init(
    id: String,
    betaReviewState: String? = nil,
    submittedDate: Date? = nil,
    buildID: String? = nil
  ) {
    self.id = id
    self.betaReviewState = betaReviewState
    self.submittedDate = submittedDate
    self.buildID = buildID
  }
}

public struct AppStoreConnectBetaLicenseAgreementSummary: Codable, Sendable, Equatable {
  public var id: String
  public var agreementText: String?
  public var appID: String?

  public init(id: String, agreementText: String? = nil, appID: String? = nil) {
    self.id = id
    self.agreementText = agreementText
    self.appID = appID
  }
}

public struct AppStoreConnectBetaFeedbackCrashSubmissionSummary: Codable, Sendable, Equatable {
  public var id: String
  public var createdDate: Date?
  public var comment: String?
  public var email: String?
  public var deviceModel: String?
  public var osVersion: String?
  public var locale: String?
  public var appPlatform: String?
  public var devicePlatform: String?
  public var deviceFamily: String?
  public var connectionType: String?
  public var buildBundleID: String?
  public var buildID: String?
  public var testerID: String?

  public init(
    id: String,
    createdDate: Date? = nil,
    comment: String? = nil,
    email: String? = nil,
    deviceModel: String? = nil,
    osVersion: String? = nil,
    locale: String? = nil,
    appPlatform: String? = nil,
    devicePlatform: String? = nil,
    deviceFamily: String? = nil,
    connectionType: String? = nil,
    buildBundleID: String? = nil,
    buildID: String? = nil,
    testerID: String? = nil
  ) {
    self.id = id
    self.createdDate = createdDate
    self.comment = comment
    self.email = email
    self.deviceModel = deviceModel
    self.osVersion = osVersion
    self.locale = locale
    self.appPlatform = appPlatform
    self.devicePlatform = devicePlatform
    self.deviceFamily = deviceFamily
    self.connectionType = connectionType
    self.buildBundleID = buildBundleID
    self.buildID = buildID
    self.testerID = testerID
  }
}

public struct AppStoreConnectBetaFeedbackScreenshotSubmissionSummary: Codable, Sendable, Equatable {
  public var id: String
  public var createdDate: Date?
  public var comment: String?
  public var email: String?
  public var deviceModel: String?
  public var osVersion: String?
  public var locale: String?
  public var appPlatform: String?
  public var devicePlatform: String?
  public var deviceFamily: String?
  public var connectionType: String?
  public var buildBundleID: String?
  public var screenshotCount: Int
  public var buildID: String?
  public var testerID: String?

  public init(
    id: String,
    createdDate: Date? = nil,
    comment: String? = nil,
    email: String? = nil,
    deviceModel: String? = nil,
    osVersion: String? = nil,
    locale: String? = nil,
    appPlatform: String? = nil,
    devicePlatform: String? = nil,
    deviceFamily: String? = nil,
    connectionType: String? = nil,
    buildBundleID: String? = nil,
    screenshotCount: Int = 0,
    buildID: String? = nil,
    testerID: String? = nil
  ) {
    self.id = id
    self.createdDate = createdDate
    self.comment = comment
    self.email = email
    self.deviceModel = deviceModel
    self.osVersion = osVersion
    self.locale = locale
    self.appPlatform = appPlatform
    self.devicePlatform = devicePlatform
    self.deviceFamily = deviceFamily
    self.connectionType = connectionType
    self.buildBundleID = buildBundleID
    self.screenshotCount = screenshotCount
    self.buildID = buildID
    self.testerID = testerID
  }
}

public struct AppStoreConnectBetaCrashLogSummary: Codable, Sendable, Equatable {
  public var id: String
  public var logText: String?

  public init(id: String, logText: String? = nil) {
    self.id = id
    self.logText = logText
  }
}

public struct AppStoreConnectBetaTesterUsageMetricPoint: Codable, Sendable, Equatable {
  public var start: Date?
  public var end: Date?
  public var crashCount: Int?
  public var feedbackCount: Int?
  public var sessionCount: Int?

  public init(
    start: Date? = nil,
    end: Date? = nil,
    crashCount: Int? = nil,
    feedbackCount: Int? = nil,
    sessionCount: Int? = nil
  ) {
    self.start = start
    self.end = end
    self.crashCount = crashCount
    self.feedbackCount = feedbackCount
    self.sessionCount = sessionCount
  }
}

public struct AppStoreConnectBetaTesterUsageMetricSeries: Codable, Sendable, Equatable {
  public var scope: String
  public var appID: String?
  public var groupID: String?
  public var testerID: String?
  public var dataPoints: [AppStoreConnectBetaTesterUsageMetricPoint]

  public init(
    scope: String,
    appID: String? = nil,
    groupID: String? = nil,
    testerID: String? = nil,
    dataPoints: [AppStoreConnectBetaTesterUsageMetricPoint] = []
  ) {
    self.scope = scope
    self.appID = appID
    self.groupID = groupID
    self.testerID = testerID
    self.dataPoints = dataPoints
  }
}

public struct AppStoreConnectBetaBuildUsageMetricPoint: Codable, Sendable, Equatable {
  public var start: Date?
  public var end: Date?
  public var crashCount: Int?
  public var feedbackCount: Int?
  public var installCount: Int?
  public var inviteCount: Int?
  public var sessionCount: Int?

  public init(
    start: Date? = nil,
    end: Date? = nil,
    crashCount: Int? = nil,
    feedbackCount: Int? = nil,
    installCount: Int? = nil,
    inviteCount: Int? = nil,
    sessionCount: Int? = nil
  ) {
    self.start = start
    self.end = end
    self.crashCount = crashCount
    self.feedbackCount = feedbackCount
    self.installCount = installCount
    self.inviteCount = inviteCount
    self.sessionCount = sessionCount
  }
}

public struct AppStoreConnectBetaBuildUsageMetricSeries: Codable, Sendable, Equatable {
  public var buildID: String
  public var dataPoints: [AppStoreConnectBetaBuildUsageMetricPoint]

  public init(buildID: String, dataPoints: [AppStoreConnectBetaBuildUsageMetricPoint] = []) {
    self.buildID = buildID
    self.dataPoints = dataPoints
  }
}

public struct AppStoreConnectBetaPublicLinkUsageMetricPoint: Codable, Sendable, Equatable {
  public var start: Date?
  public var end: Date?
  public var acceptedCount: Int?
  public var didNotAcceptCount: Int?
  public var didNotMeetCriteriaCount: Int?
  public var notClearRatio: Double?
  public var notInterestingRatio: Double?
  public var notRelevantRatio: Double?
  public var viewCount: Int?

  public init(
    start: Date? = nil,
    end: Date? = nil,
    acceptedCount: Int? = nil,
    didNotAcceptCount: Int? = nil,
    didNotMeetCriteriaCount: Int? = nil,
    notClearRatio: Double? = nil,
    notInterestingRatio: Double? = nil,
    notRelevantRatio: Double? = nil,
    viewCount: Int? = nil
  ) {
    self.start = start
    self.end = end
    self.acceptedCount = acceptedCount
    self.didNotAcceptCount = didNotAcceptCount
    self.didNotMeetCriteriaCount = didNotMeetCriteriaCount
    self.notClearRatio = notClearRatio
    self.notInterestingRatio = notInterestingRatio
    self.notRelevantRatio = notRelevantRatio
    self.viewCount = viewCount
  }
}

public struct AppStoreConnectBetaPublicLinkUsageMetricSeries: Codable, Sendable, Equatable {
  public var groupID: String
  public var dataPoints: [AppStoreConnectBetaPublicLinkUsageMetricPoint]

  public init(groupID: String, dataPoints: [AppStoreConnectBetaPublicLinkUsageMetricPoint] = []) {
    self.groupID = groupID
    self.dataPoints = dataPoints
  }
}

public struct AppStoreConnectBetaGroupSummary: Codable, Sendable, Equatable {
  public var id: String
  public var name: String?
  public var isInternalGroup: Bool?
  public var publicLinkEnabled: Bool?
  public var publicLinkLimit: Int?
  public var feedbackEnabled: Bool?
  public var appID: String?

  public init(
    id: String,
    name: String? = nil,
    isInternalGroup: Bool? = nil,
    publicLinkEnabled: Bool? = nil,
    publicLinkLimit: Int? = nil,
    feedbackEnabled: Bool? = nil,
    appID: String? = nil
  ) {
    self.id = id
    self.name = name
    self.isInternalGroup = isInternalGroup
    self.publicLinkEnabled = publicLinkEnabled
    self.publicLinkLimit = publicLinkLimit
    self.feedbackEnabled = feedbackEnabled
    self.appID = appID
  }
}

public struct AppStoreConnectBetaTesterSummary: Codable, Sendable, Equatable {
  public var id: String
  public var email: String?
  public var firstName: String?
  public var lastName: String?
  public var state: String?
  public var inviteType: String?
  public var appIDs: [String]
  public var betaGroupIDs: [String]

  public init(
    id: String,
    email: String? = nil,
    firstName: String? = nil,
    lastName: String? = nil,
    state: String? = nil,
    inviteType: String? = nil,
    appIDs: [String] = [],
    betaGroupIDs: [String] = []
  ) {
    self.id = id
    self.email = email
    self.firstName = firstName
    self.lastName = lastName
    self.state = state
    self.inviteType = inviteType
    self.appIDs = appIDs
    self.betaGroupIDs = betaGroupIDs
  }
}

public struct AppStoreConnectBundleIDSummary: Codable, Sendable, Equatable {
  public var id: String
  public var identifier: String?
  public var name: String?
  public var platform: String?
  public var seedID: String?
  public var appID: String?
  public var profileIDs: [String]

  public init(
    id: String,
    identifier: String? = nil,
    name: String? = nil,
    platform: String? = nil,
    seedID: String? = nil,
    appID: String? = nil,
    profileIDs: [String] = []
  ) {
    self.id = id
    self.identifier = identifier
    self.name = name
    self.platform = platform
    self.seedID = seedID
    self.appID = appID
    self.profileIDs = profileIDs
  }
}

public struct AppStoreConnectBundleIDCapabilitySummary: Codable, Sendable, Equatable {
  public var id: String
  public var capabilityType: String?
  public var settingKeys: [String]
  public var settingCount: Int

  public init(
    id: String,
    capabilityType: String? = nil,
    settingKeys: [String] = [],
    settingCount: Int = 0
  ) {
    self.id = id
    self.capabilityType = capabilityType
    self.settingKeys = settingKeys
    self.settingCount = settingCount
  }
}

public struct AppStoreConnectCertificateSummary: Codable, Sendable, Equatable {
  public var id: String
  public var name: String?
  public var displayName: String?
  public var certificateType: String?
  public var serialNumber: String?
  public var platform: String?
  public var expirationDate: Date?
  public var activated: Bool?

  public init(
    id: String,
    name: String? = nil,
    displayName: String? = nil,
    certificateType: String? = nil,
    serialNumber: String? = nil,
    platform: String? = nil,
    expirationDate: Date? = nil,
    activated: Bool? = nil
  ) {
    self.id = id
    self.name = name
    self.displayName = displayName
    self.certificateType = certificateType
    self.serialNumber = serialNumber
    self.platform = platform
    self.expirationDate = expirationDate
    self.activated = activated
  }
}

public struct AppStoreConnectCertificateDownloadSummary: Codable, Sendable, Equatable {
  public var id: String
  public var name: String?
  public var displayName: String?
  public var certificateType: String?
  public var serialNumber: String?
  public var outputPath: String
  public var byteCount: Int
  public var operationID: String

  public init(
    id: String,
    name: String? = nil,
    displayName: String? = nil,
    certificateType: String? = nil,
    serialNumber: String? = nil,
    outputPath: String,
    byteCount: Int,
    operationID: String
  ) {
    self.id = id
    self.name = name
    self.displayName = displayName
    self.certificateType = certificateType
    self.serialNumber = serialNumber
    self.outputPath = outputPath
    self.byteCount = byteCount
    self.operationID = operationID
  }
}

public struct AppStoreConnectDeviceSummary: Codable, Sendable, Equatable {
  public var id: String
  public var name: String?
  public var udid: String?
  public var platform: String?
  public var status: String?
  public var deviceClass: String?
  public var model: String?
  public var addedDate: Date?

  public init(
    id: String,
    name: String? = nil,
    udid: String? = nil,
    platform: String? = nil,
    status: String? = nil,
    deviceClass: String? = nil,
    model: String? = nil,
    addedDate: Date? = nil
  ) {
    self.id = id
    self.name = name
    self.udid = udid
    self.platform = platform
    self.status = status
    self.deviceClass = deviceClass
    self.model = model
    self.addedDate = addedDate
  }
}

public struct AppStoreConnectProfileSummary: Codable, Sendable, Equatable {
  public var id: String
  public var name: String?
  public var platform: String?
  public var profileType: String?
  public var profileState: String?
  public var uuid: String?
  public var createdDate: Date?
  public var expirationDate: Date?
  public var bundleID: String?
  public var certificateIDs: [String]
  public var deviceIDs: [String]

  public init(
    id: String,
    name: String? = nil,
    platform: String? = nil,
    profileType: String? = nil,
    profileState: String? = nil,
    uuid: String? = nil,
    createdDate: Date? = nil,
    expirationDate: Date? = nil,
    bundleID: String? = nil,
    certificateIDs: [String] = [],
    deviceIDs: [String] = []
  ) {
    self.id = id
    self.name = name
    self.platform = platform
    self.profileType = profileType
    self.profileState = profileState
    self.uuid = uuid
    self.createdDate = createdDate
    self.expirationDate = expirationDate
    self.bundleID = bundleID
    self.certificateIDs = certificateIDs
    self.deviceIDs = deviceIDs
  }
}

public struct AppStoreConnectProfileDownloadSummary: Codable, Sendable, Equatable {
  public var id: String
  public var name: String?
  public var uuid: String?
  public var profileType: String?
  public var outputPath: String
  public var byteCount: Int
  public var operationID: String

  public init(
    id: String,
    name: String? = nil,
    uuid: String? = nil,
    profileType: String? = nil,
    outputPath: String,
    byteCount: Int,
    operationID: String
  ) {
    self.id = id
    self.name = name
    self.uuid = uuid
    self.profileType = profileType
    self.outputPath = outputPath
    self.byteCount = byteCount
    self.operationID = operationID
  }
}

public struct AppStoreConnectUserSummary: Codable, Sendable, Equatable {
  public var id: String
  public var username: String?
  public var firstName: String?
  public var lastName: String?
  public var roles: [String]
  public var allAppsVisible: Bool?
  public var provisioningAllowed: Bool?
  public var visibleAppIDs: [String]

  public init(
    id: String,
    username: String? = nil,
    firstName: String? = nil,
    lastName: String? = nil,
    roles: [String] = [],
    allAppsVisible: Bool? = nil,
    provisioningAllowed: Bool? = nil,
    visibleAppIDs: [String] = []
  ) {
    self.id = id
    self.username = username
    self.firstName = firstName
    self.lastName = lastName
    self.roles = roles
    self.allAppsVisible = allAppsVisible
    self.provisioningAllowed = provisioningAllowed
    self.visibleAppIDs = visibleAppIDs
  }
}

public struct AppStoreConnectActorSummary: Codable, Sendable, Equatable {
  public var id: String
  public var actorType: String?
  public var apiKeyID: String?
  public var userEmail: String?
  public var userFirstName: String?
  public var userLastName: String?

  public init(
    id: String,
    actorType: String? = nil,
    apiKeyID: String? = nil,
    userEmail: String? = nil,
    userFirstName: String? = nil,
    userLastName: String? = nil
  ) {
    self.id = id
    self.actorType = actorType
    self.apiKeyID = apiKeyID
    self.userEmail = userEmail
    self.userFirstName = userFirstName
    self.userLastName = userLastName
  }
}

public struct AppStoreConnectUserInvitationSummary: Codable, Sendable, Equatable {
  public var id: String
  public var email: String?
  public var firstName: String?
  public var lastName: String?
  public var roles: [String]
  public var allAppsVisible: Bool?
  public var provisioningAllowed: Bool?
  public var expirationDate: Date?
  public var visibleAppIDs: [String]

  public init(
    id: String,
    email: String? = nil,
    firstName: String? = nil,
    lastName: String? = nil,
    roles: [String] = [],
    allAppsVisible: Bool? = nil,
    provisioningAllowed: Bool? = nil,
    expirationDate: Date? = nil,
    visibleAppIDs: [String] = []
  ) {
    self.id = id
    self.email = email
    self.firstName = firstName
    self.lastName = lastName
    self.roles = roles
    self.allAppsVisible = allAppsVisible
    self.provisioningAllowed = provisioningAllowed
    self.expirationDate = expirationDate
    self.visibleAppIDs = visibleAppIDs
  }
}

public struct AppStoreConnectListResult<Resource: Codable & Sendable & Equatable>: Codable,
  Sendable, Equatable
{
  public var data: [Resource]
  public var count: Int
  public var next: String?

  public init(data: [Resource], next: String? = nil) {
    self.data = data
    self.count = data.count
    self.next = next
  }
}

public struct AppStoreConnectResourceResult<Resource: Codable & Sendable & Equatable>: Codable,
  Sendable, Equatable
{
  public var data: Resource

  public init(data: Resource) {
    self.data = data
  }
}

public enum AppStoreConnectBuildWaitStatus: String, Codable, Sendable, Equatable {
  case succeeded
  case failed
  case timedOut
}

public struct AppStoreConnectBuildWaitAttempt: Codable, Sendable, Equatable {
  public var attempt: Int
  public var build: AppStoreConnectBuildSummary

  public init(attempt: Int, build: AppStoreConnectBuildSummary) {
    self.attempt = attempt
    self.build = build
  }
}

public struct AppStoreConnectBuildWaitResult: Codable, Sendable, Equatable {
  public var status: AppStoreConnectBuildWaitStatus
  public var build: AppStoreConnectBuildSummary
  public var attempts: [AppStoreConnectBuildWaitAttempt]
  public var targetProcessingStates: [String]
  public var failureProcessingStates: [String]

  public init(
    status: AppStoreConnectBuildWaitStatus,
    build: AppStoreConnectBuildSummary,
    attempts: [AppStoreConnectBuildWaitAttempt],
    targetProcessingStates: [String],
    failureProcessingStates: [String]
  ) {
    self.status = status
    self.build = build
    self.attempts = attempts
    self.targetProcessingStates = targetProcessingStates
    self.failureProcessingStates = failureProcessingStates
  }
}

public struct AppStoreConnectStatusResult: Codable, Sendable, Equatable {
  public var app: AppStoreConnectAppSummary
  public var appStoreVersion: AppStoreConnectAppStoreVersionSummary?
  public var reviewSubmissions: [AppStoreConnectReviewSubmissionSummary]

  public init(
    app: AppStoreConnectAppSummary,
    appStoreVersion: AppStoreConnectAppStoreVersionSummary? = nil,
    reviewSubmissions: [AppStoreConnectReviewSubmissionSummary] = []
  ) {
    self.app = app
    self.appStoreVersion = appStoreVersion
    self.reviewSubmissions = reviewSubmissions
  }
}

public typealias AppStoreConnectAppListResult = AppStoreConnectListResult<AppStoreConnectAppSummary>
public typealias AppStoreConnectAppResult = AppStoreConnectResourceResult<AppStoreConnectAppSummary>
public typealias AppStoreConnectAppCategoryListResult = AppStoreConnectListResult<
  AppStoreConnectAppCategorySummary
>
public typealias AppStoreConnectAppCategoryResult = AppStoreConnectResourceResult<
  AppStoreConnectAppCategorySummary
>
public typealias AppStoreConnectAgeRatingResult = AppStoreConnectResourceResult<
  AppStoreConnectAgeRatingSummary
>
public typealias AppStoreConnectAppEventListResult = AppStoreConnectListResult<
  AppStoreConnectAppEventSummary
>
public typealias AppStoreConnectAppEventResult = AppStoreConnectResourceResult<
  AppStoreConnectAppEventSummary
>
public typealias AppStoreConnectCustomerReviewListResult = AppStoreConnectListResult<
  AppStoreConnectCustomerReviewSummary
>
public typealias AppStoreConnectCustomerReviewResult = AppStoreConnectResourceResult<
  AppStoreConnectCustomerReviewSummary
>
public typealias AppStoreConnectCustomerReviewResponseResult = AppStoreConnectResourceResult<
  AppStoreConnectCustomerReviewResponseSummary
>
public typealias AppStoreConnectCustomerReviewSummarizationListResult = AppStoreConnectListResult<
  AppStoreConnectCustomerReviewSummarizationSummary
>
#if ASC_PUBLIC_API_METADATA_MEDIA
  public typealias AppStoreConnectAppClipListResult = AppStoreConnectListResult<
    AppStoreConnectAppClipSummary
  >
  public typealias AppStoreConnectAppClipResult = AppStoreConnectResourceResult<
    AppStoreConnectAppClipSummary
  >
  public typealias AppStoreConnectAppClipDefaultExperienceListResult = AppStoreConnectListResult<
    AppStoreConnectAppClipDefaultExperienceSummary
  >
  public typealias AppStoreConnectAppClipDefaultExperienceResult = AppStoreConnectResourceResult<
    AppStoreConnectAppClipDefaultExperienceSummary
  >
  public typealias AppStoreConnectAppClipLocalizationListResult = AppStoreConnectListResult<
    AppStoreConnectAppClipLocalizationSummary
  >
  public typealias AppStoreConnectAppClipLocalizationResult = AppStoreConnectResourceResult<
    AppStoreConnectAppClipLocalizationSummary
  >
#endif
#if ASC_PUBLIC_API_GAME_CENTER
  public typealias AppStoreConnectGameCenterDetailResult = AppStoreConnectResourceResult<
    AppStoreConnectGameCenterDetailSummary
  >
  public typealias AppStoreConnectGameCenterAchievementListResult = AppStoreConnectListResult<
    AppStoreConnectGameCenterAchievementSummary
  >
  public typealias AppStoreConnectGameCenterAchievementResult = AppStoreConnectResourceResult<
    AppStoreConnectGameCenterAchievementSummary
  >
  public typealias AppStoreConnectGameCenterLeaderboardListResult = AppStoreConnectListResult<
    AppStoreConnectGameCenterLeaderboardSummary
  >
  public typealias AppStoreConnectGameCenterLeaderboardResult = AppStoreConnectResourceResult<
    AppStoreConnectGameCenterLeaderboardSummary
  >
  public typealias AppStoreConnectGameCenterLeaderboardSetListResult = AppStoreConnectListResult<
    AppStoreConnectGameCenterLeaderboardSetSummary
  >
  public typealias AppStoreConnectGameCenterLeaderboardSetResult = AppStoreConnectResourceResult<
    AppStoreConnectGameCenterLeaderboardSetSummary
  >
  public typealias AppStoreConnectGameCenterChallengeListResult = AppStoreConnectListResult<
    AppStoreConnectGameCenterChallengeSummary
  >
  public typealias AppStoreConnectGameCenterChallengeResult = AppStoreConnectResourceResult<
    AppStoreConnectGameCenterChallengeSummary
  >
#endif
public typealias AppStoreConnectEULAResult = AppStoreConnectResourceResult<
  AppStoreConnectEULASummary
>
public typealias AppStoreConnectTerritoryListResult = AppStoreConnectListResult<
  AppStoreConnectTerritorySummary
>
public typealias AppStoreConnectAlternativeDistributionDomainListResult = AppStoreConnectListResult<
  AppStoreConnectAlternativeDistributionDomainSummary
>
public typealias AppStoreConnectAlternativeDistributionDomainResult = AppStoreConnectResourceResult<
  AppStoreConnectAlternativeDistributionDomainSummary
>
public typealias AppStoreConnectAlternativeDistributionKeyListResult = AppStoreConnectListResult<
  AppStoreConnectAlternativeDistributionKeySummary
>
public typealias AppStoreConnectAlternativeDistributionKeyResult = AppStoreConnectResourceResult<
  AppStoreConnectAlternativeDistributionKeySummary
>
public typealias AppStoreConnectMarketplaceWebhookListResult = AppStoreConnectListResult<
  AppStoreConnectMarketplaceWebhookSummary
>
public typealias AppStoreConnectWebhookListResult = AppStoreConnectListResult<
  AppStoreConnectWebhookSummary
>
public typealias AppStoreConnectWebhookResult = AppStoreConnectResourceResult<
  AppStoreConnectWebhookSummary
>
public typealias AppStoreConnectWebhookDeliveryListResult = AppStoreConnectListResult<
  AppStoreConnectWebhookDeliverySummary
>
public typealias AppStoreConnectWebhookDeliveryLinkageListResult = AppStoreConnectListResult<
  AppStoreConnectWebhookDeliveryLinkageSummary
>
public typealias AppStoreConnectBuildListResult = AppStoreConnectListResult<
  AppStoreConnectBuildSummary
>
public typealias AppStoreConnectBuildResult = AppStoreConnectResourceResult<
  AppStoreConnectBuildSummary
>
public typealias AppStoreConnectBuildBetaDetailListResult = AppStoreConnectListResult<
  AppStoreConnectBuildBetaDetailSummary
>
public typealias AppStoreConnectBuildBetaDetailResult = AppStoreConnectResourceResult<
  AppStoreConnectBuildBetaDetailSummary
>
public typealias AppStoreConnectPreReleaseVersionListResult = AppStoreConnectListResult<
  AppStoreConnectPreReleaseVersionSummary
>
public typealias AppStoreConnectPreReleaseVersionResult = AppStoreConnectResourceResult<
  AppStoreConnectPreReleaseVersionSummary
>
public typealias AppStoreConnectAppStoreVersionListResult = AppStoreConnectListResult<
  AppStoreConnectAppStoreVersionSummary
>
public typealias AppStoreConnectAppStoreVersionResult = AppStoreConnectResourceResult<
  AppStoreConnectAppStoreVersionSummary
>
public typealias AppStoreConnectReviewSubmissionListResult = AppStoreConnectListResult<
  AppStoreConnectReviewSubmissionSummary
>
public typealias AppStoreConnectReviewSubmissionResult = AppStoreConnectResourceResult<
  AppStoreConnectReviewSubmissionSummary
>
public typealias AppStoreConnectBetaAppLocalizationListResult = AppStoreConnectListResult<
  AppStoreConnectBetaAppLocalizationSummary
>
public typealias AppStoreConnectBetaAppLocalizationResult = AppStoreConnectResourceResult<
  AppStoreConnectBetaAppLocalizationSummary
>
public typealias AppStoreConnectBetaBuildLocalizationListResult = AppStoreConnectListResult<
  AppStoreConnectBetaBuildLocalizationSummary
>
public typealias AppStoreConnectBetaBuildLocalizationResult = AppStoreConnectResourceResult<
  AppStoreConnectBetaBuildLocalizationSummary
>
public typealias AppStoreConnectBetaAppReviewDetailListResult = AppStoreConnectListResult<
  AppStoreConnectBetaAppReviewDetailSummary
>
public typealias AppStoreConnectBetaAppReviewDetailResult = AppStoreConnectResourceResult<
  AppStoreConnectBetaAppReviewDetailSummary
>
public typealias AppStoreConnectBetaAppReviewSubmissionListResult = AppStoreConnectListResult<
  AppStoreConnectBetaAppReviewSubmissionSummary
>
public typealias AppStoreConnectBetaAppReviewSubmissionResult = AppStoreConnectResourceResult<
  AppStoreConnectBetaAppReviewSubmissionSummary
>
public typealias AppStoreConnectBetaLicenseAgreementListResult = AppStoreConnectListResult<
  AppStoreConnectBetaLicenseAgreementSummary
>
public typealias AppStoreConnectBetaLicenseAgreementResult = AppStoreConnectResourceResult<
  AppStoreConnectBetaLicenseAgreementSummary
>
public typealias AppStoreConnectBetaFeedbackCrashSubmissionListResult = AppStoreConnectListResult<
  AppStoreConnectBetaFeedbackCrashSubmissionSummary
>
public typealias AppStoreConnectBetaFeedbackCrashSubmissionResult = AppStoreConnectResourceResult<
  AppStoreConnectBetaFeedbackCrashSubmissionSummary
>
public typealias AppStoreConnectBetaFeedbackScreenshotSubmissionListResult =
  AppStoreConnectListResult<AppStoreConnectBetaFeedbackScreenshotSubmissionSummary>
public typealias AppStoreConnectBetaFeedbackScreenshotSubmissionResult =
  AppStoreConnectResourceResult<AppStoreConnectBetaFeedbackScreenshotSubmissionSummary>
public typealias AppStoreConnectBetaCrashLogResult = AppStoreConnectResourceResult<
  AppStoreConnectBetaCrashLogSummary
>
public typealias AppStoreConnectBetaTesterUsageMetricsResult = AppStoreConnectListResult<
  AppStoreConnectBetaTesterUsageMetricSeries
>
public typealias AppStoreConnectBetaBuildUsageMetricsResult = AppStoreConnectListResult<
  AppStoreConnectBetaBuildUsageMetricSeries
>
public typealias AppStoreConnectBetaPublicLinkUsageMetricsResult = AppStoreConnectListResult<
  AppStoreConnectBetaPublicLinkUsageMetricSeries
>
public typealias AppStoreConnectBetaGroupListResult = AppStoreConnectListResult<
  AppStoreConnectBetaGroupSummary
>
public typealias AppStoreConnectBetaGroupResult = AppStoreConnectResourceResult<
  AppStoreConnectBetaGroupSummary
>
public typealias AppStoreConnectBetaTesterListResult = AppStoreConnectListResult<
  AppStoreConnectBetaTesterSummary
>
public typealias AppStoreConnectBetaTesterResult = AppStoreConnectResourceResult<
  AppStoreConnectBetaTesterSummary
>
public typealias AppStoreConnectBundleIDListResult = AppStoreConnectListResult<
  AppStoreConnectBundleIDSummary
>
public typealias AppStoreConnectBundleIDResult = AppStoreConnectResourceResult<
  AppStoreConnectBundleIDSummary
>
public typealias AppStoreConnectBundleIDCapabilityListResult = AppStoreConnectListResult<
  AppStoreConnectBundleIDCapabilitySummary
>
public typealias AppStoreConnectBundleIDCapabilityResult = AppStoreConnectResourceResult<
  AppStoreConnectBundleIDCapabilitySummary
>
public typealias AppStoreConnectCertificateListResult = AppStoreConnectListResult<
  AppStoreConnectCertificateSummary
>
public typealias AppStoreConnectCertificateResult = AppStoreConnectResourceResult<
  AppStoreConnectCertificateSummary
>
public typealias AppStoreConnectCertificateDownloadResult = AppStoreConnectResourceResult<
  AppStoreConnectCertificateDownloadSummary
>
public typealias AppStoreConnectDeviceListResult = AppStoreConnectListResult<
  AppStoreConnectDeviceSummary
>
public typealias AppStoreConnectDeviceResult = AppStoreConnectResourceResult<
  AppStoreConnectDeviceSummary
>
public typealias AppStoreConnectProfileListResult = AppStoreConnectListResult<
  AppStoreConnectProfileSummary
>
public typealias AppStoreConnectProfileResult = AppStoreConnectResourceResult<
  AppStoreConnectProfileSummary
>
public typealias AppStoreConnectProfileDownloadResult = AppStoreConnectResourceResult<
  AppStoreConnectProfileDownloadSummary
>
public typealias AppStoreConnectUserListResult = AppStoreConnectListResult<
  AppStoreConnectUserSummary
>
public typealias AppStoreConnectUserResult = AppStoreConnectResourceResult<
  AppStoreConnectUserSummary
>
public typealias AppStoreConnectActorListResult = AppStoreConnectListResult<
  AppStoreConnectActorSummary
>
public typealias AppStoreConnectActorResult = AppStoreConnectResourceResult<
  AppStoreConnectActorSummary
>
public typealias AppStoreConnectUserInvitationListResult = AppStoreConnectListResult<
  AppStoreConnectUserInvitationSummary
>
public typealias AppStoreConnectUserInvitationResult = AppStoreConnectResourceResult<
  AppStoreConnectUserInvitationSummary
>

public struct PublicAPIReadCommands: Sendable {
  public let client: AppStoreConnectPublicClient
  private let sleep: @Sendable (UInt64) async throws -> Void

  public init(
    client: AppStoreConnectPublicClient,
    sleep: @escaping @Sendable (UInt64) async throws -> Void = { nanoseconds in
      try await Task.sleep(nanoseconds: nanoseconds)
    }
  ) {
    self.client = client
    self.sleep = sleep
  }

  public func listApps(_ input: AppStoreConnectAppListInput = .init()) async throws
    -> AppStoreConnectAppListResult
  {
    let output = try await client.apps.listApps(query: appListQuery(from: input))

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectAppListResult(
        data: body.data.map(Self.appSummary),
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected apps list response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Apps list did not return 200 ok.")
    }
  }

  public func getApp(_ input: AppStoreConnectAppViewInput) async throws -> AppStoreConnectAppResult
  {
    let output = try await client.apps.getApp(id: input.id)

    switch output {
    case .ok(let response):
      return AppStoreConnectAppResult(data: Self.appSummary(try response.body.json.data))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected app lookup response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "App lookup did not return 200 ok.")
    }
  }

  #if ASC_PUBLIC_API_RELEASE
    public func listAppCategories(
      _ input: AppStoreConnectAppCategoryListInput = .init()
    ) async throws -> AppStoreConnectAppCategoryListResult {
      let output = try await client.openAPI.appCategoriesGetCollection(
        query: appCategoryListQuery(from: input))

      switch output {
      case .ok(let response):
        let body = try response.body.json
        return AppStoreConnectAppCategoryListResult(
          data: body.data.map(Self.appCategorySummary),
          next: body.links.next
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected app categories response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "App categories listing did not return 200 ok.")
      }
    }

    public func getAppCategory(
      _ input: AppStoreConnectAppCategoryViewInput
    ) async throws -> AppStoreConnectAppCategoryResult {
      let output = try await client.openAPI.appCategoriesGetInstance(
        path: .init(id: input.id),
        query: appCategoryViewQuery(from: input)
      )

      switch output {
      case .ok(let response):
        return AppStoreConnectAppCategoryResult(
          data: Self.appCategorySummary(try response.body.json.data))
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected app category response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "App category lookup did not return 200 ok.")
      }
    }

    public func getAppCategoryParent(
      _ input: AppStoreConnectAppCategoryParentInput
    ) async throws -> AppStoreConnectAppCategoryResult {
      let output = try await client.openAPI.appCategoriesParentGetToOneRelated(
        path: .init(id: input.id),
        query: appCategoryParentQuery(from: input)
      )

      switch output {
      case .ok(let response):
        return AppStoreConnectAppCategoryResult(
          data: Self.appCategorySummary(try response.body.json.data))
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected app category parent response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "App category parent lookup did not return 200 ok.")
      }
    }

    public func listAppCategorySubcategories(
      _ input: AppStoreConnectAppCategorySubcategoriesInput
    ) async throws -> AppStoreConnectAppCategoryListResult {
      let output = try await client.openAPI.appCategoriesSubcategoriesGetToManyRelated(
        path: .init(id: input.id),
        query: appCategorySubcategoriesQuery(from: input)
      )

      switch output {
      case .ok(let response):
        let body = try response.body.json
        return AppStoreConnectAppCategoryListResult(
          data: body.data.map(Self.appCategorySummary),
          next: body.links.next
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected app category subcategories response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "App category subcategories lookup did not return 200 ok.")
      }
    }

    public func getAgeRating(
      _ input: AppStoreConnectAgeRatingViewInput
    ) async throws -> AppStoreConnectAgeRatingResult {
      let output = try await client.openAPI.appInfosAgeRatingDeclarationGetToOneRelated(
        path: .init(id: input.appInfoID),
        query: ageRatingViewQuery(from: input)
      )

      switch output {
      case .ok(let response):
        return AppStoreConnectAgeRatingResult(
          data: Self.ageRatingSummary(try response.body.json.data))
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected age rating declaration response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Age rating declaration lookup did not return 200 ok.")
      }
    }

    public func listAppEvents(
      _ input: AppStoreConnectAppEventListInput
    ) async throws -> AppStoreConnectAppEventListResult {
      let output = try await client.openAPI.appsAppEventsGetToManyRelated(
        path: .init(id: input.appID),
        query: appEventListQuery(from: input)
      )

      switch output {
      case .ok(let response):
        let body = try response.body.json
        return AppStoreConnectAppEventListResult(
          data: body.data.map(Self.appEventSummary),
          next: body.links.next
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected app events response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "App events listing did not return 200 ok.")
      }
    }

    public func getAppEvent(
      _ input: AppStoreConnectAppEventViewInput
    ) async throws -> AppStoreConnectAppEventResult {
      let output = try await client.openAPI.appEventsGetInstance(
        path: .init(id: input.id),
        query: appEventViewQuery(from: input)
      )

      switch output {
      case .ok(let response):
        return AppStoreConnectAppEventResult(
          data: Self.appEventSummary(try response.body.json.data))
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected app event response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "App event lookup did not return 200 ok.")
      }
    }
  #endif

  #if ASC_PUBLIC_API_METADATA_MEDIA
    public func listAppClips(
      _ input: AppStoreConnectAppClipListInput
    ) async throws -> AppStoreConnectAppClipListResult {
      let output = try await client.openAPI.appsAppClipsGetToManyRelated(
        path: .init(id: input.appID),
        query: appClipListQuery(from: input)
      )

      switch output {
      case .ok(let response):
        let body = try response.body.json
        return AppStoreConnectAppClipListResult(
          data: body.data.map(Self.appClipSummary),
          next: body.links.next
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected app clips response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "App clips listing did not return 200 ok.")
      }
    }

    public func getAppClip(
      _ input: AppStoreConnectAppClipViewInput
    ) async throws -> AppStoreConnectAppClipResult {
      let output = try await client.openAPI.appClipsGetInstance(
        path: .init(id: input.id),
        query: appClipViewQuery(from: input)
      )

      switch output {
      case .ok(let response):
        return AppStoreConnectAppClipResult(data: Self.appClipSummary(try response.body.json.data))
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected app clip response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "App clip lookup did not return 200 ok.")
      }
    }

    public func listAppClipDefaultExperiences(
      _ input: AppStoreConnectAppClipDefaultExperienceListInput
    ) async throws -> AppStoreConnectAppClipDefaultExperienceListResult {
      let output = try await client.openAPI.appClipsAppClipDefaultExperiencesGetToManyRelated(
        path: .init(id: input.appClipID),
        query: appClipDefaultExperienceListQuery(from: input)
      )

      switch output {
      case .ok(let response):
        let body = try response.body.json
        return AppStoreConnectAppClipDefaultExperienceListResult(
          data: body.data.map(Self.appClipDefaultExperienceSummary),
          next: body.links.next
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected app clip default experiences response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "App clip default experiences listing did not return 200 ok.")
      }
    }

    public func getAppClipDefaultExperience(
      _ input: AppStoreConnectAppClipDefaultExperienceViewInput
    ) async throws -> AppStoreConnectAppClipDefaultExperienceResult {
      let output = try await client.openAPI.appClipDefaultExperiencesGetInstance(
        path: .init(id: input.id),
        query: appClipDefaultExperienceViewQuery(from: input)
      )

      switch output {
      case .ok(let response):
        return AppStoreConnectAppClipDefaultExperienceResult(
          data: Self.appClipDefaultExperienceSummary(try response.body.json.data)
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected app clip default experience response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "App clip default experience lookup did not return 200 ok.")
      }
    }

    public func listAppClipLocalizations(
      _ input: AppStoreConnectAppClipLocalizationListInput
    ) async throws -> AppStoreConnectAppClipLocalizationListResult {
      let output = try await client.openAPI
        .appClipDefaultExperiencesAppClipDefaultExperienceLocalizationsGetToManyRelated(
          path: .init(id: input.defaultExperienceID),
          query: appClipLocalizationListQuery(from: input)
        )

      switch output {
      case .ok(let response):
        let body = try response.body.json
        return AppStoreConnectAppClipLocalizationListResult(
          data: body.data.map(Self.appClipLocalizationSummary),
          next: body.links.next
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected app clip localizations response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "App clip localizations listing did not return 200 ok.")
      }
    }

    public func getAppClipLocalization(
      _ input: AppStoreConnectAppClipLocalizationViewInput
    ) async throws -> AppStoreConnectAppClipLocalizationResult {
      let output = try await client.openAPI.appClipDefaultExperienceLocalizationsGetInstance(
        path: .init(id: input.id),
        query: appClipLocalizationViewQuery(from: input)
      )

      switch output {
      case .ok(let response):
        return AppStoreConnectAppClipLocalizationResult(
          data: Self.appClipLocalizationSummary(try response.body.json.data))
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected app clip localization response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "App clip localization lookup did not return 200 ok.")
      }
    }
  #endif

  #if ASC_PUBLIC_API_GAME_CENTER
    public func getGameCenterDetailForApp(
      _ input: AppStoreConnectGameCenterDetailForAppInput
    ) async throws -> AppStoreConnectGameCenterDetailResult {
      let output = try await client.openAPI.appsGameCenterDetailGetToOneRelated(
        path: .init(id: input.appID),
        query: gameCenterDetailForAppQuery(from: input)
      )

      switch output {
      case .ok(let response):
        return AppStoreConnectGameCenterDetailResult(
          data: Self.gameCenterDetailSummary(try response.body.json.data))
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected app Game Center detail response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "App Game Center detail lookup did not return 200 ok.")
      }
    }

    public func getGameCenterDetail(
      _ input: AppStoreConnectGameCenterDetailViewInput
    ) async throws -> AppStoreConnectGameCenterDetailResult {
      let output = try await client.openAPI.gameCenterDetailsGetInstance(
        path: .init(id: input.id),
        query: gameCenterDetailViewQuery(from: input)
      )

      switch output {
      case .ok(let response):
        return AppStoreConnectGameCenterDetailResult(
          data: Self.gameCenterDetailSummary(try response.body.json.data))
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected Game Center detail response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Game Center detail lookup did not return 200 ok.")
      }
    }

    public func listGameCenterAchievements(
      _ input: AppStoreConnectGameCenterNamedResourceListInput
    ) async throws -> AppStoreConnectGameCenterAchievementListResult {
      let output = try await client.openAPI
        .gameCenterDetailsGameCenterAchievementsV2GetToManyRelated(
          path: .init(id: input.detailID),
          query: gameCenterAchievementListQuery(from: input)
        )

      switch output {
      case .ok(let response):
        let body = try response.body.json
        return AppStoreConnectGameCenterAchievementListResult(
          data: body.data.map(Self.gameCenterAchievementSummary),
          next: body.links.next
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected Game Center achievements response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Game Center achievements listing did not return 200 ok.")
      }
    }

    public func getGameCenterAchievement(
      _ input: AppStoreConnectGameCenterResourceViewInput
    ) async throws -> AppStoreConnectGameCenterAchievementResult {
      let output = try await client.openAPI.gameCenterAchievementsV2GetInstance(
        path: .init(id: input.id),
        query: gameCenterAchievementViewQuery(from: input)
      )

      switch output {
      case .ok(let response):
        return AppStoreConnectGameCenterAchievementResult(
          data: Self.gameCenterAchievementSummary(try response.body.json.data))
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected Game Center achievement response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Game Center achievement lookup did not return 200 ok.")
      }
    }

    public func listGameCenterLeaderboards(
      _ input: AppStoreConnectGameCenterNamedResourceListInput
    ) async throws -> AppStoreConnectGameCenterLeaderboardListResult {
      let output = try await client.openAPI
        .gameCenterDetailsGameCenterLeaderboardsV2GetToManyRelated(
          path: .init(id: input.detailID),
          query: gameCenterLeaderboardListQuery(from: input)
        )

      switch output {
      case .ok(let response):
        let body = try response.body.json
        return AppStoreConnectGameCenterLeaderboardListResult(
          data: body.data.map(Self.gameCenterLeaderboardSummary),
          next: body.links.next
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected Game Center leaderboards response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Game Center leaderboards listing did not return 200 ok.")
      }
    }

    public func getGameCenterLeaderboard(
      _ input: AppStoreConnectGameCenterResourceViewInput
    ) async throws -> AppStoreConnectGameCenterLeaderboardResult {
      let output = try await client.openAPI.gameCenterLeaderboardsV2GetInstance(
        path: .init(id: input.id),
        query: gameCenterLeaderboardViewQuery(from: input)
      )

      switch output {
      case .ok(let response):
        return AppStoreConnectGameCenterLeaderboardResult(
          data: Self.gameCenterLeaderboardSummary(try response.body.json.data))
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected Game Center leaderboard response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Game Center leaderboard lookup did not return 200 ok.")
      }
    }

    public func listGameCenterLeaderboardSets(
      _ input: AppStoreConnectGameCenterNamedResourceListInput
    ) async throws -> AppStoreConnectGameCenterLeaderboardSetListResult {
      let output = try await client.openAPI
        .gameCenterDetailsGameCenterLeaderboardSetsV2GetToManyRelated(
          path: .init(id: input.detailID),
          query: gameCenterLeaderboardSetListQuery(from: input)
        )

      switch output {
      case .ok(let response):
        let body = try response.body.json
        return AppStoreConnectGameCenterLeaderboardSetListResult(
          data: body.data.map(Self.gameCenterLeaderboardSetSummary),
          next: body.links.next
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected Game Center leaderboard sets response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Game Center leaderboard sets listing did not return 200 ok.")
      }
    }

    public func getGameCenterLeaderboardSet(
      _ input: AppStoreConnectGameCenterResourceViewInput
    ) async throws -> AppStoreConnectGameCenterLeaderboardSetResult {
      let output = try await client.openAPI.gameCenterLeaderboardSetsV2GetInstance(
        path: .init(id: input.id),
        query: gameCenterLeaderboardSetViewQuery(from: input)
      )

      switch output {
      case .ok(let response):
        return AppStoreConnectGameCenterLeaderboardSetResult(
          data: Self.gameCenterLeaderboardSetSummary(try response.body.json.data))
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected Game Center leaderboard set response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Game Center leaderboard set lookup did not return 200 ok.")
      }
    }

    public func listGameCenterChallenges(
      _ input: AppStoreConnectGameCenterNamedResourceListInput
    ) async throws -> AppStoreConnectGameCenterChallengeListResult {
      let output = try await client.openAPI.gameCenterDetailsGameCenterChallengesGetToManyRelated(
        path: .init(id: input.detailID),
        query: gameCenterChallengeListQuery(from: input)
      )

      switch output {
      case .ok(let response):
        let body = try response.body.json
        return AppStoreConnectGameCenterChallengeListResult(
          data: body.data.map(Self.gameCenterChallengeSummary),
          next: body.links.next
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected Game Center challenges response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Game Center challenges listing did not return 200 ok.")
      }
    }

    public func getGameCenterChallenge(
      _ input: AppStoreConnectGameCenterResourceViewInput
    ) async throws -> AppStoreConnectGameCenterChallengeResult {
      let output = try await client.openAPI.gameCenterChallengesGetInstance(
        path: .init(id: input.id),
        query: gameCenterChallengeViewQuery(from: input)
      )

      switch output {
      case .ok(let response):
        return AppStoreConnectGameCenterChallengeResult(
          data: Self.gameCenterChallengeSummary(try response.body.json.data))
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected Game Center challenge response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Game Center challenge lookup did not return 200 ok.")
      }
    }
  #endif

  #if ASC_PUBLIC_API_DISTRIBUTION
    public func listAlternativeDistributionDomains(
      _ input: AppStoreConnectAlternativeDistributionDomainListInput = .init()
    ) async throws -> AppStoreConnectAlternativeDistributionDomainListResult {
      let output = try await client.openAPI.alternativeDistributionDomainsGetCollection(
        query: alternativeDistributionDomainListQuery(from: input)
      )

      switch output {
      case .ok(let response):
        let body = try response.body.json
        return AppStoreConnectAlternativeDistributionDomainListResult(
          data: body.data.map(Self.alternativeDistributionDomainSummary),
          next: body.links.next
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected alternative distribution domains response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Alternative distribution domains listing did not return 200 ok."
        )
      }
    }

    public func getAlternativeDistributionDomain(
      _ input: AppStoreConnectAlternativeDistributionDomainViewInput
    ) async throws -> AppStoreConnectAlternativeDistributionDomainResult {
      let output = try await client.openAPI.alternativeDistributionDomainsGetInstance(
        path: .init(id: input.id),
        query: alternativeDistributionDomainViewQuery(from: input)
      )

      switch output {
      case .ok(let response):
        return AppStoreConnectAlternativeDistributionDomainResult(
          data: Self.alternativeDistributionDomainSummary(try response.body.json.data)
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected alternative distribution domain response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Alternative distribution domain lookup did not return 200 ok.")
      }
    }

    public func listAlternativeDistributionKeys(
      _ input: AppStoreConnectAlternativeDistributionKeyListInput = .init()
    ) async throws -> AppStoreConnectAlternativeDistributionKeyListResult {
      let output = try await client.openAPI.alternativeDistributionKeysGetCollection(
        query: alternativeDistributionKeyListQuery(from: input)
      )

      switch output {
      case .ok(let response):
        let body = try response.body.json
        return AppStoreConnectAlternativeDistributionKeyListResult(
          data: body.data.map(Self.alternativeDistributionKeySummary),
          next: body.links.next
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected alternative distribution keys response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Alternative distribution keys listing did not return 200 ok.")
      }
    }

    public func getAlternativeDistributionKey(
      _ input: AppStoreConnectAlternativeDistributionKeyViewInput
    ) async throws -> AppStoreConnectAlternativeDistributionKeyResult {
      let output = try await client.openAPI.alternativeDistributionKeysGetInstance(
        path: .init(id: input.id),
        query: alternativeDistributionKeyViewQuery(from: input)
      )

      switch output {
      case .ok(let response):
        return AppStoreConnectAlternativeDistributionKeyResult(
          data: Self.alternativeDistributionKeySummary(try response.body.json.data)
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected alternative distribution key response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Alternative distribution key lookup did not return 200 ok.")
      }
    }

    public func listMarketplaceWebhooks(
      _ input: AppStoreConnectMarketplaceWebhookListInput = .init()
    ) async throws -> AppStoreConnectMarketplaceWebhookListResult {
      let output = try await client.openAPI.marketplaceWebhooksGetCollection(
        query: marketplaceWebhookListQuery(from: input)
      )

      switch output {
      case .ok(let response):
        let body = try response.body.json
        return AppStoreConnectMarketplaceWebhookListResult(
          data: body.data.map(Self.marketplaceWebhookSummary),
          next: body.links.next
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected marketplace webhooks response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Marketplace webhooks listing did not return 200 ok.")
      }
    }

    public func listWebhooks(
      _ input: AppStoreConnectWebhookListInput
    ) async throws -> AppStoreConnectWebhookListResult {
      let output = try await client.openAPI.appsWebhooksGetToManyRelated(
        .init(path: .init(id: input.appID), query: webhookListQuery(from: input))
      )

      switch output {
      case .ok(let response):
        let body = try response.body.json
        return AppStoreConnectWebhookListResult(
          data: body.data.map(Self.webhookSummary),
          next: body.links.next
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected webhooks response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Webhooks listing did not return 200 ok.")
      }
    }

    public func getWebhook(_ input: AppStoreConnectWebhookViewInput) async throws
      -> AppStoreConnectWebhookResult
    {
      let output = try await client.openAPI.webhooksGetInstance(
        .init(path: .init(id: input.id), query: webhookViewQuery(from: input))
      )

      switch output {
      case .ok(let response):
        return AppStoreConnectWebhookResult(data: Self.webhookSummary(try response.body.json.data))
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected webhook response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Webhook lookup did not return 200 ok.")
      }
    }

    public func listWebhookDeliveries(
      _ input: AppStoreConnectWebhookDeliveryListInput
    ) async throws -> AppStoreConnectWebhookDeliveryListResult {
      let output = try await client.openAPI.webhooksDeliveriesGetToManyRelated(
        .init(path: .init(id: input.webhookID), query: webhookDeliveryListQuery(from: input))
      )

      switch output {
      case .ok(let response):
        let body = try response.body.json
        return AppStoreConnectWebhookDeliveryListResult(
          data: body.data.map(Self.webhookDeliverySummary),
          next: body.links.next
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected webhook deliveries response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Webhook deliveries listing did not return 200 ok.")
      }
    }

    public func listWebhookDeliveryLinkages(
      _ input: AppStoreConnectWebhookDeliveryLinkageListInput
    ) async throws -> AppStoreConnectWebhookDeliveryLinkageListResult {
      let output = try await client.openAPI.webhooksDeliveriesGetToManyRelationship(
        path: .init(id: input.webhookID),
        query: webhookDeliveryLinkageListQuery(from: input)
      )

      switch output {
      case .ok(let response):
        let body = try response.body.json
        return AppStoreConnectWebhookDeliveryLinkageListResult(
          data: body.data.map(Self.webhookDeliveryLinkageSummary),
          next: body.links.next
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected webhook delivery linkages response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Webhook delivery linkages listing did not return 200 ok.")
      }
    }

    public func getEULA(_ input: AppStoreConnectEULAViewInput) async throws
      -> AppStoreConnectEULAResult
    {
      let output = try await client.openAPI.endUserLicenseAgreementsGetInstance(
        path: .init(id: input.id),
        query: eulaViewQuery(from: input)
      )

      switch output {
      case .ok(let response):
        return AppStoreConnectEULAResult(data: Self.eulaSummary(try response.body.json.data))
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected EULA response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "EULA lookup did not return 200 ok.")
      }
    }

    public func listTerritories(
      _ input: AppStoreConnectTerritoryListInput = .init()
    ) async throws -> AppStoreConnectTerritoryListResult {
      let output = try await client.openAPI.territoriesGetCollection(
        query: territoryListQuery(from: input))

      switch output {
      case .ok(let response):
        let body = try response.body.json
        return AppStoreConnectTerritoryListResult(
          data: body.data.map(Self.territorySummary),
          next: body.links.next
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected territories response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Territories listing did not return 200 ok.")
      }
    }
  #endif

  public func listBuilds(_ input: AppStoreConnectBuildListInput = .init()) async throws
    -> AppStoreConnectBuildListResult
  {
    let output = try await client.builds.listBuilds(query: buildListQuery(from: input))

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectBuildListResult(
        data: body.data.map(Self.buildSummary),
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected builds list response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Builds list did not return 200 ok.")
    }
  }

  public func getBuild(_ input: AppStoreConnectBuildInfoInput) async throws
    -> AppStoreConnectBuildResult
  {
    if let id = input.id {
      let output = try await client.builds.getBuild(id: id)

      switch output {
      case .ok(let response):
        return AppStoreConnectBuildResult(data: Self.buildSummary(try response.body.json.data))
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected build lookup response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Build lookup did not return 200 ok.")
      }
    }

    guard var selector = input.latestSelector else {
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Missing build id or latest build selector.")
    }
    selector.sort = selector.sort ?? "-uploadedDate"
    selector.limit = selector.limit ?? 1

    let result = try await listBuilds(selector)
    guard let build = result.data.first else {
      throw AppStoreConnectError.requestFailed(
        statusCode: 404, message: "No matching build was found.")
    }
    return AppStoreConnectBuildResult(data: build)
  }

  public func listBuildBetaDetails(
    _ input: AppStoreConnectBuildBetaDetailListInput = .init()
  ) async throws -> AppStoreConnectBuildBetaDetailListResult {
    let output = try await client.builds.listBuildBetaDetails(
      query: buildBetaDetailListQuery(from: input))

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectBuildBetaDetailListResult(
        data: body.data.map(Self.buildBetaDetailSummary),
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected build beta details response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Build beta details listing did not return 200 ok.")
    }
  }

  public func getBuildBetaDetail(
    _ input: AppStoreConnectBuildBetaDetailViewInput
  ) async throws -> AppStoreConnectBuildBetaDetailResult {
    let output = try await client.builds.getBuildBetaDetail(
      id: input.id,
      query: .init(include: [.build])
    )

    switch output {
    case .ok(let response):
      return AppStoreConnectBuildBetaDetailResult(
        data: Self.buildBetaDetailSummary(try response.body.json.data))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected build beta detail response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Build beta detail lookup did not return 200 ok.")
    }
  }

  public func listPreReleaseVersions(
    _ input: AppStoreConnectPreReleaseVersionListInput = .init()
  ) async throws -> AppStoreConnectPreReleaseVersionListResult {
    let output = try await client.builds.listPreReleaseVersions(
      query: preReleaseVersionListQuery(from: input))

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectPreReleaseVersionListResult(
        data: body.data.map(Self.preReleaseVersionSummary),
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected prerelease versions response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Prerelease versions listing did not return 200 ok.")
    }
  }

  public func getPreReleaseVersion(
    _ input: AppStoreConnectPreReleaseVersionViewInput
  ) async throws -> AppStoreConnectPreReleaseVersionResult {
    let output = try await client.builds.getPreReleaseVersion(
      id: input.id,
      query: .init(include: [.app, .builds])
    )

    switch output {
    case .ok(let response):
      return AppStoreConnectPreReleaseVersionResult(
        data: Self.preReleaseVersionSummary(try response.body.json.data))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected prerelease version response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Prerelease version lookup did not return 200 ok.")
    }
  }

  public func listAppStoreVersions(
    _ input: AppStoreConnectAppStoreVersionListInput
  ) async throws -> AppStoreConnectAppStoreVersionListResult {
    let output = try await client.apps.listAppStoreVersionsForApp(
      id: input.appID,
      query: appStoreVersionListQuery(from: input)
    )

    switch output {
    case .ok(let response):
      let body = try response.body.json
      let versions = body.data
        .map(Self.appStoreVersionSummary)
        .filter { version in
          input.appStoreStates.isEmpty
            || version.appStoreState.map { input.appStoreStates.contains($0) } == true
        }
      return AppStoreConnectAppStoreVersionListResult(
        data: versions,
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected App Store versions response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "App Store versions listing did not return 200 ok.")
    }
  }

  public func getAppStoreVersion(
    _ input: AppStoreConnectAppStoreVersionViewInput
  ) async throws -> AppStoreConnectAppStoreVersionResult {
    AppStoreConnectAppStoreVersionResult(data: try await fetchAppStoreVersion(id: input.id))
  }

  public func listBetaGroups(
    _ input: AppStoreConnectBetaGroupListInput = .init()
  ) async throws -> AppStoreConnectBetaGroupListResult {
    let output = try await client.testFlight.listBetaGroups(query: betaGroupListQuery(from: input))

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectBetaGroupListResult(
        data: body.data.map(Self.betaGroupSummary),
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta groups response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Beta groups listing did not return 200 ok.")
    }
  }

  public func getBetaGroup(_ input: AppStoreConnectBetaGroupViewInput) async throws
    -> AppStoreConnectBetaGroupResult
  {
    let output = try await client.testFlight.getBetaGroup(id: input.id)

    switch output {
    case .ok(let response):
      return AppStoreConnectBetaGroupResult(
        data: Self.betaGroupSummary(try response.body.json.data))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta group response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Beta group lookup did not return 200 ok.")
    }
  }

  public func listBetaTesters(
    _ input: AppStoreConnectBetaTesterListInput = .init()
  ) async throws -> AppStoreConnectBetaTesterListResult {
    let output = try await client.testFlight.listBetaTesters(
      query: betaTesterListQuery(from: input))

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectBetaTesterListResult(
        data: body.data.map(Self.betaTesterSummary),
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta testers response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Beta testers listing did not return 200 ok.")
    }
  }

  public func getBetaTester(_ input: AppStoreConnectBetaTesterViewInput) async throws
    -> AppStoreConnectBetaTesterResult
  {
    let output = try await client.testFlight.getBetaTester(id: input.id)

    switch output {
    case .ok(let response):
      return AppStoreConnectBetaTesterResult(
        data: Self.betaTesterSummary(try response.body.json.data))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta tester response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Beta tester lookup did not return 200 ok.")
    }
  }

  public func listBundleIDs(
    _ input: AppStoreConnectBundleIDListInput = .init()
  ) async throws -> AppStoreConnectBundleIDListResult {
    let output = try await client.certificatesProfiles.listBundleIds(
      query: bundleIDListQuery(from: input))

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectBundleIDListResult(
        data: body.data.map(Self.bundleIDSummary),
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected bundle IDs response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Bundle IDs listing did not return 200 ok.")
    }
  }

  public func getBundleID(_ input: AppStoreConnectBundleIDViewInput) async throws
    -> AppStoreConnectBundleIDResult
  {
    let output = try await client.certificatesProfiles.getBundleId(id: input.id)

    switch output {
    case .ok(let response):
      return AppStoreConnectBundleIDResult(data: Self.bundleIDSummary(try response.body.json.data))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected bundle ID response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Bundle ID lookup did not return 200 ok.")
    }
  }

  public func listBundleIDCapabilities(
    _ input: AppStoreConnectBundleIDCapabilityListInput
  ) async throws -> AppStoreConnectBundleIDCapabilityListResult {
    let output = try await client.certificatesProfiles.listBundleIdCapabilitiesForBundleId(
      id: input.bundleID,
      query: bundleIDCapabilityListQuery(from: input)
    )

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectBundleIDCapabilityListResult(
        data: body.data.map(Self.bundleIDCapabilitySummary),
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected bundle ID capabilities response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Bundle ID capability listing did not return 200 ok.")
    }
  }

  public func listCertificates(
    _ input: AppStoreConnectCertificateListInput = .init()
  ) async throws -> AppStoreConnectCertificateListResult {
    let output = try await client.certificatesProfiles.listCertificates(
      query: certificateListQuery(from: input))

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectCertificateListResult(
        data: body.data.map(Self.certificateSummary),
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected certificates response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Certificates listing did not return 200 ok.")
    }
  }

  public func getCertificate(
    _ input: AppStoreConnectCertificateViewInput
  ) async throws -> AppStoreConnectCertificateResult {
    let output = try await client.certificatesProfiles.getCertificate(id: input.id)

    switch output {
    case .ok(let response):
      return AppStoreConnectCertificateResult(
        data: Self.certificateSummary(try response.body.json.data))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected certificate response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Certificate lookup did not return 200 ok.")
    }
  }

  public func downloadCertificate(
    _ input: AppStoreConnectCertificateDownloadInput
  ) async throws -> AppStoreConnectCertificateDownloadResult {
    let output = try await client.certificatesProfiles.getCertificate(id: input.id)

    switch output {
    case .ok(let response):
      let certificate = try response.body.json.data
      guard let certificateContent = certificate.attributes?.certificateContent,
        !certificateContent.isEmpty
      else {
        throw AppStoreConnectError.decodingFailed(
          "Certificate response did not include certificateContent.")
      }
      guard let data = Data(base64Encoded: certificateContent, options: [.ignoreUnknownCharacters])
      else {
        throw AppStoreConnectError.decodingFailed(
          "Certificate certificateContent was not valid base64.")
      }
      let url = try Self.certificateDownloadDestinationURL(
        outputPath: input.outputPath,
        certificateID: certificate.id,
        serialNumber: certificate.attributes?.serialNumber
      )
      let byteCount = try Self.write(data, to: url)
      return AppStoreConnectCertificateDownloadResult(
        data: .init(
          id: certificate.id,
          name: certificate.attributes?.name,
          displayName: certificate.attributes?.displayName,
          certificateType: certificate.attributes?.certificateType?.rawValue,
          serialNumber: certificate.attributes?.serialNumber,
          outputPath: url.path,
          byteCount: byteCount,
          operationID: Operations.CertificatesGetInstance.id
        ))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected certificate response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Certificate download did not return 200 ok.")
    }
  }

  public func listDevices(
    _ input: AppStoreConnectDeviceListInput = .init()
  ) async throws -> AppStoreConnectDeviceListResult {
    let output = try await client.certificatesProfiles.listDevices(
      query: deviceListQuery(from: input))

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectDeviceListResult(
        data: body.data.map(Self.deviceSummary),
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected devices response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Devices listing did not return 200 ok.")
    }
  }

  public func getDevice(_ input: AppStoreConnectDeviceViewInput) async throws
    -> AppStoreConnectDeviceResult
  {
    let output = try await client.certificatesProfiles.getDevice(id: input.id)

    switch output {
    case .ok(let response):
      return AppStoreConnectDeviceResult(data: Self.deviceSummary(try response.body.json.data))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected device response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Device lookup did not return 200 ok.")
    }
  }

  public func listProfiles(
    _ input: AppStoreConnectProfileListInput = .init()
  ) async throws -> AppStoreConnectProfileListResult {
    let output = try await client.certificatesProfiles.listProfiles(
      query: profileListQuery(from: input))

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectProfileListResult(
        data: body.data.map(Self.profileSummary),
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected profiles response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Profiles listing did not return 200 ok.")
    }
  }

  public func getProfile(_ input: AppStoreConnectProfileViewInput) async throws
    -> AppStoreConnectProfileResult
  {
    let output = try await client.certificatesProfiles.getProfile(id: input.id)

    switch output {
    case .ok(let response):
      return AppStoreConnectProfileResult(data: Self.profileSummary(try response.body.json.data))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected profile response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Profile lookup did not return 200 ok.")
    }
  }

  public func downloadProfile(
    _ input: AppStoreConnectProfileDownloadInput
  ) async throws -> AppStoreConnectProfileDownloadResult {
    let output = try await client.certificatesProfiles.getProfile(id: input.id)

    switch output {
    case .ok(let response):
      let profile = try response.body.json.data
      guard let profileContent = profile.attributes?.profileContent, !profileContent.isEmpty else {
        throw AppStoreConnectError.decodingFailed(
          "Profile response did not include profileContent.")
      }
      guard let data = Data(base64Encoded: profileContent, options: [.ignoreUnknownCharacters])
      else {
        throw AppStoreConnectError.decodingFailed("Profile profileContent was not valid base64.")
      }
      let url = try Self.profileDownloadDestinationURL(
        outputPath: input.outputPath,
        profileID: profile.id,
        uuid: profile.attributes?.uuid
      )
      let byteCount = try Self.write(data, to: url)
      return AppStoreConnectProfileDownloadResult(
        data: .init(
          id: profile.id,
          name: profile.attributes?.name,
          uuid: profile.attributes?.uuid,
          profileType: profile.attributes?.profileType?.rawValue,
          outputPath: url.path,
          byteCount: byteCount,
          operationID: Operations.ProfilesGetInstance.id
        ))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected profile response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Profile download did not return 200 ok.")
    }
  }

  public func listUsers(
    _ input: AppStoreConnectUserListInput = .init()
  ) async throws -> AppStoreConnectUserListResult {
    let output = try await client.users.listUsers(query: userListQuery(from: input))

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectUserListResult(
        data: body.data.map(Self.userSummary),
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected users response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Users listing did not return 200 ok.")
    }
  }

  public func getUser(_ input: AppStoreConnectUserViewInput) async throws
    -> AppStoreConnectUserResult
  {
    let output = try await client.users.getUser(
      id: input.id,
      query: .init(include: [.visibleApps])
    )

    switch output {
    case .ok(let response):
      return AppStoreConnectUserResult(data: Self.userSummary(try response.body.json.data))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected user response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "User lookup did not return 200 ok.")
    }
  }

  #if ASC_PUBLIC_API_SIGNING_ACCESS
    public func listActors(
      _ input: AppStoreConnectActorListInput = .init()
    ) async throws -> AppStoreConnectActorListResult {
      let output = try await client.openAPI.actorsGetCollection(query: actorListQuery(from: input))

      switch output {
      case .ok(let response):
        let body = try response.body.json
        return AppStoreConnectActorListResult(
          data: body.data.map(Self.actorSummary),
          next: body.links.next
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected actors response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Actors listing did not return 200 ok.")
      }
    }

    public func getActor(_ input: AppStoreConnectActorViewInput) async throws
      -> AppStoreConnectActorResult
    {
      let output = try await client.openAPI.actorsGetInstance(
        path: .init(id: input.id),
        query: actorViewQuery(from: input)
      )

      switch output {
      case .ok(let response):
        return AppStoreConnectActorResult(data: Self.actorSummary(try response.body.json.data))
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected actor response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Actor lookup did not return 200 ok.")
      }
    }
  #endif

  public func listUserInvitations(
    _ input: AppStoreConnectUserInvitationListInput = .init()
  ) async throws -> AppStoreConnectUserInvitationListResult {
    let output = try await client.users.listUserInvitations(
      query: userInvitationListQuery(from: input))

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectUserInvitationListResult(
        data: body.data.map(Self.userInvitationSummary),
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected user invitations response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "User invitations listing did not return 200 ok.")
    }
  }

  public func getUserInvitation(
    _ input: AppStoreConnectUserInvitationViewInput
  ) async throws -> AppStoreConnectUserInvitationResult {
    let output = try await client.users.getUserInvitation(
      id: input.id,
      query: .init(include: [.visibleApps])
    )

    switch output {
    case .ok(let response):
      return AppStoreConnectUserInvitationResult(
        data: Self.userInvitationSummary(try response.body.json.data))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected user invitation response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "User invitation lookup did not return 200 ok.")
    }
  }

  public func listReviewSubmissions(
    _ input: AppStoreConnectReviewSubmissionListInput
  ) async throws -> AppStoreConnectReviewSubmissionListResult {
    let output = try await client.apps.listReviewSubmissions(
      query: reviewSubmissionListQuery(from: input))

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectReviewSubmissionListResult(
        data: body.data.map(Self.reviewSubmissionSummary),
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected review submissions response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Review submission listing did not return 200 ok.")
    }
  }

  public func getReviewSubmission(
    _ input: AppStoreConnectReviewSubmissionViewInput
  ) async throws -> AppStoreConnectReviewSubmissionResult {
    let output = try await client.apps.getReviewSubmission(
      id: input.id,
      query: .init(include: [.app, .appStoreVersionForReview])
    )

    switch output {
    case .ok(let response):
      return AppStoreConnectReviewSubmissionResult(
        data: Self.reviewSubmissionSummary(try response.body.json.data))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected review submission response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Review submission lookup did not return 200 ok.")
    }
  }

  #if ASC_PUBLIC_API_RELEASE
    public func listCustomerReviews(
      _ input: AppStoreConnectCustomerReviewListInput
    ) async throws -> AppStoreConnectCustomerReviewListResult {
      if let appStoreVersionID = input.appStoreVersionID {
        let output = try await client.openAPI.appStoreVersionsCustomerReviewsGetToManyRelated(
          path: .init(id: appStoreVersionID),
          query: appStoreVersionCustomerReviewListQuery(from: input)
        )
        switch output {
        case .ok(let response):
          let body = try response.body.json
          return AppStoreConnectCustomerReviewListResult(
            data: body.data.map(Self.customerReviewSummary),
            next: body.links.next
          )
        case .undocumented(let statusCode, _):
          throw AppStoreConnectError.requestFailed(
            statusCode: statusCode, message: "Unexpected customer review listing response.")
        default:
          throw AppStoreConnectError.requestFailed(
            statusCode: -1, message: "Customer review listing did not return 200 ok.")
        }
      }

      guard let appID = input.appID else {
        throw AppStoreConnectError.invalidConfiguration("reviews list requires --app or --version.")
      }

      let output = try await client.openAPI.appsCustomerReviewsGetToManyRelated(
        path: .init(id: appID),
        query: appCustomerReviewListQuery(from: input)
      )
      switch output {
      case .ok(let response):
        let body = try response.body.json
        return AppStoreConnectCustomerReviewListResult(
          data: body.data.map(Self.customerReviewSummary),
          next: body.links.next
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected customer review listing response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Customer review listing did not return 200 ok.")
      }
    }

    public func getCustomerReview(
      _ input: AppStoreConnectCustomerReviewViewInput
    ) async throws -> AppStoreConnectCustomerReviewResult {
      let output = try await client.openAPI.customerReviewsGetInstance(
        path: .init(id: input.id),
        query: customerReviewViewQuery(from: input)
      )

      switch output {
      case .ok(let response):
        return AppStoreConnectCustomerReviewResult(
          data: Self.customerReviewSummary(try response.body.json.data))
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected customer review response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Customer review lookup did not return 200 ok.")
      }
    }

    public func listCustomerReviewSummarizations(
      _ input: AppStoreConnectCustomerReviewSummarizationListInput
    ) async throws -> AppStoreConnectCustomerReviewSummarizationListResult {
      guard !input.platforms.isEmpty else {
        throw AppStoreConnectError.invalidConfiguration(
          "reviews ratings requires at least one --platform.")
      }

      let output = try await client.openAPI.appsCustomerReviewSummarizationsGetToManyRelated(
        path: .init(id: input.appID),
        query: customerReviewSummarizationListQuery(from: input)
      )

      switch output {
      case .ok(let response):
        let body = try response.body.json
        return AppStoreConnectCustomerReviewSummarizationListResult(
          data: body.data.map(Self.customerReviewSummarizationSummary),
          next: body.links.next
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected customer review summarization response.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Customer review summarization listing did not return 200 ok.")
      }
    }

    public func getCustomerReviewResponse(
      _ input: AppStoreConnectCustomerReviewResponseViewInput
    ) async throws -> AppStoreConnectCustomerReviewResponseResult {
      let output = try await client.openAPI.customerReviewResponsesGetInstance(
        path: .init(id: input.id))

      switch output {
      case .ok(let response):
        return AppStoreConnectCustomerReviewResponseResult(
          data: Self.customerReviewResponseSummary(try response.body.json.data)
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected customer review response lookup.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Customer review response lookup did not return 200 ok.")
      }
    }

    public func getCustomerReviewResponseForReview(
      _ input: AppStoreConnectCustomerReviewResponseForReviewInput
    ) async throws -> AppStoreConnectCustomerReviewResponseResult {
      let output = try await client.openAPI.customerReviewsResponseGetToOneRelated(
        path: .init(id: input.reviewID))

      switch output {
      case .ok(let response):
        return AppStoreConnectCustomerReviewResponseResult(
          data: Self.customerReviewResponseSummary(try response.body.json.data)
        )
      case .undocumented(let statusCode, _):
        throw AppStoreConnectError.requestFailed(
          statusCode: statusCode, message: "Unexpected customer review response lookup.")
      default:
        throw AppStoreConnectError.requestFailed(
          statusCode: -1, message: "Customer review response lookup did not return 200 ok.")
      }
    }
  #endif

  public func listBetaAppLocalizations(
    _ input: AppStoreConnectBetaAppLocalizationListInput = .init()
  ) async throws -> AppStoreConnectBetaAppLocalizationListResult {
    let output = try await client.testFlight.listBetaAppLocalizations(
      query: betaAppLocalizationListQuery(from: input)
    )

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectBetaAppLocalizationListResult(
        data: body.data.map(Self.betaAppLocalizationSummary),
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta app localizations response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Beta app localization listing did not return 200 ok.")
    }
  }

  public func getBetaAppLocalization(
    _ input: AppStoreConnectBetaAppLocalizationViewInput
  ) async throws -> AppStoreConnectBetaAppLocalizationResult {
    let output = try await client.testFlight.getBetaAppLocalization(
      id: input.id,
      query: .init(include: [.app])
    )

    switch output {
    case .ok(let response):
      return AppStoreConnectBetaAppLocalizationResult(
        data: Self.betaAppLocalizationSummary(try response.body.json.data))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta app localization response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Beta app localization lookup did not return 200 ok.")
    }
  }

  public func listBetaBuildLocalizations(
    _ input: AppStoreConnectBetaBuildLocalizationListInput = .init()
  ) async throws -> AppStoreConnectBetaBuildLocalizationListResult {
    let output = try await client.testFlight.listBetaBuildLocalizations(
      query: betaBuildLocalizationListQuery(from: input)
    )

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectBetaBuildLocalizationListResult(
        data: body.data.map(Self.betaBuildLocalizationSummary),
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta build localizations response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Beta build localization listing did not return 200 ok.")
    }
  }

  public func getBetaBuildLocalization(
    _ input: AppStoreConnectBetaBuildLocalizationViewInput
  ) async throws -> AppStoreConnectBetaBuildLocalizationResult {
    let output = try await client.testFlight.getBetaBuildLocalization(
      id: input.id,
      query: .init(include: [.build])
    )

    switch output {
    case .ok(let response):
      return AppStoreConnectBetaBuildLocalizationResult(
        data: Self.betaBuildLocalizationSummary(try response.body.json.data))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta build localization response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Beta build localization lookup did not return 200 ok.")
    }
  }

  public func listBetaAppReviewDetails(
    _ input: AppStoreConnectBetaAppReviewDetailListInput
  ) async throws -> AppStoreConnectBetaAppReviewDetailListResult {
    let output = try await client.testFlight.listBetaAppReviewDetails(
      query: betaAppReviewDetailListQuery(from: input)
    )

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectBetaAppReviewDetailListResult(
        data: body.data.map(Self.betaAppReviewDetailSummary),
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta app review details response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Beta app review detail listing did not return 200 ok.")
    }
  }

  public func getBetaAppReviewDetail(
    _ input: AppStoreConnectBetaAppReviewDetailViewInput
  ) async throws -> AppStoreConnectBetaAppReviewDetailResult {
    let output = try await client.testFlight.getBetaAppReviewDetail(
      id: input.id,
      query: .init(include: [.app])
    )

    switch output {
    case .ok(let response):
      return AppStoreConnectBetaAppReviewDetailResult(
        data: Self.betaAppReviewDetailSummary(try response.body.json.data))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta app review detail response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Beta app review detail lookup did not return 200 ok.")
    }
  }

  public func listBetaAppReviewSubmissions(
    _ input: AppStoreConnectBetaAppReviewSubmissionListInput
  ) async throws -> AppStoreConnectBetaAppReviewSubmissionListResult {
    guard !input.buildIDs.isEmpty else {
      throw AppStoreConnectError.invalidConfiguration(
        "Beta app review submission listing requires at least one build ID.")
    }

    let output = try await client.testFlight.listBetaAppReviewSubmissions(
      query: betaAppReviewSubmissionListQuery(from: input)
    )

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectBetaAppReviewSubmissionListResult(
        data: body.data.map(Self.betaAppReviewSubmissionSummary),
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta app review submissions response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Beta app review submission listing did not return 200 ok.")
    }
  }

  public func getBetaAppReviewSubmission(
    _ input: AppStoreConnectBetaAppReviewSubmissionViewInput
  ) async throws -> AppStoreConnectBetaAppReviewSubmissionResult {
    let output = try await client.testFlight.getBetaAppReviewSubmission(
      id: input.id,
      query: .init(include: [.build])
    )

    switch output {
    case .ok(let response):
      return AppStoreConnectBetaAppReviewSubmissionResult(
        data: Self.betaAppReviewSubmissionSummary(try response.body.json.data))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta app review submission response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Beta app review submission lookup did not return 200 ok.")
    }
  }

  public func listBetaLicenseAgreements(
    _ input: AppStoreConnectBetaLicenseAgreementListInput = .init()
  ) async throws -> AppStoreConnectBetaLicenseAgreementListResult {
    let output = try await client.testFlight.listBetaLicenseAgreements(
      query: betaLicenseAgreementListQuery(from: input)
    )

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectBetaLicenseAgreementListResult(
        data: body.data.map(Self.betaLicenseAgreementSummary),
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta license agreements response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Beta license agreement listing did not return 200 ok.")
    }
  }

  public func getBetaLicenseAgreement(
    _ input: AppStoreConnectBetaLicenseAgreementViewInput
  ) async throws -> AppStoreConnectBetaLicenseAgreementResult {
    let output = try await client.testFlight.getBetaLicenseAgreement(
      id: input.id,
      query: .init(include: [.app])
    )

    switch output {
    case .ok(let response):
      return AppStoreConnectBetaLicenseAgreementResult(
        data: Self.betaLicenseAgreementSummary(try response.body.json.data))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta license agreement response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Beta license agreement lookup did not return 200 ok.")
    }
  }

  public func listBetaFeedbackCrashSubmissions(
    _ input: AppStoreConnectBetaFeedbackCrashSubmissionListInput
  ) async throws -> AppStoreConnectBetaFeedbackCrashSubmissionListResult {
    let output = try await client.testFlight.listBetaFeedbackCrashSubmissionsForApp(
      id: input.appID,
      query: betaFeedbackCrashSubmissionListQuery(from: input)
    )

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectBetaFeedbackCrashSubmissionListResult(
        data: body.data.map(Self.betaFeedbackCrashSubmissionSummary),
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta feedback crash submissions response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Beta feedback crash submission listing did not return 200 ok.")
    }
  }

  public func getBetaFeedbackCrashSubmission(
    _ input: AppStoreConnectBetaFeedbackCrashSubmissionViewInput
  ) async throws -> AppStoreConnectBetaFeedbackCrashSubmissionResult {
    let output = try await client.testFlight.getBetaFeedbackCrashSubmission(
      id: input.id,
      query: .init(include: [.build, .tester])
    )

    switch output {
    case .ok(let response):
      return AppStoreConnectBetaFeedbackCrashSubmissionResult(
        data: Self.betaFeedbackCrashSubmissionSummary(try response.body.json.data))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta feedback crash submission response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Beta feedback crash submission lookup did not return 200 ok.")
    }
  }

  public func listBetaFeedbackScreenshotSubmissions(
    _ input: AppStoreConnectBetaFeedbackScreenshotSubmissionListInput
  ) async throws -> AppStoreConnectBetaFeedbackScreenshotSubmissionListResult {
    let output = try await client.testFlight.listBetaFeedbackScreenshotSubmissionsForApp(
      id: input.appID,
      query: betaFeedbackScreenshotSubmissionListQuery(from: input)
    )

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectBetaFeedbackScreenshotSubmissionListResult(
        data: body.data.map(Self.betaFeedbackScreenshotSubmissionSummary),
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta feedback screenshot submissions response."
      )
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1,
        message: "Beta feedback screenshot submission listing did not return 200 ok.")
    }
  }

  public func getBetaFeedbackScreenshotSubmission(
    _ input: AppStoreConnectBetaFeedbackScreenshotSubmissionViewInput
  ) async throws -> AppStoreConnectBetaFeedbackScreenshotSubmissionResult {
    let output = try await client.testFlight.getBetaFeedbackScreenshotSubmission(
      id: input.id,
      query: .init(include: [.build, .tester])
    )

    switch output {
    case .ok(let response):
      return AppStoreConnectBetaFeedbackScreenshotSubmissionResult(
        data: Self.betaFeedbackScreenshotSubmissionSummary(try response.body.json.data))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta feedback screenshot submission response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Beta feedback screenshot submission lookup did not return 200 ok."
      )
    }
  }

  public func getBetaCrashLog(
    _ input: AppStoreConnectBetaCrashLogViewInput
  ) async throws -> AppStoreConnectBetaCrashLogResult {
    let output = try await client.testFlight.getBetaCrashLog(id: input.id)

    switch output {
    case .ok(let response):
      return AppStoreConnectBetaCrashLogResult(
        data: Self.betaCrashLogSummary(try response.body.json.data))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta crash log response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Beta crash log lookup did not return 200 ok.")
    }
  }

  public func getCrashLogForBetaFeedbackCrashSubmission(
    _ input: AppStoreConnectBetaFeedbackCrashSubmissionCrashLogInput
  ) async throws -> AppStoreConnectBetaCrashLogResult {
    let output = try await client.testFlight.getCrashLogForBetaFeedbackCrashSubmission(id: input.id)

    switch output {
    case .ok(let response):
      return AppStoreConnectBetaCrashLogResult(
        data: Self.betaCrashLogSummary(try response.body.json.data))
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode,
        message: "Unexpected beta feedback crash submission crash log response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1,
        message: "Beta feedback crash submission crash log lookup did not return 200 ok.")
    }
  }

  public func getAppBetaTesterUsageMetrics(
    _ input: AppStoreConnectAppBetaTesterUsageMetricsInput
  ) async throws -> AppStoreConnectBetaTesterUsageMetricsResult {
    let output = try await client.testFlight.appsBetaTesterUsagesGetMetrics(
      id: input.appID,
      query: appBetaTesterUsageMetricsQuery(from: input)
    )

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectBetaTesterUsageMetricsResult(
        data: body.data.map {
          Self.appBetaTesterUsageMetricSeries($0, appID: input.appID, testerID: input.betaTesterID)
        },
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected app beta tester usage metrics response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "App beta tester usage metrics lookup did not return 200 ok.")
    }
  }

  public func getBetaGroupBetaTesterUsageMetrics(
    _ input: AppStoreConnectBetaGroupBetaTesterUsageMetricsInput
  ) async throws -> AppStoreConnectBetaTesterUsageMetricsResult {
    let output = try await client.testFlight.betaGroupsBetaTesterUsagesGetMetrics(
      id: input.groupID,
      query: betaGroupBetaTesterUsageMetricsQuery(from: input)
    )

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectBetaTesterUsageMetricsResult(
        data: body.data.map {
          Self.betaGroupBetaTesterUsageMetricSeries(
            $0, groupID: input.groupID, testerID: input.betaTesterID)
        },
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta group tester usage metrics response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Beta group tester usage metrics lookup did not return 200 ok.")
    }
  }

  public func getBetaTesterUsageMetrics(
    _ input: AppStoreConnectBetaTesterUsageMetricsInput
  ) async throws -> AppStoreConnectBetaTesterUsageMetricsResult {
    let output = try await client.testFlight.betaTestersBetaTesterUsagesGetMetrics(
      id: input.testerID,
      query: betaTesterUsageMetricsQuery(from: input)
    )

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectBetaTesterUsageMetricsResult(
        data: body.data.map {
          Self.betaTesterUsageMetricSeries($0, testerID: input.testerID, appID: input.appID)
        },
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta tester usage metrics response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Beta tester usage metrics lookup did not return 200 ok.")
    }
  }

  public func getBetaGroupPublicLinkUsageMetrics(
    _ input: AppStoreConnectBetaGroupPublicLinkUsageMetricsInput
  ) async throws -> AppStoreConnectBetaPublicLinkUsageMetricsResult {
    let output = try await client.testFlight.betaGroupsPublicLinkUsagesGetMetrics(
      id: input.groupID,
      query: .init(limit: input.limit)
    )

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectBetaPublicLinkUsageMetricsResult(
        data: body.data.map { Self.betaPublicLinkUsageMetricSeries($0, groupID: input.groupID) },
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta group public link usage metrics response."
      )
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1,
        message: "Beta group public link usage metrics lookup did not return 200 ok.")
    }
  }

  public func getBetaBuildUsageMetrics(
    _ input: AppStoreConnectBetaBuildUsageMetricsInput
  ) async throws -> AppStoreConnectBetaBuildUsageMetricsResult {
    let output = try await client.testFlight.buildsBetaBuildUsagesGetMetrics(
      id: input.buildID,
      query: .init(limit: input.limit)
    )

    switch output {
    case .ok(let response):
      let body = try response.body.json
      return AppStoreConnectBetaBuildUsageMetricsResult(
        data: body.data.map { Self.betaBuildUsageMetricSeries($0, buildID: input.buildID) },
        next: body.links.next
      )
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected beta build usage metrics response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "Beta build usage metrics lookup did not return 200 ok.")
    }
  }

  public func getStatus(_ input: AppStoreConnectStatusInput) async throws
    -> AppStoreConnectStatusResult
  {
    let app = try await getApp(.init(id: input.appID)).data
    let version = try await input.appStoreVersionID.asyncMap {
      try await fetchAppStoreVersion(id: $0)
    }
    let submissions: [AppStoreConnectReviewSubmissionSummary]

    if let reviewSubmissionID = input.reviewSubmissionID {
      submissions = [try await getReviewSubmission(.init(id: reviewSubmissionID)).data]
    } else {
      submissions = try await listReviewSubmissions(
        .init(
          appID: input.appID,
          platforms: input.platforms,
          states: input.reviewStates,
          limit: input.limit
        )
      ).data
    }

    let filteredSubmissions =
      input.appStoreVersionID.map { versionID in
        submissions.filter { submission in
          submission.appStoreVersionID == nil || submission.appStoreVersionID == versionID
        }
      } ?? submissions

    return AppStoreConnectStatusResult(
      app: app,
      appStoreVersion: version,
      reviewSubmissions: filteredSubmissions
    )
  }

  public func waitForBuild(_ input: AppStoreConnectBuildWaitInput) async throws
    -> AppStoreConnectBuildWaitResult
  {
    guard input.maxAttempts > 0 else {
      throw AppStoreConnectError.invalidConfiguration(
        "Build wait maxAttempts must be greater than zero.")
    }
    guard input.intervalSeconds.isFinite, input.intervalSeconds >= 0 else {
      throw AppStoreConnectError.invalidConfiguration(
        "Build wait intervalSeconds must be finite and greater than or equal to zero.")
    }

    let targetStates = normalizedStates(input.targetProcessingStates, fallback: ["VALID"])
    let failureStates = normalizedStates(
      input.failureProcessingStates, fallback: ["FAILED", "INVALID"])
    let sleepNanoseconds = UInt64(input.intervalSeconds * 1_000_000_000)
    var attempts: [AppStoreConnectBuildWaitAttempt] = []

    for attempt in 1...input.maxAttempts {
      let build = try await getBuild(input.build).data
      attempts.append(AppStoreConnectBuildWaitAttempt(attempt: attempt, build: build))

      let state = build.processingState?.uppercased()
      if state.map(targetStates.contains) == true {
        return AppStoreConnectBuildWaitResult(
          status: .succeeded,
          build: build,
          attempts: attempts,
          targetProcessingStates: targetStates,
          failureProcessingStates: failureStates
        )
      }
      if state.map(failureStates.contains) == true {
        return AppStoreConnectBuildWaitResult(
          status: .failed,
          build: build,
          attempts: attempts,
          targetProcessingStates: targetStates,
          failureProcessingStates: failureStates
        )
      }
      if attempt < input.maxAttempts, sleepNanoseconds > 0 {
        try await sleep(sleepNanoseconds)
      }
    }

    return AppStoreConnectBuildWaitResult(
      status: .timedOut,
      build: attempts[attempts.count - 1].build,
      attempts: attempts,
      targetProcessingStates: targetStates,
      failureProcessingStates: failureStates
    )
  }

  private func appListQuery(
    from input: AppStoreConnectAppListInput
  ) -> Operations.AppsGetCollection.Input.Query {
    var query = Operations.AppsGetCollection.Input.Query()
    query.filter_lbrack_id_rbrack_ = input.ids.nilIfEmpty
    query.filter_lbrack_name_rbrack_ = input.names.nilIfEmpty
    query.filter_lbrack_bundleId_rbrack_ = input.bundleIDs.nilIfEmpty
    query.filter_lbrack_sku_rbrack_ = input.skus.nilIfEmpty
    query.limit = input.limit
    if let sort = input.sort {
      query.sort =
        sort
        .split(separator: ",")
        .map(String.init)
        .compactMap(Operations.AppsGetCollection.Input.Query.SortPayloadPayload.init(rawValue:))
    }
    return query
  }

  #if ASC_PUBLIC_API_RELEASE
    private func appCategoryListQuery(
      from input: AppStoreConnectAppCategoryListInput
    ) -> Operations.AppCategoriesGetCollection.Input.Query {
      var query = Operations.AppCategoriesGetCollection.Input.Query()
      query.filter_lbrack_platforms_rbrack_ =
        input.platforms.compactMap {
          Operations.AppCategoriesGetCollection.Input.Query
            .FilterLbrackPlatformsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.exists_lbrack_parent_rbrack_ = input.existsParent
      query.include = appCategoryListIncludes(
        parent: input.includeParent,
        subcategories: input.includeSubcategories
      )
      query.limit = input.limit
      query.limit_lbrack_subcategories_rbrack_ = input.subcategoriesLimit
      return query
    }

    private func appCategoryViewQuery(
      from input: AppStoreConnectAppCategoryViewInput
    ) -> Operations.AppCategoriesGetInstance.Input.Query {
      var query = Operations.AppCategoriesGetInstance.Input.Query()
      query.include = appCategoryViewIncludes(
        parent: input.includeParent,
        subcategories: input.includeSubcategories
      )
      query.limit_lbrack_subcategories_rbrack_ = input.subcategoriesLimit
      return query
    }

    private func appCategoryParentQuery(
      from input: AppStoreConnectAppCategoryParentInput
    ) -> Operations.AppCategoriesParentGetToOneRelated.Input.Query {
      var query = Operations.AppCategoriesParentGetToOneRelated.Input.Query()
      query.fields_lbrack_appCategories_rbrack_ =
        input.fields.compactMap {
          Operations.AppCategoriesParentGetToOneRelated.Input.Query
            .FieldsLbrackAppCategoriesRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      return query
    }

    private func appCategorySubcategoriesQuery(
      from input: AppStoreConnectAppCategorySubcategoriesInput
    ) -> Operations.AppCategoriesSubcategoriesGetToManyRelated.Input.Query {
      var query = Operations.AppCategoriesSubcategoriesGetToManyRelated.Input.Query()
      query.fields_lbrack_appCategories_rbrack_ =
        input.fields.compactMap {
          Operations.AppCategoriesSubcategoriesGetToManyRelated.Input.Query
            .FieldsLbrackAppCategoriesRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.limit = input.limit
      return query
    }

    private func ageRatingViewQuery(
      from input: AppStoreConnectAgeRatingViewInput
    ) -> Operations.AppInfosAgeRatingDeclarationGetToOneRelated.Input.Query {
      var query = Operations.AppInfosAgeRatingDeclarationGetToOneRelated.Input.Query()
      query.fields_lbrack_ageRatingDeclarations_rbrack_ =
        input.fields.compactMap {
          Operations.AppInfosAgeRatingDeclarationGetToOneRelated.Input.Query
            .FieldsLbrackAgeRatingDeclarationsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      return query
    }

    private func appCategoryListIncludes(
      parent: Bool,
      subcategories: Bool
    ) -> Operations.AppCategoriesGetCollection.Input.Query.IncludePayload? {
      var include: Operations.AppCategoriesGetCollection.Input.Query.IncludePayload = []
      if parent {
        include.append(.parent)
      }
      if subcategories {
        include.append(.subcategories)
      }
      return include.nilIfEmpty
    }

    private func appCategoryViewIncludes(
      parent: Bool,
      subcategories: Bool
    ) -> Operations.AppCategoriesGetInstance.Input.Query.IncludePayload? {
      var include: Operations.AppCategoriesGetInstance.Input.Query.IncludePayload = []
      if parent {
        include.append(.parent)
      }
      if subcategories {
        include.append(.subcategories)
      }
      return include.nilIfEmpty
    }

    private func appEventListQuery(
      from input: AppStoreConnectAppEventListInput
    ) -> Operations.AppsAppEventsGetToManyRelated.Input.Query {
      var query = Operations.AppsAppEventsGetToManyRelated.Input.Query()
      query.filter_lbrack_id_rbrack_ = input.ids.nilIfEmpty
      query.filter_lbrack_eventState_rbrack_ =
        input.eventStates.compactMap {
          Operations.AppsAppEventsGetToManyRelated.Input.Query
            .FilterLbrackEventStateRbrackPayloadPayload(rawValue: $0.uppercased())
        }.nilIfEmpty
      query.fields_lbrack_appEvents_rbrack_ =
        input.fields.compactMap {
          Operations.AppsAppEventsGetToManyRelated.Input.Query
            .FieldsLbrackAppEventsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.fields_lbrack_appEventLocalizations_rbrack_ =
        input.localizationFields.compactMap {
          Operations.AppsAppEventsGetToManyRelated.Input.Query
            .FieldsLbrackAppEventLocalizationsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.include = input.includeLocalizations ? [.localizations] : nil
      query.limit = input.limit
      query.limit_lbrack_localizations_rbrack_ = input.localizationsLimit
      return query
    }

    private func appEventViewQuery(
      from input: AppStoreConnectAppEventViewInput
    ) -> Operations.AppEventsGetInstance.Input.Query {
      var query = Operations.AppEventsGetInstance.Input.Query()
      query.fields_lbrack_appEvents_rbrack_ =
        input.fields.compactMap {
          Operations.AppEventsGetInstance.Input.Query
            .FieldsLbrackAppEventsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.fields_lbrack_appEventLocalizations_rbrack_ =
        input.localizationFields.compactMap {
          Operations.AppEventsGetInstance.Input.Query
            .FieldsLbrackAppEventLocalizationsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.include = input.includeLocalizations ? [.localizations] : nil
      query.limit_lbrack_localizations_rbrack_ = input.localizationsLimit
      return query
    }
  #endif

  #if ASC_PUBLIC_API_METADATA_MEDIA
    private func appClipListQuery(
      from input: AppStoreConnectAppClipListInput
    ) -> Operations.AppsAppClipsGetToManyRelated.Input.Query {
      var query = Operations.AppsAppClipsGetToManyRelated.Input.Query()
      query.filter_lbrack_bundleId_rbrack_ = input.bundleIDs.nilIfEmpty
      query.fields_lbrack_appClips_rbrack_ =
        input.fields.compactMap {
          Operations.AppsAppClipsGetToManyRelated.Input.Query
            .FieldsLbrackAppClipsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.fields_lbrack_appClipDefaultExperiences_rbrack_ =
        input.defaultExperienceFields.compactMap {
          Operations.AppsAppClipsGetToManyRelated.Input.Query
            .FieldsLbrackAppClipDefaultExperiencesRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.include = appClipListIncludes(
        app: input.includeApp,
        defaultExperiences: input.includeDefaultExperiences
      )
      query.limit = input.limit
      query.limit_lbrack_appClipDefaultExperiences_rbrack_ = input.defaultExperiencesLimit
      return query
    }

    private func appClipViewQuery(
      from input: AppStoreConnectAppClipViewInput
    ) -> Operations.AppClipsGetInstance.Input.Query {
      var query = Operations.AppClipsGetInstance.Input.Query()
      query.fields_lbrack_appClips_rbrack_ =
        input.fields.compactMap {
          Operations.AppClipsGetInstance.Input.Query.FieldsLbrackAppClipsRbrackPayloadPayload(
            rawValue: $0)
        }.nilIfEmpty
      query.fields_lbrack_appClipDefaultExperiences_rbrack_ =
        input.defaultExperienceFields.compactMap {
          Operations.AppClipsGetInstance.Input.Query
            .FieldsLbrackAppClipDefaultExperiencesRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.include = appClipViewIncludes(
        app: input.includeApp,
        defaultExperiences: input.includeDefaultExperiences
      )
      query.limit_lbrack_appClipDefaultExperiences_rbrack_ = input.defaultExperiencesLimit
      return query
    }

    private func appClipDefaultExperienceListQuery(
      from input: AppStoreConnectAppClipDefaultExperienceListInput
    ) -> Operations.AppClipsAppClipDefaultExperiencesGetToManyRelated.Input.Query {
      var query = Operations.AppClipsAppClipDefaultExperiencesGetToManyRelated.Input.Query()
      query.exists_lbrack_releaseWithAppStoreVersion_rbrack_ = input.hasReleaseWithAppStoreVersion
      query.fields_lbrack_appClipDefaultExperiences_rbrack_ =
        input.fields.compactMap {
          Operations.AppClipsAppClipDefaultExperiencesGetToManyRelated.Input.Query
            .FieldsLbrackAppClipDefaultExperiencesRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.fields_lbrack_appClipDefaultExperienceLocalizations_rbrack_ =
        input.localizationFields.compactMap {
          Operations.AppClipsAppClipDefaultExperiencesGetToManyRelated.Input.Query
            .FieldsLbrackAppClipDefaultExperienceLocalizationsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.include = appClipDefaultExperienceListIncludes(
        appClip: input.includeAppClip,
        localizations: input.includeLocalizations,
        reviewDetail: input.includeReviewDetail
      )
      query.limit = input.limit
      query.limit_lbrack_appClipDefaultExperienceLocalizations_rbrack_ = input.localizationsLimit
      return query
    }

    private func appClipDefaultExperienceViewQuery(
      from input: AppStoreConnectAppClipDefaultExperienceViewInput
    ) -> Operations.AppClipDefaultExperiencesGetInstance.Input.Query {
      var query = Operations.AppClipDefaultExperiencesGetInstance.Input.Query()
      query.fields_lbrack_appClipDefaultExperiences_rbrack_ =
        input.fields.compactMap {
          Operations.AppClipDefaultExperiencesGetInstance.Input.Query
            .FieldsLbrackAppClipDefaultExperiencesRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.fields_lbrack_appClipDefaultExperienceLocalizations_rbrack_ =
        input.localizationFields.compactMap {
          Operations.AppClipDefaultExperiencesGetInstance.Input.Query
            .FieldsLbrackAppClipDefaultExperienceLocalizationsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.include = appClipDefaultExperienceViewIncludes(
        appClip: input.includeAppClip,
        localizations: input.includeLocalizations,
        reviewDetail: input.includeReviewDetail
      )
      query.limit_lbrack_appClipDefaultExperienceLocalizations_rbrack_ = input.localizationsLimit
      return query
    }

    private func appClipLocalizationListQuery(
      from input: AppStoreConnectAppClipLocalizationListInput
    )
      -> Operations.AppClipDefaultExperiencesAppClipDefaultExperienceLocalizationsGetToManyRelated
      .Input.Query
    {
      var query = Operations
        .AppClipDefaultExperiencesAppClipDefaultExperienceLocalizationsGetToManyRelated.Input
        .Query()
      query.filter_lbrack_locale_rbrack_ = input.locales.nilIfEmpty
      query.fields_lbrack_appClipDefaultExperienceLocalizations_rbrack_ =
        input.fields.compactMap {
          Operations.AppClipDefaultExperiencesAppClipDefaultExperienceLocalizationsGetToManyRelated
            .Input.Query
            .FieldsLbrackAppClipDefaultExperienceLocalizationsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.include = appClipLocalizationListIncludes(
        defaultExperience: input.includeDefaultExperience,
        headerImage: input.includeHeaderImage
      )
      query.limit = input.limit
      return query
    }

    private func appClipLocalizationViewQuery(
      from input: AppStoreConnectAppClipLocalizationViewInput
    ) -> Operations.AppClipDefaultExperienceLocalizationsGetInstance.Input.Query {
      var query = Operations.AppClipDefaultExperienceLocalizationsGetInstance.Input.Query()
      query.fields_lbrack_appClipDefaultExperienceLocalizations_rbrack_ =
        input.fields.compactMap {
          Operations.AppClipDefaultExperienceLocalizationsGetInstance.Input.Query
            .FieldsLbrackAppClipDefaultExperienceLocalizationsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.include = appClipLocalizationViewIncludes(
        defaultExperience: input.includeDefaultExperience,
        headerImage: input.includeHeaderImage
      )
      return query
    }

    private func appClipListIncludes(
      app: Bool,
      defaultExperiences: Bool
    ) -> Operations.AppsAppClipsGetToManyRelated.Input.Query.IncludePayload? {
      var include: Operations.AppsAppClipsGetToManyRelated.Input.Query.IncludePayload = []
      if app {
        include.append(.app)
      }
      if defaultExperiences {
        include.append(.appClipDefaultExperiences)
      }
      return include.nilIfEmpty
    }

    private func appClipViewIncludes(
      app: Bool,
      defaultExperiences: Bool
    ) -> Operations.AppClipsGetInstance.Input.Query.IncludePayload? {
      var include: Operations.AppClipsGetInstance.Input.Query.IncludePayload = []
      if app {
        include.append(.app)
      }
      if defaultExperiences {
        include.append(.appClipDefaultExperiences)
      }
      return include.nilIfEmpty
    }

    private func appClipDefaultExperienceListIncludes(
      appClip: Bool,
      localizations: Bool,
      reviewDetail: Bool
    ) -> Operations.AppClipsAppClipDefaultExperiencesGetToManyRelated.Input.Query.IncludePayload? {
      var include:
        Operations.AppClipsAppClipDefaultExperiencesGetToManyRelated.Input.Query.IncludePayload = []
      if appClip {
        include.append(.appClip)
      }
      if localizations {
        include.append(.appClipDefaultExperienceLocalizations)
      }
      if reviewDetail {
        include.append(.appClipAppStoreReviewDetail)
      }
      return include.nilIfEmpty
    }

    private func appClipDefaultExperienceViewIncludes(
      appClip: Bool,
      localizations: Bool,
      reviewDetail: Bool
    ) -> Operations.AppClipDefaultExperiencesGetInstance.Input.Query.IncludePayload? {
      var include: Operations.AppClipDefaultExperiencesGetInstance.Input.Query.IncludePayload = []
      if appClip {
        include.append(.appClip)
      }
      if localizations {
        include.append(.appClipDefaultExperienceLocalizations)
      }
      if reviewDetail {
        include.append(.appClipAppStoreReviewDetail)
      }
      return include.nilIfEmpty
    }

    private func appClipLocalizationListIncludes(
      defaultExperience: Bool,
      headerImage: Bool
    ) -> Operations.AppClipDefaultExperiencesAppClipDefaultExperienceLocalizationsGetToManyRelated
      .Input.Query.IncludePayload?
    {
      var include:
        Operations.AppClipDefaultExperiencesAppClipDefaultExperienceLocalizationsGetToManyRelated
          .Input.Query.IncludePayload = []
      if defaultExperience {
        include.append(.appClipDefaultExperience)
      }
      if headerImage {
        include.append(.appClipHeaderImage)
      }
      return include.nilIfEmpty
    }

    private func appClipLocalizationViewIncludes(
      defaultExperience: Bool,
      headerImage: Bool
    ) -> Operations.AppClipDefaultExperienceLocalizationsGetInstance.Input.Query.IncludePayload? {
      var include:
        Operations.AppClipDefaultExperienceLocalizationsGetInstance.Input.Query.IncludePayload = []
      if defaultExperience {
        include.append(.appClipDefaultExperience)
      }
      if headerImage {
        include.append(.appClipHeaderImage)
      }
      return include.nilIfEmpty
    }
  #endif

  #if ASC_PUBLIC_API_GAME_CENTER
    private func gameCenterDetailForAppQuery(
      from input: AppStoreConnectGameCenterDetailForAppInput
    ) -> Operations.AppsGameCenterDetailGetToOneRelated.Input.Query {
      var query = Operations.AppsGameCenterDetailGetToOneRelated.Input.Query()
      query.fields_lbrack_gameCenterDetails_rbrack_ =
        input.fields.compactMap {
          Operations.AppsGameCenterDetailGetToOneRelated.Input.Query
            .FieldsLbrackGameCenterDetailsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.include = gameCenterDetailForAppIncludes(from: input)
      query.limit_lbrack_gameCenterAchievementsV2_rbrack_ = input.relatedLimit
      query.limit_lbrack_gameCenterLeaderboardsV2_rbrack_ = input.relatedLimit
      query.limit_lbrack_gameCenterLeaderboardSetsV2_rbrack_ = input.relatedLimit
      query.limit_lbrack_gameCenterChallenges_rbrack_ = input.relatedLimit
      return query
    }

    private func gameCenterDetailViewQuery(
      from input: AppStoreConnectGameCenterDetailViewInput
    ) -> Operations.GameCenterDetailsGetInstance.Input.Query {
      var query = Operations.GameCenterDetailsGetInstance.Input.Query()
      query.fields_lbrack_gameCenterDetails_rbrack_ =
        input.fields.compactMap {
          Operations.GameCenterDetailsGetInstance.Input.Query
            .FieldsLbrackGameCenterDetailsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.include = gameCenterDetailViewIncludes(from: input)
      query.limit_lbrack_gameCenterAchievementsV2_rbrack_ = input.relatedLimit
      query.limit_lbrack_gameCenterLeaderboardsV2_rbrack_ = input.relatedLimit
      query.limit_lbrack_gameCenterLeaderboardSetsV2_rbrack_ = input.relatedLimit
      query.limit_lbrack_gameCenterChallenges_rbrack_ = input.relatedLimit
      return query
    }

    private func gameCenterAchievementListQuery(
      from input: AppStoreConnectGameCenterNamedResourceListInput
    ) -> Operations.GameCenterDetailsGameCenterAchievementsV2GetToManyRelated.Input.Query {
      var query = Operations.GameCenterDetailsGameCenterAchievementsV2GetToManyRelated.Input.Query()
      query.filter_lbrack_id_rbrack_ = input.ids.nilIfEmpty
      query.filter_lbrack_referenceName_rbrack_ = input.referenceNames.nilIfEmpty
      query.filter_lbrack_archived_rbrack_ = input.archived.map { [$0] }
      query.fields_lbrack_gameCenterAchievements_rbrack_ =
        input.fields.compactMap {
          Operations.GameCenterDetailsGameCenterAchievementsV2GetToManyRelated.Input.Query
            .FieldsLbrackGameCenterAchievementsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.limit = input.limit
      return query
    }

    private func gameCenterAchievementViewQuery(
      from input: AppStoreConnectGameCenterResourceViewInput
    ) -> Operations.GameCenterAchievementsV2GetInstance.Input.Query {
      var query = Operations.GameCenterAchievementsV2GetInstance.Input.Query()
      query.fields_lbrack_gameCenterAchievements_rbrack_ =
        input.fields.compactMap {
          Operations.GameCenterAchievementsV2GetInstance.Input.Query
            .FieldsLbrackGameCenterAchievementsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      return query
    }

    private func gameCenterLeaderboardListQuery(
      from input: AppStoreConnectGameCenterNamedResourceListInput
    ) -> Operations.GameCenterDetailsGameCenterLeaderboardsV2GetToManyRelated.Input.Query {
      var query = Operations.GameCenterDetailsGameCenterLeaderboardsV2GetToManyRelated.Input.Query()
      query.filter_lbrack_id_rbrack_ = input.ids.nilIfEmpty
      query.filter_lbrack_referenceName_rbrack_ = input.referenceNames.nilIfEmpty
      query.filter_lbrack_archived_rbrack_ = input.archived.map { [$0] }
      query.fields_lbrack_gameCenterLeaderboards_rbrack_ =
        input.fields.compactMap {
          Operations.GameCenterDetailsGameCenterLeaderboardsV2GetToManyRelated.Input.Query
            .FieldsLbrackGameCenterLeaderboardsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.limit = input.limit
      return query
    }

    private func gameCenterLeaderboardViewQuery(
      from input: AppStoreConnectGameCenterResourceViewInput
    ) -> Operations.GameCenterLeaderboardsV2GetInstance.Input.Query {
      var query = Operations.GameCenterLeaderboardsV2GetInstance.Input.Query()
      query.fields_lbrack_gameCenterLeaderboards_rbrack_ =
        input.fields.compactMap {
          Operations.GameCenterLeaderboardsV2GetInstance.Input.Query
            .FieldsLbrackGameCenterLeaderboardsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      return query
    }

    private func gameCenterLeaderboardSetListQuery(
      from input: AppStoreConnectGameCenterNamedResourceListInput
    ) -> Operations.GameCenterDetailsGameCenterLeaderboardSetsV2GetToManyRelated.Input.Query {
      var query = Operations.GameCenterDetailsGameCenterLeaderboardSetsV2GetToManyRelated.Input
        .Query()
      query.filter_lbrack_id_rbrack_ = input.ids.nilIfEmpty
      query.filter_lbrack_referenceName_rbrack_ = input.referenceNames.nilIfEmpty
      query.fields_lbrack_gameCenterLeaderboardSets_rbrack_ =
        input.fields.compactMap {
          Operations.GameCenterDetailsGameCenterLeaderboardSetsV2GetToManyRelated.Input.Query
            .FieldsLbrackGameCenterLeaderboardSetsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.limit = input.limit
      return query
    }

    private func gameCenterLeaderboardSetViewQuery(
      from input: AppStoreConnectGameCenterResourceViewInput
    ) -> Operations.GameCenterLeaderboardSetsV2GetInstance.Input.Query {
      var query = Operations.GameCenterLeaderboardSetsV2GetInstance.Input.Query()
      query.fields_lbrack_gameCenterLeaderboardSets_rbrack_ =
        input.fields.compactMap {
          Operations.GameCenterLeaderboardSetsV2GetInstance.Input.Query
            .FieldsLbrackGameCenterLeaderboardSetsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      return query
    }

    private func gameCenterChallengeListQuery(
      from input: AppStoreConnectGameCenterNamedResourceListInput
    ) -> Operations.GameCenterDetailsGameCenterChallengesGetToManyRelated.Input.Query {
      var query = Operations.GameCenterDetailsGameCenterChallengesGetToManyRelated.Input.Query()
      query.filter_lbrack_id_rbrack_ = input.ids.nilIfEmpty
      query.filter_lbrack_referenceName_rbrack_ = input.referenceNames.nilIfEmpty
      query.filter_lbrack_archived_rbrack_ = input.archived.map { [$0] }
      query.fields_lbrack_gameCenterChallenges_rbrack_ =
        input.fields.compactMap {
          Operations.GameCenterDetailsGameCenterChallengesGetToManyRelated.Input.Query
            .FieldsLbrackGameCenterChallengesRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.limit = input.limit
      return query
    }

    private func gameCenterChallengeViewQuery(
      from input: AppStoreConnectGameCenterResourceViewInput
    ) -> Operations.GameCenterChallengesGetInstance.Input.Query {
      var query = Operations.GameCenterChallengesGetInstance.Input.Query()
      query.fields_lbrack_gameCenterChallenges_rbrack_ =
        input.fields.compactMap {
          Operations.GameCenterChallengesGetInstance.Input.Query
            .FieldsLbrackGameCenterChallengesRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      return query
    }

    private func gameCenterDetailForAppIncludes(
      from input: AppStoreConnectGameCenterDetailForAppInput
    ) -> Operations.AppsGameCenterDetailGetToOneRelated.Input.Query.IncludePayload? {
      var include: Operations.AppsGameCenterDetailGetToOneRelated.Input.Query.IncludePayload = []
      if input.includeApp {
        include.append(.app)
      }
      if input.includeAchievements {
        include.append(.gameCenterAchievementsV2)
      }
      if input.includeLeaderboards {
        include.append(.gameCenterLeaderboardsV2)
      }
      if input.includeLeaderboardSets {
        include.append(.gameCenterLeaderboardSetsV2)
      }
      if input.includeChallenges {
        include.append(.gameCenterChallenges)
      }
      return include.nilIfEmpty
    }

    private func gameCenterDetailViewIncludes(
      from input: AppStoreConnectGameCenterDetailViewInput
    ) -> Operations.GameCenterDetailsGetInstance.Input.Query.IncludePayload? {
      var include: Operations.GameCenterDetailsGetInstance.Input.Query.IncludePayload = []
      if input.includeApp {
        include.append(.app)
      }
      if input.includeAchievements {
        include.append(.gameCenterAchievementsV2)
      }
      if input.includeLeaderboards {
        include.append(.gameCenterLeaderboardsV2)
      }
      if input.includeLeaderboardSets {
        include.append(.gameCenterLeaderboardSetsV2)
      }
      if input.includeChallenges {
        include.append(.gameCenterChallenges)
      }
      return include.nilIfEmpty
    }
  #endif

  #if ASC_PUBLIC_API_DISTRIBUTION
    private func alternativeDistributionDomainListQuery(
      from input: AppStoreConnectAlternativeDistributionDomainListInput
    ) -> Operations.AlternativeDistributionDomainsGetCollection.Input.Query {
      var query = Operations.AlternativeDistributionDomainsGetCollection.Input.Query()
      query.fields_lbrack_alternativeDistributionDomains_rbrack_ =
        input.fields.compactMap {
          Operations.AlternativeDistributionDomainsGetCollection.Input.Query
            .FieldsLbrackAlternativeDistributionDomainsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.limit = input.limit
      return query
    }

    private func alternativeDistributionDomainViewQuery(
      from input: AppStoreConnectAlternativeDistributionDomainViewInput
    ) -> Operations.AlternativeDistributionDomainsGetInstance.Input.Query {
      var query = Operations.AlternativeDistributionDomainsGetInstance.Input.Query()
      query.fields_lbrack_alternativeDistributionDomains_rbrack_ =
        input.fields.compactMap {
          Operations.AlternativeDistributionDomainsGetInstance.Input.Query
            .FieldsLbrackAlternativeDistributionDomainsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      return query
    }

    private func alternativeDistributionKeyListQuery(
      from input: AppStoreConnectAlternativeDistributionKeyListInput
    ) -> Operations.AlternativeDistributionKeysGetCollection.Input.Query {
      var query = Operations.AlternativeDistributionKeysGetCollection.Input.Query()
      query.exists_lbrack_app_rbrack_ = input.existsApp
      query.fields_lbrack_alternativeDistributionKeys_rbrack_ =
        input.fields.compactMap {
          Operations.AlternativeDistributionKeysGetCollection.Input.Query
            .FieldsLbrackAlternativeDistributionKeysRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.limit = input.limit
      return query
    }

    private func alternativeDistributionKeyViewQuery(
      from input: AppStoreConnectAlternativeDistributionKeyViewInput
    ) -> Operations.AlternativeDistributionKeysGetInstance.Input.Query {
      var query = Operations.AlternativeDistributionKeysGetInstance.Input.Query()
      query.fields_lbrack_alternativeDistributionKeys_rbrack_ =
        input.fields.compactMap {
          Operations.AlternativeDistributionKeysGetInstance.Input.Query
            .FieldsLbrackAlternativeDistributionKeysRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      return query
    }

    private func marketplaceWebhookListQuery(
      from input: AppStoreConnectMarketplaceWebhookListInput
    ) -> Operations.MarketplaceWebhooksGetCollection.Input.Query {
      var query = Operations.MarketplaceWebhooksGetCollection.Input.Query()
      query.fields_lbrack_marketplaceWebhooks_rbrack_ =
        input.fields.compactMap {
          Operations.MarketplaceWebhooksGetCollection.Input.Query
            .FieldsLbrackMarketplaceWebhooksRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.limit = input.limit
      return query
    }

    private func webhookListQuery(
      from input: AppStoreConnectWebhookListInput
    ) -> Operations.AppsWebhooksGetToManyRelated.Input.Query {
      var query = Operations.AppsWebhooksGetToManyRelated.Input.Query()
      query.fields_lbrack_webhooks_rbrack_ =
        input.fields.compactMap {
          Operations.AppsWebhooksGetToManyRelated.Input.Query
            .FieldsLbrackWebhooksRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.include = input.includeApp ? [.app] : nil
      query.limit = input.limit
      return query
    }

    private func webhookViewQuery(
      from input: AppStoreConnectWebhookViewInput
    ) -> Operations.WebhooksGetInstance.Input.Query {
      var query = Operations.WebhooksGetInstance.Input.Query()
      query.fields_lbrack_webhooks_rbrack_ =
        input.fields.compactMap {
          Operations.WebhooksGetInstance.Input.Query
            .FieldsLbrackWebhooksRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.include = input.includeApp ? [.app] : nil
      return query
    }

    private func webhookDeliveryListQuery(
      from input: AppStoreConnectWebhookDeliveryListInput
    ) -> Operations.WebhooksDeliveriesGetToManyRelated.Input.Query {
      var query = Operations.WebhooksDeliveriesGetToManyRelated.Input.Query()
      query.filter_lbrack_deliveryState_rbrack_ =
        input.states.compactMap {
          Operations.WebhooksDeliveriesGetToManyRelated.Input.Query
            .FilterLbrackDeliveryStateRbrackPayloadPayload(rawValue: $0.uppercased())
        }.nilIfEmpty
      query.filter_lbrack_createdDateGreaterThanOrEqualTo_rbrack_ =
        input.createdDateGreaterThanOrEqualTo.nilIfEmpty
      query.filter_lbrack_createdDateLessThan_rbrack_ = input.createdDateLessThan.nilIfEmpty
      query.fields_lbrack_webhookDeliveries_rbrack_ =
        input.fields.compactMap {
          Operations.WebhooksDeliveriesGetToManyRelated.Input.Query
            .FieldsLbrackWebhookDeliveriesRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.fields_lbrack_webhookEvents_rbrack_ =
        input.eventFields.compactMap {
          Operations.WebhooksDeliveriesGetToManyRelated.Input.Query
            .FieldsLbrackWebhookEventsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.include = input.includeEvent ? [.event] : nil
      query.limit = input.limit
      return query
    }

    private func webhookDeliveryLinkageListQuery(
      from input: AppStoreConnectWebhookDeliveryLinkageListInput
    ) -> Operations.WebhooksDeliveriesGetToManyRelationship.Input.Query {
      Operations.WebhooksDeliveriesGetToManyRelationship.Input.Query(limit: input.limit)
    }

    private func eulaViewQuery(
      from input: AppStoreConnectEULAViewInput
    ) -> Operations.EndUserLicenseAgreementsGetInstance.Input.Query {
      var query = Operations.EndUserLicenseAgreementsGetInstance.Input.Query()
      query.fields_lbrack_endUserLicenseAgreements_rbrack_ =
        input.fields.compactMap {
          Operations.EndUserLicenseAgreementsGetInstance.Input.Query
            .FieldsLbrackEndUserLicenseAgreementsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.include = eulaViewIncludes(
        app: input.includeApp,
        territories: input.includeTerritories
      )
      query.limit_lbrack_territories_rbrack_ = input.territoriesLimit
      return query
    }

    private func eulaViewIncludes(
      app: Bool,
      territories: Bool
    ) -> Operations.EndUserLicenseAgreementsGetInstance.Input.Query.IncludePayload? {
      var include: Operations.EndUserLicenseAgreementsGetInstance.Input.Query.IncludePayload = []
      if app {
        include.append(.app)
      }
      if territories {
        include.append(.territories)
      }
      return include.nilIfEmpty
    }

    private func territoryListQuery(
      from input: AppStoreConnectTerritoryListInput
    ) -> Operations.TerritoriesGetCollection.Input.Query {
      var query = Operations.TerritoriesGetCollection.Input.Query()
      query.fields_lbrack_territories_rbrack_ =
        input.fields.compactMap {
          Operations.TerritoriesGetCollection.Input.Query
            .FieldsLbrackTerritoriesRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.limit = input.limit
      return query
    }
  #endif

  private func buildListQuery(
    from input: AppStoreConnectBuildListInput
  ) -> Operations.BuildsGetCollection.Input.Query {
    var query = Operations.BuildsGetCollection.Input.Query()
    query.filter_lbrack_app_rbrack_ = input.appID.map { [$0] }
    query.filter_lbrack_id_rbrack_ = input.buildIDs.nilIfEmpty
    query.filter_lbrack_version_rbrack_ = input.buildNumbers.nilIfEmpty
    query.filter_lbrack_preReleaseVersion_version_rbrack_ = input.versions.nilIfEmpty
    query.limit = input.limit
    if !input.platforms.isEmpty {
      query.filter_lbrack_preReleaseVersion_platform_rbrack_ = input.platforms.compactMap {
        Operations.BuildsGetCollection.Input.Query
          .FilterLbrackPreReleaseVersionPlatformRbrackPayloadPayload(
            rawValue: $0
          )
      }
    }
    if !input.processingStates.isEmpty {
      query.filter_lbrack_processingState_rbrack_ = input.processingStates.compactMap {
        Operations.BuildsGetCollection.Input.Query.FilterLbrackProcessingStateRbrackPayloadPayload(
          rawValue: $0
        )
      }
    }
    if let sort = input.sort {
      query.sort =
        sort
        .split(separator: ",")
        .map(String.init)
        .compactMap(Operations.BuildsGetCollection.Input.Query.SortPayloadPayload.init(rawValue:))
    }
    return query
  }

  private func buildBetaDetailListQuery(
    from input: AppStoreConnectBuildBetaDetailListInput
  ) -> Operations.BuildBetaDetailsGetCollection.Input.Query {
    var query = Operations.BuildBetaDetailsGetCollection.Input.Query()
    query.filter_lbrack_id_rbrack_ = input.ids.nilIfEmpty
    query.filter_lbrack_build_rbrack_ = input.buildIDs.nilIfEmpty
    query.include = [.build]
    query.limit = input.limit
    return query
  }

  private func preReleaseVersionListQuery(
    from input: AppStoreConnectPreReleaseVersionListInput
  ) -> Operations.PreReleaseVersionsGetCollection.Input.Query {
    var query = Operations.PreReleaseVersionsGetCollection.Input.Query()
    query.filter_lbrack_app_rbrack_ = input.appIDs.nilIfEmpty
    query.filter_lbrack_builds_rbrack_ = input.buildIDs.nilIfEmpty
    query.filter_lbrack_version_rbrack_ = input.versions.nilIfEmpty
    query.filter_lbrack_builds_version_rbrack_ = input.buildVersions.nilIfEmpty
    query.filter_lbrack_builds_expired_rbrack_ = input.buildExpired.map { [$0] }
    query.filter_lbrack_platform_rbrack_ =
      input.platforms.compactMap {
        Operations.PreReleaseVersionsGetCollection.Input.Query
          .FilterLbrackPlatformRbrackPayloadPayload(rawValue: $0)
      }.nilIfEmpty
    query.filter_lbrack_builds_buildAudienceType_rbrack_ =
      input.buildAudienceTypes.compactMap {
        Operations.PreReleaseVersionsGetCollection.Input.Query
          .FilterLbrackBuildsBuildAudienceTypeRbrackPayloadPayload(rawValue: $0)
      }.nilIfEmpty
    query.filter_lbrack_builds_processingState_rbrack_ =
      input.processingStates.compactMap {
        Operations.PreReleaseVersionsGetCollection.Input.Query
          .FilterLbrackBuildsProcessingStateRbrackPayloadPayload(rawValue: $0)
      }.nilIfEmpty
    query.include = [.app, .builds]
    query.limit = input.limit
    if let sort = input.sort {
      query.sort =
        sort
        .split(separator: ",")
        .map(String.init)
        .compactMap(
          Operations.PreReleaseVersionsGetCollection.Input.Query.SortPayloadPayload.init(rawValue:)
        )
        .nilIfEmpty
    }
    return query
  }

  private func reviewSubmissionListQuery(
    from input: AppStoreConnectReviewSubmissionListInput
  ) -> Operations.ReviewSubmissionsGetCollection.Input.Query {
    var query = Operations.ReviewSubmissionsGetCollection.Input.Query(
      filter_lbrack_app_rbrack_: [input.appID]
    )
    query.filter_lbrack_platform_rbrack_ =
      input.platforms.compactMap {
        Operations.ReviewSubmissionsGetCollection.Input.Query
          .FilterLbrackPlatformRbrackPayloadPayload(
            rawValue: $0
          )
      }.nilIfEmpty
    query.filter_lbrack_state_rbrack_ =
      input.states.compactMap {
        Operations.ReviewSubmissionsGetCollection.Input.Query.FilterLbrackStateRbrackPayloadPayload(
          rawValue: $0
        )
      }.nilIfEmpty
    query.include = [.app, .appStoreVersionForReview]
    query.limit = input.limit
    return query
  }

  #if ASC_PUBLIC_API_RELEASE
    private func appCustomerReviewListQuery(
      from input: AppStoreConnectCustomerReviewListInput
    ) -> Operations.AppsCustomerReviewsGetToManyRelated.Input.Query {
      var query = Operations.AppsCustomerReviewsGetToManyRelated.Input.Query()
      query.filter_lbrack_territory_rbrack_ =
        input.territories.compactMap {
          Operations.AppsCustomerReviewsGetToManyRelated.Input.Query
            .FilterLbrackTerritoryRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.filter_lbrack_rating_rbrack_ = input.ratings.nilIfEmpty
      query.exists_lbrack_publishedResponse_rbrack_ = input.responseExists
      query.sort =
        input.sort.compactMap {
          Operations.AppsCustomerReviewsGetToManyRelated.Input.Query.SortPayloadPayload(
            rawValue: $0)
        }.nilIfEmpty
      query.include = input.includeResponse ? [.response] : nil
      query.limit = input.limit
      return query
    }

    private func appStoreVersionCustomerReviewListQuery(
      from input: AppStoreConnectCustomerReviewListInput
    ) -> Operations.AppStoreVersionsCustomerReviewsGetToManyRelated.Input.Query {
      var query = Operations.AppStoreVersionsCustomerReviewsGetToManyRelated.Input.Query()
      query.filter_lbrack_territory_rbrack_ =
        input.territories.compactMap {
          Operations.AppStoreVersionsCustomerReviewsGetToManyRelated.Input.Query
            .FilterLbrackTerritoryRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
      query.filter_lbrack_rating_rbrack_ = input.ratings.nilIfEmpty
      query.exists_lbrack_publishedResponse_rbrack_ = input.responseExists
      query.sort =
        input.sort.compactMap {
          Operations.AppStoreVersionsCustomerReviewsGetToManyRelated.Input.Query.SortPayloadPayload(
            rawValue: $0)
        }.nilIfEmpty
      query.include = input.includeResponse ? [.response] : nil
      query.limit = input.limit
      return query
    }

    private func customerReviewViewQuery(
      from input: AppStoreConnectCustomerReviewViewInput
    ) -> Operations.CustomerReviewsGetInstance.Input.Query {
      var query = Operations.CustomerReviewsGetInstance.Input.Query()
      query.include = input.includeResponse ? [.response] : nil
      return query
    }

    private func customerReviewSummarizationListQuery(
      from input: AppStoreConnectCustomerReviewSummarizationListInput
    ) -> Operations.AppsCustomerReviewSummarizationsGetToManyRelated.Input.Query {
      Operations.AppsCustomerReviewSummarizationsGetToManyRelated.Input.Query(
        filter_lbrack_platform_rbrack_: input.platforms.compactMap {
          Operations.AppsCustomerReviewSummarizationsGetToManyRelated.Input.Query
            .FilterLbrackPlatformRbrackPayloadPayload(rawValue: $0)
        },
        filter_lbrack_territory_rbrack_: input.territories.nilIfEmpty,
        limit: input.limit,
        include: input.includeTerritory ? [.territory] : nil
      )
    }
  #endif

  private func appStoreVersionListQuery(
    from input: AppStoreConnectAppStoreVersionListInput
  ) -> Operations.AppsAppStoreVersionsGetToManyRelated.Input.Query {
    var query = Operations.AppsAppStoreVersionsGetToManyRelated.Input.Query()
    query.filter_lbrack_id_rbrack_ = input.ids.nilIfEmpty
    query.filter_lbrack_versionString_rbrack_ = input.versionStrings.nilIfEmpty
    query.filter_lbrack_platform_rbrack_ =
      input.platforms.compactMap {
        Operations.AppsAppStoreVersionsGetToManyRelated.Input.Query
          .FilterLbrackPlatformRbrackPayloadPayload(
            rawValue: $0
          )
      }.nilIfEmpty
    query.filter_lbrack_appVersionState_rbrack_ =
      input.appVersionStates.compactMap {
        Operations.AppsAppStoreVersionsGetToManyRelated.Input.Query
          .FilterLbrackAppVersionStateRbrackPayloadPayload(
            rawValue: $0
          )
      }.nilIfEmpty
    query.limit = input.limit
    return query
  }

  private func betaAppLocalizationListQuery(
    from input: AppStoreConnectBetaAppLocalizationListInput
  ) -> Operations.BetaAppLocalizationsGetCollection.Input.Query {
    var query = Operations.BetaAppLocalizationsGetCollection.Input.Query()
    query.filter_lbrack_app_rbrack_ = input.appIDs.nilIfEmpty
    query.filter_lbrack_locale_rbrack_ = input.locales.nilIfEmpty
    query.include = [.app]
    query.limit = input.limit
    return query
  }

  private func betaBuildLocalizationListQuery(
    from input: AppStoreConnectBetaBuildLocalizationListInput
  ) -> Operations.BetaBuildLocalizationsGetCollection.Input.Query {
    var query = Operations.BetaBuildLocalizationsGetCollection.Input.Query()
    query.filter_lbrack_build_rbrack_ = input.buildIDs.nilIfEmpty
    query.filter_lbrack_locale_rbrack_ = input.locales.nilIfEmpty
    query.include = [.build]
    query.limit = input.limit
    return query
  }

  private func betaAppReviewDetailListQuery(
    from input: AppStoreConnectBetaAppReviewDetailListInput
  ) -> Operations.BetaAppReviewDetailsGetCollection.Input.Query {
    Operations.BetaAppReviewDetailsGetCollection.Input.Query(
      filter_lbrack_app_rbrack_: [input.appID],
      limit: input.limit,
      include: [.app]
    )
  }

  private func betaAppReviewSubmissionListQuery(
    from input: AppStoreConnectBetaAppReviewSubmissionListInput
  ) -> Operations.BetaAppReviewSubmissionsGetCollection.Input.Query {
    Operations.BetaAppReviewSubmissionsGetCollection.Input.Query(
      filter_lbrack_betaReviewState_rbrack_: input.betaReviewStates.compactMap {
        Operations.BetaAppReviewSubmissionsGetCollection.Input.Query
          .FilterLbrackBetaReviewStateRbrackPayloadPayload(rawValue: $0)
      }.nilIfEmpty,
      filter_lbrack_build_rbrack_: input.buildIDs,
      limit: input.limit,
      include: [.build]
    )
  }

  private func betaLicenseAgreementListQuery(
    from input: AppStoreConnectBetaLicenseAgreementListInput
  ) -> Operations.BetaLicenseAgreementsGetCollection.Input.Query {
    var query = Operations.BetaLicenseAgreementsGetCollection.Input.Query()
    query.filter_lbrack_app_rbrack_ = input.appIDs.nilIfEmpty
    query.include = [.app]
    query.limit = input.limit
    return query
  }

  private func betaFeedbackCrashSubmissionListQuery(
    from input: AppStoreConnectBetaFeedbackCrashSubmissionListInput
  ) -> Operations.AppsBetaFeedbackCrashSubmissionsGetToManyRelated.Input.Query {
    var query = Operations.AppsBetaFeedbackCrashSubmissionsGetToManyRelated.Input.Query()
    query.filter_lbrack_deviceModel_rbrack_ = input.deviceModels.nilIfEmpty
    query.filter_lbrack_osVersion_rbrack_ = input.osVersions.nilIfEmpty
    query.filter_lbrack_appPlatform_rbrack_ =
      input.appPlatforms.compactMap {
        Operations.AppsBetaFeedbackCrashSubmissionsGetToManyRelated.Input.Query
          .FilterLbrackAppPlatformRbrackPayloadPayload(rawValue: $0)
      }.nilIfEmpty
    query.filter_lbrack_devicePlatform_rbrack_ =
      input.devicePlatforms.compactMap {
        Operations.AppsBetaFeedbackCrashSubmissionsGetToManyRelated.Input.Query
          .FilterLbrackDevicePlatformRbrackPayloadPayload(rawValue: $0)
      }.nilIfEmpty
    query.filter_lbrack_build_rbrack_ = input.buildIDs.nilIfEmpty
    query.filter_lbrack_build_preReleaseVersion_rbrack_ = input.preReleaseVersionIDs.nilIfEmpty
    query.filter_lbrack_tester_rbrack_ = input.testerIDs.nilIfEmpty
    query.limit = input.limit
    query.include = [.build, .tester]
    if let sort = input.sort {
      query.sort =
        sort
        .split(separator: ",")
        .map(String.init)
        .compactMap(
          Operations.AppsBetaFeedbackCrashSubmissionsGetToManyRelated.Input.Query.SortPayloadPayload
            .init(rawValue:)
        )
        .nilIfEmpty
    }
    return query
  }

  private func betaFeedbackScreenshotSubmissionListQuery(
    from input: AppStoreConnectBetaFeedbackScreenshotSubmissionListInput
  ) -> Operations.AppsBetaFeedbackScreenshotSubmissionsGetToManyRelated.Input.Query {
    var query = Operations.AppsBetaFeedbackScreenshotSubmissionsGetToManyRelated.Input.Query()
    query.filter_lbrack_deviceModel_rbrack_ = input.deviceModels.nilIfEmpty
    query.filter_lbrack_osVersion_rbrack_ = input.osVersions.nilIfEmpty
    query.filter_lbrack_appPlatform_rbrack_ =
      input.appPlatforms.compactMap {
        Operations.AppsBetaFeedbackScreenshotSubmissionsGetToManyRelated.Input.Query
          .FilterLbrackAppPlatformRbrackPayloadPayload(rawValue: $0)
      }.nilIfEmpty
    query.filter_lbrack_devicePlatform_rbrack_ =
      input.devicePlatforms.compactMap {
        Operations.AppsBetaFeedbackScreenshotSubmissionsGetToManyRelated.Input.Query
          .FilterLbrackDevicePlatformRbrackPayloadPayload(rawValue: $0)
      }.nilIfEmpty
    query.filter_lbrack_build_rbrack_ = input.buildIDs.nilIfEmpty
    query.filter_lbrack_build_preReleaseVersion_rbrack_ = input.preReleaseVersionIDs.nilIfEmpty
    query.filter_lbrack_tester_rbrack_ = input.testerIDs.nilIfEmpty
    query.limit = input.limit
    query.include = [.build, .tester]
    if let sort = input.sort {
      query.sort =
        sort
        .split(separator: ",")
        .map(String.init)
        .compactMap(
          Operations.AppsBetaFeedbackScreenshotSubmissionsGetToManyRelated.Input.Query
            .SortPayloadPayload.init(rawValue:)
        )
        .nilIfEmpty
    }
    return query
  }

  private func appBetaTesterUsageMetricsQuery(
    from input: AppStoreConnectAppBetaTesterUsageMetricsInput
  ) -> Operations.AppsBetaTesterUsagesGetMetrics.Input.Query {
    Operations.AppsBetaTesterUsagesGetMetrics.Input.Query(
      period: input.period
        .map { $0.uppercased() }
        .flatMap(
          Operations.AppsBetaTesterUsagesGetMetrics.Input.Query.PeriodPayload.init(rawValue:)),
      groupBy: input.groupByBetaTesters ? [.betaTesters] : nil,
      filter_lbrack_betaTesters_rbrack_: input.betaTesterID,
      limit: input.limit
    )
  }

  private func betaGroupBetaTesterUsageMetricsQuery(
    from input: AppStoreConnectBetaGroupBetaTesterUsageMetricsInput
  ) -> Operations.BetaGroupsBetaTesterUsagesGetMetrics.Input.Query {
    Operations.BetaGroupsBetaTesterUsagesGetMetrics.Input.Query(
      period: input.period
        .map { $0.uppercased() }
        .flatMap(
          Operations.BetaGroupsBetaTesterUsagesGetMetrics.Input.Query.PeriodPayload.init(rawValue:)),
      groupBy: input.groupByBetaTesters ? [.betaTesters] : nil,
      filter_lbrack_betaTesters_rbrack_: input.betaTesterID,
      limit: input.limit
    )
  }

  private func betaTesterUsageMetricsQuery(
    from input: AppStoreConnectBetaTesterUsageMetricsInput
  ) -> Operations.BetaTestersBetaTesterUsagesGetMetrics.Input.Query {
    Operations.BetaTestersBetaTesterUsagesGetMetrics.Input.Query(
      period: input.period
        .map { $0.uppercased() }
        .flatMap(
          Operations.BetaTestersBetaTesterUsagesGetMetrics.Input.Query.PeriodPayload.init(rawValue:)
        ),
      filter_lbrack_apps_rbrack_: input.appID,
      limit: input.limit
    )
  }

  private func betaGroupListQuery(
    from input: AppStoreConnectBetaGroupListInput
  ) -> Operations.BetaGroupsGetCollection.Input.Query {
    var query = Operations.BetaGroupsGetCollection.Input.Query()
    query.filter_lbrack_app_rbrack_ = input.appID.map { [$0] }
    query.filter_lbrack_id_rbrack_ = input.ids.nilIfEmpty
    query.filter_lbrack_name_rbrack_ = input.names.nilIfEmpty
    query.filter_lbrack_builds_rbrack_ = input.buildIDs.nilIfEmpty
    query.filter_lbrack_isInternalGroup_rbrack_ = input.isInternalGroup.map { [$0] }
    query.filter_lbrack_publicLinkEnabled_rbrack_ = input.publicLinkEnabled.map { [$0] }
    query.filter_lbrack_publicLinkLimitEnabled_rbrack_ = input.publicLinkLimitEnabled.map { [$0] }
    query.filter_lbrack_publicLink_rbrack_ = input.publicLink.map { [$0] }
    query.limit = input.limit
    if let sort = input.sort {
      query.sort =
        sort
        .split(separator: ",")
        .map(String.init)
        .compactMap(
          Operations.BetaGroupsGetCollection.Input.Query.SortPayloadPayload.init(rawValue:))
    }
    return query
  }

  private func betaTesterListQuery(
    from input: AppStoreConnectBetaTesterListInput
  ) -> Operations.BetaTestersGetCollection.Input.Query {
    var query = Operations.BetaTestersGetCollection.Input.Query()
    query.filter_lbrack_id_rbrack_ = input.ids.nilIfEmpty
    query.filter_lbrack_apps_rbrack_ = input.appIDs.nilIfEmpty
    query.filter_lbrack_betaGroups_rbrack_ = input.betaGroupIDs.nilIfEmpty
    query.filter_lbrack_builds_rbrack_ = input.buildIDs.nilIfEmpty
    query.filter_lbrack_email_rbrack_ = input.emails.nilIfEmpty
    query.filter_lbrack_firstName_rbrack_ = input.firstNames.nilIfEmpty
    query.filter_lbrack_lastName_rbrack_ = input.lastNames.nilIfEmpty
    query.filter_lbrack_inviteType_rbrack_ =
      input.inviteTypes.compactMap {
        Operations.BetaTestersGetCollection.Input.Query.FilterLbrackInviteTypeRbrackPayloadPayload(
          rawValue: $0
        )
      }.nilIfEmpty
    query.limit = input.limit
    if let sort = input.sort {
      query.sort =
        sort
        .split(separator: ",")
        .map(String.init)
        .compactMap(
          Operations.BetaTestersGetCollection.Input.Query.SortPayloadPayload.init(rawValue:))
    }
    return query
  }

  private func bundleIDListQuery(
    from input: AppStoreConnectBundleIDListInput
  ) -> Operations.BundleIdsGetCollection.Input.Query {
    var query = Operations.BundleIdsGetCollection.Input.Query()
    query.filter_lbrack_id_rbrack_ = input.ids.nilIfEmpty
    query.filter_lbrack_name_rbrack_ = input.names.nilIfEmpty
    query.filter_lbrack_identifier_rbrack_ = input.identifiers.nilIfEmpty
    query.filter_lbrack_seedId_rbrack_ = input.seedIDs.nilIfEmpty
    query.filter_lbrack_platform_rbrack_ =
      input.platforms.compactMap {
        Operations.BundleIdsGetCollection.Input.Query.FilterLbrackPlatformRbrackPayloadPayload(
          rawValue: $0)
      }.nilIfEmpty
    query.limit = input.limit
    if let sort = input.sort {
      query.sort =
        sort
        .split(separator: ",")
        .map(String.init)
        .compactMap(
          Operations.BundleIdsGetCollection.Input.Query.SortPayloadPayload.init(rawValue:)
        )
        .nilIfEmpty
    }
    return query
  }

  private func bundleIDCapabilityListQuery(
    from input: AppStoreConnectBundleIDCapabilityListInput
  ) -> Operations.BundleIdsBundleIdCapabilitiesGetToManyRelated.Input.Query {
    Operations.BundleIdsBundleIdCapabilitiesGetToManyRelated.Input.Query(
      fields_lbrack_bundleIdCapabilities_rbrack_: input.fields.compactMap {
        Operations.BundleIdsBundleIdCapabilitiesGetToManyRelated.Input.Query
          .FieldsLbrackBundleIdCapabilitiesRbrackPayloadPayload(rawValue: $0)
      }.nilIfEmpty,
      limit: input.limit
    )
  }

  private func certificateListQuery(
    from input: AppStoreConnectCertificateListInput
  ) -> Operations.CertificatesGetCollection.Input.Query {
    var query = Operations.CertificatesGetCollection.Input.Query()
    query.filter_lbrack_id_rbrack_ = input.ids.nilIfEmpty
    query.filter_lbrack_displayName_rbrack_ = input.displayNames.nilIfEmpty
    query.filter_lbrack_serialNumber_rbrack_ = input.serialNumbers.nilIfEmpty
    query.filter_lbrack_certificateType_rbrack_ =
      input.certificateTypes.compactMap {
        Operations.CertificatesGetCollection.Input.Query
          .FilterLbrackCertificateTypeRbrackPayloadPayload(rawValue: $0)
      }.nilIfEmpty
    query.limit = input.limit
    if let sort = input.sort {
      query.sort =
        sort
        .split(separator: ",")
        .map(String.init)
        .compactMap(
          Operations.CertificatesGetCollection.Input.Query.SortPayloadPayload.init(rawValue:)
        )
        .nilIfEmpty
    }
    return query
  }

  private func deviceListQuery(
    from input: AppStoreConnectDeviceListInput
  ) -> Operations.DevicesGetCollection.Input.Query {
    var query = Operations.DevicesGetCollection.Input.Query()
    query.filter_lbrack_id_rbrack_ = input.ids.nilIfEmpty
    query.filter_lbrack_name_rbrack_ = input.names.nilIfEmpty
    query.filter_lbrack_udid_rbrack_ = input.udids.nilIfEmpty
    query.filter_lbrack_platform_rbrack_ =
      input.platforms.compactMap {
        Operations.DevicesGetCollection.Input.Query.FilterLbrackPlatformRbrackPayloadPayload(
          rawValue: $0)
      }.nilIfEmpty
    query.filter_lbrack_status_rbrack_ =
      input.statuses.compactMap {
        Operations.DevicesGetCollection.Input.Query.FilterLbrackStatusRbrackPayloadPayload(
          rawValue: $0)
      }.nilIfEmpty
    query.limit = input.limit
    if let sort = input.sort {
      query.sort =
        sort
        .split(separator: ",")
        .map(String.init)
        .compactMap(Operations.DevicesGetCollection.Input.Query.SortPayloadPayload.init(rawValue:))
        .nilIfEmpty
    }
    return query
  }

  private func profileListQuery(
    from input: AppStoreConnectProfileListInput
  ) -> Operations.ProfilesGetCollection.Input.Query {
    var query = Operations.ProfilesGetCollection.Input.Query()
    query.filter_lbrack_id_rbrack_ = input.ids.nilIfEmpty
    query.filter_lbrack_name_rbrack_ = input.names.nilIfEmpty
    query.filter_lbrack_profileType_rbrack_ =
      input.profileTypes.compactMap {
        Operations.ProfilesGetCollection.Input.Query.FilterLbrackProfileTypeRbrackPayloadPayload(
          rawValue: $0)
      }.nilIfEmpty
    query.filter_lbrack_profileState_rbrack_ =
      input.profileStates.compactMap {
        Operations.ProfilesGetCollection.Input.Query.FilterLbrackProfileStateRbrackPayloadPayload(
          rawValue: $0)
      }.nilIfEmpty
    query.limit = input.limit
    if let sort = input.sort {
      query.sort =
        sort
        .split(separator: ",")
        .map(String.init)
        .compactMap(Operations.ProfilesGetCollection.Input.Query.SortPayloadPayload.init(rawValue:))
        .nilIfEmpty
    }
    return query
  }

  private func userListQuery(
    from input: AppStoreConnectUserListInput
  ) -> Operations.UsersGetCollection.Input.Query {
    var query = Operations.UsersGetCollection.Input.Query()
    query.filter_lbrack_username_rbrack_ = input.usernames.nilIfEmpty
    query.filter_lbrack_visibleApps_rbrack_ = input.visibleAppIDs.nilIfEmpty
    query.filter_lbrack_roles_rbrack_ =
      input.roles.compactMap {
        Operations.UsersGetCollection.Input.Query.FilterLbrackRolesRbrackPayloadPayload(
          rawValue: $0)
      }.nilIfEmpty
    query.limit = input.limit
    query.include = [.visibleApps]
    if let sort = input.sort {
      query.sort =
        sort
        .split(separator: ",")
        .map(String.init)
        .compactMap(Operations.UsersGetCollection.Input.Query.SortPayloadPayload.init(rawValue:))
        .nilIfEmpty
    }
    return query
  }

  #if ASC_PUBLIC_API_SIGNING_ACCESS
    private func actorListQuery(
      from input: AppStoreConnectActorListInput
    ) -> Operations.ActorsGetCollection.Input.Query {
      Operations.ActorsGetCollection.Input.Query(
        filter_lbrack_id_rbrack_: input.ids,
        fields_lbrack_actors_rbrack_: actorListFields(input.fields),
        limit: input.limit
      )
    }

    private func actorViewQuery(
      from input: AppStoreConnectActorViewInput
    ) -> Operations.ActorsGetInstance.Input.Query {
      Operations.ActorsGetInstance.Input.Query(
        fields_lbrack_actors_rbrack_: actorViewFields(input.fields)
      )
    }

    private func actorListFields(
      _ fields: [String]
    ) -> Operations.ActorsGetCollection.Input.Query.Fields_lbrack_actors_rbrack_Payload? {
      fields
        .compactMap(
          Operations.ActorsGetCollection.Input.Query.FieldsLbrackActorsRbrackPayloadPayload.init(
            rawValue:)
        )
        .nilIfEmpty
    }

    private func actorViewFields(
      _ fields: [String]
    ) -> Operations.ActorsGetInstance.Input.Query.Fields_lbrack_actors_rbrack_Payload? {
      fields
        .compactMap(
          Operations.ActorsGetInstance.Input.Query.FieldsLbrackActorsRbrackPayloadPayload.init(
            rawValue:)
        )
        .nilIfEmpty
    }
  #endif

  private func userInvitationListQuery(
    from input: AppStoreConnectUserInvitationListInput
  ) -> Operations.UserInvitationsGetCollection.Input.Query {
    var query = Operations.UserInvitationsGetCollection.Input.Query()
    query.filter_lbrack_email_rbrack_ = input.emails.nilIfEmpty
    query.filter_lbrack_visibleApps_rbrack_ = input.visibleAppIDs.nilIfEmpty
    query.filter_lbrack_roles_rbrack_ =
      input.roles.compactMap {
        Operations.UserInvitationsGetCollection.Input.Query.FilterLbrackRolesRbrackPayloadPayload(
          rawValue: $0)
      }.nilIfEmpty
    query.limit = input.limit
    query.include = [.visibleApps]
    if let sort = input.sort {
      query.sort =
        sort
        .split(separator: ",")
        .map(String.init)
        .compactMap(
          Operations.UserInvitationsGetCollection.Input.Query.SortPayloadPayload.init(rawValue:)
        )
        .nilIfEmpty
    }
    return query
  }

  private func fetchAppStoreVersion(id: String) async throws
    -> AppStoreConnectAppStoreVersionSummary
  {
    let output = try await client.apps.getAppStoreVersion(id: id)

    switch output {
    case .ok(let response):
      return Self.appStoreVersionSummary(try response.body.json.data)
    case .undocumented(let statusCode, _):
      throw AppStoreConnectError.requestFailed(
        statusCode: statusCode, message: "Unexpected App Store version response.")
    default:
      throw AppStoreConnectError.requestFailed(
        statusCode: -1, message: "App Store version lookup did not return 200 ok.")
    }
  }

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

  #if ASC_PUBLIC_API_RELEASE
    private static func appCategorySummary(
      _ category: Components.Schemas.AppCategory
    ) -> AppStoreConnectAppCategorySummary {
      AppStoreConnectAppCategorySummary(
        id: category.id,
        platforms: category.attributes?.platforms?.map(\.rawValue) ?? [],
        parentID: category.relationships?.parent?.data?.id,
        subcategoryIDs: category.relationships?.subcategories?.data?.map(\.id) ?? []
      )
    }

    static func ageRatingSummary(
      _ declaration: Components.Schemas.AgeRatingDeclaration
    ) -> AppStoreConnectAgeRatingSummary {
      let attributes = declaration.attributes
      return AppStoreConnectAgeRatingSummary(
        id: declaration.id,
        frequencyRatings: compactStringDictionary([
          (
            "alcoholTobaccoOrDrugUseOrReferences",
            attributes?.alcoholTobaccoOrDrugUseOrReferences?.rawValue
          ),
          ("contests", attributes?.contests?.rawValue),
          ("gamblingSimulated", attributes?.gamblingSimulated?.rawValue),
          ("gunsOrOtherWeapons", attributes?.gunsOrOtherWeapons?.rawValue),
          ("horrorOrFearThemes", attributes?.horrorOrFearThemes?.rawValue),
          ("matureOrSuggestiveThemes", attributes?.matureOrSuggestiveThemes?.rawValue),
          ("medicalOrTreatmentInformation", attributes?.medicalOrTreatmentInformation?.rawValue),
          ("profanityOrCrudeHumor", attributes?.profanityOrCrudeHumor?.rawValue),
          ("sexualContentGraphicAndNudity", attributes?.sexualContentGraphicAndNudity?.rawValue),
          ("sexualContentOrNudity", attributes?.sexualContentOrNudity?.rawValue),
          ("violenceCartoonOrFantasy", attributes?.violenceCartoonOrFantasy?.rawValue),
          ("violenceRealistic", attributes?.violenceRealistic?.rawValue),
          (
            "violenceRealisticProlongedGraphicOrSadistic",
            attributes?.violenceRealisticProlongedGraphicOrSadistic?.rawValue
          ),
        ]),
        booleanRatings: compactBoolDictionary([
          ("advertising", attributes?.advertising),
          ("ageAssurance", attributes?.ageAssurance),
          ("gambling", attributes?.gambling),
          ("healthOrWellnessTopics", attributes?.healthOrWellnessTopics),
          ("lootBox", attributes?.lootBox),
          ("messagingAndChat", attributes?.messagingAndChat),
          ("parentalControls", attributes?.parentalControls),
          ("unrestrictedWebAccess", attributes?.unrestrictedWebAccess),
          ("userGeneratedContent", attributes?.userGeneratedContent),
        ]),
        kidsAgeBand: attributes?.kidsAgeBand?.rawValue,
        ageRatingOverrideV2: attributes?.ageRatingOverrideV2?.rawValue,
        koreaAgeRatingOverride: attributes?.koreaAgeRatingOverride?.rawValue,
        developerAgeRatingInfoURL: attributes?.developerAgeRatingInfoUrl
      )
    }

    private static func compactStringDictionary(_ pairs: [(String, String?)]) -> [String: String] {
      Dictionary(
        uniqueKeysWithValues: pairs.compactMap { key, value in
          value.map { (key, $0) }
        })
    }

    private static func compactBoolDictionary(_ pairs: [(String, Bool?)]) -> [String: Bool] {
      Dictionary(
        uniqueKeysWithValues: pairs.compactMap { key, value in
          value.map { (key, $0) }
        })
    }

    static func appEventSummary(
      _ event: Components.Schemas.AppEvent
    ) -> AppStoreConnectAppEventSummary {
      AppStoreConnectAppEventSummary(
        id: event.id,
        referenceName: event.attributes?.referenceName,
        eventState: event.attributes?.eventState?.rawValue,
        badge: event.attributes?.badge?.rawValue,
        priority: event.attributes?.priority?.rawValue,
        purpose: event.attributes?.purpose?.rawValue,
        primaryLocale: event.attributes?.primaryLocale,
        deepLink: event.attributes?.deepLink,
        purchaseRequirement: event.attributes?.purchaseRequirement,
        localizationIDs: event.relationships?.localizations?.data?.map(\.id) ?? []
      )
    }

    static func customerReviewSummary(
      _ review: Components.Schemas.CustomerReview
    ) -> AppStoreConnectCustomerReviewSummary {
      AppStoreConnectCustomerReviewSummary(
        id: review.id,
        rating: review.attributes?.rating,
        title: review.attributes?.title,
        body: review.attributes?.body,
        reviewerNickname: review.attributes?.reviewerNickname,
        createdDate: review.attributes?.createdDate,
        territory: review.attributes?.territory?.rawValue,
        responseID: review.relationships?.response?.data?.id
      )
    }

    static func customerReviewResponseSummary(
      _ response: Components.Schemas.CustomerReviewResponseV1
    ) -> AppStoreConnectCustomerReviewResponseSummary {
      AppStoreConnectCustomerReviewResponseSummary(
        id: response.id,
        responseBody: response.attributes?.responseBody,
        state: response.attributes?.state?.rawValue,
        lastModifiedDate: response.attributes?.lastModifiedDate,
        reviewID: response.relationships?.review?.data?.id
      )
    }

    static func customerReviewSummarizationSummary(
      _ summarization: Components.Schemas.CustomerReviewSummarization
    ) -> AppStoreConnectCustomerReviewSummarizationSummary {
      AppStoreConnectCustomerReviewSummarizationSummary(
        id: summarization.id,
        platform: summarization.attributes?.platform?.rawValue,
        locale: summarization.attributes?.locale,
        text: summarization.attributes?.text,
        createdDate: summarization.attributes?.createdDate,
        territoryID: summarization.relationships?.territory?.data?.id
      )
    }
  #endif

  #if ASC_PUBLIC_API_METADATA_MEDIA
    private static func appClipSummary(
      _ appClip: Components.Schemas.AppClip
    ) -> AppStoreConnectAppClipSummary {
      AppStoreConnectAppClipSummary(
        id: appClip.id,
        bundleID: appClip.attributes?.bundleId,
        appID: appClip.relationships?.app?.data?.id,
        defaultExperienceIDs: appClip.relationships?.appClipDefaultExperiences?.data?.map(\.id)
          ?? []
      )
    }

    private static func appClipDefaultExperienceSummary(
      _ experience: Components.Schemas.AppClipDefaultExperience
    ) -> AppStoreConnectAppClipDefaultExperienceSummary {
      AppStoreConnectAppClipDefaultExperienceSummary(
        id: experience.id,
        action: experience.attributes?.action?.rawValue,
        appClipID: experience.relationships?.appClip?.data?.id,
        releaseWithAppStoreVersionID: experience.relationships?.releaseWithAppStoreVersion?.data?
          .id,
        reviewDetailID: experience.relationships?.appClipAppStoreReviewDetail?.data?.id,
        localizationIDs: experience.relationships?.appClipDefaultExperienceLocalizations?.data?.map(
          \.id) ?? []
      )
    }

    private static func appClipLocalizationSummary(
      _ localization: Components.Schemas.AppClipDefaultExperienceLocalization
    ) -> AppStoreConnectAppClipLocalizationSummary {
      AppStoreConnectAppClipLocalizationSummary(
        id: localization.id,
        locale: localization.attributes?.locale,
        subtitle: localization.attributes?.subtitle,
        defaultExperienceID: localization.relationships?.appClipDefaultExperience?.data?.id,
        headerImageID: localization.relationships?.appClipHeaderImage?.data?.id
      )
    }
  #endif

  #if ASC_PUBLIC_API_GAME_CENTER
    private static func gameCenterDetailSummary(
      _ detail: Components.Schemas.GameCenterDetail
    ) -> AppStoreConnectGameCenterDetailSummary {
      AppStoreConnectGameCenterDetailSummary(
        id: detail.id,
        arcadeEnabled: detail.attributes?.arcadeEnabled,
        challengeEnabled: detail.attributes?.challengeEnabled,
        appID: detail.relationships?.app?.data?.id,
        achievementIDs: detail.relationships?.gameCenterAchievementsV2?.data?.map(\.id) ?? [],
        leaderboardIDs: detail.relationships?.gameCenterLeaderboardsV2?.data?.map(\.id) ?? [],
        leaderboardSetIDs: detail.relationships?.gameCenterLeaderboardSetsV2?.data?.map(\.id) ?? [],
        challengeIDs: detail.relationships?.gameCenterChallenges?.data?.map(\.id) ?? []
      )
    }

    private static func gameCenterAchievementSummary(
      _ achievement: Components.Schemas.GameCenterAchievementV2
    ) -> AppStoreConnectGameCenterAchievementSummary {
      AppStoreConnectGameCenterAchievementSummary(
        id: achievement.id,
        referenceName: achievement.attributes?.referenceName,
        vendorIdentifier: achievement.attributes?.vendorIdentifier,
        points: achievement.attributes?.points,
        archived: achievement.attributes?.archived,
        repeatable: achievement.attributes?.repeatable,
        detailID: achievement.relationships?.gameCenterDetail?.data?.id,
        versionIDs: achievement.relationships?.versions?.data?.map(\.id) ?? []
      )
    }

    private static func gameCenterLeaderboardSummary(
      _ leaderboard: Components.Schemas.GameCenterLeaderboardV2
    ) -> AppStoreConnectGameCenterLeaderboardSummary {
      AppStoreConnectGameCenterLeaderboardSummary(
        id: leaderboard.id,
        referenceName: leaderboard.attributes?.referenceName,
        vendorIdentifier: leaderboard.attributes?.vendorIdentifier,
        scoreSortType: leaderboard.attributes?.scoreSortType?.rawValue,
        defaultFormatter: leaderboard.attributes?.defaultFormatter?.rawValue,
        submissionType: leaderboard.attributes?.submissionType?.rawValue,
        archived: leaderboard.attributes?.archived,
        detailID: leaderboard.relationships?.gameCenterDetail?.data?.id,
        leaderboardSetIDs: leaderboard.relationships?.gameCenterLeaderboardSets?.data?.map(\.id)
          ?? [],
        versionIDs: leaderboard.relationships?.versions?.data?.map(\.id) ?? []
      )
    }

    private static func gameCenterLeaderboardSetSummary(
      _ leaderboardSet: Components.Schemas.GameCenterLeaderboardSetV2
    ) -> AppStoreConnectGameCenterLeaderboardSetSummary {
      AppStoreConnectGameCenterLeaderboardSetSummary(
        id: leaderboardSet.id,
        referenceName: leaderboardSet.attributes?.referenceName,
        vendorIdentifier: leaderboardSet.attributes?.vendorIdentifier,
        detailID: leaderboardSet.relationships?.gameCenterDetail?.data?.id,
        leaderboardIDs: leaderboardSet.relationships?.gameCenterLeaderboards?.data?.map(\.id) ?? [],
        versionIDs: leaderboardSet.relationships?.versions?.data?.map(\.id) ?? []
      )
    }

    private static func gameCenterChallengeSummary(
      _ challenge: Components.Schemas.GameCenterChallenge
    ) -> AppStoreConnectGameCenterChallengeSummary {
      AppStoreConnectGameCenterChallengeSummary(
        id: challenge.id,
        referenceName: challenge.attributes?.referenceName,
        vendorIdentifier: challenge.attributes?.vendorIdentifier,
        challengeType: challenge.attributes?.challengeType?.rawValue,
        archived: challenge.attributes?.archived,
        repeatable: challenge.attributes?.repeatable,
        detailID: challenge.relationships?.gameCenterDetail?.data?.id,
        leaderboardID: challenge.relationships?.leaderboardV2?.data?.id
          ?? challenge.relationships?.leaderboard?.data?.id,
        versionIDs: challenge.relationships?.versions?.data?.map(\.id) ?? []
      )
    }
  #endif

  #if ASC_PUBLIC_API_DISTRIBUTION
    private static func alternativeDistributionDomainSummary(
      _ domain: Components.Schemas.AlternativeDistributionDomain
    ) -> AppStoreConnectAlternativeDistributionDomainSummary {
      AppStoreConnectAlternativeDistributionDomainSummary(
        id: domain.id,
        domain: domain.attributes?.domain,
        referenceName: domain.attributes?.referenceName,
        createdDate: domain.attributes?.createdDate
      )
    }

    private static func alternativeDistributionKeySummary(
      _ key: Components.Schemas.AlternativeDistributionKey
    ) -> AppStoreConnectAlternativeDistributionKeySummary {
      AppStoreConnectAlternativeDistributionKeySummary(
        id: key.id,
        publicKey: key.attributes?.publicKey
      )
    }

    private static func marketplaceWebhookSummary(
      _ webhook: Components.Schemas.MarketplaceWebhook
    ) -> AppStoreConnectMarketplaceWebhookSummary {
      AppStoreConnectMarketplaceWebhookSummary(
        id: webhook.id,
        endpointURL: webhook.attributes?.endpointUrl
      )
    }

    static func webhookSummary(
      _ webhook: Components.Schemas.Webhook
    ) -> AppStoreConnectWebhookSummary {
      AppStoreConnectWebhookSummary(
        id: webhook.id,
        name: webhook.attributes?.name,
        url: webhook.attributes?.url,
        enabled: webhook.attributes?.enabled,
        eventTypes: webhook.attributes?.eventTypes?.map(\.rawValue) ?? [],
        appID: webhook.relationships?.app?.data?.id
      )
    }

    static func webhookDeliverySummary(
      _ delivery: Components.Schemas.WebhookDelivery
    ) -> AppStoreConnectWebhookDeliverySummary {
      AppStoreConnectWebhookDeliverySummary(
        id: delivery.id,
        deliveryState: delivery.attributes?.deliveryState?.rawValue,
        createdDate: delivery.attributes?.createdDate,
        sentDate: delivery.attributes?.sentDate,
        redelivery: delivery.attributes?.redelivery,
        errorMessage: delivery.attributes?.errorMessage,
        requestURL: delivery.attributes?.request?.url,
        responseStatusCode: delivery.attributes?.response?.httpStatusCode,
        eventID: delivery.relationships?.event?.data?.id
      )
    }

    private static func webhookDeliveryLinkageSummary(
      _ linkage: Components.Schemas.WebhookDeliveriesLinkagesResponse.DataPayloadPayload
    ) -> AppStoreConnectWebhookDeliveryLinkageSummary {
      AppStoreConnectWebhookDeliveryLinkageSummary(
        id: linkage.id,
        type: linkage._type.rawValue
      )
    }

    static func eulaSummary(
      _ eula: Components.Schemas.EndUserLicenseAgreement
    ) -> AppStoreConnectEULASummary {
      AppStoreConnectEULASummary(
        id: eula.id,
        agreementText: eula.attributes?.agreementText,
        appID: eula.relationships?.app?.data?.id,
        territoryIDs: eula.relationships?.territories?.data?.map(\.id) ?? []
      )
    }

    private static func territorySummary(
      _ territory: Components.Schemas.Territory
    ) -> AppStoreConnectTerritorySummary {
      AppStoreConnectTerritorySummary(
        id: territory.id,
        currency: territory.attributes?.currency
      )
    }
  #endif

  private static func buildSummary(_ build: Components.Schemas.Build) -> AppStoreConnectBuildSummary
  {
    AppStoreConnectBuildSummary(
      id: build.id,
      version: build.attributes?.version,
      processingState: build.attributes?.processingState?.rawValue,
      uploadedDate: build.attributes?.uploadedDate,
      expired: build.attributes?.expired,
      minOSVersion: build.attributes?.minOsVersion,
      appID: build.relationships?.app?.data?.id
    )
  }

  private static func buildBetaDetailSummary(
    _ detail: Components.Schemas.BuildBetaDetail
  ) -> AppStoreConnectBuildBetaDetailSummary {
    AppStoreConnectBuildBetaDetailSummary(
      id: detail.id,
      autoNotifyEnabled: detail.attributes?.autoNotifyEnabled,
      internalBuildState: detail.attributes?.internalBuildState?.rawValue,
      externalBuildState: detail.attributes?.externalBuildState?.rawValue,
      buildID: detail.relationships?.build?.data?.id
    )
  }

  private static func preReleaseVersionSummary(
    _ version: Components.Schemas.PrereleaseVersion
  ) -> AppStoreConnectPreReleaseVersionSummary {
    AppStoreConnectPreReleaseVersionSummary(
      id: version.id,
      version: version.attributes?.version,
      platform: version.attributes?.platform?.rawValue,
      appID: version.relationships?.app?.data?.id,
      buildIDs: version.relationships?.builds?.data?.map(\.id) ?? []
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

  private static func betaAppLocalizationSummary(
    _ localization: Components.Schemas.BetaAppLocalization
  ) -> AppStoreConnectBetaAppLocalizationSummary {
    AppStoreConnectBetaAppLocalizationSummary(
      id: localization.id,
      locale: localization.attributes?.locale,
      description: localization.attributes?.description,
      feedbackEmail: localization.attributes?.feedbackEmail,
      marketingURL: localization.attributes?.marketingUrl,
      privacyPolicyURL: localization.attributes?.privacyPolicyUrl,
      tvOSPrivacyPolicy: localization.attributes?.tvOsPrivacyPolicy,
      appID: localization.relationships?.app?.data?.id
    )
  }

  private static func betaBuildLocalizationSummary(
    _ localization: Components.Schemas.BetaBuildLocalization
  ) -> AppStoreConnectBetaBuildLocalizationSummary {
    AppStoreConnectBetaBuildLocalizationSummary(
      id: localization.id,
      locale: localization.attributes?.locale,
      whatsNew: localization.attributes?.whatsNew,
      buildID: localization.relationships?.build?.data?.id
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

  private static func betaLicenseAgreementSummary(
    _ agreement: Components.Schemas.BetaLicenseAgreement
  ) -> AppStoreConnectBetaLicenseAgreementSummary {
    AppStoreConnectBetaLicenseAgreementSummary(
      id: agreement.id,
      agreementText: agreement.attributes?.agreementText,
      appID: agreement.relationships?.app?.data?.id
    )
  }

  private static func betaFeedbackCrashSubmissionSummary(
    _ submission: Components.Schemas.BetaFeedbackCrashSubmission
  ) -> AppStoreConnectBetaFeedbackCrashSubmissionSummary {
    AppStoreConnectBetaFeedbackCrashSubmissionSummary(
      id: submission.id,
      createdDate: submission.attributes?.createdDate,
      comment: submission.attributes?.comment,
      email: submission.attributes?.email,
      deviceModel: submission.attributes?.deviceModel,
      osVersion: submission.attributes?.osVersion,
      locale: submission.attributes?.locale,
      appPlatform: submission.attributes?.appPlatform?.rawValue,
      devicePlatform: submission.attributes?.devicePlatform?.rawValue,
      deviceFamily: submission.attributes?.deviceFamily?.rawValue,
      connectionType: submission.attributes?.connectionType?.rawValue,
      buildBundleID: submission.attributes?.buildBundleId,
      buildID: submission.relationships?.build?.data?.id,
      testerID: submission.relationships?.tester?.data?.id
    )
  }

  private static func betaFeedbackScreenshotSubmissionSummary(
    _ submission: Components.Schemas.BetaFeedbackScreenshotSubmission
  ) -> AppStoreConnectBetaFeedbackScreenshotSubmissionSummary {
    AppStoreConnectBetaFeedbackScreenshotSubmissionSummary(
      id: submission.id,
      createdDate: submission.attributes?.createdDate,
      comment: submission.attributes?.comment,
      email: submission.attributes?.email,
      deviceModel: submission.attributes?.deviceModel,
      osVersion: submission.attributes?.osVersion,
      locale: submission.attributes?.locale,
      appPlatform: submission.attributes?.appPlatform?.rawValue,
      devicePlatform: submission.attributes?.devicePlatform?.rawValue,
      deviceFamily: submission.attributes?.deviceFamily?.rawValue,
      connectionType: submission.attributes?.connectionType?.rawValue,
      buildBundleID: submission.attributes?.buildBundleId,
      screenshotCount: submission.attributes?.screenshots?.count ?? 0,
      buildID: submission.relationships?.build?.data?.id,
      testerID: submission.relationships?.tester?.data?.id
    )
  }

  private static func betaCrashLogSummary(_ log: Components.Schemas.BetaCrashLog)
    -> AppStoreConnectBetaCrashLogSummary
  {
    AppStoreConnectBetaCrashLogSummary(
      id: log.id,
      logText: log.attributes?.logText
    )
  }

  private static func appBetaTesterUsageMetricSeries(
    _ series: Components.Schemas.AppsBetaTesterUsagesV1MetricResponse.DataPayloadPayload,
    appID: String,
    testerID: String?
  ) -> AppStoreConnectBetaTesterUsageMetricSeries {
    AppStoreConnectBetaTesterUsageMetricSeries(
      scope: "app",
      appID: appID,
      testerID: series.dimensions?.betaTesters?.data ?? testerID,
      dataPoints: series.dataPoints?.map { betaTesterUsageMetricPoint($0) } ?? []
    )
  }

  private static func betaGroupBetaTesterUsageMetricSeries(
    _ series: Components.Schemas.AppsBetaTesterUsagesV1MetricResponse.DataPayloadPayload,
    groupID: String,
    testerID: String?
  ) -> AppStoreConnectBetaTesterUsageMetricSeries {
    AppStoreConnectBetaTesterUsageMetricSeries(
      scope: "group",
      groupID: groupID,
      testerID: series.dimensions?.betaTesters?.data ?? testerID,
      dataPoints: series.dataPoints?.map { betaTesterUsageMetricPoint($0) } ?? []
    )
  }

  private static func betaTesterUsageMetricSeries(
    _ series: Components.Schemas.BetaTesterUsagesV1MetricResponse.DataPayloadPayload,
    testerID: String,
    appID: String
  ) -> AppStoreConnectBetaTesterUsageMetricSeries {
    AppStoreConnectBetaTesterUsageMetricSeries(
      scope: "tester",
      appID: series.dimensions?.apps?.data ?? appID,
      testerID: testerID,
      dataPoints: series.dataPoints?.map { betaTesterUsageMetricPoint($0) } ?? []
    )
  }

  private static func betaTesterUsageMetricPoint(
    _ point: Components.Schemas.AppsBetaTesterUsagesV1MetricResponse.DataPayloadPayload
      .DataPointsPayloadPayload
  ) -> AppStoreConnectBetaTesterUsageMetricPoint {
    AppStoreConnectBetaTesterUsageMetricPoint(
      start: point.start,
      end: point.end,
      crashCount: point.values?.crashCount,
      feedbackCount: point.values?.feedbackCount,
      sessionCount: point.values?.sessionCount
    )
  }

  private static func betaTesterUsageMetricPoint(
    _ point: Components.Schemas.BetaTesterUsagesV1MetricResponse.DataPayloadPayload
      .DataPointsPayloadPayload
  ) -> AppStoreConnectBetaTesterUsageMetricPoint {
    AppStoreConnectBetaTesterUsageMetricPoint(
      start: point.start,
      end: point.end,
      crashCount: point.values?.crashCount,
      feedbackCount: point.values?.feedbackCount,
      sessionCount: point.values?.sessionCount
    )
  }

  private static func betaBuildUsageMetricSeries(
    _ series: Components.Schemas.BetaBuildUsagesV1MetricResponse.DataPayloadPayload,
    buildID: String
  ) -> AppStoreConnectBetaBuildUsageMetricSeries {
    AppStoreConnectBetaBuildUsageMetricSeries(
      buildID: buildID,
      dataPoints: series.dataPoints?.map { betaBuildUsageMetricPoint($0) } ?? []
    )
  }

  private static func betaBuildUsageMetricPoint(
    _ point: Components.Schemas.BetaBuildUsagesV1MetricResponse.DataPayloadPayload
      .DataPointsPayloadPayload
  ) -> AppStoreConnectBetaBuildUsageMetricPoint {
    AppStoreConnectBetaBuildUsageMetricPoint(
      start: point.start,
      end: point.end,
      crashCount: point.values?.crashCount,
      feedbackCount: point.values?.feedbackCount,
      installCount: point.values?.installCount,
      inviteCount: point.values?.inviteCount,
      sessionCount: point.values?.sessionCount
    )
  }

  private static func betaPublicLinkUsageMetricSeries(
    _ series: Components.Schemas.BetaPublicLinkUsagesV1MetricResponse.DataPayloadPayload,
    groupID: String
  ) -> AppStoreConnectBetaPublicLinkUsageMetricSeries {
    AppStoreConnectBetaPublicLinkUsageMetricSeries(
      groupID: groupID,
      dataPoints: series.dataPoints?.map { betaPublicLinkUsageMetricPoint($0) } ?? []
    )
  }

  private static func betaPublicLinkUsageMetricPoint(
    _ point: Components.Schemas.BetaPublicLinkUsagesV1MetricResponse.DataPayloadPayload
      .DataPointsPayloadPayload
  ) -> AppStoreConnectBetaPublicLinkUsageMetricPoint {
    AppStoreConnectBetaPublicLinkUsageMetricPoint(
      start: point.start,
      end: point.end,
      acceptedCount: point.values?.acceptedCount,
      didNotAcceptCount: point.values?.didNotAcceptCount,
      didNotMeetCriteriaCount: point.values?.didNotMeetCriteriaCount,
      notClearRatio: point.values?.notClearRatio,
      notInterestingRatio: point.values?.notInterestingRatio,
      notRelevantRatio: point.values?.notRelevantRatio,
      viewCount: point.values?.viewCount
    )
  }

  private static func betaGroupSummary(_ group: Components.Schemas.BetaGroup)
    -> AppStoreConnectBetaGroupSummary
  {
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

  private static func betaTesterSummary(_ tester: Components.Schemas.BetaTester)
    -> AppStoreConnectBetaTesterSummary
  {
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

  private static func bundleIDSummary(_ bundleID: Components.Schemas.BundleId)
    -> AppStoreConnectBundleIDSummary
  {
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

  static func bundleIDCapabilitySummary(
    _ capability: Components.Schemas.BundleIdCapability
  ) -> AppStoreConnectBundleIDCapabilitySummary {
    let settings = capability.attributes?.settings ?? []
    return AppStoreConnectBundleIDCapabilitySummary(
      id: capability.id,
      capabilityType: capability.attributes?.capabilityType?.rawValue,
      settingKeys: settings.compactMap { $0.key?.rawValue },
      settingCount: settings.count
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

  private static func deviceSummary(_ device: Components.Schemas.Device)
    -> AppStoreConnectDeviceSummary
  {
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

  private static func profileSummary(_ profile: Components.Schemas.Profile)
    -> AppStoreConnectProfileSummary
  {
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

  private static func certificateDownloadDestinationURL(
    outputPath: String?,
    certificateID: String,
    serialNumber: String?
  ) throws -> URL {
    if let outputPath, !outputPath.isEmpty {
      return URL(fileURLWithPath: outputPath)
    }

    let fileName: String
    if let serialNumber, !serialNumber.isEmpty {
      fileName = serialNumber
    } else {
      fileName = certificateID
    }
    return FileManager.default.temporaryDirectory
      .appendingPathComponent(fileName)
      .appendingPathExtension("cer")
  }

  private static func profileDownloadDestinationURL(
    outputPath: String?,
    profileID: String,
    uuid: String?
  ) throws -> URL {
    if let outputPath, !outputPath.isEmpty {
      return URL(fileURLWithPath: outputPath)
    }

    let fileName: String
    if let uuid, !uuid.isEmpty {
      fileName = uuid
    } else {
      fileName = profileID
    }
    return FileManager.default.temporaryDirectory
      .appendingPathComponent(fileName)
      .appendingPathExtension("mobileprovision")
  }

  @discardableResult
  private static func write(_ data: Data, to url: URL) throws -> Int {
    let directory = url.deletingLastPathComponent()
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    try data.write(to: url, options: [.atomic])
    return data.count
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

  #if ASC_PUBLIC_API_SIGNING_ACCESS
    private static func actorSummary(_ actor: Components.Schemas.Actor)
      -> AppStoreConnectActorSummary
    {
      AppStoreConnectActorSummary(
        id: actor.id,
        actorType: actor.attributes?.actorType?.rawValue,
        apiKeyID: actor.attributes?.apiKeyId,
        userEmail: actor.attributes?.userEmail,
        userFirstName: actor.attributes?.userFirstName,
        userLastName: actor.attributes?.userLastName
      )
    }
  #endif

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

  private func normalizedStates(_ states: [String], fallback: [String]) -> [String] {
    let normalized =
      states
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() }
      .filter { !$0.isEmpty }
    return normalized.isEmpty ? fallback : normalized
  }
}

extension Array {
  fileprivate var nilIfEmpty: [Element]? {
    isEmpty ? nil : self
  }
}

extension Optional {
  fileprivate func asyncMap<T>(_ transform: (Wrapped) async throws -> T) async rethrows -> T? {
    switch self {
    case .some(let value):
      try await transform(value)
    case .none:
      nil
    }
  }
}
