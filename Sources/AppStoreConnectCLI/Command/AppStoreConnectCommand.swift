import AppStoreConnectWorkflow
import Foundation

public struct AppStoreConnectCLIResult: Sendable, Equatable {
    public var exitCode: Int32
    public var stdout: String
    public var stderr: String

    public init(exitCode: Int32, stdout: String = "", stderr: String = "") {
        self.exitCode = exitCode
        self.stdout = stdout
        self.stderr = stderr
    }
}

public enum AppStoreConnectCommand {
    public static func run(
        arguments: [String],
        environment: [String: String] = ProcessInfo.processInfo.environment,
        currentDirectory: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    ) async -> AppStoreConnectCLIResult {
        do {
            return try await execute(
                parsed: ParsedArguments(arguments),
                environment: environment,
                currentDirectory: currentDirectory
            )
        } catch let error as CLIError {
            return AppStoreConnectCLIResult(exitCode: error.exitCode, stderr: "\(error.message)\n")
        } catch {
            return AppStoreConnectCLIResult(exitCode: 1, stderr: "\(error)\n")
        }
    }

    private static func execute(
        parsed: ParsedArguments,
        environment: [String: String],
        currentDirectory: URL
    ) async throws -> AppStoreConnectCLIResult {
        guard !parsed.commands.isEmpty, !parsed.hasFlag("help") else {
            return AppStoreConnectCLIResult(exitCode: 0, stdout: helpText)
        }

        switch parsed.commands {
        case ["commands", "list"]:
            return try render(AppStoreConnectCLICommandRegistry.descriptors, json: parsed.wantsJSON)
        case ["workflows", "list"]:
            return try render(BuiltinWorkflow.allCases.map(\.rawValue), json: parsed.wantsJSON)
        case ["workflow", "list"]:
            return try render(BuiltinWorkflow.allCases.map(\.rawValue), json: parsed.wantsJSON)
        case ["workflow", "dry-run", "public-release-readiness"]:
            let input = try publicReleaseReadinessInput(from: parsed)
            return try render(PublicReleaseReadinessWorkflow.dryRun(input), json: parsed.wantsJSON)
        case ["workflow", "run", "public-release-readiness"]:
            let input = try publicReleaseReadinessInput(from: parsed)
            let workflow = try WorkflowRuntime.publicReleaseReadinessWorkflow(
                configuration: WorkflowRuntimeConfiguration(environment: environment)
            )
            return try render(await workflow.run(input), json: parsed.wantsJSON)
        case ["workflow", "run"]:
            let file = try workflowFile(parsed: parsed, currentDirectory: currentDirectory)
            let context = try WorkflowRuntime.executionContext(
                configuration: WorkflowRuntimeConfiguration(environment: environment)
            )
            let result = try await WorkflowFileRunner().run(file, context: context)
            return try render(result, json: parsed.wantsJSON)
        case ["workflow", "validate"]:
            let result = try workflowFileRunnerResult(
                parsed: parsed,
                currentDirectory: currentDirectory
            )
            let exitCode: Int32 = result.validationIssues.isEmpty ? 0 : 2
            return try render(result, json: parsed.wantsJSON, exitCode: exitCode)
        case ["workflow-file", "dry-run"]:
            let result = try workflowFileRunnerResult(
                parsed: parsed,
                currentDirectory: currentDirectory
            )
            let exitCode: Int32 = result.validationIssues.isEmpty ? 0 : 2
            return try render(result, json: parsed.wantsJSON, exitCode: exitCode)
        case ["workflow-file", "run"]:
            let file = try workflowFile(parsed: parsed, currentDirectory: currentDirectory)
            let context = try WorkflowRuntime.executionContext(
                configuration: WorkflowRuntimeConfiguration(environment: environment)
            )
            let result = try await WorkflowFileRunner().run(file, context: context)
            return try render(result, json: parsed.wantsJSON)
        case ["publish", "appstore"], ["publish", "app-store"]:
            if parsed.hasFlag("confirm") {
                throw CLIError(exitCode: 64, message: "publish appstore currently exposes a workflow dry-run plan; live publish orchestration is not implemented yet.")
            }
            return try render(WorkflowRunner().dryRun(.publishAppStore), json: parsed.wantsJSON)
        case ["publish", "testflight"], ["publish", "test-flight"]:
            if parsed.hasFlag("confirm") {
                throw CLIError(exitCode: 64, message: "publish testflight currently exposes a workflow dry-run plan; live publish orchestration is not implemented yet.")
            }
            return try render(WorkflowRunner().dryRun(.publishTestFlight), json: parsed.wantsJSON)
        case ["metadata", "validate"]:
            let result = AppStoreConnectMetadataCommands.validate(
                metadataValidationInput(from: parsed, currentDirectory: currentDirectory)
            )
            return try render(result, json: parsed.wantsJSON, exitCode: result.valid ? 0 : 2)
        case ["metadata", "pull"]:
            if parsed.hasFlag("confirm") {
                throw CLIError(exitCode: 64, message: "metadata pull currently exposes a workflow dry-run plan; live file writing is blocked until the metadata directory contract is finalized.")
            }
            return try render(
                AppStoreConnectMetadataCommands.planPull(metadataPlanInput(from: parsed, currentDirectory: currentDirectory)),
                json: parsed.wantsJSON
            )
        case ["metadata", "push"]:
            if parsed.hasFlag("confirm") {
                throw CLIError(exitCode: 64, message: "metadata push currently exposes a workflow dry-run plan; live metadata apply is blocked until the metadata directory contract is finalized.")
            }
            return try render(
                AppStoreConnectMetadataCommands.planPush(metadataPlanInput(from: parsed, currentDirectory: currentDirectory)),
                json: parsed.wantsJSON
            )
        case ["metadata", "keywords"]:
            if parsed.hasFlag("confirm") {
                throw CLIError(exitCode: 64, message: "metadata keywords currently exposes a dry-run plan; live keyword mutation is blocked until localization file mapping is finalized.")
            }
            return try render(
                AppStoreConnectMetadataCommands.planKeywords(try metadataKeywordsInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["screenshots", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getAppScreenshotSet(mediaAssetSetInput(from: parsed, defaultIDOption: "set")),
                json: parsed.wantsJSON
            )
        case ["screenshots", "view"], ["screenshots", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getAppScreenshot(mediaAssetInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["video-previews", "list"], ["videopreviews", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getAppPreviewSet(mediaAssetSetInput(from: parsed, defaultIDOption: "set")),
                json: parsed.wantsJSON
            )
        case ["video-previews", "view"], ["video-previews", "get"], ["videopreviews", "view"], ["videopreviews", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getAppPreview(mediaAssetInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["auth"], ["auth", "status"]:
            let commands = WorkflowRuntime.authCommands(
                configuration: WorkflowRuntimeConfiguration(environment: environment)
            )
            let status = await commands.status(
                authStatusInput(
                    from: parsed,
                    environment: environment,
                    currentDirectory: currentDirectory
                )
            )
            return try render(status, json: parsed.wantsJSON, exitCode: status.authenticated ? 0 : 1)
        case ["auth", "doctor"]:
            let commands = WorkflowRuntime.authCommands(
                configuration: WorkflowRuntimeConfiguration(environment: environment)
            )
            let doctor = await commands.doctor(
                authStatusInput(
                    from: parsed,
                    environment: environment,
                    currentDirectory: currentDirectory
                )
            )
            return try render(doctor, json: parsed.wantsJSON, exitCode: doctor.healthy ? 0 : 1)
        case ["auth", "logout"]:
            let commands = WorkflowRuntime.authCommands(
                configuration: WorkflowRuntimeConfiguration(environment: environment)
            )
            let input = authLogoutInput(
                from: parsed,
                environment: environment,
                currentDirectory: currentDirectory
            )
            if parsed.hasFlag("confirm") {
                if parsed.hasFlag("dry-run") {
                    throw CLIError(exitCode: 64, message: "Use either --dry-run or --confirm, not both.")
                }
                return try render(try commands.logout(input), json: parsed.wantsJSON)
            }
            return try render(AppStoreConnectAuthCommands.planLogout(input), json: parsed.wantsJSON)
        case ["xcode", "version"]:
            let input = xcodeVersionInput(
                from: parsed,
                environment: environment,
                currentDirectory: currentDirectory
            )
            if parsed.hasFlag("dry-run") {
                return try render(AppStoreConnectXcodeCommands.planVersion(input), json: parsed.wantsJSON)
            }
            let result = try await WorkflowRuntime.xcodeCommands().version(input)
            return try render(result, json: parsed.wantsJSON, exitCode: result.result.exitCode)
        case ["xcode", "archive"]:
            let input = try xcodeArchiveInput(
                from: parsed,
                environment: environment,
                currentDirectory: currentDirectory
            )
            return try await renderXcodeToolCommand(
                parsed: parsed,
                plan: try AppStoreConnectXcodeCommands.planArchive(input)
            ) { commands in
                try await commands.archive(input)
            }
        case ["xcode", "export"]:
            let input = try xcodeExportInput(
                from: parsed,
                environment: environment,
                currentDirectory: currentDirectory
            )
            return try await renderXcodeToolCommand(
                parsed: parsed,
                plan: AppStoreConnectXcodeCommands.planExport(input)
            ) { commands in
                try await commands.export(input)
            }
        case ["xcode", "upload"]:
            let input = try xcodeUploadInput(
                from: parsed,
                environment: environment,
                currentDirectory: currentDirectory
            )
            return try await renderXcodeToolCommand(
                parsed: parsed,
                plan: AppStoreConnectXcodeCommands.planUpload(input)
            ) { commands in
                try await commands.upload(input)
            }
        case ["apps", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listApps(appListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["apps", "view"], ["apps", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getApp(appViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["apps", "update"]:
            let input = try appUpdateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateApp(input)
            ) { commands in
                try await commands.updateApp(input)
            }
#if ASC_PUBLIC_API_RELEASE
        case ["categories", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listAppCategories(appCategoryListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["categories", "view"], ["categories", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getAppCategory(appCategoryViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["categories", "parent"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getAppCategoryParent(appCategoryParentInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["categories", "subcategories"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listAppCategorySubcategories(appCategorySubcategoriesInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["categories", "set"], ["categories", "edit"], ["categories", "update"]:
            let input = try appCategoryUpdateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateAppCategory(input)
            ) { commands in
                try await commands.updateAppCategory(input)
            }
        case ["age-rating", "view"], ["age-rating", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getAgeRating(ageRatingViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["age-rating", "update"], ["age-rating", "edit"], ["age-rating", "set"]:
            let input = try ageRatingUpdateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateAgeRating(input)
            ) { commands in
                try await commands.updateAgeRating(input)
            }
        case ["app-events", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listAppEvents(try appEventListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["app-events", "view"], ["app-events", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getAppEvent(try appEventViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["app-events", "create"]:
            let input = try appEventCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateAppEvent(input)
            ) { commands in
                try await commands.createAppEvent(input)
            }
        case ["app-events", "update"]:
            let input = try appEventUpdateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateAppEvent(input)
            ) { commands in
                try await commands.updateAppEvent(input)
            }
        case ["app-events", "delete"]:
            let input = try appEventDeleteInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeleteAppEvent(input)
            ) { commands in
                try await commands.deleteAppEvent(input)
            }
#endif
#if ASC_PUBLIC_API_METADATA_MEDIA
        case ["app-clips", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listAppClips(try appClipListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["app-clips", "view"], ["app-clips", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getAppClip(try appClipViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["app-clips", "default-experiences", "list"], ["app-clips", "experiences", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listAppClipDefaultExperiences(try appClipDefaultExperienceListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["app-clips", "default-experiences", "view"],
            ["app-clips", "default-experiences", "get"],
            ["app-clips", "experiences", "view"],
            ["app-clips", "experiences", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getAppClipDefaultExperience(try appClipDefaultExperienceViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["app-clips", "localizations", "list"],
            ["app-clips", "default-experiences", "localizations", "list"],
            ["app-clips", "experiences", "localizations", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listAppClipLocalizations(try appClipLocalizationListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["app-clips", "localizations", "view"],
            ["app-clips", "localizations", "get"],
            ["app-clips", "default-experiences", "localizations", "view"],
            ["app-clips", "default-experiences", "localizations", "get"],
            ["app-clips", "experiences", "localizations", "view"],
            ["app-clips", "experiences", "localizations", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getAppClipLocalization(try appClipLocalizationViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
#endif
#if ASC_PUBLIC_API_GAME_CENTER
        case ["game-center", "details", "app"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getGameCenterDetailForApp(try gameCenterDetailForAppInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["game-center", "details", "view"], ["game-center", "details", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getGameCenterDetail(try gameCenterDetailViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["game-center", "achievements", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listGameCenterAchievements(try gameCenterNamedResourceListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["game-center", "achievements", "view"], ["game-center", "achievements", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getGameCenterAchievement(try gameCenterResourceViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["game-center", "leaderboards", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listGameCenterLeaderboards(try gameCenterNamedResourceListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["game-center", "leaderboards", "view"], ["game-center", "leaderboards", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getGameCenterLeaderboard(try gameCenterResourceViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["game-center", "leaderboard-sets", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listGameCenterLeaderboardSets(try gameCenterNamedResourceListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["game-center", "leaderboard-sets", "view"], ["game-center", "leaderboard-sets", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getGameCenterLeaderboardSet(try gameCenterResourceViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["game-center", "challenges", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listGameCenterChallenges(try gameCenterNamedResourceListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["game-center", "challenges", "view"], ["game-center", "challenges", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getGameCenterChallenge(try gameCenterResourceViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
#endif
#if ASC_PUBLIC_API_DISTRIBUTION
        case ["alternative-distribution", "domains", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listAlternativeDistributionDomains(
                    alternativeDistributionDomainListInput(from: parsed)
                ),
                json: parsed.wantsJSON
            )
        case ["alternative-distribution", "domains", "view"], ["alternative-distribution", "domains", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getAlternativeDistributionDomain(
                    alternativeDistributionDomainViewInput(from: parsed)
                ),
                json: parsed.wantsJSON
            )
        case ["alternative-distribution", "keys", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listAlternativeDistributionKeys(
                    try alternativeDistributionKeyListInput(from: parsed)
                ),
                json: parsed.wantsJSON
            )
        case ["alternative-distribution", "keys", "view"], ["alternative-distribution", "keys", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getAlternativeDistributionKey(
                    alternativeDistributionKeyViewInput(from: parsed)
                ),
                json: parsed.wantsJSON
            )
        case ["marketplace", "webhooks", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listMarketplaceWebhooks(
                    marketplaceWebhookListInput(from: parsed)
                ),
                json: parsed.wantsJSON
            )
        case ["webhooks", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listWebhooks(webhookListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["webhooks", "view"], ["webhooks", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getWebhook(webhookViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["webhooks", "create"]:
            let input = try webhookCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateWebhook(input)
            ) { commands in
                try await commands.createWebhook(input)
            }
        case ["webhooks", "update"]:
            let input = try webhookUpdateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateWebhook(input)
            ) { commands in
                try await commands.updateWebhook(input)
            }
        case ["webhooks", "delete"], ["webhooks", "remove"]:
            let input = try webhookDeleteInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeleteWebhook(input)
            ) { commands in
                try await commands.deleteWebhook(input)
            }
        case ["webhooks", "deliveries"], ["webhooks", "deliveries", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listWebhookDeliveries(webhookDeliveryListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["webhooks", "deliveries", "links"], ["webhooks", "deliveries", "relationships"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listWebhookDeliveryLinkages(webhookDeliveryLinkageListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["webhooks", "deliveries", "redeliver"], ["webhooks", "deliveries", "retry"]:
            let input = try webhookDeliveryRedeliverInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planRedeliverWebhookDelivery(input)
            ) { commands in
                try await commands.redeliverWebhookDelivery(input)
            }
        case ["webhooks", "ping"]:
            let input = try webhookPingInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planPingWebhook(input)
            ) { commands in
                try await commands.pingWebhook(input)
            }
        case ["eula", "view"], ["eula", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getEULA(eulaViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["eula", "create"]:
            let input = try eulaCreateInput(from: parsed, currentDirectory: currentDirectory)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateEULA(input)
            ) { commands in
                try await commands.createEULA(input)
            }
        case ["eula", "update"], ["eula", "edit"]:
            let input = try eulaUpdateInput(from: parsed, currentDirectory: currentDirectory)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateEULA(input)
            ) { commands in
                try await commands.updateEULA(input)
            }
        case ["eula", "delete"], ["eula", "remove"]:
            let input = try eulaDeleteInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeleteEULA(input)
            ) { commands in
                try await commands.deleteEULA(input)
            }
        case ["territories", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listTerritories(territoryListInput(from: parsed)),
                json: parsed.wantsJSON
            )
#endif
#if ASC_PUBLIC_API_CLOUD
        case ["xcode-cloud", "products", "list"], ["xcodecloud", "products", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listXcodeCloudProducts(xcodeCloudProductListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["xcode-cloud", "products", "view"], ["xcode-cloud", "products", "get"],
            ["xcodecloud", "products", "view"], ["xcodecloud", "products", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getXcodeCloudProduct(xcodeCloudProductViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["xcode-cloud", "workflows", "list"], ["xcodecloud", "workflows", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listXcodeCloudWorkflows(xcodeCloudWorkflowListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["xcode-cloud", "workflows", "view"], ["xcode-cloud", "workflows", "get"],
            ["xcodecloud", "workflows", "view"], ["xcodecloud", "workflows", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getXcodeCloudWorkflow(xcodeCloudWorkflowViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["xcode-cloud", "runs", "list"], ["xcode-cloud", "build-runs", "list"],
            ["xcodecloud", "runs", "list"], ["xcodecloud", "build-runs", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listXcodeCloudBuildRuns(xcodeCloudBuildRunListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["xcode-cloud", "runs", "view"], ["xcode-cloud", "runs", "get"],
            ["xcode-cloud", "build-runs", "view"], ["xcode-cloud", "build-runs", "get"],
            ["xcodecloud", "runs", "view"], ["xcodecloud", "runs", "get"],
            ["xcodecloud", "build-runs", "view"], ["xcodecloud", "build-runs", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getXcodeCloudBuildRun(xcodeCloudBuildRunViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["xcode-cloud", "actions", "list"], ["xcodecloud", "actions", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listXcodeCloudBuildActions(xcodeCloudBuildActionListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["xcode-cloud", "actions", "view"], ["xcode-cloud", "actions", "get"],
            ["xcodecloud", "actions", "view"], ["xcodecloud", "actions", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getXcodeCloudBuildAction(xcodeCloudBuildActionViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["xcode-cloud", "artifacts", "list"], ["xcodecloud", "artifacts", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listXcodeCloudArtifacts(xcodeCloudArtifactListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["xcode-cloud", "artifacts", "view"], ["xcode-cloud", "artifacts", "get"],
            ["xcodecloud", "artifacts", "view"], ["xcodecloud", "artifacts", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getXcodeCloudArtifact(xcodeCloudArtifactViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["xcode-cloud", "logs", "list"], ["xcodecloud", "logs", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listXcodeCloudArtifacts(xcodeCloudLogListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["xcode-cloud", "logs", "view"], ["xcode-cloud", "logs", "get"],
            ["xcodecloud", "logs", "view"], ["xcodecloud", "logs", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getXcodeCloudArtifact(xcodeCloudArtifactViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
#endif
        case ["builds", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listBuilds(buildListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["builds", "info"], ["builds", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getBuild(buildInfoInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["builds", "wait"]:
            let commands = try publicReadCommands(environment: environment)
            let result = try await commands.waitForBuild(buildWaitInput(from: parsed))
            return try render(
                result,
                json: parsed.wantsJSON,
                exitCode: buildWaitExitCode(result)
            )
        case ["builds", "beta-details", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listBuildBetaDetails(buildBetaDetailListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["builds", "beta-details", "view"], ["builds", "beta-details", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getBuildBetaDetail(buildBetaDetailViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["prerelease", "list"], ["builds", "prerelease", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listPreReleaseVersions(preReleaseVersionListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["prerelease", "view"], ["prerelease", "get"], ["builds", "prerelease", "view"], ["builds", "prerelease", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getPreReleaseVersion(preReleaseVersionViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["versions", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listAppStoreVersions(appStoreVersionListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["versions", "view"], ["versions", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getAppStoreVersion(appStoreVersionViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["versions", "create"]:
            let input = try appStoreVersionCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateAppStoreVersion(input)
            ) { commands in
                try await commands.createAppStoreVersion(input)
            }
        case ["versions", "update"]:
            let input = try appStoreVersionUpdateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateAppStoreVersion(input)
            ) { commands in
                try await commands.updateAppStoreVersion(input)
            }
        case ["versions", "delete"]:
            let input = try appStoreVersionDeleteInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeleteAppStoreVersion(input)
            ) { commands in
                try await commands.deleteAppStoreVersion(input)
            }
        case ["versions", "release"], ["release", "request"], ["release", "submit"]:
            let input = try appStoreVersionReleaseRequestCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateAppStoreVersionReleaseRequest(input)
            ) { commands in
                try await commands.createAppStoreVersionReleaseRequest(input)
            }
        case ["testflight", "builds", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listBuilds(buildListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "builds", "info"], ["testflight", "builds", "view"], ["testflight", "builds", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getBuild(buildInfoInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "builds", "wait"]:
            let commands = try publicReadCommands(environment: environment)
            let result = try await commands.waitForBuild(buildWaitInput(from: parsed))
            return try render(
                result,
                json: parsed.wantsJSON,
                exitCode: buildWaitExitCode(result)
            )
        case ["testflight", "builds", "beta-details", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listBuildBetaDetails(buildBetaDetailListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "builds", "beta-details", "view"], ["testflight", "builds", "beta-details", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getBuildBetaDetail(buildBetaDetailViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "builds", "localizations", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listBetaBuildLocalizations(betaBuildLocalizationListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "builds", "localizations", "view"], ["testflight", "builds", "localizations", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getBetaBuildLocalization(betaBuildLocalizationViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "builds", "review-submissions", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listBetaAppReviewSubmissions(betaAppReviewSubmissionListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "builds", "review-submissions", "view"], ["testflight", "builds", "review-submissions", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getBetaAppReviewSubmission(betaAppReviewSubmissionViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "groups", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listBetaGroups(betaGroupListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "groups", "view"], ["testflight", "groups", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getBetaGroup(betaGroupViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "testers", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listBetaTesters(betaTesterListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "testers", "view"], ["testflight", "testers", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getBetaTester(betaTesterViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "app-localizations", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listBetaAppLocalizations(betaAppLocalizationListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "app-localizations", "view"], ["testflight", "app-localizations", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getBetaAppLocalization(betaAppLocalizationViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "build-localizations", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listBetaBuildLocalizations(betaBuildLocalizationListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "build-localizations", "view"], ["testflight", "build-localizations", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getBetaBuildLocalization(betaBuildLocalizationViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "review-details", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listBetaAppReviewDetails(betaAppReviewDetailListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "review-details", "view"], ["testflight", "review-details", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getBetaAppReviewDetail(betaAppReviewDetailViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "review-submissions", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listBetaAppReviewSubmissions(betaAppReviewSubmissionListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "review-submissions", "view"], ["testflight", "review-submissions", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getBetaAppReviewSubmission(betaAppReviewSubmissionViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "license-agreements", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listBetaLicenseAgreements(betaLicenseAgreementListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "license-agreements", "view"], ["testflight", "license-agreements", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getBetaLicenseAgreement(betaLicenseAgreementViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "feedback", "list"], ["testflight", "feedback", "screenshots", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listBetaFeedbackScreenshotSubmissions(betaFeedbackScreenshotSubmissionListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "feedback", "view"], ["testflight", "feedback", "get"], ["testflight", "feedback", "screenshots", "view"], ["testflight", "feedback", "screenshots", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getBetaFeedbackScreenshotSubmission(betaFeedbackScreenshotSubmissionViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "crashes", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listBetaFeedbackCrashSubmissions(betaFeedbackCrashSubmissionListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "crashes", "view"], ["testflight", "crashes", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getBetaFeedbackCrashSubmission(betaFeedbackCrashSubmissionViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "crashes", "log"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getCrashLogForBetaFeedbackCrashSubmission(betaFeedbackCrashSubmissionCrashLogInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "crash-logs", "view"], ["testflight", "crash-logs", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getBetaCrashLog(betaCrashLogViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "metrics", "beta-tester-usages"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await betaTesterUsageMetricsResult(parsed: parsed, commands: commands),
                json: parsed.wantsJSON
            )
        case ["testflight", "groups", "metrics", "beta-tester-usages"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getBetaGroupBetaTesterUsageMetrics(betaGroupBetaTesterUsageMetricsInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "testers", "metrics", "beta-tester-usages"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getBetaTesterUsageMetrics(betaTesterUsageMetricsInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "metrics", "public-link-usages"], ["testflight", "groups", "metrics", "public-link-usages"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getBetaGroupPublicLinkUsageMetrics(betaGroupPublicLinkUsageMetricsInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "metrics", "beta-build-usages"], ["testflight", "builds", "metrics", "beta-build-usages"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getBetaBuildUsageMetrics(betaBuildUsageMetricsInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["testflight", "groups", "create"]:
            let input = try betaGroupCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateBetaGroup(input)
            ) { commands in
                try await commands.createBetaGroup(input)
            }
        case ["testflight", "groups", "update"]:
            let input = try betaGroupUpdateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateBetaGroup(input)
            ) { commands in
                try await commands.updateBetaGroup(input)
            }
        case ["testflight", "groups", "delete"]:
            let input = try betaGroupDeleteInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeleteBetaGroup(input)
            ) { commands in
                try await commands.deleteBetaGroup(input)
            }
        case ["testflight", "testers", "create"]:
            let input = try betaTesterCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateBetaTester(input)
            ) { commands in
                try await commands.createBetaTester(input)
            }
        case ["testflight", "testers", "delete"]:
            let input = try betaTesterDeleteInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeleteBetaTester(input)
            ) { commands in
                try await commands.deleteBetaTester(input)
            }
        case ["testflight", "review-details", "update"]:
            let input = try betaAppReviewDetailUpdateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateBetaAppReviewDetail(input)
            ) { commands in
                try await commands.updateBetaAppReviewDetail(input)
            }
        case ["testflight", "review-submissions", "create"], ["testflight", "review-submissions", "submit"]:
            let input = try betaAppReviewSubmissionCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateBetaAppReviewSubmission(input)
            ) { commands in
                try await commands.createBetaAppReviewSubmission(input)
            }
        case ["testflight", "invitations", "create"], ["testflight", "tester-invitations", "create"]:
            let input = try betaTesterInvitationCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateBetaTesterInvitation(input)
            ) { commands in
                try await commands.createBetaTesterInvitation(input)
            }
        case ["bundle-ids", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listBundleIDs(bundleIDListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["bundle-ids", "view"], ["bundle-ids", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getBundleID(bundleIDViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["bundle-ids", "create"]:
            let input = try bundleIDCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateBundleID(input)
            ) { commands in
                try await commands.createBundleID(input)
            }
        case ["bundle-ids", "update"]:
            let input = try bundleIDUpdateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateBundleID(input)
            ) { commands in
                try await commands.updateBundleID(input)
            }
        case ["bundle-ids", "delete"]:
            let input = try bundleIDDeleteInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeleteBundleID(input)
            ) { commands in
                try await commands.deleteBundleID(input)
            }
        case ["bundle-ids", "capabilities", "list"], ["bundle-ids", "capability", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listBundleIDCapabilities(bundleIDCapabilityListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["bundle-ids", "capabilities", "enable"], ["bundle-ids", "capabilities", "create"],
             ["bundle-ids", "capability", "enable"], ["bundle-ids", "capability", "create"]:
            let input = try bundleIDCapabilityCreateInput(from: parsed, currentDirectory: currentDirectory)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateBundleIDCapability(input)
            ) { commands in
                try await commands.createBundleIDCapability(input)
            }
        case ["bundle-ids", "capabilities", "update"], ["bundle-ids", "capability", "update"]:
            let input = try bundleIDCapabilityUpdateInput(from: parsed, currentDirectory: currentDirectory)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateBundleIDCapability(input)
            ) { commands in
                try await commands.updateBundleIDCapability(input)
            }
        case ["bundle-ids", "capabilities", "disable"], ["bundle-ids", "capabilities", "delete"],
             ["bundle-ids", "capability", "disable"], ["bundle-ids", "capability", "delete"]:
            let input = try bundleIDCapabilityDeleteInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeleteBundleIDCapability(input)
            ) { commands in
                try await commands.deleteBundleIDCapability(input)
            }
        case ["certificates", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listCertificates(certificateListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["certificates", "view"], ["certificates", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getCertificate(certificateViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["certificates", "download"], ["certificates", "export"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.downloadCertificate(certificateDownloadInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["certificates", "create"]:
            let input = try certificateCreateInput(from: parsed, currentDirectory: currentDirectory)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateCertificate(input)
            ) { commands in
                try await commands.createCertificate(input)
            }
        case ["certificates", "update"]:
            let input = try certificateUpdateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateCertificate(input)
            ) { commands in
                try await commands.updateCertificate(input)
            }
        case ["certificates", "delete"], ["certificates", "revoke"]:
            let input = try certificateDeleteInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeleteCertificate(input)
            ) { commands in
                try await commands.deleteCertificate(input)
            }
        case ["devices", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listDevices(deviceListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["devices", "view"], ["devices", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getDevice(deviceViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["devices", "register"], ["devices", "create"]:
            let input = try deviceCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateDevice(input)
            ) { commands in
                try await commands.createDevice(input)
            }
        case ["devices", "update"]:
            let input = try deviceUpdateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateDevice(input)
            ) { commands in
                try await commands.updateDevice(input)
            }
        case ["devices", "enable"]:
            let input = try deviceStatusInput(from: parsed, status: "ENABLED")
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateDevice(input)
            ) { commands in
                try await commands.updateDevice(input)
            }
        case ["devices", "disable"]:
            let input = try deviceStatusInput(from: parsed, status: "DISABLED")
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateDevice(input)
            ) { commands in
                try await commands.updateDevice(input)
            }
        case ["profiles", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listProfiles(profileListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["profiles", "view"], ["profiles", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getProfile(profileViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["profiles", "download"], ["profiles", "export"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.downloadProfile(profileDownloadInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["profiles", "create"]:
            let input = try profileCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateProfile(input)
            ) { commands in
                try await commands.createProfile(input)
            }
        case ["profiles", "delete"]:
            let input = try profileDeleteInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeleteProfile(input)
            ) { commands in
                try await commands.deleteProfile(input)
            }
        case ["users", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listUsers(userListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["users", "view"], ["users", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getUser(userViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
#if ASC_PUBLIC_API_SIGNING_ACCESS
        case ["actors", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listActors(actorListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["actors", "view"], ["actors", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getActor(actorViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
#endif
        case ["users", "update"], ["users", "roles", "update"], ["users", "visibility", "update"]:
            let input = try userUpdateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateUser(input)
            ) { commands in
                try await commands.updateUser(input)
            }
        case ["users", "delete"], ["users", "remove"]:
            let input = try userDeleteInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeleteUser(input)
            ) { commands in
                try await commands.deleteUser(input)
            }
        case ["users", "invite"], ["users", "invitations", "create"]:
            let input = try userInvitationCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateUserInvitation(input)
            ) { commands in
                try await commands.createUserInvitation(input)
            }
        case ["users", "invitations", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listUserInvitations(userInvitationListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["users", "invitations", "view"], ["users", "invitations", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getUserInvitation(userInvitationViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["users", "invitations", "delete"], ["users", "invitations", "cancel"]:
            let input = try userInvitationDeleteInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeleteUserInvitation(input)
            ) { commands in
                try await commands.deleteUserInvitation(input)
            }
#if ASC_PUBLIC_API_COMMERCE
        case ["iap", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listInAppPurchases(iapListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["iap", "view"], ["iap", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getInAppPurchase(iapViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["iap", "create"]:
            let input = try iapCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateInAppPurchase(input)
            ) { commands in
                try await commands.createInAppPurchase(input)
            }
        case ["iap", "update"]:
            let input = try iapUpdateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateInAppPurchase(input)
            ) { commands in
                try await commands.updateInAppPurchase(input)
            }
        case ["iap", "delete"]:
            let input = try iapDeleteInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeleteInAppPurchase(input)
            ) { commands in
                try await commands.deleteInAppPurchase(input)
            }
        case ["iap", "submit"]:
            let input = try iapSubmitInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planSubmitInAppPurchase(input)
            ) { commands in
                try await commands.submitInAppPurchase(input)
            }
        case ["iap", "localizations", "list"], ["iap", "localization", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listInAppPurchaseLocalizations(iapLocalizationListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["iap", "localizations", "view"], ["iap", "localizations", "get"],
             ["iap", "localization", "view"], ["iap", "localization", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getInAppPurchaseLocalization(localizationViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["iap", "localizations", "create"], ["iap", "localization", "create"]:
            let input = try iapLocalizationCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateInAppPurchaseLocalization(input)
            ) { commands in
                try await commands.createInAppPurchaseLocalization(input)
            }
        case ["iap", "localizations", "update"], ["iap", "localization", "update"]:
            let input = try iapLocalizationUpdateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateInAppPurchaseLocalization(input)
            ) { commands in
                try await commands.updateInAppPurchaseLocalization(input)
            }
        case ["iap", "localizations", "delete"], ["iap", "localization", "delete"]:
            let input = try localizationDeleteInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeleteInAppPurchaseLocalization(input)
            ) { commands in
                try await commands.deleteInAppPurchaseLocalization(input)
            }
        case ["promoted-purchases", "list"], ["promotedpurchases", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listPromotedPurchases(promotedPurchaseListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["promoted-purchases", "view"], ["promoted-purchases", "get"],
             ["promotedpurchases", "view"], ["promotedpurchases", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getPromotedPurchase(promotedPurchaseViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["promoted-purchases", "create"], ["promotedpurchases", "create"]:
            let input = try promotedPurchaseCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreatePromotedPurchase(input)
            ) { commands in
                try await commands.createPromotedPurchase(input)
            }
        case ["promoted-purchases", "update"], ["promotedpurchases", "update"]:
            let input = try promotedPurchaseUpdateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdatePromotedPurchase(input)
            ) { commands in
                try await commands.updatePromotedPurchase(input)
            }
        case ["promoted-purchases", "delete"], ["promotedpurchases", "delete"]:
            let input = try promotedPurchaseDeleteInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeletePromotedPurchase(input)
            ) { commands in
                try await commands.deletePromotedPurchase(input)
            }
        case ["subscription-groups", "view"], ["subscription-groups", "get"], ["subscriptions", "groups", "view"], ["subscriptions", "groups", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getSubscriptionGroup(subscriptionGroupViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["subscription-groups", "create"], ["subscriptions", "groups", "create"]:
            let input = try subscriptionGroupCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateSubscriptionGroup(input)
            ) { commands in
                try await commands.createSubscriptionGroup(input)
            }
        case ["subscription-groups", "update"], ["subscriptions", "groups", "update"]:
            let input = try subscriptionGroupUpdateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateSubscriptionGroup(input)
            ) { commands in
                try await commands.updateSubscriptionGroup(input)
            }
        case ["subscription-groups", "delete"], ["subscriptions", "groups", "delete"]:
            let input = try subscriptionGroupDeleteInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeleteSubscriptionGroup(input)
            ) { commands in
                try await commands.deleteSubscriptionGroup(input)
            }
        case ["subscription-groups", "localizations", "list"], ["subscriptions", "groups", "localizations", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listSubscriptionGroupLocalizations(subscriptionGroupLocalizationListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["subscription-groups", "localizations", "view"], ["subscription-groups", "localizations", "get"],
             ["subscriptions", "groups", "localizations", "view"], ["subscriptions", "groups", "localizations", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getSubscriptionGroupLocalization(.init(id: try localizationID(from: parsed))),
                json: parsed.wantsJSON
            )
        case ["subscription-groups", "localizations", "create"], ["subscriptions", "groups", "localizations", "create"]:
            let input = try subscriptionGroupLocalizationCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateSubscriptionGroupLocalization(input)
            ) { commands in
                try await commands.createSubscriptionGroupLocalization(input)
            }
        case ["subscription-groups", "localizations", "update"], ["subscriptions", "groups", "localizations", "update"]:
            let input = try subscriptionGroupLocalizationUpdateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateSubscriptionGroupLocalization(input)
            ) { commands in
                try await commands.updateSubscriptionGroupLocalization(input)
            }
        case ["subscription-groups", "localizations", "delete"], ["subscriptions", "groups", "localizations", "delete"]:
            let input = AppStoreConnectSubscriptionGroupLocalizationDeleteInput(id: try localizationID(from: parsed))
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeleteSubscriptionGroupLocalization(input)
            ) { commands in
                try await commands.deleteSubscriptionGroupLocalization(input)
            }
        case ["subscriptions", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listSubscriptions(subscriptionListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["subscriptions", "view"], ["subscriptions", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getSubscription(subscriptionViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["subscriptions", "create"]:
            let input = try subscriptionCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateSubscription(input)
            ) { commands in
                try await commands.createSubscription(input)
            }
        case ["subscriptions", "update"]:
            let input = try subscriptionUpdateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateSubscription(input)
            ) { commands in
                try await commands.updateSubscription(input)
            }
        case ["subscriptions", "delete"]:
            let input = try subscriptionDeleteInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeleteSubscription(input)
            ) { commands in
                try await commands.deleteSubscription(input)
            }
        case ["subscriptions", "submit"]:
            let input = try subscriptionSubmitInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planSubmitSubscription(input)
            ) { commands in
                try await commands.submitSubscription(input)
            }
        case ["subscriptions", "localizations", "list"], ["subscriptions", "localization", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listSubscriptionLocalizations(subscriptionLocalizationListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["subscriptions", "localizations", "view"], ["subscriptions", "localizations", "get"],
             ["subscriptions", "localization", "view"], ["subscriptions", "localization", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getSubscriptionLocalization(.init(id: try localizationID(from: parsed))),
                json: parsed.wantsJSON
            )
        case ["subscriptions", "localizations", "create"], ["subscriptions", "localization", "create"]:
            let input = try subscriptionLocalizationCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateSubscriptionLocalization(input)
            ) { commands in
                try await commands.createSubscriptionLocalization(input)
            }
        case ["subscriptions", "localizations", "update"], ["subscriptions", "localization", "update"]:
            let input = try subscriptionLocalizationUpdateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateSubscriptionLocalization(input)
            ) { commands in
                try await commands.updateSubscriptionLocalization(input)
            }
        case ["subscriptions", "localizations", "delete"], ["subscriptions", "localization", "delete"]:
            let input = AppStoreConnectSubscriptionLocalizationDeleteInput(id: try localizationID(from: parsed))
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeleteSubscriptionLocalization(input)
            ) { commands in
                try await commands.deleteSubscriptionLocalization(input)
            }
        case ["win-back-offers", "list"], ["winbackoffers", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listWinBackOffers(winBackOfferListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["win-back-offers", "view"], ["win-back-offers", "get"],
             ["winbackoffers", "view"], ["winbackoffers", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getWinBackOffer(winBackOfferViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["win-back-offers", "create"], ["winbackoffers", "create"]:
            let input = try winBackOfferCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateWinBackOffer(input)
            ) { commands in
                try await commands.createWinBackOffer(input)
            }
        case ["win-back-offers", "update"], ["winbackoffers", "update"]:
            let input = try winBackOfferUpdateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateWinBackOffer(input)
            ) { commands in
                try await commands.updateWinBackOffer(input)
            }
        case ["win-back-offers", "delete"], ["winbackoffers", "delete"]:
            let input = try winBackOfferDeleteInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeleteWinBackOffer(input)
            ) { commands in
                try await commands.deleteWinBackOffer(input)
            }
        case ["pricing", "tiers"], ["pricing", "tiers", "list"], ["pricing", "price-points"], ["pricing", "price-points", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listAppPricePoints(appPricePointListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["pricing", "current"], ["pricing", "schedule"], ["pricing", "schedule", "current"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getCurrentAppPriceSchedule(appPriceScheduleCurrentInput(from: parsed)),
                json: parsed.wantsJSON
            )
#endif
        case ["analytics", "reports", "view"], ["analytics", "reports", "get"], ["analytics", "report", "view"], ["analytics", "report", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getAnalyticsReport(analyticsReportViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["analytics", "request", "create"], ["analytics", "requests", "create"]:
            let input = try analyticsReportRequestCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateAnalyticsReportRequest(input)
            ) { commands in
                try await commands.createAnalyticsReportRequest(input)
            }
        case ["analytics", "request", "view"], ["analytics", "request", "get"], ["analytics", "requests", "view"], ["analytics", "requests", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getAnalyticsReportRequest(analyticsReportRequestViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["analytics", "request", "delete"], ["analytics", "requests", "delete"], ["analytics", "delete"]:
            let input = try analyticsReportRequestDeleteInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeleteAnalyticsReportRequest(input)
            ) { commands in
                try await commands.deleteAnalyticsReportRequest(input)
            }
        case ["analytics", "segments", "view"], ["analytics", "segments", "get"], ["analytics", "segment", "view"], ["analytics", "segment", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getAnalyticsReportSegment(analyticsReportSegmentViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["analytics", "instances", "view"], ["analytics", "instances", "get"], ["analytics", "instance", "view"], ["analytics", "instance", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getAnalyticsReportInstance(analyticsReportInstanceViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["finance", "reports"], ["finance", "download"], ["reports", "finance"], ["reports", "finance", "download"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.downloadFinanceReport(financeReportDownloadInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["reports", "sales"], ["reports", "sales", "download"], ["sales", "reports"], ["sales", "download"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.downloadSalesReport(salesReportDownloadInput(from: parsed)),
                json: parsed.wantsJSON
            )
#if ASC_PUBLIC_API_REPORTS
        case ["performance", "list"], ["performance", "metrics"], ["performance", "metrics", "list"], ["insights", "performance"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getPerformanceMetrics(performanceMetricsInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["performance", "download"], ["performance", "metrics", "download"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.downloadPerformanceMetrics(performanceMetricsInput(from: parsed)),
                json: parsed.wantsJSON
            )
#endif
#if ASC_PUBLIC_API_RELEASE
        case ["reviews", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listCustomerReviews(try customerReviewListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["reviews", "view"], ["reviews", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getCustomerReview(try customerReviewViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["reviews", "ratings"], ["reviews", "ratings", "list"], ["reviews", "summaries"], ["reviews", "summaries", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listCustomerReviewSummarizations(try customerReviewSummarizationListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["reviews", "response", "view"], ["reviews", "response", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getCustomerReviewResponseForReview(try customerReviewResponseForReviewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["reviews", "responses", "view"], ["reviews", "responses", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getCustomerReviewResponse(try customerReviewResponseViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["reviews", "responses", "create"], ["reviews", "reply"]:
            let input = try customerReviewResponseCreateInput(from: parsed, currentDirectory: currentDirectory)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateCustomerReviewResponse(input)
            ) { commands in
                try await commands.createCustomerReviewResponse(input)
            }
        case ["reviews", "responses", "delete"], ["reviews", "responses", "remove"]:
            let input = try customerReviewResponseDeleteInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeleteCustomerReviewResponse(input)
            ) { commands in
                try await commands.deleteCustomerReviewResponse(input)
            }
#endif
        case ["review", "submissions", "list"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.listReviewSubmissions(reviewSubmissionListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["review", "submissions", "view"], ["review", "submissions", "get"]:
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getReviewSubmission(reviewSubmissionViewInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["review", "submissions", "create"], ["submit", "create"]:
            let input = try reviewSubmissionCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateReviewSubmission(input)
            ) { commands in
                try await commands.createReviewSubmission(input)
            }
        case ["review", "submissions", "update"]:
            let input = try reviewSubmissionUpdateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateReviewSubmission(input)
            ) { commands in
                try await commands.updateReviewSubmission(input)
            }
        case ["review", "submissions", "submit"], ["review", "submit"]:
            let input = try reviewSubmissionSubmitInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateReviewSubmission(input)
            ) { commands in
                try await commands.updateReviewSubmission(input)
            }
        case ["review", "submissions", "cancel"], ["submit", "cancel"]:
            let input = try reviewSubmissionCancelInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateReviewSubmission(input)
            ) { commands in
                try await commands.updateReviewSubmission(input)
            }
        case ["review", "items", "create"], ["review", "submission-items", "create"], ["versions", "submit"]:
            let input = try reviewSubmissionItemCreateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planCreateReviewSubmissionItem(input)
            ) { commands in
                try await commands.createReviewSubmissionItem(input)
            }
        case ["review", "items", "update"], ["review", "submission-items", "update"]:
            let input = try reviewSubmissionItemUpdateInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planUpdateReviewSubmissionItem(input)
            ) { commands in
                try await commands.updateReviewSubmissionItem(input)
            }
        case ["review", "items", "delete"], ["review", "submission-items", "delete"]:
            let input = try reviewSubmissionItemDeleteInput(from: parsed)
            return try await renderWriteCommand(
                parsed: parsed,
                environment: environment,
                plan: PublicAPIWriteCommands.planDeleteReviewSubmissionItem(input)
            ) { commands in
                try await commands.deleteReviewSubmissionItem(input)
            }
        case ["submit", "status"], ["review", "status"]:
            let commands = try publicReadCommands(environment: environment)
            if let id = parsed.firstOption(["id", "review-submission-id", "submission-id"]) {
                return try render(
                    try await commands.getReviewSubmission(.init(id: id)),
                    json: parsed.wantsJSON
                )
            }
            return try render(
                try await commands.listReviewSubmissions(reviewSubmissionListInput(from: parsed)),
                json: parsed.wantsJSON
            )
        case ["status"]:
            let input = try statusInput(from: parsed)
            let commands = try publicReadCommands(environment: environment)
            return try render(
                try await commands.getStatus(input),
                json: parsed.wantsJSON
            )
        case ["validate"]:
            let input = try publicReleaseReadinessInput(from: parsed)
            if parsed.hasFlag("dry-run") {
                return try render(PublicReleaseReadinessWorkflow.dryRun(input), json: parsed.wantsJSON)
            }
            let workflow = try WorkflowRuntime.publicReleaseReadinessWorkflow(
                configuration: WorkflowRuntimeConfiguration(environment: environment)
            )
            return try render(await workflow.run(input), json: parsed.wantsJSON)
        case ["schema"], ["schema", "info"]:
            return try render(schemaInfo(currentDirectory: currentDirectory), json: parsed.wantsJSON)
        case ["schema", "path"]:
            return try render(schemaPathInfo(currentDirectory: currentDirectory), json: parsed.wantsJSON)
        case ["completion"], ["completion", "zsh"], ["completion", "bash"], ["completion", "fish"]:
            let shell = try completionShell(from: parsed)
            return AppStoreConnectCLIResult(exitCode: 0, stdout: completionScript(for: shell))
        default:
            if let descriptor = AppStoreConnectCLICommandRegistry.descriptor(for: parsed.commands) {
                return try renderUnsupportedCommand(
                    requestedCommand: parsed.commands.joined(separator: " "),
                    descriptor: descriptor,
                    json: parsed.wantsJSON
                )
            }
            throw CLIError(exitCode: 64, message: "Unknown command: \(parsed.commands.joined(separator: " "))")
        }
    }

    private static func publicReadCommands(
        environment: [String: String]
    ) throws -> PublicAPIReadCommands {
        try WorkflowRuntime.publicReadCommands(
            configuration: WorkflowRuntimeConfiguration(environment: environment)
        )
    }

    private static func publicWriteCommands(
        environment: [String: String]
    ) throws -> PublicAPIWriteCommands {
        try WorkflowRuntime.publicWriteCommands(
            configuration: WorkflowRuntimeConfiguration(environment: environment)
        )
    }

    private static func authStatusInput(
        from parsed: ParsedArguments,
        environment: [String: String],
        currentDirectory: URL
    ) -> AppStoreConnectAuthStatusInput {
        let explicitSessionFile = parsed.firstOption(["session-file", "web-session-file"])
        let environmentSessionFile = environment["ASC_WEB_SESSION_FILE"].flatMap { $0.isEmpty ? nil : $0 }
        let sessionFilePath = explicitSessionFile
            ?? environmentSessionFile
            ?? defaultWebSessionFilePath(environment: environment)
        let browserCookieFilePath = parsed.firstOption(["browser-cookie-file", "cookies-file"])
            ?? environment["ASC_WEB_SESSION_BROWSER_COOKIE_FILE"].flatMap { $0.isEmpty ? nil : $0 }

        return AppStoreConnectAuthStatusInput(
            sessionFileURL: resolvedFileURL(sessionFilePath, currentDirectory: currentDirectory),
            requireSessionFile: explicitSessionFile != nil || environmentSessionFile != nil,
            browserCookieFileURL: browserCookieFilePath.map { resolvedFileURL($0, currentDirectory: currentDirectory) },
            includeCookieNames: parsed.hasFlag("include-cookie-names")
        )
    }

    private static func authLogoutInput(
        from parsed: ParsedArguments,
        environment: [String: String],
        currentDirectory: URL
    ) -> AppStoreConnectAuthLogoutInput {
        let sessionFilePath = parsed.firstOption(["session-file", "web-session-file"])
            ?? environment["ASC_WEB_SESSION_FILE"].flatMap { $0.isEmpty ? nil : $0 }
            ?? defaultWebSessionFilePath(environment: environment)

        return AppStoreConnectAuthLogoutInput(
            sessionFileURL: resolvedFileURL(sessionFilePath, currentDirectory: currentDirectory)
        )
    }

    private static func xcodeVersionInput(
        from parsed: ParsedArguments,
        environment: [String: String],
        currentDirectory: URL
    ) -> AppStoreConnectXcodeVersionInput {
        AppStoreConnectXcodeVersionInput(
            xcodebuildPath: xcodebuildPath(from: parsed, environment: environment),
            developerDirectoryPath: developerDirectoryPath(from: parsed, environment: environment),
            currentDirectoryPath: currentDirectory.path
        )
    }

    private static func xcodeArchiveInput(
        from parsed: ParsedArguments,
        environment: [String: String],
        currentDirectory: URL
    ) throws -> AppStoreConnectXcodeArchiveInput {
        guard let scheme = parsed.option("scheme") else {
            throw CLIError(exitCode: 64, message: "Missing required option --scheme.")
        }
        guard let archivePath = parsed.firstOption(["archive-path", "archive"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --archive-path.")
        }

        return AppStoreConnectXcodeArchiveInput(
            workspacePath: parsed.option("workspace"),
            projectPath: parsed.option("project"),
            scheme: scheme,
            configuration: parsed.option("configuration"),
            destination: parsed.option("destination"),
            archivePath: archivePath,
            derivedDataPath: parsed.option("derived-data-path"),
            resultBundlePath: parsed.option("result-bundle-path"),
            allowProvisioningUpdates: try boolOption(from: parsed, names: ["allow-provisioning-updates"]) ?? false,
            xcodebuildPath: xcodebuildPath(from: parsed, environment: environment),
            developerDirectoryPath: developerDirectoryPath(from: parsed, environment: environment),
            currentDirectoryPath: currentDirectory.path
        )
    }

    private static func xcodeExportInput(
        from parsed: ParsedArguments,
        environment: [String: String],
        currentDirectory: URL
    ) throws -> AppStoreConnectXcodeExportInput {
        guard let archivePath = parsed.firstOption(["archive-path", "archive"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --archive-path.")
        }
        guard let exportPath = parsed.firstOption(["export-path", "output"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --export-path.")
        }
        guard let exportOptionsPlistPath = parsed.firstOption(["export-options-plist", "options-plist"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --export-options-plist.")
        }

        return AppStoreConnectXcodeExportInput(
            archivePath: archivePath,
            exportPath: exportPath,
            exportOptionsPlistPath: exportOptionsPlistPath,
            xcodebuildPath: xcodebuildPath(from: parsed, environment: environment),
            developerDirectoryPath: developerDirectoryPath(from: parsed, environment: environment),
            currentDirectoryPath: currentDirectory.path
        )
    }

    private static func xcodeUploadInput(
        from parsed: ParsedArguments,
        environment: [String: String],
        currentDirectory: URL
    ) throws -> AppStoreConnectXcodeUploadInput {
        guard let assetPath = parsed.firstOption(["file", "asset", "ipa", "package"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --file.")
        }
        let transportValue = parsed.firstOption(["transport", "upload-transport"])?.lowercased() ?? "transporter"
        let transport: AppStoreConnectUploadTransport
        switch transportValue {
        case "transporter", "itmstransporter", "itms":
            transport = .transporter
        case "altool":
            transport = .altool
        default:
            throw CLIError(exitCode: 64, message: "Invalid --transport value: \(transportValue).")
        }

        return AppStoreConnectXcodeUploadInput(
            assetPath: assetPath,
            apiKeyID: parsed.firstOption(["api-key", "api-key-id", "key-id"]) ?? environment["ASC_API_KEY_ID"],
            apiIssuerID: parsed.firstOption(["api-issuer", "api-issuer-id", "issuer-id"]) ?? environment["ASC_API_ISSUER_ID"],
            toolPath: parsed.firstOption(["tool-path", "upload-tool-path", "transporter-path"])
                ?? environment["ASC_UPLOAD_TOOL_PATH"]
                ?? "xcrun",
            transport: transport,
            currentDirectoryPath: currentDirectory.path
        )
    }

    private static func xcodebuildPath(
        from parsed: ParsedArguments,
        environment: [String: String]
    ) -> String {
        parsed.firstOption(["xcodebuild", "xcodebuild-path"])
            ?? environment["ASC_XCODEBUILD_PATH"]
            ?? "xcodebuild"
    }

    private static func developerDirectoryPath(
        from parsed: ParsedArguments,
        environment: [String: String]
    ) -> String? {
        parsed.firstOption(["developer-dir", "developer-directory"])
            ?? environment["DEVELOPER_DIR"]
    }

    private static func defaultWebSessionFilePath(environment: [String: String]) -> String {
        let home = environment["HOME"].flatMap { $0.isEmpty ? nil : $0 }
            ?? FileManager.default.homeDirectoryForCurrentUser.path
        return "\(home)/.appstoreconnect/web-session.json"
    }

    private static func resolvedFileURL(_ path: String, currentDirectory: URL) -> URL {
        let expanded = NSString(string: path).expandingTildeInPath
        if expanded.hasPrefix("/") {
            return URL(fileURLWithPath: expanded).standardizedFileURL
        }
        return currentDirectory.appendingPathComponent(expanded).standardizedFileURL
    }

    private static func metadataValidationInput(
        from parsed: ParsedArguments,
        currentDirectory: URL
    ) -> AppStoreConnectMetadataValidationInput {
        let path = parsed.option("path") ?? parsed.option("metadata-path") ?? "."
        return AppStoreConnectMetadataValidationInput(
            path: resolvedFileURL(path, currentDirectory: currentDirectory).path
        )
    }

    private static func metadataPlanInput(
        from parsed: ParsedArguments,
        currentDirectory: URL
    ) -> AppStoreConnectMetadataPlanInput {
        let path = parsed.option("path") ?? parsed.option("metadata-path")
        return AppStoreConnectMetadataPlanInput(
            appID: parsed.firstOption(["app", "app-id"]),
            appStoreVersionID: parsed.firstOption(["version-id", "app-store-version-id"]),
            locale: parsed.option("locale"),
            path: path.map { resolvedFileURL($0, currentDirectory: currentDirectory).path }
        )
    }

    private static func metadataKeywordsInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectMetadataPlanInput {
        guard let id = parsed.firstOption(["id", "localization", "localization-id"]) else {
            throw CLIError(exitCode: 64, message: "metadata keywords requires --id <localization-id>.")
        }
        guard let keywords = parsed.option("keywords") else {
            throw CLIError(exitCode: 64, message: "metadata keywords requires --keywords <text>.")
        }
        return AppStoreConnectMetadataPlanInput(localizationID: id, keywords: keywords)
    }

    private static func mediaAssetSetInput(
        from parsed: ParsedArguments,
        defaultIDOption: String
    ) throws -> AppStoreConnectMediaAssetSetViewInput {
        guard let id = parsed.firstOption([defaultIDOption, "set-id", "id"]) else {
            throw CLIError(exitCode: 64, message: "Media asset list requires --\(defaultIDOption) <set-id>.")
        }
        return AppStoreConnectMediaAssetSetViewInput(
            id: id,
            includeAssets: !parsed.hasFlag("no-include-assets"),
            limit: parsed.intOption("limit")
        )
    }

    private static func mediaAssetInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectMediaAssetViewInput {
        guard let id = parsed.option("id") else {
            throw CLIError(exitCode: 64, message: "Media asset view requires --id <asset-id>.")
        }
        return AppStoreConnectMediaAssetViewInput(id: id)
    }

    private static func renderWriteCommand<Result: Encodable>(
        parsed: ParsedArguments,
        environment: [String: String],
        plan: AppStoreConnectPublicAPIMutationPlan,
        execute: (PublicAPIWriteCommands) async throws -> Result
    ) async throws -> AppStoreConnectCLIResult {
        if parsed.hasFlag("confirm") {
            if parsed.hasFlag("dry-run") {
                throw CLIError(exitCode: 64, message: "Use either --dry-run or --confirm, not both.")
            }
            let commands = try publicWriteCommands(environment: environment)
            return try render(try await execute(commands), json: parsed.wantsJSON)
        }

        return try render(plan, json: parsed.wantsJSON)
    }

    private static func renderXcodeToolCommand(
        parsed: ParsedArguments,
        plan: AppStoreConnectXcodeToolPlan,
        execute: (AppStoreConnectXcodeCommands) async throws -> AppStoreConnectXcodeToolRunResult
    ) async throws -> AppStoreConnectCLIResult {
        if parsed.hasFlag("confirm") {
            if parsed.hasFlag("dry-run") {
                throw CLIError(exitCode: 64, message: "Use either --dry-run or --confirm, not both.")
            }
            let result = try await execute(WorkflowRuntime.xcodeCommands())
            return try render(result, json: parsed.wantsJSON, exitCode: result.result.exitCode)
        }

        return try render(plan, json: parsed.wantsJSON)
    }

    private static func appListInput(from parsed: ParsedArguments) -> AppStoreConnectAppListInput {
        AppStoreConnectAppListInput(
            ids: parsed.commaSeparatedOption("id"),
            names: parsed.commaSeparatedOption("name"),
            bundleIDs: parsed.commaSeparatedOption("bundle-id"),
            skus: parsed.commaSeparatedOption("sku"),
            sort: parsed.option("sort"),
            limit: parsed.intOption("limit")
        )
    }

    private static func appViewInput(from parsed: ParsedArguments) throws -> AppStoreConnectAppViewInput {
        guard let id = parsed.firstOption(["id", "app-id", "app"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id.")
        }
        return AppStoreConnectAppViewInput(id: id)
    }

#if ASC_PUBLIC_API_RELEASE
    private static let ageRatingFrequencyOptions: [(field: String, names: [String])] = [
        ("alcoholTobaccoOrDrugUseOrReferences", ["alcohol-tobacco-or-drug-use-or-references", "alcohol-tobacco-drug-use", "alcohol"]),
        ("contests", ["contests"]),
        ("gamblingSimulated", ["gambling-simulated", "simulated-gambling"]),
        ("gunsOrOtherWeapons", ["guns-or-other-weapons", "weapons", "guns"]),
        ("horrorOrFearThemes", ["horror-or-fear-themes", "horror-fear-themes", "horror"]),
        ("matureOrSuggestiveThemes", ["mature-or-suggestive-themes", "mature-suggestive-themes"]),
        ("medicalOrTreatmentInformation", ["medical-or-treatment-information", "medical-treatment-information", "medical"]),
        ("profanityOrCrudeHumor", ["profanity-or-crude-humor", "profanity-crude-humor", "profanity"]),
        ("sexualContentGraphicAndNudity", ["sexual-content-graphic-and-nudity", "graphic-sexual-content-nudity"]),
        ("sexualContentOrNudity", ["sexual-content-or-nudity", "sexual-content-nudity"]),
        ("violenceCartoonOrFantasy", ["violence-cartoon-or-fantasy", "cartoon-fantasy-violence"]),
        ("violenceRealistic", ["violence-realistic", "realistic-violence"]),
        ("violenceRealisticProlongedGraphicOrSadistic", ["violence-realistic-prolonged-graphic-or-sadistic", "prolonged-graphic-sadistic-violence"]),
    ]

    private static let ageRatingBooleanOptions: [(field: String, names: [String])] = [
        ("advertising", ["advertising"]),
        ("ageAssurance", ["age-assurance"]),
        ("gambling", ["gambling"]),
        ("healthOrWellnessTopics", ["health-or-wellness-topics", "health-wellness-topics"]),
        ("lootBox", ["loot-box", "lootbox"]),
        ("messagingAndChat", ["messaging-and-chat", "messaging-chat"]),
        ("parentalControls", ["parental-controls"]),
        ("unrestrictedWebAccess", ["unrestricted-web-access", "web-access"]),
        ("userGeneratedContent", ["user-generated-content", "ugc"]),
    ]

    private static func appCategoryListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppCategoryListInput {
        let existsParent = try boolOption(from: parsed, names: ["exists-parent", "has-parent"])
        if parsed.hasFlag("root-only"), existsParent == true {
            throw CLIError(exitCode: 64, message: "Use either --root-only or --exists-parent true, not both.")
        }

        return AppStoreConnectAppCategoryListInput(
            platforms: parsed.commaSeparatedOption("platform").map { $0.uppercased() },
            existsParent: parsed.hasFlag("root-only") ? false : existsParent,
            includeParent: parsed.hasFlag("include-parent"),
            includeSubcategories: parsed.hasFlag("include-subcategories"),
            limit: parsed.intOption("limit"),
            subcategoriesLimit: parsed.intOption("subcategories-limit")
        )
    }

    private static func appCategoryViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppCategoryViewInput {
        guard let id = parsed.firstOption(["id", "category-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --category-id.")
        }
        return AppStoreConnectAppCategoryViewInput(
            id: id,
            includeParent: parsed.hasFlag("include-parent"),
            includeSubcategories: parsed.hasFlag("include-subcategories"),
            subcategoriesLimit: parsed.intOption("subcategories-limit")
        )
    }

    private static func appCategoryParentInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppCategoryParentInput {
        guard let id = parsed.firstOption(["id", "category-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --category-id.")
        }
        return AppStoreConnectAppCategoryParentInput(
            id: id,
            fields: parsed.commaSeparatedOptions(["field", "fields"])
        )
    }

    private static func appCategorySubcategoriesInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppCategorySubcategoriesInput {
        guard let id = parsed.firstOption(["id", "category-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --category-id.")
        }
        return AppStoreConnectAppCategorySubcategoriesInput(
            id: id,
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            limit: parsed.intOption("limit")
        )
    }

    private static func appCategoryUpdateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppCategoryUpdateInput {
        guard let appInfoID = parsed.firstOption(["app-info-id", "app-info", "id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app-info-id.")
        }
        let input = AppStoreConnectAppCategoryUpdateInput(
            appInfoID: appInfoID,
            primaryCategoryID: parsed.firstOption(["primary-category", "primary-category-id", "primary"]),
            secondaryCategoryID: parsed.firstOption(["secondary-category", "secondary-category-id", "secondary"]),
            primarySubcategoryOneID: parsed.firstOption(["primary-subcategory-one", "primary-subcategory-one-id"]),
            primarySubcategoryTwoID: parsed.firstOption(["primary-subcategory-two", "primary-subcategory-two-id"]),
            secondarySubcategoryOneID: parsed.firstOption(["secondary-subcategory-one", "secondary-subcategory-one-id"]),
            secondarySubcategoryTwoID: parsed.firstOption(["secondary-subcategory-two", "secondary-subcategory-two-id"])
        )
        guard input.primaryCategoryID != nil
            || input.secondaryCategoryID != nil
            || input.primarySubcategoryOneID != nil
            || input.primarySubcategoryTwoID != nil
            || input.secondarySubcategoryOneID != nil
            || input.secondarySubcategoryTwoID != nil
        else {
            throw CLIError(exitCode: 64, message: "Specify at least one category relationship.")
        }
        return input
    }

    private static func ageRatingViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAgeRatingViewInput {
        guard let appInfoID = parsed.firstOption(["app-info-id", "app-info", "id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app-info-id.")
        }
        return AppStoreConnectAgeRatingViewInput(
            appInfoID: appInfoID,
            fields: parsed.commaSeparatedOptions(["field", "fields"])
        )
    }

    private static func ageRatingUpdateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAgeRatingUpdateInput {
        guard let id = parsed.firstOption(["id", "declaration-id", "age-rating-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --declaration-id.")
        }
        var frequencyRatings: [String: String] = [:]
        for option in ageRatingFrequencyOptions {
            if let value = parsed.firstOption(option.names) {
                frequencyRatings[option.field] = normalizedPublicAPIEnum(value)
            }
        }
        var booleanRatings: [String: Bool] = [:]
        for option in ageRatingBooleanOptions {
            if let value = try boolOption(from: parsed, names: option.names) {
                booleanRatings[option.field] = value
            }
        }
        let input = AppStoreConnectAgeRatingUpdateInput(
            id: id,
            frequencyRatings: frequencyRatings,
            booleanRatings: booleanRatings,
            kidsAgeBand: parsed.firstOption(["kids-age-band"]).map(normalizedPublicAPIEnum),
            ageRatingOverrideV2: parsed.firstOption(["age-rating-override-v2", "rating-override-v2", "age-rating-override"]).map(normalizedPublicAPIEnum),
            koreaAgeRatingOverride: parsed.firstOption(["korea-age-rating-override"]).map(normalizedPublicAPIEnum),
            developerAgeRatingInfoURL: parsed.firstOption(["developer-age-rating-info-url", "developer-info-url", "info-url"]),
            allNone: parsed.hasFlag("all-none")
        )
        guard input.allNone
            || !input.frequencyRatings.isEmpty
            || !input.booleanRatings.isEmpty
            || input.kidsAgeBand != nil
            || input.ageRatingOverrideV2 != nil
            || input.koreaAgeRatingOverride != nil
            || input.developerAgeRatingInfoURL != nil
        else {
            throw CLIError(exitCode: 64, message: "Specify at least one age rating update field.")
        }
        return input
    }

    private static func appEventListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppEventListInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        return AppStoreConnectAppEventListInput(
            appID: appID,
            ids: parsed.commaSeparatedOptions(["id", "event-id"]),
            eventStates: parsed.commaSeparatedOptions(["state", "event-state"]).map { $0.uppercased() },
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            localizationFields: parsed.commaSeparatedOptions(["localization-field", "localization-fields"]),
            includeLocalizations: parsed.hasFlag("include-localizations"),
            limit: parsed.intOption("limit"),
            localizationsLimit: parsed.intOption("localizations-limit")
        )
    }

    private static func appEventViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppEventViewInput {
        guard let id = parsed.firstOption(["id", "event-id", "app-event-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --event-id.")
        }
        return AppStoreConnectAppEventViewInput(
            id: id,
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            localizationFields: parsed.commaSeparatedOptions(["localization-field", "localization-fields"]),
            includeLocalizations: parsed.hasFlag("include-localizations"),
            localizationsLimit: parsed.intOption("localizations-limit")
        )
    }

    private static func appEventCreateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppEventCreateInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        guard let referenceName = parsed.firstOption(["reference-name", "name"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --reference-name or --name.")
        }
        return AppStoreConnectAppEventCreateInput(
            appID: appID,
            referenceName: referenceName,
            badge: parsed.option("badge"),
            deepLink: parsed.firstOption(["deep-link", "url"]),
            primaryLocale: parsed.firstOption(["primary-locale", "locale"]),
            priority: parsed.option("priority"),
            purchaseRequirement: parsed.option("purchase-requirement"),
            purpose: parsed.option("purpose")
        )
    }

    private static func appEventUpdateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppEventUpdateInput {
        guard let id = parsed.firstOption(["id", "event-id", "app-event-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --event-id.")
        }
        let input = AppStoreConnectAppEventUpdateInput(
            id: id,
            referenceName: parsed.firstOption(["reference-name", "name"]),
            badge: parsed.option("badge"),
            deepLink: parsed.firstOption(["deep-link", "url"]),
            primaryLocale: parsed.firstOption(["primary-locale", "locale"]),
            priority: parsed.option("priority"),
            purchaseRequirement: parsed.option("purchase-requirement"),
            purpose: parsed.option("purpose")
        )
        guard input.referenceName != nil
            || input.badge != nil
            || input.deepLink != nil
            || input.primaryLocale != nil
            || input.priority != nil
            || input.purchaseRequirement != nil
            || input.purpose != nil
        else {
            throw CLIError(exitCode: 64, message: "Specify at least one app event update field.")
        }
        return input
    }

    private static func appEventDeleteInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppEventDeleteInput {
        guard let id = parsed.firstOption(["id", "event-id", "app-event-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --event-id.")
        }
        return AppStoreConnectAppEventDeleteInput(id: id)
    }
#endif

#if ASC_PUBLIC_API_METADATA_MEDIA
    private static func appClipListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppClipListInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        return AppStoreConnectAppClipListInput(
            appID: appID,
            bundleIDs: parsed.commaSeparatedOptions(["bundle-id", "bundle-ids"]),
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            defaultExperienceFields: parsed.commaSeparatedOptions(["default-experience-field", "default-experience-fields"]),
            includeApp: parsed.hasFlag("include-app"),
            includeDefaultExperiences: parsed.hasFlag("include-default-experiences") || parsed.hasFlag("include-experiences"),
            limit: parsed.intOption("limit"),
            defaultExperiencesLimit: parsed.intOption("default-experiences-limit") ?? parsed.intOption("experiences-limit")
        )
    }

    private static func appClipViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppClipViewInput {
        guard let id = parsed.firstOption(["id", "app-clip-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --app-clip-id.")
        }
        return AppStoreConnectAppClipViewInput(
            id: id,
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            defaultExperienceFields: parsed.commaSeparatedOptions(["default-experience-field", "default-experience-fields"]),
            includeApp: parsed.hasFlag("include-app"),
            includeDefaultExperiences: parsed.hasFlag("include-default-experiences") || parsed.hasFlag("include-experiences"),
            defaultExperiencesLimit: parsed.intOption("default-experiences-limit") ?? parsed.intOption("experiences-limit")
        )
    }

    private static func appClipDefaultExperienceListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppClipDefaultExperienceListInput {
        guard let appClipID = parsed.firstOption(["app-clip", "app-clip-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app-clip or --app-clip-id.")
        }
        return AppStoreConnectAppClipDefaultExperienceListInput(
            appClipID: appClipID,
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            localizationFields: parsed.commaSeparatedOptions(["localization-field", "localization-fields"]),
            includeAppClip: parsed.hasFlag("include-app-clip"),
            includeLocalizations: parsed.hasFlag("include-localizations"),
            includeReviewDetail: parsed.hasFlag("include-review-detail"),
            limit: parsed.intOption("limit"),
            localizationsLimit: parsed.intOption("localizations-limit"),
            hasReleaseWithAppStoreVersion: try boolOption(
                from: parsed,
                names: ["has-release-with-app-store-version", "exists-release-with-app-store-version"]
            )
        )
    }

    private static func appClipDefaultExperienceViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppClipDefaultExperienceViewInput {
        guard let id = parsed.firstOption(["id", "experience-id", "default-experience-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --experience-id.")
        }
        return AppStoreConnectAppClipDefaultExperienceViewInput(
            id: id,
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            localizationFields: parsed.commaSeparatedOptions(["localization-field", "localization-fields"]),
            includeAppClip: parsed.hasFlag("include-app-clip"),
            includeLocalizations: parsed.hasFlag("include-localizations"),
            includeReviewDetail: parsed.hasFlag("include-review-detail"),
            localizationsLimit: parsed.intOption("localizations-limit")
        )
    }

    private static func appClipLocalizationListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppClipLocalizationListInput {
        guard let defaultExperienceID = parsed.firstOption(["default-experience", "default-experience-id", "experience", "experience-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --default-experience or --experience-id.")
        }
        return AppStoreConnectAppClipLocalizationListInput(
            defaultExperienceID: defaultExperienceID,
            locales: parsed.commaSeparatedOptions(["locale", "locales"]),
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            includeDefaultExperience: parsed.hasFlag("include-default-experience"),
            includeHeaderImage: parsed.hasFlag("include-header-image"),
            limit: parsed.intOption("limit")
        )
    }

    private static func appClipLocalizationViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppClipLocalizationViewInput {
        guard let id = parsed.firstOption(["id", "localization-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --localization-id.")
        }
        return AppStoreConnectAppClipLocalizationViewInput(
            id: id,
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            includeDefaultExperience: parsed.hasFlag("include-default-experience"),
            includeHeaderImage: parsed.hasFlag("include-header-image")
        )
    }
#endif

#if ASC_PUBLIC_API_GAME_CENTER
    private static func gameCenterDetailForAppInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectGameCenterDetailForAppInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        return AppStoreConnectGameCenterDetailForAppInput(
            appID: appID,
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            includeApp: parsed.hasFlag("include-app"),
            includeAchievements: parsed.hasFlag("include-achievements"),
            includeLeaderboards: parsed.hasFlag("include-leaderboards"),
            includeLeaderboardSets: parsed.hasFlag("include-leaderboard-sets"),
            includeChallenges: parsed.hasFlag("include-challenges"),
            relatedLimit: parsed.intOption("related-limit")
        )
    }

    private static func gameCenterDetailViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectGameCenterDetailViewInput {
        guard let id = parsed.firstOption(["id", "detail-id", "game-center-detail-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --detail-id.")
        }
        return AppStoreConnectGameCenterDetailViewInput(
            id: id,
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            includeApp: parsed.hasFlag("include-app"),
            includeAchievements: parsed.hasFlag("include-achievements"),
            includeLeaderboards: parsed.hasFlag("include-leaderboards"),
            includeLeaderboardSets: parsed.hasFlag("include-leaderboard-sets"),
            includeChallenges: parsed.hasFlag("include-challenges"),
            relatedLimit: parsed.intOption("related-limit")
        )
    }

    private static func gameCenterNamedResourceListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectGameCenterNamedResourceListInput {
        guard let detailID = parsed.firstOption(["detail", "detail-id", "game-center-detail-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --detail or --detail-id.")
        }
        return AppStoreConnectGameCenterNamedResourceListInput(
            detailID: detailID,
            ids: parsed.commaSeparatedOptions(["id", "ids"]),
            referenceNames: parsed.commaSeparatedOptions(["reference-name", "reference-names", "name"]),
            archived: parsed.firstOption(["archived"]),
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            limit: parsed.intOption("limit")
        )
    }

    private static func gameCenterResourceViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectGameCenterResourceViewInput {
        guard let id = parsed.firstOption(["id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id.")
        }
        return AppStoreConnectGameCenterResourceViewInput(
            id: id,
            fields: parsed.commaSeparatedOptions(["field", "fields"])
        )
    }
#endif

#if ASC_PUBLIC_API_DISTRIBUTION
    private static func alternativeDistributionDomainListInput(
        from parsed: ParsedArguments
    ) -> AppStoreConnectAlternativeDistributionDomainListInput {
        AppStoreConnectAlternativeDistributionDomainListInput(
            fields: parsed.commaSeparatedOption("field"),
            limit: parsed.intOption("limit")
        )
    }

    private static func alternativeDistributionDomainViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAlternativeDistributionDomainViewInput {
        guard let id = parsed.firstOption(["id", "domain-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --domain-id.")
        }
        return AppStoreConnectAlternativeDistributionDomainViewInput(
            id: id,
            fields: parsed.commaSeparatedOption("field")
        )
    }

    private static func alternativeDistributionKeyListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAlternativeDistributionKeyListInput {
        try AppStoreConnectAlternativeDistributionKeyListInput(
            existsApp: boolOption(from: parsed, names: ["exists-app", "has-app"]),
            fields: parsed.commaSeparatedOption("field"),
            limit: parsed.intOption("limit")
        )
    }

    private static func alternativeDistributionKeyViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAlternativeDistributionKeyViewInput {
        guard let id = parsed.firstOption(["id", "key-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --key-id.")
        }
        return AppStoreConnectAlternativeDistributionKeyViewInput(
            id: id,
            fields: parsed.commaSeparatedOption("field")
        )
    }

    private static func marketplaceWebhookListInput(
        from parsed: ParsedArguments
    ) -> AppStoreConnectMarketplaceWebhookListInput {
        AppStoreConnectMarketplaceWebhookListInput(
            fields: parsed.commaSeparatedOption("field"),
            limit: parsed.intOption("limit")
        )
    }

    private static func webhookListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectWebhookListInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        return AppStoreConnectWebhookListInput(
            appID: appID,
            fields: parsed.commaSeparatedOption("field"),
            includeApp: parsed.hasFlag("include-app"),
            limit: parsed.intOption("limit")
        )
    }

    private static func webhookViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectWebhookViewInput {
        guard let id = parsed.firstOption(["id", "webhook-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --webhook-id.")
        }
        return AppStoreConnectWebhookViewInput(
            id: id,
            fields: parsed.commaSeparatedOption("field"),
            includeApp: parsed.hasFlag("include-app")
        )
    }

    private static func webhookDeliveryListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectWebhookDeliveryListInput {
        guard let id = parsed.firstOption(["id", "webhook-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --webhook-id.")
        }
        return AppStoreConnectWebhookDeliveryListInput(
            webhookID: id,
            states: parsed.commaSeparatedOption("state"),
            createdDateGreaterThanOrEqualTo: parsed.commaSeparatedOption("created-after"),
            createdDateLessThan: parsed.commaSeparatedOption("created-before"),
            fields: parsed.commaSeparatedOption("field"),
            eventFields: parsed.commaSeparatedOption("event-field"),
            includeEvent: parsed.hasFlag("include-event"),
            limit: parsed.intOption("limit")
        )
    }

    private static func webhookDeliveryLinkageListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectWebhookDeliveryLinkageListInput {
        guard let id = parsed.firstOption(["id", "webhook-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --webhook-id.")
        }
        return AppStoreConnectWebhookDeliveryLinkageListInput(
            webhookID: id,
            limit: parsed.intOption("limit")
        )
    }

    private static func webhookCreateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectWebhookCreateInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        guard let name = parsed.option("name") else {
            throw CLIError(exitCode: 64, message: "Missing required option --name.")
        }
        guard let url = parsed.option("url") else {
            throw CLIError(exitCode: 64, message: "Missing required option --url.")
        }
        guard let secret = parsed.option("secret") else {
            throw CLIError(exitCode: 64, message: "Missing required option --secret.")
        }
        let events = parsed.commaSeparatedOptions(["events", "event"])
        guard !events.isEmpty else {
            throw CLIError(exitCode: 64, message: "Missing required option --events or --event.")
        }
        guard let enabled = try boolOption(from: parsed, names: ["enabled"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --enabled.")
        }
        return AppStoreConnectWebhookCreateInput(
            appID: appID,
            name: name,
            url: url,
            secret: secret,
            eventTypes: events,
            enabled: enabled
        )
    }

    private static func webhookUpdateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectWebhookUpdateInput {
        guard let id = parsed.firstOption(["id", "webhook-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --webhook-id.")
        }
        let events = parsed.commaSeparatedOptions(["events", "event"])
        let enabled = try boolOption(from: parsed, names: ["enabled"])
        let input = AppStoreConnectWebhookUpdateInput(
            id: id,
            name: parsed.option("name"),
            url: parsed.option("url"),
            secret: parsed.option("secret"),
            eventTypes: events,
            enabled: enabled
        )
        guard input.name != nil
            || input.url != nil
            || input.secret != nil
            || !input.eventTypes.isEmpty
            || input.enabled != nil
        else {
            throw CLIError(exitCode: 64, message: "Provide at least one webhook update option.")
        }
        return input
    }

    private static func webhookDeleteInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectWebhookDeleteInput {
        guard let id = parsed.firstOption(["id", "webhook-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --webhook-id.")
        }
        return AppStoreConnectWebhookDeleteInput(id: id)
    }

    private static func webhookDeliveryRedeliverInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectWebhookDeliveryRedeliverInput {
        guard let id = parsed.firstOption(["delivery-id", "id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --delivery-id or --id.")
        }
        return AppStoreConnectWebhookDeliveryRedeliverInput(deliveryID: id)
    }

    private static func webhookPingInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectWebhookPingInput {
        guard let id = parsed.firstOption(["webhook-id", "id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --webhook-id or --id.")
        }
        return AppStoreConnectWebhookPingInput(webhookID: id)
    }

    private static func territoryListInput(from parsed: ParsedArguments) -> AppStoreConnectTerritoryListInput {
        AppStoreConnectTerritoryListInput(
            fields: parsed.commaSeparatedOption("field"),
            limit: parsed.intOption("limit")
        )
    }

    private static func eulaViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectEULAViewInput {
        guard let id = parsed.firstOption(["id", "eula-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --eula-id.")
        }
        return AppStoreConnectEULAViewInput(
            id: id,
            fields: parsed.commaSeparatedOption("field"),
            includeApp: parsed.hasFlag("include-app"),
            includeTerritories: parsed.hasFlag("include-territories"),
            territoriesLimit: parsed.intOption("territories-limit")
        )
    }

    private static func eulaCreateInput(
        from parsed: ParsedArguments,
        currentDirectory: URL
    ) throws -> AppStoreConnectEULACreateInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        let agreementText = try eulaAgreementText(from: parsed, currentDirectory: currentDirectory, required: true)
        let territoryIDs = parsed.commaSeparatedOptions(["territory", "territory-id", "territories"])
        guard !territoryIDs.isEmpty else {
            throw CLIError(exitCode: 64, message: "Provide at least one --territory.")
        }
        return AppStoreConnectEULACreateInput(appID: appID, agreementText: agreementText ?? "", territoryIDs: territoryIDs)
    }

    private static func eulaUpdateInput(
        from parsed: ParsedArguments,
        currentDirectory: URL
    ) throws -> AppStoreConnectEULAUpdateInput {
        guard let id = parsed.firstOption(["id", "eula-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --eula-id.")
        }
        let agreementText = try eulaAgreementText(from: parsed, currentDirectory: currentDirectory, required: false)
        let territoryIDs = parsed.commaSeparatedOptions(["territory", "territory-id", "territories"])
        guard agreementText != nil || !territoryIDs.isEmpty else {
            throw CLIError(exitCode: 64, message: "Provide --text, --text-path, or at least one --territory.")
        }
        return AppStoreConnectEULAUpdateInput(id: id, agreementText: agreementText, territoryIDs: territoryIDs)
    }

    private static func eulaDeleteInput(from parsed: ParsedArguments) throws -> AppStoreConnectEULADeleteInput {
        guard let id = parsed.firstOption(["id", "eula-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --eula-id.")
        }
        return AppStoreConnectEULADeleteInput(id: id)
    }

    private static func eulaAgreementText(
        from parsed: ParsedArguments,
        currentDirectory: URL,
        required: Bool
    ) throws -> String? {
        if let text = parsed.firstOption(["text", "agreement-text"]) {
            return text
        }

        guard let path = parsed.firstOption(["text-path", "agreement-text-path"]) else {
            if required {
                throw CLIError(exitCode: 64, message: "Missing required option --text or --text-path.")
            }
            return nil
        }

        let url = URL(fileURLWithPath: path, relativeTo: currentDirectory).standardizedFileURL
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            throw CLIError(exitCode: 1, message: "Could not read EULA text at \(url.path): \(error).")
        }
    }
#endif

#if ASC_PUBLIC_API_CLOUD
    private static func xcodeCloudProductListInput(
        from parsed: ParsedArguments
    ) -> AppStoreConnectXcodeCloudProductListInput {
        AppStoreConnectXcodeCloudProductListInput(
            productTypes: parsed.commaSeparatedOptions(["type", "product-type"]),
            appIDs: parsed.commaSeparatedOptions(["app", "app-id"]),
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            includeApp: parsed.hasFlag("include-app"),
            includeBundleID: parsed.hasFlag("include-bundle-id"),
            includePrimaryRepositories: parsed.hasFlag("include-primary-repositories"),
            limit: parsed.intOption("limit"),
            primaryRepositoriesLimit: parsed.intOption("primary-repositories-limit")
        )
    }

    private static func xcodeCloudProductViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectXcodeCloudProductViewInput {
        guard let id = parsed.firstOption(["id", "product-id", "product"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --product-id.")
        }
        return AppStoreConnectXcodeCloudProductViewInput(
            id: id,
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            includeApp: parsed.hasFlag("include-app"),
            includeBundleID: parsed.hasFlag("include-bundle-id"),
            includePrimaryRepositories: parsed.hasFlag("include-primary-repositories"),
            primaryRepositoriesLimit: parsed.intOption("primary-repositories-limit")
        )
    }

    private static func xcodeCloudWorkflowListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectXcodeCloudWorkflowListInput {
        guard let productID = parsed.firstOption(["product", "product-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --product or --product-id.")
        }
        return AppStoreConnectXcodeCloudWorkflowListInput(
            productID: productID,
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            includeProduct: parsed.hasFlag("include-product"),
            includeRepository: parsed.hasFlag("include-repository"),
            includeXcodeVersion: parsed.hasFlag("include-xcode-version"),
            includeMacOSVersion: parsed.hasFlag("include-macos-version"),
            limit: parsed.intOption("limit")
        )
    }

    private static func xcodeCloudWorkflowViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectXcodeCloudWorkflowViewInput {
        guard let id = parsed.firstOption(["id", "workflow-id", "workflow"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --workflow-id.")
        }
        return AppStoreConnectXcodeCloudWorkflowViewInput(
            id: id,
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            includeProduct: parsed.hasFlag("include-product"),
            includeRepository: parsed.hasFlag("include-repository"),
            includeXcodeVersion: parsed.hasFlag("include-xcode-version"),
            includeMacOSVersion: parsed.hasFlag("include-macos-version")
        )
    }

    private static func xcodeCloudBuildRunListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectXcodeCloudBuildRunListInput {
        let workflowID = parsed.firstOption(["workflow", "workflow-id"])
        let productID = parsed.firstOption(["product", "product-id"])
        guard workflowID != nil || productID != nil else {
            throw CLIError(exitCode: 64, message: "Missing required option --workflow/--workflow-id or --product/--product-id.")
        }
        return AppStoreConnectXcodeCloudBuildRunListInput(
            workflowID: workflowID,
            productID: productID,
            buildIDs: parsed.commaSeparatedOptions(["build", "build-id"]),
            sort: parsed.commaSeparatedOption("sort"),
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            includeBuilds: parsed.hasFlag("include-builds"),
            includeWorkflow: parsed.hasFlag("include-workflow"),
            includeProduct: parsed.hasFlag("include-product"),
            includeSourceBranchOrTag: parsed.hasFlag("include-source-branch-or-tag"),
            includeDestinationBranch: parsed.hasFlag("include-destination-branch"),
            includePullRequest: parsed.hasFlag("include-pull-request"),
            limit: parsed.intOption("limit"),
            buildsLimit: parsed.intOption("builds-limit")
        )
    }

    private static func xcodeCloudBuildRunViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectXcodeCloudBuildRunViewInput {
        guard let id = parsed.firstOption(["id", "run-id", "run", "build-run-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --run-id.")
        }
        return AppStoreConnectXcodeCloudBuildRunViewInput(
            id: id,
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            includeBuilds: parsed.hasFlag("include-builds"),
            includeWorkflow: parsed.hasFlag("include-workflow"),
            includeProduct: parsed.hasFlag("include-product"),
            includeSourceBranchOrTag: parsed.hasFlag("include-source-branch-or-tag"),
            includeDestinationBranch: parsed.hasFlag("include-destination-branch"),
            includePullRequest: parsed.hasFlag("include-pull-request"),
            buildsLimit: parsed.intOption("builds-limit")
        )
    }

    private static func xcodeCloudBuildActionListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectXcodeCloudBuildActionListInput {
        guard let runID = parsed.firstOption(["run", "run-id", "build-run-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --run or --run-id.")
        }
        return AppStoreConnectXcodeCloudBuildActionListInput(
            buildRunID: runID,
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            includeBuildRun: parsed.hasFlag("include-build-run"),
            limit: parsed.intOption("limit")
        )
    }

    private static func xcodeCloudBuildActionViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectXcodeCloudBuildActionViewInput {
        guard let id = parsed.firstOption(["id", "action-id", "action"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --action-id.")
        }
        return AppStoreConnectXcodeCloudBuildActionViewInput(
            id: id,
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            includeBuildRun: parsed.hasFlag("include-build-run")
        )
    }

    private static func xcodeCloudArtifactListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectXcodeCloudArtifactListInput {
        guard let actionID = parsed.firstOption(["action", "action-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --action or --action-id.")
        }
        return AppStoreConnectXcodeCloudArtifactListInput(
            buildActionID: actionID,
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            logOnly: false,
            limit: parsed.intOption("limit")
        )
    }

    private static func xcodeCloudLogListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectXcodeCloudArtifactListInput {
        var input = try xcodeCloudArtifactListInput(from: parsed)
        input.logOnly = true
        return input
    }

    private static func xcodeCloudArtifactViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectXcodeCloudArtifactViewInput {
        guard let id = parsed.firstOption(["id", "artifact-id", "artifact", "log-id", "log"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --artifact-id.")
        }
        return AppStoreConnectXcodeCloudArtifactViewInput(
            id: id,
            fields: parsed.commaSeparatedOptions(["field", "fields"])
        )
    }
#endif

    private static func appUpdateInput(from parsed: ParsedArguments) throws -> AppStoreConnectAppUpdateInput {
        guard let id = parsed.firstOption(["id", "app-id", "app"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --app.")
        }
        let input = AppStoreConnectAppUpdateInput(
            id: id,
            primaryLocale: parsed.firstOption(["primary-locale", "locale"]),
            contentRightsDeclaration: parsed.firstOption(["content-rights", "content-rights-declaration"]).map { $0.uppercased() },
            accessibilityURL: parsed.firstOption(["accessibility-url"]),
            subscriptionStatusURL: parsed.firstOption(["subscription-status-url"]),
            subscriptionStatusURLForSandbox: parsed.firstOption(["subscription-status-url-sandbox", "subscription-status-url-for-sandbox"]),
            streamlinedPurchasingEnabled: try boolOption(from: parsed, names: ["streamlined-purchasing-enabled"])
        )
        guard input.primaryLocale != nil
            || input.contentRightsDeclaration != nil
            || input.accessibilityURL != nil
            || input.subscriptionStatusURL != nil
            || input.subscriptionStatusURLForSandbox != nil
            || input.streamlinedPurchasingEnabled != nil
        else {
            throw CLIError(exitCode: 64, message: "Specify at least one app update field.")
        }
        return input
    }

    private static func buildListInput(from parsed: ParsedArguments) -> AppStoreConnectBuildListInput {
        AppStoreConnectBuildListInput(
            appID: parsed.firstOption(["app", "app-id"]),
            buildIDs: parsed.commaSeparatedOptions(["build-id", "id"]),
            buildNumbers: parsed.commaSeparatedOption("build-number"),
            versions: parsed.commaSeparatedOption("version"),
            platforms: parsed.commaSeparatedOption("platform").map { $0.uppercased() },
            processingStates: parsed.commaSeparatedOption("processing-state").map { $0.uppercased() },
            sort: parsed.option("sort"),
            limit: parsed.intOption("limit")
        )
    }

    private static func buildInfoInput(from parsed: ParsedArguments) throws -> AppStoreConnectBuildInfoInput {
        if let id = parsed.firstOption(["build-id", "id"]) {
            return AppStoreConnectBuildInfoInput(id: id)
        }

        guard parsed.hasFlag("latest") else {
            throw CLIError(exitCode: 64, message: "Missing required option --build-id, --id, or --latest.")
        }
        guard parsed.firstOption(["app", "app-id"]) != nil else {
            throw CLIError(exitCode: 64, message: "Missing required option --app when --latest is used.")
        }

        return AppStoreConnectBuildInfoInput(latestSelector: buildListInput(from: parsed))
    }

    private static func buildWaitInput(from parsed: ParsedArguments) throws -> AppStoreConnectBuildWaitInput {
        let maxAttempts = parsed.intOption("max-attempts") ?? parsed.intOption("attempts") ?? 60
        guard maxAttempts > 0 else {
            throw CLIError(exitCode: 64, message: "--max-attempts must be greater than zero.")
        }

        let intervalSeconds = parsed.doubleOption("interval")
            ?? parsed.doubleOption("interval-seconds")
            ?? 30
        guard intervalSeconds.isFinite, intervalSeconds >= 0 else {
            throw CLIError(exitCode: 64, message: "--interval must be finite and greater than or equal to zero.")
        }

        return AppStoreConnectBuildWaitInput(
            build: try buildInfoInput(from: parsed),
            targetProcessingStates: parsed
                .commaSeparatedOptions(["target-processing-state", "target-state"])
                .map { $0.uppercased() },
            failureProcessingStates: parsed
                .commaSeparatedOptions(["failure-processing-state", "failure-state"])
                .map { $0.uppercased() },
            maxAttempts: maxAttempts,
            intervalSeconds: intervalSeconds
        )
    }

    private static func buildBetaDetailListInput(
        from parsed: ParsedArguments
    ) -> AppStoreConnectBuildBetaDetailListInput {
        AppStoreConnectBuildBetaDetailListInput(
            ids: parsed.commaSeparatedOptions(["id", "beta-detail-id", "build-beta-detail-id"]),
            buildIDs: parsed.commaSeparatedOptions(["build", "build-id"]),
            limit: parsed.intOption("limit")
        )
    }

    private static func buildBetaDetailViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectBuildBetaDetailViewInput {
        guard let id = parsed.firstOption(["id", "beta-detail-id", "build-beta-detail-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --beta-detail-id.")
        }
        return AppStoreConnectBuildBetaDetailViewInput(id: id)
    }

    private static func preReleaseVersionListInput(
        from parsed: ParsedArguments
    ) -> AppStoreConnectPreReleaseVersionListInput {
        AppStoreConnectPreReleaseVersionListInput(
            appIDs: parsed.commaSeparatedOptions(["app", "app-id"]),
            buildIDs: parsed.commaSeparatedOptions(["build", "build-id"]),
            versions: parsed.commaSeparatedOptions(["version", "pre-release-version"]),
            buildVersions: parsed.commaSeparatedOptions(["build-version", "build-number"]),
            platforms: parsed.commaSeparatedOption("platform").map { $0.uppercased() },
            buildAudienceTypes: parsed.commaSeparatedOptions(["build-audience-type", "audience"]).map { $0.uppercased() },
            processingStates: parsed.commaSeparatedOptions(["processing-state", "build-processing-state"]).map { $0.uppercased() },
            buildExpired: parsed.firstOption(["build-expired", "expired"]),
            sort: parsed.option("sort"),
            limit: parsed.intOption("limit")
        )
    }

    private static func preReleaseVersionViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectPreReleaseVersionViewInput {
        guard let id = parsed.firstOption(["id", "pre-release-version-id", "prerelease-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --pre-release-version-id.")
        }
        return AppStoreConnectPreReleaseVersionViewInput(id: id)
    }

    private static func appStoreVersionListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppStoreVersionListInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }

        return AppStoreConnectAppStoreVersionListInput(
            appID: appID,
            ids: parsed.commaSeparatedOptions(["version-id", "app-store-version-id", "id"]),
            versionStrings: parsed.commaSeparatedOptions(["version", "version-string"]),
            platforms: parsed.commaSeparatedOption("platform").map { $0.uppercased() },
            appStoreStates: parsed.commaSeparatedOptions(["app-store-state", "store-state"]).map { $0.uppercased() },
            appVersionStates: parsed.commaSeparatedOptions(["app-version-state", "state"]).map { $0.uppercased() },
            limit: parsed.intOption("limit")
        )
    }

    private static func appStoreVersionViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppStoreVersionViewInput {
        guard let id = parsed.firstOption(["id", "version-id", "app-store-version-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --version-id.")
        }
        return AppStoreConnectAppStoreVersionViewInput(id: id)
    }

    private static func appStoreVersionCreateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppStoreVersionCreateInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        guard let versionString = parsed.firstOption(["version", "version-string"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --version.")
        }
        guard let platform = parsed.option("platform") else {
            throw CLIError(exitCode: 64, message: "Missing required option --platform.")
        }
        return AppStoreConnectAppStoreVersionCreateInput(
            appID: appID,
            versionString: versionString,
            platform: platform.uppercased(),
            buildID: parsed.firstOption(["build", "build-id"]),
            copyright: parsed.option("copyright"),
            earliestReleaseDate: try iso8601DateOption(from: parsed, names: ["earliest-release-date", "release-date"]),
            releaseType: parsed.option("release-type").map { $0.uppercased() },
            reviewType: parsed.option("review-type").map { $0.uppercased() }
        )
    }

    private static func appStoreVersionUpdateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppStoreVersionUpdateInput {
        guard let id = parsed.firstOption(["id", "version-id", "app-store-version-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --version-id.")
        }
        let input = AppStoreConnectAppStoreVersionUpdateInput(
            id: id,
            versionString: parsed.firstOption(["version", "version-string"]),
            buildID: parsed.firstOption(["build", "build-id"]),
            copyright: parsed.option("copyright"),
            downloadable: try boolOption(from: parsed, names: ["downloadable"]),
            earliestReleaseDate: try iso8601DateOption(from: parsed, names: ["earliest-release-date", "release-date"]),
            releaseType: parsed.option("release-type").map { $0.uppercased() },
            reviewType: parsed.option("review-type").map { $0.uppercased() }
        )
        guard input.versionString != nil
            || input.buildID != nil
            || input.copyright != nil
            || input.downloadable != nil
            || input.earliestReleaseDate != nil
            || input.releaseType != nil
            || input.reviewType != nil
        else {
            throw CLIError(exitCode: 64, message: "Specify at least one App Store version update field.")
        }
        return input
    }

    private static func appStoreVersionDeleteInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppStoreVersionDeleteInput {
        guard let id = parsed.firstOption(["id", "version-id", "app-store-version-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --version-id.")
        }
        return AppStoreConnectAppStoreVersionDeleteInput(id: id)
    }

    private static func appStoreVersionReleaseRequestCreateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppStoreVersionReleaseRequestCreateInput {
        guard let id = parsed.firstOption(["id", "version-id", "app-store-version-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --version-id.")
        }
        return AppStoreConnectAppStoreVersionReleaseRequestCreateInput(appStoreVersionID: id)
    }

    private static func betaGroupListInput(from parsed: ParsedArguments) -> AppStoreConnectBetaGroupListInput {
        AppStoreConnectBetaGroupListInput(
            appID: parsed.firstOption(["app", "app-id"]),
            ids: parsed.commaSeparatedOptions(["group-id", "id"]),
            names: parsed.commaSeparatedOption("name"),
            buildIDs: parsed.commaSeparatedOptions(["build", "build-id"]),
            isInternalGroup: parsed.firstOption(["is-internal", "internal"]),
            publicLinkEnabled: parsed.firstOption(["public-link-enabled"]),
            publicLinkLimitEnabled: parsed.firstOption(["public-link-limit-enabled"]),
            publicLink: parsed.firstOption(["public-link"]),
            sort: parsed.option("sort"),
            limit: parsed.intOption("limit")
        )
    }

    private static func betaGroupViewInput(from parsed: ParsedArguments) throws -> AppStoreConnectBetaGroupViewInput {
        guard let id = parsed.firstOption(["id", "group-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --group-id.")
        }
        return AppStoreConnectBetaGroupViewInput(id: id)
    }

    private static func betaTesterListInput(from parsed: ParsedArguments) -> AppStoreConnectBetaTesterListInput {
        AppStoreConnectBetaTesterListInput(
            ids: parsed.commaSeparatedOptions(["tester-id", "id"]),
            appIDs: parsed.commaSeparatedOptions(["app", "app-id"]),
            betaGroupIDs: parsed.commaSeparatedOptions(["group", "group-id"]),
            buildIDs: parsed.commaSeparatedOptions(["build", "build-id"]),
            emails: parsed.commaSeparatedOption("email"),
            firstNames: parsed.commaSeparatedOption("first-name"),
            lastNames: parsed.commaSeparatedOption("last-name"),
            inviteTypes: parsed.commaSeparatedOption("invite-type").map { $0.uppercased() },
            sort: parsed.option("sort"),
            limit: parsed.intOption("limit")
        )
    }

    private static func betaTesterViewInput(from parsed: ParsedArguments) throws -> AppStoreConnectBetaTesterViewInput {
        guard let id = parsed.firstOption(["id", "tester-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --tester-id.")
        }
        return AppStoreConnectBetaTesterViewInput(id: id)
    }

    private static func betaGroupCreateInput(from parsed: ParsedArguments) throws -> AppStoreConnectBetaGroupCreateInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        guard let name = parsed.option("name") else {
            throw CLIError(exitCode: 64, message: "Missing required option --name.")
        }
        return AppStoreConnectBetaGroupCreateInput(
            appID: appID,
            name: name,
            feedbackEnabled: try boolOption(from: parsed, names: ["feedback-enabled"]),
            hasAccessToAllBuilds: try boolOption(from: parsed, names: ["has-access-to-all-builds", "all-builds"]),
            isInternalGroup: try boolOption(from: parsed, names: ["is-internal", "internal"]),
            publicLinkEnabled: try boolOption(from: parsed, names: ["public-link-enabled"]),
            publicLinkLimit: parsed.intOption("public-link-limit"),
            publicLinkLimitEnabled: try boolOption(from: parsed, names: ["public-link-limit-enabled"]),
            betaTesterIDs: parsed.commaSeparatedOptions(["tester", "tester-id"]),
            buildIDs: parsed.commaSeparatedOptions(["build", "build-id"])
        )
    }

    private static func betaGroupUpdateInput(from parsed: ParsedArguments) throws -> AppStoreConnectBetaGroupUpdateInput {
        guard let id = parsed.firstOption(["id", "group-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --group-id.")
        }
        let input = AppStoreConnectBetaGroupUpdateInput(
            id: id,
            name: parsed.option("name"),
            feedbackEnabled: try boolOption(from: parsed, names: ["feedback-enabled"]),
            publicLinkEnabled: try boolOption(from: parsed, names: ["public-link-enabled"]),
            publicLinkLimit: parsed.intOption("public-link-limit"),
            publicLinkLimitEnabled: try boolOption(from: parsed, names: ["public-link-limit-enabled"]),
            iosBuildsAvailableForAppleSiliconMac: try boolOption(from: parsed, names: ["ios-builds-available-for-apple-silicon-mac", "apple-silicon-mac-builds"]),
            iosBuildsAvailableForAppleVision: try boolOption(from: parsed, names: ["ios-builds-available-for-apple-vision", "apple-vision-builds"])
        )
        guard input.name != nil
            || input.feedbackEnabled != nil
            || input.publicLinkEnabled != nil
            || input.publicLinkLimit != nil
            || input.publicLinkLimitEnabled != nil
            || input.iosBuildsAvailableForAppleSiliconMac != nil
            || input.iosBuildsAvailableForAppleVision != nil
        else {
            throw CLIError(exitCode: 64, message: "Specify at least one beta group update field.")
        }
        return input
    }

    private static func betaGroupDeleteInput(from parsed: ParsedArguments) throws -> AppStoreConnectBetaGroupDeleteInput {
        guard let id = parsed.firstOption(["id", "group-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --group-id.")
        }
        return AppStoreConnectBetaGroupDeleteInput(id: id)
    }

    private static func betaTesterCreateInput(from parsed: ParsedArguments) throws -> AppStoreConnectBetaTesterCreateInput {
        guard let email = parsed.option("email") else {
            throw CLIError(exitCode: 64, message: "Missing required option --email.")
        }
        return AppStoreConnectBetaTesterCreateInput(
            email: email,
            firstName: parsed.option("first-name"),
            lastName: parsed.option("last-name"),
            betaGroupIDs: parsed.commaSeparatedOptions(["group", "group-id"]),
            buildIDs: parsed.commaSeparatedOptions(["build", "build-id"])
        )
    }

    private static func betaTesterDeleteInput(from parsed: ParsedArguments) throws -> AppStoreConnectBetaTesterDeleteInput {
        guard let id = parsed.firstOption(["id", "tester-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --tester-id.")
        }
        return AppStoreConnectBetaTesterDeleteInput(id: id)
    }

    private static func betaAppLocalizationListInput(
        from parsed: ParsedArguments
    ) -> AppStoreConnectBetaAppLocalizationListInput {
        AppStoreConnectBetaAppLocalizationListInput(
            appIDs: parsed.commaSeparatedOptions(["app", "app-id"]),
            locales: parsed.commaSeparatedOptions(["locale", "locales"]),
            limit: parsed.intOption("limit")
        )
    }

    private static func betaAppLocalizationViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectBetaAppLocalizationViewInput {
        guard let id = parsed.firstOption(["id", "localization-id", "beta-app-localization-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --localization-id.")
        }
        return AppStoreConnectBetaAppLocalizationViewInput(id: id)
    }

    private static func betaBuildLocalizationListInput(
        from parsed: ParsedArguments
    ) -> AppStoreConnectBetaBuildLocalizationListInput {
        AppStoreConnectBetaBuildLocalizationListInput(
            buildIDs: parsed.commaSeparatedOptions(["build", "build-id"]),
            locales: parsed.commaSeparatedOptions(["locale", "locales"]),
            limit: parsed.intOption("limit")
        )
    }

    private static func betaBuildLocalizationViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectBetaBuildLocalizationViewInput {
        guard let id = parsed.firstOption(["id", "localization-id", "beta-build-localization-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --localization-id.")
        }
        return AppStoreConnectBetaBuildLocalizationViewInput(id: id)
    }

    private static func betaAppReviewDetailListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectBetaAppReviewDetailListInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        return AppStoreConnectBetaAppReviewDetailListInput(
            appID: appID,
            limit: parsed.intOption("limit")
        )
    }

    private static func betaAppReviewDetailViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectBetaAppReviewDetailViewInput {
        guard let id = parsed.firstOption(["id", "review-detail-id", "beta-app-review-detail-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --review-detail-id.")
        }
        return AppStoreConnectBetaAppReviewDetailViewInput(id: id)
    }

    private static func betaAppReviewDetailUpdateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectBetaAppReviewDetailUpdateInput {
        guard let id = parsed.firstOption(["id", "review-detail-id", "beta-app-review-detail-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --review-detail-id.")
        }
        let input = AppStoreConnectBetaAppReviewDetailUpdateInput(
            id: id,
            contactEmail: parsed.option("contact-email"),
            contactFirstName: parsed.option("contact-first-name"),
            contactLastName: parsed.option("contact-last-name"),
            contactPhone: parsed.option("contact-phone"),
            demoAccountName: parsed.option("demo-account-name"),
            demoAccountPassword: parsed.option("demo-account-password"),
            demoAccountRequired: try boolOption(from: parsed, names: ["demo-account-required"]),
            notes: parsed.option("notes")
        )
        guard input.contactEmail != nil
            || input.contactFirstName != nil
            || input.contactLastName != nil
            || input.contactPhone != nil
            || input.demoAccountName != nil
            || input.demoAccountPassword != nil
            || input.demoAccountRequired != nil
            || input.notes != nil
        else {
            throw CLIError(exitCode: 64, message: "Specify at least one beta app review detail update field.")
        }
        return input
    }

    private static func betaAppReviewSubmissionListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectBetaAppReviewSubmissionListInput {
        let buildIDs = parsed.commaSeparatedOptions(["build", "build-id"])
        guard !buildIDs.isEmpty else {
            throw CLIError(exitCode: 64, message: "Missing required option --build or --build-id.")
        }
        return AppStoreConnectBetaAppReviewSubmissionListInput(
            buildIDs: buildIDs,
            betaReviewStates: parsed.commaSeparatedOptions(["beta-review-state", "review-state", "state"]).map { $0.uppercased() },
            limit: parsed.intOption("limit")
        )
    }

    private static func betaAppReviewSubmissionViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectBetaAppReviewSubmissionViewInput {
        guard let id = parsed.firstOption(["id", "review-submission-id", "beta-review-submission-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --review-submission-id.")
        }
        return AppStoreConnectBetaAppReviewSubmissionViewInput(id: id)
    }

    private static func betaAppReviewSubmissionCreateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectBetaAppReviewSubmissionCreateInput {
        guard let buildID = parsed.firstOption(["build", "build-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --build or --build-id.")
        }
        return AppStoreConnectBetaAppReviewSubmissionCreateInput(buildID: buildID)
    }

    private static func betaLicenseAgreementListInput(
        from parsed: ParsedArguments
    ) -> AppStoreConnectBetaLicenseAgreementListInput {
        AppStoreConnectBetaLicenseAgreementListInput(
            appIDs: parsed.commaSeparatedOptions(["app", "app-id"]),
            limit: parsed.intOption("limit")
        )
    }

    private static func betaLicenseAgreementViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectBetaLicenseAgreementViewInput {
        guard let id = parsed.firstOption(["id", "license-agreement-id", "beta-license-agreement-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --license-agreement-id.")
        }
        return AppStoreConnectBetaLicenseAgreementViewInput(id: id)
    }

    private static func betaFeedbackCrashSubmissionListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectBetaFeedbackCrashSubmissionListInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        return AppStoreConnectBetaFeedbackCrashSubmissionListInput(
            appID: appID,
            deviceModels: parsed.commaSeparatedOptions(["device-model"]),
            osVersions: parsed.commaSeparatedOptions(["os-version"]),
            appPlatforms: parsed.commaSeparatedOptions(["app-platform"]).map { $0.uppercased() },
            devicePlatforms: parsed.commaSeparatedOptions(["device-platform", "platform"]).map { $0.uppercased() },
            buildIDs: parsed.commaSeparatedOptions(["build", "build-id"]),
            preReleaseVersionIDs: parsed.commaSeparatedOptions(["pre-release-version", "pre-release-version-id", "prerelease-id"]),
            testerIDs: parsed.commaSeparatedOptions(["tester", "tester-id"]),
            sort: parsed.option("sort"),
            limit: parsed.intOption("limit")
        )
    }

    private static func betaFeedbackCrashSubmissionViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectBetaFeedbackCrashSubmissionViewInput {
        guard let id = parsed.firstOption(["id", "feedback-id", "crash-id", "crash-submission-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --crash-id.")
        }
        return AppStoreConnectBetaFeedbackCrashSubmissionViewInput(id: id)
    }

    private static func betaFeedbackScreenshotSubmissionListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectBetaFeedbackScreenshotSubmissionListInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        return AppStoreConnectBetaFeedbackScreenshotSubmissionListInput(
            appID: appID,
            deviceModels: parsed.commaSeparatedOptions(["device-model"]),
            osVersions: parsed.commaSeparatedOptions(["os-version"]),
            appPlatforms: parsed.commaSeparatedOptions(["app-platform"]).map { $0.uppercased() },
            devicePlatforms: parsed.commaSeparatedOptions(["device-platform", "platform"]).map { $0.uppercased() },
            buildIDs: parsed.commaSeparatedOptions(["build", "build-id"]),
            preReleaseVersionIDs: parsed.commaSeparatedOptions(["pre-release-version", "pre-release-version-id", "prerelease-id"]),
            testerIDs: parsed.commaSeparatedOptions(["tester", "tester-id"]),
            sort: parsed.option("sort"),
            limit: parsed.intOption("limit")
        )
    }

    private static func betaFeedbackScreenshotSubmissionViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectBetaFeedbackScreenshotSubmissionViewInput {
        guard let id = parsed.firstOption(["id", "feedback-id", "screenshot-id", "screenshot-submission-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --feedback-id.")
        }
        return AppStoreConnectBetaFeedbackScreenshotSubmissionViewInput(id: id)
    }

    private static func betaCrashLogViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectBetaCrashLogViewInput {
        guard let id = parsed.firstOption(["id", "crash-log-id", "log-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --crash-log-id.")
        }
        return AppStoreConnectBetaCrashLogViewInput(id: id)
    }

    private static func betaFeedbackCrashSubmissionCrashLogInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectBetaFeedbackCrashSubmissionCrashLogInput {
        guard let id = parsed.firstOption(["id", "feedback-id", "crash-id", "crash-submission-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --crash-id.")
        }
        return AppStoreConnectBetaFeedbackCrashSubmissionCrashLogInput(id: id)
    }

    private static func betaTesterUsageMetricsResult(
        parsed: ParsedArguments,
        commands: PublicAPIReadCommands
    ) async throws -> AppStoreConnectBetaTesterUsageMetricsResult {
        if let testerID = parsed.firstOption(["tester", "tester-id"]) {
            guard let appID = parsed.firstOption(["app", "app-id"]) else {
                throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id for tester metrics.")
            }
            return try await commands.getBetaTesterUsageMetrics(.init(
                testerID: testerID,
                appID: appID,
                period: parsed.option("period"),
                limit: parsed.intOption("limit")
            ))
        }

        if let groupID = parsed.firstOption(["group", "group-id"]) {
            return try await commands.getBetaGroupBetaTesterUsageMetrics(.init(
                groupID: groupID,
                betaTesterID: betaTesterIDFilter(from: parsed),
                period: parsed.option("period"),
                groupByBetaTesters: parsed.hasFlag("group-by-beta-testers"),
                limit: parsed.intOption("limit")
            ))
        }

        if let appID = parsed.firstOption(["app", "app-id"]) {
            return try await commands.getAppBetaTesterUsageMetrics(.init(
                appID: appID,
                betaTesterID: betaTesterIDFilter(from: parsed),
                period: parsed.option("period"),
                groupByBetaTesters: parsed.hasFlag("group-by-beta-testers"),
                limit: parsed.intOption("limit")
            ))
        }

        throw CLIError(exitCode: 64, message: "Missing required option --app, --group, or --tester.")
    }

    private static func betaGroupBetaTesterUsageMetricsInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectBetaGroupBetaTesterUsageMetricsInput {
        guard let groupID = parsed.firstOption(["group", "group-id", "id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --group or --id.")
        }
        return AppStoreConnectBetaGroupBetaTesterUsageMetricsInput(
            groupID: groupID,
            betaTesterID: betaTesterIDFilter(from: parsed),
            period: parsed.option("period"),
            groupByBetaTesters: parsed.hasFlag("group-by-beta-testers"),
            limit: parsed.intOption("limit")
        )
    }

    private static func betaTesterUsageMetricsInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectBetaTesterUsageMetricsInput {
        guard let testerID = parsed.firstOption(["tester", "tester-id", "id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --tester or --id.")
        }
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        return AppStoreConnectBetaTesterUsageMetricsInput(
            testerID: testerID,
            appID: appID,
            period: parsed.option("period"),
            limit: parsed.intOption("limit")
        )
    }

    private static func betaGroupPublicLinkUsageMetricsInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectBetaGroupPublicLinkUsageMetricsInput {
        guard let groupID = parsed.firstOption(["group", "group-id", "id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --group or --id.")
        }
        return AppStoreConnectBetaGroupPublicLinkUsageMetricsInput(
            groupID: groupID,
            limit: parsed.intOption("limit")
        )
    }

    private static func betaBuildUsageMetricsInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectBetaBuildUsageMetricsInput {
        guard let buildID = parsed.firstOption(["build", "build-id", "id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --build or --id.")
        }
        return AppStoreConnectBetaBuildUsageMetricsInput(
            buildID: buildID,
            limit: parsed.intOption("limit")
        )
    }

    private static func betaTesterIDFilter(from parsed: ParsedArguments) -> String? {
        parsed.firstOption(["beta-tester", "beta-tester-id", "tester-filter", "tester-filter-id"])
    }

    private static func betaTesterInvitationCreateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectBetaTesterInvitationCreateInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        return AppStoreConnectBetaTesterInvitationCreateInput(appID: appID)
    }

    private static func bundleIDListInput(from parsed: ParsedArguments) -> AppStoreConnectBundleIDListInput {
        AppStoreConnectBundleIDListInput(
            ids: parsed.commaSeparatedOptions(["id", "bundle-id-id"]),
            names: parsed.commaSeparatedOption("name"),
            identifiers: parsed.commaSeparatedOptions(["identifier", "bundle-id"]),
            seedIDs: parsed.commaSeparatedOptions(["seed-id", "team-id"]),
            platforms: parsed.commaSeparatedOption("platform").map { $0.uppercased() },
            sort: parsed.option("sort"),
            limit: parsed.intOption("limit")
        )
    }

    private static func bundleIDViewInput(from parsed: ParsedArguments) throws -> AppStoreConnectBundleIDViewInput {
        guard let id = parsed.firstOption(["id", "bundle-id-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --bundle-id-id.")
        }
        return AppStoreConnectBundleIDViewInput(id: id)
    }

    private static func bundleIDCreateInput(from parsed: ParsedArguments) throws -> AppStoreConnectBundleIDCreateInput {
        guard let identifier = parsed.firstOption(["identifier", "bundle-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --identifier or --bundle-id.")
        }
        guard let name = parsed.option("name") else {
            throw CLIError(exitCode: 64, message: "Missing required option --name.")
        }
        guard let platform = parsed.option("platform") else {
            throw CLIError(exitCode: 64, message: "Missing required option --platform.")
        }
        return AppStoreConnectBundleIDCreateInput(
            identifier: identifier,
            name: name,
            platform: platform.uppercased(),
            seedID: parsed.firstOption(["seed-id", "team-id"])
        )
    }

    private static func bundleIDUpdateInput(from parsed: ParsedArguments) throws -> AppStoreConnectBundleIDUpdateInput {
        guard let id = parsed.firstOption(["id", "bundle-id-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --bundle-id-id.")
        }
        let input = AppStoreConnectBundleIDUpdateInput(id: id, name: parsed.option("name"))
        guard input.name != nil else {
            throw CLIError(exitCode: 64, message: "Specify at least one bundle ID update field.")
        }
        return input
    }

    private static func bundleIDDeleteInput(from parsed: ParsedArguments) throws -> AppStoreConnectBundleIDDeleteInput {
        guard let id = parsed.firstOption(["id", "bundle-id-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --bundle-id-id.")
        }
        return AppStoreConnectBundleIDDeleteInput(id: id)
    }

    private static func bundleIDCapabilityListInput(from parsed: ParsedArguments) throws -> AppStoreConnectBundleIDCapabilityListInput {
        guard let bundleID = parsed.firstOption(["bundle-id", "bundle-id-id", "id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --bundle-id or --id.")
        }
        return AppStoreConnectBundleIDCapabilityListInput(
            bundleID: bundleID,
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            limit: parsed.intOption("limit")
        )
    }

    private static func bundleIDCapabilityCreateInput(
        from parsed: ParsedArguments,
        currentDirectory: URL
    ) throws -> AppStoreConnectBundleIDCapabilityCreateInput {
        guard let bundleID = parsed.firstOption(["bundle-id", "bundle-id-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --bundle-id or --bundle-id-id.")
        }
        guard let capabilityType = parsed.firstOption(["capability-type", "capability", "type"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --capability-type or --capability.")
        }
        return AppStoreConnectBundleIDCapabilityCreateInput(
            bundleID: bundleID,
            capabilityType: capabilityType,
            settingsJSON: try bundleIDCapabilitySettingsJSON(from: parsed, currentDirectory: currentDirectory)
        )
    }

    private static func bundleIDCapabilityUpdateInput(
        from parsed: ParsedArguments,
        currentDirectory: URL
    ) throws -> AppStoreConnectBundleIDCapabilityUpdateInput {
        guard let id = parsed.firstOption(["id", "capability-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --capability-id.")
        }
        let input = AppStoreConnectBundleIDCapabilityUpdateInput(
            id: id,
            capabilityType: parsed.firstOption(["capability-type", "capability", "type"]),
            settingsJSON: try bundleIDCapabilitySettingsJSON(from: parsed, currentDirectory: currentDirectory)
        )
        guard input.capabilityType != nil || input.settingsJSON != nil else {
            throw CLIError(exitCode: 64, message: "Specify at least one bundle ID capability update field.")
        }
        return input
    }

    private static func bundleIDCapabilityDeleteInput(from parsed: ParsedArguments) throws -> AppStoreConnectBundleIDCapabilityDeleteInput {
        guard let id = parsed.firstOption(["id", "capability-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --capability-id.")
        }
        return AppStoreConnectBundleIDCapabilityDeleteInput(id: id)
    }

    private static func certificateListInput(from parsed: ParsedArguments) -> AppStoreConnectCertificateListInput {
        AppStoreConnectCertificateListInput(
            ids: parsed.commaSeparatedOptions(["id", "certificate-id"]),
            displayNames: parsed.commaSeparatedOptions(["display-name", "name"]),
            certificateTypes: parsed.commaSeparatedOptions(["certificate-type", "type"]).map { $0.uppercased() },
            serialNumbers: parsed.commaSeparatedOption("serial-number"),
            sort: parsed.option("sort"),
            limit: parsed.intOption("limit")
        )
    }

    private static func certificateViewInput(from parsed: ParsedArguments) throws -> AppStoreConnectCertificateViewInput {
        guard let id = parsed.firstOption(["id", "certificate-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --certificate-id.")
        }
        return AppStoreConnectCertificateViewInput(id: id)
    }

    private static func certificateDownloadInput(from parsed: ParsedArguments) throws -> AppStoreConnectCertificateDownloadInput {
        guard let id = parsed.firstOption(["id", "certificate-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --certificate-id.")
        }
        return AppStoreConnectCertificateDownloadInput(
            id: id,
            outputPath: parsed.firstOption(["output-path", "output", "file", "path"])
        )
    }

    private static func certificateCreateInput(
        from parsed: ParsedArguments,
        currentDirectory: URL
    ) throws -> AppStoreConnectCertificateCreateInput {
        guard let certificateType = parsed.firstOption(["certificate-type", "type"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --certificate-type or --type.")
        }
        return AppStoreConnectCertificateCreateInput(
            certificateType: certificateType.uppercased(),
            csrContent: try csrContent(from: parsed, currentDirectory: currentDirectory),
            merchantID: parsed.firstOption(["merchant-id", "merchant"]),
            passTypeID: parsed.firstOption(["pass-type-id", "pass-type"])
        )
    }

    private static func certificateUpdateInput(from parsed: ParsedArguments) throws -> AppStoreConnectCertificateUpdateInput {
        guard let id = parsed.firstOption(["id", "certificate-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --certificate-id.")
        }
        let input = AppStoreConnectCertificateUpdateInput(
            id: id,
            activated: try boolOption(from: parsed, names: ["activated"])
        )
        guard input.activated != nil else {
            throw CLIError(exitCode: 64, message: "Specify at least one certificate update field.")
        }
        return input
    }

    private static func certificateDeleteInput(from parsed: ParsedArguments) throws -> AppStoreConnectCertificateDeleteInput {
        guard let id = parsed.firstOption(["id", "certificate-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --certificate-id.")
        }
        return AppStoreConnectCertificateDeleteInput(id: id)
    }

    private static func deviceListInput(from parsed: ParsedArguments) -> AppStoreConnectDeviceListInput {
        AppStoreConnectDeviceListInput(
            ids: parsed.commaSeparatedOptions(["id", "device-id"]),
            names: parsed.commaSeparatedOption("name"),
            platforms: parsed.commaSeparatedOption("platform").map { $0.uppercased() },
            udids: parsed.commaSeparatedOption("udid"),
            statuses: parsed.commaSeparatedOption("status").map { $0.uppercased() },
            sort: parsed.option("sort"),
            limit: parsed.intOption("limit")
        )
    }

    private static func deviceViewInput(from parsed: ParsedArguments) throws -> AppStoreConnectDeviceViewInput {
        guard let id = parsed.firstOption(["id", "device-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --device-id.")
        }
        return AppStoreConnectDeviceViewInput(id: id)
    }

    private static func deviceCreateInput(from parsed: ParsedArguments) throws -> AppStoreConnectDeviceCreateInput {
        guard let name = parsed.option("name") else {
            throw CLIError(exitCode: 64, message: "Missing required option --name.")
        }
        guard let udid = parsed.option("udid") else {
            throw CLIError(exitCode: 64, message: "Missing required option --udid.")
        }
        guard let platform = parsed.option("platform") else {
            throw CLIError(exitCode: 64, message: "Missing required option --platform.")
        }
        return AppStoreConnectDeviceCreateInput(
            name: name,
            udid: udid,
            platform: platform.uppercased()
        )
    }

    private static func deviceUpdateInput(from parsed: ParsedArguments) throws -> AppStoreConnectDeviceUpdateInput {
        guard let id = parsed.firstOption(["id", "device-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --device-id.")
        }
        let input = AppStoreConnectDeviceUpdateInput(
            id: id,
            name: parsed.option("name"),
            status: parsed.option("status").map { $0.uppercased() }
        )
        guard input.name != nil || input.status != nil else {
            throw CLIError(exitCode: 64, message: "Specify at least one device update field.")
        }
        return input
    }

    private static func deviceStatusInput(
        from parsed: ParsedArguments,
        status: String
    ) throws -> AppStoreConnectDeviceUpdateInput {
        guard let id = parsed.firstOption(["id", "device-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --device-id.")
        }
        return AppStoreConnectDeviceUpdateInput(id: id, status: status)
    }

    private static func profileListInput(from parsed: ParsedArguments) -> AppStoreConnectProfileListInput {
        AppStoreConnectProfileListInput(
            ids: parsed.commaSeparatedOptions(["id", "profile-id"]),
            names: parsed.commaSeparatedOption("name"),
            profileTypes: parsed.commaSeparatedOptions(["profile-type", "type"]).map { $0.uppercased() },
            profileStates: parsed.commaSeparatedOptions(["profile-state", "state", "status"]).map { $0.uppercased() },
            sort: parsed.option("sort"),
            limit: parsed.intOption("limit")
        )
    }

    private static func profileViewInput(from parsed: ParsedArguments) throws -> AppStoreConnectProfileViewInput {
        guard let id = parsed.firstOption(["id", "profile-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --profile-id.")
        }
        return AppStoreConnectProfileViewInput(id: id)
    }

    private static func profileDownloadInput(from parsed: ParsedArguments) throws -> AppStoreConnectProfileDownloadInput {
        guard let id = parsed.firstOption(["id", "profile-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --profile-id.")
        }
        return AppStoreConnectProfileDownloadInput(
            id: id,
            outputPath: parsed.firstOption(["output-path", "output", "file", "path"])
        )
    }

    private static func profileCreateInput(from parsed: ParsedArguments) throws -> AppStoreConnectProfileCreateInput {
        guard let name = parsed.option("name") else {
            throw CLIError(exitCode: 64, message: "Missing required option --name.")
        }
        guard let profileType = parsed.firstOption(["profile-type", "type"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --profile-type or --type.")
        }
        guard let bundleID = parsed.firstOption(["bundle-id", "bundle-id-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --bundle-id.")
        }
        let certificateIDs = parsed.commaSeparatedOptions(["certificate", "certificate-id"])
        guard !certificateIDs.isEmpty else {
            throw CLIError(exitCode: 64, message: "Missing required option --certificate or --certificate-id.")
        }
        return AppStoreConnectProfileCreateInput(
            name: name,
            profileType: profileType.uppercased(),
            bundleID: bundleID,
            certificateIDs: certificateIDs,
            deviceIDs: parsed.commaSeparatedOptions(["device", "device-id"])
        )
    }

    private static func profileDeleteInput(from parsed: ParsedArguments) throws -> AppStoreConnectProfileDeleteInput {
        guard let id = parsed.firstOption(["id", "profile-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --profile-id.")
        }
        return AppStoreConnectProfileDeleteInput(id: id)
    }

    private static func userListInput(from parsed: ParsedArguments) -> AppStoreConnectUserListInput {
        AppStoreConnectUserListInput(
            usernames: parsed.commaSeparatedOptions(["username", "email"]),
            roles: parsed.commaSeparatedOption("role").map { $0.uppercased() },
            visibleAppIDs: parsed.commaSeparatedOptions(["visible-app", "visible-app-id", "app", "app-id"]),
            sort: parsed.option("sort"),
            limit: parsed.intOption("limit")
        )
    }

    private static func userViewInput(from parsed: ParsedArguments) throws -> AppStoreConnectUserViewInput {
        guard let id = parsed.firstOption(["id", "user-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --user-id.")
        }
        return AppStoreConnectUserViewInput(id: id)
    }

#if ASC_PUBLIC_API_SIGNING_ACCESS
    private static func actorListInput(from parsed: ParsedArguments) -> AppStoreConnectActorListInput {
        AppStoreConnectActorListInput(
            ids: parsed.commaSeparatedOptions(["id", "actor-id"]),
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            limit: parsed.intOption("limit")
        )
    }

    private static func actorViewInput(from parsed: ParsedArguments) throws -> AppStoreConnectActorViewInput {
        guard let id = parsed.firstOption(["id", "actor-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --actor-id.")
        }
        return AppStoreConnectActorViewInput(
            id: id,
            fields: parsed.commaSeparatedOptions(["field", "fields"])
        )
    }
#endif

    private static func userUpdateInput(from parsed: ParsedArguments) throws -> AppStoreConnectUserUpdateInput {
        guard let id = parsed.firstOption(["id", "user-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --user-id.")
        }
        return AppStoreConnectUserUpdateInput(
            id: id,
            roles: parsed.commaSeparatedOptions(["role", "roles"]).map { $0.uppercased() },
            allAppsVisible: try boolOption(from: parsed, names: ["all-apps-visible", "all-apps"]),
            provisioningAllowed: try boolOption(from: parsed, names: ["provisioning-allowed", "allow-provisioning"]),
            visibleAppIDs: parsed.commaSeparatedOptions(["visible-app", "visible-app-id", "app", "app-id"])
        )
    }

    private static func userDeleteInput(from parsed: ParsedArguments) throws -> AppStoreConnectUserDeleteInput {
        guard let id = parsed.firstOption(["id", "user-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --user-id.")
        }
        return AppStoreConnectUserDeleteInput(id: id)
    }

    private static func userInvitationCreateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectUserInvitationCreateInput {
        guard let email = parsed.firstOption(["email", "username"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --email.")
        }
        guard let firstName = parsed.firstOption(["first-name", "given-name"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --first-name.")
        }
        guard let lastName = parsed.firstOption(["last-name", "family-name"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --last-name.")
        }
        let roles = parsed.commaSeparatedOptions(["role", "roles"]).map { $0.uppercased() }
        guard !roles.isEmpty else {
            throw CLIError(exitCode: 64, message: "Missing required option --role or --roles.")
        }
        return AppStoreConnectUserInvitationCreateInput(
            email: email,
            firstName: firstName,
            lastName: lastName,
            roles: roles,
            allAppsVisible: try boolOption(from: parsed, names: ["all-apps-visible", "all-apps"]),
            provisioningAllowed: try boolOption(from: parsed, names: ["provisioning-allowed", "allow-provisioning"]),
            visibleAppIDs: parsed.commaSeparatedOptions(["visible-app", "visible-app-id", "app", "app-id"])
        )
    }

    private static func userInvitationListInput(
        from parsed: ParsedArguments
    ) -> AppStoreConnectUserInvitationListInput {
        AppStoreConnectUserInvitationListInput(
            emails: parsed.commaSeparatedOption("email"),
            roles: parsed.commaSeparatedOption("role").map { $0.uppercased() },
            visibleAppIDs: parsed.commaSeparatedOptions(["visible-app", "visible-app-id", "app", "app-id"]),
            sort: parsed.option("sort"),
            limit: parsed.intOption("limit")
        )
    }

    private static func userInvitationViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectUserInvitationViewInput {
        guard let id = parsed.firstOption(["id", "invitation-id", "user-invitation-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --invitation-id.")
        }
        return AppStoreConnectUserInvitationViewInput(id: id)
    }

    private static func userInvitationDeleteInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectUserInvitationDeleteInput {
        guard let id = parsed.firstOption(["id", "invitation-id", "user-invitation-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --invitation-id.")
        }
        return AppStoreConnectUserInvitationDeleteInput(id: id)
    }

#if ASC_PUBLIC_API_COMMERCE
    private static func iapListInput(from parsed: ParsedArguments) throws -> AppStoreConnectInAppPurchaseListInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        return AppStoreConnectInAppPurchaseListInput(
            appID: appID,
            productIDs: parsed.commaSeparatedOptions(["product-id", "product"]),
            names: parsed.commaSeparatedOption("name"),
            states: parsed.commaSeparatedOptions(["state", "iap-state"]).map(normalizedASCEnum),
            inAppPurchaseTypes: parsed.commaSeparatedOptions(["type", "iap-type", "in-app-purchase-type"]).map(normalizedASCEnum),
            sort: parsed.option("sort"),
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            includes: parsed.commaSeparatedOption("include").map(normalizedInAppPurchaseInclude),
            limit: parsed.intOption("limit")
        )
    }

    private static func iapViewInput(from parsed: ParsedArguments) throws -> AppStoreConnectInAppPurchaseViewInput {
        guard let id = parsed.firstOption(["id", "iap-id", "in-app-purchase-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --iap-id.")
        }
        return AppStoreConnectInAppPurchaseViewInput(id: id)
    }

    private static func iapCreateInput(from parsed: ParsedArguments) throws -> AppStoreConnectInAppPurchaseCreateInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        guard let name = parsed.option("name") else {
            throw CLIError(exitCode: 64, message: "Missing required option --name.")
        }
        guard let productID = parsed.firstOption(["product-id", "product"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --product-id.")
        }
        guard let type = parsed.firstOption(["type", "iap-type", "in-app-purchase-type"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --type.")
        }
        return AppStoreConnectInAppPurchaseCreateInput(
            appID: appID,
            name: name,
            productID: productID,
            inAppPurchaseType: normalizedASCEnum(type),
            familySharable: try boolOption(from: parsed, names: ["family-sharable"]),
            reviewNote: parsed.firstOption(["review-note", "notes"])
        )
    }

    private static func iapUpdateInput(from parsed: ParsedArguments) throws -> AppStoreConnectInAppPurchaseUpdateInput {
        guard let id = parsed.firstOption(["id", "iap-id", "in-app-purchase-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --iap-id.")
        }
        let input = AppStoreConnectInAppPurchaseUpdateInput(
            id: id,
            name: parsed.option("name"),
            familySharable: try boolOption(from: parsed, names: ["family-sharable"]),
            reviewNote: parsed.firstOption(["review-note", "notes"])
        )
        guard input.name != nil || input.familySharable != nil || input.reviewNote != nil else {
            throw CLIError(exitCode: 64, message: "Specify at least one IAP update field.")
        }
        return input
    }

    private static func iapDeleteInput(from parsed: ParsedArguments) throws -> AppStoreConnectInAppPurchaseDeleteInput {
        guard let id = parsed.firstOption(["id", "iap-id", "in-app-purchase-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --iap-id.")
        }
        return AppStoreConnectInAppPurchaseDeleteInput(id: id)
    }

    private static func iapSubmitInput(from parsed: ParsedArguments) throws -> AppStoreConnectInAppPurchaseSubmitInput {
        guard let id = parsed.firstOption(["id", "iap-id", "in-app-purchase-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --iap-id.")
        }
        return AppStoreConnectInAppPurchaseSubmitInput(id: id)
    }

    private static func iapLocalizationListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectInAppPurchaseLocalizationListInput {
        guard let id = parsed.firstOption(["iap", "iap-id", "in-app-purchase", "in-app-purchase-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --iap or --iap-id.")
        }
        return AppStoreConnectInAppPurchaseLocalizationListInput(
            inAppPurchaseID: id,
            limit: parsed.intOption("limit")
        )
    }

    private static func iapLocalizationCreateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectInAppPurchaseLocalizationCreateInput {
        guard let id = parsed.firstOption(["iap", "iap-id", "in-app-purchase", "in-app-purchase-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --iap or --iap-id.")
        }
        guard let locale = parsed.option("locale") else {
            throw CLIError(exitCode: 64, message: "Missing required option --locale.")
        }
        guard let name = parsed.option("name") else {
            throw CLIError(exitCode: 64, message: "Missing required option --name.")
        }
        return AppStoreConnectInAppPurchaseLocalizationCreateInput(
            inAppPurchaseID: id,
            locale: locale,
            name: name,
            description: parsed.option("description")
        )
    }

    private static func iapLocalizationUpdateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectInAppPurchaseLocalizationUpdateInput {
        guard let id = parsed.firstOption(["id", "localization-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --localization-id.")
        }
        let input = AppStoreConnectInAppPurchaseLocalizationUpdateInput(
            id: id,
            name: parsed.option("name"),
            description: parsed.option("description")
        )
        guard input.name != nil || input.description != nil else {
            throw CLIError(exitCode: 64, message: "Specify at least one IAP localization update field.")
        }
        return input
    }

    private static func promotedPurchaseListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectPromotedPurchaseListInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        return AppStoreConnectPromotedPurchaseListInput(
            appID: appID,
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            includes: parsed.commaSeparatedOption("include").map(normalizedPromotedPurchaseInclude),
            limit: parsed.intOption("limit")
        )
    }

    private static func promotedPurchaseViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectPromotedPurchaseViewInput {
        guard let id = parsed.firstOption(["id", "promoted-purchase-id", "promotedpurchase-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --promoted-purchase-id.")
        }
        return AppStoreConnectPromotedPurchaseViewInput(
            id: id,
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            includes: parsed.commaSeparatedOption("include").map(normalizedPromotedPurchaseInclude)
        )
    }

    private static func promotedPurchaseCreateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectPromotedPurchaseCreateInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        let inAppPurchaseID = parsed.firstOption(["iap", "iap-id", "in-app-purchase", "in-app-purchase-id"])
        let subscriptionID = parsed.firstOption(["subscription", "subscription-id"])
        guard (inAppPurchaseID == nil) != (subscriptionID == nil) else {
            throw CLIError(exitCode: 64, message: "Specify exactly one of --iap or --subscription.")
        }
        guard let visibleForAllUsers = try boolOption(from: parsed, names: ["visible-for-all-users", "visible"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --visible-for-all-users.")
        }
        return AppStoreConnectPromotedPurchaseCreateInput(
            appID: appID,
            inAppPurchaseID: inAppPurchaseID,
            subscriptionID: subscriptionID,
            visibleForAllUsers: visibleForAllUsers,
            enabled: try boolOption(from: parsed, names: ["enabled"])
        )
    }

    private static func promotedPurchaseUpdateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectPromotedPurchaseUpdateInput {
        guard let id = parsed.firstOption(["id", "promoted-purchase-id", "promotedpurchase-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --promoted-purchase-id.")
        }
        let input = AppStoreConnectPromotedPurchaseUpdateInput(
            id: id,
            visibleForAllUsers: try boolOption(from: parsed, names: ["visible-for-all-users", "visible"]),
            enabled: try boolOption(from: parsed, names: ["enabled"])
        )
        guard input.visibleForAllUsers != nil || input.enabled != nil else {
            throw CLIError(exitCode: 64, message: "Specify at least one promoted purchase update field.")
        }
        return input
    }

    private static func promotedPurchaseDeleteInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectPromotedPurchaseDeleteInput {
        guard let id = parsed.firstOption(["id", "promoted-purchase-id", "promotedpurchase-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --promoted-purchase-id.")
        }
        return AppStoreConnectPromotedPurchaseDeleteInput(id: id)
    }

    private static func subscriptionGroupViewInput(from parsed: ParsedArguments) throws -> AppStoreConnectSubscriptionGroupViewInput {
        guard let id = parsed.firstOption(["id", "group", "group-id", "subscription-group-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --group-id.")
        }
        return AppStoreConnectSubscriptionGroupViewInput(id: id)
    }

    private static func subscriptionGroupCreateInput(from parsed: ParsedArguments) throws -> AppStoreConnectSubscriptionGroupCreateInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        guard let referenceName = parsed.firstOption(["reference-name", "name"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --reference-name or --name.")
        }
        return AppStoreConnectSubscriptionGroupCreateInput(appID: appID, referenceName: referenceName)
    }

    private static func subscriptionGroupUpdateInput(from parsed: ParsedArguments) throws -> AppStoreConnectSubscriptionGroupUpdateInput {
        guard let id = parsed.firstOption(["id", "group", "group-id", "subscription-group-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --group-id.")
        }
        let input = AppStoreConnectSubscriptionGroupUpdateInput(
            id: id,
            referenceName: parsed.firstOption(["reference-name", "name"])
        )
        guard input.referenceName != nil else {
            throw CLIError(exitCode: 64, message: "Specify at least one subscription group update field.")
        }
        return input
    }

    private static func subscriptionGroupDeleteInput(from parsed: ParsedArguments) throws -> AppStoreConnectSubscriptionGroupDeleteInput {
        guard let id = parsed.firstOption(["id", "group", "group-id", "subscription-group-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --group-id.")
        }
        return AppStoreConnectSubscriptionGroupDeleteInput(id: id)
    }

    private static func subscriptionGroupLocalizationListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectSubscriptionGroupLocalizationListInput {
        guard let id = parsed.firstOption(["group", "group-id", "subscription-group-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --group or --group-id.")
        }
        return AppStoreConnectSubscriptionGroupLocalizationListInput(
            groupID: id,
            limit: parsed.intOption("limit")
        )
    }

    private static func subscriptionGroupLocalizationCreateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectSubscriptionGroupLocalizationCreateInput {
        guard let id = parsed.firstOption(["group", "group-id", "subscription-group-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --group or --group-id.")
        }
        guard let locale = parsed.option("locale") else {
            throw CLIError(exitCode: 64, message: "Missing required option --locale.")
        }
        guard let name = parsed.option("name") else {
            throw CLIError(exitCode: 64, message: "Missing required option --name.")
        }
        return AppStoreConnectSubscriptionGroupLocalizationCreateInput(
            groupID: id,
            locale: locale,
            name: name,
            customAppName: parsed.firstOption(["custom-app-name", "app-name"])
        )
    }

    private static func subscriptionGroupLocalizationUpdateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectSubscriptionGroupLocalizationUpdateInput {
        guard let id = parsed.firstOption(["id", "localization-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --localization-id.")
        }
        let input = AppStoreConnectSubscriptionGroupLocalizationUpdateInput(
            id: id,
            name: parsed.option("name"),
            customAppName: parsed.firstOption(["custom-app-name", "app-name"])
        )
        guard input.name != nil || input.customAppName != nil else {
            throw CLIError(exitCode: 64, message: "Specify at least one subscription group localization update field.")
        }
        return input
    }

    private static func subscriptionListInput(from parsed: ParsedArguments) throws -> AppStoreConnectSubscriptionListInput {
        guard let groupID = parsed.firstOption(["group", "group-id", "subscription-group-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --group or --group-id.")
        }
        return AppStoreConnectSubscriptionListInput(
            groupID: groupID,
            productIDs: parsed.commaSeparatedOptions(["product-id", "product"]),
            names: parsed.commaSeparatedOption("name"),
            states: parsed.commaSeparatedOptions(["state", "subscription-state"]).map(normalizedASCEnum),
            sort: parsed.option("sort"),
            limit: parsed.intOption("limit")
        )
    }

    private static func subscriptionViewInput(from parsed: ParsedArguments) throws -> AppStoreConnectSubscriptionViewInput {
        guard let id = parsed.firstOption(["id", "subscription-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --subscription-id.")
        }
        return AppStoreConnectSubscriptionViewInput(id: id)
    }

    private static func subscriptionCreateInput(from parsed: ParsedArguments) throws -> AppStoreConnectSubscriptionCreateInput {
        guard let groupID = parsed.firstOption(["group", "group-id", "subscription-group-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --group or --group-id.")
        }
        guard let name = parsed.option("name") else {
            throw CLIError(exitCode: 64, message: "Missing required option --name.")
        }
        guard let productID = parsed.firstOption(["product-id", "product"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --product-id.")
        }
        return AppStoreConnectSubscriptionCreateInput(
            groupID: groupID,
            name: name,
            productID: productID,
            subscriptionPeriod: parsed.firstOption(["period", "subscription-period"]).map(normalizedASCEnum),
            groupLevel: parsed.intOption("group-level"),
            familySharable: try boolOption(from: parsed, names: ["family-sharable"]),
            reviewNote: parsed.firstOption(["review-note", "notes"])
        )
    }

    private static func subscriptionUpdateInput(from parsed: ParsedArguments) throws -> AppStoreConnectSubscriptionUpdateInput {
        guard let id = parsed.firstOption(["id", "subscription-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --subscription-id.")
        }
        let input = AppStoreConnectSubscriptionUpdateInput(
            id: id,
            name: parsed.option("name"),
            subscriptionPeriod: parsed.firstOption(["period", "subscription-period"]).map(normalizedASCEnum),
            groupLevel: parsed.intOption("group-level"),
            familySharable: try boolOption(from: parsed, names: ["family-sharable"]),
            reviewNote: parsed.firstOption(["review-note", "notes"])
        )
        guard input.name != nil
            || input.subscriptionPeriod != nil
            || input.groupLevel != nil
            || input.familySharable != nil
            || input.reviewNote != nil else {
            throw CLIError(exitCode: 64, message: "Specify at least one subscription update field.")
        }
        return input
    }

    private static func subscriptionDeleteInput(from parsed: ParsedArguments) throws -> AppStoreConnectSubscriptionDeleteInput {
        guard let id = parsed.firstOption(["id", "subscription-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --subscription-id.")
        }
        return AppStoreConnectSubscriptionDeleteInput(id: id)
    }

    private static func subscriptionSubmitInput(from parsed: ParsedArguments) throws -> AppStoreConnectSubscriptionSubmitInput {
        guard let id = parsed.firstOption(["id", "subscription-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --subscription-id.")
        }
        return AppStoreConnectSubscriptionSubmitInput(id: id)
    }

    private static func subscriptionLocalizationListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectSubscriptionLocalizationListInput {
        guard let id = parsed.firstOption(["subscription", "subscription-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --subscription or --subscription-id.")
        }
        return AppStoreConnectSubscriptionLocalizationListInput(
            subscriptionID: id,
            limit: parsed.intOption("limit")
        )
    }

    private static func subscriptionLocalizationCreateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectSubscriptionLocalizationCreateInput {
        guard let id = parsed.firstOption(["subscription", "subscription-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --subscription or --subscription-id.")
        }
        guard let locale = parsed.option("locale") else {
            throw CLIError(exitCode: 64, message: "Missing required option --locale.")
        }
        guard let name = parsed.option("name") else {
            throw CLIError(exitCode: 64, message: "Missing required option --name.")
        }
        return AppStoreConnectSubscriptionLocalizationCreateInput(
            subscriptionID: id,
            locale: locale,
            name: name,
            description: parsed.option("description")
        )
    }

    private static func subscriptionLocalizationUpdateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectSubscriptionLocalizationUpdateInput {
        guard let id = parsed.firstOption(["id", "localization-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --localization-id.")
        }
        let input = AppStoreConnectSubscriptionLocalizationUpdateInput(
            id: id,
            name: parsed.option("name"),
            description: parsed.option("description")
        )
        guard input.name != nil || input.description != nil else {
            throw CLIError(exitCode: 64, message: "Specify at least one subscription localization update field.")
        }
        return input
    }

    private static func localizationID(from parsed: ParsedArguments) throws -> String {
        guard let id = parsed.firstOption(["id", "localization-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --localization-id.")
        }
        return id
    }

    private static func localizationViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectInAppPurchaseLocalizationViewInput {
        AppStoreConnectInAppPurchaseLocalizationViewInput(id: try localizationID(from: parsed))
    }

    private static func localizationDeleteInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectInAppPurchaseLocalizationDeleteInput {
        AppStoreConnectInAppPurchaseLocalizationDeleteInput(id: try localizationID(from: parsed))
    }

    private static func winBackOfferListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectWinBackOfferListInput {
        guard let subscriptionID = parsed.firstOption(["subscription", "subscription-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --subscription or --subscription-id.")
        }
        return AppStoreConnectWinBackOfferListInput(
            subscriptionID: subscriptionID,
            limit: parsed.intOption("limit")
        )
    }

    private static func winBackOfferViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectWinBackOfferViewInput {
        AppStoreConnectWinBackOfferViewInput(id: try winBackOfferID(from: parsed))
    }

    private static func winBackOfferCreateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectWinBackOfferCreateInput {
        guard let subscriptionID = parsed.firstOption(["subscription", "subscription-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --subscription or --subscription-id.")
        }
        guard let referenceName = parsed.firstOption(["reference-name", "name"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --reference-name or --name.")
        }
        guard let offerID = parsed.firstOption(["offer-id", "offer"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --offer-id or --offer.")
        }
        guard let duration = parsed.option("duration") else {
            throw CLIError(exitCode: 64, message: "Missing required option --duration.")
        }
        guard let offerMode = parsed.firstOption(["offer-mode", "mode"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --offer-mode or --mode.")
        }
        guard let periodCount = parsed.intOption("period-count") else {
            throw CLIError(exitCode: 64, message: "Missing required option --period-count.")
        }
        guard let paidMonths = parsed.intOption("paid-subscription-months") else {
            throw CLIError(exitCode: 64, message: "Missing required option --paid-subscription-months.")
        }
        guard let lastMin = parsed.intOption("last-subscribed-min-months") else {
            throw CLIError(exitCode: 64, message: "Missing required option --last-subscribed-min-months.")
        }
        guard let lastMax = parsed.intOption("last-subscribed-max-months") else {
            throw CLIError(exitCode: 64, message: "Missing required option --last-subscribed-max-months.")
        }
        guard let startDate = try dateStringOption(from: parsed, names: ["start-date"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --start-date.")
        }
        guard let priority = parsed.option("priority") else {
            throw CLIError(exitCode: 64, message: "Missing required option --priority.")
        }
        let priceIDs = parsed.commaSeparatedOptions(["price", "price-id", "prices", "price-ids"])
        guard !priceIDs.isEmpty else {
            throw CLIError(exitCode: 64, message: "Missing required option --price or --price-id.")
        }
        return AppStoreConnectWinBackOfferCreateInput(
            subscriptionID: subscriptionID,
            referenceName: referenceName,
            offerID: offerID,
            duration: normalizedASCEnum(duration),
            offerMode: normalizedASCEnum(offerMode),
            periodCount: periodCount,
            paidSubscriptionDurationMonths: paidMonths,
            lastSubscribedMinMonths: lastMin,
            lastSubscribedMaxMonths: lastMax,
            waitBetweenOffersMonths: parsed.intOption("wait-between-offers-months"),
            startDate: startDate,
            endDate: try dateStringOption(from: parsed, names: ["end-date"]),
            priority: normalizedASCEnum(priority),
            promotionIntent: parsed.option("promotion-intent").map(normalizedASCEnum),
            priceIDs: priceIDs
        )
    }

    private static func winBackOfferUpdateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectWinBackOfferUpdateInput {
        let input = AppStoreConnectWinBackOfferUpdateInput(
            id: try winBackOfferID(from: parsed),
            paidSubscriptionDurationMonths: parsed.intOption("paid-subscription-months"),
            lastSubscribedMinMonths: parsed.intOption("last-subscribed-min-months"),
            lastSubscribedMaxMonths: parsed.intOption("last-subscribed-max-months"),
            waitBetweenOffersMonths: parsed.intOption("wait-between-offers-months"),
            startDate: try dateStringOption(from: parsed, names: ["start-date"]),
            endDate: try dateStringOption(from: parsed, names: ["end-date"]),
            priority: parsed.option("priority").map(normalizedASCEnum),
            promotionIntent: parsed.option("promotion-intent").map(normalizedASCEnum)
        )
        guard input.paidSubscriptionDurationMonths != nil
            || input.lastSubscribedMinMonths != nil
            || input.lastSubscribedMaxMonths != nil
            || input.waitBetweenOffersMonths != nil
            || input.startDate != nil
            || input.endDate != nil
            || input.priority != nil
            || input.promotionIntent != nil
        else {
            throw CLIError(exitCode: 64, message: "Specify at least one win-back offer update field.")
        }
        return input
    }

    private static func winBackOfferDeleteInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectWinBackOfferDeleteInput {
        AppStoreConnectWinBackOfferDeleteInput(id: try winBackOfferID(from: parsed))
    }

    private static func winBackOfferID(from parsed: ParsedArguments) throws -> String {
        guard let id = parsed.firstOption(["id", "win-back-offer-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --win-back-offer-id.")
        }
        return id
    }

    private static func appPricePointListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppPricePointListInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        return AppStoreConnectAppPricePointListInput(
            appID: appID,
            territories: parsed.commaSeparatedOptions(["territory", "territory-id"]),
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            territoryFields: parsed.commaSeparatedOptions(["territory-field", "territory-fields"]),
            includeApp: parsed.hasFlag("include-app"),
            includeTerritory: parsed.hasFlag("include-territory"),
            limit: parsed.intOption("limit")
        )
    }

    private static func appPriceScheduleCurrentInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAppPriceScheduleCurrentInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        return AppStoreConnectAppPriceScheduleCurrentInput(
            appID: appID,
            fields: parsed.commaSeparatedOptions(["field", "fields"]),
            priceFields: parsed.commaSeparatedOptions(["price-field", "price-fields"]),
            territoryFields: parsed.commaSeparatedOptions(["territory-field", "territory-fields"]),
            includeApp: parsed.hasFlag("include-app"),
            includeBaseTerritory: parsed.hasFlag("include-base-territory"),
            includeManualPrices: parsed.hasFlag("include-manual-prices"),
            includeAutomaticPrices: parsed.hasFlag("include-automatic-prices"),
            manualPricesLimit: parsed.intOption("manual-prices-limit"),
            automaticPricesLimit: parsed.intOption("automatic-prices-limit")
        )
    }

    private static func normalizedASCEnum(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "-", with: "_")
            .uppercased()
    }

    private static func normalizedInAppPurchaseInclude(_ value: String) -> String {
        switch value.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "_", with: "-")
            .lowercased()
        {
        case "localizations", "localization", "in-app-purchase-localizations":
            return "inAppPurchaseLocalizations"
        case "review-screenshot", "app-store-review-screenshot":
            return "appStoreReviewScreenshot"
        case "promoted-purchase":
            return "promotedPurchase"
        case "price-schedule", "iap-price-schedule":
            return "iapPriceSchedule"
        case "availability", "in-app-purchase-availability":
            return "inAppPurchaseAvailability"
        case "offer-codes", "offer-code":
            return "offerCodes"
        default:
            return value
        }
    }

    private static func normalizedPromotedPurchaseInclude(_ value: String) -> String {
        switch value.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "_", with: "-")
            .lowercased()
        {
        case "iap", "in-app-purchase", "in-app-purchase-v2":
            return "inAppPurchaseV2"
        default:
            return value
        }
    }
#endif

    private static func analyticsReportViewInput(from parsed: ParsedArguments) throws -> AppStoreConnectAnalyticsReportViewInput {
        guard let id = parsed.firstOption(["id", "report-id", "analytics-report-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --report-id.")
        }
        return AppStoreConnectAnalyticsReportViewInput(id: id)
    }

    private static func analyticsReportRequestCreateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAnalyticsReportRequestCreateInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        return AppStoreConnectAnalyticsReportRequestCreateInput(
            appID: appID,
            accessType: normalizedPublicAPIEnum(parsed.firstOption(["access-type", "type"]) ?? "ONE_TIME_SNAPSHOT")
        )
    }

    private static func analyticsReportRequestViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAnalyticsReportRequestViewInput {
        guard let id = parsed.firstOption(["id", "request-id", "analytics-report-request-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --request-id.")
        }
        return AppStoreConnectAnalyticsReportRequestViewInput(
            id: id,
            includeReports: !parsed.hasFlag("no-include-reports"),
            reportLimit: parsed.intOption("limit")
        )
    }

    private static func analyticsReportRequestDeleteInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAnalyticsReportRequestDeleteInput {
        guard let id = parsed.firstOption(["id", "request-id", "analytics-report-request-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --request-id.")
        }
        return AppStoreConnectAnalyticsReportRequestDeleteInput(id: id)
    }

    private static func analyticsReportSegmentViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAnalyticsReportSegmentViewInput {
        guard let id = parsed.firstOption(["id", "segment-id", "analytics-report-segment-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --segment-id.")
        }
        return AppStoreConnectAnalyticsReportSegmentViewInput(id: id)
    }

    private static func analyticsReportInstanceViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectAnalyticsReportInstanceViewInput {
        guard let id = parsed.firstOption(["id", "instance-id", "analytics-report-instance-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --instance-id.")
        }
        return AppStoreConnectAnalyticsReportInstanceViewInput(id: id)
    }

    private static func financeReportDownloadInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectFinanceReportDownloadInput {
        guard let vendorNumber = parsed.firstOption(["vendor-number", "vendor"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --vendor-number.")
        }
        guard let regionCode = parsed.firstOption(["region-code", "region"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --region-code or --region.")
        }
        guard let reportDate = parsed.firstOption(["report-date", "date"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --report-date or --date.")
        }
        return AppStoreConnectFinanceReportDownloadInput(
            vendorNumber: vendorNumber,
            reportType: normalizedPublicAPIEnum(parsed.firstOption(["report-type", "type"]) ?? "FINANCIAL"),
            regionCode: regionCode.uppercased(),
            reportDate: reportDate,
            outputPath: parsed.firstOption(["output-path", "output", "file", "path"])
        )
    }

    private static func salesReportDownloadInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectSalesReportDownloadInput {
        guard let vendorNumber = parsed.firstOption(["vendor-number", "vendor"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --vendor-number.")
        }
        return AppStoreConnectSalesReportDownloadInput(
            vendorNumber: vendorNumber,
            reportType: normalizedPublicAPIEnum(parsed.firstOption(["report-type", "type"]) ?? "SALES"),
            reportSubType: normalizedPublicAPIEnum(parsed.firstOption(["report-sub-type", "subtype", "sub-type"]) ?? "SUMMARY"),
            frequency: normalizedPublicAPIEnum(parsed.firstOption(["frequency"]) ?? "DAILY"),
            reportDate: parsed.firstOption(["report-date", "date"]),
            version: parsed.option("version"),
            outputPath: parsed.firstOption(["output-path", "output", "file", "path"])
        )
    }

#if ASC_PUBLIC_API_REPORTS
    private static func performanceMetricsInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectPerformanceMetricsInput {
        let appID = parsed.firstOption(["app", "app-id"])
        let buildID = parsed.firstOption(["build", "build-id"])
        guard (appID == nil) != (buildID == nil) else {
            throw CLIError(exitCode: 64, message: "Specify exactly one of --app or --build.")
        }
        return AppStoreConnectPerformanceMetricsInput(
            appID: appID,
            buildID: buildID,
            platform: parsed.option("platform").map(normalizedPublicAPIEnum),
            metricType: parsed.firstOption(["metric-type", "metric"]).map(normalizedPublicAPIEnum),
            deviceTypes: parsed.commaSeparatedOptions(["device-type", "device"]),
            outputPath: parsed.firstOption(["output-path", "output", "file", "path"])
        )
    }
#endif

#if ASC_PUBLIC_API_RELEASE
    private static func customerReviewListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectCustomerReviewListInput {
        let appID = parsed.firstOption(["app", "app-id"])
        let versionID = parsed.firstOption(["version", "version-id", "app-store-version", "app-store-version-id"])
        guard appID != nil || versionID != nil else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --version.")
        }
        return AppStoreConnectCustomerReviewListInput(
            appID: appID,
            appStoreVersionID: versionID,
            territories: parsed.commaSeparatedOptions(["territory", "territory-id", "territories"]).map { $0.uppercased() },
            ratings: parsed.commaSeparatedOptions(["rating", "ratings"]),
            responseExists: try boolOption(from: parsed, names: ["response-exists", "has-response", "published-response"]),
            sort: parsed.commaSeparatedOption("sort"),
            includeResponse: parsed.hasFlag("include-response"),
            limit: parsed.intOption("limit")
        )
    }

    private static func customerReviewViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectCustomerReviewViewInput {
        guard let id = parsed.firstOption(["id", "review-id", "customer-review-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --review-id.")
        }
        return AppStoreConnectCustomerReviewViewInput(
            id: id,
            includeResponse: parsed.hasFlag("include-response")
        )
    }

    private static func customerReviewSummarizationListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectCustomerReviewSummarizationListInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        let platforms = parsed.commaSeparatedOptions(["platform", "platforms"]).map(normalizedPublicAPIEnum)
        guard !platforms.isEmpty else {
            throw CLIError(exitCode: 64, message: "Missing required option --platform.")
        }
        return AppStoreConnectCustomerReviewSummarizationListInput(
            appID: appID,
            platforms: platforms,
            territories: parsed.commaSeparatedOptions(["territory", "territory-id", "territories"]).map { $0.uppercased() },
            includeTerritory: parsed.hasFlag("include-territory"),
            limit: parsed.intOption("limit")
        )
    }

    private static func customerReviewResponseViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectCustomerReviewResponseViewInput {
        guard let id = parsed.firstOption(["id", "response-id", "review-response-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --response-id.")
        }
        return AppStoreConnectCustomerReviewResponseViewInput(id: id)
    }

    private static func customerReviewResponseForReviewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectCustomerReviewResponseForReviewInput {
        guard let reviewID = parsed.firstOption(["review", "review-id", "customer-review-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --review or --review-id.")
        }
        return AppStoreConnectCustomerReviewResponseForReviewInput(reviewID: reviewID)
    }

    private static func customerReviewResponseCreateInput(
        from parsed: ParsedArguments,
        currentDirectory: URL
    ) throws -> AppStoreConnectCustomerReviewResponseCreateInput {
        guard let reviewID = parsed.firstOption(["review", "review-id", "customer-review-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --review or --review-id.")
        }
        return AppStoreConnectCustomerReviewResponseCreateInput(
            reviewID: reviewID,
            responseBody: try customerReviewResponseBody(from: parsed, currentDirectory: currentDirectory)
        )
    }

    private static func customerReviewResponseDeleteInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectCustomerReviewResponseDeleteInput {
        guard let id = parsed.firstOption(["id", "response-id", "review-response-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --response-id.")
        }
        return AppStoreConnectCustomerReviewResponseDeleteInput(id: id)
    }

    private static func customerReviewResponseBody(
        from parsed: ParsedArguments,
        currentDirectory: URL
    ) throws -> String {
        if let body = parsed.firstOption(["body", "response-body", "text"]) {
            return body
        }

        guard let path = parsed.firstOption(["body-path", "response-body-path", "text-path"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --body or --body-path.")
        }

        let url = URL(fileURLWithPath: path, relativeTo: currentDirectory).standardizedFileURL
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            throw CLIError(exitCode: 1, message: "Could not read review response body at \(url.path): \(error).")
        }
    }
#endif

    private static func normalizedPublicAPIEnum(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "-", with: "_")
            .uppercased()
    }

    private static func reviewSubmissionListInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectReviewSubmissionListInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }

        return AppStoreConnectReviewSubmissionListInput(
            appID: appID,
            platforms: parsed.commaSeparatedOption("platform").map { $0.uppercased() },
            states: parsed.commaSeparatedOptions(["review-state", "state"]).map { $0.uppercased() },
            limit: parsed.intOption("limit")
        )
    }

    private static func reviewSubmissionViewInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectReviewSubmissionViewInput {
        guard let id = parsed.firstOption(["id", "review-submission-id", "submission-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --review-submission-id.")
        }
        return AppStoreConnectReviewSubmissionViewInput(id: id)
    }

    private static func reviewSubmissionCreateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectReviewSubmissionCreateInput {
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }
        return AppStoreConnectReviewSubmissionCreateInput(
            appID: appID,
            platform: parsed.option("platform").map { $0.uppercased() }
        )
    }

    private static func reviewSubmissionUpdateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectReviewSubmissionUpdateInput {
        guard let id = parsed.firstOption(["id", "review-submission-id", "submission-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --review-submission-id.")
        }
        let input = AppStoreConnectReviewSubmissionUpdateInput(
            id: id,
            submitted: try boolOption(from: parsed, names: ["submitted"]),
            canceled: try boolOption(from: parsed, names: ["canceled", "cancelled"]),
            platform: parsed.option("platform").map { $0.uppercased() }
        )
        guard input.submitted != nil || input.canceled != nil || input.platform != nil else {
            throw CLIError(exitCode: 64, message: "Specify at least one review submission update field.")
        }
        return input
    }

    private static func reviewSubmissionSubmitInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectReviewSubmissionUpdateInput {
        guard let id = parsed.firstOption(["id", "review-submission-id", "submission-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --review-submission-id.")
        }
        return AppStoreConnectReviewSubmissionUpdateInput(id: id, submitted: true)
    }

    private static func reviewSubmissionCancelInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectReviewSubmissionUpdateInput {
        guard let id = parsed.firstOption(["id", "review-submission-id", "submission-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --review-submission-id.")
        }
        return AppStoreConnectReviewSubmissionUpdateInput(id: id, canceled: true)
    }

    private static func reviewSubmissionItemCreateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectReviewSubmissionItemCreateInput {
        guard let submissionID = parsed.firstOption(["review-submission", "review-submission-id", "submission-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --review-submission-id.")
        }
        guard let versionID = parsed.firstOption(["version", "version-id", "app-store-version-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --version-id.")
        }
        return AppStoreConnectReviewSubmissionItemCreateInput(
            reviewSubmissionID: submissionID,
            appStoreVersionID: versionID
        )
    }

    private static func reviewSubmissionItemUpdateInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectReviewSubmissionItemUpdateInput {
        guard let id = parsed.firstOption(["id", "item-id", "review-submission-item-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --item-id.")
        }
        let input = AppStoreConnectReviewSubmissionItemUpdateInput(
            id: id,
            removed: try boolOption(from: parsed, names: ["removed"]),
            resolved: try boolOption(from: parsed, names: ["resolved"])
        )
        guard input.removed != nil || input.resolved != nil else {
            throw CLIError(exitCode: 64, message: "Specify at least one review submission item update field.")
        }
        return input
    }

    private static func reviewSubmissionItemDeleteInput(
        from parsed: ParsedArguments
    ) throws -> AppStoreConnectReviewSubmissionItemDeleteInput {
        guard let id = parsed.firstOption(["id", "item-id", "review-submission-item-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --id or --item-id.")
        }
        return AppStoreConnectReviewSubmissionItemDeleteInput(id: id)
    }

    private static func statusInput(from parsed: ParsedArguments) throws -> AppStoreConnectStatusInput {
        if parsed.hasFlag("watch") || parsed.option("watch-interval") != nil {
            throw CLIError(exitCode: 64, message: "status watch mode is not implemented yet; run a snapshot status query instead.")
        }
        guard let appID = parsed.firstOption(["app", "app-id"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app or --app-id.")
        }

        return AppStoreConnectStatusInput(
            appID: appID,
            appStoreVersionID: parsed.firstOption(["version-id", "app-store-version-id"]),
            reviewSubmissionID: parsed.firstOption(["review-submission-id", "submission-id"]),
            platforms: parsed.commaSeparatedOption("platform").map { $0.uppercased() },
            reviewStates: parsed.commaSeparatedOptions(["review-state", "state"]).map { $0.uppercased() },
            limit: parsed.intOption("limit")
        )
    }

    private static func publicReleaseReadinessInput(
        from parsed: ParsedArguments
    ) throws -> PublicReleaseReadinessInput {
        guard let appID = parsed.firstOption(["app-id", "app"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --app-id or --app.")
        }

        return PublicReleaseReadinessInput(
            appID: appID,
            appStoreVersionID: parsed.firstOption(["app-store-version-id", "version-id"]),
            screenshotSetID: parsed.firstOption(["screenshot-set-id", "screenshot-set"]),
            includeBuilds: !parsed.hasFlag("skip-builds"),
            includeTestFlightGroups: !parsed.hasFlag("skip-testflight-groups")
        )
    }

    private static func workflowFileRunnerResult(
        parsed: ParsedArguments,
        currentDirectory: URL
    ) throws -> WorkflowFileDryRunResult {
        let file = try workflowFile(parsed: parsed, currentDirectory: currentDirectory)
        return try WorkflowFileRunner().dryRun(file)
    }

    private static func workflowFile(
        parsed: ParsedArguments,
        currentDirectory: URL
    ) throws -> WorkflowFile {
        let path = parsed.firstOption(["path", "file"]) ?? ".asc/workflow.json"
        let url = URL(fileURLWithPath: path, relativeTo: currentDirectory).standardizedFileURL
        return try WorkflowFileRunner().load(from: url)
    }

    private static func csrContent(
        from parsed: ParsedArguments,
        currentDirectory: URL
    ) throws -> String {
        if let content = parsed.option("csr-content") {
            return content
        }

        guard let path = parsed.firstOption(["csr-path", "csr-file", "csr"]) else {
            throw CLIError(exitCode: 64, message: "Missing required option --csr-content or --csr-path.")
        }

        let url = URL(fileURLWithPath: path, relativeTo: currentDirectory).standardizedFileURL
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            throw CLIError(exitCode: 1, message: "Could not read CSR at \(url.path): \(error).")
        }
    }

    private static func bundleIDCapabilitySettingsJSON(
        from parsed: ParsedArguments,
        currentDirectory: URL
    ) throws -> String? {
        if let settings = parsed.firstOption(["settings-json", "settings"]) {
            return settings
        }

        guard let path = parsed.firstOption(["settings-path", "settings-file"]) else {
            return nil
        }

        let url = URL(fileURLWithPath: path, relativeTo: currentDirectory).standardizedFileURL
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            throw CLIError(exitCode: 1, message: "Could not read bundle ID capability settings at \(url.path): \(error).")
        }
    }

    private static func schemaInfo(currentDirectory: URL) throws -> AppStoreConnectSchemaInfo {
        let root = try packageRoot(startingAt: currentDirectory)
        let officialRelativePath = "Vendor/AppStoreConnectOpenAPI/schema/app-store-connect-openapi.json"
        let selectedRelativePath = "Sources/AppStoreConnectPublicAPI/openapi.json"
        let auditRelativePath = "Vendor/AppStoreConnectOpenAPI/schema-audit.json"
        let lockRelativePath = "Vendor/AppStoreConnectOpenAPI/spec.lock.json"
        let generationRelativePath = "Sources/AppStoreConnectPublicAPI/openapi-generation.json"
        let partitionRelativePath = "Vendor/AppStoreConnectOpenAPI/partitions/public-api-traits.json"

        let audit = try loadJSONDictionary(root.appendingPathComponent(auditRelativePath))
        let lock = try loadJSONDictionary(root.appendingPathComponent(lockRelativePath))
        let generation = try loadJSONDictionary(root.appendingPathComponent(generationRelativePath))
        let partition = try loadJSONDictionary(root.appendingPathComponent(partitionRelativePath))

        let official = try schemaDocumentSummary(
            url: root.appendingPathComponent(officialRelativePath),
            relativePath: officialRelativePath,
            sha256: stringValue(audit, ["schema", "sha256"]) ?? stringValue(lock, ["schema", "sha256"])
        )
        let selected = try schemaDocumentSummary(
            url: root.appendingPathComponent(selectedRelativePath),
            relativePath: selectedRelativePath,
            sha256: nil
        )

        return AppStoreConnectSchemaInfo(
            official: official,
            selected: selected,
            source: .init(
                checkedAt: stringValue(lock, ["source", "checkedAt"]),
                httpLastModified: stringValue(lock, ["source", "httpLastModified"]),
                archiveSHA256: stringValue(lock, ["archive", "sha256"]),
                normalization: stringValue(lock, ["normalization", "contentChanges"])
            ),
            generation: .init(
                mode: stringValue(generation, ["mode"]) ?? "appleTypedUnion",
                defaultTraits: stringArrayValue(generation, ["defaultTraits"]),
                fullTrait: stringValue(generation, ["fullTrait"]),
                activeTraitSource: stringValue(generation, ["activeTraitSource"]),
                traitNames: traitNames(partition)
            )
        )
    }

    private static func schemaPathInfo(currentDirectory: URL) throws -> AppStoreConnectSchemaPathInfo {
        let root = try packageRoot(startingAt: currentDirectory)
        return AppStoreConnectSchemaPathInfo(
            officialSchema: root.appendingPathComponent("Vendor/AppStoreConnectOpenAPI/schema/app-store-connect-openapi.json").path,
            selectedSchema: root.appendingPathComponent("Sources/AppStoreConnectPublicAPI/openapi.json").path,
            specLock: root.appendingPathComponent("Vendor/AppStoreConnectOpenAPI/spec.lock.json").path,
            schemaAudit: root.appendingPathComponent("Vendor/AppStoreConnectOpenAPI/schema-audit.json").path,
            traitManifest: root.appendingPathComponent("Vendor/AppStoreConnectOpenAPI/partitions/public-api-traits.json").path
        )
    }

    private static func completionShell(from parsed: ParsedArguments) throws -> String {
        let shell = parsed.commands.dropFirst().first
            ?? parsed.firstOption(["shell", "type"])
            ?? "zsh"
        let normalized = shell.lowercased()
        guard ["bash", "fish", "zsh"].contains(normalized) else {
            throw CLIError(exitCode: 64, message: "Unsupported completion shell: \(shell). Use bash, fish, or zsh.")
        }
        return normalized
    }

    private static func completionScript(for shell: String) -> String {
        let commands = AppStoreConnectCLICommandRegistry.descriptors.map(\.command).sorted()
        switch shell {
        case "bash":
            let words = Set(commands.flatMap { $0.split(separator: " ").map(String.init) }).sorted().joined(separator: " ")
            return """
            _appstoreconnect_completions() {
                local current="${COMP_WORDS[COMP_CWORD]}"
                COMPREPLY=($(compgen -W "\(words)" -- "$current"))
            }
            complete -F _appstoreconnect_completions appstoreconnect
            """
        case "fish":
            return commands.map { command in
                "complete -c appstoreconnect -f -a \(shellSingleQuoted(command))"
            }.joined(separator: "\n") + "\n"
        default:
            let entries = commands.map { command in
                "  \(shellSingleQuoted(command + ":" + "command"))"
            }.joined(separator: "\n")
            return """
            #compdef appstoreconnect
            _appstoreconnect() {
                local -a commands
                commands=(
            \(entries)
                )
                _describe 'command' commands
            }
            _appstoreconnect "$@"
            """
        }
    }

    private static func shellSingleQuoted(_ value: String) -> String {
        "'\(value.replacingOccurrences(of: "'", with: "'\\''"))'"
    }

    private static func packageRoot(startingAt currentDirectory: URL) throws -> URL {
        var candidate = currentDirectory.standardizedFileURL
        for _ in 0..<12 {
            let packageFile = candidate.appendingPathComponent("Package.swift")
            let schemaFile = candidate.appendingPathComponent("Vendor/AppStoreConnectOpenAPI/schema/app-store-connect-openapi.json")
            if FileManager.default.fileExists(atPath: packageFile.path),
               FileManager.default.fileExists(atPath: schemaFile.path) {
                return candidate
            }
            let parent = candidate.deletingLastPathComponent()
            if parent.path == candidate.path {
                break
            }
            candidate = parent
        }
        throw CLIError(exitCode: 1, message: "Could not locate package root containing Vendor/AppStoreConnectOpenAPI.")
    }

    private static func schemaDocumentSummary(
        url: URL,
        relativePath: String,
        sha256: String?
    ) throws -> AppStoreConnectSchemaDocumentSummary {
        let root = try loadJSONDictionary(url)
        let inventory = schemaInventory(root)
        return AppStoreConnectSchemaDocumentSummary(
            path: relativePath,
            sha256: sha256,
            openapi: stringValue(root, ["openapi"]) ?? "unknown",
            title: stringValue(root, ["info", "title"]) ?? "unknown",
            version: stringValue(root, ["info", "version"]) ?? "unknown",
            pathCount: inventory.pathCount,
            operationCount: inventory.operationCount,
            schemaCount: inventory.schemaCount
        )
    }

    private static func schemaInventory(_ root: [String: Any]) -> AppStoreConnectSchemaInventory {
        let paths = root["paths"] as? [String: Any] ?? [:]
        let schemas = (root["components"] as? [String: Any])?["schemas"] as? [String: Any] ?? [:]
        let methods: Set<String> = ["delete", "get", "patch", "post", "put"]
        let operationCount = paths.values.reduce(0) { count, value in
            guard let operations = value as? [String: Any] else {
                return count
            }
            return count + operations.keys.filter { methods.contains($0.lowercased()) }.count
        }
        return AppStoreConnectSchemaInventory(
            pathCount: paths.count,
            operationCount: operationCount,
            schemaCount: schemas.count
        )
    }

    private static func loadJSONDictionary(_ url: URL) throws -> [String: Any] {
        let data = try Data(contentsOf: url)
        guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw CLIError(exitCode: 1, message: "Expected JSON object at \(url.path).")
        }
        return dictionary
    }

    private static func stringValue(_ root: [String: Any], _ path: [String]) -> String? {
        var current: Any = root
        for key in path {
            guard let dictionary = current as? [String: Any], let value = dictionary[key] else {
                return nil
            }
            current = value
        }
        return current as? String
    }

    private static func stringArrayValue(_ root: [String: Any], _ path: [String]) -> [String] {
        var current: Any = root
        for key in path {
            guard let dictionary = current as? [String: Any], let value = dictionary[key] else {
                return []
            }
            current = value
        }
        return current as? [String] ?? []
    }

    private static func traitNames(_ root: [String: Any]) -> [String] {
        guard let traits = root["traits"] as? [[String: Any]] else {
            return []
        }
        return traits.compactMap { $0["name"] as? String }
    }

    private static func render<T: Encodable>(
        _ value: T,
        json: Bool,
        exitCode: Int32 = 0
    ) throws -> AppStoreConnectCLIResult {
        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(value)
            return AppStoreConnectCLIResult(
                exitCode: exitCode,
                stdout: String(decoding: data, as: UTF8.self) + "\n"
            )
        }

        if let workflows = value as? [String] {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: workflows.joined(separator: "\n") + "\n")
        }

        if let descriptors = value as? [AppStoreConnectCLICommandDescriptor] {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderCommandDescriptors(descriptors))
        }

        if let schema = value as? AppStoreConnectSchemaInfo {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderSchemaInfo(schema))
        }

        if let paths = value as? AppStoreConnectSchemaPathInfo {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderSchemaPathInfo(paths))
        }

        if let auth = value as? AppStoreConnectAuthStatusResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAuthStatus(auth))
        }

        if let doctor = value as? AppStoreConnectAuthDoctorResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAuthDoctor(doctor))
        }

        if let plan = value as? AppStoreConnectAuthLogoutPlan {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAuthLogoutPlan(plan))
        }

        if let logout = value as? AppStoreConnectAuthLogoutResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAuthLogout(logout))
        }

        if let plan = value as? AppStoreConnectXcodeToolPlan {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderXcodeToolPlan(plan))
        }

        if let result = value as? AppStoreConnectXcodeToolRunResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderXcodeToolRunResult(result))
        }

        if let apps = value as? AppStoreConnectAppListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderApps(apps.data))
        }

        if let app = value as? AppStoreConnectAppResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderApp(app.data))
        }

#if ASC_PUBLIC_API_RELEASE
        if let categories = value as? AppStoreConnectAppCategoryListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAppCategories(categories.data))
        }

        if let category = value as? AppStoreConnectAppCategoryResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAppCategory(category.data))
        }

        if let assignment = value as? AppStoreConnectAppCategoryAssignmentResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAppCategoryAssignment(assignment.data))
        }

        if let ageRating = value as? AppStoreConnectAgeRatingResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAgeRating(ageRating.data))
        }

        if let events = value as? AppStoreConnectAppEventListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAppEvents(events.data))
        }

        if let event = value as? AppStoreConnectAppEventResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAppEvent(event.data))
        }

        if let event = value as? AppStoreConnectAppEventMutationResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAppEvent(event.data))
        }
#endif

#if ASC_PUBLIC_API_METADATA_MEDIA
        if let appClips = value as? AppStoreConnectAppClipListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAppClips(appClips.data))
        }

        if let appClip = value as? AppStoreConnectAppClipResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAppClip(appClip.data))
        }

        if let experiences = value as? AppStoreConnectAppClipDefaultExperienceListResult {
            return AppStoreConnectCLIResult(
                exitCode: exitCode,
                stdout: renderAppClipDefaultExperiences(experiences.data)
            )
        }

        if let experience = value as? AppStoreConnectAppClipDefaultExperienceResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAppClipDefaultExperience(experience.data))
        }

        if let localizations = value as? AppStoreConnectAppClipLocalizationListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAppClipLocalizations(localizations.data))
        }

        if let localization = value as? AppStoreConnectAppClipLocalizationResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAppClipLocalization(localization.data))
        }
#endif

#if ASC_PUBLIC_API_GAME_CENTER
        if let detail = value as? AppStoreConnectGameCenterDetailResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderGameCenterDetail(detail.data))
        }

        if let achievements = value as? AppStoreConnectGameCenterAchievementListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderGameCenterAchievements(achievements.data))
        }

        if let achievement = value as? AppStoreConnectGameCenterAchievementResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderGameCenterAchievement(achievement.data))
        }

        if let leaderboards = value as? AppStoreConnectGameCenterLeaderboardListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderGameCenterLeaderboards(leaderboards.data))
        }

        if let leaderboard = value as? AppStoreConnectGameCenterLeaderboardResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderGameCenterLeaderboard(leaderboard.data))
        }

        if let leaderboardSets = value as? AppStoreConnectGameCenterLeaderboardSetListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderGameCenterLeaderboardSets(leaderboardSets.data))
        }

        if let leaderboardSet = value as? AppStoreConnectGameCenterLeaderboardSetResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderGameCenterLeaderboardSet(leaderboardSet.data))
        }

        if let challenges = value as? AppStoreConnectGameCenterChallengeListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderGameCenterChallenges(challenges.data))
        }

        if let challenge = value as? AppStoreConnectGameCenterChallengeResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderGameCenterChallenge(challenge.data))
        }
#endif

#if ASC_PUBLIC_API_DISTRIBUTION
        if let domains = value as? AppStoreConnectAlternativeDistributionDomainListResult {
            return AppStoreConnectCLIResult(
                exitCode: exitCode,
                stdout: renderAlternativeDistributionDomains(domains.data)
            )
        }

        if let domain = value as? AppStoreConnectAlternativeDistributionDomainResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAlternativeDistributionDomain(domain.data))
        }

        if let keys = value as? AppStoreConnectAlternativeDistributionKeyListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAlternativeDistributionKeys(keys.data))
        }

        if let key = value as? AppStoreConnectAlternativeDistributionKeyResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAlternativeDistributionKey(key.data))
        }

        if let marketplaceWebhooks = value as? AppStoreConnectMarketplaceWebhookListResult {
            return AppStoreConnectCLIResult(
                exitCode: exitCode,
                stdout: renderMarketplaceWebhooks(marketplaceWebhooks.data)
            )
        }

        if let webhooks = value as? AppStoreConnectWebhookListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderWebhooks(webhooks.data))
        }

        if let webhook = value as? AppStoreConnectWebhookResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderWebhook(webhook.data))
        }

        if let deliveries = value as? AppStoreConnectWebhookDeliveryListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderWebhookDeliveries(deliveries.data))
        }

        if let deliveryLinkages = value as? AppStoreConnectWebhookDeliveryLinkageListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderWebhookDeliveryLinkages(deliveryLinkages.data))
        }

        if let delivery = value as? AppStoreConnectWebhookDeliveryMutationResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderWebhookDelivery(delivery.data))
        }

        if let ping = value as? AppStoreConnectWebhookPingResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderWebhookPing(ping.data))
        }

        if let territories = value as? AppStoreConnectTerritoryListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderTerritories(territories.data))
        }

        if let eula = value as? AppStoreConnectEULAResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderEULA(eula.data))
        }
#endif

#if ASC_PUBLIC_API_CLOUD
        if let products = value as? AppStoreConnectXcodeCloudProductListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderXcodeCloudProducts(products.data))
        }

        if let product = value as? AppStoreConnectXcodeCloudProductResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderXcodeCloudProduct(product.data))
        }

        if let workflows = value as? AppStoreConnectXcodeCloudWorkflowListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderXcodeCloudWorkflows(workflows.data))
        }

        if let workflow = value as? AppStoreConnectXcodeCloudWorkflowResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderXcodeCloudWorkflow(workflow.data))
        }

        if let runs = value as? AppStoreConnectXcodeCloudBuildRunListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderXcodeCloudBuildRuns(runs.data))
        }

        if let run = value as? AppStoreConnectXcodeCloudBuildRunResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderXcodeCloudBuildRun(run.data))
        }

        if let actions = value as? AppStoreConnectXcodeCloudBuildActionListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderXcodeCloudBuildActions(actions.data))
        }

        if let action = value as? AppStoreConnectXcodeCloudBuildActionResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderXcodeCloudBuildAction(action.data))
        }

        if let artifacts = value as? AppStoreConnectXcodeCloudArtifactListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderXcodeCloudArtifacts(artifacts.data))
        }

        if let artifact = value as? AppStoreConnectXcodeCloudArtifactResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderXcodeCloudArtifact(artifact.data))
        }
#endif

#if ASC_PUBLIC_API_COMMERCE
        if let iaps = value as? AppStoreConnectInAppPurchaseListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderInAppPurchases(iaps.data))
        }

        if let promotedPurchases = value as? AppStoreConnectPromotedPurchaseListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderPromotedPurchases(promotedPurchases.data))
        }

        if let promotedPurchase = value as? AppStoreConnectPromotedPurchaseResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderPromotedPurchase(promotedPurchase.data))
        }

        if let pricePoints = value as? AppStoreConnectAppPricePointListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAppPricePoints(pricePoints.data))
        }

        if let priceSchedule = value as? AppStoreConnectAppPriceScheduleResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAppPriceSchedule(priceSchedule.data))
        }

        if let localizations = value as? AppStoreConnectCommerceLocalizationListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderCommerceLocalizations(localizations.data))
        }

        if let localization = value as? AppStoreConnectCommerceLocalizationResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderCommerceLocalization(localization.data))
        }

        if let winBackOffers = value as? AppStoreConnectWinBackOfferListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderWinBackOffers(winBackOffers.data))
        }

        if let winBackOffer = value as? AppStoreConnectWinBackOfferResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderWinBackOffer(winBackOffer.data))
        }
#endif

        if let builds = value as? AppStoreConnectBuildListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBuilds(builds.data))
        }

        if let build = value as? AppStoreConnectBuildResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBuild(build.data))
        }

        if let buildWait = value as? AppStoreConnectBuildWaitResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBuildWait(buildWait))
        }

        if let details = value as? AppStoreConnectBuildBetaDetailListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBuildBetaDetails(details.data))
        }

        if let detail = value as? AppStoreConnectBuildBetaDetailResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBuildBetaDetail(detail.data))
        }

        if let versions = value as? AppStoreConnectPreReleaseVersionListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderPreReleaseVersions(versions.data))
        }

        if let version = value as? AppStoreConnectPreReleaseVersionResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderPreReleaseVersion(version.data))
        }

        if let versions = value as? AppStoreConnectAppStoreVersionListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAppStoreVersions(versions.data))
        }

        if let version = value as? AppStoreConnectAppStoreVersionResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAppStoreVersion(version.data))
        }

        if let betaGroups = value as? AppStoreConnectBetaGroupListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaGroups(betaGroups.data))
        }

        if let betaGroup = value as? AppStoreConnectBetaGroupResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaGroup(betaGroup.data))
        }

        if let betaTesters = value as? AppStoreConnectBetaTesterListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaTesters(betaTesters.data))
        }

        if let betaTester = value as? AppStoreConnectBetaTesterResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaTester(betaTester.data))
        }

        if let localizations = value as? AppStoreConnectBetaAppLocalizationListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaAppLocalizations(localizations.data))
        }

        if let localization = value as? AppStoreConnectBetaAppLocalizationResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaAppLocalization(localization.data))
        }

        if let localizations = value as? AppStoreConnectBetaBuildLocalizationListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaBuildLocalizations(localizations.data))
        }

        if let localization = value as? AppStoreConnectBetaBuildLocalizationResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaBuildLocalization(localization.data))
        }

        if let details = value as? AppStoreConnectBetaAppReviewDetailListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaAppReviewDetails(details.data))
        }

        if let detail = value as? AppStoreConnectBetaAppReviewDetailResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaAppReviewDetail(detail.data))
        }

        if let submissions = value as? AppStoreConnectBetaAppReviewSubmissionListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaAppReviewSubmissions(submissions.data))
        }

        if let submission = value as? AppStoreConnectBetaAppReviewSubmissionResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaAppReviewSubmission(submission.data))
        }

        if let agreements = value as? AppStoreConnectBetaLicenseAgreementListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaLicenseAgreements(agreements.data))
        }

        if let agreement = value as? AppStoreConnectBetaLicenseAgreementResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaLicenseAgreement(agreement.data))
        }

        if let submissions = value as? AppStoreConnectBetaFeedbackCrashSubmissionListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaFeedbackCrashSubmissions(submissions.data))
        }

        if let submission = value as? AppStoreConnectBetaFeedbackCrashSubmissionResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaFeedbackCrashSubmission(submission.data))
        }

        if let submissions = value as? AppStoreConnectBetaFeedbackScreenshotSubmissionListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaFeedbackScreenshotSubmissions(submissions.data))
        }

        if let submission = value as? AppStoreConnectBetaFeedbackScreenshotSubmissionResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaFeedbackScreenshotSubmission(submission.data))
        }

        if let log = value as? AppStoreConnectBetaCrashLogResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaCrashLog(log.data))
        }

        if let metrics = value as? AppStoreConnectBetaTesterUsageMetricsResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaTesterUsageMetrics(metrics.data))
        }

        if let metrics = value as? AppStoreConnectBetaPublicLinkUsageMetricsResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaPublicLinkUsageMetrics(metrics.data))
        }

        if let metrics = value as? AppStoreConnectBetaBuildUsageMetricsResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaBuildUsageMetrics(metrics.data))
        }

        if let report = value as? AppStoreConnectAnalyticsReportResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAnalyticsReport(report.data))
        }

        if let request = value as? AppStoreConnectAnalyticsReportRequestResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAnalyticsReportRequest(request.data))
        }

        if let segment = value as? AppStoreConnectAnalyticsReportSegmentResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAnalyticsReportSegment(segment.data))
        }

        if let instance = value as? AppStoreConnectAnalyticsReportInstanceResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAnalyticsReportInstance(instance.data))
        }

        if let download = value as? AppStoreConnectReportDownloadResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderReportDownload(download.data))
        }

#if ASC_PUBLIC_API_REPORTS
        if let metrics = value as? AppStoreConnectPerformanceMetricsResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderPerformanceMetrics(metrics.data))
        }

        if let download = value as? AppStoreConnectPerformanceMetricsDownloadResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderPerformanceMetricsDownload(download.data))
        }
#endif

#if ASC_PUBLIC_API_RELEASE
        if let reviews = value as? AppStoreConnectCustomerReviewListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderCustomerReviews(reviews.data))
        }

        if let review = value as? AppStoreConnectCustomerReviewResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderCustomerReview(review.data))
        }

        if let response = value as? AppStoreConnectCustomerReviewResponseResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderCustomerReviewResponse(response.data))
        }

        if let summaries = value as? AppStoreConnectCustomerReviewSummarizationListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderCustomerReviewSummarizations(summaries.data))
        }
#endif

        if let plan = value as? AppStoreConnectPublicAPIMutationPlan {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderMutationPlan(plan))
        }

        if let acknowledgement = value as? AppStoreConnectMutationAcknowledgementResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderMutationAcknowledgement(acknowledgement.data))
        }

        if let invitation = value as? AppStoreConnectBetaTesterInvitationResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBetaTesterInvitation(invitation.data))
        }

        if let bundleIDs = value as? AppStoreConnectBundleIDListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBundleIDs(bundleIDs.data))
        }

        if let bundleID = value as? AppStoreConnectBundleIDResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBundleID(bundleID.data))
        }

        if let capabilities = value as? AppStoreConnectBundleIDCapabilityListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBundleIDCapabilities(capabilities.data))
        }

        if let capability = value as? AppStoreConnectBundleIDCapabilityResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderBundleIDCapability(capability.data))
        }

        if let certificates = value as? AppStoreConnectCertificateListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderCertificates(certificates.data))
        }

        if let certificate = value as? AppStoreConnectCertificateResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderCertificate(certificate.data))
        }

        if let certificateDownload = value as? AppStoreConnectCertificateDownloadResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderCertificateDownload(certificateDownload.data))
        }

        if let devices = value as? AppStoreConnectDeviceListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderDevices(devices.data))
        }

        if let device = value as? AppStoreConnectDeviceResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderDevice(device.data))
        }

        if let profiles = value as? AppStoreConnectProfileListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderProfiles(profiles.data))
        }

        if let profile = value as? AppStoreConnectProfileResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderProfile(profile.data))
        }

        if let profileDownload = value as? AppStoreConnectProfileDownloadResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderProfileDownload(profileDownload.data))
        }

        if let users = value as? AppStoreConnectUserListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderUsers(users.data))
        }

        if let user = value as? AppStoreConnectUserResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderUser(user.data))
        }

#if ASC_PUBLIC_API_SIGNING_ACCESS
        if let actors = value as? AppStoreConnectActorListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderActors(actors.data))
        }

        if let actor = value as? AppStoreConnectActorResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderActor(actor.data))
        }
#endif

        if let invitations = value as? AppStoreConnectUserInvitationListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderUserInvitations(invitations.data))
        }

        if let invitation = value as? AppStoreConnectUserInvitationResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderUserInvitation(invitation.data))
        }

        if let submissions = value as? AppStoreConnectReviewSubmissionListResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderReviewSubmissions(submissions.data))
        }

        if let submission = value as? AppStoreConnectReviewSubmissionResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderReviewSubmission(submission.data))
        }

        if let releaseRequest = value as? AppStoreConnectAppStoreVersionReleaseRequestResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderAppStoreVersionReleaseRequest(releaseRequest.data))
        }

        if let item = value as? AppStoreConnectReviewSubmissionItemResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderReviewSubmissionItem(item.data))
        }

        if let status = value as? AppStoreConnectStatusResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderStatus(status))
        }

        if let plan = value as? WorkflowPlan {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderPlan(plan))
        }

        if let result = value as? WorkflowRunResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderRunResult(result))
        }

        if let dryRun = value as? WorkflowFileDryRunResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderDryRunResult(dryRun))
        }

        if let runResult = value as? WorkflowFileRunResult {
            return AppStoreConnectCLIResult(exitCode: exitCode, stdout: renderRunResult(runResult.result))
        }

        return try render(value, json: true, exitCode: exitCode)
    }

    private static func renderUnsupportedCommand(
        requestedCommand: String,
        descriptor: AppStoreConnectCLICommandDescriptor,
        json: Bool
    ) throws -> AppStoreConnectCLIResult {
        let message: String = switch descriptor.status {
        case .implemented, .compatibilityAlias:
            "Command is registered, but no direct CLI route matched the requested arguments."
        case .planned:
            "Command is registered  but is not executable yet."
        case .blocked:
            "Command is registered  but is blocked by an explicit platform or source constraint."
        case .outOfScopeConfirmed:
            "Command is registered  but is intentionally outside this package scope."
        }
        let result = UnsupportedCommandResult(
            command: requestedCommand,
            registeredCommand: descriptor.command,
            status: descriptor.status,
            message: message,
            parameterSemantics: descriptor.parameterSemantics,
            backend: descriptor.backend,
            notes: descriptor.notes
        )

        if json {
            return try render(result, json: true, exitCode: 64)
        }

        var lines = [
            message,
            "Status: \(descriptor.status.rawValue)",
            "Registered command: \(descriptor.command)",
            "Backend: \(descriptor.backend)",
        ]
        if let notes = descriptor.notes {
            lines.append("Notes: \(notes)")
        }
        return AppStoreConnectCLIResult(exitCode: 64, stdout: lines.joined(separator: "\n") + "\n")
    }

    private static func renderCommandDescriptors(_ descriptors: [AppStoreConnectCLICommandDescriptor]) -> String {
        var lines = ["Command Matrix"]
        lines += descriptors.map { descriptor in
            var line = "- \(descriptor.command): \(descriptor.status.rawValue) -> \(descriptor.backend)"
            if let notes = descriptor.notes {
                line += " (\(notes))"
            }
            return line
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private static func renderSchemaInfo(_ info: AppStoreConnectSchemaInfo) -> String {
        [
            "Official OpenAPI: \(info.official.title) \(info.official.version) (OpenAPI \(info.official.openapi))",
            "Vendor schema: \(info.official.path) (\(info.official.pathCount) paths, \(info.official.operationCount) operations, \(info.official.schemaCount) schemas)",
            "Selected schema: \(info.selected.path) (\(info.selected.pathCount) paths, \(info.selected.operationCount) operations, \(info.selected.schemaCount) schemas)",
            "Default traits: \(info.generation.defaultTraits.joined(separator: ", "))",
            "Full trait: \(info.generation.fullTrait ?? "none")",
            "Trait source: \(info.generation.activeTraitSource ?? "unknown")",
        ].joined(separator: "\n") + "\n"
    }

    private static func renderSchemaPathInfo(_ paths: AppStoreConnectSchemaPathInfo) -> String {
        [
            "officialSchema\t\(paths.officialSchema)",
            "selectedSchema\t\(paths.selectedSchema)",
            "specLock\t\(paths.specLock)",
            "schemaAudit\t\(paths.schemaAudit)",
            "traitManifest\t\(paths.traitManifest)",
        ].joined(separator: "\n") + "\n"
    }

    private static func renderAuthStatus(_ status: AppStoreConnectAuthStatusResult) -> String {
        var fields: [String] = [
            status.authenticated ? "authenticated" : "not-authenticated",
            status.source,
            status.accountEmail,
            status.accountID,
            status.teamID,
            status.teamName,
            status.expiresAt.map(iso8601String),
            "cookies=\(status.cookieCount)",
        ].compactMap { $0 }

        if !status.cookieNames.isEmpty {
            fields.append("cookieNames=\(status.cookieNames.joined(separator: ","))")
        }

        fields.append(status.message)
        if !status.diagnostics.isEmpty {
            fields.append(status.diagnostics.joined(separator: " | "))
        }

        return fields.joined(separator: "\t") + "\n"
    }

    private static func renderAuthDoctor(_ doctor: AppStoreConnectAuthDoctorResult) -> String {
        var lines = [
            doctor.healthy ? "Auth doctor: healthy" : "Auth doctor: no usable web session",
            renderAuthStatus(doctor.status).trimmingCharacters(in: .newlines),
        ]
        lines += doctor.checks.map { check in
            [
                check.passed ? "ok" : "fail",
                check.name,
                check.source,
                check.message,
            ].joined(separator: "\t")
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private static func renderAuthLogoutPlan(_ plan: AppStoreConnectAuthLogoutPlan) -> String {
        [
            "Dry run auth logout",
            "sessionFile\t\(plan.sessionFilePath)",
            "willRemove\t\(plan.willRemove)",
            plan.message,
        ].joined(separator: "\n") + "\n"
    }

    private static func renderAuthLogout(_ result: AppStoreConnectAuthLogoutResult) -> String {
        [
            result.removed ? "removed" : "not-removed",
            result.sessionFilePath,
            result.message,
        ].joined(separator: "\t") + "\n"
    }

    private static func renderXcodeToolPlan(_ plan: AppStoreConnectXcodeToolPlan) -> String {
        [
            "Dry run \(plan.operation)",
            "executable\t\(plan.invocation.executablePath)",
            "arguments\t\(shellEscaped(plan.invocation.arguments))",
            "currentDirectory\t\(plan.invocation.currentDirectoryPath ?? "")",
            "mutatesLocalFileSystem\t\(plan.mutatesLocalFileSystem)",
            "contactsAppleServices\t\(plan.contactsAppleServices)",
            plan.message,
        ].joined(separator: "\n") + "\n"
    }

    private static func renderXcodeToolRunResult(_ result: AppStoreConnectXcodeToolRunResult) -> String {
        var lines = [
            "\(result.plan.operation)\t\(result.succeeded ? "succeeded" : "failed")\texitCode=\(result.result.exitCode)",
            "executable\t\(result.plan.invocation.executablePath)",
            "arguments\t\(shellEscaped(result.plan.invocation.arguments))",
        ]
        if !result.result.stdout.isEmpty {
            lines.append("stdout")
            lines.append(result.result.stdout.trimmingCharacters(in: .newlines))
        }
        if !result.result.stderr.isEmpty {
            lines.append("stderr")
            lines.append(result.result.stderr.trimmingCharacters(in: .newlines))
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private static func shellEscaped(_ arguments: [String]) -> String {
        arguments.map { argument in
            if argument.rangeOfCharacter(from: .whitespacesAndNewlines) == nil, !argument.isEmpty {
                return argument
            }
            return "'" + argument.replacingOccurrences(of: "'", with: "'\\''") + "'"
        }.joined(separator: " ")
    }

    private static func renderApps(_ apps: [AppStoreConnectAppSummary]) -> String {
        if apps.isEmpty {
            return "No apps found.\n"
        }
        return apps.map(renderAppLine).joined(separator: "\n") + "\n"
    }

    private static func renderApp(_ app: AppStoreConnectAppSummary) -> String {
        renderAppLine(app) + "\n"
    }

    private static func renderAppLine(_ app: AppStoreConnectAppSummary) -> String {
        [
            app.id,
            app.name,
            app.bundleID,
            app.sku,
            app.primaryLocale,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

#if ASC_PUBLIC_API_RELEASE
    private static func renderAppCategories(_ categories: [AppStoreConnectAppCategorySummary]) -> String {
        if categories.isEmpty {
            return "No app categories found.\n"
        }
        return categories.map(renderAppCategoryLine).joined(separator: "\n") + "\n"
    }

    private static func renderAppCategory(_ category: AppStoreConnectAppCategorySummary) -> String {
        renderAppCategoryLine(category) + "\n"
    }

    private static func renderAppCategoryLine(_ category: AppStoreConnectAppCategorySummary) -> String {
        [
            category.id,
            category.platforms.isEmpty ? nil : category.platforms.joined(separator: ","),
            category.parentID,
            category.subcategoryIDs.isEmpty ? nil : category.subcategoryIDs.joined(separator: ","),
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderAppCategoryAssignment(_ assignment: AppStoreConnectAppCategoryAssignmentSummary) -> String {
        [
            assignment.appInfoID,
            assignment.primaryCategoryID,
            assignment.secondaryCategoryID,
            assignment.primarySubcategoryOneID,
            assignment.primarySubcategoryTwoID,
            assignment.secondarySubcategoryOneID,
            assignment.secondarySubcategoryTwoID,
        ]
            .compactMap { $0 }
            .joined(separator: "\t") + "\n"
    }

    private static func renderAgeRating(_ ageRating: AppStoreConnectAgeRatingSummary) -> String {
        [
            ageRating.id,
            ageRating.ageRatingOverrideV2,
            ageRating.koreaAgeRatingOverride,
            ageRating.kidsAgeBand,
            ageRating.developerAgeRatingInfoURL,
            renderKeyValuePairs(ageRating.frequencyRatings),
            renderKeyValuePairs(ageRating.booleanRatings.mapValues(String.init)),
        ]
            .compactMap { value in
                value?.isEmpty == true ? nil : value
            }
            .joined(separator: "\t") + "\n"
    }

    private static func renderKeyValuePairs(_ values: [String: String]) -> String? {
        guard !values.isEmpty else { return nil }
        return values
            .map { key, value in "\(key)=\(value)" }
            .sorted()
            .joined(separator: ",")
    }

    private static func renderAppEvents(_ events: [AppStoreConnectAppEventSummary]) -> String {
        if events.isEmpty {
            return "No app events found.\n"
        }
        return events.map(renderAppEventLine).joined(separator: "\n") + "\n"
    }

    private static func renderAppEvent(_ event: AppStoreConnectAppEventSummary) -> String {
        renderAppEventLine(event) + "\n"
    }

    private static func renderAppEventLine(_ event: AppStoreConnectAppEventSummary) -> String {
        [
            event.id,
            event.referenceName,
            event.eventState,
            event.badge,
            event.priority,
            event.purpose,
            event.primaryLocale,
            event.deepLink,
            event.purchaseRequirement,
            event.localizationIDs.isEmpty ? nil : event.localizationIDs.joined(separator: ","),
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }
#endif

#if ASC_PUBLIC_API_METADATA_MEDIA
    private static func renderAppClips(_ appClips: [AppStoreConnectAppClipSummary]) -> String {
        if appClips.isEmpty {
            return "No app clips found.\n"
        }
        return appClips.map(renderAppClipLine).joined(separator: "\n") + "\n"
    }

    private static func renderAppClip(_ appClip: AppStoreConnectAppClipSummary) -> String {
        renderAppClipLine(appClip) + "\n"
    }

    private static func renderAppClipLine(_ appClip: AppStoreConnectAppClipSummary) -> String {
        [
            appClip.id,
            appClip.bundleID,
            appClip.appID,
            appClip.defaultExperienceIDs.isEmpty ? nil : appClip.defaultExperienceIDs.joined(separator: ","),
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderAppClipDefaultExperiences(
        _ experiences: [AppStoreConnectAppClipDefaultExperienceSummary]
    ) -> String {
        if experiences.isEmpty {
            return "No app clip default experiences found.\n"
        }
        return experiences.map(renderAppClipDefaultExperienceLine).joined(separator: "\n") + "\n"
    }

    private static func renderAppClipDefaultExperience(
        _ experience: AppStoreConnectAppClipDefaultExperienceSummary
    ) -> String {
        renderAppClipDefaultExperienceLine(experience) + "\n"
    }

    private static func renderAppClipDefaultExperienceLine(
        _ experience: AppStoreConnectAppClipDefaultExperienceSummary
    ) -> String {
        [
            experience.id,
            experience.action,
            experience.appClipID,
            experience.releaseWithAppStoreVersionID,
            experience.reviewDetailID,
            experience.localizationIDs.isEmpty ? nil : experience.localizationIDs.joined(separator: ","),
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderAppClipLocalizations(
        _ localizations: [AppStoreConnectAppClipLocalizationSummary]
    ) -> String {
        if localizations.isEmpty {
            return "No app clip localizations found.\n"
        }
        return localizations.map(renderAppClipLocalizationLine).joined(separator: "\n") + "\n"
    }

    private static func renderAppClipLocalization(
        _ localization: AppStoreConnectAppClipLocalizationSummary
    ) -> String {
        renderAppClipLocalizationLine(localization) + "\n"
    }

    private static func renderAppClipLocalizationLine(
        _ localization: AppStoreConnectAppClipLocalizationSummary
    ) -> String {
        [
            localization.id,
            localization.locale,
            localization.subtitle,
            localization.defaultExperienceID,
            localization.headerImageID,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }
#endif

#if ASC_PUBLIC_API_GAME_CENTER
    private static func renderGameCenterDetail(_ detail: AppStoreConnectGameCenterDetailSummary) -> String {
        [
            detail.id,
            detail.arcadeEnabled.map(String.init),
            detail.challengeEnabled.map(String.init),
            detail.appID,
            detail.achievementIDs.isEmpty ? nil : detail.achievementIDs.joined(separator: ","),
            detail.leaderboardIDs.isEmpty ? nil : detail.leaderboardIDs.joined(separator: ","),
            detail.leaderboardSetIDs.isEmpty ? nil : detail.leaderboardSetIDs.joined(separator: ","),
            detail.challengeIDs.isEmpty ? nil : detail.challengeIDs.joined(separator: ","),
        ]
            .compactMap { $0 }
            .joined(separator: "\t") + "\n"
    }

    private static func renderGameCenterAchievements(
        _ achievements: [AppStoreConnectGameCenterAchievementSummary]
    ) -> String {
        if achievements.isEmpty {
            return "No Game Center achievements found.\n"
        }
        return achievements.map(renderGameCenterAchievementLine).joined(separator: "\n") + "\n"
    }

    private static func renderGameCenterAchievement(
        _ achievement: AppStoreConnectGameCenterAchievementSummary
    ) -> String {
        renderGameCenterAchievementLine(achievement) + "\n"
    }

    private static func renderGameCenterAchievementLine(
        _ achievement: AppStoreConnectGameCenterAchievementSummary
    ) -> String {
        [
            achievement.id,
            achievement.referenceName,
            achievement.vendorIdentifier,
            achievement.points.map(String.init),
            achievement.archived.map(String.init),
            achievement.repeatable.map(String.init),
            achievement.detailID,
            achievement.versionIDs.isEmpty ? nil : achievement.versionIDs.joined(separator: ","),
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderGameCenterLeaderboards(
        _ leaderboards: [AppStoreConnectGameCenterLeaderboardSummary]
    ) -> String {
        if leaderboards.isEmpty {
            return "No Game Center leaderboards found.\n"
        }
        return leaderboards.map(renderGameCenterLeaderboardLine).joined(separator: "\n") + "\n"
    }

    private static func renderGameCenterLeaderboard(
        _ leaderboard: AppStoreConnectGameCenterLeaderboardSummary
    ) -> String {
        renderGameCenterLeaderboardLine(leaderboard) + "\n"
    }

    private static func renderGameCenterLeaderboardLine(
        _ leaderboard: AppStoreConnectGameCenterLeaderboardSummary
    ) -> String {
        [
            leaderboard.id,
            leaderboard.referenceName,
            leaderboard.vendorIdentifier,
            leaderboard.scoreSortType,
            leaderboard.defaultFormatter,
            leaderboard.submissionType,
            leaderboard.archived.map(String.init),
            leaderboard.detailID,
            leaderboard.leaderboardSetIDs.isEmpty ? nil : leaderboard.leaderboardSetIDs.joined(separator: ","),
            leaderboard.versionIDs.isEmpty ? nil : leaderboard.versionIDs.joined(separator: ","),
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderGameCenterLeaderboardSets(
        _ leaderboardSets: [AppStoreConnectGameCenterLeaderboardSetSummary]
    ) -> String {
        if leaderboardSets.isEmpty {
            return "No Game Center leaderboard sets found.\n"
        }
        return leaderboardSets.map(renderGameCenterLeaderboardSetLine).joined(separator: "\n") + "\n"
    }

    private static func renderGameCenterLeaderboardSet(
        _ leaderboardSet: AppStoreConnectGameCenterLeaderboardSetSummary
    ) -> String {
        renderGameCenterLeaderboardSetLine(leaderboardSet) + "\n"
    }

    private static func renderGameCenterLeaderboardSetLine(
        _ leaderboardSet: AppStoreConnectGameCenterLeaderboardSetSummary
    ) -> String {
        [
            leaderboardSet.id,
            leaderboardSet.referenceName,
            leaderboardSet.vendorIdentifier,
            leaderboardSet.detailID,
            leaderboardSet.leaderboardIDs.isEmpty ? nil : leaderboardSet.leaderboardIDs.joined(separator: ","),
            leaderboardSet.versionIDs.isEmpty ? nil : leaderboardSet.versionIDs.joined(separator: ","),
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderGameCenterChallenges(
        _ challenges: [AppStoreConnectGameCenterChallengeSummary]
    ) -> String {
        if challenges.isEmpty {
            return "No Game Center challenges found.\n"
        }
        return challenges.map(renderGameCenterChallengeLine).joined(separator: "\n") + "\n"
    }

    private static func renderGameCenterChallenge(
        _ challenge: AppStoreConnectGameCenterChallengeSummary
    ) -> String {
        renderGameCenterChallengeLine(challenge) + "\n"
    }

    private static func renderGameCenterChallengeLine(
        _ challenge: AppStoreConnectGameCenterChallengeSummary
    ) -> String {
        [
            challenge.id,
            challenge.referenceName,
            challenge.vendorIdentifier,
            challenge.challengeType,
            challenge.archived.map(String.init),
            challenge.repeatable.map(String.init),
            challenge.detailID,
            challenge.leaderboardID,
            challenge.versionIDs.isEmpty ? nil : challenge.versionIDs.joined(separator: ","),
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }
#endif

#if ASC_PUBLIC_API_DISTRIBUTION
    private static func renderAlternativeDistributionDomains(
        _ domains: [AppStoreConnectAlternativeDistributionDomainSummary]
    ) -> String {
        if domains.isEmpty {
            return "No alternative distribution domains found.\n"
        }
        return domains.map(renderAlternativeDistributionDomainLine).joined(separator: "\n") + "\n"
    }

    private static func renderAlternativeDistributionDomain(
        _ domain: AppStoreConnectAlternativeDistributionDomainSummary
    ) -> String {
        renderAlternativeDistributionDomainLine(domain) + "\n"
    }

    private static func renderAlternativeDistributionDomainLine(
        _ domain: AppStoreConnectAlternativeDistributionDomainSummary
    ) -> String {
        [
            domain.id,
            domain.domain,
            domain.referenceName,
            domain.createdDate.map(iso8601String),
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderAlternativeDistributionKeys(
        _ keys: [AppStoreConnectAlternativeDistributionKeySummary]
    ) -> String {
        if keys.isEmpty {
            return "No alternative distribution keys found.\n"
        }
        return keys.map(renderAlternativeDistributionKeyLine).joined(separator: "\n") + "\n"
    }

    private static func renderAlternativeDistributionKey(
        _ key: AppStoreConnectAlternativeDistributionKeySummary
    ) -> String {
        renderAlternativeDistributionKeyLine(key) + "\n"
    }

    private static func renderAlternativeDistributionKeyLine(
        _ key: AppStoreConnectAlternativeDistributionKeySummary
    ) -> String {
        [
            key.id,
            key.publicKey,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderMarketplaceWebhooks(
        _ webhooks: [AppStoreConnectMarketplaceWebhookSummary]
    ) -> String {
        if webhooks.isEmpty {
            return "No marketplace webhooks found.\n"
        }
        return webhooks.map(renderMarketplaceWebhookLine).joined(separator: "\n") + "\n"
    }

    private static func renderMarketplaceWebhookLine(
        _ webhook: AppStoreConnectMarketplaceWebhookSummary
    ) -> String {
        [
            webhook.id,
            webhook.endpointURL,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderWebhooks(_ webhooks: [AppStoreConnectWebhookSummary]) -> String {
        if webhooks.isEmpty {
            return "No webhooks found.\n"
        }
        return webhooks.map(renderWebhookLine).joined(separator: "\n") + "\n"
    }

    private static func renderWebhook(_ webhook: AppStoreConnectWebhookSummary) -> String {
        renderWebhookLine(webhook) + "\n"
    }

    private static func renderWebhookLine(_ webhook: AppStoreConnectWebhookSummary) -> String {
        [
            webhook.id,
            webhook.name,
            webhook.url,
            webhook.enabled.map(String.init),
            webhook.eventTypes.isEmpty ? nil : webhook.eventTypes.joined(separator: ","),
            webhook.appID,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderWebhookDeliveries(
        _ deliveries: [AppStoreConnectWebhookDeliverySummary]
    ) -> String {
        if deliveries.isEmpty {
            return "No webhook deliveries found.\n"
        }
        return deliveries.map(renderWebhookDeliveryLine).joined(separator: "\n") + "\n"
    }

    private static func renderWebhookDelivery(
        _ delivery: AppStoreConnectWebhookDeliverySummary
    ) -> String {
        renderWebhookDeliveryLine(delivery) + "\n"
    }

    private static func renderWebhookDeliveryLine(
        _ delivery: AppStoreConnectWebhookDeliverySummary
    ) -> String {
        [
            delivery.id,
            delivery.deliveryState,
            delivery.createdDate.map(iso8601String),
            delivery.sentDate.map(iso8601String),
            delivery.redelivery.map(String.init),
            delivery.responseStatusCode.map(String.init),
            delivery.requestURL,
            delivery.eventID,
            delivery.errorMessage,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderWebhookDeliveryLinkages(
        _ linkages: [AppStoreConnectWebhookDeliveryLinkageSummary]
    ) -> String {
        if linkages.isEmpty {
            return "No webhook delivery linkages found.\n"
        }
        return linkages.map(renderWebhookDeliveryLinkageLine).joined(separator: "\n") + "\n"
    }

    private static func renderWebhookDeliveryLinkageLine(
        _ linkage: AppStoreConnectWebhookDeliveryLinkageSummary
    ) -> String {
        [
            linkage.id,
            linkage.type,
        ].joined(separator: "\t")
    }

    private static func renderWebhookPing(_ ping: AppStoreConnectWebhookPingSummary) -> String {
        [
            ping.id,
            ping.webhookID,
        ].joined(separator: "\t") + "\n"
    }

    private static func renderTerritories(_ territories: [AppStoreConnectTerritorySummary]) -> String {
        if territories.isEmpty {
            return "No territories found.\n"
        }
        return territories.map(renderTerritoryLine).joined(separator: "\n") + "\n"
    }

    private static func renderTerritoryLine(_ territory: AppStoreConnectTerritorySummary) -> String {
        [
            territory.id,
            territory.currency,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderEULA(_ eula: AppStoreConnectEULASummary) -> String {
        [
            eula.id,
            eula.appID,
            eula.territoryIDs.isEmpty ? nil : eula.territoryIDs.joined(separator: ","),
            eula.agreementText,
        ]
            .compactMap { $0 }
            .joined(separator: "\t") + "\n"
    }
#endif

#if ASC_PUBLIC_API_CLOUD
    private static func renderXcodeCloudProducts(
        _ products: [AppStoreConnectXcodeCloudProductSummary]
    ) -> String {
        if products.isEmpty {
            return "No Xcode Cloud products found.\n"
        }
        return products.map(renderXcodeCloudProductLine).joined(separator: "\n") + "\n"
    }

    private static func renderXcodeCloudProduct(
        _ product: AppStoreConnectXcodeCloudProductSummary
    ) -> String {
        renderXcodeCloudProductLine(product) + "\n"
    }

    private static func renderXcodeCloudProductLine(
        _ product: AppStoreConnectXcodeCloudProductSummary
    ) -> String {
        [
            product.id,
            product.name,
            product.productType,
            product.createdDate.map(iso8601String),
            product.appID,
            product.bundleID,
            product.primaryRepositoryIDs.isEmpty ? nil : product.primaryRepositoryIDs.joined(separator: ","),
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderXcodeCloudWorkflows(
        _ workflows: [AppStoreConnectXcodeCloudWorkflowSummary]
    ) -> String {
        if workflows.isEmpty {
            return "No Xcode Cloud workflows found.\n"
        }
        return workflows.map(renderXcodeCloudWorkflowLine).joined(separator: "\n") + "\n"
    }

    private static func renderXcodeCloudWorkflow(
        _ workflow: AppStoreConnectXcodeCloudWorkflowSummary
    ) -> String {
        renderXcodeCloudWorkflowLine(workflow) + "\n"
    }

    private static func renderXcodeCloudWorkflowLine(
        _ workflow: AppStoreConnectXcodeCloudWorkflowSummary
    ) -> String {
        [
            workflow.id,
            workflow.name,
            workflow.isEnabled.map(String.init),
            workflow.isLockedForEditing.map(String.init),
            workflow.clean.map(String.init),
            workflow.lastModifiedDate.map(iso8601String),
            workflow.productID,
            workflow.repositoryID,
            workflow.xcodeVersionID,
            workflow.macOSVersionID,
            workflow.containerFilePath,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderXcodeCloudBuildRuns(
        _ runs: [AppStoreConnectXcodeCloudBuildRunSummary]
    ) -> String {
        if runs.isEmpty {
            return "No Xcode Cloud build runs found.\n"
        }
        return runs.map(renderXcodeCloudBuildRunLine).joined(separator: "\n") + "\n"
    }

    private static func renderXcodeCloudBuildRun(
        _ run: AppStoreConnectXcodeCloudBuildRunSummary
    ) -> String {
        renderXcodeCloudBuildRunLine(run) + "\n"
    }

    private static func renderXcodeCloudBuildRunLine(
        _ run: AppStoreConnectXcodeCloudBuildRunSummary
    ) -> String {
        [
            run.id,
            run.number.map(String.init),
            run.executionProgress,
            run.completionStatus,
            run.startReason,
            run.createdDate.map(iso8601String),
            run.startedDate.map(iso8601String),
            run.finishedDate.map(iso8601String),
            run.workflowID,
            run.productID,
            run.sourceCommitSHA,
            run.buildIDs.isEmpty ? nil : run.buildIDs.joined(separator: ","),
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderXcodeCloudBuildActions(
        _ actions: [AppStoreConnectXcodeCloudBuildActionSummary]
    ) -> String {
        if actions.isEmpty {
            return "No Xcode Cloud build actions found.\n"
        }
        return actions.map(renderXcodeCloudBuildActionLine).joined(separator: "\n") + "\n"
    }

    private static func renderXcodeCloudBuildAction(
        _ action: AppStoreConnectXcodeCloudBuildActionSummary
    ) -> String {
        renderXcodeCloudBuildActionLine(action) + "\n"
    }

    private static func renderXcodeCloudBuildActionLine(
        _ action: AppStoreConnectXcodeCloudBuildActionSummary
    ) -> String {
        [
            action.id,
            action.name,
            action.actionType,
            action.executionProgress,
            action.completionStatus,
            action.isRequiredToPass.map(String.init),
            action.startedDate.map(iso8601String),
            action.finishedDate.map(iso8601String),
            action.buildRunID,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderXcodeCloudArtifacts(
        _ artifacts: [AppStoreConnectXcodeCloudArtifactSummary]
    ) -> String {
        if artifacts.isEmpty {
            return "No Xcode Cloud artifacts found.\n"
        }
        return artifacts.map(renderXcodeCloudArtifactLine).joined(separator: "\n") + "\n"
    }

    private static func renderXcodeCloudArtifact(
        _ artifact: AppStoreConnectXcodeCloudArtifactSummary
    ) -> String {
        renderXcodeCloudArtifactLine(artifact) + "\n"
    }

    private static func renderXcodeCloudArtifactLine(
        _ artifact: AppStoreConnectXcodeCloudArtifactSummary
    ) -> String {
        [
            artifact.id,
            artifact.fileName,
            artifact.fileType,
            artifact.fileSize.map(String.init),
            artifact.downloadURL,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }
#endif

#if ASC_PUBLIC_API_COMMERCE
    private static func renderInAppPurchases(_ purchases: [AppStoreConnectInAppPurchaseSummary]) -> String {
        if purchases.isEmpty {
            return "No in-app purchases found.\n"
        }
        return purchases.map(renderInAppPurchaseLine).joined(separator: "\n") + "\n"
    }

    private static func renderInAppPurchaseLine(_ purchase: AppStoreConnectInAppPurchaseSummary) -> String {
        [
            purchase.id,
            purchase.productID,
            purchase.name,
            purchase.inAppPurchaseType,
            purchase.state,
            purchase.familySharable.map(String.init),
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderPromotedPurchases(_ purchases: [AppStoreConnectPromotedPurchaseSummary]) -> String {
        if purchases.isEmpty {
            return "No promoted purchases found.\n"
        }
        return purchases.map(renderPromotedPurchaseLine).joined(separator: "\n") + "\n"
    }

    private static func renderPromotedPurchase(_ purchase: AppStoreConnectPromotedPurchaseSummary) -> String {
        renderPromotedPurchaseLine(purchase) + "\n"
    }

    private static func renderPromotedPurchaseLine(_ purchase: AppStoreConnectPromotedPurchaseSummary) -> String {
        [
            purchase.id,
            purchase.inAppPurchaseID,
            purchase.subscriptionID,
            purchase.state,
            purchase.visibleForAllUsers.map(String.init),
            purchase.enabled.map(String.init),
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderAppPricePoints(_ pricePoints: [AppStoreConnectAppPricePointSummary]) -> String {
        if pricePoints.isEmpty {
            return "No app price points found.\n"
        }
        return pricePoints.map(renderAppPricePointLine).joined(separator: "\n") + "\n"
    }

    private static func renderAppPricePointLine(_ pricePoint: AppStoreConnectAppPricePointSummary) -> String {
        [
            pricePoint.id,
            pricePoint.customerPrice,
            pricePoint.proceeds,
            pricePoint.appID,
            pricePoint.territoryID,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderAppPriceSchedule(_ schedule: AppStoreConnectAppPriceScheduleSummary) -> String {
        [
            schedule.id,
            schedule.appID,
            schedule.baseTerritoryID,
            schedule.manualPriceIDs.isEmpty ? nil : schedule.manualPriceIDs.joined(separator: ","),
            schedule.automaticPriceIDs.isEmpty ? nil : schedule.automaticPriceIDs.joined(separator: ","),
        ]
            .compactMap { $0 }
            .joined(separator: "\t") + "\n"
    }

    private static func renderCommerceLocalizations(_ localizations: [AppStoreConnectCommerceLocalizationSummary]) -> String {
        if localizations.isEmpty {
            return "No commerce localizations found.\n"
        }
        return localizations.map(renderCommerceLocalizationLine).joined(separator: "\n") + "\n"
    }

    private static func renderCommerceLocalization(_ localization: AppStoreConnectCommerceLocalizationSummary) -> String {
        renderCommerceLocalizationLine(localization) + "\n"
    }

    private static func renderCommerceLocalizationLine(_ localization: AppStoreConnectCommerceLocalizationSummary) -> String {
        [
            localization.id,
            localization.resourceType,
            localization.locale,
            localization.name,
            localization.description,
            localization.customAppName,
            localization.parentResourceType,
            localization.parentID,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderWinBackOffers(_ offers: [AppStoreConnectWinBackOfferSummary]) -> String {
        if offers.isEmpty {
            return "No win-back offers found.\n"
        }
        return offers.map(renderWinBackOfferLine).joined(separator: "\n") + "\n"
    }

    private static func renderWinBackOffer(_ offer: AppStoreConnectWinBackOfferSummary) -> String {
        renderWinBackOfferLine(offer) + "\n"
    }

    private static func renderWinBackOfferLine(_ offer: AppStoreConnectWinBackOfferSummary) -> String {
        [
            offer.id,
            offer.referenceName,
            offer.offerID,
            offer.duration,
            offer.offerMode,
            offer.periodCount.map(String.init),
            offer.priority,
            offer.startDate,
            offer.endDate,
            offer.priceIDs.isEmpty ? nil : offer.priceIDs.joined(separator: ","),
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }
#endif

    private static func renderBuilds(_ builds: [AppStoreConnectBuildSummary]) -> String {
        if builds.isEmpty {
            return "No builds found.\n"
        }
        return builds.map(renderBuildLine).joined(separator: "\n") + "\n"
    }

    private static func renderBuild(_ build: AppStoreConnectBuildSummary) -> String {
        renderBuildLine(build) + "\n"
    }

    private static func renderBuildLine(_ build: AppStoreConnectBuildSummary) -> String {
        [
            build.id,
            build.version,
            build.processingState,
            build.appID,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderBuildWait(_ result: AppStoreConnectBuildWaitResult) -> String {
        let state = result.build.processingState ?? "unknown"
        return "Build \(result.build.id) \(result.status.rawValue) after \(result.attempts.count) attempt(s): \(state)\n"
    }

    private static func renderBuildBetaDetails(_ details: [AppStoreConnectBuildBetaDetailSummary]) -> String {
        if details.isEmpty {
            return "No build beta details found.\n"
        }
        return details.map(renderBuildBetaDetailLine).joined(separator: "\n") + "\n"
    }

    private static func renderBuildBetaDetail(_ detail: AppStoreConnectBuildBetaDetailSummary) -> String {
        renderBuildBetaDetailLine(detail) + "\n"
    }

    private static func renderBuildBetaDetailLine(_ detail: AppStoreConnectBuildBetaDetailSummary) -> String {
        [
            detail.id,
            detail.buildID,
            detail.internalBuildState,
            detail.externalBuildState,
            detail.autoNotifyEnabled.map(String.init),
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderPreReleaseVersions(_ versions: [AppStoreConnectPreReleaseVersionSummary]) -> String {
        if versions.isEmpty {
            return "No prerelease versions found.\n"
        }
        return versions.map(renderPreReleaseVersionLine).joined(separator: "\n") + "\n"
    }

    private static func renderPreReleaseVersion(_ version: AppStoreConnectPreReleaseVersionSummary) -> String {
        renderPreReleaseVersionLine(version) + "\n"
    }

    private static func renderPreReleaseVersionLine(_ version: AppStoreConnectPreReleaseVersionSummary) -> String {
        [
            version.id,
            version.version,
            version.platform,
            version.appID,
            version.buildIDs.isEmpty ? nil : version.buildIDs.joined(separator: ","),
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderAppStoreVersions(_ versions: [AppStoreConnectAppStoreVersionSummary]) -> String {
        if versions.isEmpty {
            return "No App Store versions found.\n"
        }
        return versions.map(renderAppStoreVersionLine).joined(separator: "\n") + "\n"
    }

    private static func renderAppStoreVersion(_ version: AppStoreConnectAppStoreVersionSummary) -> String {
        renderAppStoreVersionLine(version) + "\n"
    }

    private static func renderAppStoreVersionLine(_ version: AppStoreConnectAppStoreVersionSummary) -> String {
        [
            version.id,
            version.versionString,
            version.platform,
            version.appStoreState,
            version.appVersionState,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderBetaGroups(_ groups: [AppStoreConnectBetaGroupSummary]) -> String {
        if groups.isEmpty {
            return "No beta groups found.\n"
        }
        return groups.map(renderBetaGroupLine).joined(separator: "\n") + "\n"
    }

    private static func renderBetaGroup(_ group: AppStoreConnectBetaGroupSummary) -> String {
        renderBetaGroupLine(group) + "\n"
    }

    private static func renderBetaGroupLine(_ group: AppStoreConnectBetaGroupSummary) -> String {
        [
            group.id,
            group.name,
            group.isInternalGroup.map(String.init),
            group.publicLinkEnabled.map(String.init),
            group.appID,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderBetaTesters(_ testers: [AppStoreConnectBetaTesterSummary]) -> String {
        if testers.isEmpty {
            return "No beta testers found.\n"
        }
        return testers.map(renderBetaTesterLine).joined(separator: "\n") + "\n"
    }

    private static func renderBetaTester(_ tester: AppStoreConnectBetaTesterSummary) -> String {
        renderBetaTesterLine(tester) + "\n"
    }

    private static func renderBetaTesterLine(_ tester: AppStoreConnectBetaTesterSummary) -> String {
        [
            tester.id,
            tester.email,
            tester.firstName,
            tester.lastName,
            tester.state,
            tester.inviteType,
            tester.appIDs.isEmpty ? nil : tester.appIDs.joined(separator: ","),
            tester.betaGroupIDs.isEmpty ? nil : tester.betaGroupIDs.joined(separator: ","),
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderBetaAppLocalizations(_ localizations: [AppStoreConnectBetaAppLocalizationSummary]) -> String {
        if localizations.isEmpty {
            return "No beta app localizations found.\n"
        }
        return localizations.map(renderBetaAppLocalizationLine).joined(separator: "\n") + "\n"
    }

    private static func renderBetaAppLocalization(_ localization: AppStoreConnectBetaAppLocalizationSummary) -> String {
        renderBetaAppLocalizationLine(localization) + "\n"
    }

    private static func renderBetaAppLocalizationLine(_ localization: AppStoreConnectBetaAppLocalizationSummary) -> String {
        [
            localization.id,
            localization.locale,
            localization.appID,
            localization.feedbackEmail,
            localization.marketingURL,
            localization.privacyPolicyURL,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderBetaBuildLocalizations(_ localizations: [AppStoreConnectBetaBuildLocalizationSummary]) -> String {
        if localizations.isEmpty {
            return "No beta build localizations found.\n"
        }
        return localizations.map(renderBetaBuildLocalizationLine).joined(separator: "\n") + "\n"
    }

    private static func renderBetaBuildLocalization(_ localization: AppStoreConnectBetaBuildLocalizationSummary) -> String {
        renderBetaBuildLocalizationLine(localization) + "\n"
    }

    private static func renderBetaBuildLocalizationLine(_ localization: AppStoreConnectBetaBuildLocalizationSummary) -> String {
        [
            localization.id,
            localization.locale,
            localization.buildID,
            localization.whatsNew,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderBetaAppReviewDetails(_ details: [AppStoreConnectBetaAppReviewDetailSummary]) -> String {
        if details.isEmpty {
            return "No beta app review details found.\n"
        }
        return details.map(renderBetaAppReviewDetailLine).joined(separator: "\n") + "\n"
    }

    private static func renderBetaAppReviewDetail(_ detail: AppStoreConnectBetaAppReviewDetailSummary) -> String {
        renderBetaAppReviewDetailLine(detail) + "\n"
    }

    private static func renderBetaAppReviewDetailLine(_ detail: AppStoreConnectBetaAppReviewDetailSummary) -> String {
        [
            detail.id,
            detail.appID,
            detail.contactEmail,
            detail.contactFirstName,
            detail.contactLastName,
            detail.demoAccountRequired.map(String.init),
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderBetaAppReviewSubmissions(_ submissions: [AppStoreConnectBetaAppReviewSubmissionSummary]) -> String {
        if submissions.isEmpty {
            return "No beta app review submissions found.\n"
        }
        return submissions.map(renderBetaAppReviewSubmissionLine).joined(separator: "\n") + "\n"
    }

    private static func renderBetaAppReviewSubmission(_ submission: AppStoreConnectBetaAppReviewSubmissionSummary) -> String {
        renderBetaAppReviewSubmissionLine(submission) + "\n"
    }

    private static func renderBetaAppReviewSubmissionLine(_ submission: AppStoreConnectBetaAppReviewSubmissionSummary) -> String {
        [
            submission.id,
            submission.buildID,
            submission.betaReviewState,
            submission.submittedDate.map(iso8601String),
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderBetaLicenseAgreements(_ agreements: [AppStoreConnectBetaLicenseAgreementSummary]) -> String {
        if agreements.isEmpty {
            return "No beta license agreements found.\n"
        }
        return agreements.map(renderBetaLicenseAgreementLine).joined(separator: "\n") + "\n"
    }

    private static func renderBetaLicenseAgreement(_ agreement: AppStoreConnectBetaLicenseAgreementSummary) -> String {
        renderBetaLicenseAgreementLine(agreement) + "\n"
    }

    private static func renderBetaLicenseAgreementLine(_ agreement: AppStoreConnectBetaLicenseAgreementSummary) -> String {
        [
            agreement.id,
            agreement.appID,
            agreement.agreementText,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderBetaFeedbackCrashSubmissions(
        _ submissions: [AppStoreConnectBetaFeedbackCrashSubmissionSummary]
    ) -> String {
        if submissions.isEmpty {
            return "No beta feedback crash submissions found.\n"
        }
        return submissions.map(renderBetaFeedbackCrashSubmissionLine).joined(separator: "\n") + "\n"
    }

    private static func renderBetaFeedbackCrashSubmission(
        _ submission: AppStoreConnectBetaFeedbackCrashSubmissionSummary
    ) -> String {
        renderBetaFeedbackCrashSubmissionLine(submission) + "\n"
    }

    private static func renderBetaFeedbackCrashSubmissionLine(
        _ submission: AppStoreConnectBetaFeedbackCrashSubmissionSummary
    ) -> String {
        [
            submission.id,
            submission.buildID,
            submission.testerID,
            submission.deviceModel,
            submission.osVersion,
            submission.appPlatform,
            submission.createdDate.map(iso8601String),
            submission.comment,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderBetaFeedbackScreenshotSubmissions(
        _ submissions: [AppStoreConnectBetaFeedbackScreenshotSubmissionSummary]
    ) -> String {
        if submissions.isEmpty {
            return "No beta feedback screenshot submissions found.\n"
        }
        return submissions.map(renderBetaFeedbackScreenshotSubmissionLine).joined(separator: "\n") + "\n"
    }

    private static func renderBetaFeedbackScreenshotSubmission(
        _ submission: AppStoreConnectBetaFeedbackScreenshotSubmissionSummary
    ) -> String {
        renderBetaFeedbackScreenshotSubmissionLine(submission) + "\n"
    }

    private static func renderBetaFeedbackScreenshotSubmissionLine(
        _ submission: AppStoreConnectBetaFeedbackScreenshotSubmissionSummary
    ) -> String {
        [
            submission.id,
            submission.buildID,
            submission.testerID,
            submission.deviceModel,
            submission.osVersion,
            submission.appPlatform,
            String(submission.screenshotCount),
            submission.createdDate.map(iso8601String),
            submission.comment,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderBetaCrashLog(_ log: AppStoreConnectBetaCrashLogSummary) -> String {
        [
            log.id,
            log.logText,
        ]
            .compactMap { $0 }
            .joined(separator: "\t") + "\n"
    }

    private static func renderBetaTesterUsageMetrics(
        _ metrics: [AppStoreConnectBetaTesterUsageMetricSeries]
    ) -> String {
        if metrics.isEmpty {
            return "No beta tester usage metrics found.\n"
        }
        return metrics
            .flatMap { series -> [String] in
                if series.dataPoints.isEmpty {
                    return [renderBetaTesterUsageMetricLine(series, point: nil)]
                }
                return series.dataPoints.map { renderBetaTesterUsageMetricLine(series, point: $0) }
            }
            .joined(separator: "\n") + "\n"
    }

    private static func renderBetaTesterUsageMetricLine(
        _ series: AppStoreConnectBetaTesterUsageMetricSeries,
        point: AppStoreConnectBetaTesterUsageMetricPoint?
    ) -> String {
        let start = point?.start.map(iso8601String)
        let end = point?.end.map(iso8601String)
        let sessionCount = point?.sessionCount.map { String($0) }
        let crashCount = point?.crashCount.map { String($0) }
        let feedbackCount = point?.feedbackCount.map { String($0) }
        let columns: [String?] = [
            series.scope,
            series.appID,
            series.groupID,
            series.testerID,
            start,
            end,
            sessionCount,
            crashCount,
            feedbackCount,
        ]
        return columns.compactMap { $0 }.joined(separator: "\t")
    }

    private static func renderBetaPublicLinkUsageMetrics(
        _ metrics: [AppStoreConnectBetaPublicLinkUsageMetricSeries]
    ) -> String {
        if metrics.isEmpty {
            return "No beta public link usage metrics found.\n"
        }
        return metrics
            .flatMap { series -> [String] in
                if series.dataPoints.isEmpty {
                    return [renderBetaPublicLinkUsageMetricLine(series, point: nil)]
                }
                return series.dataPoints.map { renderBetaPublicLinkUsageMetricLine(series, point: $0) }
            }
            .joined(separator: "\n") + "\n"
    }

    private static func renderBetaPublicLinkUsageMetricLine(
        _ series: AppStoreConnectBetaPublicLinkUsageMetricSeries,
        point: AppStoreConnectBetaPublicLinkUsageMetricPoint?
    ) -> String {
        let start = point?.start.map(iso8601String)
        let end = point?.end.map(iso8601String)
        let viewCount = point?.viewCount.map { String($0) }
        let acceptedCount = point?.acceptedCount.map { String($0) }
        let didNotAcceptCount = point?.didNotAcceptCount.map { String($0) }
        let didNotMeetCriteriaCount = point?.didNotMeetCriteriaCount.map { String($0) }
        let notClearRatio = point?.notClearRatio.map { String($0) }
        let notInterestingRatio = point?.notInterestingRatio.map { String($0) }
        let notRelevantRatio = point?.notRelevantRatio.map { String($0) }
        let columns: [String?] = [
            series.groupID,
            start,
            end,
            viewCount,
            acceptedCount,
            didNotAcceptCount,
            didNotMeetCriteriaCount,
            notClearRatio,
            notInterestingRatio,
            notRelevantRatio,
        ]
        return columns.compactMap { $0 }.joined(separator: "\t")
    }

    private static func renderBetaBuildUsageMetrics(
        _ metrics: [AppStoreConnectBetaBuildUsageMetricSeries]
    ) -> String {
        if metrics.isEmpty {
            return "No beta build usage metrics found.\n"
        }
        return metrics
            .flatMap { series -> [String] in
                if series.dataPoints.isEmpty {
                    return [renderBetaBuildUsageMetricLine(series, point: nil)]
                }
                return series.dataPoints.map { renderBetaBuildUsageMetricLine(series, point: $0) }
            }
            .joined(separator: "\n") + "\n"
    }

    private static func renderBetaBuildUsageMetricLine(
        _ series: AppStoreConnectBetaBuildUsageMetricSeries,
        point: AppStoreConnectBetaBuildUsageMetricPoint?
    ) -> String {
        let start = point?.start.map(iso8601String)
        let end = point?.end.map(iso8601String)
        let installCount = point?.installCount.map { String($0) }
        let inviteCount = point?.inviteCount.map { String($0) }
        let sessionCount = point?.sessionCount.map { String($0) }
        let crashCount = point?.crashCount.map { String($0) }
        let feedbackCount = point?.feedbackCount.map { String($0) }
        let columns: [String?] = [
            series.buildID,
            start,
            end,
            installCount,
            inviteCount,
            sessionCount,
            crashCount,
            feedbackCount,
        ]
        return columns.compactMap { $0 }.joined(separator: "\t")
    }

    private static func renderAnalyticsReport(_ report: AppStoreConnectAnalyticsReportSummary) -> String {
        [
            report.id,
            report.category,
            report.name,
        ]
            .compactMap { $0 }
            .joined(separator: "\t") + "\n"
    }

    private static func renderAnalyticsReportRequest(_ request: AppStoreConnectAnalyticsReportRequestSummary) -> String {
        [
            request.id,
            request.accessType,
            request.stoppedDueToInactivity.map(String.init),
            request.reportIDs.isEmpty ? nil : request.reportIDs.joined(separator: ","),
            request.includedReports.isEmpty ? nil : request.includedReports.map(\.id).joined(separator: ","),
        ]
            .compactMap { $0 }
            .joined(separator: "\t") + "\n"
    }

    private static func renderAnalyticsReportSegment(_ segment: AppStoreConnectAnalyticsReportSegmentSummary) -> String {
        [
            segment.id,
            segment.sizeInBytes.map(String.init),
            segment.checksum,
            segment.url,
        ]
            .compactMap { $0 }
            .joined(separator: "\t") + "\n"
    }

    private static func renderAnalyticsReportInstance(_ instance: AppStoreConnectAnalyticsReportInstanceSummary) -> String {
        [
            instance.id,
            instance.granularity,
            instance.processingDate,
        ]
            .compactMap { $0 }
            .joined(separator: "\t") + "\n"
    }

    private static func renderReportDownload(_ download: AppStoreConnectReportDownloadSummary) -> String {
        [
            download.kind,
            download.outputPath,
            String(download.byteCount),
            download.vendorNumber,
            download.reportType,
            download.reportSubType,
            download.frequency,
            download.regionCode,
            download.reportDate,
            download.version,
        ]
            .compactMap { $0 }
            .joined(separator: "\t") + "\n"
    }

#if ASC_PUBLIC_API_REPORTS
    private static func renderPerformanceMetrics(_ metrics: AppStoreConnectPerformanceMetricsSummary) -> String {
        [
            metrics.scope,
            metrics.appID,
            metrics.buildID,
            metrics.operationID,
            metrics.version,
            String(metrics.productDataCount),
            String(metrics.metricCategoryCount),
            String(metrics.metricCount),
            String(metrics.datasetCount),
            String(metrics.pointCount),
            String(metrics.regressionCount),
            String(metrics.trendingUpCount),
            metrics.metricCategories.isEmpty ? nil : metrics.metricCategories.joined(separator: ","),
            metrics.metrics.isEmpty ? nil : metrics.metrics.joined(separator: ","),
        ]
            .compactMap { $0 }
            .joined(separator: "\t") + "\n"
    }

    private static func renderPerformanceMetricsDownload(
        _ download: AppStoreConnectPerformanceMetricsDownloadSummary
    ) -> String {
        [
            download.metrics.scope,
            download.outputPath,
            String(download.byteCount),
            download.metrics.appID,
            download.metrics.buildID,
            download.metrics.operationID,
            String(download.metrics.productDataCount),
            String(download.metrics.metricCategoryCount),
            String(download.metrics.metricCount),
            String(download.metrics.datasetCount),
            String(download.metrics.pointCount),
        ]
            .compactMap { $0 }
            .joined(separator: "\t") + "\n"
    }
#endif

    private static func renderMutationPlan(_ plan: AppStoreConnectPublicAPIMutationPlan) -> String {
        var lines = [
            "Dry run \(plan.operationID)",
            "Source: \(plan.source.rawValue)",
            "Mutates: \(plan.mutates)",
            plan.commandDescription,
        ]
        lines += plan.inputs
            .sorted { $0.key < $1.key }
            .map { "- \($0.key): \($0.value)" }
        return lines.joined(separator: "\n") + "\n"
    }

    private static func renderMutationAcknowledgement(_ acknowledgement: AppStoreConnectMutationAcknowledgement) -> String {
        [
            acknowledgement.status,
            acknowledgement.resourceType,
            acknowledgement.id,
            acknowledgement.operationID,
        ].joined(separator: "\t") + "\n"
    }

    private static func renderBetaTesterInvitation(_ invitation: AppStoreConnectBetaTesterInvitationSummary) -> String {
        [
            invitation.id,
            invitation.appID,
        ]
            .joined(separator: "\t") + "\n"
    }

    private static func iso8601String(from date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }

    private static func iso8601DateOption(from parsed: ParsedArguments, names: [String]) throws -> Date? {
        guard let value = parsed.firstOption(names) else {
            return nil
        }
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: value) else {
            throw CLIError(exitCode: 64, message: "Invalid ISO-8601 date value: \(value).")
        }
        return date
    }

    private static func dateStringOption(from parsed: ParsedArguments, names: [String]) throws -> String? {
        guard let value = parsed.firstOption(names) else {
            return nil
        }
        if isValidDateString(value) {
            return value
        }
        throw CLIError(exitCode: 64, message: "Invalid date value: \(value). Use yyyy-MM-dd or ISO-8601.")
    }

    private static func isValidDateString(_ value: String) -> Bool {
        let dateOnly = DateFormatter()
        dateOnly.locale = Locale(identifier: "en_US_POSIX")
        dateOnly.timeZone = TimeZone(secondsFromGMT: 0)
        dateOnly.dateFormat = "yyyy-MM-dd"
        if dateOnly.date(from: value) != nil {
            return true
        }
        return ISO8601DateFormatter().date(from: value) != nil
    }

    private static func renderBundleIDs(_ bundleIDs: [AppStoreConnectBundleIDSummary]) -> String {
        if bundleIDs.isEmpty {
            return "No bundle IDs found.\n"
        }
        return bundleIDs.map(renderBundleIDLine).joined(separator: "\n") + "\n"
    }

    private static func renderBundleID(_ bundleID: AppStoreConnectBundleIDSummary) -> String {
        renderBundleIDLine(bundleID) + "\n"
    }

    private static func renderBundleIDLine(_ bundleID: AppStoreConnectBundleIDSummary) -> String {
        [
            bundleID.id,
            bundleID.identifier,
            bundleID.name,
            bundleID.platform,
            bundleID.seedID,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderBundleIDCapabilities(_ capabilities: [AppStoreConnectBundleIDCapabilitySummary]) -> String {
        if capabilities.isEmpty {
            return "No bundle ID capabilities found.\n"
        }
        return capabilities.map(renderBundleIDCapabilityLine).joined(separator: "\n") + "\n"
    }

    private static func renderBundleIDCapability(_ capability: AppStoreConnectBundleIDCapabilitySummary) -> String {
        renderBundleIDCapabilityLine(capability) + "\n"
    }

    private static func renderBundleIDCapabilityLine(_ capability: AppStoreConnectBundleIDCapabilitySummary) -> String {
        [
            capability.id,
            capability.capabilityType,
            capability.settingKeys.isEmpty ? nil : capability.settingKeys.joined(separator: ","),
            String(capability.settingCount),
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderCertificates(_ certificates: [AppStoreConnectCertificateSummary]) -> String {
        if certificates.isEmpty {
            return "No certificates found.\n"
        }
        return certificates.map(renderCertificateLine).joined(separator: "\n") + "\n"
    }

    private static func renderCertificate(_ certificate: AppStoreConnectCertificateSummary) -> String {
        renderCertificateLine(certificate) + "\n"
    }

    private static func renderCertificateLine(_ certificate: AppStoreConnectCertificateSummary) -> String {
        [
            certificate.id,
            certificate.displayName ?? certificate.name,
            certificate.certificateType,
            certificate.serialNumber,
            certificate.platform,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderCertificateDownload(_ download: AppStoreConnectCertificateDownloadSummary) -> String {
        [
            download.id,
            download.outputPath,
            String(download.byteCount),
            download.displayName ?? download.name,
            download.certificateType,
            download.serialNumber,
            download.operationID,
        ]
            .compactMap { $0 }
            .joined(separator: "\t") + "\n"
    }

    private static func renderDevices(_ devices: [AppStoreConnectDeviceSummary]) -> String {
        if devices.isEmpty {
            return "No devices found.\n"
        }
        return devices.map(renderDeviceLine).joined(separator: "\n") + "\n"
    }

    private static func renderDevice(_ device: AppStoreConnectDeviceSummary) -> String {
        renderDeviceLine(device) + "\n"
    }

    private static func renderDeviceLine(_ device: AppStoreConnectDeviceSummary) -> String {
        [
            device.id,
            device.name,
            device.udid,
            device.platform,
            device.status,
            device.deviceClass,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderProfiles(_ profiles: [AppStoreConnectProfileSummary]) -> String {
        if profiles.isEmpty {
            return "No profiles found.\n"
        }
        return profiles.map(renderProfileLine).joined(separator: "\n") + "\n"
    }

    private static func renderProfile(_ profile: AppStoreConnectProfileSummary) -> String {
        renderProfileLine(profile) + "\n"
    }

    private static func renderProfileLine(_ profile: AppStoreConnectProfileSummary) -> String {
        [
            profile.id,
            profile.name,
            profile.profileType,
            profile.profileState,
            profile.platform,
            profile.bundleID,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderProfileDownload(_ download: AppStoreConnectProfileDownloadSummary) -> String {
        [
            download.id,
            download.outputPath,
            String(download.byteCount),
            download.uuid,
            download.profileType,
            download.operationID,
        ]
            .compactMap { $0 }
            .joined(separator: "\t") + "\n"
    }

    private static func renderUsers(_ users: [AppStoreConnectUserSummary]) -> String {
        if users.isEmpty {
            return "No users found.\n"
        }
        return users.map(renderUserLine).joined(separator: "\n") + "\n"
    }

    private static func renderUser(_ user: AppStoreConnectUserSummary) -> String {
        renderUserLine(user) + "\n"
    }

    private static func renderUserLine(_ user: AppStoreConnectUserSummary) -> String {
        [
            user.id,
            user.username,
            user.firstName,
            user.lastName,
            user.roles.isEmpty ? nil : user.roles.joined(separator: ","),
            user.visibleAppIDs.isEmpty ? nil : user.visibleAppIDs.joined(separator: ","),
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

#if ASC_PUBLIC_API_SIGNING_ACCESS
    private static func renderActors(_ actors: [AppStoreConnectActorSummary]) -> String {
        if actors.isEmpty {
            return "No actors found.\n"
        }
        return actors.map(renderActorLine).joined(separator: "\n") + "\n"
    }

    private static func renderActor(_ actor: AppStoreConnectActorSummary) -> String {
        renderActorLine(actor) + "\n"
    }

    private static func renderActorLine(_ actor: AppStoreConnectActorSummary) -> String {
        [
            actor.id,
            actor.actorType,
            actor.userEmail,
            actor.userFirstName,
            actor.userLastName,
            actor.apiKeyID,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }
#endif

    private static func renderUserInvitations(_ invitations: [AppStoreConnectUserInvitationSummary]) -> String {
        if invitations.isEmpty {
            return "No user invitations found.\n"
        }
        return invitations.map(renderUserInvitationLine).joined(separator: "\n") + "\n"
    }

    private static func renderUserInvitation(_ invitation: AppStoreConnectUserInvitationSummary) -> String {
        renderUserInvitationLine(invitation) + "\n"
    }

    private static func renderUserInvitationLine(_ invitation: AppStoreConnectUserInvitationSummary) -> String {
        [
            invitation.id,
            invitation.email,
            invitation.firstName,
            invitation.lastName,
            invitation.roles.isEmpty ? nil : invitation.roles.joined(separator: ","),
            invitation.visibleAppIDs.isEmpty ? nil : invitation.visibleAppIDs.joined(separator: ","),
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

#if ASC_PUBLIC_API_RELEASE
    private static func renderCustomerReviews(_ reviews: [AppStoreConnectCustomerReviewSummary]) -> String {
        if reviews.isEmpty {
            return "No customer reviews found.\n"
        }
        return reviews.map(renderCustomerReviewLine).joined(separator: "\n") + "\n"
    }

    private static func renderCustomerReview(_ review: AppStoreConnectCustomerReviewSummary) -> String {
        renderCustomerReviewLine(review) + "\n"
    }

    private static func renderCustomerReviewLine(_ review: AppStoreConnectCustomerReviewSummary) -> String {
        [
            review.id,
            review.rating.map(String.init),
            review.territory,
            review.reviewerNickname,
            review.title,
            review.responseID,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderCustomerReviewResponse(
        _ response: AppStoreConnectCustomerReviewResponseSummary
    ) -> String {
        [
            response.id,
            response.state,
            response.reviewID,
            response.responseBody,
        ]
            .compactMap { $0 }
            .joined(separator: "\t") + "\n"
    }

    private static func renderCustomerReviewSummarizations(
        _ summarizations: [AppStoreConnectCustomerReviewSummarizationSummary]
    ) -> String {
        if summarizations.isEmpty {
            return "No customer review summarizations found.\n"
        }
        return summarizations.map(renderCustomerReviewSummarizationLine).joined(separator: "\n") + "\n"
    }

    private static func renderCustomerReviewSummarizationLine(
        _ summarization: AppStoreConnectCustomerReviewSummarizationSummary
    ) -> String {
        [
            summarization.id,
            summarization.platform,
            summarization.locale,
            summarization.territoryID,
            summarization.text,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }
#endif

    private static func renderReviewSubmissions(_ submissions: [AppStoreConnectReviewSubmissionSummary]) -> String {
        if submissions.isEmpty {
            return "No review submissions found.\n"
        }
        return submissions.map(renderReviewSubmissionLine).joined(separator: "\n") + "\n"
    }

    private static func renderReviewSubmission(_ submission: AppStoreConnectReviewSubmissionSummary) -> String {
        renderReviewSubmissionLine(submission) + "\n"
    }

    private static func renderReviewSubmissionLine(_ submission: AppStoreConnectReviewSubmissionSummary) -> String {
        [
            submission.id,
            submission.platform,
            submission.state,
            submission.appID,
            submission.appStoreVersionID,
        ]
            .compactMap { $0 }
            .joined(separator: "\t")
    }

    private static func renderAppStoreVersionReleaseRequest(
        _ request: AppStoreConnectAppStoreVersionReleaseRequestSummary
    ) -> String {
        [
            request.id,
            request.appStoreVersionID,
        ]
            .compactMap { $0 }
            .joined(separator: "\t") + "\n"
    }

    private static func renderReviewSubmissionItem(_ item: AppStoreConnectReviewSubmissionItemSummary) -> String {
        [
            item.id,
            item.state,
            item.reviewSubmissionID,
            item.appStoreVersionID,
        ]
            .compactMap { $0 }
            .joined(separator: "\t") + "\n"
    }

    private static func renderStatus(_ result: AppStoreConnectStatusResult) -> String {
        var lines = ["Status for \(renderAppLine(result.app))"]
        if let version = result.appStoreVersion {
            lines.append([
                "Version",
                version.id,
                version.versionString,
                version.platform,
                version.appStoreState,
                version.appVersionState,
            ].compactMap { $0 }.joined(separator: "\t"))
        }
        if result.reviewSubmissions.isEmpty {
            lines.append("No review submissions found.")
        } else {
            lines += result.reviewSubmissions.map { submission in
                [
                    "ReviewSubmission",
                    submission.id,
                    submission.platform,
                    submission.state,
                    submission.appStoreVersionID,
                ].compactMap { $0 }.joined(separator: "\t")
            }
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private static func buildWaitExitCode(_ result: AppStoreConnectBuildWaitResult) -> Int32 {
        result.status == .succeeded ? 0 : 2
    }

    private static func renderPlan(_ plan: WorkflowPlan) -> String {
        var lines = ["Workflow \(plan.workflow.rawValue)"]
        lines += plan.steps.map {
            "- \($0.id) [\($0.source.rawValue)] \($0.commandDescription)"
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private static func renderRunResult(_ result: WorkflowRunResult) -> String {
        var lines = ["Workflow \(result.workflow.rawValue)"]
        lines += result.steps.map {
            "- \($0.stepID): \($0.status.rawValue)"
        }
        return lines.joined(separator: "\n") + "\n"
    }

    private static func renderDryRunResult(_ result: WorkflowFileDryRunResult) -> String {
        if !result.validationIssues.isEmpty {
            return result.validationIssues
                .map { "\($0.path): \($0.message)" }
                .joined(separator: "\n") + "\n"
        }

        return renderPlan(result.plan)
    }

    private static let helpText = """
    Usage:
      appstoreconnect commands list [--json]
      appstoreconnect workflows list [--json]
      appstoreconnect workflow list [--json]
      appstoreconnect workflow dry-run public-release-readiness --app-id <id> [--app-store-version-id <id>] [--screenshot-set-id <id>] [--skip-builds] [--skip-testflight-groups] [--json]
      appstoreconnect workflow run public-release-readiness --app-id <id> [--json]
      appstoreconnect workflow run [--file .asc/workflow.json] [--json]
      appstoreconnect workflow validate [--file .asc/workflow.json] [--json]
      appstoreconnect workflow-file dry-run [--path .asc/workflow.json] [--json]
      appstoreconnect workflow-file run [--path .asc/workflow.json] [--json]
      appstoreconnect auth status [--session-file <path>] [--browser-cookie-file <path>] [--include-cookie-names] [--json]
      appstoreconnect auth doctor [--session-file <path>] [--browser-cookie-file <path>] [--include-cookie-names] [--json]
      appstoreconnect auth logout [--session-file <path>] [--dry-run | --confirm] [--json]
      appstoreconnect xcode version [--xcodebuild <path>] [--developer-dir <path>] [--dry-run] [--json]
      appstoreconnect xcode archive (--workspace <path> | --project <path>) --scheme <scheme> --archive-path <path> [--configuration Release] [--destination <destination>] [--allow-provisioning-updates] [--dry-run | --confirm] [--json]
      appstoreconnect xcode export --archive-path <path> --export-path <path> --export-options-plist <path> [--dry-run | --confirm] [--json]
      appstoreconnect xcode upload --file <ipa-or-pkg> [--api-key <key-id>] [--api-issuer <issuer-id>] [--transport transporter|altool] [--dry-run | --confirm] [--json]
      appstoreconnect apps list [--id <id>] [--bundle-id <bundle-id>] [--name <name>] [--sku <sku>] [--limit <n>] [--json]
      appstoreconnect apps view --id <id> [--json]
      appstoreconnect apps update --id <app-id> [--primary-locale en-US] [--content-rights DOES_NOT_USE_THIRD_PARTY_CONTENT] [--dry-run | --confirm] [--json]
      appstoreconnect categories list [--platform IOS] [--root-only | --exists-parent true] [--include-subcategories] [--limit <n>] [--json]  (requires PublicAPIRelease trait)
      appstoreconnect categories view --id <category-id> [--include-parent] [--include-subcategories] [--json]  (requires PublicAPIRelease trait)
      appstoreconnect categories parent --id <category-id> [--json]  (requires PublicAPIRelease trait)
      appstoreconnect categories subcategories --id <category-id> [--limit <n>] [--json]  (requires PublicAPIRelease trait)
      appstoreconnect categories set --app-info-id <app-info-id> [--primary-category <id>] [--secondary-category <id>] [--primary-subcategory-one <id>] [--dry-run | --confirm] [--json]  (requires PublicAPIRelease trait)
      appstoreconnect age-rating view --app-info-id <app-info-id> [--json]  (requires PublicAPIRelease trait)
      appstoreconnect age-rating update --id <declaration-id> [--all-none] [--violence-realistic NONE] [--gambling false] [--kids-age-band NINE_TO_ELEVEN] [--dry-run | --confirm] [--json]  (requires PublicAPIRelease trait)
      appstoreconnect app-events list --app <app-id> [--state DRAFT] [--include-localizations] [--limit <n>] [--json]  (requires PublicAPIRelease trait)
      appstoreconnect app-events view --id <event-id> [--include-localizations] [--json]  (requires PublicAPIRelease trait)
      appstoreconnect app-events create --app <app-id> --reference-name <name> [--badge LIVE_EVENT] [--purpose ATTRACT_NEW_USERS] [--dry-run | --confirm] [--json]  (requires PublicAPIRelease trait)
      appstoreconnect app-events update --id <event-id> [--reference-name <name>] [--dry-run | --confirm] [--json]  (requires PublicAPIRelease trait)
      appstoreconnect app-events delete --id <event-id> [--dry-run | --confirm] [--json]  (requires PublicAPIRelease trait)
      appstoreconnect app-clips list --app <app-id> [--bundle-id <bundle-id>] [--include-default-experiences] [--limit <n>] [--json]  (requires PublicAPIMetadataMedia trait)
      appstoreconnect app-clips view --id <app-clip-id> [--include-default-experiences] [--json]  (requires PublicAPIMetadataMedia trait)
      appstoreconnect app-clips default-experiences list --app-clip <app-clip-id> [--include-localizations] [--limit <n>] [--json]  (requires PublicAPIMetadataMedia trait)
      appstoreconnect app-clips default-experiences view --id <experience-id> [--include-localizations] [--json]  (requires PublicAPIMetadataMedia trait)
      appstoreconnect app-clips localizations list --default-experience <experience-id> [--locale en-US] [--limit <n>] [--json]  (requires PublicAPIMetadataMedia trait)
      appstoreconnect app-clips localizations view --id <localization-id> [--json]  (requires PublicAPIMetadataMedia trait)
      appstoreconnect game-center details app --app <app-id> [--include-achievements] [--include-leaderboards] [--json]  (requires PublicAPIGameCenter trait)
      appstoreconnect game-center details view --id <detail-id> [--include-achievements] [--include-leaderboards] [--json]  (requires PublicAPIGameCenter trait)
      appstoreconnect game-center achievements list --detail <detail-id> [--reference-name <name>] [--limit <n>] [--json]  (requires PublicAPIGameCenter trait)
      appstoreconnect game-center achievements view --id <achievement-id> [--json]  (requires PublicAPIGameCenter trait)
      appstoreconnect game-center leaderboards list --detail <detail-id> [--reference-name <name>] [--limit <n>] [--json]  (requires PublicAPIGameCenter trait)
      appstoreconnect game-center leaderboards view --id <leaderboard-id> [--json]  (requires PublicAPIGameCenter trait)
      appstoreconnect game-center leaderboard-sets list --detail <detail-id> [--reference-name <name>] [--limit <n>] [--json]  (requires PublicAPIGameCenter trait)
      appstoreconnect game-center leaderboard-sets view --id <leaderboard-set-id> [--json]  (requires PublicAPIGameCenter trait)
      appstoreconnect game-center challenges list --detail <detail-id> [--reference-name <name>] [--limit <n>] [--json]  (requires PublicAPIGameCenter trait)
      appstoreconnect game-center challenges view --id <challenge-id> [--json]  (requires PublicAPIGameCenter trait)
      appstoreconnect alternative-distribution domains list [--field domain,referenceName,createdDate] [--limit <n>] [--json]  (requires PublicAPIDistribution trait)
      appstoreconnect alternative-distribution domains view --id <domain-id> [--field domain,referenceName,createdDate] [--json]  (requires PublicAPIDistribution trait)
      appstoreconnect alternative-distribution keys list [--exists-app true] [--field publicKey] [--limit <n>] [--json]  (requires PublicAPIDistribution trait)
      appstoreconnect alternative-distribution keys view --id <key-id> [--field publicKey] [--json]  (requires PublicAPIDistribution trait)
      appstoreconnect marketplace webhooks list [--field endpointUrl] [--limit <n>] [--json]  (requires PublicAPIDistribution trait)
      appstoreconnect webhooks list --app <app-id> [--field name,url,enabled,eventTypes] [--include-app] [--limit <n>] [--json]  (requires PublicAPIDistribution trait)
      appstoreconnect webhooks view --id <webhook-id> [--field name,url,enabled,eventTypes] [--include-app] [--json]  (requires PublicAPIDistribution trait)
      appstoreconnect webhooks create --app <app-id> --name <name> --url <url> --secret <secret> --events <event-types> --enabled true [--dry-run | --confirm] [--json]  (requires PublicAPIDistribution trait)
      appstoreconnect webhooks update --id <webhook-id> [--name <name>] [--url <url>] [--secret <secret>] [--events <event-types>] [--enabled true|false] [--dry-run | --confirm] [--json]  (requires PublicAPIDistribution trait)
      appstoreconnect webhooks delete --id <webhook-id> [--dry-run | --confirm] [--json]  (requires PublicAPIDistribution trait)
      appstoreconnect webhooks deliveries --id <webhook-id> [--state SUCCEEDED,FAILED] [--created-after <date>] [--created-before <date>] [--include-event] [--limit <n>] [--json]  (requires PublicAPIDistribution trait)
      appstoreconnect webhooks deliveries links --id <webhook-id> [--limit <n>] [--json]  (requires PublicAPIDistribution trait)
      appstoreconnect webhooks deliveries redeliver --delivery-id <delivery-id> [--dry-run | --confirm] [--json]  (requires PublicAPIDistribution trait)
      appstoreconnect webhooks ping --id <webhook-id> [--dry-run | --confirm] [--json]  (requires PublicAPIDistribution trait)
      appstoreconnect eula view --id <eula-id> [--field agreementText,territories] [--include-app] [--include-territories] [--territories-limit <n>] [--json]  (requires PublicAPIDistribution trait)
      appstoreconnect eula create --app <app-id> --text <text> --territory USA [--dry-run | --confirm] [--json]  (requires PublicAPIDistribution trait)
      appstoreconnect eula update --id <eula-id> [--text <text> | --text-path <path>] [--territory USA] [--dry-run | --confirm] [--json]  (requires PublicAPIDistribution trait)
      appstoreconnect eula delete --id <eula-id> [--dry-run | --confirm] [--json]  (requires PublicAPIDistribution trait)
      appstoreconnect territories list [--field currency] [--limit <n>] [--json]  (requires PublicAPIDistribution trait)
      appstoreconnect xcode-cloud products list [--type APP] [--app <app-id>] [--include-app] [--include-bundle-id] [--include-primary-repositories] [--limit <n>] [--json]  (requires PublicAPICloud trait)
      appstoreconnect xcode-cloud products view --id <product-id> [--json]  (requires PublicAPICloud trait)
      appstoreconnect xcode-cloud workflows list --product <product-id> [--include-repository] [--limit <n>] [--json]  (requires PublicAPICloud trait)
      appstoreconnect xcode-cloud workflows view --id <workflow-id> [--json]  (requires PublicAPICloud trait)
      appstoreconnect xcode-cloud runs list (--workflow <workflow-id> | --product <product-id>) [--sort -number] [--limit <n>] [--json]  (requires PublicAPICloud trait)
      appstoreconnect xcode-cloud runs view --id <run-id> [--include-builds] [--json]  (requires PublicAPICloud trait)
      appstoreconnect xcode-cloud actions list --run <run-id> [--include-build-run] [--limit <n>] [--json]  (requires PublicAPICloud trait)
      appstoreconnect xcode-cloud actions view --id <action-id> [--json]  (requires PublicAPICloud trait)
      appstoreconnect xcode-cloud artifacts list --action <action-id> [--limit <n>] [--json]  (requires PublicAPICloud trait)
      appstoreconnect xcode-cloud logs list --action <action-id> [--limit <n>] [--json]  (requires PublicAPICloud trait)
      appstoreconnect builds list [--app <id>] [--version <version>] [--build-number <number>] [--platform IOS] [--processing-state VALID] [--limit <n>] [--json]
      appstoreconnect builds info (--build-id <id> | --app <id> --latest) [--json]
      appstoreconnect builds wait (--build-id <id> | --app <id> --latest) [--target-processing-state VALID] [--max-attempts <n>] [--interval <seconds>] [--json]
      appstoreconnect builds beta-details list [--build <id>] [--limit <n>] [--json]
      appstoreconnect builds beta-details view --id <build-beta-detail-id> [--json]
      appstoreconnect prerelease list [--app <id>] [--version <version>] [--platform IOS] [--build <id>] [--processing-state VALID] [--limit <n>] [--json]
      appstoreconnect prerelease view --id <pre-release-version-id> [--json]
      appstoreconnect versions list --app <id> [--version <version>] [--platform IOS] [--app-version-state READY_FOR_REVIEW] [--limit <n>] [--json]
      appstoreconnect versions view --id <version-id> [--json]
      appstoreconnect versions create --app <id> --version <version> --platform IOS [--build <id>] [--release-type MANUAL] [--dry-run | --confirm] [--json]
      appstoreconnect versions update --id <version-id> [--build <id>] [--release-type AFTER_APPROVAL] [--dry-run | --confirm] [--json]
      appstoreconnect versions delete --id <version-id> [--dry-run | --confirm] [--json]
      appstoreconnect versions release --id <version-id> [--dry-run | --confirm] [--json]
      appstoreconnect release request --version-id <version-id> [--dry-run | --confirm] [--json]
      appstoreconnect release submit --version-id <version-id> [--dry-run | --confirm] [--json]
      appstoreconnect metadata validate [--path <metadata-dir-or-json>] [--json]
      appstoreconnect metadata pull [--app <id>] [--version-id <id>] [--locale en-US] [--path <metadata-dir>] [--dry-run] [--json]
      appstoreconnect metadata push [--path <metadata-dir>] [--app <id>] [--version-id <id>] [--locale en-US] [--dry-run] [--json]
      appstoreconnect metadata keywords --id <version-localization-id> --keywords <text> [--dry-run] [--json]
      appstoreconnect screenshots list --set <screenshot-set-id> [--limit <n>] [--json]
      appstoreconnect screenshots view --id <screenshot-id> [--json]
      appstoreconnect video-previews list --set <preview-set-id> [--limit <n>] [--json]
      appstoreconnect video-previews view --id <preview-id> [--json]
      appstoreconnect testflight builds list [--app <id>] [--version <version>] [--build-number <number>] [--platform IOS] [--processing-state VALID] [--limit <n>] [--json]
      appstoreconnect testflight builds view (--build-id <id> | --id <id> | --app <id> --latest) [--json]
      appstoreconnect testflight builds wait (--build-id <id> | --app <id> --latest) [--target-processing-state VALID] [--max-attempts <n>] [--interval <seconds>] [--json]
      appstoreconnect testflight builds beta-details list [--build <id>] [--limit <n>] [--json]
      appstoreconnect testflight builds localizations list [--build <id>] [--locale <locale>] [--limit <n>] [--json]
      appstoreconnect testflight builds review-submissions list --build <id> [--beta-review-state IN_REVIEW] [--limit <n>] [--json]
      appstoreconnect testflight groups list [--app <id>] [--name <name>] [--limit <n>] [--json]
      appstoreconnect testflight groups view --id <group-id> [--json]
      appstoreconnect testflight groups create --app <id> --name <name> [--dry-run | --confirm] [--json]
      appstoreconnect testflight groups update --id <group-id> [--name <name>] [--dry-run | --confirm] [--json]
      appstoreconnect testflight groups delete --id <group-id> [--dry-run | --confirm] [--json]
      appstoreconnect testflight testers list [--app <id>] [--group <group-id>] [--email <email>] [--invite-type EMAIL] [--limit <n>] [--json]
      appstoreconnect testflight testers view --id <tester-id> [--json]
      appstoreconnect testflight testers create --email <email> [--group <group-id>] [--dry-run | --confirm] [--json]
      appstoreconnect testflight testers delete --id <tester-id> [--dry-run | --confirm] [--json]
      appstoreconnect testflight app-localizations list [--app <id>] [--locale <locale>] [--limit <n>] [--json]
      appstoreconnect testflight app-localizations view --id <localization-id> [--json]
      appstoreconnect testflight build-localizations list [--build <id>] [--locale <locale>] [--limit <n>] [--json]
      appstoreconnect testflight build-localizations view --id <localization-id> [--json]
      appstoreconnect testflight review-details list --app <id> [--limit <n>] [--json]
      appstoreconnect testflight review-details view --id <review-detail-id> [--json]
      appstoreconnect testflight review-details update --id <review-detail-id> [--contact-email <email>] [--dry-run | --confirm] [--json]
      appstoreconnect testflight review-submissions list --build <id> [--beta-review-state IN_REVIEW] [--limit <n>] [--json]
      appstoreconnect testflight review-submissions view --id <review-submission-id> [--json]
      appstoreconnect testflight review-submissions create --build <id> [--dry-run | --confirm] [--json]
      appstoreconnect testflight license-agreements list [--app <id>] [--limit <n>] [--json]
      appstoreconnect testflight license-agreements view --id <license-agreement-id> [--json]
      appstoreconnect testflight feedback list --app <id> [--build <id>] [--tester <id>] [--device-model <model>] [--limit <n>] [--json]
      appstoreconnect testflight feedback view --id <feedback-id> [--json]
      appstoreconnect testflight crashes list --app <id> [--build <id>] [--tester <id>] [--device-model <model>] [--limit <n>] [--json]
      appstoreconnect testflight crashes view --id <crash-id> [--json]
      appstoreconnect testflight crashes log --id <crash-id> [--json]
      appstoreconnect testflight crash-logs view --id <crash-log-id> [--json]
      appstoreconnect testflight metrics beta-tester-usages (--app <id> | --group <id> | --tester <id> --app <id>) [--period P7D] [--group-by-beta-testers] [--limit <n>] [--json]
      appstoreconnect testflight metrics public-link-usages --group <group-id> [--limit <n>] [--json]
      appstoreconnect testflight metrics beta-build-usages --build <build-id> [--limit <n>] [--json]
      appstoreconnect testflight invitations create --app <id> [--dry-run | --confirm] [--json]
      appstoreconnect bundle-ids list [--identifier <bundle-id>] [--platform IOS] [--limit <n>] [--json]
      appstoreconnect bundle-ids view --id <bundle-id-resource-id> [--json]
      appstoreconnect bundle-ids create --identifier <bundle-id> --name <name> --platform IOS [--seed-id <team-id>] [--dry-run | --confirm] [--json]
      appstoreconnect bundle-ids update --id <bundle-id-resource-id> --name <name> [--dry-run | --confirm] [--json]
      appstoreconnect bundle-ids delete --id <bundle-id-resource-id> [--dry-run | --confirm] [--json]
      appstoreconnect bundle-ids capabilities list --bundle-id <bundle-id-resource-id> [--json]
      appstoreconnect bundle-ids capabilities enable --bundle-id <bundle-id-resource-id> --capability <capability-type> [--settings-json <json>] [--dry-run | --confirm] [--json]
      appstoreconnect bundle-ids capabilities update --id <capability-id> [--capability <capability-type>] [--settings-json <json>] [--dry-run | --confirm] [--json]
      appstoreconnect bundle-ids capabilities disable --id <capability-id> [--dry-run | --confirm] [--json]
      appstoreconnect certificates list [--certificate-type IOS_DEVELOPMENT] [--limit <n>] [--json]
      appstoreconnect certificates view --id <certificate-id> [--json]
      appstoreconnect certificates download --id <certificate-id> [--output <path>] [--json]
      appstoreconnect certificates create --certificate-type IOS_DEVELOPMENT --csr-path <path> [--merchant-id <id>] [--pass-type-id <id>] [--dry-run | --confirm] [--json]
      appstoreconnect certificates update --id <certificate-id> [--activated true] [--dry-run | --confirm] [--json]
      appstoreconnect certificates revoke --id <certificate-id> [--dry-run | --confirm] [--json]
      appstoreconnect devices list [--name <name>] [--udid <udid>] [--platform IOS] [--status ENABLED] [--limit <n>] [--json]
      appstoreconnect devices view --id <device-id> [--json]
      appstoreconnect devices register --name <name> --udid <udid> --platform IOS [--dry-run | --confirm] [--json]
      appstoreconnect devices update --id <device-id> [--name <name>] [--status ENABLED] [--dry-run | --confirm] [--json]
      appstoreconnect devices enable --id <device-id> [--dry-run | --confirm] [--json]
      appstoreconnect devices disable --id <device-id> [--dry-run | --confirm] [--json]
      appstoreconnect profiles list [--profile-type IOS_APP_STORE] [--profile-state ACTIVE] [--limit <n>] [--json]
      appstoreconnect profiles view --id <profile-id> [--json]
      appstoreconnect profiles download --id <profile-id> [--output <path>] [--json]
      appstoreconnect profiles create --name <name> --profile-type IOS_APP_STORE --bundle-id <bundle-id-resource-id> --certificate <certificate-id> [--device <device-id>] [--dry-run | --confirm] [--json]
      appstoreconnect profiles delete --id <profile-id> [--dry-run | --confirm] [--json]
      appstoreconnect users list [--username <email>] [--role DEVELOPER] [--visible-app <app-id>] [--limit <n>] [--json]
      appstoreconnect users view --id <user-id> [--json]
      appstoreconnect actors list [--id <actor-id>] [--field actorType,userEmail] [--limit <n>] [--json]  (requires PublicAPISigningAccess trait)
      appstoreconnect actors view --id <actor-id> [--field actorType,userEmail] [--json]  (requires PublicAPISigningAccess trait)
      appstoreconnect users update --id <user-id> [--role DEVELOPER] [--all-apps-visible true] [--provisioning-allowed true] [--visible-app <app-id>] [--dry-run | --confirm] [--json]
      appstoreconnect users delete --id <user-id> [--dry-run | --confirm] [--json]
      appstoreconnect users invite --email <email> --first-name <name> --last-name <name> --role DEVELOPER [--visible-app <app-id>] [--dry-run | --confirm] [--json]
      appstoreconnect users invitations list [--email <email>] [--role DEVELOPER] [--visible-app <app-id>] [--limit <n>] [--json]
      appstoreconnect users invitations view --id <invitation-id> [--json]
      appstoreconnect users invitations create --email <email> --first-name <name> --last-name <name> --role DEVELOPER [--visible-app <app-id>] [--dry-run | --confirm] [--json]
      appstoreconnect users invitations delete --id <invitation-id> [--dry-run | --confirm] [--json]
      appstoreconnect iap list --app <app-id> [--product-id <id>] [--type CONSUMABLE] [--state APPROVED] [--limit <n>] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect iap view --id <in-app-purchase-id> [--json]                       (requires PublicAPICommerce trait)
      appstoreconnect iap create --app <id> --name <name> --product-id <id> --type CONSUMABLE [--family-sharable true] [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect iap update --id <in-app-purchase-id> [--name <name>] [--family-sharable true] [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect iap delete --id <in-app-purchase-id> [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect iap submit --id <in-app-purchase-id> [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect iap localizations list --iap <in-app-purchase-id> [--limit <n>] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect iap localizations view --id <localization-id> [--json]  (requires PublicAPICommerce trait)
      appstoreconnect iap localizations create --iap <in-app-purchase-id> --locale en-US --name <name> [--description <text>] [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect iap localizations update --id <localization-id> [--name <name>] [--description <text>] [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect iap localizations delete --id <localization-id> [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect promoted-purchases list --app <app-id> [--include iap] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect promoted-purchases create --app <app-id> (--iap <iap-id> | --subscription <subscription-id>) --visible-for-all-users true [--enabled true] [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect promoted-purchases update --id <promoted-purchase-id> [--visible-for-all-users true] [--enabled true] [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect promoted-purchases delete --id <promoted-purchase-id> [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect subscription-groups view --id <subscription-group-id> [--json]    (requires PublicAPICommerce trait)
      appstoreconnect subscription-groups create --app <id> --reference-name <name> [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect subscription-groups update --id <subscription-group-id> --reference-name <name> [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect subscription-groups delete --id <subscription-group-id> [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect subscription-groups localizations list --group <subscription-group-id> [--limit <n>] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect subscription-groups localizations view --id <localization-id> [--json]  (requires PublicAPICommerce trait)
      appstoreconnect subscription-groups localizations create --group <subscription-group-id> --locale en-US --name <name> [--custom-app-name <name>] [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect subscription-groups localizations update --id <localization-id> [--name <name>] [--custom-app-name <name>] [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect subscription-groups localizations delete --id <localization-id> [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect subscriptions list --group <subscription-group-id> [--product-id <id>] [--state APPROVED] [--limit <n>] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect subscriptions view --id <subscription-id> [--json]                (requires PublicAPICommerce trait)
      appstoreconnect subscriptions create --group <subscription-group-id> --name <name> --product-id <id> [--period ONE_MONTH] [--group-level <n>] [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect subscriptions update --id <subscription-id> [--name <name>] [--period ONE_YEAR] [--group-level <n>] [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect subscriptions delete --id <subscription-id> [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect subscriptions submit --id <subscription-id> [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect subscriptions localizations list --subscription <subscription-id> [--limit <n>] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect subscriptions localizations view --id <localization-id> [--json]  (requires PublicAPICommerce trait)
      appstoreconnect subscriptions localizations create --subscription <subscription-id> --locale en-US --name <name> [--description <text>] [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect subscriptions localizations update --id <localization-id> [--name <name>] [--description <text>] [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect subscriptions localizations delete --id <localization-id> [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect win-back-offers list --subscription <subscription-id> [--limit <n>] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect win-back-offers view --id <win-back-offer-id> [--json]  (requires PublicAPICommerce trait)
      appstoreconnect win-back-offers create --subscription <subscription-id> --reference-name <name> --offer-id <id> --duration ONE_MONTH --offer-mode PAY_AS_YOU_GO --period-count <n> --paid-subscription-months <n> --last-subscribed-min-months <n> --last-subscribed-max-months <n> --start-date yyyy-MM-dd --priority NORMAL --price <win-back-offer-price-id> [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect win-back-offers update --id <win-back-offer-id> [--start-date yyyy-MM-dd] [--priority HIGH] [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect win-back-offers delete --id <win-back-offer-id> [--dry-run | --confirm] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect pricing tiers --app <app-id> [--territory USA] [--include-territory] [--limit <n>] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect pricing current --app <app-id> [--include-base-territory] [--include-manual-prices] [--json]  (requires PublicAPICommerce trait)
      appstoreconnect analytics reports view --id <analytics-report-id> [--json]
      appstoreconnect analytics request create --app <id> [--access-type ONE_TIME_SNAPSHOT] [--dry-run | --confirm] [--json]
      appstoreconnect analytics request view --id <analytics-report-request-id> [--limit <n>] [--json]
      appstoreconnect analytics request delete --id <analytics-report-request-id> [--dry-run | --confirm] [--json]
      appstoreconnect analytics segments view --id <analytics-report-segment-id> [--json]
      appstoreconnect analytics instances view --id <analytics-report-instance-id> [--json]
      appstoreconnect finance reports --vendor-number <vendor> --region-code <region> --report-date <YYYY-MM> [--report-type FINANCIAL] [--output <path>] [--json]
      appstoreconnect reports sales --vendor-number <vendor> [--report-type SALES] [--report-sub-type SUMMARY] [--frequency DAILY] [--report-date <YYYY-MM-DD>] [--output <path>] [--json]
      appstoreconnect performance list (--app <id> | --build <id>) [--platform IOS] [--metric-type HANG] [--device-type <device>] [--json]  (requires PublicAPIReports trait)
      appstoreconnect performance download (--app <id> | --build <id>) [--platform IOS] [--metric-type HANG] [--output <path>] [--json]  (requires PublicAPIReports trait)
      appstoreconnect review submissions list --app <id> [--review-state IN_REVIEW] [--platform IOS] [--limit <n>] [--json]
      appstoreconnect review submissions view --id <review-submission-id> [--json]
      appstoreconnect review submissions create --app <id> [--platform IOS] [--dry-run | --confirm] [--json]
      appstoreconnect review submissions submit --id <review-submission-id> [--dry-run | --confirm] [--json]
      appstoreconnect review submissions cancel --id <review-submission-id> [--dry-run | --confirm] [--json]
      appstoreconnect review submit --id <review-submission-id> [--dry-run | --confirm] [--json]
      appstoreconnect review items create --review-submission-id <id> --version-id <version-id> [--dry-run | --confirm] [--json]
      appstoreconnect review items update --id <item-id> [--resolved true] [--removed true] [--dry-run | --confirm] [--json]
      appstoreconnect review items delete --id <item-id> [--dry-run | --confirm] [--json]
      appstoreconnect review submission-items create --review-submission-id <id> --version-id <version-id> [--dry-run | --confirm] [--json]
      appstoreconnect review submission-items update --id <item-id> [--resolved true] [--removed true] [--dry-run | --confirm] [--json]
      appstoreconnect review submission-items delete --id <item-id> [--dry-run | --confirm] [--json]
      appstoreconnect submit status (--id <review-submission-id> | --app <id>) [--json]
      appstoreconnect submit create --app <id> [--platform IOS] [--dry-run | --confirm] [--json]
      appstoreconnect submit cancel --id <review-submission-id> [--dry-run | --confirm] [--json]
      appstoreconnect status --app <id> [--version-id <id>] [--review-state IN_REVIEW] [--limit <n>] [--json]
      appstoreconnect validate --app <id> [--version-id <id>] [--dry-run] [--json]
      appstoreconnect schema [info] [--json]
      appstoreconnect schema path [--json]
      appstoreconnect completion [zsh|bash|fish]

    Environment:
      ASC_API_TOKEN             Bearer token used by workflow run commands.
      ASC_WEB_SESSION_COOKIES   Cookie header used by auth/web-session commands.
      ASC_WEB_SESSION_FILE      JSON web-session file used by auth commands.
      ASC_XCODEBUILD_PATH       Optional xcodebuild path used by xcode commands.
      ASC_UPLOAD_TOOL_PATH      Optional upload-tool path used by xcode upload.

    """
}

private struct AppStoreConnectSchemaInfo: Encodable, Sendable, Equatable {
    var official: AppStoreConnectSchemaDocumentSummary
    var selected: AppStoreConnectSchemaDocumentSummary
    var source: AppStoreConnectSchemaSourceSummary
    var generation: AppStoreConnectSchemaGenerationSummary
}

private struct AppStoreConnectSchemaDocumentSummary: Encodable, Sendable, Equatable {
    var path: String
    var sha256: String?
    var openapi: String
    var title: String
    var version: String
    var pathCount: Int
    var operationCount: Int
    var schemaCount: Int
}

private struct AppStoreConnectSchemaInventory: Sendable, Equatable {
    var pathCount: Int
    var operationCount: Int
    var schemaCount: Int
}

private struct AppStoreConnectSchemaSourceSummary: Encodable, Sendable, Equatable {
    var checkedAt: String?
    var httpLastModified: String?
    var archiveSHA256: String?
    var normalization: String?
}

private struct AppStoreConnectSchemaGenerationSummary: Encodable, Sendable, Equatable {
    var mode: String
    var defaultTraits: [String]
    var fullTrait: String?
    var activeTraitSource: String?
    var traitNames: [String]
}

private struct AppStoreConnectSchemaPathInfo: Encodable, Sendable, Equatable {
    var officialSchema: String
    var selectedSchema: String
    var specLock: String
    var schemaAudit: String
    var traitManifest: String
}

private struct UnsupportedCommandResult: Encodable, Sendable, Equatable {
    var command: String
    var registeredCommand: String
    var status: AppStoreConnectCLICommandStatus
    var message: String
    var parameterSemantics: [String]
    var backend: String
    var notes: String?
}

private struct ParsedArguments {
    var commands: [String] = []
    var options: [String: String] = [:]
    var flags: Set<String> = []

    init(_ arguments: [String]) {
        var index = 0

        while index < arguments.count {
            let argument = arguments[index]
            if argument.hasPrefix("--") {
                let key = String(argument.dropFirst(2))
                let nextIndex = arguments.index(after: index)
                if nextIndex < arguments.count, !arguments[nextIndex].hasPrefix("--") {
                    options[key] = arguments[nextIndex]
                    index += 2
                } else {
                    flags.insert(key)
                    index += 1
                }
            } else {
                commands.append(argument)
                index += 1
            }
        }
    }

    var wantsJSON: Bool {
        hasFlag("json")
            || option("output") == "json"
            || option("format") == "json"
    }

    func option(_ name: String) -> String? {
        options[name]
    }

    func intOption(_ name: String) -> Int? {
        option(name).flatMap(Int.init)
    }

    func doubleOption(_ name: String) -> Double? {
        option(name).flatMap(Double.init)
    }

    func commaSeparatedOption(_ name: String) -> [String] {
        option(name).map(Self.splitCommaSeparated) ?? []
    }

    func commaSeparatedOptions(_ names: [String]) -> [String] {
        for name in names {
            let values = commaSeparatedOption(name)
            if !values.isEmpty {
                return values
            }
        }
        return []
    }

    func firstOption(_ names: [String]) -> String? {
        for name in names {
            if let value = option(name) {
                return value
            }
        }
        return nil
    }

    func hasFlag(_ name: String) -> Bool {
        flags.contains(name)
    }

    private static func splitCommaSeparated(_ value: String) -> [String] {
        value
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

private func boolOption(from parsed: ParsedArguments, names: [String]) throws -> Bool? {
    for name in names {
        if parsed.hasFlag(name) {
            return true
        }
        if let value = parsed.option(name) {
            switch value.lowercased() {
            case "true", "yes", "1":
                return true
            case "false", "no", "0":
                return false
            default:
                throw CLIError(exitCode: 64, message: "Invalid boolean value for --\(name): \(value).")
            }
        }
    }
    return nil
}

private struct CLIError: Error {
    var exitCode: Int32
    var message: String
}
