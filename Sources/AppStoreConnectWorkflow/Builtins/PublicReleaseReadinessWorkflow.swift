import AppStoreConnectCore
import AppStoreConnectPublicAPI

public struct PublicReleaseReadinessInput: Codable, Sendable, Equatable {
    public var appID: String
    public var appStoreVersionID: String?
    public var screenshotSetID: String?
    public var includeBuilds: Bool
    public var includeTestFlightGroups: Bool

    public init(
        appID: String,
        appStoreVersionID: String? = nil,
        screenshotSetID: String? = nil,
        includeBuilds: Bool = true,
        includeTestFlightGroups: Bool = true
    ) {
        self.appID = appID
        self.appStoreVersionID = appStoreVersionID
        self.screenshotSetID = screenshotSetID
        self.includeBuilds = includeBuilds
        self.includeTestFlightGroups = includeTestFlightGroups
    }
}

public struct PublicReleaseReadinessWorkflow: Sendable {
    public let client: AppStoreConnectPublicClient

    public init(client: AppStoreConnectPublicClient) {
        self.client = client
    }

    public static func planSteps() -> [WorkflowStep] {
        [
            WorkflowStep(
                name: "resolve-app",
                label: "Resolve App",
                commandDescription: "Fetch the app resource through the public App Store Connect API.",
                source: .publicAPIBacked,
                outputKeys: ["appID"]
            ),
            WorkflowStep(
                name: "inspect-builds",
                label: "Inspect Builds",
                commandDescription: "List public API build resources visible to the current API key.",
                dependencies: ["resolve-app"],
                source: .publicAPIBacked,
                outputKeys: ["buildIDs", "buildCount"]
            ),
            WorkflowStep(
                name: "binary-upload-boundary",
                label: "Binary Upload Boundary",
                commandDescription: "Record that app binary upload remains an Xcode or Transporter handoff outside this public API workflow.",
                dependencies: ["inspect-builds"],
                source: .uploadToolBacked
            ),
            WorkflowStep(
                name: "inspect-testflight-groups",
                label: "Inspect TestFlight Groups",
                commandDescription: "List TestFlight beta groups through the public App Store Connect API.",
                dependencies: ["resolve-app"],
                source: .publicAPIBacked,
                outputKeys: ["betaGroupIDs", "betaGroupCount"]
            ),
            WorkflowStep(
                name: "inspect-screenshot-set",
                label: "Inspect Screenshot Set",
                commandDescription: "Fetch a screenshot set when a screenshot set identifier is provided.",
                dependencies: ["resolve-app"],
                source: .publicAPIBacked,
                outputKeys: ["screenshotSetID"]
            ),
            WorkflowStep(
                name: "inspect-metadata-version",
                label: "Inspect Metadata Version",
                commandDescription: "Fetch the App Store version metadata seed when a version identifier is provided.",
                dependencies: ["resolve-app"],
                source: .publicAPIBacked,
                outputKeys: ["appStoreVersionID"]
            ),
        ]
    }

    public static func dryRun(_ input: PublicReleaseReadinessInput) -> WorkflowPlan {
        var steps = Self.planSteps()

        if !input.includeBuilds {
            steps = steps.map { step in
                step.name == "inspect-builds"
                    ? step.withDescription("Skip build inspection because includeBuilds is false.")
                    : step
            }
        }

        if !input.includeTestFlightGroups {
            steps = steps.map { step in
                step.name == "inspect-testflight-groups"
                    ? step.withDescription("Skip TestFlight group inspection because includeTestFlightGroups is false.")
                    : step
            }
        }

        if input.screenshotSetID == nil {
            steps = steps.map { step in
                step.name == "inspect-screenshot-set"
                    ? step.withDescription("Skip screenshot inspection because screenshotSetID is not provided.")
                    : step
            }
        }

        if input.appStoreVersionID == nil {
            steps = steps.map { step in
                step.name == "inspect-metadata-version"
                    ? step.withDescription("Skip metadata version inspection because appStoreVersionID is not provided.")
                    : step
            }
        }

        return WorkflowPlan(workflow: .publicReleaseReadiness, steps: steps)
    }

    public func dryRun(_ input: PublicReleaseReadinessInput) -> WorkflowPlan {
        Self.dryRun(input)
    }

    public func run(_ input: PublicReleaseReadinessInput) async -> WorkflowRunResult {
        var results: [WorkflowStepResult] = []

        let appResult = await resolveApp(appID: input.appID)
        results.append(appResult)

        guard appResult.status == .succeeded else {
            results.append(contentsOf: dependencySkippedResults(afterAppResolutionFailure: appResult))
            return WorkflowRunResult(workflow: .publicReleaseReadiness, steps: results)
        }

        if input.includeBuilds {
            results.append(await inspectBuilds())
        } else {
            results.append(skipped("inspect-builds", source: .publicAPIBacked, "Build inspection disabled by input."))
        }

        results.append(skipped(
            "binary-upload-boundary",
            source: .uploadToolBacked,
            "Binary upload is not performed by this public API workflow; use Xcode or Transporter handoff."
        ))

        if input.includeTestFlightGroups {
            results.append(await inspectTestFlightGroups())
        } else {
            results.append(skipped(
                "inspect-testflight-groups",
                source: .publicAPIBacked,
                "TestFlight group inspection disabled by input."
            ))
        }

        if let screenshotSetID = input.screenshotSetID {
            results.append(await inspectScreenshotSet(id: screenshotSetID))
        } else {
            results.append(skipped(
                "inspect-screenshot-set",
                source: .publicAPIBacked,
                "No screenshotSetID was provided."
            ))
        }

        if let appStoreVersionID = input.appStoreVersionID {
            results.append(await inspectMetadataVersion(id: appStoreVersionID))
        } else {
            results.append(skipped(
                "inspect-metadata-version",
                source: .publicAPIBacked,
                "No appStoreVersionID was provided."
            ))
        }

        return WorkflowRunResult(workflow: .publicReleaseReadiness, steps: results)
    }

    private func resolveApp(appID: String) async -> WorkflowStepResult {
        await capture(stepID: "resolve-app", source: .publicAPIBacked) {
            let output = try await client.apps.getApp(id: appID)

            switch output {
            case let .ok(response):
                let app = try response.body.json.data
                return WorkflowStepResult(
                    stepID: "resolve-app",
                    status: .succeeded,
                    source: .publicAPIBacked,
                    mutates: false,
                    outputs: ["appID": .string(app.id)],
                    diagnostics: ["Resolved app \(app.id)."]
                )
            case let .undocumented(statusCode, _):
                throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected app lookup response.")
            default:
                throw AppStoreConnectError.requestFailed(statusCode: -1, message: "App lookup did not return 200 ok.")
            }
        }
    }

    private func inspectBuilds() async -> WorkflowStepResult {
        await capture(stepID: "inspect-builds", source: .publicAPIBacked) {
            let output = try await client.builds.listBuilds()

            switch output {
            case let .ok(response):
                let builds = try response.body.json.data
                let ids = builds.map(\.id)
                return WorkflowStepResult(
                    stepID: "inspect-builds",
                    status: .succeeded,
                    source: .publicAPIBacked,
                    mutates: false,
                    outputs: [
                        "buildIDs": .strings(ids),
                        "buildCount": .integer(ids.count),
                    ],
                    diagnostics: ["Found \(ids.count) build resource(s)."]
                )
            case let .undocumented(statusCode, _):
                throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected builds response.")
            default:
                throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Build listing did not return 200 ok.")
            }
        }
    }

    private func inspectTestFlightGroups() async -> WorkflowStepResult {
        await capture(stepID: "inspect-testflight-groups", source: .publicAPIBacked) {
            let output = try await client.testFlight.listBetaGroups()

            switch output {
            case let .ok(response):
                let groups = try response.body.json.data
                let ids = groups.map(\.id)
                return WorkflowStepResult(
                    stepID: "inspect-testflight-groups",
                    status: .succeeded,
                    source: .publicAPIBacked,
                    mutates: false,
                    outputs: [
                        "betaGroupIDs": .strings(ids),
                        "betaGroupCount": .integer(ids.count),
                    ],
                    diagnostics: ["Found \(ids.count) TestFlight beta group resource(s)."]
                )
            case let .undocumented(statusCode, _):
                throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected beta groups response.")
            default:
                throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Beta group listing did not return 200 ok.")
            }
        }
    }

    private func inspectScreenshotSet(id: String) async -> WorkflowStepResult {
        await capture(stepID: "inspect-screenshot-set", source: .publicAPIBacked) {
            let output = try await client.mediaAssets.getAppScreenshotSet(id: id)

            switch output {
            case let .ok(response):
                let set = try response.body.json.data
                return WorkflowStepResult(
                    stepID: "inspect-screenshot-set",
                    status: .succeeded,
                    source: .publicAPIBacked,
                    mutates: false,
                    outputs: ["screenshotSetID": .string(set.id)],
                    diagnostics: ["Resolved screenshot set \(set.id)."]
                )
            case let .undocumented(statusCode, _):
                throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected screenshot set response.")
            default:
                throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Screenshot set lookup did not return 200 ok.")
            }
        }
    }

    private func inspectMetadataVersion(id: String) async -> WorkflowStepResult {
        await capture(stepID: "inspect-metadata-version", source: .publicAPIBacked) {
            let output = try await client.apps.getAppStoreVersion(id: id)

            switch output {
            case let .ok(response):
                let version = try response.body.json.data
                return WorkflowStepResult(
                    stepID: "inspect-metadata-version",
                    status: .succeeded,
                    source: .publicAPIBacked,
                    mutates: false,
                    outputs: ["appStoreVersionID": .string(version.id)],
                    diagnostics: ["Resolved App Store version \(version.id)."]
                )
            case let .undocumented(statusCode, _):
                throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected metadata version response.")
            default:
                throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Metadata version lookup did not return 200 ok.")
            }
        }
    }

    private func capture(
        stepID: String,
        source: WorkflowStepSource,
        operation: () async throws -> WorkflowStepResult
    ) async -> WorkflowStepResult {
        do {
            return try await operation()
        } catch {
            return WorkflowStepResult(
                stepID: stepID,
                status: .failed,
                source: source,
                mutates: false,
                diagnostics: [String(describing: error)],
                resumable: true
            )
        }
    }

    private func skipped(
        _ stepID: String,
        source: WorkflowStepSource,
        _ diagnostic: String
    ) -> WorkflowStepResult {
        WorkflowStepResult(
            stepID: stepID,
            status: .skipped,
            source: source,
            mutates: false,
            diagnostics: [diagnostic]
        )
    }

    private func dependencySkippedResults(afterAppResolutionFailure result: WorkflowStepResult) -> [WorkflowStepResult] {
        Self.planSteps()
            .dropFirst()
            .map {
                skipped(
                    $0.name,
                    source: $0.source,
                    "Skipped because \(result.stepID) failed."
                )
            }
    }
}

private extension WorkflowStep {
    func withDescription(_ description: String) -> WorkflowStep {
        var step = self
        step.commandDescription = description
        return step
    }
}
