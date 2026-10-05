import AppStoreConnectPublicAPI
import AppStoreConnectWebSession
import AppStoreConnectWorkflow
import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing

@Test func dryRunReturnsPlannedSteps() {
    let plan = WorkflowRunner().dryRun(.publishTestFlight)

    #expect(plan.workflow == .publishTestFlight)
    #expect(plan.steps.map(\.name) == ["upload-build", "wait-processing", "distribute"])
    #expect(plan.steps.map(\.source) == [.uploadToolBacked, .publicAPIBacked, .publicAPIBacked])
}

@Test func publicReleaseReadinessDryRunIsSerializableAndClassified() throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let workflow = PublicReleaseReadinessWorkflow(client: publicClient)
    let plan = workflow.dryRun(.init(appID: "app-1", appStoreVersionID: "version-1", screenshotSetID: "set-1"))

    #expect(plan.workflow == .publicReleaseReadiness)
    #expect(plan.steps.map(\.name) == [
        "resolve-app",
        "inspect-builds",
        "binary-upload-boundary",
        "inspect-testflight-groups",
        "inspect-screenshot-set",
        "inspect-metadata-version",
    ])
    #expect(plan.steps.map(\.source) == [
        .publicAPIBacked,
        .publicAPIBacked,
        .uploadToolBacked,
        .publicAPIBacked,
        .publicAPIBacked,
        .publicAPIBacked,
    ])
    #expect(plan.steps.allSatisfy { !$0.mutates })
    #expect(try JSONEncoder().encode(plan).isEmpty == false)
}

@Test func publicReleaseReadinessRunUsesPublicAPIFacade() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let workflow = PublicReleaseReadinessWorkflow(client: publicClient)

    let result = await workflow.run(.init(
        appID: "app-1",
        appStoreVersionID: "version-1",
        screenshotSetID: "set-1"
    ))

    #expect(result.workflow == .publicReleaseReadiness)
    #expect(result.steps.map(\.stepID) == [
        "resolve-app",
        "inspect-builds",
        "binary-upload-boundary",
        "inspect-testflight-groups",
        "inspect-screenshot-set",
        "inspect-metadata-version",
    ])
    #expect(result.steps.map(\.status) == [
        .succeeded,
        .succeeded,
        .skipped,
        .succeeded,
        .succeeded,
        .succeeded,
    ])
    #expect(result.steps[1].outputs["buildCount"] == .integer(2))
    #expect(result.steps[3].outputs["betaGroupIDs"] == .strings(["group-1"]))
    #expect(result.steps[4].outputs["screenshotSetID"] == .string("set-1"))
    #expect(result.steps[5].outputs["appStoreVersionID"] == .string("version-1"))
    #expect(try JSONEncoder().encode(result).isEmpty == false)

    let requests = await transport.requests()
    #expect(requests.map(\.operationID) == [
        "apps_getInstance",
        "builds_getCollection",
        "betaGroups_getCollection",
        "appScreenshotSets_getInstance",
        "appStoreVersions_getInstance",
    ])
}

@Test func publicReleaseReadinessRunSkipsDependentStepsAfterAppFailure() async {
    let transport = WorkflowOpenAPITransport(failAppLookup: true)
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let workflow = PublicReleaseReadinessWorkflow(client: publicClient)

    let result = await workflow.run(.init(appID: "app-1", appStoreVersionID: "version-1", screenshotSetID: "set-1"))

    #expect(result.steps.first?.status == .failed)
    #expect(result.steps.dropFirst().allSatisfy { $0.status == .skipped })
    #expect(result.steps.first?.resumable == true)
}

@Test func authCommandsResolveEnvironmentSessionAndPlanLogout() async throws {
    let commands = AppStoreConnectAuthCommands(environment: [
        "ASC_WEB_SESSION_COOKIES": "myacinfo=token; itctx=context",
        "ASC_WEB_SESSION_ACCOUNT_EMAIL": "dev@example.com",
    ])
    let status = await commands.status(.init(includeCookieNames: true), now: Date(timeIntervalSince1970: 1_700_000_000))

    let sessionFile = temporaryFileURL("auth-session.json")
    try WebSessionFileStore(fileURL: sessionFile).save(WebSession(
        cookies: ["myacinfo": "cached-token"],
        expiresAt: Date(timeIntervalSince1970: 2_000_000_000),
        source: .environment
    ))
    let plan = AppStoreConnectAuthCommands.planLogout(.init(sessionFileURL: sessionFile))
    let logout = try commands.logout(.init(sessionFileURL: sessionFile))

    #expect(status.authenticated)
    #expect(status.source == "environment")
    #expect(status.accountEmail == "dev@example.com")
    #expect(status.cookieNames == ["itctx", "myacinfo"])
    #expect(plan.willRemove)
    #expect(logout.removed)
    #expect(!FileManager.default.fileExists(atPath: sessionFile.path))
}

@Test func xcodeCommandsPlanAndRunLocalToolHandoffs() async throws {
    let commands = AppStoreConnectXcodeCommands(runner: AppStoreConnectLocalToolRunner { invocation in
        AppStoreConnectLocalToolResult(
            exitCode: 0,
            stdout: invocation.arguments.joined(separator: " "),
            stderr: ""
        )
    })
    let input = AppStoreConnectXcodeArchiveInput(
        workspacePath: "App.xcworkspace",
        scheme: "App",
        configuration: "Release",
        destination: "generic/platform=iOS",
        archivePath: "build/App.xcarchive",
        allowProvisioningUpdates: true,
        xcodebuildPath: "/bin/echo",
        developerDirectoryPath: "/Applications/Xcode.app",
        currentDirectoryPath: "/tmp/project"
    )

    let plan = try AppStoreConnectXcodeCommands.planArchive(input)
    let result = try await commands.archive(input)

    #expect(plan.operation == "xcode-archive")
    #expect(plan.mutatesLocalFileSystem)
    #expect(plan.contactsAppleServices)
    #expect(plan.invocation.executablePath == "/bin/echo")
    #expect(plan.invocation.environment["DEVELOPER_DIR"] == "/Applications/Xcode.app")
    #expect(plan.invocation.arguments == [
        "-workspace", "App.xcworkspace",
        "-scheme", "App",
        "-configuration", "Release",
        "-destination", "generic/platform=iOS",
        "-allowProvisioningUpdates",
        "-archivePath", "build/App.xcarchive",
        "archive",
    ])
    #expect(result.succeeded)
    #expect(result.result.stdout.contains("-archivePath build/App.xcarchive archive"))
}

@Test func publicReadCommandsListAndViewAppsThroughPublicAPIFacade() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIReadCommands(client: publicClient)

    let list = try await commands.listApps(.init(
        names: ["My App"],
        bundleIDs: ["com.example.app"],
        skus: ["SKU-1"],
        sort: "name",
        limit: 10
    ))
    let view = try await commands.getApp(.init(id: "app-1"))

    #expect(list.data == [
        AppStoreConnectAppSummary(
            id: "app-1",
            name: "My App",
            bundleID: "com.example.app",
            sku: "SKU-1",
            primaryLocale: "en-US"
        ),
    ])
    #expect(list.next == "https://api.appstoreconnect.apple.com/v1/apps?page=2")
    #expect(view.data.id == "app-1")
    #expect(view.data.name == "My App")

    let requests = await transport.requests()
    #expect(requests.suffix(2).map(\.operationID) == [
        "apps_getCollection",
        "apps_getInstance",
    ])
}

@Test func publicReadCommandsViewMediaAssetsThroughPublicAPIFacade() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIReadCommands(client: publicClient)

    let screenshotSet = try await commands.getAppScreenshotSet(.init(id: "set-1", limit: 2))
    let screenshot = try await commands.getAppScreenshot(.init(id: "screenshot-1"))
    let previewSet = try await commands.getAppPreviewSet(.init(id: "preview-set-1", limit: 2))
    let preview = try await commands.getAppPreview(.init(id: "preview-1"))

    #expect(screenshotSet.data == AppStoreConnectScreenshotSetSummary(
        id: "set-1",
        displayType: "APP_IPHONE_67",
        screenshotIDs: ["screenshot-1"]
    ))
    #expect(screenshot.data.fileName == "iphone-67-1.png")
    #expect(screenshot.data.fileSize == 123_456)
    #expect(screenshot.data.assetState == "COMPLETE")
    #expect(screenshot.data.screenshotSetID == "set-1")
    #expect(previewSet.data == AppStoreConnectPreviewSetSummary(
        id: "preview-set-1",
        previewType: "IPHONE_67",
        previewIDs: ["preview-1"]
    ))
    #expect(preview.data.fileName == "iphone-67-preview.mov")
    #expect(preview.data.mimeType == "video/mp4")
    #expect(preview.data.assetState == "COMPLETE")
    #expect(preview.data.videoState == "PROCESSING")
    #expect(preview.data.previewSetID == "preview-set-1")

    let requests = await transport.requests()
    #expect(requests.suffix(4).map(\.operationID) == [
        "appScreenshotSets_getInstance",
        "appScreenshots_getInstance",
        "appPreviewSets_getInstance",
        "appPreviews_getInstance",
    ])
}

#if ASC_PUBLIC_API_RELEASE
@Test func publicReadCommandsListAndViewAppCategoriesThroughReleaseTrait() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIReadCommands(client: publicClient)

    let list = try await commands.listAppCategories(.init(
        platforms: ["IOS"],
        existsParent: false,
        includeSubcategories: true,
        limit: 10,
        subcategoriesLimit: 5
    ))
    let category = try await commands.getAppCategory(.init(
        id: "category-1",
        includeParent: true,
        includeSubcategories: true,
        subcategoriesLimit: 5
    ))
    let parent = try await commands.getAppCategoryParent(.init(id: "category-1"))
    let subcategories = try await commands.listAppCategorySubcategories(.init(id: "category-1", limit: 5))
    let ageRating = try await commands.getAgeRating(.init(appInfoID: "app-info-1"))

    #expect(list.data == [
        AppStoreConnectAppCategorySummary(
            id: "category-1",
            platforms: ["IOS"],
            subcategoryIDs: ["subcategory-1"]
        ),
    ])
    #expect(list.next == "https://api.appstoreconnect.apple.com/v1/appCategories?page=2")
    #expect(category.data == AppStoreConnectAppCategorySummary(
        id: "category-1",
        platforms: ["IOS"],
        parentID: "parent-1",
        subcategoryIDs: ["subcategory-1"]
    ))
    #expect(parent.data.id == "parent-1")
    #expect(subcategories.data == [
        AppStoreConnectAppCategorySummary(id: "subcategory-1", platforms: ["IOS"], parentID: "category-1"),
    ])
    #expect(ageRating.data.id == "age-rating-1")
    #expect(ageRating.data.frequencyRatings["violenceRealistic"] == "NONE")
    #expect(ageRating.data.booleanRatings["gambling"] == false)

    let requests = await transport.requests()
    #expect(requests.suffix(5).map(\.operationID) == [
        "appCategories_getCollection",
        "appCategories_getInstance",
        "appCategories_parent_getToOneRelated",
        "appCategories_subcategories_getToManyRelated",
        "appInfos_ageRatingDeclaration_getToOneRelated",
    ])
}
#endif

#if ASC_PUBLIC_API_RELEASE
@Test func publicReadAndWriteCommandsUseReleaseTraitForCustomerReviews() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let reads = PublicAPIReadCommands(client: publicClient)
    let writes = PublicAPIWriteCommands(client: publicClient)

    let appReviews = try await reads.listCustomerReviews(.init(
        appID: "app-1",
        territories: ["USA"],
        ratings: ["5"],
        responseExists: true,
        includeResponse: true,
        limit: 5
    ))
    let versionReviews = try await reads.listCustomerReviews(.init(
        appStoreVersionID: "version-1",
        territories: ["USA"],
        includeResponse: true,
        limit: 5
    ))
    let review = try await reads.getCustomerReview(.init(id: "customer-review-1", includeResponse: true))
    let summaries = try await reads.listCustomerReviewSummarizations(.init(
        appID: "app-1",
        platforms: ["IOS"],
        territories: ["USA"],
        includeTerritory: true,
        limit: 5
    ))
    let responseForReview = try await reads.getCustomerReviewResponseForReview(.init(reviewID: "customer-review-1"))
    let response = try await reads.getCustomerReviewResponse(.init(id: "customer-review-response-1"))
    let createInput = AppStoreConnectCustomerReviewResponseCreateInput(
        reviewID: "customer-review-1",
        responseBody: "Thanks for the review."
    )
    let createPlan = PublicAPIWriteCommands.planCreateCustomerReviewResponse(createInput)
    let deletePlan = PublicAPIWriteCommands.planDeleteCustomerReviewResponse(.init(id: "customer-review-response-1"))
    let created = try await writes.createCustomerReviewResponse(createInput)
    let deleted = try await writes.deleteCustomerReviewResponse(.init(id: "customer-review-response-1"))

    #expect(appReviews.data.first?.id == "customer-review-1")
    #expect(appReviews.data.first?.rating == 5)
    #expect(appReviews.data.first?.responseID == "customer-review-response-1")
    #expect(versionReviews.next == "https://api.appstoreconnect.apple.com/v1/appStoreVersions/version-1/customerReviews?page=2")
    #expect(review.data.title == "Great app")
    #expect(summaries.data.first?.text == "Most reviews are positive.")
    #expect(responseForReview.data.reviewID == "customer-review-1")
    #expect(response.data.state == "PUBLISHED")
    #expect(createPlan.operationID == "customerReviewResponses_createInstance")
    #expect(createPlan.dryRun)
    #expect(createPlan.inputs["reviewID"] == "customer-review-1")
    #expect(deletePlan.operationID == "customerReviewResponses_deleteInstance")
    #expect(created.data.responseBody == "Thanks for the review.")
    #expect(deleted.data.resourceType == "customerReviewResponses")

    let requests = await transport.requests()
    #expect(requests.suffix(8).map(\.operationID) == [
        "apps_customerReviews_getToManyRelated",
        "appStoreVersions_customerReviews_getToManyRelated",
        "customerReviews_getInstance",
        "apps_customerReviewSummarizations_getToManyRelated",
        "customerReviews_response_getToOneRelated",
        "customerReviewResponses_getInstance",
        "customerReviewResponses_createInstance",
        "customerReviewResponses_deleteInstance",
    ])
}
#endif

#if ASC_PUBLIC_API_RELEASE
@Test func publicWriteCommandsUseReleaseTraitForCategoriesAndAgeRating() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let writes = PublicAPIWriteCommands(client: publicClient)

    let categoryInput = AppStoreConnectAppCategoryUpdateInput(
        appInfoID: "app-info-1",
        primaryCategoryID: "GAMES",
        secondaryCategoryID: "ENTERTAINMENT",
        primarySubcategoryOneID: "GAMES_ACTION"
    )
    let ageRatingInput = AppStoreConnectAgeRatingUpdateInput(
        id: "age-rating-1",
        frequencyRatings: ["violenceRealistic": "NONE"],
        booleanRatings: ["gambling": false],
        kidsAgeBand: "NINE_TO_ELEVEN"
    )

    let categoryPlan = PublicAPIWriteCommands.planUpdateAppCategory(categoryInput)
    let ageRatingPlan = PublicAPIWriteCommands.planUpdateAgeRating(ageRatingInput)
    let category = try await writes.updateAppCategory(categoryInput)
    let ageRating = try await writes.updateAgeRating(ageRatingInput)

    #expect(categoryPlan.operationID == "appInfos_updateInstance")
    #expect(categoryPlan.dryRun)
    #expect(categoryPlan.inputs["primaryCategoryID"] == "GAMES")
    #expect(ageRatingPlan.operationID == "ageRatingDeclarations_updateInstance")
    #expect(ageRatingPlan.dryRun)
    #expect(ageRatingPlan.inputs["frequencyRatings"] == "violenceRealistic")
    #expect(category.data == AppStoreConnectAppCategoryAssignmentSummary(
        appInfoID: "app-info-1",
        primaryCategoryID: "GAMES",
        secondaryCategoryID: "ENTERTAINMENT",
        primarySubcategoryOneID: "GAMES_ACTION"
    ))
    #expect(ageRating.data.frequencyRatings["violenceRealistic"] == "NONE")
    #expect(ageRating.data.booleanRatings["gambling"] == false)
    #expect(ageRating.data.kidsAgeBand == "NINE_TO_ELEVEN")

    let requests = await transport.requests()
    #expect(requests.suffix(2).map(\.operationID) == [
        "appInfos_updateInstance",
        "ageRatingDeclarations_updateInstance",
    ])
}
#endif

#if ASC_PUBLIC_API_RELEASE
@Test func publicReadAndWriteCommandsUseReleaseTraitForAppEvents() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let reads = PublicAPIReadCommands(client: publicClient)
    let writes = PublicAPIWriteCommands(client: publicClient)

    let list = try await reads.listAppEvents(.init(
        appID: "app-1",
        eventStates: ["DRAFT"],
        includeLocalizations: true,
        limit: 10,
        localizationsLimit: 2
    ))
    let event = try await reads.getAppEvent(.init(
        id: "event-1",
        includeLocalizations: true,
        localizationsLimit: 2
    ))
    let createInput = AppStoreConnectAppEventCreateInput(
        appID: "app-1",
        referenceName: "Spring Launch",
        badge: "LIVE_EVENT",
        deepLink: "myapp://spring",
        primaryLocale: "en-US",
        priority: "HIGH",
        purchaseRequirement: "NO_COST_ASSOCIATED",
        purpose: "ATTRACT_NEW_USERS"
    )
    let updateInput = AppStoreConnectAppEventUpdateInput(
        id: "event-1",
        referenceName: "Spring Launch Updated",
        priority: "NORMAL"
    )

    let createPlan = PublicAPIWriteCommands.planCreateAppEvent(createInput)
    let updatePlan = PublicAPIWriteCommands.planUpdateAppEvent(updateInput)
    let deletePlan = PublicAPIWriteCommands.planDeleteAppEvent(.init(id: "event-1"))
    let created = try await writes.createAppEvent(createInput)
    let updated = try await writes.updateAppEvent(updateInput)
    let deleted = try await writes.deleteAppEvent(.init(id: "event-1"))

    #expect(list.data == [
        AppStoreConnectAppEventSummary(
            id: "event-1",
            referenceName: "Spring Launch",
            eventState: "DRAFT",
            badge: "LIVE_EVENT",
            priority: "HIGH",
            purpose: "ATTRACT_NEW_USERS",
            primaryLocale: "en-US",
            deepLink: "myapp://spring",
            purchaseRequirement: "NO_COST_ASSOCIATED",
            localizationIDs: ["event-loc-1"]
        ),
    ])
    #expect(list.next == "https://api.appstoreconnect.apple.com/v1/apps/app-1/appEvents?page=2")
    #expect(event.data.referenceName == "Spring Launch")
    #expect(createPlan.operationID == "appEvents_createInstance")
    #expect(updatePlan.operationID == "appEvents_updateInstance")
    #expect(deletePlan.operationID == "appEvents_deleteInstance")
    #expect(createPlan.dryRun && updatePlan.dryRun && deletePlan.dryRun)
    #expect(created.data.id == "event-2")
    #expect(updated.data.referenceName == "Spring Launch Updated")
    #expect(deleted.data.resourceType == "appEvents")

    let requests = await transport.requests()
    #expect(requests.suffix(5).map(\.operationID) == [
        "apps_appEvents_getToManyRelated",
        "appEvents_getInstance",
        "appEvents_createInstance",
        "appEvents_updateInstance",
        "appEvents_deleteInstance",
    ])
}
#endif

#if ASC_PUBLIC_API_METADATA_MEDIA
@Test func publicReadCommandsUseMetadataMediaTraitForAppClips() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIReadCommands(client: publicClient)

    let appClips = try await commands.listAppClips(.init(
        appID: "app-1",
        includeDefaultExperiences: true,
        limit: 10,
        defaultExperiencesLimit: 2
    ))
    let appClip = try await commands.getAppClip(.init(id: "app-clip-1", includeDefaultExperiences: true))
    let experiences = try await commands.listAppClipDefaultExperiences(.init(
        appClipID: "app-clip-1",
        includeLocalizations: true,
        limit: 10,
        localizationsLimit: 2
    ))
    let experience = try await commands.getAppClipDefaultExperience(.init(
        id: "experience-1",
        includeLocalizations: true
    ))
    let localizations = try await commands.listAppClipLocalizations(.init(
        defaultExperienceID: "experience-1",
        locales: ["en-US"],
        limit: 10
    ))
    let localization = try await commands.getAppClipLocalization(.init(id: "clip-loc-1"))

    #expect(appClips.data == [
        AppStoreConnectAppClipSummary(
            id: "app-clip-1",
            bundleID: "com.example.app.Clip",
            appID: "app-1",
            defaultExperienceIDs: ["experience-1"]
        ),
    ])
    #expect(appClips.next == "https://api.appstoreconnect.apple.com/v1/apps/app-1/appClips?page=2")
    #expect(appClip.data.defaultExperienceIDs == ["experience-1"])
    #expect(experiences.data == [
        AppStoreConnectAppClipDefaultExperienceSummary(
            id: "experience-1",
            action: "OPEN",
            appClipID: "app-clip-1",
            releaseWithAppStoreVersionID: "version-1",
            reviewDetailID: "review-detail-1",
            localizationIDs: ["clip-loc-1"]
        ),
    ])
    #expect(experience.data.localizationIDs == ["clip-loc-1"])
    #expect(localizations.data == [
        AppStoreConnectAppClipLocalizationSummary(
            id: "clip-loc-1",
            locale: "en-US",
            subtitle: "Launch instantly",
            defaultExperienceID: "experience-1",
            headerImageID: "header-image-1"
        ),
    ])
    #expect(localization.data.headerImageID == "header-image-1")

    let requests = await transport.requests()
    #expect(requests.suffix(6).map(\.operationID) == [
        "apps_appClips_getToManyRelated",
        "appClips_getInstance",
        "appClips_appClipDefaultExperiences_getToManyRelated",
        "appClipDefaultExperiences_getInstance",
        "appClipDefaultExperiences_appClipDefaultExperienceLocalizations_getToManyRelated",
        "appClipDefaultExperienceLocalizations_getInstance",
    ])
}
#endif

#if ASC_PUBLIC_API_GAME_CENTER
@Test func publicReadCommandsUseGameCenterTraitForGameCenterReads() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIReadCommands(client: publicClient)

    let appDetail = try await commands.getGameCenterDetailForApp(.init(
        appID: "app-1",
        includeAchievements: true,
        includeLeaderboards: true,
        includeLeaderboardSets: true,
        includeChallenges: true
    ))
    let detail = try await commands.getGameCenterDetail(.init(
        id: "gc-detail-1",
        includeAchievements: true,
        includeLeaderboards: true,
        includeLeaderboardSets: true,
        includeChallenges: true
    ))
    let achievements = try await commands.listGameCenterAchievements(.init(detailID: "gc-detail-1", limit: 10))
    let achievement = try await commands.getGameCenterAchievement(.init(id: "achievement-1"))
    let leaderboards = try await commands.listGameCenterLeaderboards(.init(detailID: "gc-detail-1", limit: 10))
    let leaderboard = try await commands.getGameCenterLeaderboard(.init(id: "leaderboard-1"))
    let leaderboardSets = try await commands.listGameCenterLeaderboardSets(.init(detailID: "gc-detail-1", limit: 10))
    let leaderboardSet = try await commands.getGameCenterLeaderboardSet(.init(id: "leaderboard-set-1"))
    let challenges = try await commands.listGameCenterChallenges(.init(detailID: "gc-detail-1", limit: 10))
    let challenge = try await commands.getGameCenterChallenge(.init(id: "challenge-1"))

    #expect(appDetail.data == AppStoreConnectGameCenterDetailSummary(
        id: "gc-detail-1",
        arcadeEnabled: true,
        challengeEnabled: true,
        appID: "app-1",
        achievementIDs: ["achievement-1"],
        leaderboardIDs: ["leaderboard-1"],
        leaderboardSetIDs: ["leaderboard-set-1"],
        challengeIDs: ["challenge-1"]
    ))
    #expect(detail.data.challengeIDs == ["challenge-1"])
    #expect(achievements.data.first?.referenceName == "First Win")
    #expect(achievement.data.points == 10)
    #expect(leaderboards.data.first?.scoreSortType == "DESC")
    #expect(leaderboard.data.leaderboardSetIDs == ["leaderboard-set-1"])
    #expect(leaderboardSets.data.first?.leaderboardIDs == ["leaderboard-1"])
    #expect(leaderboardSet.data.versionIDs == ["leaderboard-set-version-1"])
    #expect(challenges.data.first?.challengeType == "LEADERBOARD")
    #expect(challenge.data.leaderboardID == "leaderboard-1")

    let requests = await transport.requests()
    #expect(requests.suffix(10).map(\.operationID) == [
        "apps_gameCenterDetail_getToOneRelated",
        "gameCenterDetails_getInstance",
        "gameCenterDetails_gameCenterAchievementsV2_getToManyRelated",
        "gameCenterAchievementsV2_getInstance",
        "gameCenterDetails_gameCenterLeaderboardsV2_getToManyRelated",
        "gameCenterLeaderboardsV2_getInstance",
        "gameCenterDetails_gameCenterLeaderboardSetsV2_getToManyRelated",
        "gameCenterLeaderboardSetsV2_getInstance",
        "gameCenterDetails_gameCenterChallenges_getToManyRelated",
        "gameCenterChallenges_getInstance",
    ])
}
#endif

#if ASC_PUBLIC_API_DISTRIBUTION
@Test func publicReadCommandsUseDistributionTraitForMarketplaceAlternativeDistributionWebhooksTerritoriesAndEULA() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIReadCommands(client: publicClient)

    let domains = try await commands.listAlternativeDistributionDomains(.init(
        fields: ["domain", "referenceName", "createdDate"],
        limit: 2
    ))
    let domain = try await commands.getAlternativeDistributionDomain(.init(
        id: "domain-1",
        fields: ["domain", "referenceName"]
    ))
    let keys = try await commands.listAlternativeDistributionKeys(.init(
        existsApp: true,
        fields: ["publicKey"],
        limit: 2
    ))
    let key = try await commands.getAlternativeDistributionKey(.init(
        id: "key-1",
        fields: ["publicKey"]
    ))
    let marketplaceWebhooks = try await commands.listMarketplaceWebhooks(.init(
        fields: ["endpointUrl"],
        limit: 2
    ))
    let webhooks = try await commands.listWebhooks(.init(
        appID: "app-1",
        fields: ["name", "url", "enabled", "eventTypes"],
        includeApp: true,
        limit: 2
    ))
    let webhook = try await commands.getWebhook(.init(
        id: "webhook-1",
        fields: ["name", "url", "enabled"],
        includeApp: true
    ))
    let deliveries = try await commands.listWebhookDeliveries(.init(
        webhookID: "webhook-1",
        states: ["SUCCEEDED"],
        createdDateGreaterThanOrEqualTo: ["2026-05-01T00:00:00Z"],
        createdDateLessThan: ["2026-06-01T00:00:00Z"],
        fields: ["deliveryState", "createdDate", "request", "response", "event"],
        includeEvent: true,
        limit: 2
    ))
    let deliveryLinkages = try await commands.listWebhookDeliveryLinkages(.init(
        webhookID: "webhook-1",
        limit: 2
    ))
    let territories = try await commands.listTerritories(.init(fields: ["currency"], limit: 2))
    let eula = try await commands.getEULA(.init(
        id: "eula-1",
        fields: ["agreementText", "territories"],
        includeApp: true,
        includeTerritories: true,
        territoriesLimit: 2
    ))

    #expect(domains.data == [
        AppStoreConnectAlternativeDistributionDomainSummary(
            id: "domain-1",
            domain: "apps.example.com",
            referenceName: "EU Store",
            createdDate: Date(timeIntervalSince1970: 1_777_593_600)
        ),
    ])
    #expect(domains.next == "https://api.appstoreconnect.apple.com/v1/alternativeDistributionDomains?page=2")
    #expect(domain.data == AppStoreConnectAlternativeDistributionDomainSummary(
        id: "domain-1",
        domain: "apps.example.com",
        referenceName: "EU Store",
        createdDate: Date(timeIntervalSince1970: 1_777_593_600)
    ))
    #expect(keys.data == [
        AppStoreConnectAlternativeDistributionKeySummary(
            id: "key-1",
            publicKey: "public-key"
        ),
    ])
    #expect(keys.next == "https://api.appstoreconnect.apple.com/v1/alternativeDistributionKeys?page=2")
    #expect(key.data == AppStoreConnectAlternativeDistributionKeySummary(
        id: "key-1",
        publicKey: "public-key"
    ))
    #expect(marketplaceWebhooks.data == [
        AppStoreConnectMarketplaceWebhookSummary(
            id: "marketplace-webhook-1",
            endpointURL: "https://example.com/marketplace"
        ),
    ])
    #expect(marketplaceWebhooks.next == "https://api.appstoreconnect.apple.com/v1/marketplaceWebhooks?page=2")
    #expect(webhooks.data == [
        AppStoreConnectWebhookSummary(
            id: "webhook-1",
            name: "Release hook",
            url: "https://example.com/asc",
            enabled: true,
            eventTypes: ["BUILD_UPLOAD_STATE_UPDATED"],
            appID: "app-1"
        ),
    ])
    #expect(webhooks.next == "https://api.appstoreconnect.apple.com/v1/apps/app-1/webhooks?page=2")
    #expect(webhook.data == AppStoreConnectWebhookSummary(
        id: "webhook-1",
        name: "Release hook",
        url: "https://example.com/asc",
        enabled: true,
        eventTypes: ["BUILD_UPLOAD_STATE_UPDATED"],
        appID: "app-1"
    ))
    #expect(deliveries.data.first?.id == "delivery-1")
    #expect(deliveries.data.first?.deliveryState == "SUCCEEDED")
    #expect(deliveries.data.first?.requestURL == "https://example.com/asc")
    #expect(deliveries.data.first?.responseStatusCode == 200)
    #expect(deliveries.data.first?.eventID == "event-1")
    #expect(deliveryLinkages.data == [
        AppStoreConnectWebhookDeliveryLinkageSummary(id: "delivery-1", type: "webhookDeliveries"),
    ])
    #expect(deliveryLinkages.next == "https://api.appstoreconnect.apple.com/v1/webhooks/webhook-1/relationships/deliveries?page=2")
    #expect(territories.data == [
        AppStoreConnectTerritorySummary(id: "USA", currency: "USD"),
        AppStoreConnectTerritorySummary(id: "CAN", currency: "CAD"),
    ])
    #expect(territories.next == "https://api.appstoreconnect.apple.com/v1/territories?page=2")
    #expect(eula.data == AppStoreConnectEULASummary(
        id: "eula-1",
        agreementText: "Custom EULA text",
        appID: "app-1",
        territoryIDs: ["USA", "CAN"]
    ))

    let requests = await transport.requests()
    #expect(requests.suffix(11).map(\.operationID) == [
        "alternativeDistributionDomains_getCollection",
        "alternativeDistributionDomains_getInstance",
        "alternativeDistributionKeys_getCollection",
        "alternativeDistributionKeys_getInstance",
        "marketplaceWebhooks_getCollection",
        "apps_webhooks_getToManyRelated",
        "webhooks_getInstance",
        "webhooks_deliveries_getToManyRelated",
        "webhooks_deliveries_getToManyRelationship",
        "territories_getCollection",
        "endUserLicenseAgreements_getInstance",
    ])
}

@Test func publicWriteCommandsUseDistributionTraitForWebhookMutations() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIWriteCommands(client: publicClient)

    let createInput = AppStoreConnectWebhookCreateInput(
        appID: "app-1",
        name: "Release hook",
        url: "https://example.com/asc",
        secret: "super-secret",
        eventTypes: ["build-upload-state-updated"],
        enabled: true
    )
    let updateInput = AppStoreConnectWebhookUpdateInput(
        id: "webhook-1",
        name: "Release hook updated",
        url: "https://example.com/asc-updated",
        secret: "rotated-secret",
        eventTypes: ["beta.feedback.crash.submission.created"],
        enabled: false
    )
    let eulaCreateInput = AppStoreConnectEULACreateInput(
        appID: "app-1",
        agreementText: "Custom EULA text",
        territoryIDs: ["USA", "CAN"]
    )
    let eulaUpdateInput = AppStoreConnectEULAUpdateInput(
        id: "eula-1",
        agreementText: "Updated EULA text",
        territoryIDs: ["USA"]
    )

    let createPlan = PublicAPIWriteCommands.planCreateWebhook(createInput)
    let updatePlan = PublicAPIWriteCommands.planUpdateWebhook(updateInput)
    let deletePlan = PublicAPIWriteCommands.planDeleteWebhook(.init(id: "webhook-1"))
    let redeliverPlan = PublicAPIWriteCommands.planRedeliverWebhookDelivery(.init(deliveryID: "delivery-1"))
    let pingPlan = PublicAPIWriteCommands.planPingWebhook(.init(webhookID: "webhook-1"))
    let eulaCreatePlan = PublicAPIWriteCommands.planCreateEULA(eulaCreateInput)
    let eulaUpdatePlan = PublicAPIWriteCommands.planUpdateEULA(eulaUpdateInput)
    let eulaDeletePlan = PublicAPIWriteCommands.planDeleteEULA(.init(id: "eula-1"))
    let created = try await commands.createWebhook(createInput)
    let updated = try await commands.updateWebhook(updateInput)
    let deleted = try await commands.deleteWebhook(.init(id: "webhook-1"))
    let redelivered = try await commands.redeliverWebhookDelivery(.init(deliveryID: "delivery-1"))
    let pinged = try await commands.pingWebhook(.init(webhookID: "webhook-1"))
    let eulaCreated = try await commands.createEULA(eulaCreateInput)
    let eulaUpdated = try await commands.updateEULA(eulaUpdateInput)
    let eulaDeleted = try await commands.deleteEULA(.init(id: "eula-1"))

    #expect([
        createPlan.operationID,
        updatePlan.operationID,
        deletePlan.operationID,
        redeliverPlan.operationID,
        pingPlan.operationID,
        eulaCreatePlan.operationID,
        eulaUpdatePlan.operationID,
        eulaDeletePlan.operationID,
    ] == [
        "webhooks_createInstance",
        "webhooks_updateInstance",
        "webhooks_deleteInstance",
        "webhookDeliveries_createInstance",
        "webhookPings_createInstance",
        "endUserLicenseAgreements_createInstance",
        "endUserLicenseAgreements_updateInstance",
        "endUserLicenseAgreements_deleteInstance",
    ])
    #expect([createPlan, updatePlan, deletePlan, redeliverPlan, pingPlan, eulaCreatePlan, eulaUpdatePlan, eulaDeletePlan].allSatisfy { $0.dryRun })
    #expect(createPlan.inputs["secret"] == nil)
    #expect(createPlan.inputs["secretLength"] == "12")
    #expect(updatePlan.inputs["secret"] == nil)
    #expect(updatePlan.inputs["secretLength"] == "14")
    #expect(eulaCreatePlan.inputs["agreementText"] == nil)
    #expect(eulaCreatePlan.inputs["agreementTextLength"] == "16")
    #expect(eulaUpdatePlan.inputs["agreementTextLength"] == "17")
    #expect(created.data.id == "webhook-2")
    #expect(created.data.eventTypes == ["BUILD_UPLOAD_STATE_UPDATED"])
    #expect(updated.data.name == "Release hook updated")
    #expect(updated.data.enabled == false)
    #expect(updated.data.eventTypes == ["BETA_FEEDBACK_CRASH_SUBMISSION_CREATED"])
    #expect(deleted.data.resourceType == "webhooks")
    #expect(redelivered.data.id == "delivery-2")
    #expect(redelivered.data.redelivery == true)
    #expect(pinged.data == AppStoreConnectWebhookPingSummary(id: "ping-1", webhookID: "webhook-1"))
    #expect(eulaCreated.data.appID == "app-1")
    #expect(eulaCreated.data.territoryIDs == ["USA", "CAN"])
    #expect(eulaUpdated.data.agreementText == "Updated EULA text")
    #expect(eulaDeleted.data.resourceType == "endUserLicenseAgreements")

    let requests = await transport.requests()
    #expect(requests.suffix(8).map(\.operationID) == [
        "webhooks_createInstance",
        "webhooks_updateInstance",
        "webhooks_deleteInstance",
        "webhookDeliveries_createInstance",
        "webhookPings_createInstance",
        "endUserLicenseAgreements_createInstance",
        "endUserLicenseAgreements_updateInstance",
        "endUserLicenseAgreements_deleteInstance",
    ])
}
#endif

#if ASC_PUBLIC_API_CLOUD
@Test func publicReadCommandsUseCloudTraitForXcodeCloudReads() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIReadCommands(client: publicClient)

    let products = try await commands.listXcodeCloudProducts(.init(
        productTypes: ["APP"],
        appIDs: ["app-1"],
        fields: ["name", "productType", "app", "bundleId", "primaryRepositories"],
        includeApp: true,
        includeBundleID: true,
        includePrimaryRepositories: true,
        limit: 2
    ))
    let product = try await commands.getXcodeCloudProduct(.init(
        id: "ci-product-1",
        fields: ["name", "productType"],
        includeApp: true,
        includeBundleID: true
    ))
    let workflows = try await commands.listXcodeCloudWorkflows(.init(
        productID: "ci-product-1",
        fields: ["name", "isEnabled", "repository"],
        includeRepository: true,
        limit: 2
    ))
    let workflow = try await commands.getXcodeCloudWorkflow(.init(
        id: "ci-workflow-1",
        fields: ["name", "isEnabled"],
        includeRepository: true
    ))
    let workflowRuns = try await commands.listXcodeCloudBuildRuns(.init(
        workflowID: "ci-workflow-1",
        buildIDs: ["build-1"],
        sort: ["-number"],
        fields: ["number", "executionProgress", "completionStatus", "workflow", "product", "builds"],
        includeBuilds: true,
        includeWorkflow: true,
        includeProduct: true,
        limit: 2
    ))
    let productRuns = try await commands.listXcodeCloudBuildRuns(.init(
        productID: "ci-product-1",
        sort: ["number"],
        fields: ["number"],
        limit: 2
    ))
    let run = try await commands.getXcodeCloudBuildRun(.init(
        id: "ci-run-1",
        fields: ["number", "sourceCommit", "workflow", "product", "builds"],
        includeBuilds: true,
        includeWorkflow: true,
        includeProduct: true
    ))
    let actions = try await commands.listXcodeCloudBuildActions(.init(
        buildRunID: "ci-run-1",
        fields: ["name", "actionType", "executionProgress", "completionStatus", "buildRun"],
        includeBuildRun: true,
        limit: 2
    ))
    let action = try await commands.getXcodeCloudBuildAction(.init(
        id: "ci-action-1",
        fields: ["name", "actionType", "buildRun"],
        includeBuildRun: true
    ))
    let artifacts = try await commands.listXcodeCloudArtifacts(.init(
        buildActionID: "ci-action-1",
        fields: ["fileName", "fileType", "downloadUrl"],
        logOnly: false,
        limit: 2
    ))
    let logs = try await commands.listXcodeCloudArtifacts(.init(
        buildActionID: "ci-action-1",
        fields: ["fileName", "fileType", "downloadUrl"],
        logOnly: true,
        limit: 2
    ))
    let artifact = try await commands.getXcodeCloudArtifact(.init(
        id: "ci-artifact-1",
        fields: ["fileName", "fileType", "downloadUrl"]
    ))

    #expect(products.data == [
        AppStoreConnectXcodeCloudProductSummary(
            id: "ci-product-1",
            name: "My App CI",
            productType: "APP",
            createdDate: Date(timeIntervalSince1970: 1_777_593_600),
            appID: "app-1",
            bundleID: "bundle-1",
            primaryRepositoryIDs: ["repo-1"]
        ),
    ])
    #expect(products.next == "https://api.appstoreconnect.apple.com/v1/ciProducts?page=2")
    #expect(product.data.name == "My App CI")
    #expect(workflows.data.first?.id == "ci-workflow-1")
    #expect(workflows.data.first?.repositoryID == "repo-1")
    #expect(workflow.data.isEnabled == true)
    #expect(workflow.data.repositoryID == "repo-1")
    #expect(workflowRuns.data.first?.number == 42)
    #expect(workflowRuns.data.first?.completionStatus == "SUCCEEDED")
    #expect(workflowRuns.data.first?.workflowID == "ci-workflow-1")
    #expect(productRuns.data.first?.productID == "ci-product-1")
    #expect(run.data.sourceCommitSHA == "abc123")
    #expect(run.data.buildIDs == ["build-1"])
    #expect(actions.data.first?.name == "Archive")
    #expect(actions.data.first?.buildRunID == "ci-run-1")
    #expect(action.data.actionType == "ARCHIVE")
    #expect(artifacts.data.map(\.id) == ["ci-artifact-1", "ci-artifact-2"])
    #expect(logs.data.map(\.id) == ["ci-artifact-1"])
    #expect(artifact.data.fileType == "LOG_BUNDLE")

    let requests = await transport.requests()
    #expect(requests.suffix(12).map(\.operationID) == [
        "ciProducts_getCollection",
        "ciProducts_getInstance",
        "ciProducts_workflows_getToManyRelated",
        "ciWorkflows_getInstance",
        "ciWorkflows_buildRuns_getToManyRelated",
        "ciProducts_buildRuns_getToManyRelated",
        "ciBuildRuns_getInstance",
        "ciBuildRuns_actions_getToManyRelated",
        "ciBuildActions_getInstance",
        "ciBuildActions_artifacts_getToManyRelated",
        "ciBuildActions_artifacts_getToManyRelated",
        "ciArtifacts_getInstance",
    ])
}
#endif

@Test func publicReadCommandsListAndResolveBuildsThroughPublicAPIFacade() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIReadCommands(client: publicClient)

    let list = try await commands.listBuilds(.init(
        appID: "app-1",
        buildNumbers: ["42"],
        versions: ["1.2.0"],
        platforms: ["IOS"],
        processingStates: ["VALID"],
        sort: "-uploadedDate",
        limit: 5
    ))
    let byID = try await commands.getBuild(.init(id: "build-1"))
    let latest = try await commands.getBuild(.init(
        latestSelector: .init(appID: "app-1", versions: ["1.2.0"])
    ))

    #expect(list.data.count == 2)
    #expect(list.data.first?.appID == "app-1")
    #expect(list.data.first?.processingState == "VALID")
    #expect(byID.data.id == "build-1")
    #expect(latest.data.id == "build-1")

    let requests = await transport.requests()
    #expect(requests.suffix(3).map(\.operationID) == [
        "builds_getCollection",
        "builds_getInstance",
        "builds_getCollection",
    ])
}

@Test func publicReadCommandsWaitsForBuildProcessingState() async throws {
    let transport = WorkflowOpenAPITransport(buildInstanceProcessingStates: ["PROCESSING", "VALID"])
    let sleepRecorder = SleepRecorder()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIReadCommands(client: publicClient, sleep: { nanoseconds in
        await sleepRecorder.record(nanoseconds)
    })

    let result = try await commands.waitForBuild(.init(
        build: .init(id: "build-1"),
        maxAttempts: 3,
        intervalSeconds: 0.25
    ))

    #expect(result.status == .succeeded)
    #expect(result.build.processingState == "VALID")
    #expect(result.attempts.map { $0.build.processingState } == ["PROCESSING", "VALID"])
    #expect(await sleepRecorder.calls() == [250_000_000])

    let requests = await transport.requests()
    #expect(requests.suffix(2).map(\.operationID) == [
        "builds_getInstance",
        "builds_getInstance",
    ])
}

@Test func publicReadCommandsListAndViewBuildMetadataThroughPublicAPIFacade() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIReadCommands(client: publicClient)

    let details = try await commands.listBuildBetaDetails(.init(
        buildIDs: ["build-1"],
        limit: 5
    ))
    let detail = try await commands.getBuildBetaDetail(.init(id: "beta-detail-1"))
    let prereleases = try await commands.listPreReleaseVersions(.init(
        appIDs: ["app-1"],
        buildIDs: ["build-1"],
        versions: ["1.2.0"],
        buildVersions: ["42"],
        platforms: ["IOS"],
        buildAudienceTypes: ["APP_STORE_ELIGIBLE"],
        processingStates: ["VALID"],
        buildExpired: "false",
        sort: "version",
        limit: 5
    ))
    let prerelease = try await commands.getPreReleaseVersion(.init(id: "pre-1"))

    #expect(details.data.first == AppStoreConnectBuildBetaDetailSummary(
        id: "beta-detail-1",
        autoNotifyEnabled: true,
        internalBuildState: "READY_FOR_BETA_TESTING",
        externalBuildState: "READY_FOR_BETA_TESTING",
        buildID: "build-1"
    ))
    #expect(details.next == "https://api.appstoreconnect.apple.com/v1/buildBetaDetails?page=2")
    #expect(detail.data.buildID == "build-1")
    #expect(prereleases.data.first == AppStoreConnectPreReleaseVersionSummary(
        id: "pre-1",
        version: "1.2.0",
        platform: "IOS",
        appID: "app-1",
        buildIDs: ["build-1"]
    ))
    #expect(prereleases.next == "https://api.appstoreconnect.apple.com/v1/preReleaseVersions?page=2")
    #expect(prerelease.data.version == "1.2.0")

    let requests = await transport.requests()
    #expect(requests.suffix(4).map(\.operationID) == [
        "buildBetaDetails_getCollection",
        "buildBetaDetails_getInstance",
        "preReleaseVersions_getCollection",
        "preReleaseVersions_getInstance",
    ])
}

@Test func publicReadCommandsGetsSnapshotStatusThroughPublicAPIFacade() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIReadCommands(client: publicClient)

    let status = try await commands.getStatus(.init(
        appID: "app-1",
        appStoreVersionID: "version-1",
        platforms: ["IOS"],
        reviewStates: ["IN_REVIEW"],
        limit: 10
    ))

    #expect(status.app.id == "app-1")
    #expect(status.appStoreVersion?.id == "version-1")
    #expect(status.appStoreVersion?.versionString == "1.2.0")
    #expect(status.appStoreVersion?.appStoreState == "IN_REVIEW")
    #expect(status.reviewSubmissions == [
        AppStoreConnectReviewSubmissionSummary(
            id: "review-1",
            platform: "IOS",
            state: "IN_REVIEW",
            appID: "app-1",
            appStoreVersionID: "version-1"
        ),
    ])

    let requests = await transport.requests()
    #expect(requests.suffix(3).map(\.operationID) == [
        "apps_getInstance",
        "appStoreVersions_getInstance",
        "reviewSubmissions_getCollection",
    ])
}

@Test func publicReadCommandsListAndViewReviewSubmissionsThroughPublicAPIFacade() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIReadCommands(client: publicClient)

    let list = try await commands.listReviewSubmissions(.init(
        appID: "app-1",
        platforms: ["IOS"],
        states: ["IN_REVIEW"],
        limit: 5
    ))
    let view = try await commands.getReviewSubmission(.init(id: "review-1"))

    #expect(list.data == [
        AppStoreConnectReviewSubmissionSummary(
            id: "review-1",
            platform: "IOS",
            state: "IN_REVIEW",
            appID: "app-1",
            appStoreVersionID: "version-1"
        ),
    ])
    #expect(list.next == "https://api.appstoreconnect.apple.com/v1/reviewSubmissions?page=2")
    #expect(view.data.id == "review-1")
    #expect(view.data.appStoreVersionID == "version-1")

    let requests = await transport.requests()
    #expect(requests.suffix(2).map(\.operationID) == [
        "reviewSubmissions_getCollection",
        "reviewSubmissions_getInstance",
    ])
}

@Test func publicReadCommandsListAndViewAppStoreVersionsThroughPublicAPIFacade() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIReadCommands(client: publicClient)

    let list = try await commands.listAppStoreVersions(.init(
        appID: "app-1",
        versionStrings: ["1.2.0"],
        platforms: ["IOS"],
        appStoreStates: ["IN_REVIEW"],
        appVersionStates: ["ACCEPTED"],
        limit: 5
    ))
    let view = try await commands.getAppStoreVersion(.init(id: "version-1"))

    #expect(list.data == [
        AppStoreConnectAppStoreVersionSummary(
            id: "version-1",
            versionString: "1.2.0",
            platform: "IOS",
            appStoreState: "IN_REVIEW",
            appVersionState: "ACCEPTED",
            releaseType: "MANUAL"
        ),
    ])
    #expect(list.next == "https://api.appstoreconnect.apple.com/v1/apps/app-1/appStoreVersions?page=2")
    #expect(view.data.id == "version-1")
    #expect(view.data.versionString == "1.2.0")

    let requests = await transport.requests()
    #expect(requests.suffix(2).map(\.operationID) == [
        "apps_appStoreVersions_getToManyRelated",
        "appStoreVersions_getInstance",
    ])
}

@Test func publicReadCommandsListAndViewTestFlightResourcesThroughPublicAPIFacade() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIReadCommands(client: publicClient)

    let groups = try await commands.listBetaGroups(.init(
        appID: "app-1",
        names: ["Internal Testers"],
        isInternalGroup: "true",
        publicLinkEnabled: "false",
        sort: "name",
        limit: 5
    ))
    let group = try await commands.getBetaGroup(.init(id: "group-1"))
    let testers = try await commands.listBetaTesters(.init(
        appIDs: ["app-1"],
        betaGroupIDs: ["group-1"],
        emails: ["tester@example.com"],
        inviteTypes: ["EMAIL"],
        sort: "email",
        limit: 10
    ))
    let tester = try await commands.getBetaTester(.init(id: "tester-1"))

    #expect(groups.data.first == AppStoreConnectBetaGroupSummary(
        id: "group-1",
        name: "Internal Testers",
        isInternalGroup: true,
        publicLinkEnabled: false,
        publicLinkLimit: 100,
        feedbackEnabled: true,
        appID: "app-1"
    ))
    #expect(groups.next == "https://api.appstoreconnect.apple.com/v1/betaGroups?page=2")
    #expect(group.data.id == "group-1")
    #expect(testers.data.first == AppStoreConnectBetaTesterSummary(
        id: "tester-1",
        email: "tester@example.com",
        firstName: "Test",
        lastName: "User",
        state: "INVITED",
        inviteType: "EMAIL",
        appIDs: ["app-1"],
        betaGroupIDs: ["group-1"]
    ))
    #expect(tester.data.id == "tester-1")

    let requests = await transport.requests()
    #expect(requests.suffix(4).map(\.operationID) == [
        "betaGroups_getCollection",
        "betaGroups_getInstance",
        "betaTesters_getCollection",
        "betaTesters_getInstance",
    ])
}

@Test func publicReadCommandsListAndViewTestFlightMetadataThroughPublicAPIFacade() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIReadCommands(client: publicClient)

    let appLocalizations = try await commands.listBetaAppLocalizations(.init(
        appIDs: ["app-1"],
        locales: ["en-US"],
        limit: 5
    ))
    let appLocalization = try await commands.getBetaAppLocalization(.init(id: "beta-app-loc-1"))
    let buildLocalizations = try await commands.listBetaBuildLocalizations(.init(
        buildIDs: ["build-1"],
        locales: ["en-US"],
        limit: 5
    ))
    let buildLocalization = try await commands.getBetaBuildLocalization(.init(id: "beta-build-loc-1"))
    let reviewDetails = try await commands.listBetaAppReviewDetails(.init(appID: "app-1", limit: 5))
    let reviewDetail = try await commands.getBetaAppReviewDetail(.init(id: "beta-review-detail-1"))
    let reviewSubmissions = try await commands.listBetaAppReviewSubmissions(.init(
        buildIDs: ["build-1"],
        betaReviewStates: ["IN_REVIEW"],
        limit: 5
    ))
    let reviewSubmission = try await commands.getBetaAppReviewSubmission(.init(id: "beta-review-submission-1"))
    let agreements = try await commands.listBetaLicenseAgreements(.init(appIDs: ["app-1"], limit: 5))
    let agreement = try await commands.getBetaLicenseAgreement(.init(id: "beta-license-1"))

    #expect(appLocalizations.data.first == AppStoreConnectBetaAppLocalizationSummary(
        id: "beta-app-loc-1",
        locale: "en-US",
        description: "Join the beta",
        feedbackEmail: "beta@example.com",
        marketingURL: "https://example.com/beta",
        privacyPolicyURL: "https://example.com/privacy",
        tvOSPrivacyPolicy: "TV privacy",
        appID: "app-1"
    ))
    #expect(appLocalization.data.id == "beta-app-loc-1")
    #expect(buildLocalizations.data.first == AppStoreConnectBetaBuildLocalizationSummary(
        id: "beta-build-loc-1",
        locale: "en-US",
        whatsNew: "Bug fixes",
        buildID: "build-1"
    ))
    #expect(buildLocalization.data.id == "beta-build-loc-1")
    #expect(reviewDetails.data.first == AppStoreConnectBetaAppReviewDetailSummary(
        id: "beta-review-detail-1",
        contactEmail: "review@example.com",
        contactFirstName: "Review",
        contactLastName: "Owner",
        contactPhone: "+15551234567",
        demoAccountName: "demo@example.com",
        demoAccountRequired: true,
        notes: "Use the demo account.",
        appID: "app-1"
    ))
    #expect(reviewDetail.data.id == "beta-review-detail-1")
    #expect(reviewSubmissions.data.first?.id == "beta-review-submission-1")
    #expect(reviewSubmissions.data.first?.betaReviewState == "IN_REVIEW")
    #expect(reviewSubmissions.data.first?.buildID == "build-1")
    #expect(reviewSubmission.data.id == "beta-review-submission-1")
    #expect(agreements.data.first == AppStoreConnectBetaLicenseAgreementSummary(
        id: "beta-license-1",
        agreementText: "Beta license text",
        appID: "app-1"
    ))
    #expect(agreement.data.id == "beta-license-1")

    let requests = await transport.requests()
    #expect(requests.suffix(10).map(\.operationID) == [
        "betaAppLocalizations_getCollection",
        "betaAppLocalizations_getInstance",
        "betaBuildLocalizations_getCollection",
        "betaBuildLocalizations_getInstance",
        "betaAppReviewDetails_getCollection",
        "betaAppReviewDetails_getInstance",
        "betaAppReviewSubmissions_getCollection",
        "betaAppReviewSubmissions_getInstance",
        "betaLicenseAgreements_getCollection",
        "betaLicenseAgreements_getInstance",
    ])
}

@Test func publicReadCommandsListAndViewTestFlightFeedbackAndCrashesThroughPublicAPIFacade() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIReadCommands(client: publicClient)

    let crashSubmissions = try await commands.listBetaFeedbackCrashSubmissions(.init(
        appID: "app-1",
        deviceModels: ["iPhone 15"],
        osVersions: ["17.4"],
        appPlatforms: ["IOS"],
        devicePlatforms: ["IOS"],
        buildIDs: ["build-1"],
        testerIDs: ["tester-1"],
        sort: "-createdDate",
        limit: 5
    ))
    let crashSubmission = try await commands.getBetaFeedbackCrashSubmission(.init(id: "crash-feedback-1"))
    let relatedCrashLog = try await commands.getCrashLogForBetaFeedbackCrashSubmission(.init(id: "crash-feedback-1"))
    let crashLog = try await commands.getBetaCrashLog(.init(id: "crash-log-1"))
    let screenshotSubmissions = try await commands.listBetaFeedbackScreenshotSubmissions(.init(
        appID: "app-1",
        deviceModels: ["iPhone 15"],
        osVersions: ["17.4"],
        appPlatforms: ["IOS"],
        devicePlatforms: ["IOS"],
        buildIDs: ["build-1"],
        testerIDs: ["tester-1"],
        sort: "createdDate",
        limit: 5
    ))
    let screenshotSubmission = try await commands.getBetaFeedbackScreenshotSubmission(.init(id: "screenshot-feedback-1"))

    #expect(crashSubmissions.data.first?.id == "crash-feedback-1")
    #expect(crashSubmissions.data.first?.comment == "It crashed")
    #expect(crashSubmissions.data.first?.deviceModel == "iPhone 15")
    #expect(crashSubmissions.data.first?.appPlatform == "IOS")
    #expect(crashSubmissions.data.first?.buildID == "build-1")
    #expect(crashSubmissions.data.first?.testerID == "tester-1")
    #expect(crashSubmissions.data.first?.createdDate != nil)
    #expect(crashSubmissions.next == "https://api.appstoreconnect.apple.com/v1/apps/app-1/betaFeedbackCrashSubmissions?page=2")
    #expect(crashSubmission.data.id == "crash-feedback-1")
    #expect(relatedCrashLog.data.logText == "Thread 0 crashed")
    #expect(crashLog.data.id == "crash-log-1")
    #expect(screenshotSubmissions.data.first?.id == "screenshot-feedback-1")
    #expect(screenshotSubmissions.data.first?.screenshotCount == 2)
    #expect(screenshotSubmissions.data.first?.buildID == "build-1")
    #expect(screenshotSubmission.data.screenshotCount == 2)

    let requests = await transport.requests()
    #expect(requests.suffix(6).map(\.operationID) == [
        "apps_betaFeedbackCrashSubmissions_getToManyRelated",
        "betaFeedbackCrashSubmissions_getInstance",
        "betaFeedbackCrashSubmissions_crashLog_getToOneRelated",
        "betaCrashLogs_getInstance",
        "apps_betaFeedbackScreenshotSubmissions_getToManyRelated",
        "betaFeedbackScreenshotSubmissions_getInstance",
    ])
}

@Test func publicReadCommandsGetTestFlightMetricsThroughPublicAPIFacade() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIReadCommands(client: publicClient)

    let appTesterMetrics = try await commands.getAppBetaTesterUsageMetrics(.init(
        appID: "app-1",
        betaTesterID: "tester-1",
        period: "P7D",
        groupByBetaTesters: true,
        limit: 5
    ))
    let groupTesterMetrics = try await commands.getBetaGroupBetaTesterUsageMetrics(.init(
        groupID: "group-1",
        betaTesterID: "tester-1",
        period: "P30D",
        groupByBetaTesters: true,
        limit: 5
    ))
    let testerMetrics = try await commands.getBetaTesterUsageMetrics(.init(
        testerID: "tester-1",
        appID: "app-1",
        period: "P90D",
        limit: 5
    ))
    let publicLinkMetrics = try await commands.getBetaGroupPublicLinkUsageMetrics(.init(
        groupID: "group-1",
        limit: 5
    ))
    let buildMetrics = try await commands.getBetaBuildUsageMetrics(.init(
        buildID: "build-1",
        limit: 5
    ))

    #expect(appTesterMetrics.data.first?.scope == "app")
    #expect(appTesterMetrics.data.first?.appID == "app-1")
    #expect(appTesterMetrics.data.first?.testerID == "tester-1")
    #expect(appTesterMetrics.data.first?.dataPoints.first?.sessionCount == 12)
    #expect(groupTesterMetrics.data.first?.scope == "group")
    #expect(groupTesterMetrics.data.first?.groupID == "group-1")
    #expect(groupTesterMetrics.data.first?.dataPoints.first?.crashCount == 1)
    #expect(testerMetrics.data.first?.scope == "tester")
    #expect(testerMetrics.data.first?.appID == "app-1")
    #expect(testerMetrics.data.first?.dataPoints.first?.feedbackCount == 2)
    #expect(publicLinkMetrics.data.first?.groupID == "group-1")
    #expect(publicLinkMetrics.data.first?.dataPoints.first?.viewCount == 100)
    #expect(publicLinkMetrics.data.first?.dataPoints.first?.notRelevantRatio == 0.3)
    #expect(buildMetrics.data.first?.buildID == "build-1")
    #expect(buildMetrics.data.first?.dataPoints.first?.installCount == 20)
    #expect(buildMetrics.data.first?.dataPoints.first?.inviteCount == 25)

    let requests = await transport.requests()
    #expect(requests.suffix(5).map(\.operationID) == [
        "apps_betaTesterUsages_getMetrics",
        "betaGroups_betaTesterUsages_getMetrics",
        "betaTesters_betaTesterUsages_getMetrics",
        "betaGroups_publicLinkUsages_getMetrics",
        "builds_betaBuildUsages_getMetrics",
    ])
}

@Test func publicWriteCommandsPlanAndCreateBetaTesterInvitationThroughPublicAPIFacade() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIWriteCommands(client: publicClient)
    let input = AppStoreConnectBetaTesterInvitationCreateInput(appID: "app-1")

    let plan = PublicAPIWriteCommands.planCreateBetaTesterInvitation(input)
    let result = try await commands.createBetaTesterInvitation(input)

    #expect(plan.operationID == "betaTesterInvitations_createInstance")
    #expect(plan.source == .publicAPIBacked)
    #expect(plan.mutates)
    #expect(plan.dryRun)
    #expect(plan.inputs["appID"] == "app-1")
    #expect(result.data == AppStoreConnectBetaTesterInvitationSummary(id: "invitation-1", appID: "app-1"))

    let requests = await transport.requests()
    #expect(requests.suffix(1).map(\.operationID) == [
        "betaTesterInvitations_createInstance",
    ])
}

@Test func publicWriteCommandsMutateTestFlightResourcesThroughPublicAPIFacade() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIWriteCommands(client: publicClient)

    let groupCreate = AppStoreConnectBetaGroupCreateInput(
        appID: "app-1",
        name: "External Testers",
        feedbackEnabled: true,
        publicLinkEnabled: true,
        betaTesterIDs: ["tester-1"],
        buildIDs: ["build-1"]
    )
    let groupUpdate = AppStoreConnectBetaGroupUpdateInput(
        id: "group-1",
        name: "Renamed Testers",
        publicLinkEnabled: false
    )
    let testerCreate = AppStoreConnectBetaTesterCreateInput(
        email: "tester@example.com",
        firstName: "Test",
        lastName: "User",
        betaGroupIDs: ["group-1"]
    )
    let reviewDetailUpdate = AppStoreConnectBetaAppReviewDetailUpdateInput(
        id: "review-detail-1",
        contactEmail: "qa@example.com",
        demoAccountRequired: true,
        notes: "Ready for beta review."
    )
    let reviewSubmissionCreate = AppStoreConnectBetaAppReviewSubmissionCreateInput(buildID: "build-1")

    let createGroupPlan = PublicAPIWriteCommands.planCreateBetaGroup(groupCreate)
    let updateGroupPlan = PublicAPIWriteCommands.planUpdateBetaGroup(groupUpdate)
    let deleteGroupPlan = PublicAPIWriteCommands.planDeleteBetaGroup(.init(id: "group-1"))
    let createTesterPlan = PublicAPIWriteCommands.planCreateBetaTester(testerCreate)
    let deleteTesterPlan = PublicAPIWriteCommands.planDeleteBetaTester(.init(id: "tester-1"))
    let reviewDetailPlan = PublicAPIWriteCommands.planUpdateBetaAppReviewDetail(reviewDetailUpdate)
    let reviewSubmissionPlan = PublicAPIWriteCommands.planCreateBetaAppReviewSubmission(reviewSubmissionCreate)

    let createdGroup = try await commands.createBetaGroup(groupCreate)
    let updatedGroup = try await commands.updateBetaGroup(groupUpdate)
    let deletedGroup = try await commands.deleteBetaGroup(.init(id: "group-1"))
    let createdTester = try await commands.createBetaTester(testerCreate)
    let deletedTester = try await commands.deleteBetaTester(.init(id: "tester-1"))
    let updatedReviewDetail = try await commands.updateBetaAppReviewDetail(reviewDetailUpdate)
    let createdReviewSubmission = try await commands.createBetaAppReviewSubmission(reviewSubmissionCreate)

    #expect(createGroupPlan.operationID == "betaGroups_createInstance")
    #expect(updateGroupPlan.operationID == "betaGroups_updateInstance")
    #expect(deleteGroupPlan.operationID == "betaGroups_deleteInstance")
    #expect(createTesterPlan.operationID == "betaTesters_createInstance")
    #expect(deleteTesterPlan.operationID == "betaTesters_deleteInstance")
    #expect(reviewDetailPlan.operationID == "betaAppReviewDetails_updateInstance")
    #expect(reviewSubmissionPlan.operationID == "betaAppReviewSubmissions_createInstance")
    #expect(createGroupPlan.dryRun && createTesterPlan.dryRun && reviewSubmissionPlan.dryRun)
    #expect(createdGroup.data.name == "External Testers")
    #expect(updatedGroup.data.name == "Renamed Testers")
    #expect(deletedGroup.data == AppStoreConnectMutationAcknowledgement(
        operationID: "betaGroups_deleteInstance",
        resourceType: "betaGroups",
        id: "group-1",
        status: "deleted"
    ))
    #expect(createdTester.data.email == "tester@example.com")
    #expect(createdTester.data.betaGroupIDs == ["group-1"])
    #expect(deletedTester.data.resourceType == "betaTesters")
    #expect(updatedReviewDetail.data.contactEmail == "qa@example.com")
    #expect(createdReviewSubmission.data.buildID == "build-1")

    let requests = await transport.requests()
    #expect(requests.suffix(7).map(\.operationID) == [
        "betaGroups_createInstance",
        "betaGroups_updateInstance",
        "betaGroups_deleteInstance",
        "betaTesters_createInstance",
        "betaTesters_deleteInstance",
        "betaAppReviewDetails_updateInstance",
        "betaAppReviewSubmissions_createInstance",
    ])
}

@Test func publicWriteCommandsMutateReleaseReviewResourcesThroughPublicAPIFacade() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIWriteCommands(client: publicClient)

    let appUpdate = AppStoreConnectAppUpdateInput(id: "app-1", primaryLocale: "en-US")
    let versionCreate = AppStoreConnectAppStoreVersionCreateInput(
        appID: "app-1",
        versionString: "1.3.0",
        platform: "IOS",
        buildID: "build-1",
        releaseType: "MANUAL"
    )
    let versionUpdate = AppStoreConnectAppStoreVersionUpdateInput(
        id: "version-1",
        buildID: "build-2",
        releaseType: "AFTER_APPROVAL"
    )
    let releaseRequestCreate = AppStoreConnectAppStoreVersionReleaseRequestCreateInput(appStoreVersionID: "version-1")
    let reviewCreate = AppStoreConnectReviewSubmissionCreateInput(appID: "app-1", platform: "IOS")
    let reviewSubmit = AppStoreConnectReviewSubmissionUpdateInput(id: "review-1", submitted: true)
    let itemCreate = AppStoreConnectReviewSubmissionItemCreateInput(
        reviewSubmissionID: "review-1",
        appStoreVersionID: "version-1"
    )
    let itemUpdate = AppStoreConnectReviewSubmissionItemUpdateInput(id: "item-1", resolved: true)

    let appPlan = PublicAPIWriteCommands.planUpdateApp(appUpdate)
    let versionCreatePlan = PublicAPIWriteCommands.planCreateAppStoreVersion(versionCreate)
    let versionUpdatePlan = PublicAPIWriteCommands.planUpdateAppStoreVersion(versionUpdate)
    let versionDeletePlan = PublicAPIWriteCommands.planDeleteAppStoreVersion(.init(id: "version-1"))
    let releasePlan = PublicAPIWriteCommands.planCreateAppStoreVersionReleaseRequest(releaseRequestCreate)
    let reviewCreatePlan = PublicAPIWriteCommands.planCreateReviewSubmission(reviewCreate)
    let reviewSubmitPlan = PublicAPIWriteCommands.planUpdateReviewSubmission(reviewSubmit)
    let itemCreatePlan = PublicAPIWriteCommands.planCreateReviewSubmissionItem(itemCreate)
    let itemUpdatePlan = PublicAPIWriteCommands.planUpdateReviewSubmissionItem(itemUpdate)
    let itemDeletePlan = PublicAPIWriteCommands.planDeleteReviewSubmissionItem(.init(id: "item-1"))

    let updatedApp = try await commands.updateApp(appUpdate)
    let createdVersion = try await commands.createAppStoreVersion(versionCreate)
    let updatedVersion = try await commands.updateAppStoreVersion(versionUpdate)
    let deletedVersion = try await commands.deleteAppStoreVersion(.init(id: "version-1"))
    let releaseRequest = try await commands.createAppStoreVersionReleaseRequest(releaseRequestCreate)
    let createdReview = try await commands.createReviewSubmission(reviewCreate)
    let submittedReview = try await commands.updateReviewSubmission(reviewSubmit)
    let createdItem = try await commands.createReviewSubmissionItem(itemCreate)
    let updatedItem = try await commands.updateReviewSubmissionItem(itemUpdate)
    let deletedItem = try await commands.deleteReviewSubmissionItem(.init(id: "item-1"))

    #expect(appPlan.operationID == "apps_updateInstance")
    #expect(versionCreatePlan.operationID == "appStoreVersions_createInstance")
    #expect(versionUpdatePlan.operationID == "appStoreVersions_updateInstance")
    #expect(versionDeletePlan.operationID == "appStoreVersions_deleteInstance")
    #expect(releasePlan.operationID == "appStoreVersionReleaseRequests_createInstance")
    #expect(reviewCreatePlan.operationID == "reviewSubmissions_createInstance")
    #expect(reviewSubmitPlan.operationID == "reviewSubmissions_updateInstance")
    #expect(itemCreatePlan.operationID == "reviewSubmissionItems_createInstance")
    #expect(itemUpdatePlan.operationID == "reviewSubmissionItems_updateInstance")
    #expect(itemDeletePlan.operationID == "reviewSubmissionItems_deleteInstance")
    #expect(appPlan.dryRun && versionCreatePlan.dryRun && reviewCreatePlan.dryRun)
    #expect(updatedApp.data.primaryLocale == "en-US")
    #expect(createdVersion.data.versionString == "1.3.0")
    #expect(updatedVersion.data.releaseType == "AFTER_APPROVAL")
    #expect(deletedVersion.data.resourceType == "appStoreVersions")
    #expect(releaseRequest.data.appStoreVersionID == "version-1")
    #expect(createdReview.data.appID == "app-1")
    #expect(submittedReview.data.state == "WAITING_FOR_REVIEW")
    #expect(createdItem.data.appStoreVersionID == "version-1")
    #expect(updatedItem.data.state == "ACCEPTED")
    #expect(deletedItem.data.resourceType == "reviewSubmissionItems")

    let requests = await transport.requests()
    #expect(requests.suffix(10).map(\.operationID) == [
        "apps_updateInstance",
        "appStoreVersions_createInstance",
        "appStoreVersions_updateInstance",
        "appStoreVersions_deleteInstance",
        "appStoreVersionReleaseRequests_createInstance",
        "reviewSubmissions_createInstance",
        "reviewSubmissions_updateInstance",
        "reviewSubmissionItems_createInstance",
        "reviewSubmissionItems_updateInstance",
        "reviewSubmissionItems_deleteInstance",
    ])
}

@Test func publicReadCommandsListAndViewSigningResourcesThroughPublicAPIFacade() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIReadCommands(client: publicClient)

    let bundleIDs = try await commands.listBundleIDs(.init(
        identifiers: ["com.example.app"],
        platforms: ["IOS"],
        limit: 5
    ))
    let bundleID = try await commands.getBundleID(.init(id: "bundle-1"))
    let bundleIDCapabilities = try await commands.listBundleIDCapabilities(.init(
        bundleID: "bundle-1",
        fields: ["capabilityType", "settings"],
        limit: 5
    ))
    let certificates = try await commands.listCertificates(.init(
        certificateTypes: ["IOS_DEVELOPMENT"],
        limit: 5
    ))
    let certificate = try await commands.getCertificate(.init(id: "cert-1"))
    let certificateOutputURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("asc-certificate-\(UUID().uuidString)")
        .appendingPathExtension("cer")
    defer { try? FileManager.default.removeItem(at: certificateOutputURL) }
    let certificateDownload = try await commands.downloadCertificate(.init(
        id: "cert-1",
        outputPath: certificateOutputURL.path
    ))
    let devices = try await commands.listDevices(.init(
        platforms: ["IOS"],
        statuses: ["ENABLED"],
        limit: 5
    ))
    let device = try await commands.getDevice(.init(id: "device-1"))
    let profiles = try await commands.listProfiles(.init(
        profileTypes: ["IOS_APP_STORE"],
        profileStates: ["ACTIVE"],
        limit: 5
    ))
    let profile = try await commands.getProfile(.init(id: "profile-1"))
    let profileOutputURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("asc-profile-\(UUID().uuidString)")
        .appendingPathExtension("mobileprovision")
    defer { try? FileManager.default.removeItem(at: profileOutputURL) }
    let profileDownload = try await commands.downloadProfile(.init(
        id: "profile-1",
        outputPath: profileOutputURL.path
    ))

    #expect(bundleIDs.data.first == AppStoreConnectBundleIDSummary(
        id: "bundle-1",
        identifier: "com.example.app",
        name: "Example Bundle",
        platform: "IOS",
        seedID: "TEAM1",
        appID: "app-1",
        profileIDs: ["profile-1"]
    ))
    #expect(bundleID.data.identifier == "com.example.app")
    #expect(bundleIDCapabilities.data.first == AppStoreConnectBundleIDCapabilitySummary(
        id: "capability-1",
        capabilityType: "PUSH_NOTIFICATIONS",
        settingKeys: ["ICLOUD_VERSION"],
        settingCount: 1
    ))
    #expect(certificates.data.first?.certificateType == "IOS_DEVELOPMENT")
    #expect(certificate.data.serialNumber == "ABC123")
    #expect(certificate.data.expirationDate != nil)
    #expect(certificateDownload.data.outputPath == certificateOutputURL.path)
    #expect(certificateDownload.data.byteCount == "CERT-CONTENT".utf8.count)
    #expect(try String(contentsOf: certificateOutputURL, encoding: .utf8) == "CERT-CONTENT")
    #expect(devices.data.first?.udid == "00000000-0000000000000001")
    #expect(device.data.status == "ENABLED")
    #expect(profiles.data.first?.bundleID == "bundle-1")
    #expect(profile.data.certificateIDs == ["cert-1"])
    #expect(profile.data.deviceIDs == ["device-1"])
    #expect(profileDownload.data.outputPath == profileOutputURL.path)
    #expect(profileDownload.data.byteCount == "PROFILE-CONTENT".utf8.count)
    #expect(try String(contentsOf: profileOutputURL, encoding: .utf8) == "PROFILE-CONTENT")

    let requests = await transport.requests()
    #expect(requests.suffix(11).map(\.operationID) == [
        "bundleIds_getCollection",
        "bundleIds_getInstance",
        "bundleIds_bundleIdCapabilities_getToManyRelated",
        "certificates_getCollection",
        "certificates_getInstance",
        "certificates_getInstance",
        "devices_getCollection",
        "devices_getInstance",
        "profiles_getCollection",
        "profiles_getInstance",
        "profiles_getInstance",
    ])
}

@Test func publicWriteCommandsMutateSigningResourcesThroughPublicAPIFacade() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIWriteCommands(client: publicClient)

    let bundleCreate = AppStoreConnectBundleIDCreateInput(
        identifier: "com.example.new",
        name: "Example New Bundle",
        platform: "IOS",
        seedID: "TEAM1"
    )
    let bundleUpdate = AppStoreConnectBundleIDUpdateInput(id: "bundle-1", name: "Example Renamed Bundle")
    let capabilityCreate = AppStoreConnectBundleIDCapabilityCreateInput(
        bundleID: "bundle-1",
        capabilityType: "PUSH_NOTIFICATIONS"
    )
    let capabilityUpdate = AppStoreConnectBundleIDCapabilityUpdateInput(
        id: "capability-1",
        settingsJSON: """
        [{"key":"ICLOUD_VERSION","name":"iCloud version"}]
        """
    )
    let certificateCreate = AppStoreConnectCertificateCreateInput(
        certificateType: "IOS_DEVELOPMENT",
        csrContent: "-----BEGIN CERTIFICATE REQUEST-----\nMIIB\n-----END CERTIFICATE REQUEST-----"
    )
    let certificateUpdate = AppStoreConnectCertificateUpdateInput(id: "cert-1", activated: true)
    let deviceCreate = AppStoreConnectDeviceCreateInput(
        name: "iPhone 16",
        udid: "00000000-0000000000000001",
        platform: "IOS"
    )
    let deviceDisable = AppStoreConnectDeviceUpdateInput(id: "device-1", status: "DISABLED")
    let profileCreate = AppStoreConnectProfileCreateInput(
        name: "Example Development Profile",
        profileType: "IOS_APP_DEVELOPMENT",
        bundleID: "bundle-1",
        certificateIDs: ["cert-1"],
        deviceIDs: ["device-1"]
    )

    let bundleCreatePlan = PublicAPIWriteCommands.planCreateBundleID(bundleCreate)
    let bundleUpdatePlan = PublicAPIWriteCommands.planUpdateBundleID(bundleUpdate)
    let bundleDeletePlan = PublicAPIWriteCommands.planDeleteBundleID(.init(id: "bundle-1"))
    let capabilityCreatePlan = PublicAPIWriteCommands.planCreateBundleIDCapability(capabilityCreate)
    let capabilityUpdatePlan = PublicAPIWriteCommands.planUpdateBundleIDCapability(capabilityUpdate)
    let capabilityDeletePlan = PublicAPIWriteCommands.planDeleteBundleIDCapability(.init(id: "capability-1"))
    let certificateCreatePlan = PublicAPIWriteCommands.planCreateCertificate(certificateCreate)
    let certificateUpdatePlan = PublicAPIWriteCommands.planUpdateCertificate(certificateUpdate)
    let certificateDeletePlan = PublicAPIWriteCommands.planDeleteCertificate(.init(id: "cert-1"))
    let deviceCreatePlan = PublicAPIWriteCommands.planCreateDevice(deviceCreate)
    let deviceDisablePlan = PublicAPIWriteCommands.planUpdateDevice(deviceDisable)
    let profileCreatePlan = PublicAPIWriteCommands.planCreateProfile(profileCreate)
    let profileDeletePlan = PublicAPIWriteCommands.planDeleteProfile(.init(id: "profile-1"))

    let createdBundle = try await commands.createBundleID(bundleCreate)
    let updatedBundle = try await commands.updateBundleID(bundleUpdate)
    let deletedBundle = try await commands.deleteBundleID(.init(id: "bundle-1"))
    let createdCapability = try await commands.createBundleIDCapability(capabilityCreate)
    let updatedCapability = try await commands.updateBundleIDCapability(capabilityUpdate)
    let deletedCapability = try await commands.deleteBundleIDCapability(.init(id: "capability-1"))
    let createdCertificate = try await commands.createCertificate(certificateCreate)
    let updatedCertificate = try await commands.updateCertificate(certificateUpdate)
    let deletedCertificate = try await commands.deleteCertificate(.init(id: "cert-1"))
    let createdDevice = try await commands.createDevice(deviceCreate)
    let disabledDevice = try await commands.updateDevice(deviceDisable)
    let createdProfile = try await commands.createProfile(profileCreate)
    let deletedProfile = try await commands.deleteProfile(.init(id: "profile-1"))

    #expect(bundleCreatePlan.operationID == "bundleIds_createInstance")
    #expect(bundleUpdatePlan.operationID == "bundleIds_updateInstance")
    #expect(bundleDeletePlan.operationID == "bundleIds_deleteInstance")
    #expect(capabilityCreatePlan.operationID == "bundleIdCapabilities_createInstance")
    #expect(capabilityUpdatePlan.operationID == "bundleIdCapabilities_updateInstance")
    #expect(capabilityUpdatePlan.inputs["settingsJSONLength"] == String(capabilityUpdate.settingsJSON!.count))
    #expect(capabilityDeletePlan.operationID == "bundleIdCapabilities_deleteInstance")
    #expect(certificateCreatePlan.operationID == "certificates_createInstance")
    #expect(certificateCreatePlan.inputs["csrContentLength"] == String(certificateCreate.csrContent.count))
    #expect(certificateUpdatePlan.operationID == "certificates_updateInstance")
    #expect(certificateDeletePlan.operationID == "certificates_deleteInstance")
    #expect(deviceCreatePlan.operationID == "devices_createInstance")
    #expect(deviceDisablePlan.operationID == "devices_updateInstance")
    #expect(profileCreatePlan.operationID == "profiles_createInstance")
    #expect(profileDeletePlan.operationID == "profiles_deleteInstance")
    #expect(bundleCreatePlan.dryRun && certificateCreatePlan.dryRun && profileCreatePlan.dryRun)
    #expect(createdBundle.data.identifier == "com.example.new")
    #expect(updatedBundle.data.name == "Example Renamed Bundle")
    #expect(deletedBundle.data.resourceType == "bundleIds")
    #expect(createdCapability.data.capabilityType == "PUSH_NOTIFICATIONS")
    #expect(updatedCapability.data.settingKeys == ["ICLOUD_VERSION"])
    #expect(deletedCapability.data.resourceType == "bundleIdCapabilities")
    #expect(createdCertificate.data.certificateType == "IOS_DEVELOPMENT")
    #expect(updatedCertificate.data.activated == true)
    #expect(deletedCertificate.data.resourceType == "certificates")
    #expect(createdDevice.data.udid == "00000000-0000000000000001")
    #expect(disabledDevice.data.status == "DISABLED")
    #expect(createdProfile.data.profileType == "IOS_APP_DEVELOPMENT")
    #expect(createdProfile.data.deviceIDs == ["device-1"])
    #expect(deletedProfile.data.resourceType == "profiles")

    let requests = await transport.requests()
    #expect(requests.suffix(13).map(\.operationID) == [
        "bundleIds_createInstance",
        "bundleIds_updateInstance",
        "bundleIds_deleteInstance",
        "bundleIdCapabilities_createInstance",
        "bundleIdCapabilities_updateInstance",
        "bundleIdCapabilities_deleteInstance",
        "certificates_createInstance",
        "certificates_updateInstance",
        "certificates_deleteInstance",
        "devices_createInstance",
        "devices_updateInstance",
        "profiles_createInstance",
        "profiles_deleteInstance",
    ])
}

@Test func publicReadCommandsListAndViewUsersThroughPublicAPIFacade() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIReadCommands(client: publicClient)

    let users = try await commands.listUsers(.init(
        usernames: ["developer@example.com"],
        roles: ["DEVELOPER"],
        visibleAppIDs: ["app-1"],
        sort: "username",
        limit: 5
    ))
    let user = try await commands.getUser(.init(id: "user-1"))
    let invitations = try await commands.listUserInvitations(.init(
        emails: ["invitee@example.com"],
        roles: ["APP_MANAGER"],
        visibleAppIDs: ["app-1"],
        sort: "email",
        limit: 5
    ))
    let invitation = try await commands.getUserInvitation(.init(id: "invite-1"))

    #expect(users.data.first == AppStoreConnectUserSummary(
        id: "user-1",
        username: "developer@example.com",
        firstName: "Dev",
        lastName: "User",
        roles: ["DEVELOPER"],
        allAppsVisible: false,
        provisioningAllowed: true,
        visibleAppIDs: ["app-1"]
    ))
    #expect(user.data.username == "developer@example.com")
    #expect(invitations.data.first == AppStoreConnectUserInvitationSummary(
        id: "invite-1",
        email: "invitee@example.com",
        firstName: "Invite",
        lastName: "User",
        roles: ["APP_MANAGER"],
        allAppsVisible: false,
        provisioningAllowed: false,
        expirationDate: invitation.data.expirationDate,
        visibleAppIDs: ["app-1"]
    ))
    #expect(invitation.data.email == "invitee@example.com")
    #expect(invitation.data.expirationDate != nil)

    let requests = await transport.requests()
    #expect(requests.suffix(4).map(\.operationID) == [
        "users_getCollection",
        "users_getInstance",
        "userInvitations_getCollection",
        "userInvitations_getInstance",
    ])
}

#if ASC_PUBLIC_API_SIGNING_ACCESS
@Test func publicReadCommandsListAndViewActorsThroughSigningAccessTrait() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIReadCommands(client: publicClient)

    let actors = try await commands.listActors(.init(
        ids: ["actor-1"],
        fields: ["actorType", "userEmail"],
        limit: 5
    ))
    let actor = try await commands.getActor(.init(
        id: "actor-1",
        fields: ["actorType", "userEmail"]
    ))

    #expect(actors.data == [
        AppStoreConnectActorSummary(
            id: "actor-1",
            actorType: "USER",
            userEmail: "developer@example.com",
            userFirstName: "Dev",
            userLastName: "User"
        ),
    ])
    #expect(actors.next == "https://api.appstoreconnect.apple.com/v1/actors?page=2")
    #expect(actor.data == AppStoreConnectActorSummary(
        id: "actor-1",
        actorType: "USER",
        userEmail: "developer@example.com",
        userFirstName: "Dev",
        userLastName: "User"
    ))

    let requests = await transport.requests()
    #expect(requests.suffix(2).map(\.operationID) == [
        "actors_getCollection",
        "actors_getInstance",
    ])
}
#endif

@Test func publicWriteCommandsMutateUsersThroughPublicAPIFacade() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIWriteCommands(client: publicClient)

    let invitationCreate = AppStoreConnectUserInvitationCreateInput(
        email: "invitee@example.com",
        firstName: "Invite",
        lastName: "User",
        roles: ["APP_MANAGER"],
        allAppsVisible: false,
        provisioningAllowed: true,
        visibleAppIDs: ["app-1"]
    )
    let userUpdate = AppStoreConnectUserUpdateInput(
        id: "user-1",
        roles: ["DEVELOPER"],
        allAppsVisible: false,
        provisioningAllowed: true,
        visibleAppIDs: ["app-1"]
    )

    let invitationCreatePlan = PublicAPIWriteCommands.planCreateUserInvitation(invitationCreate)
    let invitationDeletePlan = PublicAPIWriteCommands.planDeleteUserInvitation(.init(id: "invite-1"))
    let userUpdatePlan = PublicAPIWriteCommands.planUpdateUser(userUpdate)
    let userDeletePlan = PublicAPIWriteCommands.planDeleteUser(.init(id: "user-1"))

    let createdInvitation = try await commands.createUserInvitation(invitationCreate)
    let deletedInvitation = try await commands.deleteUserInvitation(.init(id: "invite-1"))
    let updatedUser = try await commands.updateUser(userUpdate)
    let deletedUser = try await commands.deleteUser(.init(id: "user-1"))

    #expect(invitationCreatePlan.operationID == "userInvitations_createInstance")
    #expect(invitationCreatePlan.inputs["email"] == "invitee@example.com")
    #expect(invitationDeletePlan.operationID == "userInvitations_deleteInstance")
    #expect(userUpdatePlan.operationID == "users_updateInstance")
    #expect(userUpdatePlan.inputs["roles"] == "DEVELOPER")
    #expect(userDeletePlan.operationID == "users_deleteInstance")
    #expect(createdInvitation.data.email == "invitee@example.com")
    #expect(createdInvitation.data.visibleAppIDs == ["app-1"])
    #expect(deletedInvitation.data.resourceType == "userInvitations")
    #expect(updatedUser.data.roles == ["DEVELOPER"])
    #expect(updatedUser.data.visibleAppIDs == ["app-1"])
    #expect(deletedUser.data.resourceType == "users")

    let requests = await transport.requests()
    #expect(requests.suffix(4).map(\.operationID) == [
        "userInvitations_createInstance",
        "userInvitations_deleteInstance",
        "users_updateInstance",
        "users_deleteInstance",
    ])
}

@Test func publicReportCommandsUsePublicAPIOperations() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let reads = PublicAPIReadCommands(client: publicClient)
    let writes = PublicAPIWriteCommands(client: publicClient)
    let outputDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent("swift-appstoreconnect-report-tests-\(UUID().uuidString)")
    defer {
        try? FileManager.default.removeItem(at: outputDirectory)
    }
    let salesURL = outputDirectory.appendingPathComponent("sales.gz")
    let financeURL = outputDirectory.appendingPathComponent("finance.gz")

    let report = try await reads.getAnalyticsReport(.init(id: "report-1"))
    let request = try await reads.getAnalyticsReportRequest(.init(id: "request-1", reportLimit: 1))
    let segment = try await reads.getAnalyticsReportSegment(.init(id: "segment-1"))
    let instance = try await reads.getAnalyticsReportInstance(.init(id: "instance-1"))
    let createInput = AppStoreConnectAnalyticsReportRequestCreateInput(
        appID: "app-1",
        accessType: "ONGOING"
    )
    let createPlan = PublicAPIWriteCommands.planCreateAnalyticsReportRequest(createInput)
    let deletePlan = PublicAPIWriteCommands.planDeleteAnalyticsReportRequest(.init(id: "request-1"))
    let created = try await writes.createAnalyticsReportRequest(createInput)
    let deleted = try await writes.deleteAnalyticsReportRequest(.init(id: "request-1"))
    let sales = try await reads.downloadSalesReport(.init(
        vendorNumber: "12345678",
        reportType: "SALES",
        reportSubType: "SUMMARY",
        frequency: "DAILY",
        reportDate: "2026-05-01",
        outputPath: salesURL.path
    ))
    let finance = try await reads.downloadFinanceReport(.init(
        vendorNumber: "12345678",
        reportType: "FINANCIAL",
        regionCode: "US",
        reportDate: "2026-05",
        outputPath: financeURL.path
    ))

    #expect(report.data == AppStoreConnectAnalyticsReportSummary(
        id: "report-1",
        category: "PERFORMANCE",
        name: "Performance Overview"
    ))
    #expect(request.data.accessType == "ONE_TIME_SNAPSHOT")
    #expect(request.data.reportIDs == ["report-1"])
    #expect(request.data.includedReports.first?.name == "Performance Overview")
    #expect(segment.data.url == "https://example.com/segments/segment-1.gz")
    #expect(segment.data.sizeInBytes == 10)
    #expect(instance.data.granularity == "DAILY")
    #expect(createPlan.operationID == "analyticsReportRequests_createInstance")
    #expect(createPlan.inputs["accessType"] == "ONGOING")
    #expect(deletePlan.operationID == "analyticsReportRequests_deleteInstance")
    #expect(created.data.accessType == "ONGOING")
    #expect(deleted.data.resourceType == "analyticsReportRequests")
    #expect(sales.data.byteCount == 10)
    #expect(finance.data.byteCount == 12)
    #expect(try String(contentsOf: salesURL, encoding: .utf8) == "sales-data")
    #expect(try String(contentsOf: financeURL, encoding: .utf8) == "finance-data")

    let requests = await transport.requests()
    #expect(requests.suffix(8).map(\.operationID) == [
        "analyticsReports_getInstance",
        "analyticsReportRequests_getInstance",
        "analyticsReportSegments_getInstance",
        "analyticsReportInstances_getInstance",
        "analyticsReportRequests_createInstance",
        "analyticsReportRequests_deleteInstance",
        "salesReports_getCollection",
        "financeReports_getCollection",
    ])
}

#if ASC_PUBLIC_API_REPORTS
@Test func publicReportCommandsUsePerformanceMetricsOperations() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let commands = PublicAPIReadCommands(client: publicClient)
    let outputURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("swift-appstoreconnect-performance-\(UUID().uuidString).json")
    defer {
        try? FileManager.default.removeItem(at: outputURL)
    }

    let appMetrics = try await commands.getPerformanceMetrics(.init(
        appID: "app-1",
        platform: "ios",
        metricType: "hang",
        deviceTypes: ["iphone"]
    ))
    let buildMetrics = try await commands.getPerformanceMetrics(.init(
        buildID: "build-1",
        platform: "IOS",
        metricType: "LAUNCH"
    ))
    let download = try await commands.downloadPerformanceMetrics(.init(
        appID: "app-1",
        outputPath: outputURL.path
    ))

    #expect(appMetrics.data.scope == "app")
    #expect(appMetrics.data.appID == "app-1")
    #expect(appMetrics.data.metricCategories == ["HANG"])
    #expect(appMetrics.data.metrics == ["hangRate"])
    #expect(appMetrics.data.productDataCount == 1)
    #expect(appMetrics.data.metricCategoryCount == 1)
    #expect(appMetrics.data.metricCount == 1)
    #expect(appMetrics.data.datasetCount == 1)
    #expect(appMetrics.data.pointCount == 1)
    #expect(appMetrics.data.regressionCount == 1)
    #expect(appMetrics.data.trendingUpCount == 1)
    #expect(buildMetrics.data.scope == "build")
    #expect(buildMetrics.data.buildID == "build-1")
    #expect(buildMetrics.data.metricCategories == ["LAUNCH"])
    #expect(buildMetrics.data.metrics == ["launchTime"])
    #expect(try Data(contentsOf: outputURL).count == download.data.byteCount)
    #expect(download.data.metrics.operationID == "apps_perfPowerMetrics_getToManyRelated")

    let requests = await transport.requests()
    #expect(requests.suffix(3).map(\.operationID) == [
        "apps_perfPowerMetrics_getToManyRelated",
        "builds_perfPowerMetrics_getToManyRelated",
        "apps_perfPowerMetrics_getToManyRelated",
    ])
}
#endif

#if ASC_PUBLIC_API_COMMERCE
@Test func publicCommerceCommandsUseTraitGatedPublicAPIOperations() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let reads = PublicAPIReadCommands(client: publicClient)
    let writes = PublicAPIWriteCommands(client: publicClient)

    let iapCreate = AppStoreConnectInAppPurchaseCreateInput(
        appID: "app-1",
        name: "Coin Pack",
        productID: "coins100",
        inAppPurchaseType: "CONSUMABLE",
        familySharable: true
    )
    let iapUpdate = AppStoreConnectInAppPurchaseUpdateInput(
        id: "iap-1",
        name: "Coin Pack Renamed",
        familySharable: false
    )
    let groupCreate = AppStoreConnectSubscriptionGroupCreateInput(
        appID: "app-1",
        referenceName: "Premium"
    )
    let groupUpdate = AppStoreConnectSubscriptionGroupUpdateInput(
        id: "group-1",
        referenceName: "Premium Renamed"
    )
    let subscriptionCreate = AppStoreConnectSubscriptionCreateInput(
        groupID: "group-1",
        name: "Premium Monthly",
        productID: "premium.monthly",
        subscriptionPeriod: "ONE_MONTH",
        groupLevel: 1,
        familySharable: true
    )
    let subscriptionUpdate = AppStoreConnectSubscriptionUpdateInput(
        id: "sub-1",
        name: "Premium Annual",
        subscriptionPeriod: "ONE_YEAR",
        groupLevel: 2,
        familySharable: false
    )

    let iaps = try await reads.listInAppPurchases(.init(
        appID: "app-1",
        productIDs: ["coins100"],
        names: ["Coin Pack"],
        states: ["APPROVED"],
        inAppPurchaseTypes: ["CONSUMABLE"],
        sort: "name",
        fields: ["name", "productId", "inAppPurchaseType", "state", "familySharable"],
        includes: ["promotedPurchase"],
        limit: 5
    ))
    let iap = try await reads.getInAppPurchase(.init(id: "iap-1"))
    let group = try await reads.getSubscriptionGroup(.init(id: "group-1"))
    let subscriptions = try await reads.listSubscriptions(.init(
        groupID: "group-1",
        productIDs: ["premium.monthly"],
        names: ["Premium Monthly"],
        states: ["APPROVED"],
        sort: "name",
        limit: 5
    ))
    let subscription = try await reads.getSubscription(.init(id: "sub-1"))

    let plans = [
        PublicAPIWriteCommands.planCreateInAppPurchase(iapCreate),
        PublicAPIWriteCommands.planUpdateInAppPurchase(iapUpdate),
        PublicAPIWriteCommands.planDeleteInAppPurchase(.init(id: "iap-1")),
        PublicAPIWriteCommands.planSubmitInAppPurchase(.init(id: "iap-1")),
        PublicAPIWriteCommands.planCreateSubscriptionGroup(groupCreate),
        PublicAPIWriteCommands.planUpdateSubscriptionGroup(groupUpdate),
        PublicAPIWriteCommands.planDeleteSubscriptionGroup(.init(id: "group-1")),
        PublicAPIWriteCommands.planCreateSubscription(subscriptionCreate),
        PublicAPIWriteCommands.planUpdateSubscription(subscriptionUpdate),
        PublicAPIWriteCommands.planDeleteSubscription(.init(id: "sub-1")),
        PublicAPIWriteCommands.planSubmitSubscription(.init(id: "sub-1")),
    ]

    let createdIAP = try await writes.createInAppPurchase(iapCreate)
    let updatedIAP = try await writes.updateInAppPurchase(iapUpdate)
    let deletedIAP = try await writes.deleteInAppPurchase(.init(id: "iap-1"))
    let submittedIAP = try await writes.submitInAppPurchase(.init(id: "iap-1"))
    let createdGroup = try await writes.createSubscriptionGroup(groupCreate)
    let updatedGroup = try await writes.updateSubscriptionGroup(groupUpdate)
    let deletedGroup = try await writes.deleteSubscriptionGroup(.init(id: "group-1"))
    let createdSubscription = try await writes.createSubscription(subscriptionCreate)
    let updatedSubscription = try await writes.updateSubscription(subscriptionUpdate)
    let deletedSubscription = try await writes.deleteSubscription(.init(id: "sub-1"))
    let submittedSubscription = try await writes.submitSubscription(.init(id: "sub-1"))

    #expect(iaps.data.first?.productID == "coins100")
    #expect(iap.data.productID == "coins100")
    #expect(group.data.referenceName == "Premium")
    #expect(subscriptions.data.first?.productID == "premium.monthly")
    #expect(subscription.data.subscriptionPeriod == "ONE_MONTH")
    #expect(plans.map(\.operationID) == [
        "inAppPurchasesV2_createInstance",
        "inAppPurchasesV2_updateInstance",
        "inAppPurchasesV2_deleteInstance",
        "inAppPurchaseSubmissions_createInstance",
        "subscriptionGroups_createInstance",
        "subscriptionGroups_updateInstance",
        "subscriptionGroups_deleteInstance",
        "subscriptions_createInstance",
        "subscriptions_updateInstance",
        "subscriptions_deleteInstance",
        "subscriptionSubmissions_createInstance",
    ])
    #expect(plans.allSatisfy { $0.dryRun })
    #expect(createdIAP.data.name == "Coin Pack")
    #expect(updatedIAP.data.familySharable == false)
    #expect(deletedIAP.data.resourceType == "inAppPurchases")
    #expect(submittedIAP.data.targetID == "iap-1")
    #expect(createdGroup.data.referenceName == "Premium")
    #expect(updatedGroup.data.referenceName == "Premium Renamed")
    #expect(deletedGroup.data.resourceType == "subscriptionGroups")
    #expect(createdSubscription.data.productID == "premium.monthly")
    #expect(updatedSubscription.data.subscriptionPeriod == "ONE_YEAR")
    #expect(deletedSubscription.data.resourceType == "subscriptions")
    #expect(submittedSubscription.data.targetID == "sub-1")

    let requests = await transport.requests()
    #expect(requests.suffix(16).map(\.operationID) == [
        "apps_inAppPurchasesV2_getToManyRelated",
        "inAppPurchasesV2_getInstance",
        "subscriptionGroups_getInstance",
        "subscriptionGroups_subscriptions_getToManyRelated",
        "subscriptions_getInstance",
        "inAppPurchasesV2_createInstance",
        "inAppPurchasesV2_updateInstance",
        "inAppPurchasesV2_deleteInstance",
        "inAppPurchaseSubmissions_createInstance",
        "subscriptionGroups_createInstance",
        "subscriptionGroups_updateInstance",
        "subscriptionGroups_deleteInstance",
        "subscriptions_createInstance",
        "subscriptions_updateInstance",
        "subscriptions_deleteInstance",
        "subscriptionSubmissions_createInstance",
    ])
}

@Test func publicCommerceCommandsUseTraitGatedLocalizationOperations() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let reads = PublicAPIReadCommands(client: publicClient)
    let writes = PublicAPIWriteCommands(client: publicClient)

    let iapCreate = AppStoreConnectInAppPurchaseLocalizationCreateInput(
        inAppPurchaseID: "iap-1",
        locale: "en-US",
        name: "Coin Pack",
        description: "100 coins"
    )
    let iapUpdate = AppStoreConnectInAppPurchaseLocalizationUpdateInput(
        id: "iap-loc-1",
        name: "Coin Pack Updated",
        description: "Updated 100 coins"
    )
    let subscriptionCreate = AppStoreConnectSubscriptionLocalizationCreateInput(
        subscriptionID: "sub-1",
        locale: "en-US",
        name: "Premium Monthly",
        description: "Monthly premium access"
    )
    let subscriptionUpdate = AppStoreConnectSubscriptionLocalizationUpdateInput(
        id: "sub-loc-1",
        name: "Premium Monthly Updated",
        description: "Updated premium access"
    )
    let groupCreate = AppStoreConnectSubscriptionGroupLocalizationCreateInput(
        groupID: "group-1",
        locale: "en-US",
        name: "Premium",
        customAppName: "Example Premium"
    )
    let groupUpdate = AppStoreConnectSubscriptionGroupLocalizationUpdateInput(
        id: "group-loc-1",
        name: "Premium Updated",
        customAppName: "Example Premium Updated"
    )

    let iapLocalizations = try await reads.listInAppPurchaseLocalizations(.init(inAppPurchaseID: "iap-1", limit: 5))
    let iapLocalization = try await reads.getInAppPurchaseLocalization(.init(id: "iap-loc-1"))
    let subscriptionLocalizations = try await reads.listSubscriptionLocalizations(.init(subscriptionID: "sub-1", limit: 5))
    let subscriptionLocalization = try await reads.getSubscriptionLocalization(.init(id: "sub-loc-1"))
    let groupLocalizations = try await reads.listSubscriptionGroupLocalizations(.init(groupID: "group-1", limit: 5))
    let groupLocalization = try await reads.getSubscriptionGroupLocalization(.init(id: "group-loc-1"))

    let plans = [
        PublicAPIWriteCommands.planCreateInAppPurchaseLocalization(iapCreate),
        PublicAPIWriteCommands.planUpdateInAppPurchaseLocalization(iapUpdate),
        PublicAPIWriteCommands.planDeleteInAppPurchaseLocalization(.init(id: "iap-loc-1")),
        PublicAPIWriteCommands.planCreateSubscriptionLocalization(subscriptionCreate),
        PublicAPIWriteCommands.planUpdateSubscriptionLocalization(subscriptionUpdate),
        PublicAPIWriteCommands.planDeleteSubscriptionLocalization(.init(id: "sub-loc-1")),
        PublicAPIWriteCommands.planCreateSubscriptionGroupLocalization(groupCreate),
        PublicAPIWriteCommands.planUpdateSubscriptionGroupLocalization(groupUpdate),
        PublicAPIWriteCommands.planDeleteSubscriptionGroupLocalization(.init(id: "group-loc-1")),
    ]

    let createdIAPLocalization = try await writes.createInAppPurchaseLocalization(iapCreate)
    let updatedIAPLocalization = try await writes.updateInAppPurchaseLocalization(iapUpdate)
    let deletedIAPLocalization = try await writes.deleteInAppPurchaseLocalization(.init(id: "iap-loc-1"))
    let createdSubscriptionLocalization = try await writes.createSubscriptionLocalization(subscriptionCreate)
    let updatedSubscriptionLocalization = try await writes.updateSubscriptionLocalization(subscriptionUpdate)
    let deletedSubscriptionLocalization = try await writes.deleteSubscriptionLocalization(.init(id: "sub-loc-1"))
    let createdGroupLocalization = try await writes.createSubscriptionGroupLocalization(groupCreate)
    let updatedGroupLocalization = try await writes.updateSubscriptionGroupLocalization(groupUpdate)
    let deletedGroupLocalization = try await writes.deleteSubscriptionGroupLocalization(.init(id: "group-loc-1"))

    #expect(iapLocalizations.data.first?.parentID == "iap-1")
    #expect(iapLocalization.data.name == "Coin Pack")
    #expect(subscriptionLocalizations.data.first?.parentID == "sub-1")
    #expect(subscriptionLocalization.data.description == "Monthly premium access")
    #expect(groupLocalizations.data.first?.parentID == "group-1")
    #expect(groupLocalization.data.customAppName == "Example Premium")
    #expect(plans.map(\.operationID) == [
        "inAppPurchaseLocalizations_createInstance",
        "inAppPurchaseLocalizations_updateInstance",
        "inAppPurchaseLocalizations_deleteInstance",
        "subscriptionLocalizations_createInstance",
        "subscriptionLocalizations_updateInstance",
        "subscriptionLocalizations_deleteInstance",
        "subscriptionGroupLocalizations_createInstance",
        "subscriptionGroupLocalizations_updateInstance",
        "subscriptionGroupLocalizations_deleteInstance",
    ])
    #expect(plans.allSatisfy { $0.dryRun })
    #expect(createdIAPLocalization.data.locale == "en-US")
    #expect(updatedIAPLocalization.data.name == "Coin Pack Updated")
    #expect(deletedIAPLocalization.data.resourceType == "inAppPurchaseLocalizations")
    #expect(createdSubscriptionLocalization.data.locale == "en-US")
    #expect(updatedSubscriptionLocalization.data.name == "Premium Monthly Updated")
    #expect(deletedSubscriptionLocalization.data.resourceType == "subscriptionLocalizations")
    #expect(createdGroupLocalization.data.locale == "en-US")
    #expect(updatedGroupLocalization.data.customAppName == "Example Premium Updated")
    #expect(deletedGroupLocalization.data.resourceType == "subscriptionGroupLocalizations")

    let requests = await transport.requests()
    #expect(requests.suffix(15).map(\.operationID) == [
        "inAppPurchasesV2_inAppPurchaseLocalizations_getToManyRelated",
        "inAppPurchaseLocalizations_getInstance",
        "subscriptions_subscriptionLocalizations_getToManyRelated",
        "subscriptionLocalizations_getInstance",
        "subscriptionGroups_subscriptionGroupLocalizations_getToManyRelated",
        "subscriptionGroupLocalizations_getInstance",
        "inAppPurchaseLocalizations_createInstance",
        "inAppPurchaseLocalizations_updateInstance",
        "inAppPurchaseLocalizations_deleteInstance",
        "subscriptionLocalizations_createInstance",
        "subscriptionLocalizations_updateInstance",
        "subscriptionLocalizations_deleteInstance",
        "subscriptionGroupLocalizations_createInstance",
        "subscriptionGroupLocalizations_updateInstance",
        "subscriptionGroupLocalizations_deleteInstance",
    ])
}

@Test func publicCommerceCommandsUseTraitGatedPromotedPurchaseOperations() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let reads = PublicAPIReadCommands(client: publicClient)
    let writes = PublicAPIWriteCommands(client: publicClient)

    let list = try await reads.listPromotedPurchases(.init(
        appID: "app-1",
        fields: ["visibleForAllUsers", "enabled", "state"],
        includes: ["inAppPurchaseV2"],
        limit: 5
    ))
    let viewed = try await reads.getPromotedPurchase(.init(
        id: "promo-1",
        fields: ["visibleForAllUsers", "enabled", "state"],
        includes: ["inAppPurchaseV2"]
    ))
    let createInput = AppStoreConnectPromotedPurchaseCreateInput(
        appID: "app-1",
        inAppPurchaseID: "iap-1",
        visibleForAllUsers: true,
        enabled: true
    )
    let updateInput = AppStoreConnectPromotedPurchaseUpdateInput(
        id: "promo-1",
        visibleForAllUsers: false,
        enabled: false
    )
    let plans = [
        PublicAPIWriteCommands.planCreatePromotedPurchase(createInput),
        PublicAPIWriteCommands.planUpdatePromotedPurchase(updateInput),
        PublicAPIWriteCommands.planDeletePromotedPurchase(.init(id: "promo-1")),
    ]
    let created = try await writes.createPromotedPurchase(createInput)
    let updated = try await writes.updatePromotedPurchase(updateInput)
    let deleted = try await writes.deletePromotedPurchase(.init(id: "promo-1"))

    #expect(list.data.first?.inAppPurchaseID == "iap-1")
    #expect(viewed.data.state == "APPROVED")
    #expect(plans.map(\.operationID) == [
        "promotedPurchases_createInstance",
        "promotedPurchases_updateInstance",
        "promotedPurchases_deleteInstance",
    ])
    #expect(plans.allSatisfy { $0.dryRun })
    #expect(created.data.visibleForAllUsers == true)
    #expect(updated.data.enabled == false)
    #expect(deleted.data.resourceType == "promotedPurchases")

    let requests = await transport.requests()
    #expect(requests.suffix(5).map(\.operationID) == [
        "apps_promotedPurchases_getToManyRelated",
        "promotedPurchases_getInstance",
        "promotedPurchases_createInstance",
        "promotedPurchases_updateInstance",
        "promotedPurchases_deleteInstance",
    ])
}

@Test func publicCommerceCommandsUseTraitGatedWinBackOfferOperations() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let reads = PublicAPIReadCommands(client: publicClient)
    let writes = PublicAPIWriteCommands(client: publicClient)

    let createInput = AppStoreConnectWinBackOfferCreateInput(
        subscriptionID: "sub-1",
        referenceName: "Come Back",
        offerID: "come_back",
        duration: "ONE_MONTH",
        offerMode: "PAY_AS_YOU_GO",
        periodCount: 1,
        paidSubscriptionDurationMonths: 3,
        lastSubscribedMinMonths: 1,
        lastSubscribedMaxMonths: 12,
        waitBetweenOffersMonths: 6,
        startDate: "2026-05-10",
        endDate: "2026-12-31",
        priority: "NORMAL",
        promotionIntent: "NOT_PROMOTED",
        priceIDs: ["winback-price-1"]
    )
    let updateInput = AppStoreConnectWinBackOfferUpdateInput(
        id: "winback-1",
        paidSubscriptionDurationMonths: 4,
        lastSubscribedMinMonths: 2,
        lastSubscribedMaxMonths: 10,
        waitBetweenOffersMonths: 7,
        startDate: "2026-06-01",
        priority: "HIGH",
        promotionIntent: "USE_AUTO_GENERATED_ASSETS"
    )

    let list = try await reads.listWinBackOffers(.init(subscriptionID: "sub-1", limit: 5))
    let viewed = try await reads.getWinBackOffer(.init(id: "winback-1"))
    let plans = [
        PublicAPIWriteCommands.planCreateWinBackOffer(createInput),
        PublicAPIWriteCommands.planUpdateWinBackOffer(updateInput),
        PublicAPIWriteCommands.planDeleteWinBackOffer(.init(id: "winback-1")),
    ]
    let created = try await writes.createWinBackOffer(createInput)
    let updated = try await writes.updateWinBackOffer(updateInput)
    let deleted = try await writes.deleteWinBackOffer(.init(id: "winback-1"))

    #expect(list.data.first?.referenceName == "Come Back")
    #expect(viewed.data.priceIDs == ["winback-price-1"])
    #expect(plans.map(\.operationID) == [
        "winBackOffers_createInstance",
        "winBackOffers_updateInstance",
        "winBackOffers_deleteInstance",
    ])
    #expect(plans.allSatisfy { $0.dryRun })
    #expect(created.data.offerID == "come_back")
    #expect(updated.data.priority == "HIGH")
    #expect(deleted.data.resourceType == "winBackOffers")

    let requests = await transport.requests()
    #expect(requests.suffix(5).map(\.operationID) == [
        "subscriptions_winBackOffers_getToManyRelated",
        "winBackOffers_getInstance",
        "winBackOffers_createInstance",
        "winBackOffers_updateInstance",
        "winBackOffers_deleteInstance",
    ])
}

@Test func publicCommerceReadCommandsUseTraitGatedAppPricingOperations() async throws {
    let transport = WorkflowOpenAPITransport()
    let publicClient = AppStoreConnectPublicClient(client: Client(
        serverURL: URL(string: "https://api.appstoreconnect.apple.com")!,
        transport: transport
    ))
    let reads = PublicAPIReadCommands(client: publicClient)

    let pricePoints = try await reads.listAppPricePoints(.init(
        appID: "app-1",
        territories: ["USA"],
        fields: ["customerPrice", "proceeds", "territory"],
        territoryFields: ["currency"],
        includeTerritory: true,
        limit: 2
    ))
    let priceSchedule = try await reads.getCurrentAppPriceSchedule(.init(
        appID: "app-1",
        fields: ["app", "baseTerritory", "manualPrices", "automaticPrices"],
        priceFields: ["manual", "startDate", "endDate", "territory"],
        territoryFields: ["currency"],
        includeBaseTerritory: true,
        includeManualPrices: true,
        includeAutomaticPrices: true,
        manualPricesLimit: 2,
        automaticPricesLimit: 2
    ))

    #expect(pricePoints.data == [
        AppStoreConnectAppPricePointSummary(
            id: "price-point-1",
            customerPrice: "0.99",
            proceeds: "0.70",
            appID: "app-1",
            territoryID: "USA"
        ),
    ])
    #expect(pricePoints.next == "https://api.appstoreconnect.apple.com/v1/apps/app-1/appPricePoints?page=2")
    #expect(priceSchedule.data == AppStoreConnectAppPriceScheduleSummary(
        id: "price-schedule-1",
        appID: "app-1",
        baseTerritoryID: "USA",
        manualPriceIDs: ["price-1"],
        automaticPriceIDs: ["price-2"]
    ))

    let requests = await transport.requests()
    #expect(requests.suffix(2).map(\.operationID) == [
        "apps_appPricePoints_getToManyRelated",
        "apps_appPriceSchedule_getToOneRelated",
    ])
}
#endif

private struct WorkflowRecordedRequest: Sendable, Equatable {
    var operationID: String
    var path: String?
}

private func temporaryFileURL(_ name: String) -> URL {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("swift-appstoreconnect-workflow-tests", isDirectory: true)
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory.appendingPathComponent(name)
}

private actor SleepRecorder {
    private var recordedCalls: [UInt64] = []

    func record(_ nanoseconds: UInt64) {
        recordedCalls.append(nanoseconds)
    }

    func calls() -> [UInt64] {
        recordedCalls
    }
}

private actor WorkflowOpenAPITransport: ClientTransport {
    private let failAppLookup: Bool
    private var buildInstanceProcessingStates: [String]
    private var recordedRequests: [WorkflowRecordedRequest] = []

    init(failAppLookup: Bool = false, buildInstanceProcessingStates: [String] = ["VALID"]) {
        self.failAppLookup = failAppLookup
        self.buildInstanceProcessingStates = buildInstanceProcessingStates
    }

    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        recordedRequests.append(WorkflowRecordedRequest(
            operationID: operationID,
            path: request.path
        ))

        if failAppLookup, operationID == Operations.AppsGetInstance.id {
            return (HTTPResponse(status: .internalServerError), nil)
        }

        var response = HTTPResponse(status: .ok)
        response.headerFields[.contentType] = "application/json"

        switch operationID {
        case Operations.AppsGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "apps",
                  "id": "app-1",
                  "attributes": {
                    "name": "My App",
                    "bundleId": "com.example.app",
                    "sku": "SKU-1",
                    "primaryLocale": "en-US"
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/apps",
                "next": "https://api.appstoreconnect.apple.com/v1/apps?page=2"
              }
            }
            """))
        case Operations.AppsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "apps",
                "id": "app-1",
                "attributes": {
                  "name": "My App",
                  "bundleId": "com.example.app",
                  "sku": "SKU-1",
                  "primaryLocale": "en-US"
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/apps/app-1"}
            }
            """))
        case Operations.AppsUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "apps",
                "id": "app-1",
                "attributes": {
                  "name": "My App",
                  "bundleId": "com.example.app",
                  "sku": "SKU-1",
                  "primaryLocale": "en-US",
                  "contentRightsDeclaration": "DOES_NOT_USE_THIRD_PARTY_CONTENT"
                },
                "links": {"self": "https://api.appstoreconnect.apple.com/v1/apps/app-1"}
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/apps/app-1"}
            }
            """))
#if ASC_PUBLIC_API_RELEASE
        case Operations.AppCategoriesGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "appCategories",
                  "id": "category-1",
                  "attributes": {
                    "platforms": ["IOS"]
                  },
                  "relationships": {
                    "subcategories": {
                      "data": [{"type": "appCategories", "id": "subcategory-1"}]
                    }
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/appCategories",
                "next": "https://api.appstoreconnect.apple.com/v1/appCategories?page=2"
              }
            }
            """))
        case Operations.AppCategoriesGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "appCategories",
                "id": "category-1",
                "attributes": {
                  "platforms": ["IOS"]
                },
                "relationships": {
                  "parent": {
                    "data": {"type": "appCategories", "id": "parent-1"}
                  },
                  "subcategories": {
                    "data": [{"type": "appCategories", "id": "subcategory-1"}]
                  }
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/appCategories/category-1"}
            }
            """))
        case Operations.AppCategoriesParentGetToOneRelated.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "appCategories",
                "id": "parent-1",
                "attributes": {
                  "platforms": ["IOS"]
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/appCategories/category-1/parent"}
            }
            """))
        case Operations.AppCategoriesSubcategoriesGetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "appCategories",
                  "id": "subcategory-1",
                  "attributes": {
                    "platforms": ["IOS"]
                  },
                  "relationships": {
                    "parent": {
                      "data": {"type": "appCategories", "id": "category-1"}
                    }
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/appCategories/category-1/subcategories"
              }
            }
            """))
        case Operations.AppInfosAgeRatingDeclarationGetToOneRelated.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "ageRatingDeclarations",
                "id": "age-rating-1",
                "attributes": {
                  "violenceRealistic": "NONE",
                  "gambling": false,
                  "kidsAgeBand": "NINE_TO_ELEVEN"
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/appInfos/app-info-1/ageRatingDeclaration"}
            }
            """))
        case Operations.AppInfosUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "appInfos",
                "id": "app-info-1",
                "relationships": {
                  "primaryCategory": {
                    "data": {"type": "appCategories", "id": "GAMES"}
                  },
                  "primarySubcategoryOne": {
                    "data": {"type": "appCategories", "id": "GAMES_ACTION"}
                  },
                  "secondaryCategory": {
                    "data": {"type": "appCategories", "id": "ENTERTAINMENT"}
                  }
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/appInfos/app-info-1"}
            }
            """))
        case Operations.AgeRatingDeclarationsUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "ageRatingDeclarations",
                "id": "age-rating-1",
                "attributes": {
                  "violenceRealistic": "NONE",
                  "gambling": false,
                  "kidsAgeBand": "NINE_TO_ELEVEN"
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/ageRatingDeclarations/age-rating-1"}
            }
            """))
        case Operations.AppsAppEventsGetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "appEvents",
                  "id": "event-1",
                  "attributes": {
                    "referenceName": "Spring Launch",
                    "eventState": "DRAFT",
                    "badge": "LIVE_EVENT",
                    "priority": "HIGH",
                    "purpose": "ATTRACT_NEW_USERS",
                    "primaryLocale": "en-US",
                    "deepLink": "myapp://spring",
                    "purchaseRequirement": "NO_COST_ASSOCIATED"
                  },
                  "relationships": {
                    "localizations": {
                      "data": [{"type": "appEventLocalizations", "id": "event-loc-1"}]
                    }
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/apps/app-1/appEvents",
                "next": "https://api.appstoreconnect.apple.com/v1/apps/app-1/appEvents?page=2"
              }
            }
            """))
        case Operations.AppEventsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "appEvents",
                "id": "event-1",
                "attributes": {
                  "referenceName": "Spring Launch",
                  "eventState": "DRAFT",
                  "badge": "LIVE_EVENT",
                  "priority": "HIGH",
                  "purpose": "ATTRACT_NEW_USERS",
                  "primaryLocale": "en-US",
                  "deepLink": "myapp://spring",
                  "purchaseRequirement": "NO_COST_ASSOCIATED"
                },
                "relationships": {
                  "localizations": {
                    "data": [{"type": "appEventLocalizations", "id": "event-loc-1"}]
                  }
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/appEvents/event-1"}
            }
            """))
        case Operations.AppEventsCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "appEvents",
                "id": "event-2",
                "attributes": {
                  "referenceName": "Spring Launch",
                  "eventState": "DRAFT",
                  "badge": "LIVE_EVENT",
                  "priority": "HIGH",
                  "purpose": "ATTRACT_NEW_USERS",
                  "primaryLocale": "en-US",
                  "deepLink": "myapp://spring",
                  "purchaseRequirement": "NO_COST_ASSOCIATED"
                },
                "relationships": {
                  "localizations": {
                    "data": [{"type": "appEventLocalizations", "id": "event-loc-1"}]
                  }
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/appEvents/event-2"}
            }
            """))
        case Operations.AppEventsUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "appEvents",
                "id": "event-1",
                "attributes": {
                  "referenceName": "Spring Launch Updated",
                  "eventState": "DRAFT",
                  "badge": "LIVE_EVENT",
                  "priority": "NORMAL",
                  "purpose": "ATTRACT_NEW_USERS",
                  "primaryLocale": "en-US",
                  "deepLink": "myapp://spring",
                  "purchaseRequirement": "NO_COST_ASSOCIATED"
                },
                "relationships": {
                  "localizations": {
                    "data": [{"type": "appEventLocalizations", "id": "event-loc-1"}]
                  }
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/appEvents/event-1"}
            }
            """))
        case Operations.AppEventsDeleteInstance.id:
            response.status = .noContent
            return (response, nil)
        case Operations.AppsCustomerReviewsGetToManyRelated.id:
            return (response, HTTPBody(Self.customerReviewsJSON(
                selfURL: "https://api.appstoreconnect.apple.com/v1/apps/app-1/customerReviews",
                nextURL: "https://api.appstoreconnect.apple.com/v1/apps/app-1/customerReviews?page=2"
            )))
        case Operations.AppStoreVersionsCustomerReviewsGetToManyRelated.id:
            return (response, HTTPBody(Self.customerReviewsJSON(
                selfURL: "https://api.appstoreconnect.apple.com/v1/appStoreVersions/version-1/customerReviews",
                nextURL: "https://api.appstoreconnect.apple.com/v1/appStoreVersions/version-1/customerReviews?page=2"
            )))
        case Operations.CustomerReviewsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "customerReviews",
                "id": "customer-review-1",
                "attributes": {
                  "rating": 5,
                  "title": "Great app",
                  "body": "Fast and reliable.",
                  "reviewerNickname": "Reviewer",
                  "createdDate": "2026-05-01T00:00:00Z",
                  "territory": "USA"
                },
                "relationships": {
                  "response": {
                    "data": {"type": "customerReviewResponses", "id": "customer-review-response-1"}
                  }
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/customerReviews/customer-review-1"}
            }
            """))
        case Operations.AppsCustomerReviewSummarizationsGetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "customerReviewSummarizations",
                  "id": "customer-review-summary-1",
                  "attributes": {
                    "platform": "IOS",
                    "locale": "en-US",
                    "text": "Most reviews are positive.",
                    "createdDate": "2026-05-02T00:00:00Z"
                  },
                  "relationships": {
                    "territory": {
                      "data": {"type": "territories", "id": "USA"}
                    }
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/apps/app-1/customerReviewSummarizations"
              }
            }
            """))
        case Operations.CustomerReviewsResponseGetToOneRelated.id,
             Operations.CustomerReviewResponsesGetInstance.id:
            return (response, HTTPBody(Self.customerReviewResponseJSON(
                selfURL: "https://api.appstoreconnect.apple.com/v1/customerReviewResponses/customer-review-response-1"
            )))
        case Operations.CustomerReviewResponsesCreateInstance.id:
            response.status = .created
            return (response, HTTPBody(Self.customerReviewResponseJSON(
                selfURL: "https://api.appstoreconnect.apple.com/v1/customerReviewResponses/customer-review-response-1"
            )))
        case Operations.CustomerReviewResponsesDeleteInstance.id:
            response.status = .noContent
            return (response, nil)
#endif
#if ASC_PUBLIC_API_METADATA_MEDIA
        case Operations.AppsAppClipsGetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "appClips",
                  "id": "app-clip-1",
                  "attributes": {"bundleId": "com.example.app.Clip"},
                  "relationships": {
                    "app": {"data": {"type": "apps", "id": "app-1"}},
                    "appClipDefaultExperiences": {
                      "data": [{"type": "appClipDefaultExperiences", "id": "experience-1"}]
                    }
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/apps/app-1/appClips",
                "next": "https://api.appstoreconnect.apple.com/v1/apps/app-1/appClips?page=2"
              }
            }
            """))
        case Operations.AppClipsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "appClips",
                "id": "app-clip-1",
                "attributes": {"bundleId": "com.example.app.Clip"},
                "relationships": {
                  "app": {"data": {"type": "apps", "id": "app-1"}},
                  "appClipDefaultExperiences": {
                    "data": [{"type": "appClipDefaultExperiences", "id": "experience-1"}]
                  }
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/appClips/app-clip-1"}
            }
            """))
        case Operations.AppClipsAppClipDefaultExperiencesGetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "appClipDefaultExperiences",
                  "id": "experience-1",
                  "attributes": {"action": "OPEN"},
                  "relationships": {
                    "appClip": {"data": {"type": "appClips", "id": "app-clip-1"}},
                    "releaseWithAppStoreVersion": {"data": {"type": "appStoreVersions", "id": "version-1"}},
                    "appClipAppStoreReviewDetail": {"data": {"type": "appClipAppStoreReviewDetails", "id": "review-detail-1"}},
                    "appClipDefaultExperienceLocalizations": {
                      "data": [{"type": "appClipDefaultExperienceLocalizations", "id": "clip-loc-1"}]
                    }
                  }
                }
              ],
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/appClips/app-clip-1/appClipDefaultExperiences"}
            }
            """))
        case Operations.AppClipDefaultExperiencesGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "appClipDefaultExperiences",
                "id": "experience-1",
                "attributes": {"action": "OPEN"},
                "relationships": {
                  "appClip": {"data": {"type": "appClips", "id": "app-clip-1"}},
                  "releaseWithAppStoreVersion": {"data": {"type": "appStoreVersions", "id": "version-1"}},
                  "appClipAppStoreReviewDetail": {"data": {"type": "appClipAppStoreReviewDetails", "id": "review-detail-1"}},
                  "appClipDefaultExperienceLocalizations": {
                    "data": [{"type": "appClipDefaultExperienceLocalizations", "id": "clip-loc-1"}]
                  }
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/appClipDefaultExperiences/experience-1"}
            }
            """))
        case Operations.AppClipDefaultExperiencesAppClipDefaultExperienceLocalizationsGetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "appClipDefaultExperienceLocalizations",
                  "id": "clip-loc-1",
                  "attributes": {
                    "locale": "en-US",
                    "subtitle": "Launch instantly"
                  },
                  "relationships": {
                    "appClipDefaultExperience": {"data": {"type": "appClipDefaultExperiences", "id": "experience-1"}},
                    "appClipHeaderImage": {"data": {"type": "appClipHeaderImages", "id": "header-image-1"}}
                  }
                }
              ],
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/appClipDefaultExperiences/experience-1/appClipDefaultExperienceLocalizations"}
            }
            """))
        case Operations.AppClipDefaultExperienceLocalizationsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "appClipDefaultExperienceLocalizations",
                "id": "clip-loc-1",
                "attributes": {
                  "locale": "en-US",
                  "subtitle": "Launch instantly"
                },
                "relationships": {
                  "appClipDefaultExperience": {"data": {"type": "appClipDefaultExperiences", "id": "experience-1"}},
                  "appClipHeaderImage": {"data": {"type": "appClipHeaderImages", "id": "header-image-1"}}
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/appClipDefaultExperienceLocalizations/clip-loc-1"}
            }
            """))
#endif
#if ASC_PUBLIC_API_GAME_CENTER
        case Operations.AppsGameCenterDetailGetToOneRelated.id, Operations.GameCenterDetailsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "gameCenterDetails",
                "id": "gc-detail-1",
                "attributes": {
                  "arcadeEnabled": true,
                  "challengeEnabled": true
                },
                "relationships": {
                  "app": {"data": {"type": "apps", "id": "app-1"}},
                  "gameCenterAchievementsV2": {
                    "data": [{"type": "gameCenterAchievements", "id": "achievement-1"}]
                  },
                  "gameCenterLeaderboardsV2": {
                    "data": [{"type": "gameCenterLeaderboards", "id": "leaderboard-1"}]
                  },
                  "gameCenterLeaderboardSetsV2": {
                    "data": [{"type": "gameCenterLeaderboardSets", "id": "leaderboard-set-1"}]
                  },
                  "gameCenterChallenges": {
                    "data": [{"type": "gameCenterChallenges", "id": "challenge-1"}]
                  }
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/gameCenterDetails/gc-detail-1"}
            }
            """))
        case Operations.GameCenterDetailsGameCenterAchievementsV2GetToManyRelated.id,
            Operations.GameCenterAchievementsV2GetInstance.id:
            let isList = operationID == Operations.GameCenterDetailsGameCenterAchievementsV2GetToManyRelated.id
            return (response, HTTPBody("""
            {
              "data": \(isList ? "[" : ""){
                "type": "gameCenterAchievements",
                "id": "achievement-1",
                "attributes": {
                  "referenceName": "First Win",
                  "vendorIdentifier": "first_win",
                  "points": 10,
                  "archived": false,
                  "repeatable": false
                },
                "relationships": {
                  "gameCenterDetail": {"data": {"type": "gameCenterDetails", "id": "gc-detail-1"}},
                  "versions": {
                    "data": [{"type": "gameCenterAchievementVersions", "id": "achievement-version-1"}]
                  }
                }
              }\(isList ? "]" : ""),
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/gameCenterAchievements/achievement-1"}
            }
            """))
        case Operations.GameCenterDetailsGameCenterLeaderboardsV2GetToManyRelated.id,
            Operations.GameCenterLeaderboardsV2GetInstance.id:
            let isList = operationID == Operations.GameCenterDetailsGameCenterLeaderboardsV2GetToManyRelated.id
            return (response, HTTPBody("""
            {
              "data": \(isList ? "[" : ""){
                "type": "gameCenterLeaderboards",
                "id": "leaderboard-1",
                "attributes": {
                  "referenceName": "Top Scores",
                  "vendorIdentifier": "top_scores",
                  "scoreSortType": "DESC",
                  "defaultFormatter": "INTEGER",
                  "submissionType": "BEST_SCORE",
                  "archived": false
                },
                "relationships": {
                  "gameCenterDetail": {"data": {"type": "gameCenterDetails", "id": "gc-detail-1"}},
                  "gameCenterLeaderboardSets": {
                    "data": [{"type": "gameCenterLeaderboardSets", "id": "leaderboard-set-1"}]
                  },
                  "versions": {
                    "data": [{"type": "gameCenterLeaderboardVersions", "id": "leaderboard-version-1"}]
                  }
                }
              }\(isList ? "]" : ""),
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/gameCenterLeaderboards/leaderboard-1"}
            }
            """))
        case Operations.GameCenterDetailsGameCenterLeaderboardSetsV2GetToManyRelated.id,
            Operations.GameCenterLeaderboardSetsV2GetInstance.id:
            let isList = operationID == Operations.GameCenterDetailsGameCenterLeaderboardSetsV2GetToManyRelated.id
            return (response, HTTPBody("""
            {
              "data": \(isList ? "[" : ""){
                "type": "gameCenterLeaderboardSets",
                "id": "leaderboard-set-1",
                "attributes": {
                  "referenceName": "Seasonal",
                  "vendorIdentifier": "seasonal"
                },
                "relationships": {
                  "gameCenterDetail": {"data": {"type": "gameCenterDetails", "id": "gc-detail-1"}},
                  "gameCenterLeaderboards": {
                    "data": [{"type": "gameCenterLeaderboards", "id": "leaderboard-1"}]
                  },
                  "versions": {
                    "data": [{"type": "gameCenterLeaderboardSetVersions", "id": "leaderboard-set-version-1"}]
                  }
                }
              }\(isList ? "]" : ""),
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/gameCenterLeaderboardSets/leaderboard-set-1"}
            }
            """))
        case Operations.GameCenterDetailsGameCenterChallengesGetToManyRelated.id,
            Operations.GameCenterChallengesGetInstance.id:
            let isList = operationID == Operations.GameCenterDetailsGameCenterChallengesGetToManyRelated.id
            return (response, HTTPBody("""
            {
              "data": \(isList ? "[" : ""){
                "type": "gameCenterChallenges",
                "id": "challenge-1",
                "attributes": {
                  "referenceName": "Daily Score",
                  "vendorIdentifier": "daily_score",
                  "challengeType": "LEADERBOARD",
                  "archived": false,
                  "repeatable": true
                },
                "relationships": {
                  "gameCenterDetail": {"data": {"type": "gameCenterDetails", "id": "gc-detail-1"}},
                  "leaderboardV2": {"data": {"type": "gameCenterLeaderboards", "id": "leaderboard-1"}},
                  "versions": {
                    "data": [{"type": "gameCenterChallengeVersions", "id": "challenge-version-1"}]
                  }
                }
              }\(isList ? "]" : ""),
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/gameCenterChallenges/challenge-1"}
            }
            """))
#endif
#if ASC_PUBLIC_API_SIGNING_ACCESS
        case Operations.ActorsGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "actors",
                  "id": "actor-1",
                  "attributes": {
                    "actorType": "USER",
                    "userEmail": "developer@example.com",
                    "userFirstName": "Dev",
                    "userLastName": "User"
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/actors",
                "next": "https://api.appstoreconnect.apple.com/v1/actors?page=2"
              }
            }
            """))
        case Operations.ActorsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "actors",
                "id": "actor-1",
                "attributes": {
                  "actorType": "USER",
                  "userEmail": "developer@example.com",
                  "userFirstName": "Dev",
                  "userLastName": "User"
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/actors/actor-1"}
            }
            """))
#endif
#if ASC_PUBLIC_API_DISTRIBUTION
        case Operations.AlternativeDistributionDomainsGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "alternativeDistributionDomains",
                  "id": "domain-1",
                  "attributes": {
                    "createdDate": "2026-05-01T00:00:00Z",
                    "domain": "apps.example.com",
                    "referenceName": "EU Store"
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/alternativeDistributionDomains",
                "next": "https://api.appstoreconnect.apple.com/v1/alternativeDistributionDomains?page=2"
              }
            }
            """))
        case Operations.AlternativeDistributionDomainsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "alternativeDistributionDomains",
                "id": "domain-1",
                "attributes": {
                  "createdDate": "2026-05-01T00:00:00Z",
                  "domain": "apps.example.com",
                  "referenceName": "EU Store"
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/alternativeDistributionDomains/domain-1"}
            }
            """))
        case Operations.AlternativeDistributionKeysGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "alternativeDistributionKeys",
                  "id": "key-1",
                  "attributes": {
                    "publicKey": "public-key"
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/alternativeDistributionKeys",
                "next": "https://api.appstoreconnect.apple.com/v1/alternativeDistributionKeys?page=2"
              }
            }
            """))
        case Operations.AlternativeDistributionKeysGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "alternativeDistributionKeys",
                "id": "key-1",
                "attributes": {
                  "publicKey": "public-key"
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/alternativeDistributionKeys/key-1"}
            }
            """))
        case Operations.MarketplaceWebhooksGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "marketplaceWebhooks",
                  "id": "marketplace-webhook-1",
                  "attributes": {
                    "endpointUrl": "https://example.com/marketplace"
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/marketplaceWebhooks",
                "next": "https://api.appstoreconnect.apple.com/v1/marketplaceWebhooks?page=2"
              }
            }
            """))
        case Operations.AppsWebhooksGetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "webhooks",
                  "id": "webhook-1",
                  "attributes": {
                    "enabled": true,
                    "eventTypes": ["BUILD_UPLOAD_STATE_UPDATED"],
                    "name": "Release hook",
                    "url": "https://example.com/asc"
                  },
                  "relationships": {
                    "app": {
                      "data": {"type": "apps", "id": "app-1"}
                    }
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/apps/app-1/webhooks",
                "next": "https://api.appstoreconnect.apple.com/v1/apps/app-1/webhooks?page=2"
              }
            }
            """))
        case Operations.WebhooksGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "webhooks",
                "id": "webhook-1",
                "attributes": {
                  "enabled": true,
                  "eventTypes": ["BUILD_UPLOAD_STATE_UPDATED"],
                  "name": "Release hook",
                  "url": "https://example.com/asc"
                },
                "relationships": {
                  "app": {
                    "data": {"type": "apps", "id": "app-1"}
                  }
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/webhooks/webhook-1"}
            }
            """))
        case Operations.WebhooksDeliveriesGetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "webhookDeliveries",
                  "id": "delivery-1",
                  "attributes": {
                    "createdDate": "2026-05-01T12:00:00Z",
                    "deliveryState": "SUCCEEDED",
                    "redelivery": false,
                    "sentDate": "2026-05-01T12:00:02Z",
                    "request": {
                      "url": "https://example.com/asc"
                    },
                    "response": {
                      "httpStatusCode": 200,
                      "body": "ok"
                    }
                  },
                  "relationships": {
                    "event": {
                      "data": {"type": "webhookEvents", "id": "event-1"}
                    }
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/webhooks/webhook-1/deliveries"
              }
            }
            """))
        case Operations.WebhooksDeliveriesGetToManyRelationship.id:
            return (response, HTTPBody("""
            {
              "data": [
                {"type": "webhookDeliveries", "id": "delivery-1"}
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/webhooks/webhook-1/relationships/deliveries",
                "next": "https://api.appstoreconnect.apple.com/v1/webhooks/webhook-1/relationships/deliveries?page=2"
              }
            }
            """))
        case Operations.WebhooksCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "webhooks",
                "id": "webhook-2",
                "attributes": {
                  "enabled": true,
                  "eventTypes": ["BUILD_UPLOAD_STATE_UPDATED"],
                  "name": "Release hook",
                  "url": "https://example.com/asc"
                },
                "relationships": {
                  "app": {
                    "data": {"type": "apps", "id": "app-1"}
                  }
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/webhooks/webhook-2"}
            }
            """))
        case Operations.WebhooksUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "webhooks",
                "id": "webhook-1",
                "attributes": {
                  "enabled": false,
                  "eventTypes": ["BETA_FEEDBACK_CRASH_SUBMISSION_CREATED"],
                  "name": "Release hook updated",
                  "url": "https://example.com/asc-updated"
                },
                "relationships": {
                  "app": {
                    "data": {"type": "apps", "id": "app-1"}
                  }
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/webhooks/webhook-1"}
            }
            """))
        case Operations.WebhooksDeleteInstance.id:
            response.status = .noContent
            return (response, nil)
        case Operations.WebhookDeliveriesCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "webhookDeliveries",
                "id": "delivery-2",
                "attributes": {
                  "createdDate": "2026-05-01T12:05:00Z",
                  "deliveryState": "PENDING",
                  "redelivery": true,
                  "sentDate": "2026-05-01T12:05:02Z",
                  "request": {
                    "url": "https://example.com/asc"
                  },
                  "response": {
                    "httpStatusCode": 202,
                    "body": "accepted"
                  }
                },
                "relationships": {
                  "event": {
                    "data": {"type": "webhookEvents", "id": "event-1"}
                  }
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/webhookDeliveries/delivery-2"}
            }
            """))
        case Operations.WebhookPingsCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "webhookPings",
                "id": "ping-1"
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/webhookPings/ping-1"}
            }
            """))
        case Operations.TerritoriesGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "territories",
                  "id": "USA",
                  "attributes": {
                    "currency": "USD"
                  }
                },
                {
                  "type": "territories",
                  "id": "CAN",
                  "attributes": {
                    "currency": "CAD"
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/territories",
                "next": "https://api.appstoreconnect.apple.com/v1/territories?page=2"
              }
            }
            """))
        case Operations.EndUserLicenseAgreementsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "endUserLicenseAgreements",
                "id": "eula-1",
                "attributes": {
                  "agreementText": "Custom EULA text"
                },
                "relationships": {
                  "app": {
                    "data": {"type": "apps", "id": "app-1"}
                  },
                  "territories": {
                    "data": [
                      {"type": "territories", "id": "USA"},
                      {"type": "territories", "id": "CAN"}
                    ]
                  }
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/endUserLicenseAgreements/eula-1"}
            }
            """))
        case Operations.EndUserLicenseAgreementsCreateInstance.id:
            var created = HTTPResponse(status: .created)
            created.headerFields[.contentType] = "application/json"
            return (created, HTTPBody("""
            {
              "data": {
                "type": "endUserLicenseAgreements",
                "id": "eula-2",
                "attributes": {
                  "agreementText": "Custom EULA text"
                },
                "relationships": {
                  "app": {
                    "data": {"type": "apps", "id": "app-1"}
                  },
                  "territories": {
                    "data": [
                      {"type": "territories", "id": "USA"},
                      {"type": "territories", "id": "CAN"}
                    ]
                  }
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/endUserLicenseAgreements/eula-2"}
            }
            """))
        case Operations.EndUserLicenseAgreementsUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "endUserLicenseAgreements",
                "id": "eula-1",
                "attributes": {
                  "agreementText": "Updated EULA text"
                },
                "relationships": {
                  "app": {
                    "data": {"type": "apps", "id": "app-1"}
                  },
                  "territories": {
                    "data": [
                      {"type": "territories", "id": "USA"}
                    ]
                  }
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/endUserLicenseAgreements/eula-1"}
            }
            """))
        case Operations.EndUserLicenseAgreementsDeleteInstance.id:
            return (HTTPResponse(status: .noContent), nil)
#endif
#if ASC_PUBLIC_API_CLOUD
        case Operations.CiProductsGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "ciProducts",
                  "id": "ci-product-1",
                  "attributes": {
                    "createdDate": "2026-05-01T00:00:00Z",
                    "name": "My App CI",
                    "productType": "APP"
                  },
                  "relationships": {
                    "app": {"data": {"type": "apps", "id": "app-1"}},
                    "bundleId": {"data": {"type": "bundleIds", "id": "bundle-1"}},
                    "primaryRepositories": {
                      "data": [{"type": "scmRepositories", "id": "repo-1"}]
                    }
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/ciProducts",
                "next": "https://api.appstoreconnect.apple.com/v1/ciProducts?page=2"
              }
            }
            """))
        case Operations.CiProductsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "ciProducts",
                "id": "ci-product-1",
                "attributes": {
                  "createdDate": "2026-05-01T00:00:00Z",
                  "name": "My App CI",
                  "productType": "APP"
                },
                "relationships": {
                  "app": {"data": {"type": "apps", "id": "app-1"}},
                  "bundleId": {"data": {"type": "bundleIds", "id": "bundle-1"}},
                  "primaryRepositories": {
                    "data": [{"type": "scmRepositories", "id": "repo-1"}]
                  }
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/ciProducts/ci-product-1"}
            }
            """))
        case Operations.CiProductsWorkflowsGetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "ciWorkflows",
                  "id": "ci-workflow-1",
                  "attributes": {
                    "name": "Release",
                    "description": "Release workflow",
                    "isEnabled": true,
                    "isLockedForEditing": false,
                    "clean": true,
                    "containerFilePath": "ci_scripts/release.yml",
                    "lastModifiedDate": "2026-05-01T01:00:00Z"
                  },
                  "relationships": {
                    "product": {"data": {"type": "ciProducts", "id": "ci-product-1"}},
                    "repository": {"data": {"type": "scmRepositories", "id": "repo-1"}},
                    "xcodeVersion": {"data": {"type": "ciXcodeVersions", "id": "xcode-1"}},
                    "macOsVersion": {"data": {"type": "ciMacOsVersions", "id": "macos-1"}}
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/ciProducts/ci-product-1/workflows",
                "next": "https://api.appstoreconnect.apple.com/v1/ciProducts/ci-product-1/workflows?page=2"
              }
            }
            """))
        case Operations.CiWorkflowsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "ciWorkflows",
                "id": "ci-workflow-1",
                "attributes": {
                  "name": "Release",
                  "description": "Release workflow",
                  "isEnabled": true,
                  "isLockedForEditing": false,
                  "clean": true,
                  "containerFilePath": "ci_scripts/release.yml",
                  "lastModifiedDate": "2026-05-01T01:00:00Z"
                },
                "relationships": {
                  "product": {"data": {"type": "ciProducts", "id": "ci-product-1"}},
                  "repository": {"data": {"type": "scmRepositories", "id": "repo-1"}},
                  "xcodeVersion": {"data": {"type": "ciXcodeVersions", "id": "xcode-1"}},
                  "macOsVersion": {"data": {"type": "ciMacOsVersions", "id": "macos-1"}}
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/ciWorkflows/ci-workflow-1"}
            }
            """))
        case Operations.CiWorkflowsBuildRunsGetToManyRelated.id:
            return (response, HTTPBody(Self.xcodeCloudBuildRunsJSON(
                selfURL: "https://api.appstoreconnect.apple.com/v1/ciWorkflows/ci-workflow-1/buildRuns"
            )))
        case Operations.CiProductsBuildRunsGetToManyRelated.id:
            return (response, HTTPBody(Self.xcodeCloudBuildRunsJSON(
                selfURL: "https://api.appstoreconnect.apple.com/v1/ciProducts/ci-product-1/buildRuns"
            )))
        case Operations.CiBuildRunsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "ciBuildRuns",
                "id": "ci-run-1",
                "attributes": {
                  "number": 42,
                  "createdDate": "2026-05-01T02:00:00Z",
                  "startedDate": "2026-05-01T02:01:00Z",
                  "finishedDate": "2026-05-01T02:10:00Z",
                  "sourceCommit": {"commitSha": "abc123"},
                  "destinationCommit": {"commitSha": "def456"},
                  "isPullRequestBuild": false,
                  "executionProgress": "COMPLETE",
                  "completionStatus": "SUCCEEDED",
                  "startReason": "MANUAL"
                },
                "relationships": {
                  "workflow": {"data": {"type": "ciWorkflows", "id": "ci-workflow-1"}},
                  "product": {"data": {"type": "ciProducts", "id": "ci-product-1"}},
                  "builds": {"data": [{"type": "builds", "id": "build-1"}]}
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/ciBuildRuns/ci-run-1"}
            }
            """))
        case Operations.CiBuildRunsActionsGetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "ciBuildActions",
                  "id": "ci-action-1",
                  "attributes": {
                    "name": "Archive",
                    "actionType": "ARCHIVE",
                    "executionProgress": "COMPLETE",
                    "completionStatus": "SUCCEEDED",
                    "isRequiredToPass": true,
                    "startedDate": "2026-05-01T02:03:00Z",
                    "finishedDate": "2026-05-01T02:08:00Z"
                  },
                  "relationships": {
                    "buildRun": {"data": {"type": "ciBuildRuns", "id": "ci-run-1"}}
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/ciBuildRuns/ci-run-1/actions",
                "next": "https://api.appstoreconnect.apple.com/v1/ciBuildRuns/ci-run-1/actions?page=2"
              }
            }
            """))
        case Operations.CiBuildActionsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "ciBuildActions",
                "id": "ci-action-1",
                "attributes": {
                  "name": "Archive",
                  "actionType": "ARCHIVE",
                  "executionProgress": "COMPLETE",
                  "completionStatus": "SUCCEEDED",
                  "isRequiredToPass": true,
                  "startedDate": "2026-05-01T02:03:00Z",
                  "finishedDate": "2026-05-01T02:08:00Z"
                },
                "relationships": {
                  "buildRun": {"data": {"type": "ciBuildRuns", "id": "ci-run-1"}}
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/ciBuildActions/ci-action-1"}
            }
            """))
        case Operations.CiBuildActionsArtifactsGetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "ciArtifacts",
                  "id": "ci-artifact-1",
                  "attributes": {
                    "fileType": "LOG_BUNDLE",
                    "fileName": "build.logbundle",
                    "fileSize": 2048,
                    "downloadUrl": "https://example.com/artifacts/build.logbundle"
                  }
                },
                {
                  "type": "ciArtifacts",
                  "id": "ci-artifact-2",
                  "attributes": {
                    "fileType": "ARCHIVE",
                    "fileName": "MyApp.xcarchive.zip",
                    "fileSize": 4096,
                    "downloadUrl": "https://example.com/artifacts/MyApp.xcarchive.zip"
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/ciBuildActions/ci-action-1/artifacts",
                "next": "https://api.appstoreconnect.apple.com/v1/ciBuildActions/ci-action-1/artifacts?page=2"
              }
            }
            """))
        case Operations.CiArtifactsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "ciArtifacts",
                "id": "ci-artifact-1",
                "attributes": {
                  "fileType": "LOG_BUNDLE",
                  "fileName": "build.logbundle",
                  "fileSize": 2048,
                  "downloadUrl": "https://example.com/artifacts/build.logbundle"
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/ciArtifacts/ci-artifact-1"}
            }
            """))
#endif
        case Operations.AnalyticsReportsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "analyticsReports",
                "id": "report-1",
                "attributes": {
                  "category": "PERFORMANCE",
                  "name": "Performance Overview"
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/analyticsReports/report-1"}
            }
            """))
        case Operations.AnalyticsReportRequestsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "analyticsReportRequests",
                "id": "request-1",
                "attributes": {
                  "accessType": "ONE_TIME_SNAPSHOT",
                  "stoppedDueToInactivity": false
                },
                "relationships": {
                  "reports": {
                    "data": [
                      {"type": "analyticsReports", "id": "report-1"}
                    ]
                  }
                }
              },
              "included": [
                {
                  "type": "analyticsReports",
                  "id": "report-1",
                  "attributes": {
                    "category": "PERFORMANCE",
                    "name": "Performance Overview"
                  }
                }
              ],
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/analyticsReportRequests/request-1"}
            }
            """))
        case Operations.AnalyticsReportSegmentsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "analyticsReportSegments",
                "id": "segment-1",
                "attributes": {
                  "checksum": "sha256:abc",
                  "sizeInBytes": 10,
                  "url": "https://example.com/segments/segment-1.gz"
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/analyticsReportSegments/segment-1"}
            }
            """))
        case Operations.AnalyticsReportInstancesGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "analyticsReportInstances",
                "id": "instance-1",
                "attributes": {
                  "granularity": "DAILY",
                  "processingDate": "2026-05-01"
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/analyticsReportInstances/instance-1"}
            }
            """))
        case Operations.AnalyticsReportRequestsCreateInstance.id:
            var created = HTTPResponse(status: .created)
            created.headerFields[.contentType] = "application/json"
            return (created, HTTPBody("""
            {
              "data": {
                "type": "analyticsReportRequests",
                "id": "request-1",
                "attributes": {
                  "accessType": "ONGOING",
                  "stoppedDueToInactivity": false
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/analyticsReportRequests/request-1"}
            }
            """))
        case Operations.AnalyticsReportRequestsDeleteInstance.id:
            return (HTTPResponse(status: .noContent), nil)
        case Operations.SalesReportsGetCollection.id:
            var reportResponse = HTTPResponse(status: .ok)
            reportResponse.headerFields[.contentType] = "application/a-gzip"
            return (reportResponse, HTTPBody("sales-data"))
        case Operations.FinanceReportsGetCollection.id:
            var reportResponse = HTTPResponse(status: .ok)
            reportResponse.headerFields[.contentType] = "application/a-gzip"
            return (reportResponse, HTTPBody("finance-data"))
#if ASC_PUBLIC_API_REPORTS
        case Operations.AppsPerfPowerMetricsGetToManyRelated.id:
            var metricsResponse = HTTPResponse(status: .ok)
            metricsResponse.headerFields[.contentType] = "application/vnd.apple.xcode-metrics+json"
            return (metricsResponse, HTTPBody(Self.performanceMetricsJSON(
                platform: "IOS",
                category: "HANG",
                metric: "hangRate"
            )))
        case Operations.BuildsPerfPowerMetricsGetToManyRelated.id:
            var metricsResponse = HTTPResponse(status: .ok)
            metricsResponse.headerFields[.contentType] = "application/vnd.apple.xcode-metrics+json"
            return (metricsResponse, HTTPBody(Self.performanceMetricsJSON(
                platform: "IOS",
                category: "LAUNCH",
                metric: "launchTime"
            )))
#endif
        case Operations.BuildsGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "builds",
                  "id": "build-1",
                  "attributes": {
                    "version": "42",
                    "processingState": "VALID",
                    "expired": false,
                    "minOsVersion": "17.0"
                  },
                  "relationships": {
                    "app": {
                      "data": {"type": "apps", "id": "app-1"}
                    }
                  }
                },
                {
                  "type": "builds",
                  "id": "build-2",
                  "attributes": {
                    "version": "43",
                    "processingState": "PROCESSING",
                    "expired": false
                  },
                  "relationships": {
                    "app": {
                      "data": {"type": "apps", "id": "app-1"}
                    }
                  }
                }
              ],
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/builds"}
            }
            """))
        case Operations.BuildsGetInstance.id:
            let processingState = nextBuildInstanceProcessingState()
            return (response, HTTPBody("""
            {
              "data": {
                "type": "builds",
                "id": "build-1",
                "attributes": {
                  "version": "42",
                  "processingState": "\(processingState)",
                  "expired": false
                },
                "relationships": {
                  "app": {
                    "data": {"type": "apps", "id": "app-1"}
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/builds/build-1"}
            }
            """))
        case Operations.BuildBetaDetailsGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "buildBetaDetails",
                  "id": "beta-detail-1",
                  "attributes": {
                    "autoNotifyEnabled": true,
                    "internalBuildState": "READY_FOR_BETA_TESTING",
                    "externalBuildState": "READY_FOR_BETA_TESTING"
                  },
                  "relationships": {
                    "build": {
                      "data": {"type": "builds", "id": "build-1"}
                    }
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/buildBetaDetails",
                "next": "https://api.appstoreconnect.apple.com/v1/buildBetaDetails?page=2"
              }
            }
            """))
        case Operations.BuildBetaDetailsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "buildBetaDetails",
                "id": "beta-detail-1",
                "attributes": {
                  "autoNotifyEnabled": true,
                  "internalBuildState": "READY_FOR_BETA_TESTING",
                  "externalBuildState": "READY_FOR_BETA_TESTING"
                },
                "relationships": {
                  "build": {
                    "data": {"type": "builds", "id": "build-1"}
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/buildBetaDetails/beta-detail-1"}
            }
            """))
        case Operations.PreReleaseVersionsGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "preReleaseVersions",
                  "id": "pre-1",
                  "attributes": {
                    "version": "1.2.0",
                    "platform": "IOS"
                  },
                  "relationships": {
                    "app": {
                      "data": {"type": "apps", "id": "app-1"}
                    },
                    "builds": {
                      "data": [{"type": "builds", "id": "build-1"}]
                    }
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/preReleaseVersions",
                "next": "https://api.appstoreconnect.apple.com/v1/preReleaseVersions?page=2"
              }
            }
            """))
        case Operations.PreReleaseVersionsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "preReleaseVersions",
                "id": "pre-1",
                "attributes": {
                  "version": "1.2.0",
                  "platform": "IOS"
                },
                "relationships": {
                  "app": {
                    "data": {"type": "apps", "id": "app-1"}
                  },
                  "builds": {
                    "data": [{"type": "builds", "id": "build-1"}]
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/preReleaseVersions/pre-1"}
            }
            """))
        case Operations.BetaAppLocalizationsGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "betaAppLocalizations",
                  "id": "beta-app-loc-1",
                  "attributes": {
                    "locale": "en-US",
                    "description": "Join the beta",
                    "feedbackEmail": "beta@example.com",
                    "marketingUrl": "https://example.com/beta",
                    "privacyPolicyUrl": "https://example.com/privacy",
                    "tvOsPrivacyPolicy": "TV privacy"
                  },
                  "relationships": {
                    "app": {
                      "data": {"type": "apps", "id": "app-1"}
                    }
                  }
                }
              ],
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/betaAppLocalizations"}
            }
            """))
        case Operations.BetaAppLocalizationsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "betaAppLocalizations",
                "id": "beta-app-loc-1",
                "attributes": {
                  "locale": "en-US",
                  "description": "Join the beta",
                  "feedbackEmail": "beta@example.com",
                  "marketingUrl": "https://example.com/beta",
                  "privacyPolicyUrl": "https://example.com/privacy",
                  "tvOsPrivacyPolicy": "TV privacy"
                },
                "relationships": {
                  "app": {
                    "data": {"type": "apps", "id": "app-1"}
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/betaAppLocalizations/beta-app-loc-1"}
            }
            """))
        case Operations.BetaBuildLocalizationsGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "betaBuildLocalizations",
                  "id": "beta-build-loc-1",
                  "attributes": {
                    "locale": "en-US",
                    "whatsNew": "Bug fixes"
                  },
                  "relationships": {
                    "build": {
                      "data": {"type": "builds", "id": "build-1"}
                    }
                  }
                }
              ],
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/betaBuildLocalizations"}
            }
            """))
        case Operations.BetaBuildLocalizationsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "betaBuildLocalizations",
                "id": "beta-build-loc-1",
                "attributes": {
                  "locale": "en-US",
                  "whatsNew": "Bug fixes"
                },
                "relationships": {
                  "build": {
                    "data": {"type": "builds", "id": "build-1"}
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/betaBuildLocalizations/beta-build-loc-1"}
            }
            """))
        case Operations.BetaAppReviewDetailsGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "betaAppReviewDetails",
                  "id": "beta-review-detail-1",
                  "attributes": {
                    "contactEmail": "review@example.com",
                    "contactFirstName": "Review",
                    "contactLastName": "Owner",
                    "contactPhone": "+15551234567",
                    "demoAccountName": "demo@example.com",
                    "demoAccountRequired": true,
                    "notes": "Use the demo account."
                  },
                  "relationships": {
                    "app": {
                      "data": {"type": "apps", "id": "app-1"}
                    }
                  }
                }
              ],
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/betaAppReviewDetails"}
            }
            """))
        case Operations.BetaAppReviewDetailsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "betaAppReviewDetails",
                "id": "beta-review-detail-1",
                "attributes": {
                  "contactEmail": "review@example.com",
                  "contactFirstName": "Review",
                  "contactLastName": "Owner",
                  "contactPhone": "+15551234567",
                  "demoAccountName": "demo@example.com",
                  "demoAccountRequired": true,
                  "notes": "Use the demo account."
                },
                "relationships": {
                  "app": {
                    "data": {"type": "apps", "id": "app-1"}
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/betaAppReviewDetails/beta-review-detail-1"}
            }
            """))
        case Operations.BetaAppReviewSubmissionsGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "betaAppReviewSubmissions",
                  "id": "beta-review-submission-1",
                  "attributes": {
                    "betaReviewState": "IN_REVIEW",
                    "submittedDate": "2026-05-01T00:00:00Z"
                  },
                  "relationships": {
                    "build": {
                      "data": {"type": "builds", "id": "build-1"}
                    }
                  }
                }
              ],
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/betaAppReviewSubmissions"}
            }
            """))
        case Operations.BetaAppReviewSubmissionsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "betaAppReviewSubmissions",
                "id": "beta-review-submission-1",
                "attributes": {
                  "betaReviewState": "IN_REVIEW",
                  "submittedDate": "2026-05-01T00:00:00Z"
                },
                "relationships": {
                  "build": {
                    "data": {"type": "builds", "id": "build-1"}
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/betaAppReviewSubmissions/beta-review-submission-1"}
            }
            """))
        case Operations.BetaLicenseAgreementsGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "betaLicenseAgreements",
                  "id": "beta-license-1",
                  "attributes": {
                    "agreementText": "Beta license text"
                  },
                  "relationships": {
                    "app": {
                      "data": {"type": "apps", "id": "app-1"}
                    }
                  }
                }
              ],
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/betaLicenseAgreements"}
            }
            """))
        case Operations.BetaLicenseAgreementsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "betaLicenseAgreements",
                "id": "beta-license-1",
                "attributes": {
                  "agreementText": "Beta license text"
                },
                "relationships": {
                  "app": {
                    "data": {"type": "apps", "id": "app-1"}
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/betaLicenseAgreements/beta-license-1"}
            }
            """))
        case Operations.AppsBetaTesterUsagesGetMetrics.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "dataPoints": [
                    {
                      "start": "2026-05-01T00:00:00Z",
                      "end": "2026-05-02T00:00:00Z",
                      "values": {
                        "sessionCount": 12,
                        "crashCount": 1,
                        "feedbackCount": 2
                      }
                    }
                  ],
                  "dimensions": {
                    "betaTesters": {
                      "data": "tester-1"
                    }
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/apps/app-1/metrics/betaTesterUsages",
                "next": "https://api.appstoreconnect.apple.com/v1/apps/app-1/metrics/betaTesterUsages?page=2"
              }
            }
            """))
        case Operations.BetaGroupsBetaTesterUsagesGetMetrics.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "dataPoints": [
                    {
                      "start": "2026-05-01T00:00:00Z",
                      "end": "2026-05-02T00:00:00Z",
                      "values": {
                        "sessionCount": 12,
                        "crashCount": 1,
                        "feedbackCount": 2
                      }
                    }
                  ],
                  "dimensions": {
                    "betaTesters": {
                      "data": "tester-1"
                    }
                  }
                }
              ],
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/betaGroups/group-1/metrics/betaTesterUsages"}
            }
            """))
        case Operations.BetaTestersBetaTesterUsagesGetMetrics.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "dataPoints": [
                    {
                      "start": "2026-05-01T00:00:00Z",
                      "end": "2026-05-02T00:00:00Z",
                      "values": {
                        "sessionCount": 12,
                        "crashCount": 1,
                        "feedbackCount": 2
                      }
                    }
                  ],
                  "dimensions": {
                    "apps": {
                      "data": "app-1"
                    }
                  }
                }
              ],
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/betaTesters/tester-1/metrics/betaTesterUsages"}
            }
            """))
        case Operations.BetaGroupsPublicLinkUsagesGetMetrics.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "dataPoints": [
                    {
                      "start": "2026-05-01T00:00:00Z",
                      "end": "2026-05-02T00:00:00Z",
                      "values": {
                        "acceptedCount": 40,
                        "didNotAcceptCount": 20,
                        "didNotMeetCriteriaCount": 10,
                        "notClearRatio": 0.1,
                        "notInterestingRatio": 0.2,
                        "notRelevantRatio": 0.3,
                        "viewCount": 100
                      }
                    }
                  ]
                }
              ],
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/betaGroups/group-1/metrics/publicLinkUsages"}
            }
            """))
        case Operations.BuildsBetaBuildUsagesGetMetrics.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "dataPoints": [
                    {
                      "start": "2026-05-01T00:00:00Z",
                      "end": "2026-05-02T00:00:00Z",
                      "values": {
                        "installCount": 20,
                        "inviteCount": 25,
                        "sessionCount": 30,
                        "crashCount": 1,
                        "feedbackCount": 2
                      }
                    }
                  ]
                }
              ],
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/builds/build-1/metrics/betaBuildUsages"}
            }
            """))
        case Operations.BetaTesterInvitationsCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "betaTesterInvitations",
                "id": "invitation-1"
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/betaTesterInvitations/invitation-1"}
            }
            """))
        case Operations.BetaGroupsCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "betaGroups",
                "id": "group-2",
                "attributes": {
                  "name": "External Testers",
                  "isInternalGroup": false,
                  "publicLinkEnabled": true,
                  "publicLinkLimit": 500,
                  "feedbackEnabled": true
                },
                "relationships": {
                  "app": {"data": {"type": "apps", "id": "app-1"}}
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/betaGroups/group-2"}
            }
            """))
        case Operations.BetaGroupsUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "betaGroups",
                "id": "group-1",
                "attributes": {
                  "name": "Renamed Testers",
                  "isInternalGroup": false,
                  "publicLinkEnabled": false,
                  "feedbackEnabled": true
                },
                "relationships": {
                  "app": {"data": {"type": "apps", "id": "app-1"}}
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/betaGroups/group-1"}
            }
            """))
        case Operations.BetaGroupsDeleteInstance.id:
            response.status = .noContent
            return (response, nil)
        case Operations.BetaTestersCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "betaTesters",
                "id": "tester-2",
                "attributes": {
                  "email": "tester@example.com",
                  "firstName": "Test",
                  "lastName": "User",
                  "state": "INVITED",
                  "inviteType": "EMAIL"
                },
                "relationships": {
                  "betaGroups": {
                    "data": [
                      {"type": "betaGroups", "id": "group-1"}
                    ]
                  }
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/betaTesters/tester-2"}
            }
            """))
        case Operations.BetaTestersDeleteInstance.id:
            response.status = .noContent
            return (response, nil)
        case Operations.BetaAppReviewDetailsUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "betaAppReviewDetails",
                "id": "review-detail-1",
                "attributes": {
                  "contactEmail": "qa@example.com",
                  "contactFirstName": "QA",
                  "contactLastName": "Lead",
                  "contactPhone": "+15555550123",
                  "demoAccountName": "demo@example.com",
                  "demoAccountRequired": true,
                  "notes": "Ready for beta review."
                },
                "relationships": {
                  "app": {"data": {"type": "apps", "id": "app-1"}}
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/betaAppReviewDetails/review-detail-1"}
            }
            """))
        case Operations.BetaAppReviewSubmissionsCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "betaAppReviewSubmissions",
                "id": "beta-review-submission-2",
                "attributes": {
                  "betaReviewState": "WAITING_FOR_REVIEW"
                },
                "relationships": {
                  "build": {"data": {"type": "builds", "id": "build-1"}}
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/betaAppReviewSubmissions/beta-review-submission-2"}
            }
            """))
        case Operations.AppsBetaFeedbackCrashSubmissionsGetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "betaFeedbackCrashSubmissions",
                  "id": "crash-feedback-1",
                  "attributes": {
                    "createdDate": "2026-05-01T00:00:00Z",
                    "comment": "It crashed",
                    "email": "tester@example.com",
                    "deviceModel": "iPhone 15",
                    "osVersion": "17.4",
                    "locale": "en-US",
                    "timeZone": "America/Los_Angeles",
                    "architecture": "arm64",
                    "connectionType": "WIFI",
                    "pairedAppleWatch": "Apple Watch",
                    "appUptimeInMilliseconds": 120000,
                    "diskBytesAvailable": 1000000,
                    "diskBytesTotal": 2000000,
                    "batteryPercentage": 88,
                    "screenWidthInPoints": 390,
                    "screenHeightInPoints": 844,
                    "appPlatform": "IOS",
                    "devicePlatform": "IOS",
                    "deviceFamily": "IPHONE",
                    "buildBundleId": "com.example.app"
                  },
                  "relationships": {
                    "build": {"data": {"type": "builds", "id": "build-1"}},
                    "tester": {"data": {"type": "betaTesters", "id": "tester-1"}}
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/apps/app-1/betaFeedbackCrashSubmissions",
                "next": "https://api.appstoreconnect.apple.com/v1/apps/app-1/betaFeedbackCrashSubmissions?page=2"
              }
            }
            """))
        case Operations.BetaFeedbackCrashSubmissionsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "betaFeedbackCrashSubmissions",
                "id": "crash-feedback-1",
                "attributes": {
                  "createdDate": "2026-05-01T00:00:00Z",
                  "comment": "It crashed",
                  "email": "tester@example.com",
                  "deviceModel": "iPhone 15",
                  "osVersion": "17.4",
                  "locale": "en-US",
                  "connectionType": "WIFI",
                  "appPlatform": "IOS",
                  "devicePlatform": "IOS",
                  "deviceFamily": "IPHONE",
                  "buildBundleId": "com.example.app"
                },
                "relationships": {
                  "build": {"data": {"type": "builds", "id": "build-1"}},
                  "tester": {"data": {"type": "betaTesters", "id": "tester-1"}}
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/betaFeedbackCrashSubmissions/crash-feedback-1"}
            }
            """))
        case Operations.BetaFeedbackCrashSubmissionsCrashLogGetToOneRelated.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "betaCrashLogs",
                "id": "crash-log-1",
                "attributes": {
                  "logText": "Thread 0 crashed"
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/betaFeedbackCrashSubmissions/crash-feedback-1/crashLog"}
            }
            """))
        case Operations.BetaCrashLogsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "betaCrashLogs",
                "id": "crash-log-1",
                "attributes": {
                  "logText": "Thread 0 crashed"
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/betaCrashLogs/crash-log-1"}
            }
            """))
        case Operations.AppsBetaFeedbackScreenshotSubmissionsGetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "betaFeedbackScreenshotSubmissions",
                  "id": "screenshot-feedback-1",
                  "attributes": {
                    "createdDate": "2026-05-02T00:00:00Z",
                    "comment": "Layout issue",
                    "email": "tester@example.com",
                    "deviceModel": "iPhone 15",
                    "osVersion": "17.4",
                    "locale": "en-US",
                    "connectionType": "WIFI",
                    "appPlatform": "IOS",
                    "devicePlatform": "IOS",
                    "deviceFamily": "IPHONE",
                    "buildBundleId": "com.example.app",
                    "screenshots": [
                      {
                        "url": "https://example.com/screenshot-1.png",
                        "width": 390,
                        "height": 844,
                        "expirationDate": "2026-06-01T00:00:00Z"
                      },
                      {
                        "url": "https://example.com/screenshot-2.png",
                        "width": 390,
                        "height": 844,
                        "expirationDate": "2026-06-01T00:00:00Z"
                      }
                    ]
                  },
                  "relationships": {
                    "build": {"data": {"type": "builds", "id": "build-1"}},
                    "tester": {"data": {"type": "betaTesters", "id": "tester-1"}}
                  }
                }
              ],
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/apps/app-1/betaFeedbackScreenshotSubmissions"}
            }
            """))
        case Operations.BetaFeedbackScreenshotSubmissionsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "betaFeedbackScreenshotSubmissions",
                "id": "screenshot-feedback-1",
                "attributes": {
                  "createdDate": "2026-05-02T00:00:00Z",
                  "comment": "Layout issue",
                  "email": "tester@example.com",
                  "deviceModel": "iPhone 15",
                  "osVersion": "17.4",
                  "locale": "en-US",
                  "connectionType": "WIFI",
                  "appPlatform": "IOS",
                  "devicePlatform": "IOS",
                  "deviceFamily": "IPHONE",
                  "buildBundleId": "com.example.app",
                  "screenshots": [
                    {
                      "url": "https://example.com/screenshot-1.png",
                      "width": 390,
                      "height": 844,
                      "expirationDate": "2026-06-01T00:00:00Z"
                    },
                    {
                      "url": "https://example.com/screenshot-2.png",
                      "width": 390,
                      "height": 844,
                      "expirationDate": "2026-06-01T00:00:00Z"
                    }
                  ]
                },
                "relationships": {
                  "build": {"data": {"type": "builds", "id": "build-1"}},
                  "tester": {"data": {"type": "betaTesters", "id": "tester-1"}}
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/betaFeedbackScreenshotSubmissions/screenshot-feedback-1"}
            }
            """))
        case Operations.BetaGroupsGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "betaGroups",
                  "id": "group-1",
                  "attributes": {
                    "name": "Internal Testers",
                    "isInternalGroup": true,
                    "publicLinkEnabled": false,
                    "publicLinkLimit": 100,
                    "feedbackEnabled": true
                  },
                  "relationships": {
                    "app": {
                      "data": {"type": "apps", "id": "app-1"}
                    }
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/betaGroups",
                "next": "https://api.appstoreconnect.apple.com/v1/betaGroups?page=2"
              }
            }
            """))
        case Operations.BetaGroupsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "betaGroups",
                "id": "group-1",
                "attributes": {
                  "name": "Internal Testers",
                  "isInternalGroup": true,
                  "publicLinkEnabled": false,
                  "publicLinkLimit": 100,
                  "feedbackEnabled": true
                },
                "relationships": {
                  "app": {
                    "data": {"type": "apps", "id": "app-1"}
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/betaGroups/group-1"}
            }
            """))
        case Operations.BetaTestersGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "betaTesters",
                  "id": "tester-1",
                  "attributes": {
                    "email": "tester@example.com",
                    "firstName": "Test",
                    "lastName": "User",
                    "state": "INVITED",
                    "inviteType": "EMAIL"
                  },
                  "relationships": {
                    "apps": {
                      "data": [{"type": "apps", "id": "app-1"}]
                    },
                    "betaGroups": {
                      "data": [{"type": "betaGroups", "id": "group-1"}]
                    }
                  }
                }
              ],
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/betaTesters"}
            }
            """))
        case Operations.BetaTestersGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "betaTesters",
                "id": "tester-1",
                "attributes": {
                  "email": "tester@example.com",
                  "firstName": "Test",
                  "lastName": "User",
                  "state": "INVITED",
                  "inviteType": "EMAIL"
                },
                "relationships": {
                  "apps": {
                    "data": [{"type": "apps", "id": "app-1"}]
                  },
                  "betaGroups": {
                    "data": [{"type": "betaGroups", "id": "group-1"}]
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/betaTesters/tester-1"}
            }
            """))
        case Operations.BundleIdsGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "bundleIds",
                  "id": "bundle-1",
                  "attributes": {
                    "identifier": "com.example.app",
                    "name": "Example Bundle",
                    "platform": "IOS",
                    "seedId": "TEAM1"
                  },
                  "relationships": {
                    "app": {
                      "data": {"type": "apps", "id": "app-1"}
                    },
                    "profiles": {
                      "data": [{"type": "profiles", "id": "profile-1"}]
                    }
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/bundleIds",
                "next": "https://api.appstoreconnect.apple.com/v1/bundleIds?page=2"
              }
            }
            """))
        case Operations.BundleIdsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "bundleIds",
                "id": "bundle-1",
                "attributes": {
                  "identifier": "com.example.app",
                  "name": "Example Bundle",
                  "platform": "IOS",
                  "seedId": "TEAM1"
                },
                "relationships": {
                  "app": {
                    "data": {"type": "apps", "id": "app-1"}
                  },
                  "profiles": {
                    "data": [{"type": "profiles", "id": "profile-1"}]
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/bundleIds/bundle-1"}
            }
            """))
        case Operations.BundleIdsCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "bundleIds",
                "id": "bundle-2",
                "attributes": {
                  "identifier": "com.example.new",
                  "name": "Example New Bundle",
                  "platform": "IOS",
                  "seedId": "TEAM1"
                },
                "links": {"self":"https://api.appstoreconnect.apple.com/v1/bundleIds/bundle-2"}
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/bundleIds/bundle-2"}
            }
            """))
        case Operations.BundleIdsUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "bundleIds",
                "id": "bundle-1",
                "attributes": {
                  "identifier": "com.example.app",
                  "name": "Example Renamed Bundle",
                  "platform": "IOS",
                  "seedId": "TEAM1"
                },
                "links": {"self":"https://api.appstoreconnect.apple.com/v1/bundleIds/bundle-1"}
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/bundleIds/bundle-1"}
            }
            """))
        case Operations.BundleIdsDeleteInstance.id:
            response.status = .noContent
            return (response, nil)
        case Operations.BundleIdsBundleIdCapabilitiesGetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "bundleIdCapabilities",
                  "id": "capability-1",
                  "attributes": {
                    "capabilityType": "PUSH_NOTIFICATIONS",
                    "settings": [
                      {
                        "key": "ICLOUD_VERSION",
                        "name": "iCloud version",
                        "enabledByDefault": true
                      }
                    ]
                  }
                }
              ],
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/bundleIds/bundle-1/bundleIdCapabilities"}
            }
            """))
        case Operations.BundleIdCapabilitiesCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "bundleIdCapabilities",
                "id": "capability-1",
                "attributes": {
                  "capabilityType": "PUSH_NOTIFICATIONS"
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/bundleIdCapabilities/capability-1"}
            }
            """))
        case Operations.BundleIdCapabilitiesUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "bundleIdCapabilities",
                "id": "capability-1",
                "attributes": {
                  "capabilityType": "PUSH_NOTIFICATIONS",
                  "settings": [
                    {
                      "key": "ICLOUD_VERSION",
                      "name": "iCloud version"
                    }
                  ]
                }
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/bundleIdCapabilities/capability-1"}
            }
            """))
        case Operations.BundleIdCapabilitiesDeleteInstance.id:
            response.status = .noContent
            return (response, nil)
        case Operations.CertificatesGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "certificates",
                  "id": "cert-1",
                  "attributes": {
                    "name": "Apple Development",
                    "displayName": "Example Certificate",
                    "certificateType": "IOS_DEVELOPMENT",
                    "serialNumber": "ABC123",
                    "platform": "IOS",
                    "expirationDate": "2027-01-01T00:00:00Z",
                    "activated": true
                  }
                }
              ],
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/certificates"}
            }
            """))
        case Operations.CertificatesGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "certificates",
                "id": "cert-1",
                "attributes": {
                  "name": "Apple Development",
                  "displayName": "Example Certificate",
                  "certificateType": "IOS_DEVELOPMENT",
                  "serialNumber": "ABC123",
                  "platform": "IOS",
                  "expirationDate": "2027-01-01T00:00:00Z",
                  "activated": true,
                  "certificateContent": "Q0VSVC1DT05URU5U"
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/certificates/cert-1"}
            }
            """))
        case Operations.CertificatesCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "certificates",
                "id": "cert-2",
                "attributes": {
                  "name": "Apple Development",
                  "displayName": "Example Certificate",
                  "certificateType": "IOS_DEVELOPMENT",
                  "serialNumber": "XYZ987",
                  "platform": "IOS",
                  "expirationDate": "2027-01-01T00:00:00Z",
                  "activated": false
                },
                "links": {"self":"https://api.appstoreconnect.apple.com/v1/certificates/cert-2"}
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/certificates/cert-2"}
            }
            """))
        case Operations.CertificatesUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "certificates",
                "id": "cert-1",
                "attributes": {
                  "name": "Apple Development",
                  "displayName": "Example Certificate",
                  "certificateType": "IOS_DEVELOPMENT",
                  "serialNumber": "ABC123",
                  "platform": "IOS",
                  "expirationDate": "2027-01-01T00:00:00Z",
                  "activated": true
                },
                "links": {"self":"https://api.appstoreconnect.apple.com/v1/certificates/cert-1"}
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/certificates/cert-1"}
            }
            """))
        case Operations.CertificatesDeleteInstance.id:
            response.status = .noContent
            return (response, nil)
        case Operations.DevicesGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "devices",
                  "id": "device-1",
                  "attributes": {
                    "name": "iPhone 15",
                    "udid": "00000000-0000000000000001",
                    "platform": "IOS",
                    "status": "ENABLED",
                    "deviceClass": "IPHONE",
                    "model": "iPhone",
                    "addedDate": "2026-01-01T00:00:00Z"
                  }
                }
              ],
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/devices"}
            }
            """))
        case Operations.DevicesGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "devices",
                "id": "device-1",
                "attributes": {
                  "name": "iPhone 15",
                  "udid": "00000000-0000000000000001",
                  "platform": "IOS",
                  "status": "ENABLED",
                  "deviceClass": "IPHONE",
                  "model": "iPhone",
                  "addedDate": "2026-01-01T00:00:00Z"
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/devices/device-1"}
            }
            """))
        case Operations.DevicesCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "devices",
                "id": "device-2",
                "attributes": {
                  "name": "iPhone 16",
                  "udid": "00000000-0000000000000001",
                  "platform": "IOS",
                  "status": "ENABLED",
                  "deviceClass": "IPHONE",
                  "model": "iPhone",
                  "addedDate": "2026-01-01T00:00:00Z"
                },
                "links": {"self":"https://api.appstoreconnect.apple.com/v1/devices/device-2"}
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/devices/device-2"}
            }
            """))
        case Operations.DevicesUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "devices",
                "id": "device-1",
                "attributes": {
                  "name": "iPhone 15",
                  "udid": "00000000-0000000000000001",
                  "platform": "IOS",
                  "status": "DISABLED",
                  "deviceClass": "IPHONE",
                  "model": "iPhone",
                  "addedDate": "2026-01-01T00:00:00Z"
                },
                "links": {"self":"https://api.appstoreconnect.apple.com/v1/devices/device-1"}
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/devices/device-1"}
            }
            """))
        case Operations.ProfilesGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "profiles",
                  "id": "profile-1",
                  "attributes": {
                    "name": "Example App Store Profile",
                    "platform": "IOS",
                    "profileType": "IOS_APP_STORE",
                    "profileState": "ACTIVE",
                    "uuid": "PROFILE-UUID-1",
                    "createdDate": "2026-01-01T00:00:00Z",
                    "expirationDate": "2027-01-01T00:00:00Z"
                  },
                  "relationships": {
                    "bundleId": {
                      "data": {"type": "bundleIds", "id": "bundle-1"}
                    },
                    "certificates": {
                      "data": [{"type": "certificates", "id": "cert-1"}]
                    },
                    "devices": {
                      "data": [{"type": "devices", "id": "device-1"}]
                    }
                  }
                }
              ],
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/profiles"}
            }
            """))
        case Operations.ProfilesGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "profiles",
                "id": "profile-1",
                "attributes": {
                  "name": "Example App Store Profile",
                  "platform": "IOS",
                  "profileType": "IOS_APP_STORE",
                  "profileState": "ACTIVE",
                  "uuid": "PROFILE-UUID-1",
                  "profileContent": "UFJPRklMRS1DT05URU5U",
                  "createdDate": "2026-01-01T00:00:00Z",
                  "expirationDate": "2027-01-01T00:00:00Z"
                },
                "relationships": {
                  "bundleId": {
                    "data": {"type": "bundleIds", "id": "bundle-1"}
                  },
                  "certificates": {
                    "data": [{"type": "certificates", "id": "cert-1"}]
                  },
                  "devices": {
                    "data": [{"type": "devices", "id": "device-1"}]
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/profiles/profile-1"}
            }
            """))
        case Operations.ProfilesCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "profiles",
                "id": "profile-2",
                "attributes": {
                  "name": "Example Development Profile",
                  "platform": "IOS",
                  "profileType": "IOS_APP_DEVELOPMENT",
                  "profileState": "ACTIVE",
                  "uuid": "PROFILE-UUID-2",
                  "createdDate": "2026-01-01T00:00:00Z",
                  "expirationDate": "2027-01-01T00:00:00Z"
                },
                "relationships": {
                  "bundleId": {
                    "data": {"type": "bundleIds", "id": "bundle-1"}
                  },
                  "certificates": {
                    "data": [{"type": "certificates", "id": "cert-1"}]
                  },
                  "devices": {
                    "data": [{"type": "devices", "id": "device-1"}]
                  }
                },
                "links": {"self":"https://api.appstoreconnect.apple.com/v1/profiles/profile-2"}
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/profiles/profile-2"}
            }
            """))
        case Operations.ProfilesDeleteInstance.id:
            response.status = .noContent
            return (response, nil)
        case Operations.UsersGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "users",
                  "id": "user-1",
                  "attributes": {
                    "username": "developer@example.com",
                    "firstName": "Dev",
                    "lastName": "User",
                    "roles": ["DEVELOPER"],
                    "allAppsVisible": false,
                    "provisioningAllowed": true
                  },
                  "relationships": {
                    "visibleApps": {
                      "data": [{"type": "apps", "id": "app-1"}]
                    }
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/users",
                "next": "https://api.appstoreconnect.apple.com/v1/users?page=2"
              }
            }
            """))
        case Operations.UsersGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "users",
                "id": "user-1",
                "attributes": {
                  "username": "developer@example.com",
                  "firstName": "Dev",
                  "lastName": "User",
                  "roles": ["DEVELOPER"],
                  "allAppsVisible": false,
                  "provisioningAllowed": true
                },
                "relationships": {
                  "visibleApps": {
                    "data": [{"type": "apps", "id": "app-1"}]
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/users\\/user-1"}
            }
            """))
        case Operations.UserInvitationsGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "userInvitations",
                  "id": "invite-1",
                  "attributes": {
                    "email": "invitee@example.com",
                    "firstName": "Invite",
                    "lastName": "User",
                    "expirationDate": "2026-06-01T00:00:00Z",
                    "roles": ["APP_MANAGER"],
                    "allAppsVisible": false,
                    "provisioningAllowed": false
                  },
                  "relationships": {
                    "visibleApps": {
                      "data": [{"type": "apps", "id": "app-1"}]
                    }
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/userInvitations",
                "next": "https://api.appstoreconnect.apple.com/v1/userInvitations?page=2"
              }
            }
            """))
        case Operations.UserInvitationsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "userInvitations",
                "id": "invite-1",
                "attributes": {
                  "email": "invitee@example.com",
                  "firstName": "Invite",
                  "lastName": "User",
                  "expirationDate": "2026-06-01T00:00:00Z",
                  "roles": ["APP_MANAGER"],
                  "allAppsVisible": false,
                  "provisioningAllowed": false
                },
                "relationships": {
                  "visibleApps": {
                    "data": [{"type": "apps", "id": "app-1"}]
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/userInvitations/invite-1"}
            }
            """))
        case Operations.UserInvitationsCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "userInvitations",
                "id": "invite-2",
                "attributes": {
                  "email": "invitee@example.com",
                  "firstName": "Invite",
                  "lastName": "User",
                  "expirationDate": "2026-06-01T00:00:00Z",
                  "roles": ["APP_MANAGER"],
                  "allAppsVisible": false,
                  "provisioningAllowed": true
                },
                "relationships": {
                  "visibleApps": {
                    "data": [{"type": "apps", "id": "app-1"}]
                  }
                },
                "links": {"self":"https://api.appstoreconnect.apple.com/v1/userInvitations/invite-2"}
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/userInvitations/invite-2"}
            }
            """))
        case Operations.UserInvitationsDeleteInstance.id:
            response.status = .noContent
            return (response, nil)
        case Operations.UsersUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "users",
                "id": "user-1",
                "attributes": {
                  "username": "developer@example.com",
                  "firstName": "Dev",
                  "lastName": "User",
                  "roles": ["DEVELOPER"],
                  "allAppsVisible": false,
                  "provisioningAllowed": true
                },
                "relationships": {
                  "visibleApps": {
                    "data": [{"type": "apps", "id": "app-1"}]
                  }
                },
                "links": {"self":"https://api.appstoreconnect.apple.com/v1/users\\/user-1"}
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/users\\/user-1"}
            }
            """))
        case Operations.UsersDeleteInstance.id:
            response.status = .noContent
            return (response, nil)
#if ASC_PUBLIC_API_COMMERCE
        case Operations.AppsPromotedPurchasesGetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "promotedPurchases",
                  "id": "promo-1",
                  "attributes": {
                    "visibleForAllUsers": true,
                    "enabled": true,
                    "state": "APPROVED"
                  },
                  "relationships": {
                    "inAppPurchaseV2": {"data": {"type": "inAppPurchases", "id": "iap-1"}}
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/apps/app-1/promotedPurchases"
              }
            }
            """))
        case Operations.PromotedPurchasesGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "promotedPurchases",
                "id": "promo-1",
                "attributes": {
                  "visibleForAllUsers": true,
                  "enabled": true,
                  "state": "APPROVED"
                },
                "relationships": {
                  "inAppPurchaseV2": {"data": {"type": "inAppPurchases", "id": "iap-1"}}
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/promotedPurchases/promo-1"}
            }
            """))
        case Operations.PromotedPurchasesCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "promotedPurchases",
                "id": "promo-1",
                "attributes": {
                  "visibleForAllUsers": true,
                  "enabled": true,
                  "state": "PREPARE_FOR_SUBMISSION"
                },
                "relationships": {
                  "inAppPurchaseV2": {"data": {"type": "inAppPurchases", "id": "iap-1"}}
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/promotedPurchases/promo-1"}
            }
            """))
        case Operations.PromotedPurchasesUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "promotedPurchases",
                "id": "promo-1",
                "attributes": {
                  "visibleForAllUsers": false,
                  "enabled": false,
                  "state": "APPROVED"
                },
                "relationships": {
                  "inAppPurchaseV2": {"data": {"type": "inAppPurchases", "id": "iap-1"}}
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/promotedPurchases/promo-1"}
            }
            """))
        case Operations.PromotedPurchasesDeleteInstance.id:
            response.status = .noContent
            return (response, nil)
        case Operations.AppsInAppPurchasesV2GetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "inAppPurchases",
                  "id": "iap-1",
                  "attributes": {
                    "name": "Coin Pack",
                    "productId": "coins100",
                    "inAppPurchaseType": "CONSUMABLE",
                    "state": "APPROVED",
                    "familySharable": true
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/apps/app-1/inAppPurchasesV2"
              }
            }
            """))
        case Operations.InAppPurchasesV2GetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "inAppPurchases",
                "id": "iap-1",
                "attributes": {
                  "name": "Coin Pack",
                  "productId": "coins100",
                  "inAppPurchaseType": "CONSUMABLE",
                  "state": "APPROVED",
                  "familySharable": true
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v2/inAppPurchases/iap-1"}
            }
            """))
        case Operations.InAppPurchasesV2CreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "inAppPurchases",
                "id": "iap-1",
                "attributes": {
                  "name": "Coin Pack",
                  "productId": "coins100",
                  "inAppPurchaseType": "CONSUMABLE",
                  "state": "READY_TO_SUBMIT",
                  "familySharable": true
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v2/inAppPurchases/iap-1"}
            }
            """))
        case Operations.InAppPurchasesV2UpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "inAppPurchases",
                "id": "iap-1",
                "attributes": {
                  "name": "Coin Pack Renamed",
                  "productId": "coins100",
                  "inAppPurchaseType": "CONSUMABLE",
                  "state": "READY_TO_SUBMIT",
                  "familySharable": false
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v2/inAppPurchases/iap-1"}
            }
            """))
        case Operations.InAppPurchasesV2DeleteInstance.id:
            response.status = .noContent
            return (response, nil)
        case Operations.InAppPurchaseSubmissionsCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "inAppPurchaseSubmissions",
                "id": "iap-submission-1",
                "relationships": {
                  "inAppPurchaseV2": {
                    "data": {"type": "inAppPurchases", "id": "iap-1"}
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/inAppPurchaseSubmissions/iap-submission-1"}
            }
            """))
        case Operations.InAppPurchasesV2InAppPurchaseLocalizationsGetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "inAppPurchaseLocalizations",
                  "id": "iap-loc-1",
                  "attributes": {
                    "locale": "en-US",
                    "name": "Coin Pack",
                    "description": "100 coins"
                  },
                  "relationships": {
                    "inAppPurchaseV2": {
                      "data": {"type": "inAppPurchases", "id": "iap-1"}
                    }
                  }
                }
              ],
              "links": {"self":"https://api.appstoreconnect.apple.com/v2/inAppPurchases/iap-1/inAppPurchaseLocalizations"}
            }
            """))
        case Operations.InAppPurchaseLocalizationsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "inAppPurchaseLocalizations",
                "id": "iap-loc-1",
                "attributes": {
                  "locale": "en-US",
                  "name": "Coin Pack",
                  "description": "100 coins"
                },
                "relationships": {
                  "inAppPurchaseV2": {
                    "data": {"type": "inAppPurchases", "id": "iap-1"}
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/inAppPurchaseLocalizations/iap-loc-1"}
            }
            """))
        case Operations.InAppPurchaseLocalizationsCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "inAppPurchaseLocalizations",
                "id": "iap-loc-1",
                "attributes": {
                  "locale": "en-US",
                  "name": "Coin Pack",
                  "description": "100 coins"
                },
                "relationships": {
                  "inAppPurchaseV2": {
                    "data": {"type": "inAppPurchases", "id": "iap-1"}
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/inAppPurchaseLocalizations/iap-loc-1"}
            }
            """))
        case Operations.InAppPurchaseLocalizationsUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "inAppPurchaseLocalizations",
                "id": "iap-loc-1",
                "attributes": {
                  "locale": "en-US",
                  "name": "Coin Pack Updated",
                  "description": "Updated 100 coins"
                },
                "relationships": {
                  "inAppPurchaseV2": {
                    "data": {"type": "inAppPurchases", "id": "iap-1"}
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/inAppPurchaseLocalizations/iap-loc-1"}
            }
            """))
        case Operations.InAppPurchaseLocalizationsDeleteInstance.id:
            response.status = .noContent
            return (response, nil)
        case Operations.SubscriptionGroupsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "subscriptionGroups",
                "id": "group-1",
                "attributes": {
                  "referenceName": "Premium"
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/subscriptionGroups/group-1"}
            }
            """))
        case Operations.SubscriptionGroupsCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "subscriptionGroups",
                "id": "group-1",
                "attributes": {
                  "referenceName": "Premium"
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/subscriptionGroups/group-1"}
            }
            """))
        case Operations.SubscriptionGroupsUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "subscriptionGroups",
                "id": "group-1",
                "attributes": {
                  "referenceName": "Premium Renamed"
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/subscriptionGroups/group-1"}
            }
            """))
        case Operations.SubscriptionGroupsDeleteInstance.id:
            response.status = .noContent
            return (response, nil)
        case Operations.SubscriptionGroupsSubscriptionGroupLocalizationsGetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "subscriptionGroupLocalizations",
                  "id": "group-loc-1",
                  "attributes": {
                    "locale": "en-US",
                    "name": "Premium",
                    "customAppName": "Example Premium"
                  },
                  "relationships": {
                    "subscriptionGroup": {
                      "data": {"type": "subscriptionGroups", "id": "group-1"}
                    }
                  }
                }
              ],
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/subscriptionGroups/group-1/subscriptionGroupLocalizations"}
            }
            """))
        case Operations.SubscriptionGroupLocalizationsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "subscriptionGroupLocalizations",
                "id": "group-loc-1",
                "attributes": {
                  "locale": "en-US",
                  "name": "Premium",
                  "customAppName": "Example Premium"
                },
                "relationships": {
                  "subscriptionGroup": {
                    "data": {"type": "subscriptionGroups", "id": "group-1"}
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/subscriptionGroupLocalizations/group-loc-1"}
            }
            """))
        case Operations.SubscriptionGroupLocalizationsCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "subscriptionGroupLocalizations",
                "id": "group-loc-1",
                "attributes": {
                  "locale": "en-US",
                  "name": "Premium",
                  "customAppName": "Example Premium"
                },
                "relationships": {
                  "subscriptionGroup": {
                    "data": {"type": "subscriptionGroups", "id": "group-1"}
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/subscriptionGroupLocalizations/group-loc-1"}
            }
            """))
        case Operations.SubscriptionGroupLocalizationsUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "subscriptionGroupLocalizations",
                "id": "group-loc-1",
                "attributes": {
                  "locale": "en-US",
                  "name": "Premium Updated",
                  "customAppName": "Example Premium Updated"
                },
                "relationships": {
                  "subscriptionGroup": {
                    "data": {"type": "subscriptionGroups", "id": "group-1"}
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/subscriptionGroupLocalizations/group-loc-1"}
            }
            """))
        case Operations.SubscriptionGroupLocalizationsDeleteInstance.id:
            response.status = .noContent
            return (response, nil)
        case Operations.SubscriptionGroupsSubscriptionsGetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "subscriptions",
                  "id": "sub-1",
                  "attributes": {
                    "name": "Premium Monthly",
                    "productId": "premium.monthly",
                    "subscriptionPeriod": "ONE_MONTH",
                    "state": "APPROVED",
                    "groupLevel": 1,
                    "familySharable": true
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/subscriptionGroups/group-1/subscriptions"
              }
            }
            """))
        case Operations.SubscriptionsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "subscriptions",
                "id": "sub-1",
                "attributes": {
                  "name": "Premium Monthly",
                  "productId": "premium.monthly",
                  "subscriptionPeriod": "ONE_MONTH",
                  "state": "APPROVED",
                  "groupLevel": 1,
                  "familySharable": true
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/subscriptions/sub-1"}
            }
            """))
        case Operations.SubscriptionsCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "subscriptions",
                "id": "sub-1",
                "attributes": {
                  "name": "Premium Monthly",
                  "productId": "premium.monthly",
                  "subscriptionPeriod": "ONE_MONTH",
                  "state": "READY_TO_SUBMIT",
                  "groupLevel": 1,
                  "familySharable": true
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/subscriptions/sub-1"}
            }
            """))
        case Operations.SubscriptionsUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "subscriptions",
                "id": "sub-1",
                "attributes": {
                  "name": "Premium Annual",
                  "productId": "premium.monthly",
                  "subscriptionPeriod": "ONE_YEAR",
                  "state": "READY_TO_SUBMIT",
                  "groupLevel": 2,
                  "familySharable": false
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/subscriptions/sub-1"}
            }
            """))
        case Operations.SubscriptionsDeleteInstance.id:
            response.status = .noContent
            return (response, nil)
        case Operations.SubscriptionSubmissionsCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "subscriptionSubmissions",
                "id": "subscription-submission-1",
                "relationships": {
                  "subscription": {
                    "data": {"type": "subscriptions", "id": "sub-1"}
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/subscriptionSubmissions/subscription-submission-1"}
            }
            """))
        case Operations.SubscriptionsSubscriptionLocalizationsGetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "subscriptionLocalizations",
                  "id": "sub-loc-1",
                  "attributes": {
                    "locale": "en-US",
                    "name": "Premium Monthly",
                    "description": "Monthly premium access"
                  },
                  "relationships": {
                    "subscription": {
                      "data": {"type": "subscriptions", "id": "sub-1"}
                    }
                  }
                }
              ],
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/subscriptions/sub-1/subscriptionLocalizations"}
            }
            """))
        case Operations.SubscriptionLocalizationsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "subscriptionLocalizations",
                "id": "sub-loc-1",
                "attributes": {
                  "locale": "en-US",
                  "name": "Premium Monthly",
                  "description": "Monthly premium access"
                },
                "relationships": {
                  "subscription": {
                    "data": {"type": "subscriptions", "id": "sub-1"}
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/subscriptionLocalizations/sub-loc-1"}
            }
            """))
        case Operations.SubscriptionLocalizationsCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "subscriptionLocalizations",
                "id": "sub-loc-1",
                "attributes": {
                  "locale": "en-US",
                  "name": "Premium Monthly",
                  "description": "Monthly premium access"
                },
                "relationships": {
                  "subscription": {
                    "data": {"type": "subscriptions", "id": "sub-1"}
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/subscriptionLocalizations/sub-loc-1"}
            }
            """))
        case Operations.SubscriptionLocalizationsUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "subscriptionLocalizations",
                "id": "sub-loc-1",
                "attributes": {
                  "locale": "en-US",
                  "name": "Premium Monthly Updated",
                  "description": "Updated premium access"
                },
                "relationships": {
                  "subscription": {
                    "data": {"type": "subscriptions", "id": "sub-1"}
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/subscriptionLocalizations/sub-loc-1"}
            }
            """))
        case Operations.SubscriptionLocalizationsDeleteInstance.id:
            response.status = .noContent
            return (response, nil)
        case Operations.SubscriptionsWinBackOffersGetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "winBackOffers",
                  "id": "winback-1",
                  "attributes": {
                    "referenceName": "Come Back",
                    "offerId": "come_back",
                    "duration": "ONE_MONTH",
                    "offerMode": "PAY_AS_YOU_GO",
                    "periodCount": 1,
                    "customerEligibilityPaidSubscriptionDurationInMonths": 3,
                    "customerEligibilityTimeSinceLastSubscribedInMonths": {
                      "minimum": 1,
                      "maximum": 12
                    },
                    "customerEligibilityWaitBetweenOffersInMonths": 6,
                    "startDate": "2026-05-10",
                    "endDate": "2026-12-31",
                    "priority": "NORMAL",
                    "promotionIntent": "NOT_PROMOTED"
                  },
                  "relationships": {
                    "prices": {
                      "data": [{"type": "winBackOfferPrices", "id": "winback-price-1"}]
                    }
                  }
                }
              ],
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/subscriptions/sub-1/winBackOffers"}
            }
            """))
        case Operations.WinBackOffersGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "winBackOffers",
                "id": "winback-1",
                "attributes": {
                  "referenceName": "Come Back",
                  "offerId": "come_back",
                  "duration": "ONE_MONTH",
                  "offerMode": "PAY_AS_YOU_GO",
                  "periodCount": 1,
                  "customerEligibilityPaidSubscriptionDurationInMonths": 3,
                  "customerEligibilityTimeSinceLastSubscribedInMonths": {
                    "minimum": 1,
                    "maximum": 12
                  },
                  "customerEligibilityWaitBetweenOffersInMonths": 6,
                  "startDate": "2026-05-10",
                  "endDate": "2026-12-31",
                  "priority": "NORMAL",
                  "promotionIntent": "NOT_PROMOTED"
                },
                "relationships": {
                  "prices": {
                    "data": [{"type": "winBackOfferPrices", "id": "winback-price-1"}]
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/winBackOffers/winback-1"}
            }
            """))
        case Operations.WinBackOffersCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "winBackOffers",
                "id": "winback-1",
                "attributes": {
                  "referenceName": "Come Back",
                  "offerId": "come_back",
                  "duration": "ONE_MONTH",
                  "offerMode": "PAY_AS_YOU_GO",
                  "periodCount": 1,
                  "customerEligibilityPaidSubscriptionDurationInMonths": 3,
                  "customerEligibilityTimeSinceLastSubscribedInMonths": {
                    "minimum": 1,
                    "maximum": 12
                  },
                  "customerEligibilityWaitBetweenOffersInMonths": 6,
                  "startDate": "2026-05-10",
                  "endDate": "2026-12-31",
                  "priority": "NORMAL",
                  "promotionIntent": "NOT_PROMOTED"
                },
                "relationships": {
                  "prices": {
                    "data": [{"type": "winBackOfferPrices", "id": "winback-price-1"}]
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/winBackOffers/winback-1"}
            }
            """))
        case Operations.WinBackOffersUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "winBackOffers",
                "id": "winback-1",
                "attributes": {
                  "referenceName": "Come Back",
                  "offerId": "come_back",
                  "duration": "ONE_MONTH",
                  "offerMode": "PAY_AS_YOU_GO",
                  "periodCount": 1,
                  "customerEligibilityPaidSubscriptionDurationInMonths": 4,
                  "customerEligibilityTimeSinceLastSubscribedInMonths": {
                    "minimum": 2,
                    "maximum": 10
                  },
                  "customerEligibilityWaitBetweenOffersInMonths": 7,
                  "startDate": "2026-06-01",
                  "endDate": "2026-12-31",
                  "priority": "HIGH",
                  "promotionIntent": "USE_AUTO_GENERATED_ASSETS"
                },
                "relationships": {
                  "prices": {
                    "data": [{"type": "winBackOfferPrices", "id": "winback-price-1"}]
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/winBackOffers/winback-1"}
            }
            """))
        case Operations.WinBackOffersDeleteInstance.id:
            response.status = .noContent
            return (response, nil)
        case Operations.AppsAppPricePointsGetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "appPricePoints",
                  "id": "price-point-1",
                  "attributes": {
                    "customerPrice": "0.99",
                    "proceeds": "0.70"
                  },
                  "relationships": {
                    "app": {
                      "data": {"type": "apps", "id": "app-1"}
                    },
                    "territory": {
                      "data": {"type": "territories", "id": "USA"}
                    }
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/apps/app-1/appPricePoints",
                "next": "https://api.appstoreconnect.apple.com/v1/apps/app-1/appPricePoints?page=2"
              }
            }
            """))
        case Operations.AppsAppPriceScheduleGetToOneRelated.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "appPriceSchedules",
                "id": "price-schedule-1",
                "relationships": {
                  "app": {
                    "data": {"type": "apps", "id": "app-1"}
                  },
                  "baseTerritory": {
                    "data": {"type": "territories", "id": "USA"}
                  },
                  "manualPrices": {
                    "data": [{"type": "appPrices", "id": "price-1"}]
                  },
                  "automaticPrices": {
                    "data": [{"type": "appPrices", "id": "price-2"}]
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/apps/app-1/appPriceSchedule"}
            }
            """))
#endif
        case Operations.AppScreenshotSetsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "appScreenshotSets",
                "id": "set-1",
                "attributes": {
                  "screenshotDisplayType": "APP_IPHONE_67"
                },
                "relationships": {
                  "appScreenshots": {
                    "data": [{"type": "appScreenshots", "id": "screenshot-1"}]
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/appScreenshotSets/set-1"}
            }
            """))
        case Operations.AppScreenshotsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "appScreenshots",
                "id": "screenshot-1",
                "attributes": {
                  "fileName": "iphone-67-1.png",
                  "fileSize": 123456,
                  "assetType": "SCREENSHOT",
                  "assetDeliveryState": {"state": "COMPLETE"},
                  "sourceFileChecksum": "sha256:screenshot"
                },
                "relationships": {
                  "appScreenshotSet": {
                    "data": {"type": "appScreenshotSets", "id": "set-1"}
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/appScreenshots/screenshot-1"}
            }
            """))
        case Operations.AppPreviewSetsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "appPreviewSets",
                "id": "preview-set-1",
                "attributes": {
                  "previewType": "IPHONE_67"
                },
                "relationships": {
                  "appPreviews": {
                    "data": [{"type": "appPreviews", "id": "preview-1"}]
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/appPreviewSets/preview-set-1"}
            }
            """))
        case Operations.AppPreviewsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "appPreviews",
                "id": "preview-1",
                "attributes": {
                  "fileName": "iphone-67-preview.mov",
                  "fileSize": 987654,
                  "mimeType": "video/mp4",
                  "previewFrameTimeCode": "00:00:03:00",
                  "assetDeliveryState": {"state": "COMPLETE"},
                  "videoDeliveryState": {"state": "PROCESSING"},
                  "sourceFileChecksum": "sha256:preview"
                },
                "relationships": {
                  "appPreviewSet": {
                    "data": {"type": "appPreviewSets", "id": "preview-set-1"}
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/appPreviews/preview-1"}
            }
            """))
        case Operations.AppStoreVersionsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "appStoreVersions",
                "id": "version-1",
                "attributes": {
                  "versionString": "1.2.0",
                  "platform": "IOS",
                  "appStoreState": "IN_REVIEW",
                  "appVersionState": "ACCEPTED",
                  "releaseType": "MANUAL"
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/appStoreVersions/version-1"}
            }
            """))
        case Operations.AppsAppStoreVersionsGetToManyRelated.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "appStoreVersions",
                  "id": "version-1",
                  "attributes": {
                    "versionString": "1.2.0",
                    "platform": "IOS",
                    "appStoreState": "IN_REVIEW",
                    "appVersionState": "ACCEPTED",
                    "releaseType": "MANUAL"
                  }
                },
                {
                  "type": "appStoreVersions",
                  "id": "version-2",
                  "attributes": {
                    "versionString": "1.3.0",
                    "platform": "IOS",
                    "appStoreState": "READY_FOR_REVIEW",
                    "appVersionState": "PREPARE_FOR_SUBMISSION",
                    "releaseType": "MANUAL"
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/apps/app-1/appStoreVersions",
                "next": "https://api.appstoreconnect.apple.com/v1/apps/app-1/appStoreVersions?page=2"
              }
            }
            """))
        case Operations.ReviewSubmissionsGetCollection.id:
            return (response, HTTPBody("""
            {
              "data": [
                {
                  "type": "reviewSubmissions",
                  "id": "review-1",
                  "attributes": {
                    "platform": "IOS",
                    "state": "IN_REVIEW"
                  },
                  "relationships": {
                    "app": {
                      "data": {"type": "apps", "id": "app-1"}
                    },
                    "appStoreVersionForReview": {
                      "data": {"type": "appStoreVersions", "id": "version-1"}
                    }
                  }
                }
              ],
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/reviewSubmissions",
                "next": "https://api.appstoreconnect.apple.com/v1/reviewSubmissions?page=2"
              }
            }
            """))
        case Operations.ReviewSubmissionsGetInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "reviewSubmissions",
                "id": "review-1",
                "attributes": {
                  "platform": "IOS",
                  "state": "IN_REVIEW"
                },
                "relationships": {
                  "app": {
                    "data": {"type": "apps", "id": "app-1"}
                  },
                  "appStoreVersionForReview": {
                    "data": {"type": "appStoreVersions", "id": "version-1"}
                  }
                }
              },
              "links": {"self":"https://api.appstoreconnect.apple.com/v1/reviewSubmissions/review-1"}
            }
            """))
        case Operations.AppStoreVersionsCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "appStoreVersions",
                "id": "version-3",
                "attributes": {
                  "versionString": "1.3.0",
                  "platform": "IOS",
                  "appStoreState": "PREPARE_FOR_SUBMISSION",
                  "appVersionState": "PREPARE_FOR_SUBMISSION",
                  "releaseType": "MANUAL"
                },
                "relationships": {
                  "app": {"data": {"type": "apps", "id": "app-1"}},
                  "build": {"data": {"type": "builds", "id": "build-1"}}
                },
                "links": {"self": "https://api.appstoreconnect.apple.com/v1/appStoreVersions/version-3"}
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/appStoreVersions/version-3"}
            }
            """))
        case Operations.AppStoreVersionsUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "appStoreVersions",
                "id": "version-1",
                "attributes": {
                  "versionString": "1.2.0",
                  "platform": "IOS",
                  "appStoreState": "READY_FOR_REVIEW",
                  "appVersionState": "READY_FOR_REVIEW",
                  "releaseType": "AFTER_APPROVAL"
                },
                "relationships": {
                  "app": {"data": {"type": "apps", "id": "app-1"}},
                  "build": {"data": {"type": "builds", "id": "build-2"}}
                },
                "links": {"self": "https://api.appstoreconnect.apple.com/v1/appStoreVersions/version-1"}
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/appStoreVersions/version-1"}
            }
            """))
        case Operations.AppStoreVersionsDeleteInstance.id:
            response.status = .noContent
            return (response, nil)
        case Operations.AppStoreVersionReleaseRequestsCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "appStoreVersionReleaseRequests",
                "id": "release-request-1",
                "links": {
                  "self": "https://api.appstoreconnect.apple.com/v1/appStoreVersionReleaseRequests/release-request-1"
                }
              },
              "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/appStoreVersionReleaseRequests/release-request-1"
              }
            }
            """))
        case Operations.ReviewSubmissionsCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "reviewSubmissions",
                "id": "review-2",
                "attributes": {
                  "platform": "IOS",
                  "state": "READY_FOR_REVIEW"
                },
                "relationships": {
                  "app": {"data": {"type": "apps", "id": "app-1"}}
                },
                "links": {"self": "https://api.appstoreconnect.apple.com/v1/reviewSubmissions/review-2"}
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/reviewSubmissions/review-2"}
            }
            """))
        case Operations.ReviewSubmissionsUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "reviewSubmissions",
                "id": "review-1",
                "attributes": {
                  "platform": "IOS",
                  "state": "WAITING_FOR_REVIEW"
                },
                "relationships": {
                  "app": {"data": {"type": "apps", "id": "app-1"}},
                  "appStoreVersionForReview": {"data": {"type": "appStoreVersions", "id": "version-1"}}
                },
                "links": {"self": "https://api.appstoreconnect.apple.com/v1/reviewSubmissions/review-1"}
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/reviewSubmissions/review-1"}
            }
            """))
        case Operations.ReviewSubmissionItemsCreateInstance.id:
            response.status = .created
            return (response, HTTPBody("""
            {
              "data": {
                "type": "reviewSubmissionItems",
                "id": "item-2",
                "attributes": {
                  "state": "READY_FOR_REVIEW"
                },
                "relationships": {
                  "appStoreVersion": {"data": {"type": "appStoreVersions", "id": "version-1"}}
                },
                "links": {"self": "https://api.appstoreconnect.apple.com/v1/reviewSubmissionItems/item-2"}
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/reviewSubmissionItems/item-2"}
            }
            """))
        case Operations.ReviewSubmissionItemsUpdateInstance.id:
            return (response, HTTPBody("""
            {
              "data": {
                "type": "reviewSubmissionItems",
                "id": "item-1",
                "attributes": {
                  "state": "ACCEPTED"
                },
                "relationships": {
                  "appStoreVersion": {"data": {"type": "appStoreVersions", "id": "version-1"}}
                },
                "links": {"self": "https://api.appstoreconnect.apple.com/v1/reviewSubmissionItems/item-1"}
              },
              "links": {"self": "https://api.appstoreconnect.apple.com/v1/reviewSubmissionItems/item-1"}
            }
            """))
        case Operations.ReviewSubmissionItemsDeleteInstance.id:
            response.status = .noContent
            return (response, nil)
        default:
            return (HTTPResponse(status: .internalServerError), nil)
        }
    }

    func requests() -> [WorkflowRecordedRequest] {
        recordedRequests
    }

    private func nextBuildInstanceProcessingState() -> String {
        if buildInstanceProcessingStates.isEmpty {
            return "VALID"
        }
        return buildInstanceProcessingStates.removeFirst()
    }

#if ASC_PUBLIC_API_RELEASE
    private static func customerReviewsJSON(selfURL: String, nextURL: String) -> String {
        """
        {
          "data": [
            {
              "type": "customerReviews",
              "id": "customer-review-1",
              "attributes": {
                "rating": 5,
                "title": "Great app",
                "body": "Fast and reliable.",
                "reviewerNickname": "Reviewer",
                "createdDate": "2026-05-01T00:00:00Z",
                "territory": "USA"
              },
              "relationships": {
                "response": {
                  "data": {"type": "customerReviewResponses", "id": "customer-review-response-1"}
                }
              }
            }
          ],
          "links": {
            "self": "\(selfURL)",
            "next": "\(nextURL)"
          }
        }
        """
    }

    private static func customerReviewResponseJSON(selfURL: String) -> String {
        """
        {
          "data": {
            "type": "customerReviewResponses",
            "id": "customer-review-response-1",
            "attributes": {
              "responseBody": "Thanks for the review.",
              "state": "PUBLISHED",
              "lastModifiedDate": "2026-05-03T00:00:00Z"
            },
            "relationships": {
              "review": {
                "data": {"type": "customerReviews", "id": "customer-review-1"}
              }
            }
          },
          "links": {"self": "\(selfURL)"}
        }
        """
    }
#endif

#if ASC_PUBLIC_API_CLOUD
    private static func xcodeCloudBuildRunsJSON(selfURL: String) -> String {
        """
        {
          "data": [
            {
              "type": "ciBuildRuns",
              "id": "ci-run-1",
              "attributes": {
                "number": 42,
                "createdDate": "2026-05-01T02:00:00Z",
                "startedDate": "2026-05-01T02:01:00Z",
                "finishedDate": "2026-05-01T02:10:00Z",
                "sourceCommit": {"commitSha": "abc123"},
                "destinationCommit": {"commitSha": "def456"},
                "isPullRequestBuild": false,
                "executionProgress": "COMPLETE",
                "completionStatus": "SUCCEEDED",
                "startReason": "MANUAL"
              },
              "relationships": {
                "workflow": {"data": {"type": "ciWorkflows", "id": "ci-workflow-1"}},
                "product": {"data": {"type": "ciProducts", "id": "ci-product-1"}},
                "builds": {"data": [{"type": "builds", "id": "build-1"}]}
              }
            }
          ],
          "links": {
            "self": "\(selfURL)",
            "next": "\(selfURL)?page=2"
          }
        }
        """
    }
#endif

#if ASC_PUBLIC_API_REPORTS
    private static func performanceMetricsJSON(platform: String, category: String, metric: String) -> String {
        """
        {
          "version": "1.0",
          "productData": [
            {
              "platform": "\(platform)",
              "metricCategories": [
                {
                  "identifier": "\(category)",
                  "metrics": [
                    {
                      "identifier": "\(metric)",
                      "unit": {
                        "identifier": "percent",
                        "displayName": "Percent"
                      },
                      "datasets": [
                        {
                          "filterCriteria": {
                            "device": "iphone"
                          },
                          "points": [
                            {
                              "version": "1.0",
                              "value": 0.1,
                              "errorMargin": 0.01
                            }
                          ]
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ],
          "insights": {
            "regressions": [
              {
                "summaryString": "Regression",
                "metric": "\(metric)",
                "metricCategory": "\(category)"
              }
            ],
            "trendingUp": [
              {
                "summaryString": "Trending up",
                "metric": "\(metric)",
                "metricCategory": "\(category)"
              }
            ]
          }
        }
        """
    }
#endif
}
