import Foundation

public enum AppStoreConnectCLICommandStatus: String, Codable, Sendable, Equatable {
    case implemented
    case compatibilityAlias = "compatibility-alias"
    case planned
    case blocked
    case outOfScopeConfirmed = "out-of-scope-confirmed"
}

public struct AppStoreConnectCLICommandDescriptor: Codable, Sendable, Equatable {
    public var command: String
    public var status: AppStoreConnectCLICommandStatus
    public var parameterSemantics: [String]
    public var backend: String
    public var notes: String?

    public init(
        command: String,
        status: AppStoreConnectCLICommandStatus,

        parameterSemantics: [String],
        backend: String,
        notes: String? = nil
    ) {
        self.command = command
        self.status = status
        self.parameterSemantics = parameterSemantics
        self.backend = backend
        self.notes = notes
    }
}

public enum AppStoreConnectCLICommandRegistry {
    public static var descriptors: [AppStoreConnectCLICommandDescriptor] {
        let categoryFamilyStatus: AppStoreConnectCLICommandStatus
        let categoryFamilyNotes: String
        let ageRatingFamilyStatus: AppStoreConnectCLICommandStatus
        let ageRatingFamilyNotes: String
#if ASC_PUBLIC_API_RELEASE
        categoryFamilyStatus = .implemented
        categoryFamilyNotes = "List/view/get, parent, subcategories, and set/edit/update route through Apple's appCategories and appInfos category relationship operations with dry-run-first mutation plans."
        ageRatingFamilyStatus = .implemented
        ageRatingFamilyNotes = "View/get and update/edit/set route through Apple's appInfos ageRatingDeclaration relationship and ageRatingDeclarations update operation with full field-map payload support."
#else
        categoryFamilyStatus = .blocked
        categoryFamilyNotes = "Enable PublicAPIRelease for typed category list/view/parent/subcategories and app-info category relationship mutation."
        ageRatingFamilyStatus = .blocked
        ageRatingFamilyNotes = "Enable PublicAPIRelease for typed age-rating view/update over Apple's official ageRatingDeclaration operations."
#endif
        let eulaFamilyStatus: AppStoreConnectCLICommandStatus
        let eulaFamilyNotes: String
#if ASC_PUBLIC_API_DISTRIBUTION
        eulaFamilyStatus = .implemented
        eulaFamilyNotes = "View/get plus create/update/edit/delete now route through Apple's endUserLicenseAgreements operations with dry-run-first mutation plans."
#else
        eulaFamilyStatus = .blocked
        eulaFamilyNotes = "Enable PublicAPIDistribution for typed EULA view/create/update/delete over Apple's official endUserLicenseAgreements operations."
#endif
        let appEventsFamilyStatus: AppStoreConnectCLICommandStatus
        let appEventsFamilyNotes: String
#if ASC_PUBLIC_API_RELEASE
        appEventsFamilyStatus = .implemented
        appEventsFamilyNotes = "Core list/view/get/create/update/delete routes through Apple's appEvents operations with dry-run-first mutation plans; localization and media helpers remain follow-up metadata/media scope."
#else
        appEventsFamilyStatus = .blocked
        appEventsFamilyNotes = "Enable PublicAPIRelease for typed app-event list/view/create/update/delete over Apple's official appEvents operations."
#endif
        let reviewsFamilyStatus: AppStoreConnectCLICommandStatus
        let reviewsFamilyNotes: String
#if ASC_PUBLIC_API_RELEASE
        reviewsFamilyStatus = .implemented
        reviewsFamilyNotes = "Customer review list/view, rating summaries, response view, and response create/delete route through Apple's CustomerReview operations; mutations default to dry-run plans and require --confirm for live calls."
#else
        reviewsFamilyStatus = .blocked
        reviewsFamilyNotes = "Enable PublicAPIRelease for typed customer review list/view/rating-summary/response operations over Apple's official CustomerReview operations."
#endif
        let appClipsFamilyStatus: AppStoreConnectCLICommandStatus
        let appClipsFamilyNotes: String
#if ASC_PUBLIC_API_METADATA_MEDIA
        appClipsFamilyStatus = .implemented
        appClipsFamilyNotes = "Read commands for app clips, default experiences, and localizations route through Apple's official AppClip operations; image upload and mutation helpers remain explicit metadata/media follow-up scope."
#else
        appClipsFamilyStatus = .blocked
        appClipsFamilyNotes = "Enable PublicAPIMetadataMedia for typed App Clips reads over Apple's official AppClip operations."
#endif
        let gameCenterFamilyStatus: AppStoreConnectCLICommandStatus
        let gameCenterFamilyNotes: String
#if ASC_PUBLIC_API_GAME_CENTER
        gameCenterFamilyStatus = .implemented
        gameCenterFamilyNotes = "Read commands for Game Center details, achievements, leaderboards, leaderboard sets, and challenges route through Apple's official GameCenter operations; write/localization/release helpers remain explicit Game Center follow-up scope."
#else
        gameCenterFamilyStatus = .blocked
        gameCenterFamilyNotes = "Enable PublicAPIGameCenter for typed Game Center reads over Apple's official GameCenter operations."
#endif
        let pricingFamilyStatus: AppStoreConnectCLICommandStatus
        let pricingFamilyNotes: String
#if ASC_PUBLIC_API_COMMERCE
        pricingFamilyStatus = .implemented
        pricingFamilyNotes = "Tiers/current and schedule-current aliases route through Apple's app price point and current schedule relationship operations; availability and live schedule mutation remain follow-up commerce scope."
#else
        pricingFamilyStatus = .blocked
        pricingFamilyNotes = "Enable PublicAPICommerce for typed pricing tiers/current reads over Apple's official app price point and current schedule operations."
#endif
        let xcodeCloudFamilyStatus: AppStoreConnectCLICommandStatus
        let xcodeCloudFamilyNotes: String
#if ASC_PUBLIC_API_CLOUD
        xcodeCloudFamilyStatus = .implemented
        xcodeCloudFamilyNotes = "Product/workflow/run/action/artifact reads and log aliases route through Apple's ci* operations; build-run starts and workflow mutations remain follow-up cloud scope."
#else
        xcodeCloudFamilyStatus = .blocked
        xcodeCloudFamilyNotes = "Enable PublicAPICloud for typed Xcode Cloud product/workflow/run/action/artifact/log reads over Apple's official ci* operations."
#endif
        let webhooksFamilyStatus: AppStoreConnectCLICommandStatus
        let webhooksFamilyNotes: String
        let marketplaceFamilyStatus: AppStoreConnectCLICommandStatus
        let marketplaceFamilyNotes: String
        let alternativeDistributionFamilyStatus: AppStoreConnectCLICommandStatus
        let alternativeDistributionFamilyNotes: String
#if ASC_PUBLIC_API_DISTRIBUTION
        webhooksFamilyStatus = .implemented
        webhooksFamilyNotes = "Official OpenAPI-backed list/view/get/create/update/delete/deliveries/linkage/redelivery/ping commands route through Apple's webhook operations; local serve remains follow-up local receiver scope."
        marketplaceFamilyStatus = .blocked
        marketplaceFamilyNotes = "Marketplace webhook list is implemented with PublicAPIDistribution; broader marketplace search-detail/package mutation scope needs explicit app relationship operation mapping before it becomes executable."
        alternativeDistributionFamilyStatus = .implemented
        alternativeDistributionFamilyNotes = "Domain/key list/view/get routes through Apple's AlternativeDistribution operations; package/version reads and mutations remain follow-up distribution scope."
#else
        webhooksFamilyStatus = .blocked
        webhooksFamilyNotes = "Enable PublicAPIDistribution for typed webhook list/view/create/update/delete/delivery/redelivery/ping operations; local serve remains a separate receiver scope."
        marketplaceFamilyStatus = .blocked
        marketplaceFamilyNotes = "Enable PublicAPIDistribution for marketplace webhook list; broader marketplace search-detail/package mutation scope still needs explicit operation mapping."
        alternativeDistributionFamilyStatus = .blocked
        alternativeDistributionFamilyNotes = "Enable PublicAPIDistribution for typed alternative distribution domain/key reads; package/version reads and mutations remain follow-up scope."
#endif
        var descriptors: [AppStoreConnectCLICommandDescriptor] = [
        descriptor(
            "commands list",
            .implemented,

            parameters: ["output format"],
            backend: "AppStoreConnectCLICommandRegistry"
        ),
        descriptor(
            "workflows list",
            .implemented,

            parameters: ["output format"],
            backend: "BuiltinWorkflow.allCases"
        ),
        descriptor(
            "workflow list",
            .compatibilityAlias,

            parameters: ["workflow file path", "include private workflows", "output format"],
            backend: "BuiltinWorkflow.allCases",
            notes: "Current package alias lists built-in workflows; workflow-file catalog listing is follow-up scope."
        ),
        descriptor(
            "workflow dry-run public-release-readiness",
            .implemented,

            parameters: ["app identity", "optional version identity", "optional screenshot set identity", "skip switches"],
            backend: "PublicReleaseReadinessWorkflow.dryRun"
        ),
        descriptor(
            "workflow run public-release-readiness",
            .implemented,

            parameters: ["app identity", "optional version identity", "optional screenshot set identity", "environment credentials"],
            backend: "PublicReleaseReadinessWorkflow.run"
        ),
        descriptor(
            "workflow run",
            .compatibilityAlias,

            parameters: ["workflow file path", "environment credentials", "output format"],
            backend: "WorkflowFileRunner.run",
            notes: "Canonical entry point for the package workflow-file runner; built-in workflow names keep explicit routes such as workflow run public-release-readiness."
        ),
        descriptor(
            "workflow validate",
            .compatibilityAlias,

            parameters: ["workflow file path", "output format"],
            backend: "WorkflowFileRunner.dryRun",
            notes: "Validation is currently surfaced as workflow-file dry-run."
        ),
        descriptor(
            "workflow-file dry-run",
            .implemented,

            parameters: ["workflow file path", "output format"],
            backend: "WorkflowFileRunner.dryRun"
        ),
        descriptor(
            "workflow-file run",
            .implemented,

            parameters: ["workflow file path", "environment credentials", "output format"],
            backend: "WorkflowFileRunner.run"
        ),
        descriptor(
            "validate",
            .compatibilityAlias,

            parameters: ["app identity", "optional App Store version identity", "dry-run", "output format"],
            backend: "PublicReleaseReadinessWorkflow",
            notes: "Marketing-version resolution is not implemented yet; pass --version-id or --app-store-version-id for exact metadata lookup."
        ),
        descriptor(
            "status",
            .implemented,

            parameters: ["app identity", "optional App Store version identity", "optional review submission identity", "platform filter", "review state filter", "limit", "output format"],
            backend: "PublicAPIReadCommands.getStatus",
            notes: "Snapshot status is implemented; watch interval monitoring is follow-up scope."
        ),
        descriptor(
            "apps list",
            .implemented,

            parameters: ["id filter", "bundle ID filter", "name filter", "SKU filter", "sort", "limit", "output format"],
            backend: "PublicAPIReadCommands.listApps"
        ),
        descriptor(
            "apps view",
            .implemented,

            parameters: ["app identity", "output format"],
            backend: "PublicAPIReadCommands.getApp"
        ),
        descriptor(
            "apps get",
            .compatibilityAlias,

            parameters: ["app identity", "output format"],
            backend: "PublicAPIReadCommands.getApp",
            notes: "Compatibility alias for canonical apps view."
        ),
        descriptor(
            "apps update",
            .implemented,

            parameters: ["app identity", "primary locale", "content rights declaration", "subscription status URLs", "accessibility URL", "streamlined purchasing flag", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateApp + updateApp",
            notes: "Defaults to dry-run; pass --confirm to perform the mutation."
        ),
        descriptor(
            "apps",
            .implemented,

            parameters: ["resource identity selectors", "pagination controls", "output format"],
            backend: "AppStoreConnectPublicAPI",
            notes: "Implemented subcommands: list, view/get, update. Follow-up app-info and relationship helpers are tracked in PLAN rather than hidden as a broad planned family row."
        ),
        descriptor(
            "builds list",
            .implemented,

            parameters: ["app selector", "build ID filter", "build number filter", "marketing version filter", "platform filter", "processing state filter", "sort", "limit", "output format"],
            backend: "PublicAPIReadCommands.listBuilds"
        ),
        descriptor(
            "builds info",
            .implemented,

            parameters: ["build identity", "app latest selector", "version/platform filters", "output format"],
            backend: "PublicAPIReadCommands.getBuild"
        ),
        descriptor(
            "builds get",
            .compatibilityAlias,

            parameters: ["build identity", "app latest selector", "version/platform filters", "output format"],
            backend: "PublicAPIReadCommands.getBuild",
            notes: "Compatibility alias for canonical builds info."
        ),
        descriptor(
            "builds wait",
            .implemented,

            parameters: ["build identity", "app latest selector", "target processing state", "failure processing states", "max attempts", "poll interval", "output format"],
            backend: "PublicAPIReadCommands.waitForBuild"
        ),
        descriptor(
            "builds beta-details list",
            .implemented,

            parameters: ["build beta detail identity filter", "build identity filter", "limit", "output format"],
            backend: "PublicAPIReadCommands.listBuildBetaDetails"
        ),
        descriptor(
            "builds beta-details view",
            .implemented,

            parameters: ["build beta detail identity", "output format"],
            backend: "PublicAPIReadCommands.getBuildBetaDetail"
        ),
        descriptor(
            "builds beta-details get",
            .compatibilityAlias,

            parameters: ["build beta detail identity", "output format"],
            backend: "PublicAPIReadCommands.getBuildBetaDetail",
            notes: "Compatibility alias for canonical builds beta-details view."
        ),
        descriptor(
            "builds",
            .implemented,

            parameters: ["app/build selectors", "platform/version/build filters", "upload file paths", "dry-run/confirm"],
            backend: "AppStoreConnectWorkflow + AppStoreConnectPublicAPI + Xcode/Transporter handoff",
            notes: "Implemented subcommands: list, info/get, wait, beta-details list/view/get, and prerelease list/view/get. Upload and relationship-heavy helpers are tracked follow-up scope."
        ),
        descriptor(
            "prerelease",
            .implemented,

            parameters: ["app/build selectors", "version/build version filters", "platform", "build audience type", "processing state", "expired filter", "sort", "limit", "output format"],
            backend: "PublicAPIReadCommands + AppStoreConnectPublicAPI",
            notes: "Implemented subcommands: list and view/get. Build bundle/localization parity is tracked follow-up scope."
        ),
        descriptor(
            "prerelease list",
            .implemented,

            parameters: ["app identity filter", "build identity filter", "version filter", "build number filter", "platform filter", "build audience type filter", "processing state filter", "expired filter", "sort", "limit", "output format"],
            backend: "PublicAPIReadCommands.listPreReleaseVersions"
        ),
        descriptor(
            "prerelease view",
            .implemented,

            parameters: ["pre-release version identity", "output format"],
            backend: "PublicAPIReadCommands.getPreReleaseVersion"
        ),
        descriptor(
            "prerelease get",
            .compatibilityAlias,

            parameters: ["pre-release version identity", "output format"],
            backend: "PublicAPIReadCommands.getPreReleaseVersion",
            notes: "Compatibility alias for canonical prerelease view."
        ),
        descriptor(
            "builds prerelease list",
            .compatibilityAlias,

            parameters: ["same as prerelease list"],
            backend: "PublicAPIReadCommands.listPreReleaseVersions",
            notes: "Compatibility alias for canonical prerelease list."
        ),
        descriptor(
            "builds prerelease view",
            .compatibilityAlias,

            parameters: ["same as prerelease view"],
            backend: "PublicAPIReadCommands.getPreReleaseVersion",
            notes: "Compatibility alias for canonical prerelease view."
        ),
        descriptor(
            "builds prerelease get",
            .compatibilityAlias,

            parameters: ["same as prerelease view"],
            backend: "PublicAPIReadCommands.getPreReleaseVersion",
            notes: "Compatibility alias for canonical prerelease view."
        ),
        descriptor(
            "versions list",
            .implemented,

            parameters: ["app identity", "version identity filter", "version string filter", "platform filter", "App Store state filter", "app version state filter", "limit", "output format"],
            backend: "PublicAPIReadCommands.listAppStoreVersions",
            notes: "App Store state filtering is applied after the public API response because Apple's schema marks that query filter deprecated."
        ),
        descriptor(
            "versions view",
            .implemented,

            parameters: ["App Store version identity", "output format"],
            backend: "PublicAPIReadCommands.getAppStoreVersion"
        ),
        descriptor(
            "versions get",
            .compatibilityAlias,

            parameters: ["App Store version identity", "output format"],
            backend: "PublicAPIReadCommands.getAppStoreVersion",
            notes: "Compatibility alias for canonical versions view."
        ),
        descriptor(
            "versions create",
            .implemented,

            parameters: ["app identity", "version string", "platform", "optional build identity", "release type", "review type", "earliest release date", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateAppStoreVersion + createAppStoreVersion",
            notes: "Defaults to dry-run; pass --confirm to perform the mutation."
        ),
        descriptor(
            "versions update",
            .implemented,

            parameters: ["App Store version identity", "version string", "build identity", "release type", "review type", "downloadable flag", "earliest release date", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateAppStoreVersion + updateAppStoreVersion",
            notes: "Defaults to dry-run; pass --confirm to perform the mutation."
        ),
        descriptor(
            "versions delete",
            .implemented,

            parameters: ["App Store version identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteAppStoreVersion + deleteAppStoreVersion",
            notes: "Defaults to dry-run; pass --confirm to perform the mutation."
        ),
        descriptor(
            "versions submit",
            .compatibilityAlias,

            parameters: ["review submission identity", "App Store version identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateReviewSubmissionItem + createReviewSubmissionItem",
            notes: "Adds an App Store version as a review submission item; final submission uses review submissions submit."
        ),
        descriptor(
            "versions release",
            .implemented,

            parameters: ["App Store version identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateAppStoreVersionReleaseRequest + createAppStoreVersionReleaseRequest",
            notes: "Defaults to dry-run; pass --confirm to request release."
        ),
        descriptor(
            "release request",
            .compatibilityAlias,

            parameters: ["App Store version identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateAppStoreVersionReleaseRequest + createAppStoreVersionReleaseRequest",
            notes: "Compatibility alias for canonical versions release."
        ),
        descriptor(
            "release submit",
            .compatibilityAlias,

            parameters: ["App Store version identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateAppStoreVersionReleaseRequest + createAppStoreVersionReleaseRequest",
            notes: "Compatibility alias for canonical versions release."
        ),
        descriptor(
            "versions",
            .implemented,

            parameters: ["app identity", "version identity", "platform", "locale", "payload fields"],
            backend: "AppStoreConnectWorkflow + AppStoreConnectPublicAPI",
            notes: "Implemented subcommands: list, view/get, create, update, delete, submit alias, and release. Localization/release-note workflow parity is tracked follow-up scope."
        ),
        descriptor(
            "release",
            .implemented,

            parameters: ["app identity", "version", "build selector", "copy source", "dry-run/confirm"],
            backend: "AppStoreConnectWorkflow",
            notes: "Implemented subcommands: request/submit via appStoreVersionReleaseRequests_createInstance. Stage/status/copy-source orchestration is tracked follow-up scope."
        ),
        descriptor(
            "publish",
            .implemented,

            parameters: ["destination", "dry-run", "confirm"],
            backend: "WorkflowRunner.dryRun",
            notes: "Implemented as executable workflow dry-run planners for appstore and testflight. Live end-to-end publish remains blocked until workflow execution is backed by upload/review orchestration."
        ),
        descriptor(
            "publish appstore",
            .implemented,

            parameters: ["dry-run", "output format"],
            backend: "WorkflowRunner.dryRun(.publishAppStore)",
            notes: "Returns the App Store publish workflow plan. --confirm is rejected until live publish orchestration is implemented."
        ),
        descriptor(
            "publish app-store",
            .compatibilityAlias,

            parameters: ["dry-run", "output format"],
            backend: "WorkflowRunner.dryRun(.publishAppStore)",
            notes: "Compatibility alias for publish appstore."
        ),
        descriptor(
            "publish testflight",
            .implemented,

            parameters: ["dry-run", "output format"],
            backend: "WorkflowRunner.dryRun(.publishTestFlight)",
            notes: "Returns the TestFlight publish workflow plan. --confirm is rejected until live publish orchestration is implemented."
        ),
        descriptor(
            "publish test-flight",
            .compatibilityAlias,

            parameters: ["dry-run", "output format"],
            backend: "WorkflowRunner.dryRun(.publishTestFlight)",
            notes: "Compatibility alias for publish testflight."
        ),
        descriptor(
            "submit",
            .implemented,

            parameters: ["version identity", "review submission identity", "confirm"],
            backend: "AppStoreConnectPublicAPI + AppStoreConnectIrisAPI when public API is insufficient",
            notes: "Implemented subcommands: status, create, and cancel. Preflight and publish-style orchestration are tracked follow-up scope."
        ),
        descriptor(
            "submit create",
            .implemented,

            parameters: ["app identity", "platform", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateReviewSubmission + createReviewSubmission",
            notes: "Compatibility command for canonical review submissions create."
        ),
        descriptor(
            "submit cancel",
            .implemented,

            parameters: ["review submission identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateReviewSubmission + updateReviewSubmission",
            notes: "Sets canceled=true through the public ReviewSubmissions update operation."
        ),
        descriptor(
            "submit status",
            .implemented,

            parameters: ["review submission identity, or app identity plus platform/state filters", "output format"],
            backend: "PublicAPIReadCommands.getReviewSubmission/listReviewSubmissions",
            notes: "Returns review submission state without mutating review state."
        ),
        descriptor(
            "review",
            .implemented,

            parameters: ["version identity", "review item identity", "payload fields", "dry-run/confirm"],
            backend: "AppStoreConnectWorkflow + AppStoreConnectPublicAPI",
            notes: "Implemented subcommands: status, submissions list/view/get/create/update/submit/cancel, and items create/update/delete. Doctor/deeper diagnostics are tracked follow-up scope."
        ),
        descriptor(
            "review status",
            .compatibilityAlias,

            parameters: ["same as submit status"],
            backend: "PublicAPIReadCommands.getReviewSubmission/listReviewSubmissions",
            notes: "Compatibility alias for submit status."
        ),
        descriptor(
            "review submissions list",
            .implemented,

            parameters: ["app identity", "platform filter", "review state filter", "limit", "output format"],
            backend: "PublicAPIReadCommands.listReviewSubmissions"
        ),
        descriptor(
            "review submissions view",
            .implemented,

            parameters: ["review submission identity", "output format"],
            backend: "PublicAPIReadCommands.getReviewSubmission"
        ),
        descriptor(
            "review submissions get",
            .compatibilityAlias,

            parameters: ["review submission identity", "output format"],
            backend: "PublicAPIReadCommands.getReviewSubmission",
            notes: "Compatibility alias for canonical review submissions view."
        ),
        descriptor(
            "review submissions create",
            .implemented,

            parameters: ["app identity", "platform", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateReviewSubmission + createReviewSubmission",
            notes: "Defaults to dry-run; pass --confirm to perform the mutation."
        ),
        descriptor(
            "review submissions update",
            .implemented,

            parameters: ["review submission identity", "submitted flag", "canceled flag", "platform", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateReviewSubmission + updateReviewSubmission",
            notes: "Defaults to dry-run; pass --confirm to perform the mutation."
        ),
        descriptor(
            "review submissions submit",
            .implemented,

            parameters: ["review submission identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateReviewSubmission + updateReviewSubmission",
            notes: "Sets submitted=true through the public ReviewSubmissions update operation."
        ),
        descriptor(
            "review submit",
            .compatibilityAlias,

            parameters: ["review submission identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateReviewSubmission + updateReviewSubmission",
            notes: "Compatibility alias for canonical review submissions submit."
        ),
        descriptor(
            "review submissions cancel",
            .implemented,

            parameters: ["review submission identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateReviewSubmission + updateReviewSubmission",
            notes: "Sets canceled=true through the public ReviewSubmissions update operation."
        ),
        descriptor(
            "review items create",
            .implemented,

            parameters: ["review submission identity", "App Store version identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateReviewSubmissionItem + createReviewSubmissionItem",
            notes: "Current package-owned command covers App Store version review items."
        ),
        descriptor(
            "review submission-items create",
            .compatibilityAlias,

            parameters: ["review submission identity", "App Store version identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateReviewSubmissionItem + createReviewSubmissionItem",
            notes: "Compatibility alias for canonical review items create."
        ),
        descriptor(
            "review items update",
            .implemented,

            parameters: ["review submission item identity", "removed flag", "resolved flag", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateReviewSubmissionItem + updateReviewSubmissionItem",
            notes: "Defaults to dry-run; pass --confirm to perform the mutation."
        ),
        descriptor(
            "review submission-items update",
            .compatibilityAlias,

            parameters: ["review submission item identity", "removed flag", "resolved flag", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateReviewSubmissionItem + updateReviewSubmissionItem",
            notes: "Compatibility alias for canonical review items update."
        ),
        descriptor(
            "review items delete",
            .implemented,

            parameters: ["review submission item identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteReviewSubmissionItem + deleteReviewSubmissionItem",
            notes: "Defaults to dry-run; pass --confirm to perform the mutation."
        ),
        descriptor(
            "review submission-items delete",
            .compatibilityAlias,

            parameters: ["review submission item identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteReviewSubmissionItem + deleteReviewSubmissionItem",
            notes: "Compatibility alias for canonical review items delete."
        ),
        descriptor(
            "reviews",
            reviewsFamilyStatus,

            parameters: ["app/version identity", "review identity", "response identity", "territory", "rating filters", "platform", "dry-run", "confirm", "output format"],
            backend: "AppStoreConnectPublicAPI",
            notes: reviewsFamilyNotes
        ),
        descriptor(
            "testflight builds list",
            .implemented,

            parameters: ["app identity", "marketing version", "build number", "platform", "processing state", "limit", "output format"],
            backend: "PublicAPIReadCommands.listBuilds",
            notes: "TestFlight namespace alias for build reads."
        ),
        descriptor(
            "testflight builds view",
            .implemented,

            parameters: ["build identity, or app identity plus latest selector", "output format"],
            backend: "PublicAPIReadCommands.getBuild"
        ),
        descriptor(
            "testflight builds get",
            .compatibilityAlias,

            parameters: ["build identity, or app identity plus latest selector", "output format"],
            backend: "PublicAPIReadCommands.getBuild",
            notes: "Compatibility alias for canonical testflight builds view."
        ),
        descriptor(
            "testflight builds info",
            .compatibilityAlias,

            parameters: ["build identity, or app identity plus latest selector", "output format"],
            backend: "PublicAPIReadCommands.getBuild",
            notes: "Compatibility alias matching the top-level builds info command."
        ),
        descriptor(
            "testflight builds wait",
            .implemented,

            parameters: ["build identity, or app identity plus latest selector", "target/failure processing states", "max attempts", "poll interval", "output format"],
            backend: "PublicAPIReadCommands.waitForBuild"
        ),
        descriptor(
            "testflight builds beta-details list",
            .compatibilityAlias,

            parameters: ["build beta detail identity", "build identity", "limit", "output format"],
            backend: "PublicAPIReadCommands.listBuildBetaDetails",
            notes: "Compatibility alias for canonical builds beta-details list."
        ),
        descriptor(
            "testflight builds beta-details view",
            .compatibilityAlias,

            parameters: ["build beta detail identity", "output format"],
            backend: "PublicAPIReadCommands.getBuildBetaDetail",
            notes: "Compatibility alias for canonical builds beta-details view."
        ),
        descriptor(
            "testflight builds beta-details get",
            .compatibilityAlias,

            parameters: ["build beta detail identity", "output format"],
            backend: "PublicAPIReadCommands.getBuildBetaDetail",
            notes: "Compatibility alias for canonical builds beta-details view."
        ),
        descriptor(
            "testflight builds localizations list",
            .compatibilityAlias,

            parameters: ["build identity filter", "locale filter", "limit", "output format"],
            backend: "PublicAPIReadCommands.listBetaBuildLocalizations",
            notes: "Compatibility alias for canonical testflight build-localizations list."
        ),
        descriptor(
            "testflight builds localizations view",
            .compatibilityAlias,

            parameters: ["beta build localization identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaBuildLocalization",
            notes: "Compatibility alias for canonical testflight build-localizations view."
        ),
        descriptor(
            "testflight builds localizations get",
            .compatibilityAlias,

            parameters: ["beta build localization identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaBuildLocalization",
            notes: "Compatibility alias for canonical testflight build-localizations view."
        ),
        descriptor(
            "testflight builds review-submissions list",
            .compatibilityAlias,

            parameters: ["build identity", "beta review state", "limit", "output format"],
            backend: "PublicAPIReadCommands.listBetaAppReviewSubmissions",
            notes: "Compatibility alias for canonical testflight review-submissions list."
        ),
        descriptor(
            "testflight builds review-submissions view",
            .compatibilityAlias,

            parameters: ["beta app review submission identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaAppReviewSubmission",
            notes: "Compatibility alias for canonical testflight review-submissions view."
        ),
        descriptor(
            "testflight builds review-submissions get",
            .compatibilityAlias,

            parameters: ["beta app review submission identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaAppReviewSubmission",
            notes: "Compatibility alias for canonical testflight review-submissions view."
        ),
        descriptor(
            "testflight groups list",
            .implemented,

            parameters: ["app identity", "group identity filter", "group name filter", "build identity filter", "public link filters", "sort", "limit", "output format"],
            backend: "PublicAPIReadCommands.listBetaGroups"
        ),
        descriptor(
            "testflight groups view",
            .implemented,

            parameters: ["beta group identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaGroup"
        ),
        descriptor(
            "testflight groups get",
            .compatibilityAlias,

            parameters: ["beta group identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaGroup",
            notes: "Compatibility alias for canonical testflight groups view."
        ),
        descriptor(
            "testflight groups create",
            .implemented,

            parameters: ["app identity", "group name", "build/tester relationships", "public link flags", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateBetaGroup + createBetaGroup",
            notes: "Defaults to dry-run; pass --confirm to perform the mutation."
        ),
        descriptor(
            "testflight groups update",
            .implemented,

            parameters: ["beta group identity", "group name", "feedback/public link flags", "platform build availability flags", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateBetaGroup + updateBetaGroup",
            notes: "Defaults to dry-run; pass --confirm to perform the mutation."
        ),
        descriptor(
            "testflight groups delete",
            .implemented,

            parameters: ["beta group identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteBetaGroup + deleteBetaGroup",
            notes: "Defaults to dry-run; pass --confirm to perform the mutation."
        ),
        descriptor(
            "testflight testers list",
            .implemented,

            parameters: ["app identity", "beta group identity", "tester identity", "email/name filters", "invite type", "sort", "limit", "output format"],
            backend: "PublicAPIReadCommands.listBetaTesters"
        ),
        descriptor(
            "testflight testers view",
            .implemented,

            parameters: ["beta tester identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaTester"
        ),
        descriptor(
            "testflight testers get",
            .compatibilityAlias,

            parameters: ["beta tester identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaTester",
            notes: "Compatibility alias for canonical testflight testers view."
        ),
        descriptor(
            "testflight testers create",
            .implemented,

            parameters: ["email", "first name", "last name", "group/build relationships", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateBetaTester + createBetaTester",
            notes: "Defaults to dry-run; pass --confirm to perform the mutation."
        ),
        descriptor(
            "testflight testers delete",
            .implemented,

            parameters: ["beta tester identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteBetaTester + deleteBetaTester",
            notes: "Defaults to dry-run; pass --confirm to perform the mutation."
        ),
        descriptor(
            "testflight app-localizations list",
            .implemented,

            parameters: ["app identity filter", "locale filter", "limit", "output format"],
            backend: "PublicAPIReadCommands.listBetaAppLocalizations"
        ),
        descriptor(
            "testflight app-localizations view",
            .implemented,

            parameters: ["beta app localization identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaAppLocalization"
        ),
        descriptor(
            "testflight app-localizations get",
            .compatibilityAlias,

            parameters: ["beta app localization identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaAppLocalization",
            notes: "Compatibility alias for canonical testflight app-localizations view."
        ),
        descriptor(
            "testflight build-localizations list",
            .implemented,

            parameters: ["build identity filter", "locale filter", "limit", "output format"],
            backend: "PublicAPIReadCommands.listBetaBuildLocalizations"
        ),
        descriptor(
            "testflight build-localizations view",
            .implemented,

            parameters: ["beta build localization identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaBuildLocalization"
        ),
        descriptor(
            "testflight build-localizations get",
            .compatibilityAlias,

            parameters: ["beta build localization identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaBuildLocalization",
            notes: "Compatibility alias for canonical testflight build-localizations view."
        ),
        descriptor(
            "testflight review-details list",
            .implemented,

            parameters: ["app identity", "limit", "output format"],
            backend: "PublicAPIReadCommands.listBetaAppReviewDetails"
        ),
        descriptor(
            "testflight review-details view",
            .implemented,

            parameters: ["beta app review detail identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaAppReviewDetail"
        ),
        descriptor(
            "testflight review-details get",
            .compatibilityAlias,

            parameters: ["beta app review detail identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaAppReviewDetail",
            notes: "Compatibility alias for canonical testflight review-details view."
        ),
        descriptor(
            "testflight review-details update",
            .implemented,

            parameters: ["beta app review detail identity", "contact fields", "demo account fields", "notes", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateBetaAppReviewDetail + updateBetaAppReviewDetail",
            notes: "Defaults to dry-run; pass --confirm to perform the mutation."
        ),
        descriptor(
            "testflight review-submissions list",
            .implemented,

            parameters: ["build identity", "beta review state", "limit", "output format"],
            backend: "PublicAPIReadCommands.listBetaAppReviewSubmissions"
        ),
        descriptor(
            "testflight review-submissions view",
            .implemented,

            parameters: ["beta app review submission identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaAppReviewSubmission"
        ),
        descriptor(
            "testflight review-submissions get",
            .compatibilityAlias,

            parameters: ["beta app review submission identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaAppReviewSubmission",
            notes: "Compatibility alias for canonical testflight review-submissions view."
        ),
        descriptor(
            "testflight review-submissions create",
            .implemented,

            parameters: ["build identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateBetaAppReviewSubmission + createBetaAppReviewSubmission",
            notes: "Defaults to dry-run; pass --confirm to perform the mutation."
        ),
        descriptor(
            "testflight review-submissions submit",
            .compatibilityAlias,

            parameters: ["build identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateBetaAppReviewSubmission + createBetaAppReviewSubmission",
            notes: "Compatibility alias for canonical testflight review-submissions create."
        ),
        descriptor(
            "testflight license-agreements list",
            .implemented,

            parameters: ["app identity filter", "limit", "output format"],
            backend: "PublicAPIReadCommands.listBetaLicenseAgreements"
        ),
        descriptor(
            "testflight license-agreements view",
            .implemented,

            parameters: ["beta license agreement identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaLicenseAgreement"
        ),
        descriptor(
            "testflight license-agreements get",
            .compatibilityAlias,

            parameters: ["beta license agreement identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaLicenseAgreement",
            notes: "Compatibility alias for canonical testflight license-agreements view."
        ),
        descriptor(
            "testflight feedback list",
            .implemented,

            parameters: ["app identity", "device model", "OS version", "platform filters", "build/tester filters", "sort", "limit", "output format"],
            backend: "PublicAPIReadCommands.listBetaFeedbackScreenshotSubmissions",
            notes: "Canonical feedback command lists screenshot feedback submissions."
        ),
        descriptor(
            "testflight feedback view",
            .implemented,

            parameters: ["beta feedback screenshot submission identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaFeedbackScreenshotSubmission"
        ),
        descriptor(
            "testflight feedback get",
            .compatibilityAlias,

            parameters: ["beta feedback screenshot submission identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaFeedbackScreenshotSubmission",
            notes: "Compatibility alias for canonical testflight feedback view."
        ),
        descriptor(
            "testflight feedback screenshots list",
            .compatibilityAlias,

            parameters: ["app identity", "device model", "OS version", "platform filters", "build/tester filters", "sort", "limit", "output format"],
            backend: "PublicAPIReadCommands.listBetaFeedbackScreenshotSubmissions",
            notes: "Explicit alias for canonical testflight feedback list."
        ),
        descriptor(
            "testflight feedback screenshots view",
            .compatibilityAlias,

            parameters: ["beta feedback screenshot submission identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaFeedbackScreenshotSubmission",
            notes: "Explicit alias for canonical testflight feedback view."
        ),
        descriptor(
            "testflight feedback screenshots get",
            .compatibilityAlias,

            parameters: ["beta feedback screenshot submission identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaFeedbackScreenshotSubmission",
            notes: "Compatibility alias for canonical testflight feedback view."
        ),
        descriptor(
            "testflight crashes list",
            .implemented,

            parameters: ["app identity", "device model", "OS version", "platform filters", "build/tester filters", "sort", "limit", "output format"],
            backend: "PublicAPIReadCommands.listBetaFeedbackCrashSubmissions"
        ),
        descriptor(
            "testflight crashes view",
            .implemented,

            parameters: ["beta feedback crash submission identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaFeedbackCrashSubmission"
        ),
        descriptor(
            "testflight crashes get",
            .compatibilityAlias,

            parameters: ["beta feedback crash submission identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaFeedbackCrashSubmission",
            notes: "Compatibility alias for canonical testflight crashes view."
        ),
        descriptor(
            "testflight crashes log",
            .implemented,

            parameters: ["beta feedback crash submission identity", "output format"],
            backend: "PublicAPIReadCommands.getCrashLogForBetaFeedbackCrashSubmission"
        ),
        descriptor(
            "testflight crash-logs view",
            .implemented,

            parameters: ["beta crash log identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaCrashLog"
        ),
        descriptor(
            "testflight crash-logs get",
            .compatibilityAlias,

            parameters: ["beta crash log identity", "output format"],
            backend: "PublicAPIReadCommands.getBetaCrashLog",
            notes: "Compatibility alias for canonical testflight crash-logs view."
        ),
        descriptor(
            "testflight metrics beta-tester-usages",
            .implemented,

            parameters: ["app/group/tester metric scope", "app filter for tester scope", "beta tester filter", "period", "group by beta testers", "limit", "output format"],
            backend: "PublicAPIReadCommands.getAppBetaTesterUsageMetrics + getBetaGroupBetaTesterUsageMetrics + getBetaTesterUsageMetrics"
        ),
        descriptor(
            "testflight groups metrics beta-tester-usages",
            .compatibilityAlias,

            parameters: ["beta group identity", "beta tester filter", "period", "group by beta testers", "limit", "output format"],
            backend: "PublicAPIReadCommands.getBetaGroupBetaTesterUsageMetrics",
            notes: "Explicit group-scoped alias for canonical testflight metrics beta-tester-usages."
        ),
        descriptor(
            "testflight testers metrics beta-tester-usages",
            .compatibilityAlias,

            parameters: ["beta tester identity", "app identity filter", "period", "limit", "output format"],
            backend: "PublicAPIReadCommands.getBetaTesterUsageMetrics",
            notes: "Explicit tester-scoped alias for canonical testflight metrics beta-tester-usages."
        ),
        descriptor(
            "testflight metrics public-link-usages",
            .implemented,

            parameters: ["beta group identity", "limit", "output format"],
            backend: "PublicAPIReadCommands.getBetaGroupPublicLinkUsageMetrics"
        ),
        descriptor(
            "testflight groups metrics public-link-usages",
            .compatibilityAlias,

            parameters: ["beta group identity", "limit", "output format"],
            backend: "PublicAPIReadCommands.getBetaGroupPublicLinkUsageMetrics",
            notes: "Explicit group-scoped alias for canonical testflight metrics public-link-usages."
        ),
        descriptor(
            "testflight metrics beta-build-usages",
            .implemented,

            parameters: ["build identity", "limit", "output format"],
            backend: "PublicAPIReadCommands.getBetaBuildUsageMetrics"
        ),
        descriptor(
            "testflight builds metrics beta-build-usages",
            .compatibilityAlias,

            parameters: ["build identity", "limit", "output format"],
            backend: "PublicAPIReadCommands.getBetaBuildUsageMetrics",
            notes: "Explicit build-scoped alias for canonical testflight metrics beta-build-usages."
        ),
        descriptor(
            "testflight invitations create",
            .implemented,

            parameters: ["app identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateBetaTesterInvitation + createBetaTesterInvitation",
            notes: "Defaults to dry-run; pass --confirm to perform the mutation."
        ),
        descriptor(
            "testflight tester-invitations create",
            .compatibilityAlias,

            parameters: ["app identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateBetaTesterInvitation + createBetaTesterInvitation",
            notes: "Compatibility alias for canonical testflight invitations create."
        ),
        descriptor(
            "testflight",
            .implemented,

            parameters: ["app/build/group/tester selectors", "email lists", "review submission flags", "output format"],
            backend: "AppStoreConnectWorkflow + AppStoreConnectPublicAPI",
            notes: "Implemented subcommands: builds, group/tester reads and core mutations, app-localizations, build-localizations, review-details read/update, review-submissions read/create, license-agreements, feedback, crashes, crash-logs, metrics, and invitations create. Relationship-heavy mutations and beta review edge cases are tracked follow-up scope."
        ),
        descriptor(
            "metadata",
            .implemented,

            parameters: ["app/version identity", "locale", "metadata file paths", "validate/push/pull"],
            backend: "AppStoreConnectWorkflow + AppStoreConnectPublicAPI",
            notes: "Executable subcommands: validate, pull dry-run plan, push dry-run plan, and keywords dry-run plan. Live pull/push/apply is blocked until the metadata directory contract is finalized."
        ),
        descriptor(
            "metadata validate",
            .implemented,

            parameters: ["metadata path", "output format"],
            backend: "AppStoreConnectMetadataCommands.validate",
            notes: "Local JSON validation over a metadata file or directory."
        ),
        descriptor(
            "metadata pull",
            .implemented,

            parameters: ["app ID", "App Store version ID", "locale", "metadata path", "dry-run"],
            backend: "AppStoreConnectMetadataCommands.planPull",
            notes: "Dry-run workflow planner. Live file writing is blocked until the package metadata directory contract is finalized."
        ),
        descriptor(
            "metadata push",
            .implemented,

            parameters: ["metadata path", "app ID", "App Store version ID", "locale", "dry-run"],
            backend: "AppStoreConnectMetadataCommands.planPush",
            notes: "Dry-run workflow planner. Live metadata apply is blocked until the package metadata directory contract is finalized."
        ),
        descriptor(
            "metadata keywords",
            .implemented,

            parameters: ["App Store version localization ID", "keywords", "dry-run"],
            backend: "AppStoreConnectMetadataCommands.planKeywords",
            notes: "Dry-run planner for keyword updates; live mutation waits for the metadata/localization file mapping contract."
        ),
        descriptor(
            "localizations",
            .blocked,

            parameters: ["app/version identity", "locale", "file paths", "payload fields"],
            backend: "AppStoreConnectPublicAPI",
            notes: "Blocked as a broad family until the package metadata directory contract chooses the canonical app-info vs App Store version localization mapping. Use metadata validate/pull/push dry-run planners meanwhile."
        ),
        descriptor(
            "localizations list",
            .blocked,

            parameters: ["app info or App Store version identity", "locale", "limit", "output format"],
            backend: "Blocked pending AppStoreConnectWorkflow metadata file contract",
            notes: "Official localization relationship operations are available through trait/full PublicAPI slices, but the generic CLI command remains blocked until the package chooses the canonical app-info vs App Store version localization mapping."
        ),
        descriptor(
            "localizations upload",
            .blocked,

            parameters: ["metadata/localization file path", "locale", "dry-run", "confirm"],
            backend: "Future AppStoreConnectWorkflow metadata file contract",
            notes: "Blocked until metadata file layout and field mapping are finalized."
        ),
        descriptor(
            "localizations update",
            .blocked,

            parameters: ["localization identity", "localized payload fields", "dry-run", "confirm"],
            backend: "Future AppStoreConnectWorkflow metadata file contract",
            notes: "Blocked as a generic CLI entry because app-info and version-localization payloads differ; metadata keywords covers the narrow keyword dry-run."
        ),
        descriptor(
            "screenshots",
            .implemented,

            parameters: ["app/version identity", "locale", "display type", "media file paths", "resume"],
            backend: "AppStoreConnectWorkflow + AppStoreConnectPublicAPI upload helpers",
            notes: "Executable subcommands: list by screenshot set and view/get by screenshot ID. Upload/download/review remain blocked until the media upload/download workflow contract is finalized."
        ),
        descriptor(
            "screenshots list",
            .implemented,

            parameters: ["screenshot set ID", "include assets", "limit", "output format"],
            backend: "PublicAPIReadCommands.getAppScreenshotSet",
            notes: "Uses the official screenshot-set resource and included appScreenshots relationship."
        ),
        descriptor(
            "screenshots view",
            .implemented,

            parameters: ["screenshot ID", "output format"],
            backend: "PublicAPIReadCommands.getAppScreenshot"
        ),
        descriptor(
            "screenshots get",
            .compatibilityAlias,

            parameters: ["same as screenshots view"],
            backend: "PublicAPIReadCommands.getAppScreenshot",
            notes: "Alias for screenshots view."
        ),
        descriptor(
            "screenshots upload",
            .blocked,

            parameters: ["screenshot set ID", "file path", "resume", "dry-run", "confirm"],
            backend: "Future AppStoreConnectWorkflow media upload contract",
            notes: "Raw upload primitives exist, but the CLI workflow still needs file hashing, chunk upload, finalization, resume, and fixture coverage before live upload is exposed."
        ),
        descriptor(
            "screenshots download",
            .blocked,

            parameters: ["screenshot ID or set ID", "output path"],
            backend: "Future AppStoreConnectWorkflow media download contract",
            notes: "Blocked until image asset URL selection and local file output semantics are finalized."
        ),
        descriptor(
            "video-previews",
            .implemented,

            parameters: ["app/version identity", "locale", "display type", "media file paths", "poster frame"],
            backend: "AppStoreConnectPublicAPI upload helpers",
            notes: "Executable subcommands: list by preview set and view/get by preview ID. Upload and poster-frame mutation remain blocked until the media upload workflow contract is finalized."
        ),
        descriptor(
            "video-previews list",
            .implemented,

            parameters: ["preview set ID", "include assets", "limit", "output format"],
            backend: "PublicAPIReadCommands.getAppPreviewSet",
            notes: "Uses the official preview-set resource and included appPreviews relationship."
        ),
        descriptor(
            "video-previews view",
            .implemented,

            parameters: ["preview ID", "output format"],
            backend: "PublicAPIReadCommands.getAppPreview"
        ),
        descriptor(
            "video-previews get",
            .compatibilityAlias,

            parameters: ["same as video-previews view"],
            backend: "PublicAPIReadCommands.getAppPreview",
            notes: "Alias for video-previews view."
        ),
        descriptor(
            "videopreviews",
            .compatibilityAlias,

            parameters: ["same as video-previews"],
            backend: "PublicAPIReadCommands.getAppPreviewSet + getAppPreview",
            notes: "Spelling alias for video-previews."
        ),
        descriptor(
            "video-previews upload",
            .blocked,

            parameters: ["preview set ID", "video file path", "poster frame", "resume", "dry-run", "confirm"],
            backend: "Future AppStoreConnectWorkflow media upload contract",
            notes: "Raw upload primitives exist, but video upload needs chunk upload, frame metadata, finalization, resume, and fixture coverage before live upload is exposed."
        ),
        descriptor(
            "video-previews set-poster-frame",
            .blocked,

            parameters: ["preview ID", "preview frame time code", "dry-run", "confirm"],
            backend: "Future AppStoreConnectWorkflow media upload contract",
            notes: "Blocked until poster-frame update semantics are validated against fixtures."
        ),
        ]
#if ASC_PUBLIC_API_COMMERCE
        descriptors.append(contentsOf: [
        descriptor(
            "iap",
            .implemented,

            parameters: ["app/product identity", "localized payloads", "pricing", "availability", "review submission"],
            backend: "PublicAPICommerce trait + AppStoreConnectIrisAPI gap ledger",
            notes: "Executable trait-gated subcommands: list, view/get, create, update, delete, submit, and localizations list/view/get/create/update/delete. Price schedules, availability, images, offer codes, and Iris-only first-submission gaps are tracked follow-up scope."
        ),
        descriptor(
            "iap list",
            .implemented,

            parameters: ["app ID", "product/name/state/type filters", "sort", "fields", "include", "limit", "output format"],
            backend: "PublicAPIReadCommands.listInAppPurchases",
            notes: "Lists IAPs through the official app relationship because Apple's schema has no top-level inAppPurchasesV2 collection."
        ),
        descriptor(
            "iap view",
            .implemented,

            parameters: ["in-app purchase ID", "output format"],
            backend: "PublicAPIReadCommands.getInAppPurchase",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "iap get",
            .compatibilityAlias,

            parameters: ["in-app purchase ID", "output format"],
            backend: "PublicAPIReadCommands.getInAppPurchase",
            notes: "Alias for iap view; requires PublicAPICommerce trait."
        ),
        descriptor(
            "iap create",
            .implemented,

            parameters: ["app ID", "product ID", "reference name", "IAP type", "family sharing", "review note", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateInAppPurchase + createInAppPurchase",
            notes: "Defaults to dry-run; pass --confirm to perform the trait-gated PublicAPICommerce mutation."
        ),
        descriptor(
            "iap update",
            .implemented,

            parameters: ["in-app purchase ID", "name", "family sharing", "review note", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateInAppPurchase + updateInAppPurchase",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "iap delete",
            .implemented,

            parameters: ["in-app purchase ID", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteInAppPurchase + deleteInAppPurchase",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "iap submit",
            .implemented,

            parameters: ["in-app purchase ID", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planSubmitInAppPurchase + submitInAppPurchase",
            notes: "Public submission endpoint is executable; Iris-only first-submission behavior remains ledgered separately."
        ),
        descriptor(
            "iap localizations list",
            .implemented,

            parameters: ["in-app purchase ID", "limit", "output format"],
            backend: "PublicAPIReadCommands.listInAppPurchaseLocalizations",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "iap localizations view",
            .implemented,

            parameters: ["localization ID", "output format"],
            backend: "PublicAPIReadCommands.getInAppPurchaseLocalization",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "iap localizations get",
            .compatibilityAlias,

            parameters: ["localization ID", "output format"],
            backend: "PublicAPIReadCommands.getInAppPurchaseLocalization",
            notes: "Alias for iap localizations view."
        ),
        descriptor(
            "iap localizations create",
            .implemented,

            parameters: ["in-app purchase ID", "locale", "name", "description", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateInAppPurchaseLocalization + createInAppPurchaseLocalization",
            notes: "Defaults to dry-run; pass --confirm for live mutation."
        ),
        descriptor(
            "iap localizations update",
            .implemented,

            parameters: ["localization ID", "name", "description", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateInAppPurchaseLocalization + updateInAppPurchaseLocalization",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "iap localizations delete",
            .implemented,

            parameters: ["localization ID", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteInAppPurchaseLocalization + deleteInAppPurchaseLocalization",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "iap localization list",
            .compatibilityAlias,

            parameters: ["same as iap localizations list"],
            backend: "PublicAPIReadCommands.listInAppPurchaseLocalizations",
            notes: "Alias for iap localizations list."
        ),
        descriptor(
            "iap localization view",
            .compatibilityAlias,

            parameters: ["same as iap localizations view"],
            backend: "PublicAPIReadCommands.getInAppPurchaseLocalization",
            notes: "Alias for iap localizations view."
        ),
        descriptor(
            "iap localization get",
            .compatibilityAlias,

            parameters: ["same as iap localizations get"],
            backend: "PublicAPIReadCommands.getInAppPurchaseLocalization",
            notes: "Alias for iap localizations get."
        ),
        descriptor(
            "iap localization create",
            .compatibilityAlias,

            parameters: ["same as iap localizations create"],
            backend: "PublicAPIWriteCommands.planCreateInAppPurchaseLocalization + createInAppPurchaseLocalization",
            notes: "Alias for iap localizations create."
        ),
        descriptor(
            "iap localization update",
            .compatibilityAlias,

            parameters: ["same as iap localizations update"],
            backend: "PublicAPIWriteCommands.planUpdateInAppPurchaseLocalization + updateInAppPurchaseLocalization",
            notes: "Alias for iap localizations update."
        ),
        descriptor(
            "iap localization delete",
            .compatibilityAlias,

            parameters: ["same as iap localizations delete"],
            backend: "PublicAPIWriteCommands.planDeleteInAppPurchaseLocalization + deleteInAppPurchaseLocalization",
            notes: "Alias for iap localizations delete."
        ),
        descriptor(
            "promoted-purchases",
            .implemented,

            parameters: ["app ID", "IAP/subscription identity", "visibility/enabled flags", "fields", "include", "limit", "dry-run", "confirm", "output format"],
            backend: "PublicAPIReadCommands + PublicAPIWriteCommands",
            notes: "Canonical hyphenated command family; hyphenless spelling is a compatibility alias."
        ),
        descriptor(
            "promotedpurchases",
            .compatibilityAlias,

            parameters: ["same as promoted-purchases"],
            backend: "AppStoreConnectCommand alias",
            notes: "Alias for promoted-purchases."
        ),
        descriptor(
            "promoted-purchases list",
            .implemented,

            parameters: ["app ID", "fields", "include", "limit", "output format"],
            backend: "PublicAPIReadCommands.listPromotedPurchases",
            notes: "Lists promoted purchases through the official app relationship."
        ),
        descriptor(
            "promoted-purchases view",
            .implemented,

            parameters: ["promoted purchase ID", "fields", "include", "output format"],
            backend: "PublicAPIReadCommands.getPromotedPurchase",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "promoted-purchases get",
            .compatibilityAlias,

            parameters: ["promoted purchase ID", "fields", "include", "output format"],
            backend: "PublicAPIReadCommands.getPromotedPurchase",
            notes: "Alias for promoted-purchases view."
        ),
        descriptor(
            "promoted-purchases create",
            .implemented,

            parameters: ["app ID", "IAP or subscription ID", "visible-for-all-users", "enabled", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreatePromotedPurchase + createPromotedPurchase",
            notes: "Defaults to dry-run; pass --confirm for live mutation."
        ),
        descriptor(
            "promoted-purchases update",
            .implemented,

            parameters: ["promoted purchase ID", "visible-for-all-users", "enabled", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdatePromotedPurchase + updatePromotedPurchase",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "promoted-purchases delete",
            .implemented,

            parameters: ["promoted purchase ID", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeletePromotedPurchase + deletePromotedPurchase",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "promotedpurchases list",
            .compatibilityAlias,

            parameters: ["same as promoted-purchases list"],
            backend: "PublicAPIReadCommands.listPromotedPurchases",
            notes: "Alias for promoted-purchases list."
        ),
        descriptor(
            "promotedpurchases view",
            .compatibilityAlias,

            parameters: ["same as promoted-purchases view"],
            backend: "PublicAPIReadCommands.getPromotedPurchase",
            notes: "Alias for promoted-purchases view."
        ),
        descriptor(
            "promotedpurchases get",
            .compatibilityAlias,

            parameters: ["same as promoted-purchases get"],
            backend: "PublicAPIReadCommands.getPromotedPurchase",
            notes: "Alias for promoted-purchases get."
        ),
        descriptor(
            "promotedpurchases create",
            .compatibilityAlias,

            parameters: ["same as promoted-purchases create"],
            backend: "PublicAPIWriteCommands.planCreatePromotedPurchase + createPromotedPurchase",
            notes: "Alias for promoted-purchases create."
        ),
        descriptor(
            "promotedpurchases update",
            .compatibilityAlias,

            parameters: ["same as promoted-purchases update"],
            backend: "PublicAPIWriteCommands.planUpdatePromotedPurchase + updatePromotedPurchase",
            notes: "Alias for promoted-purchases update."
        ),
        descriptor(
            "promotedpurchases delete",
            .compatibilityAlias,

            parameters: ["same as promoted-purchases delete"],
            backend: "PublicAPIWriteCommands.planDeletePromotedPurchase + deletePromotedPurchase",
            notes: "Alias for promoted-purchases delete."
        ),
        descriptor(
            "subscriptions",
            .implemented,

            parameters: ["app/group/subscription identity", "localized payloads", "pricing", "availability", "review submission"],
            backend: "PublicAPICommerce trait + AppStoreConnectIrisAPI gap ledger",
            notes: "Executable trait-gated subcommands: list by group, view/get, create, update, delete, submit, subscription-groups CRUD, subscription/subscription-group localizations list/view/get/create/update/delete, and win-back-offers list/view/get/create/update/delete. Availability, prices, price-points, offers, and deeper win-back offer price management are tracked follow-up scope."
        ),
        descriptor(
            "subscriptions list",
            .implemented,

            parameters: ["subscription group ID", "product/name/state filters", "sort", "limit", "output format"],
            backend: "PublicAPIReadCommands.listSubscriptions",
            notes: "Lists subscriptions through the official subscription-group relationship because the commerce trait has no top-level subscriptions collection."
        ),
        descriptor(
            "subscriptions view",
            .implemented,

            parameters: ["subscription ID", "output format"],
            backend: "PublicAPIReadCommands.getSubscription",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "subscriptions get",
            .compatibilityAlias,

            parameters: ["subscription ID", "output format"],
            backend: "PublicAPIReadCommands.getSubscription",
            notes: "Alias for subscriptions view; requires PublicAPICommerce trait."
        ),
        descriptor(
            "subscriptions create",
            .implemented,

            parameters: ["subscription group ID", "product ID", "name", "period", "group level", "family sharing", "review note", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateSubscription + createSubscription",
            notes: "Defaults to dry-run; pass --confirm to perform the trait-gated PublicAPICommerce mutation."
        ),
        descriptor(
            "subscriptions update",
            .implemented,

            parameters: ["subscription ID", "name", "period", "group level", "family sharing", "review note", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateSubscription + updateSubscription",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "subscriptions delete",
            .implemented,

            parameters: ["subscription ID", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteSubscription + deleteSubscription",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "subscriptions submit",
            .implemented,

            parameters: ["subscription ID", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planSubmitSubscription + submitSubscription",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "subscriptions localizations list",
            .implemented,

            parameters: ["subscription ID", "limit", "output format"],
            backend: "PublicAPIReadCommands.listSubscriptionLocalizations",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "subscriptions localizations view",
            .implemented,

            parameters: ["localization ID", "output format"],
            backend: "PublicAPIReadCommands.getSubscriptionLocalization",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "subscriptions localizations get",
            .compatibilityAlias,

            parameters: ["localization ID", "output format"],
            backend: "PublicAPIReadCommands.getSubscriptionLocalization",
            notes: "Alias for subscriptions localizations view."
        ),
        descriptor(
            "subscriptions localizations create",
            .implemented,

            parameters: ["subscription ID", "locale", "name", "description", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateSubscriptionLocalization + createSubscriptionLocalization",
            notes: "Defaults to dry-run; pass --confirm for live mutation."
        ),
        descriptor(
            "subscriptions localizations update",
            .implemented,

            parameters: ["localization ID", "name", "description", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateSubscriptionLocalization + updateSubscriptionLocalization",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "subscriptions localizations delete",
            .implemented,

            parameters: ["localization ID", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteSubscriptionLocalization + deleteSubscriptionLocalization",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "subscriptions localization list",
            .compatibilityAlias,

            parameters: ["same as subscriptions localizations list"],
            backend: "PublicAPIReadCommands.listSubscriptionLocalizations",
            notes: "Alias for subscriptions localizations list."
        ),
        descriptor(
            "subscriptions localization view",
            .compatibilityAlias,

            parameters: ["same as subscriptions localizations view"],
            backend: "PublicAPIReadCommands.getSubscriptionLocalization",
            notes: "Alias for subscriptions localizations view."
        ),
        descriptor(
            "subscriptions localization get",
            .compatibilityAlias,

            parameters: ["same as subscriptions localizations get"],
            backend: "PublicAPIReadCommands.getSubscriptionLocalization",
            notes: "Alias for subscriptions localizations get."
        ),
        descriptor(
            "subscriptions localization create",
            .compatibilityAlias,

            parameters: ["same as subscriptions localizations create"],
            backend: "PublicAPIWriteCommands.planCreateSubscriptionLocalization + createSubscriptionLocalization",
            notes: "Alias for subscriptions localizations create."
        ),
        descriptor(
            "subscriptions localization update",
            .compatibilityAlias,

            parameters: ["same as subscriptions localizations update"],
            backend: "PublicAPIWriteCommands.planUpdateSubscriptionLocalization + updateSubscriptionLocalization",
            notes: "Alias for subscriptions localizations update."
        ),
        descriptor(
            "subscriptions localization delete",
            .compatibilityAlias,

            parameters: ["same as subscriptions localizations delete"],
            backend: "PublicAPIWriteCommands.planDeleteSubscriptionLocalization + deleteSubscriptionLocalization",
            notes: "Alias for subscriptions localizations delete."
        ),
        descriptor(
            "subscription-groups create",
            .implemented,

            parameters: ["app ID", "reference name", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateSubscriptionGroup + createSubscriptionGroup",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "subscription-groups view",
            .implemented,

            parameters: ["subscription group ID", "output format"],
            backend: "PublicAPIReadCommands.getSubscriptionGroup",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "subscription-groups get",
            .compatibilityAlias,

            parameters: ["subscription group ID", "output format"],
            backend: "PublicAPIReadCommands.getSubscriptionGroup",
            notes: "Alias for subscription-groups view."
        ),
        descriptor(
            "subscription-groups update",
            .implemented,

            parameters: ["subscription group ID", "reference name", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateSubscriptionGroup + updateSubscriptionGroup",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "subscription-groups delete",
            .implemented,

            parameters: ["subscription group ID", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteSubscriptionGroup + deleteSubscriptionGroup",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "subscription-groups localizations list",
            .implemented,

            parameters: ["subscription group ID", "limit", "output format"],
            backend: "PublicAPIReadCommands.listSubscriptionGroupLocalizations",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "subscription-groups localizations view",
            .implemented,

            parameters: ["localization ID", "output format"],
            backend: "PublicAPIReadCommands.getSubscriptionGroupLocalization",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "subscription-groups localizations get",
            .compatibilityAlias,

            parameters: ["localization ID", "output format"],
            backend: "PublicAPIReadCommands.getSubscriptionGroupLocalization",
            notes: "Alias for subscription-groups localizations view."
        ),
        descriptor(
            "subscription-groups localizations create",
            .implemented,

            parameters: ["subscription group ID", "locale", "name", "custom app name", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateSubscriptionGroupLocalization + createSubscriptionGroupLocalization",
            notes: "Defaults to dry-run; pass --confirm for live mutation."
        ),
        descriptor(
            "subscription-groups localizations update",
            .implemented,

            parameters: ["localization ID", "name", "custom app name", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateSubscriptionGroupLocalization + updateSubscriptionGroupLocalization",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "subscription-groups localizations delete",
            .implemented,

            parameters: ["localization ID", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteSubscriptionGroupLocalization + deleteSubscriptionGroupLocalization",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "subscriptions groups create",
            .compatibilityAlias,

            parameters: ["app ID", "reference name", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateSubscriptionGroup + createSubscriptionGroup",
            notes: "Alias for subscription-groups create."
        ),
        descriptor(
            "subscriptions groups view",
            .compatibilityAlias,

            parameters: ["subscription group ID", "output format"],
            backend: "PublicAPIReadCommands.getSubscriptionGroup",
            notes: "Alias for subscription-groups view."
        ),
        descriptor(
            "subscriptions groups get",
            .compatibilityAlias,

            parameters: ["subscription group ID", "output format"],
            backend: "PublicAPIReadCommands.getSubscriptionGroup",
            notes: "Alias for subscription-groups view."
        ),
        descriptor(
            "subscriptions groups update",
            .compatibilityAlias,

            parameters: ["subscription group ID", "reference name", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateSubscriptionGroup + updateSubscriptionGroup",
            notes: "Alias for subscription-groups update."
        ),
        descriptor(
            "subscriptions groups delete",
            .compatibilityAlias,

            parameters: ["subscription group ID", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteSubscriptionGroup + deleteSubscriptionGroup",
            notes: "Alias for subscription-groups delete."
        ),
        descriptor(
            "subscriptions groups localizations list",
            .compatibilityAlias,

            parameters: ["same as subscription-groups localizations list"],
            backend: "PublicAPIReadCommands.listSubscriptionGroupLocalizations",
            notes: "Alias for subscription-groups localizations list."
        ),
        descriptor(
            "subscriptions groups localizations view",
            .compatibilityAlias,

            parameters: ["same as subscription-groups localizations view"],
            backend: "PublicAPIReadCommands.getSubscriptionGroupLocalization",
            notes: "Alias for subscription-groups localizations view."
        ),
        descriptor(
            "subscriptions groups localizations get",
            .compatibilityAlias,

            parameters: ["same as subscription-groups localizations get"],
            backend: "PublicAPIReadCommands.getSubscriptionGroupLocalization",
            notes: "Alias for subscription-groups localizations get."
        ),
        descriptor(
            "subscriptions groups localizations create",
            .compatibilityAlias,

            parameters: ["same as subscription-groups localizations create"],
            backend: "PublicAPIWriteCommands.planCreateSubscriptionGroupLocalization + createSubscriptionGroupLocalization",
            notes: "Alias for subscription-groups localizations create."
        ),
        descriptor(
            "subscriptions groups localizations update",
            .compatibilityAlias,

            parameters: ["same as subscription-groups localizations update"],
            backend: "PublicAPIWriteCommands.planUpdateSubscriptionGroupLocalization + updateSubscriptionGroupLocalization",
            notes: "Alias for subscription-groups localizations update."
        ),
        descriptor(
            "subscriptions groups localizations delete",
            .compatibilityAlias,

            parameters: ["same as subscription-groups localizations delete"],
            backend: "PublicAPIWriteCommands.planDeleteSubscriptionGroupLocalization + deleteSubscriptionGroupLocalization",
            notes: "Alias for subscription-groups localizations delete."
        ),
        descriptor(
            "win-back-offers",
            .implemented,

            parameters: ["subscription ID", "win-back offer ID", "offer metadata", "eligibility windows", "price IDs", "dry-run", "confirm", "output format"],
            backend: "PublicAPIReadCommands + PublicAPIWriteCommands",
            notes: "Canonical hyphenated command family. Price IDs reference existing official winBackOfferPrices resources; deeper price schedule helpers are follow-up scope."
        ),
        descriptor(
            "winbackoffers",
            .compatibilityAlias,

            parameters: ["same as win-back-offers"],
            backend: "AppStoreConnectCommand alias",
            notes: "Alias for win-back-offers."
        ),
        descriptor(
            "win-back-offers list",
            .implemented,

            parameters: ["subscription ID", "limit", "output format"],
            backend: "PublicAPIReadCommands.listWinBackOffers",
            notes: "Lists win-back offers through the official subscription relationship."
        ),
        descriptor(
            "win-back-offers view",
            .implemented,

            parameters: ["win-back offer ID", "output format"],
            backend: "PublicAPIReadCommands.getWinBackOffer",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "win-back-offers get",
            .compatibilityAlias,

            parameters: ["win-back offer ID", "output format"],
            backend: "PublicAPIReadCommands.getWinBackOffer",
            notes: "Alias for win-back-offers view."
        ),
        descriptor(
            "win-back-offers create",
            .implemented,

            parameters: ["subscription ID", "reference name", "offer ID", "duration", "offer mode", "period count", "eligibility months", "start/end dates", "priority", "promotion intent", "price IDs", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateWinBackOffer + createWinBackOffer",
            notes: "Defaults to dry-run; pass --confirm for live mutation."
        ),
        descriptor(
            "win-back-offers update",
            .implemented,

            parameters: ["win-back offer ID", "eligibility months", "start/end dates", "priority", "promotion intent", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateWinBackOffer + updateWinBackOffer",
            notes: "Requires at least one update field."
        ),
        descriptor(
            "win-back-offers delete",
            .implemented,

            parameters: ["win-back offer ID", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteWinBackOffer + deleteWinBackOffer",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "winbackoffers list",
            .compatibilityAlias,

            parameters: ["same as win-back-offers list"],
            backend: "PublicAPIReadCommands.listWinBackOffers",
            notes: "Alias for win-back-offers list."
        ),
        descriptor(
            "winbackoffers view",
            .compatibilityAlias,

            parameters: ["same as win-back-offers view"],
            backend: "PublicAPIReadCommands.getWinBackOffer",
            notes: "Alias for win-back-offers view."
        ),
        descriptor(
            "winbackoffers get",
            .compatibilityAlias,

            parameters: ["same as win-back-offers get"],
            backend: "PublicAPIReadCommands.getWinBackOffer",
            notes: "Alias for win-back-offers get."
        ),
        descriptor(
            "winbackoffers create",
            .compatibilityAlias,

            parameters: ["same as win-back-offers create"],
            backend: "PublicAPIWriteCommands.planCreateWinBackOffer + createWinBackOffer",
            notes: "Alias for win-back-offers create."
        ),
        descriptor(
            "winbackoffers update",
            .compatibilityAlias,

            parameters: ["same as win-back-offers update"],
            backend: "PublicAPIWriteCommands.planUpdateWinBackOffer + updateWinBackOffer",
            notes: "Alias for win-back-offers update."
        ),
        descriptor(
            "winbackoffers delete",
            .compatibilityAlias,

            parameters: ["same as win-back-offers delete"],
            backend: "PublicAPIWriteCommands.planDeleteWinBackOffer + deleteWinBackOffer",
            notes: "Alias for win-back-offers delete."
        ),
        descriptor(
            "pricing tiers",
            .implemented,

            parameters: ["app ID", "territory filter", "price point fields", "territory fields", "include relationships", "limit", "output format"],
            backend: "PublicAPIReadCommands.listAppPricePoints",
            notes: "Requires PublicAPICommerce trait."
        ),
        descriptor(
            "pricing tiers list",
            .compatibilityAlias,

            parameters: ["app ID", "territory filter", "price point fields", "territory fields", "include relationships", "limit", "output format"],
            backend: "PublicAPIReadCommands.listAppPricePoints",
            notes: "Alias for pricing tiers."
        ),
        descriptor(
            "pricing price-points",
            .compatibilityAlias,

            parameters: ["app ID", "territory filter", "price point fields", "territory fields", "include relationships", "limit", "output format"],
            backend: "PublicAPIReadCommands.listAppPricePoints",
            notes: "Alias for pricing tiers."
        ),
        descriptor(
            "pricing price-points list",
            .compatibilityAlias,

            parameters: ["app ID", "territory filter", "price point fields", "territory fields", "include relationships", "limit", "output format"],
            backend: "PublicAPIReadCommands.listAppPricePoints",
            notes: "Alias for pricing tiers."
        ),
        descriptor(
            "pricing current",
            .implemented,

            parameters: ["app ID", "schedule fields", "app price fields", "territory fields", "include relationships", "relationship limits", "output format"],
            backend: "PublicAPIReadCommands.getCurrentAppPriceSchedule",
            notes: "Reads the app's current official App Store price schedule. Requires PublicAPICommerce trait."
        ),
        descriptor(
            "pricing schedule",
            .compatibilityAlias,

            parameters: ["app ID", "schedule fields", "app price fields", "territory fields", "include relationships", "relationship limits", "output format"],
            backend: "PublicAPIReadCommands.getCurrentAppPriceSchedule",
            notes: "Compatibility alias for current schedule read; broader schedule mutations are follow-up scope."
        ),
        descriptor(
            "pricing schedule current",
            .compatibilityAlias,

            parameters: ["app ID", "schedule fields", "app price fields", "territory fields", "include relationships", "relationship limits", "output format"],
            backend: "PublicAPIReadCommands.getCurrentAppPriceSchedule",
            notes: "Alias for pricing current."
        ),
        ])
#else
        descriptors.append(contentsOf: [
        descriptor(
            "iap",
            .blocked,

            parameters: ["app/product identity", "localized payloads", "pricing", "availability", "review submission"],
            backend: "AppStoreConnectPublicAPI + AppStoreConnectIrisAPI gaps",
            notes: "Enable PublicAPICommerce for typed IAP list/view/create/update/delete/submit and localization commands. Price schedules, availability, images, offer codes, and Iris-only submission gaps are tracked follow-up scope."
        ),
        descriptor(
            "subscriptions",
            .blocked,

            parameters: ["app/group/subscription identity", "localized payloads", "pricing", "availability", "review submission"],
            backend: "AppStoreConnectPublicAPI + AppStoreConnectIrisAPI gaps",
            notes: "Enable PublicAPICommerce for typed subscription group, subscription, localization, and win-back offer commands. Offers, deeper pricing, images, availability, and Iris-only submission gaps are tracked follow-up scope."
        ),
        ])
#endif
        descriptors.append(contentsOf: [
        descriptor(
            "analytics",
            .implemented,

            parameters: ["app identity", "report type", "segment", "date range", "download path"],
            backend: "AppStoreConnectPublicAPI report download",
            notes: "Implemented via Apple analytics report/request/segment/instance OpenAPI operations."
        ),
        descriptor(
            "analytics reports view",
            .implemented,

            parameters: ["analytics report ID", "output format"],
            backend: "PublicAPIReadCommands.getAnalyticsReport"
        ),
        descriptor(
            "analytics reports get",
            .compatibilityAlias,

            parameters: ["analytics report ID", "output format"],
            backend: "PublicAPIReadCommands.getAnalyticsReport",
            notes: "Alias for analytics reports view."
        ),
        descriptor(
            "analytics request create",
            .implemented,

            parameters: ["app identity", "access type", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateAnalyticsReportRequest + createAnalyticsReportRequest"
        ),
        descriptor(
            "analytics request view",
            .implemented,

            parameters: ["analytics report request ID", "include reports", "report limit", "output format"],
            backend: "PublicAPIReadCommands.getAnalyticsReportRequest"
        ),
        descriptor(
            "analytics request get",
            .compatibilityAlias,

            parameters: ["analytics report request ID", "include reports", "report limit", "output format"],
            backend: "PublicAPIReadCommands.getAnalyticsReportRequest",
            notes: "Alias for analytics request view."
        ),
        descriptor(
            "analytics request delete",
            .implemented,

            parameters: ["analytics report request ID", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteAnalyticsReportRequest + deleteAnalyticsReportRequest"
        ),
        descriptor(
            "analytics segments view",
            .implemented,

            parameters: ["analytics report segment ID", "output format"],
            backend: "PublicAPIReadCommands.getAnalyticsReportSegment"
        ),
        descriptor(
            "analytics segments get",
            .compatibilityAlias,

            parameters: ["analytics report segment ID", "output format"],
            backend: "PublicAPIReadCommands.getAnalyticsReportSegment",
            notes: "Alias for analytics segments view."
        ),
        descriptor(
            "analytics instances view",
            .implemented,

            parameters: ["analytics report instance ID", "output format"],
            backend: "PublicAPIReadCommands.getAnalyticsReportInstance"
        ),
        descriptor(
            "analytics instances get",
            .compatibilityAlias,

            parameters: ["analytics report instance ID", "output format"],
            backend: "PublicAPIReadCommands.getAnalyticsReportInstance",
            notes: "Alias for analytics instances view."
        ),
        descriptor(
            "finance",
            .implemented,

            parameters: ["vendor number", "region", "report date", "download path"],
            backend: "AppStoreConnectPublicAPI report download",
            notes: "Implemented as finance reports/download against Apple financeReports_getCollection."
        ),
        descriptor(
            "finance reports",
            .implemented,

            parameters: ["vendor number", "report type", "region code", "report date", "download path", "output format"],
            backend: "PublicAPIReadCommands.downloadFinanceReport"
        ),
        descriptor(
            "finance download",
            .compatibilityAlias,

            parameters: ["vendor number", "report type", "region code", "report date", "download path", "output format"],
            backend: "PublicAPIReadCommands.downloadFinanceReport",
            notes: "Alias for finance reports."
        ),
        descriptor(
            "reports finance",
            .compatibilityAlias,

            parameters: ["vendor number", "report type", "region code", "report date", "download path", "output format"],
            backend: "PublicAPIReadCommands.downloadFinanceReport",
            notes: "Top-level reports alias for finance reports."
        ),
        descriptor(
            "reports sales",
            .implemented,

            parameters: ["vendor number", "report type", "report subtype", "frequency", "report date", "version", "download path", "output format"],
            backend: "PublicAPIReadCommands.downloadSalesReport"
        ),
        descriptor(
            "sales reports",
            .compatibilityAlias,

            parameters: ["vendor number", "report type", "report subtype", "frequency", "report date", "version", "download path", "output format"],
            backend: "PublicAPIReadCommands.downloadSalesReport",
            notes: "Alias for reports sales."
        ),
        descriptor(
            "signing",
            .implemented,

            parameters: ["bundle ID", "certificate/profile/device identity", "CSR/key paths", "download path", "confirm"],
            backend: "AppStoreConnectPublicAPI + local signing helpers",
            notes: "Official public API signing families are implemented through bundle-ids, certificates, profiles, and devices commands. Merchant IDs, pass type IDs, notarization, and local helper expansion are tracked follow-up scope."
        ),
        descriptor(
            "bundle-ids",
            .implemented,

            parameters: ["bundle ID identity", "identifier", "capabilities", "pagination controls"],
            backend: "AppStoreConnectPublicAPI",
            notes: "Implemented subcommands: list, view/get, create, update, delete, and capability list/enable/update/disable. Capability create/delete spellings are compatibility aliases."
        ),
        descriptor(
            "bundle-ids list",
            .implemented,

            parameters: ["bundle ID identity filter", "identifier filter", "name filter", "seed/team ID filter", "platform filter", "sort", "limit", "output format"],
            backend: "PublicAPIReadCommands.listBundleIDs"
        ),
        descriptor(
            "bundle-ids view",
            .implemented,

            parameters: ["bundle ID resource identity", "output format"],
            backend: "PublicAPIReadCommands.getBundleID"
        ),
        descriptor(
            "bundle-ids get",
            .compatibilityAlias,

            parameters: ["bundle ID resource identity", "output format"],
            backend: "PublicAPIReadCommands.getBundleID",
            notes: "Compatibility alias for canonical bundle-ids view."
        ),
        descriptor(
            "bundle-ids create",
            .implemented,

            parameters: ["bundle identifier", "display name", "platform", "seed/team ID", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateBundleID + createBundleID",
            notes: "Defaults to dry-run; pass --confirm to perform the mutation."
        ),
        descriptor(
            "bundle-ids update",
            .implemented,

            parameters: ["bundle ID resource identity", "display name", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateBundleID + updateBundleID",
            notes: "Apple's public update schema currently exposes name mutation for this selected slice."
        ),
        descriptor(
            "bundle-ids delete",
            .implemented,

            parameters: ["bundle ID resource identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteBundleID + deleteBundleID",
            notes: "Defaults to dry-run; pass --confirm to perform the mutation."
        ),
        descriptor(
            "bundle-ids capabilities list",
            .implemented,

            parameters: ["bundle ID resource identity", "fields", "pagination limit", "output format"],
            backend: "PublicAPIReadCommands.listBundleIDCapabilities"
        ),
        descriptor(
            "bundle-ids capability list",
            .compatibilityAlias,

            parameters: ["same as bundle-ids capabilities list"],
            backend: "PublicAPIReadCommands.listBundleIDCapabilities",
            notes: "Singular spelling alias for bundle-ids capabilities list."
        ),
        descriptor(
            "bundle-ids capabilities enable",
            .implemented,

            parameters: ["bundle ID resource identity", "capability type", "settings JSON/path", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateBundleIDCapability + createBundleIDCapability",
            notes: "Defaults to dry-run; pass --confirm to enable the capability."
        ),
        descriptor(
            "bundle-ids capabilities create",
            .compatibilityAlias,

            parameters: ["same as bundle-ids capabilities enable"],
            backend: "PublicAPIWriteCommands.planCreateBundleIDCapability + createBundleIDCapability",
            notes: "Alias for bundle-ids capabilities enable."
        ),
        descriptor(
            "bundle-ids capability enable",
            .compatibilityAlias,

            parameters: ["same as bundle-ids capabilities enable"],
            backend: "PublicAPIWriteCommands.planCreateBundleIDCapability + createBundleIDCapability",
            notes: "Singular spelling alias for bundle-ids capabilities enable."
        ),
        descriptor(
            "bundle-ids capability create",
            .compatibilityAlias,

            parameters: ["same as bundle-ids capabilities enable"],
            backend: "PublicAPIWriteCommands.planCreateBundleIDCapability + createBundleIDCapability",
            notes: "Singular spelling alias for bundle-ids capabilities enable."
        ),
        descriptor(
            "bundle-ids capabilities update",
            .implemented,

            parameters: ["bundle ID capability identity", "capability type", "settings JSON/path", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateBundleIDCapability + updateBundleIDCapability",
            notes: "Defaults to dry-run; pass --confirm to perform the mutation."
        ),
        descriptor(
            "bundle-ids capability update",
            .compatibilityAlias,

            parameters: ["same as bundle-ids capabilities update"],
            backend: "PublicAPIWriteCommands.planUpdateBundleIDCapability + updateBundleIDCapability",
            notes: "Singular spelling alias for bundle-ids capabilities update."
        ),
        descriptor(
            "bundle-ids capabilities disable",
            .implemented,

            parameters: ["bundle ID capability identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteBundleIDCapability + deleteBundleIDCapability",
            notes: "Defaults to dry-run; pass --confirm to disable the capability."
        ),
        descriptor(
            "bundle-ids capabilities delete",
            .compatibilityAlias,

            parameters: ["same as bundle-ids capabilities disable"],
            backend: "PublicAPIWriteCommands.planDeleteBundleIDCapability + deleteBundleIDCapability",
            notes: "Alias for bundle-ids capabilities disable."
        ),
        descriptor(
            "bundle-ids capability disable",
            .compatibilityAlias,

            parameters: ["same as bundle-ids capabilities disable"],
            backend: "PublicAPIWriteCommands.planDeleteBundleIDCapability + deleteBundleIDCapability",
            notes: "Singular spelling alias for bundle-ids capabilities disable."
        ),
        descriptor(
            "bundle-ids capability delete",
            .compatibilityAlias,

            parameters: ["same as bundle-ids capabilities disable"],
            backend: "PublicAPIWriteCommands.planDeleteBundleIDCapability + deleteBundleIDCapability",
            notes: "Singular spelling alias for bundle-ids capabilities disable."
        ),
        descriptor(
            "certificates",
            .implemented,

            parameters: ["certificate identity", "CSR/key paths", "certificate type", "download path", "confirm"],
            backend: "AppStoreConnectPublicAPI + local CSR helpers",
            notes: "Implemented subcommands: list, view/get, create, update, delete/revoke, and certificateContent download/export. CSR/keypair generation is out-of-scope-confirmed because private key material remains caller-owned; create accepts CSR content/path."
        ),
        descriptor(
            "certificates list",
            .implemented,

            parameters: ["certificate identity filter", "display name filter", "certificate type filter", "serial number filter", "sort", "limit", "output format"],
            backend: "PublicAPIReadCommands.listCertificates"
        ),
        descriptor(
            "certificates view",
            .implemented,

            parameters: ["certificate identity", "output format"],
            backend: "PublicAPIReadCommands.getCertificate"
        ),
        descriptor(
            "certificates get",
            .compatibilityAlias,

            parameters: ["certificate identity", "output format"],
            backend: "PublicAPIReadCommands.getCertificate",
            notes: "Compatibility alias for canonical certificates view."
        ),
        descriptor(
            "certificates download",
            .implemented,

            parameters: ["certificate identity", "download path", "output format"],
            backend: "PublicAPIReadCommands.downloadCertificate",
            notes: "Decodes Apple's certificateContent field and writes a .cer file from Workflow."
        ),
        descriptor(
            "certificates export",
            .compatibilityAlias,

            parameters: ["certificate identity", "download path", "output format"],
            backend: "PublicAPIReadCommands.downloadCertificate",
            notes: "Compatibility alias for canonical certificates download."
        ),
        descriptor(
            "certificates create",
            .implemented,

            parameters: ["certificate type", "CSR content or CSR file path", "merchant ID", "pass type ID", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateCertificate + createCertificate",
            notes: "CLI reads local CSR text, but CSR/keypair generation stays outside endpoint clients."
        ),
        descriptor(
            "certificates update",
            .implemented,

            parameters: ["certificate identity", "activated flag", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateCertificate + updateCertificate"
        ),
        descriptor(
            "certificates delete",
            .implemented,

            parameters: ["certificate identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteCertificate + deleteCertificate"
        ),
        descriptor(
            "certificates revoke",
            .compatibilityAlias,

            parameters: ["certificate identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteCertificate + deleteCertificate",
            notes: "Compatibility alias for canonical certificates delete."
        ),
        descriptor(
            "certificates csr",
            .outOfScopeConfirmed,

            parameters: ["private key path", "CSR output path", "certificate subject metadata"],
            backend: "caller-owned local key material",
            notes: "The package intentionally does not generate or store private keys. Use a caller-owned CSR tool, then pass --csr-path to certificates create."
        ),
        descriptor(
            "certificates generate-csr",
            .outOfScopeConfirmed,

            parameters: ["private key path", "CSR output path", "certificate subject metadata"],
            backend: "caller-owned local key material",
            notes: "Compatibility spelling for certificates csr; private key generation remains outside this package boundary."
        ),
        descriptor(
            "profiles",
            .implemented,

            parameters: ["profile identity", "bundle ID", "certificates", "devices", "download path", "confirm"],
            backend: "AppStoreConnectPublicAPI",
            notes: "Implemented subcommands: list, view/get, create, delete, and content download/export."
        ),
        descriptor(
            "profiles list",
            .implemented,

            parameters: ["profile identity filter", "name filter", "profile type filter", "profile state filter", "sort", "limit", "output format"],
            backend: "PublicAPIReadCommands.listProfiles"
        ),
        descriptor(
            "profiles view",
            .implemented,

            parameters: ["profile identity", "output format"],
            backend: "PublicAPIReadCommands.getProfile"
        ),
        descriptor(
            "profiles get",
            .compatibilityAlias,

            parameters: ["profile identity", "output format"],
            backend: "PublicAPIReadCommands.getProfile",
            notes: "Compatibility alias for canonical profiles view."
        ),
        descriptor(
            "profiles download",
            .implemented,

            parameters: ["profile identity", "download path", "output format"],
            backend: "PublicAPIReadCommands.downloadProfile",
            notes: "Reads official profileContent from profiles_getInstance, decodes base64, and writes a .mobileprovision file."
        ),
        descriptor(
            "profiles export",
            .compatibilityAlias,

            parameters: ["profile identity", "download path", "output format"],
            backend: "PublicAPIReadCommands.downloadProfile",
            notes: "Compatibility alias for canonical profiles download."
        ),
        descriptor(
            "profiles create",
            .implemented,

            parameters: ["name", "profile type", "bundle ID resource identity", "certificate identities", "device identities", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateProfile + createProfile",
            notes: "Defaults to dry-run; pass --confirm to perform the mutation."
        ),
        descriptor(
            "profiles delete",
            .implemented,

            parameters: ["profile identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteProfile + deleteProfile",
            notes: "Defaults to dry-run; pass --confirm to perform the mutation."
        ),
        descriptor(
            "devices",
            .implemented,

            parameters: ["device identity", "name", "UDID", "platform", "confirm"],
            backend: "AppStoreConnectPublicAPI",
            notes: "Implemented subcommands: list, view/get, register/create, update, enable, disable. Delete/remove is explicitly blocked because Apple's official schema exposes no device delete operation."
        ),
        descriptor(
            "devices list",
            .implemented,

            parameters: ["device identity filter", "name filter", "UDID filter", "platform filter", "status filter", "sort", "limit", "output format"],
            backend: "PublicAPIReadCommands.listDevices"
        ),
        descriptor(
            "devices view",
            .implemented,

            parameters: ["device identity", "output format"],
            backend: "PublicAPIReadCommands.getDevice"
        ),
        descriptor(
            "devices get",
            .compatibilityAlias,

            parameters: ["device identity", "output format"],
            backend: "PublicAPIReadCommands.getDevice",
            notes: "Compatibility alias for canonical devices view."
        ),
        descriptor(
            "devices register",
            .implemented,

            parameters: ["device name", "UDID", "platform", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateDevice + createDevice",
            notes: "Defaults to dry-run; pass --confirm to perform the mutation."
        ),
        descriptor(
            "devices create",
            .compatibilityAlias,

            parameters: ["device name", "UDID", "platform", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateDevice + createDevice",
            notes: "Compatibility alias for canonical devices register."
        ),
        descriptor(
            "devices update",
            .implemented,

            parameters: ["device identity", "name", "status", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateDevice + updateDevice"
        ),
        descriptor(
            "devices enable",
            .compatibilityAlias,

            parameters: ["device identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateDevice + updateDevice",
            notes: "Compatibility alias that sets Apple device status to ENABLED."
        ),
        descriptor(
            "devices disable",
            .compatibilityAlias,

            parameters: ["device identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateDevice + updateDevice",
            notes: "Compatibility alias that sets Apple device status to DISABLED."
        ),
        descriptor(
            "devices delete",
            .blocked,

            parameters: ["device identity", "dry-run", "confirm", "output format"],
            backend: "Blocked pending an official App Store Connect API device delete operation",
            notes: "Apple's official schema exposes devices_getCollection, devices_getInstance, devices_createInstance, and devices_updateInstance, but no devices_deleteInstance. Use devices disable for the supported public API flow."
        ),
        descriptor(
            "devices remove",
            .blocked,

            parameters: ["device identity", "dry-run", "confirm", "output format"],
            backend: "Blocked pending an official App Store Connect API device delete operation",
            notes: "Compatibility spelling for blocked devices delete."
        ),
        descriptor(
            "users",
            .implemented,

            parameters: ["user identity", "email", "roles", "visible apps", "pagination controls", "dry-run", "confirm", "output format"],
            backend: "AppStoreConnectPublicAPI",
            notes: "Implemented subcommands: list, view, update, delete, invite, invitations list/view/create/delete. Role and visibility mutation semantics are handled by users update. Actors/auth/web-session commands remain separate trait-gated or blocked families."
        ),
        descriptor(
            "users list",
            .implemented,

            parameters: ["username filter", "role filter", "visible app filter", "sort", "limit", "output format"],
            backend: "PublicAPIReadCommands.listUsers"
        ),
        descriptor(
            "users view",
            .implemented,

            parameters: ["user identity", "output format"],
            backend: "PublicAPIReadCommands.getUser"
        ),
        descriptor(
            "users get",
            .compatibilityAlias,

            parameters: ["user identity", "output format"],
            backend: "PublicAPIReadCommands.getUser",
            notes: "Compatibility alias for canonical users view."
        ),
        descriptor(
            "users update",
            .implemented,

            parameters: ["user identity", "roles", "all apps visible flag", "provisioning allowed flag", "visible app IDs", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateUser + updateUser"
        ),
        descriptor(
            "users roles update",
            .compatibilityAlias,

            parameters: ["user identity", "roles", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateUser + updateUser",
            notes: "Compatibility alias for canonical users update."
        ),
        descriptor(
            "users visibility update",
            .compatibilityAlias,

            parameters: ["user identity", "all apps visible flag", "visible app IDs", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planUpdateUser + updateUser",
            notes: "Compatibility alias for canonical users update."
        ),
        descriptor(
            "users delete",
            .implemented,

            parameters: ["user identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteUser + deleteUser"
        ),
        descriptor(
            "users remove",
            .compatibilityAlias,

            parameters: ["user identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteUser + deleteUser",
            notes: "Compatibility alias for canonical users delete."
        ),
        descriptor(
            "users invite",
            .compatibilityAlias,

            parameters: ["email", "first name", "last name", "roles", "visible app IDs", "all apps visible flag", "provisioning allowed flag", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateUserInvitation + createUserInvitation",
            notes: "Compatibility alias for canonical users invitations create."
        ),
        descriptor(
            "users invitations list",
            .implemented,

            parameters: ["email filter", "role filter", "visible app filter", "sort", "limit", "output format"],
            backend: "PublicAPIReadCommands.listUserInvitations"
        ),
        descriptor(
            "users invitations view",
            .implemented,

            parameters: ["user invitation identity", "output format"],
            backend: "PublicAPIReadCommands.getUserInvitation"
        ),
        descriptor(
            "users invitations get",
            .compatibilityAlias,

            parameters: ["user invitation identity", "output format"],
            backend: "PublicAPIReadCommands.getUserInvitation",
            notes: "Compatibility alias for canonical users invitations view."
        ),
        descriptor(
            "users invitations create",
            .implemented,

            parameters: ["email", "first name", "last name", "roles", "visible app IDs", "all apps visible flag", "provisioning allowed flag", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planCreateUserInvitation + createUserInvitation"
        ),
        descriptor(
            "users invitations delete",
            .implemented,

            parameters: ["user invitation identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteUserInvitation + deleteUserInvitation"
        ),
        descriptor(
            "users invitations cancel",
            .compatibilityAlias,

            parameters: ["user invitation identity", "dry-run", "confirm", "output format"],
            backend: "PublicAPIWriteCommands.planDeleteUserInvitation + deleteUserInvitation",
            notes: "Compatibility alias for canonical users invitations delete."
        ),
        descriptor(
            "actors",
            .blocked,

            parameters: ["actor identity", "pagination controls", "output format"],
            backend: "PublicAPISigningAccess trait + AppStoreConnectPublicAPI",
            notes: "Accepted subcommands: list, view/get are implemented when PublicAPISigningAccess or PublicAPIFull is enabled; the broad actors command has no default action, and live WebSession account APIs remain separate auth/web scope."
        ),
        descriptor(
            "auth",
            .implemented,

            parameters: ["session file", "environment cookies", "browser cookie file", "output format"],
            backend: "WorkflowRuntime.authCommands + AppStoreConnectWebSession",
            notes: "Canonical auth status alias. Live Apple Account login is explicitly blocked until the WebSession SRP/2FA provider exists."
        ),
        descriptor(
            "auth status",
            .implemented,

            parameters: ["session file", "environment cookies", "browser cookie file", "cookie-name disclosure", "output format"],
            backend: "AppStoreConnectAuthCommands.status",
            notes: "Checks deterministic WebSession sources without calling Iris or PublicAPI."
        ),
        descriptor(
            "auth doctor",
            .implemented,

            parameters: ["session file", "environment cookies", "browser cookie file", "cookie-name disclosure", "output format"],
            backend: "AppStoreConnectAuthCommands.doctor",
            notes: "Reports per-source WebSession diagnostics and fails closed when no usable source exists."
        ),
        descriptor(
            "auth logout",
            .implemented,

            parameters: ["session file", "dry-run", "confirm", "output format"],
            backend: "AppStoreConnectAuthCommands.planLogout + logout",
            notes: "Dry-run by default; --confirm removes only the selected local JSON web-session file."
        ),
        descriptor(
            "auth login",
            .blocked,

            parameters: ["Apple ID", "password/interactive login", "2FA", "session file"],
            backend: "Future AppStoreConnectWebSession live login provider",
            notes: "Blocked intentionally: live Apple Account SRP/2FA is not implemented; use ASC_WEB_SESSION_COOKIES or --session-file for deterministic WebSession acquisition."
        ),
        descriptor(
            "web",
            .blocked,

            parameters: ["Apple ID", "session file", "browser cookies", "capability selectors"],
            backend: "AppStoreConnectWebSession + AppStoreConnectIrisAPI",
            notes: "Accepted subcommands: auth, apps, review. Deterministic auth status/doctor/logout are implemented under auth; web apps/review require Iris endpoint ledgers and fixtures before executable CLI exposure."
        ),
        descriptor(
            "xcode",
            .implemented,

            parameters: ["project/workspace", "scheme", "archive/export paths", "version/build metadata", "dry-run", "confirm"],
            backend: "AppStoreConnectXcodeCommands",
            notes: "Local handoff family. Version executes read-only; archive/export/upload default to dry-run and require --confirm for local tool execution."
        ),
        descriptor(
            "xcode version",
            .implemented,

            parameters: ["xcodebuild path", "developer directory", "output format"],
            backend: "AppStoreConnectXcodeCommands.version",
            notes: "Executes local xcodebuild -version unless --dry-run is passed."
        ),
        descriptor(
            "xcode archive",
            .implemented,

            parameters: ["workspace or project", "scheme", "configuration", "destination", "archive path", "derived data path", "result bundle path", "allow provisioning updates", "dry-run", "confirm", "output format"],
            backend: "AppStoreConnectXcodeCommands.planArchive + archive",
            notes: "Dry-run by default; pass --confirm to invoke local xcodebuild archive."
        ),
        descriptor(
            "xcode export",
            .implemented,

            parameters: ["archive path", "export path", "export options plist", "dry-run", "confirm", "output format"],
            backend: "AppStoreConnectXcodeCommands.planExport + export",
            notes: "Dry-run by default; pass --confirm to invoke local xcodebuild -exportArchive."
        ),
        descriptor(
            "xcode upload",
            .implemented,

            parameters: ["IPA/package path", "API key", "issuer ID", "upload transport", "tool path", "dry-run", "confirm", "output format"],
            backend: "AppStoreConnectXcodeCommands.planUpload + upload",
            notes: "Dry-run by default; pass --confirm to invoke the selected local Apple upload tool."
        ),
        descriptor(
            "xcode-cloud",
            xcodeCloudFamilyStatus,

            parameters: ["product/workflow/run identity", "branch", "artifact/log selectors"],
            backend: "AppStoreConnectPublicAPI",
            notes: xcodeCloudFamilyNotes
        ),
        descriptor(
            "webhooks",
            webhooksFamilyStatus,

            parameters: ["webhook identity", "URL", "event filters", "secret", "delivery identity"],
            backend: "PublicAPIDistribution trait + AppStoreConnectPublicAPI",
            notes: webhooksFamilyNotes
        ),
        descriptor(
            "app-clips",
            appClipsFamilyStatus,

            parameters: ["app/app-clip identity", "experience identity", "locale", "payload fields"],
            backend: "PublicAPIMetadataMedia trait + AppStoreConnectPublicAPI",
            notes: appClipsFamilyNotes
        ),
        descriptor(
            "game-center",
            gameCenterFamilyStatus,

            parameters: ["app identity", "achievement/leaderboard/challenge identity", "locale", "payload fields"],
            backend: "PublicAPIGameCenter trait + AppStoreConnectPublicAPI",
            notes: gameCenterFamilyNotes
        ),
        descriptor(
            "app-events",
            appEventsFamilyStatus,

            parameters: ["app event identity", "localized payloads", "schedule", "asset paths"],
            backend: "PublicAPIRelease trait + AppStoreConnectPublicAPI",
            notes: appEventsFamilyNotes
        ),
        descriptor(
            "pricing",
            pricingFamilyStatus,

            parameters: ["app identity", "territory", "price tier", "schedule", "availability"],
            backend: "PublicAPICommerce trait + AppStoreConnectPublicAPI",
            notes: pricingFamilyNotes
        ),
        descriptor(
            "categories",
            categoryFamilyStatus,

            parameters: ["category identity", "app-info identity", "primary/secondary category", "subcategory relationships", "dry-run", "confirm", "output format"],
            backend: "PublicAPIRelease trait + AppStoreConnectPublicAPI",
            notes: categoryFamilyNotes
        ),
        descriptor(
            "age-rating",
            ageRatingFamilyStatus,

            parameters: ["app-info identity", "age-rating declaration identity", "rating declaration payload", "dry-run", "confirm", "output format"],
            backend: "PublicAPIRelease trait + AppStoreConnectPublicAPI",
            notes: ageRatingFamilyNotes
        ),
        descriptor(
            "agreements",
            .blocked,

            parameters: ["agreement identity", "territory", "output format"],
            backend: "Blocked pending an endpoint ledger outside official PublicAPI",
            notes: "Accepted subcommands: list, view. Apple's official schema exposes betaLicenseAgreements and endUserLicenseAgreements, but no generic agreements collection/instance operations; do not alias this family to EULA."
        ),
        descriptor(
            "territories",
            .blocked,

            parameters: ["territory fields", "pagination limit", "output format"],
            backend: "PublicAPIDistribution trait + AppStoreConnectPublicAPI",
            notes: "Accepted subcommand: list is implemented when PublicAPIDistribution or PublicAPIFull is enabled; the broad territories command has no default action."
        ),
        descriptor(
            "eula",
            eulaFamilyStatus,

            parameters: ["app identity", "territory", "EULA text/path", "dry-run", "confirm", "output format"],
            backend: "PublicAPIDistribution trait + AppStoreConnectPublicAPI",
            notes: eulaFamilyNotes
        ),
        descriptor(
            "marketplace",
            marketplaceFamilyStatus,

            parameters: ["marketplace identity", "app identity", "territory", "output format"],
            backend: "PublicAPIDistribution trait + AppStoreConnectPublicAPI",
            notes: marketplaceFamilyNotes
        ),
        descriptor(
            "alternative-distribution",
            alternativeDistributionFamilyStatus,

            parameters: ["app/distribution identity", "territory", "payload fields"],
            backend: "PublicAPIDistribution trait + AppStoreConnectPublicAPI",
            notes: alternativeDistributionFamilyNotes
        ),
        descriptor(
            "schema",
            .implemented,

            parameters: ["info/path subcommand", "official vendor schema", "selected schema", "trait/slice metadata", "output format"],
            backend: "AppStoreConnectCLI schema introspection",
            notes: "Local-only command that reads Vendor/AppStoreConnectOpenAPI and tracked PublicAPI generation manifests."
        ),
        descriptor(
            "schema path",
            .implemented,

            parameters: ["output format"],
            backend: "AppStoreConnectCLI schema introspection",
            notes: "Prints local paths for the official schema, selected schema, lock, audit, and trait manifest."
        ),
        descriptor(
            "completion",
            .implemented,

            parameters: ["shell"],
            backend: "AppStoreConnectCLI",
            notes: "Generates registry-backed zsh, bash, or fish completion scripts without adopting a parser dependency."
        ),
        ])
#if ASC_PUBLIC_API_METADATA_MEDIA
        descriptors.append(contentsOf: [
            descriptor(
                "app-clips list",
                .implemented,

                parameters: ["app ID", "bundle ID filters", "include default experiences", "limit", "output format"],
                backend: "PublicAPIReadCommands.listAppClips"
            ),
            descriptor(
                "app-clips view",
                .implemented,

                parameters: ["app clip ID", "include default experiences", "output format"],
                backend: "PublicAPIReadCommands.getAppClip"
            ),
            descriptor(
                "app-clips get",
                .compatibilityAlias,

                parameters: ["same as app-clips view"],
                backend: "PublicAPIReadCommands.getAppClip",
                notes: "Alias for app-clips view."
            ),
            descriptor(
                "app-clips default-experiences list",
                .implemented,

                parameters: ["app clip ID", "include localizations", "limit", "output format"],
                backend: "PublicAPIReadCommands.listAppClipDefaultExperiences"
            ),
            descriptor(
                "app-clips default-experiences view",
                .implemented,

                parameters: ["default experience ID", "include localizations", "output format"],
                backend: "PublicAPIReadCommands.getAppClipDefaultExperience"
            ),
            descriptor(
                "app-clips default-experiences get",
                .compatibilityAlias,

                parameters: ["same as app-clips default-experiences view"],
                backend: "PublicAPIReadCommands.getAppClipDefaultExperience",
                notes: "Alias for app-clips default-experiences view."
            ),
            descriptor(
                "app-clips experiences list",
                .compatibilityAlias,

                parameters: ["same as app-clips default-experiences list"],
                backend: "PublicAPIReadCommands.listAppClipDefaultExperiences",
                notes: "Short alias for default-experiences."
            ),
            descriptor(
                "app-clips experiences view",
                .compatibilityAlias,

                parameters: ["same as app-clips default-experiences view"],
                backend: "PublicAPIReadCommands.getAppClipDefaultExperience",
                notes: "Short alias for default-experiences view."
            ),
            descriptor(
                "app-clips experiences get",
                .compatibilityAlias,

                parameters: ["same as app-clips experiences view"],
                backend: "PublicAPIReadCommands.getAppClipDefaultExperience",
                notes: "Alias for app-clips experiences view."
            ),
            descriptor(
                "app-clips localizations list",
                .implemented,

                parameters: ["default experience ID", "locale filters", "limit", "output format"],
                backend: "PublicAPIReadCommands.listAppClipLocalizations"
            ),
            descriptor(
                "app-clips localizations view",
                .implemented,

                parameters: ["localization ID", "include default experience", "include header image", "output format"],
                backend: "PublicAPIReadCommands.getAppClipLocalization"
            ),
            descriptor(
                "app-clips localizations get",
                .compatibilityAlias,

                parameters: ["same as app-clips localizations view"],
                backend: "PublicAPIReadCommands.getAppClipLocalization",
                notes: "Alias for app-clips localizations view."
            ),
        ])
#endif
#if ASC_PUBLIC_API_GAME_CENTER
        descriptors.append(contentsOf: [
            descriptor(
                "game-center details app",
                .implemented,

                parameters: ["app ID", "include related achievements/leaderboards/sets/challenges", "output format"],
                backend: "PublicAPIReadCommands.getGameCenterDetailForApp"
            ),
            descriptor(
                "game-center details view",
                .implemented,

                parameters: ["Game Center detail ID", "include related achievements/leaderboards/sets/challenges", "output format"],
                backend: "PublicAPIReadCommands.getGameCenterDetail"
            ),
            descriptor(
                "game-center details get",
                .compatibilityAlias,

                parameters: ["same as game-center details view"],
                backend: "PublicAPIReadCommands.getGameCenterDetail",
                notes: "Alias for game-center details view."
            ),
            descriptor(
                "game-center achievements list",
                .implemented,

                parameters: ["Game Center detail ID", "achievement ID/reference-name filters", "archived filter", "limit", "output format"],
                backend: "PublicAPIReadCommands.listGameCenterAchievements"
            ),
            descriptor(
                "game-center achievements view",
                .implemented,

                parameters: ["achievement ID", "output format"],
                backend: "PublicAPIReadCommands.getGameCenterAchievement"
            ),
            descriptor(
                "game-center achievements get",
                .compatibilityAlias,

                parameters: ["same as game-center achievements view"],
                backend: "PublicAPIReadCommands.getGameCenterAchievement",
                notes: "Alias for game-center achievements view."
            ),
            descriptor(
                "game-center leaderboards list",
                .implemented,

                parameters: ["Game Center detail ID", "leaderboard ID/reference-name filters", "archived filter", "limit", "output format"],
                backend: "PublicAPIReadCommands.listGameCenterLeaderboards"
            ),
            descriptor(
                "game-center leaderboards view",
                .implemented,

                parameters: ["leaderboard ID", "output format"],
                backend: "PublicAPIReadCommands.getGameCenterLeaderboard"
            ),
            descriptor(
                "game-center leaderboards get",
                .compatibilityAlias,

                parameters: ["same as game-center leaderboards view"],
                backend: "PublicAPIReadCommands.getGameCenterLeaderboard",
                notes: "Alias for game-center leaderboards view."
            ),
            descriptor(
                "game-center leaderboard-sets list",
                .implemented,

                parameters: ["Game Center detail ID", "leaderboard set ID/reference-name filters", "limit", "output format"],
                backend: "PublicAPIReadCommands.listGameCenterLeaderboardSets"
            ),
            descriptor(
                "game-center leaderboard-sets view",
                .implemented,

                parameters: ["leaderboard set ID", "output format"],
                backend: "PublicAPIReadCommands.getGameCenterLeaderboardSet"
            ),
            descriptor(
                "game-center leaderboard-sets get",
                .compatibilityAlias,

                parameters: ["same as game-center leaderboard-sets view"],
                backend: "PublicAPIReadCommands.getGameCenterLeaderboardSet",
                notes: "Alias for game-center leaderboard-sets view."
            ),
            descriptor(
                "game-center challenges list",
                .implemented,

                parameters: ["Game Center detail ID", "challenge ID/reference-name filters", "archived filter", "limit", "output format"],
                backend: "PublicAPIReadCommands.listGameCenterChallenges"
            ),
            descriptor(
                "game-center challenges view",
                .implemented,

                parameters: ["challenge ID", "output format"],
                backend: "PublicAPIReadCommands.getGameCenterChallenge"
            ),
            descriptor(
                "game-center challenges get",
                .compatibilityAlias,

                parameters: ["same as game-center challenges view"],
                backend: "PublicAPIReadCommands.getGameCenterChallenge",
                notes: "Alias for game-center challenges view."
            ),
        ])
#endif
#if ASC_PUBLIC_API_SIGNING_ACCESS
        descriptors += [
            descriptor(
                "actors list",
                .implemented,

                parameters: ["actor identity filter", "actor fields", "pagination limit", "output format"],
                backend: "PublicAPIReadCommands.listActors",
                notes: "Requires PublicAPISigningAccess trait."
            ),
            descriptor(
                "actors view",
                .implemented,

                parameters: ["actor identity", "actor fields", "output format"],
                backend: "PublicAPIReadCommands.getActor",
                notes: "Requires PublicAPISigningAccess trait."
            ),
            descriptor(
                "actors get",
                .compatibilityAlias,

                parameters: ["actor identity", "actor fields", "output format"],
                backend: "PublicAPIReadCommands.getActor",
                notes: "Compatibility alias for canonical actors view."
            ),
        ]
#endif
#if ASC_PUBLIC_API_RELEASE
        descriptors += [
            descriptor(
                "categories list",
                .implemented,

                parameters: ["platform filter", "parent existence filter", "relationship includes", "pagination limit", "output format"],
                backend: "PublicAPIReadCommands.listAppCategories",
                notes: "Requires PublicAPIRelease trait."
            ),
            descriptor(
                "categories view",
                .implemented,

                parameters: ["category identity", "relationship includes", "output format"],
                backend: "PublicAPIReadCommands.getAppCategory",
                notes: "Requires PublicAPIRelease trait."
            ),
            descriptor(
                "categories get",
                .compatibilityAlias,

                parameters: ["category identity", "relationship includes", "output format"],
                backend: "PublicAPIReadCommands.getAppCategory",
                notes: "Compatibility alias for canonical categories view."
            ),
            descriptor(
                "categories parent",
                .implemented,

                parameters: ["category identity", "category fields", "output format"],
                backend: "PublicAPIReadCommands.getAppCategoryParent",
                notes: "Requires PublicAPIRelease trait."
            ),
            descriptor(
                "categories subcategories",
                .implemented,

                parameters: ["category identity", "category fields", "pagination limit", "output format"],
                backend: "PublicAPIReadCommands.listAppCategorySubcategories",
                notes: "Requires PublicAPIRelease trait."
            ),
            descriptor(
                "categories set",
                .implemented,

                parameters: ["app-info identity", "primary category", "secondary category", "subcategory relationships", "dry-run", "confirm", "output format"],
                backend: "PublicAPIWriteCommands.planUpdateAppCategory + updateAppCategory",
                notes: "Canonical category mutation command; defaults to dry-run and requires PublicAPIRelease trait."
            ),
            descriptor(
                "categories edit",
                .compatibilityAlias,

                parameters: ["same as categories set"],
                backend: "PublicAPIWriteCommands.planUpdateAppCategory + updateAppCategory",
                notes: "Compatibility alias for canonical categories set."
            ),
            descriptor(
                "categories update",
                .compatibilityAlias,

                parameters: ["same as categories set"],
                backend: "PublicAPIWriteCommands.planUpdateAppCategory + updateAppCategory",
                notes: "Compatibility alias for canonical categories set."
            ),
            descriptor(
                "age-rating view",
                .implemented,

                parameters: ["app-info identity", "age-rating fields", "output format"],
                backend: "PublicAPIReadCommands.getAgeRating",
                notes: "Requires PublicAPIRelease trait."
            ),
            descriptor(
                "age-rating get",
                .compatibilityAlias,

                parameters: ["same as age-rating view"],
                backend: "PublicAPIReadCommands.getAgeRating",
                notes: "Compatibility alias for canonical age-rating view."
            ),
            descriptor(
                "age-rating update",
                .implemented,

                parameters: ["age-rating declaration identity", "full frequency/boolean rating field map", "overrides", "kids age band", "dry-run", "confirm", "output format"],
                backend: "PublicAPIWriteCommands.planUpdateAgeRating + updateAgeRating",
                notes: "Canonical age-rating mutation command; supports --all-none and individual Apple schema rating fields."
            ),
            descriptor(
                "age-rating edit",
                .compatibilityAlias,

                parameters: ["same as age-rating update"],
                backend: "PublicAPIWriteCommands.planUpdateAgeRating + updateAgeRating",
                notes: "Compatibility alias for canonical age-rating update."
            ),
            descriptor(
                "age-rating set",
                .compatibilityAlias,

                parameters: ["same as age-rating update"],
                backend: "PublicAPIWriteCommands.planUpdateAgeRating + updateAgeRating",
                notes: "Compatibility alias for canonical age-rating update."
            ),
            descriptor(
                "app-events list",
                .implemented,

                parameters: ["app identity", "app event identity filters", "event state filters", "fields", "localization fields", "relationship includes", "pagination limit", "output format"],
                backend: "PublicAPIReadCommands.listAppEvents",
                notes: "Requires PublicAPIRelease trait."
            ),
            descriptor(
                "app-events view",
                .implemented,

                parameters: ["app event identity", "fields", "localization fields", "relationship includes", "output format"],
                backend: "PublicAPIReadCommands.getAppEvent",
                notes: "Requires PublicAPIRelease trait."
            ),
            descriptor(
                "app-events get",
                .compatibilityAlias,

                parameters: ["app event identity", "fields", "localization fields", "relationship includes", "output format"],
                backend: "PublicAPIReadCommands.getAppEvent",
                notes: "Compatibility alias for canonical app-events view."
            ),
            descriptor(
                "app-events create",
                .implemented,

                parameters: ["app identity", "reference name", "badge", "deep link", "primary locale", "priority", "purchase requirement", "purpose", "dry-run", "confirm", "output format"],
                backend: "PublicAPIWriteCommands.planCreateAppEvent + createAppEvent",
                notes: "Defaults to dry-run; pass --confirm to perform the mutation. Requires PublicAPIRelease trait."
            ),
            descriptor(
                "app-events update",
                .implemented,

                parameters: ["app event identity", "reference name", "badge", "deep link", "primary locale", "priority", "purchase requirement", "purpose", "dry-run", "confirm", "output format"],
                backend: "PublicAPIWriteCommands.planUpdateAppEvent + updateAppEvent",
                notes: "Defaults to dry-run; pass --confirm to perform the mutation. Requires PublicAPIRelease trait."
            ),
            descriptor(
                "app-events delete",
                .implemented,

                parameters: ["app event identity", "dry-run", "confirm", "output format"],
                backend: "PublicAPIWriteCommands.planDeleteAppEvent + deleteAppEvent",
                notes: "Defaults to dry-run; pass --confirm to perform the mutation. Requires PublicAPIRelease trait."
            ),
        ]
#endif
#if ASC_PUBLIC_API_DISTRIBUTION
        descriptors += [
            descriptor(
                "alternative-distribution domains list",
                .implemented,

                parameters: ["domain fields", "pagination limit", "output format"],
                backend: "PublicAPIReadCommands.listAlternativeDistributionDomains",
                notes: "Requires PublicAPIDistribution trait."
            ),
            descriptor(
                "alternative-distribution domains view",
                .implemented,

                parameters: ["domain identity", "domain fields", "output format"],
                backend: "PublicAPIReadCommands.getAlternativeDistributionDomain",
                notes: "Requires PublicAPIDistribution trait."
            ),
            descriptor(
                "alternative-distribution domains get",
                .compatibilityAlias,

                parameters: ["domain identity", "domain fields", "output format"],
                backend: "PublicAPIReadCommands.getAlternativeDistributionDomain",
                notes: "Compatibility alias for canonical alternative-distribution domains view."
            ),
            descriptor(
                "alternative-distribution keys list",
                .implemented,

                parameters: ["app relationship existence filter", "key fields", "pagination limit", "output format"],
                backend: "PublicAPIReadCommands.listAlternativeDistributionKeys",
                notes: "Requires PublicAPIDistribution trait."
            ),
            descriptor(
                "alternative-distribution keys view",
                .implemented,

                parameters: ["key identity", "key fields", "output format"],
                backend: "PublicAPIReadCommands.getAlternativeDistributionKey",
                notes: "Requires PublicAPIDistribution trait."
            ),
            descriptor(
                "alternative-distribution keys get",
                .compatibilityAlias,

                parameters: ["key identity", "key fields", "output format"],
                backend: "PublicAPIReadCommands.getAlternativeDistributionKey",
                notes: "Compatibility alias for canonical alternative-distribution keys view."
            ),
            descriptor(
                "marketplace webhooks list",
                .implemented,

                parameters: ["marketplace webhook fields", "pagination limit", "output format"],
                backend: "PublicAPIReadCommands.listMarketplaceWebhooks",
                notes: "Requires PublicAPIDistribution trait."
            ),
            descriptor(
                "webhooks list",
                .implemented,

                parameters: ["app identity", "webhook fields", "relationship includes", "pagination limit", "output format"],
                backend: "PublicAPIReadCommands.listWebhooks",
                notes: "Requires PublicAPIDistribution trait."
            ),
            descriptor(
                "webhooks view",
                .implemented,

                parameters: ["webhook identity", "webhook fields", "relationship includes", "output format"],
                backend: "PublicAPIReadCommands.getWebhook",
                notes: "Requires PublicAPIDistribution trait."
            ),
            descriptor(
                "webhooks get",
                .compatibilityAlias,

                parameters: ["webhook identity", "webhook fields", "relationship includes", "output format"],
                backend: "PublicAPIReadCommands.getWebhook",
                notes: "Compatibility alias for canonical webhooks view."
            ),
            descriptor(
                "webhooks create",
                .implemented,

                parameters: ["app identity", "name", "URL", "secret", "event types", "enabled flag", "dry-run/confirm", "output format"],
                backend: "PublicAPIWriteCommands.planCreateWebhook + createWebhook",
                notes: "Requires PublicAPIDistribution trait; dry-run redacts secret value and records only secret length."
            ),
            descriptor(
                "webhooks update",
                .implemented,

                parameters: ["webhook identity", "name", "URL", "secret", "event types", "enabled flag", "dry-run/confirm", "output format"],
                backend: "PublicAPIWriteCommands.planUpdateWebhook + updateWebhook",
                notes: "Requires PublicAPIDistribution trait; dry-run redacts secret value and records only secret length."
            ),
            descriptor(
                "webhooks delete",
                .implemented,

                parameters: ["webhook identity", "dry-run/confirm", "output format"],
                backend: "PublicAPIWriteCommands.planDeleteWebhook + deleteWebhook",
                notes: "Requires PublicAPIDistribution trait."
            ),
            descriptor(
                "webhooks remove",
                .compatibilityAlias,

                parameters: ["webhook identity", "dry-run/confirm", "output format"],
                backend: "PublicAPIWriteCommands.planDeleteWebhook + deleteWebhook",
                notes: "Compatibility alias for canonical webhooks delete."
            ),
            descriptor(
                "webhooks deliveries",
                .implemented,

                parameters: ["webhook identity", "delivery state filters", "date filters", "relationship includes", "pagination limit", "output format"],
                backend: "PublicAPIReadCommands.listWebhookDeliveries",
                notes: "Requires PublicAPIDistribution trait."
            ),
            descriptor(
                "webhooks deliveries list",
                .compatibilityAlias,

                parameters: ["webhook identity", "delivery state filters", "date filters", "relationship includes", "pagination limit", "output format"],
                backend: "PublicAPIReadCommands.listWebhookDeliveries",
                notes: "Compatibility alias for canonical webhooks deliveries."
            ),
            descriptor(
                "webhooks deliveries links",
                .implemented,

                parameters: ["webhook identity", "pagination limit", "output format"],
                backend: "PublicAPIReadCommands.listWebhookDeliveryLinkages",
                notes: "Requires PublicAPIDistribution trait."
            ),
            descriptor(
                "webhooks deliveries relationships",
                .compatibilityAlias,

                parameters: ["webhook identity", "pagination limit", "output format"],
                backend: "PublicAPIReadCommands.listWebhookDeliveryLinkages",
                notes: "Compatibility alias for canonical webhooks deliveries links."
            ),
            descriptor(
                "webhooks deliveries redeliver",
                .implemented,

                parameters: ["webhook delivery identity", "dry-run/confirm", "output format"],
                backend: "PublicAPIWriteCommands.planRedeliverWebhookDelivery + redeliverWebhookDelivery",
                notes: "Requires PublicAPIDistribution trait."
            ),
            descriptor(
                "webhooks deliveries retry",
                .compatibilityAlias,

                parameters: ["webhook delivery identity", "dry-run/confirm", "output format"],
                backend: "PublicAPIWriteCommands.planRedeliverWebhookDelivery + redeliverWebhookDelivery",
                notes: "Compatibility alias for canonical webhooks deliveries redeliver."
            ),
            descriptor(
                "webhooks ping",
                .implemented,

                parameters: ["webhook identity", "dry-run/confirm", "output format"],
                backend: "PublicAPIWriteCommands.planPingWebhook + pingWebhook",
                notes: "Requires PublicAPIDistribution trait."
            ),
            descriptor(
                "territories list",
                .implemented,

                parameters: ["territory fields", "pagination limit", "output format"],
                backend: "PublicAPIReadCommands.listTerritories",
                notes: "Requires PublicAPIDistribution trait."
            ),
            descriptor(
                "eula view",
                .implemented,

                parameters: ["EULA identity", "EULA fields", "relationship includes", "territory include limit", "output format"],
                backend: "PublicAPIReadCommands.getEULA",
                notes: "Requires PublicAPIDistribution trait."
            ),
            descriptor(
                "eula get",
                .compatibilityAlias,

                parameters: ["EULA identity", "EULA fields", "relationship includes", "territory include limit", "output format"],
                backend: "PublicAPIReadCommands.getEULA",
                notes: "Compatibility alias for canonical eula view."
            ),
            descriptor(
                "eula create",
                .implemented,

                parameters: ["app identity", "agreement text", "territory IDs", "dry-run", "confirm", "output format"],
                backend: "PublicAPIWriteCommands.planCreateEULA + createEULA",
                notes: "Requires PublicAPIDistribution trait. Agreement text can be passed inline or read from a file at the CLI boundary."
            ),
            descriptor(
                "eula update",
                .implemented,

                parameters: ["EULA identity", "agreement text", "territory IDs", "dry-run", "confirm", "output format"],
                backend: "PublicAPIWriteCommands.planUpdateEULA + updateEULA",
                notes: "Requires PublicAPIDistribution trait."
            ),
            descriptor(
                "eula edit",
                .compatibilityAlias,

                parameters: ["same as eula update"],
                backend: "PublicAPIWriteCommands.planUpdateEULA + updateEULA",
                notes: "Compatibility alias for canonical eula update."
            ),
            descriptor(
                "eula delete",
                .implemented,

                parameters: ["EULA identity", "dry-run", "confirm", "output format"],
                backend: "PublicAPIWriteCommands.planDeleteEULA + deleteEULA",
                notes: "Requires PublicAPIDistribution trait."
            ),
            descriptor(
                "eula remove",
                .compatibilityAlias,

                parameters: ["same as eula delete"],
                backend: "PublicAPIWriteCommands.planDeleteEULA + deleteEULA",
                notes: "Compatibility alias for canonical eula delete."
            ),
        ]
#endif
#if ASC_PUBLIC_API_CLOUD
        descriptors += [
            descriptor(
                "xcode-cloud products list",
                .implemented,

                parameters: ["product type filter", "app identity filter", "relationship includes", "pagination limit", "output format"],
                backend: "PublicAPIReadCommands.listXcodeCloudProducts",
                notes: "Requires PublicAPICloud trait."
            ),
            descriptor(
                "xcode-cloud products view",
                .implemented,

                parameters: ["product identity", "relationship includes", "output format"],
                backend: "PublicAPIReadCommands.getXcodeCloudProduct",
                notes: "Requires PublicAPICloud trait."
            ),
            descriptor(
                "xcode-cloud products get",
                .compatibilityAlias,

                parameters: ["product identity", "relationship includes", "output format"],
                backend: "PublicAPIReadCommands.getXcodeCloudProduct",
                notes: "Compatibility alias for canonical xcode-cloud products view."
            ),
            descriptor(
                "xcodecloud products list",
                .compatibilityAlias,

                parameters: ["product type filter", "app identity filter", "relationship includes", "pagination limit", "output format"],
                backend: "PublicAPIReadCommands.listXcodeCloudProducts",
                notes: "Hyphenless spelling alias for xcode-cloud products list."
            ),
            descriptor(
                "xcode-cloud workflows list",
                .implemented,

                parameters: ["product identity", "relationship includes", "pagination limit", "output format"],
                backend: "PublicAPIReadCommands.listXcodeCloudWorkflows",
                notes: "Requires PublicAPICloud trait."
            ),
            descriptor(
                "xcode-cloud workflows view",
                .implemented,

                parameters: ["workflow identity", "relationship includes", "output format"],
                backend: "PublicAPIReadCommands.getXcodeCloudWorkflow",
                notes: "Requires PublicAPICloud trait."
            ),
            descriptor(
                "xcode-cloud workflows get",
                .compatibilityAlias,

                parameters: ["workflow identity", "relationship includes", "output format"],
                backend: "PublicAPIReadCommands.getXcodeCloudWorkflow",
                notes: "Compatibility alias for canonical xcode-cloud workflows view."
            ),
            descriptor(
                "xcode-cloud runs list",
                .implemented,

                parameters: ["workflow or product identity", "build filters", "sort", "relationship includes", "pagination limit", "output format"],
                backend: "PublicAPIReadCommands.listXcodeCloudBuildRuns",
                notes: "Requires PublicAPICloud trait."
            ),
            descriptor(
                "xcode-cloud build-runs list",
                .compatibilityAlias,

                parameters: ["workflow or product identity", "build filters", "sort", "relationship includes", "pagination limit", "output format"],
                backend: "PublicAPIReadCommands.listXcodeCloudBuildRuns",
                notes: "Compatibility alias for canonical xcode-cloud runs list."
            ),
            descriptor(
                "xcode-cloud runs view",
                .implemented,

                parameters: ["build run identity", "relationship includes", "output format"],
                backend: "PublicAPIReadCommands.getXcodeCloudBuildRun",
                notes: "Requires PublicAPICloud trait."
            ),
            descriptor(
                "xcode-cloud runs get",
                .compatibilityAlias,

                parameters: ["build run identity", "relationship includes", "output format"],
                backend: "PublicAPIReadCommands.getXcodeCloudBuildRun",
                notes: "Compatibility alias for canonical xcode-cloud runs view."
            ),
            descriptor(
                "xcode-cloud actions list",
                .implemented,

                parameters: ["build run identity", "relationship includes", "pagination limit", "output format"],
                backend: "PublicAPIReadCommands.listXcodeCloudBuildActions",
                notes: "Requires PublicAPICloud trait."
            ),
            descriptor(
                "xcode-cloud actions view",
                .implemented,

                parameters: ["build action identity", "relationship includes", "output format"],
                backend: "PublicAPIReadCommands.getXcodeCloudBuildAction",
                notes: "Requires PublicAPICloud trait."
            ),
            descriptor(
                "xcode-cloud actions get",
                .compatibilityAlias,

                parameters: ["build action identity", "relationship includes", "output format"],
                backend: "PublicAPIReadCommands.getXcodeCloudBuildAction",
                notes: "Compatibility alias for canonical xcode-cloud actions view."
            ),
            descriptor(
                "xcode-cloud artifacts list",
                .implemented,

                parameters: ["build action identity", "artifact fields", "pagination limit", "output format"],
                backend: "PublicAPIReadCommands.listXcodeCloudArtifacts",
                notes: "Requires PublicAPICloud trait."
            ),
            descriptor(
                "xcode-cloud artifacts view",
                .implemented,

                parameters: ["artifact identity", "artifact fields", "output format"],
                backend: "PublicAPIReadCommands.getXcodeCloudArtifact",
                notes: "Requires PublicAPICloud trait."
            ),
            descriptor(
                "xcode-cloud artifacts get",
                .compatibilityAlias,

                parameters: ["artifact identity", "artifact fields", "output format"],
                backend: "PublicAPIReadCommands.getXcodeCloudArtifact",
                notes: "Compatibility alias for canonical xcode-cloud artifacts view."
            ),
            descriptor(
                "xcode-cloud logs list",
                .compatibilityAlias,

                parameters: ["build action identity", "artifact fields", "pagination limit", "output format"],
                backend: "PublicAPIReadCommands.listXcodeCloudArtifacts",
                notes: "Filters artifact summaries to LOG_BUNDLE and aliases artifact list for log discovery."
            ),
            descriptor(
                "xcode-cloud logs view",
                .compatibilityAlias,

                parameters: ["artifact/log identity", "artifact fields", "output format"],
                backend: "PublicAPIReadCommands.getXcodeCloudArtifact",
                notes: "Compatibility alias over artifact view because Apple exposes log bundles as ciArtifacts."
            ),
            descriptor(
                "xcode-cloud logs get",
                .compatibilityAlias,

                parameters: ["artifact/log identity", "artifact fields", "output format"],
                backend: "PublicAPIReadCommands.getXcodeCloudArtifact",
                notes: "Compatibility alias for xcode-cloud logs view."
            ),
        ]
#endif
#if ASC_PUBLIC_API_RELEASE
        descriptors += [
            descriptor(
                "reviews list",
                .implemented,

                parameters: ["app identity or App Store version identity", "territory", "rating filters", "published response filter", "include response", "limit", "output format"],
                backend: "PublicAPIReadCommands.listCustomerReviews"
            ),
            descriptor(
                "reviews view",
                .implemented,

                parameters: ["customer review identity", "include response", "output format"],
                backend: "PublicAPIReadCommands.getCustomerReview"
            ),
            descriptor(
                "reviews get",
                .compatibilityAlias,

                parameters: ["customer review identity", "include response", "output format"],
                backend: "PublicAPIReadCommands.getCustomerReview",
                notes: "Compatibility alias for canonical reviews view."
            ),
            descriptor(
                "reviews ratings",
                .implemented,

                parameters: ["app identity", "platform", "territory", "include territory", "limit", "output format"],
                backend: "PublicAPIReadCommands.listCustomerReviewSummarizations",
                notes: "Reads rating summaries through Apple's customerReviewSummarizations operation."
            ),
            descriptor(
                "reviews ratings list",
                .compatibilityAlias,

                parameters: ["same as reviews ratings"],
                backend: "PublicAPIReadCommands.listCustomerReviewSummarizations",
                notes: "Compatibility alias for reviews ratings."
            ),
            descriptor(
                "reviews summaries",
                .compatibilityAlias,

                parameters: ["same as reviews ratings"],
                backend: "PublicAPIReadCommands.listCustomerReviewSummarizations",
                notes: "Compatibility alias for reviews ratings."
            ),
            descriptor(
                "reviews response view",
                .implemented,

                parameters: ["customer review identity", "output format"],
                backend: "PublicAPIReadCommands.getCustomerReviewResponseForReview"
            ),
            descriptor(
                "reviews response get",
                .compatibilityAlias,

                parameters: ["customer review identity", "output format"],
                backend: "PublicAPIReadCommands.getCustomerReviewResponseForReview",
                notes: "Compatibility alias for reviews response view."
            ),
            descriptor(
                "reviews responses view",
                .implemented,

                parameters: ["customer review response identity", "output format"],
                backend: "PublicAPIReadCommands.getCustomerReviewResponse"
            ),
            descriptor(
                "reviews responses get",
                .compatibilityAlias,

                parameters: ["customer review response identity", "output format"],
                backend: "PublicAPIReadCommands.getCustomerReviewResponse",
                notes: "Compatibility alias for reviews responses view."
            ),
            descriptor(
                "reviews responses create",
                .implemented,

                parameters: ["customer review identity", "response body", "dry-run", "confirm", "output format"],
                backend: "PublicAPIWriteCommands.planCreateCustomerReviewResponse + createCustomerReviewResponse",
                notes: "Defaults to dry-run; pass --confirm to create the response."
            ),
            descriptor(
                "reviews reply",
                .compatibilityAlias,

                parameters: ["same as reviews responses create"],
                backend: "PublicAPIWriteCommands.planCreateCustomerReviewResponse + createCustomerReviewResponse",
                notes: "Compatibility alias for reviews responses create."
            ),
            descriptor(
                "reviews responses delete",
                .implemented,

                parameters: ["customer review response identity", "dry-run", "confirm", "output format"],
                backend: "PublicAPIWriteCommands.planDeleteCustomerReviewResponse + deleteCustomerReviewResponse",
                notes: "Defaults to dry-run; pass --confirm to delete the response."
            ),
            descriptor(
                "reviews responses remove",
                .compatibilityAlias,

                parameters: ["same as reviews responses delete"],
                backend: "PublicAPIWriteCommands.planDeleteCustomerReviewResponse + deleteCustomerReviewResponse",
                notes: "Compatibility alias for reviews responses delete."
            ),
        ]
#endif

#if ASC_PUBLIC_API_REPORTS
        descriptors += [
            descriptor(
                "performance",
                .implemented,

                parameters: ["app/build identity", "metric type", "platform", "device type", "download path", "output format"],
                backend: "PublicAPIReadCommands.getPerformanceMetrics + downloadPerformanceMetrics",
                notes: "Requires PublicAPIReports trait because Apple tags these operations under Apps and Builds."
            ),
            descriptor(
                "performance list",
                .implemented,

                parameters: ["app/build identity", "metric type", "platform", "device type", "output format"],
                backend: "PublicAPIReadCommands.getPerformanceMetrics"
            ),
            descriptor(
                "performance metrics",
                .compatibilityAlias,

                parameters: ["app/build identity", "metric type", "platform", "device type", "output format"],
                backend: "PublicAPIReadCommands.getPerformanceMetrics",
                notes: "Alias for performance list."
            ),
            descriptor(
                "performance download",
                .implemented,

                parameters: ["app/build identity", "metric type", "platform", "device type", "download path", "output format"],
                backend: "PublicAPIReadCommands.downloadPerformanceMetrics"
            ),
            descriptor(
                "performance metrics download",
                .compatibilityAlias,

                parameters: ["app/build identity", "metric type", "platform", "device type", "download path", "output format"],
                backend: "PublicAPIReadCommands.downloadPerformanceMetrics",
                notes: "Alias for performance download."
            ),
            descriptor(
                "insights performance",
                .compatibilityAlias,

                parameters: ["app/build identity", "metric type", "platform", "device type", "output format"],
                backend: "PublicAPIReadCommands.getPerformanceMetrics",
                notes: "Alias for performance list."
            ),
        ]
#else
        descriptors.append(
            descriptor(
                "performance",
                .blocked,

                parameters: ["app identity", "metric", "platform", "date range", "output format"],
                backend: "PublicAPIReports trait + AppStoreConnectPublicAPI",
                notes: "Accepted subcommands: list, download. Enable PublicAPIReports for typed performance metrics."
            )
        )
#endif
        return descriptors
    }

    public static func descriptor(for commandParts: [String]) -> AppStoreConnectCLICommandDescriptor? {
        let normalizedParts = commandParts.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !normalizedParts.isEmpty else {
            return nil
        }

        let requested = normalizedParts.joined(separator: " ")
        let sorted = descriptors.sorted {
            $0.command.split(separator: " ").count > $1.command.split(separator: " ").count
        }

        if let exact = sorted.first(where: { $0.command == requested }) {
            return exact
        }

        return sorted.first { descriptor in
            let descriptorParts = descriptor.command.split(separator: " ").map(String.init)
            guard let firstDescriptorPart = descriptorParts.first else {
                return false
            }
            if descriptorParts.count == 1 {
                return firstDescriptorPart == normalizedParts[0]
            }
            return normalizedParts.starts(with: descriptorParts)
        }
    }

    private static func descriptor(
        _ command: String,
        _ status: AppStoreConnectCLICommandStatus,

        parameters: [String],
        backend: String,
        notes: String? = nil
    ) -> AppStoreConnectCLICommandDescriptor {
        AppStoreConnectCLICommandDescriptor(
            command: command,
            status: status,
            parameterSemantics: parameters,
            backend: backend,
            notes: notes
        )
    }
}
