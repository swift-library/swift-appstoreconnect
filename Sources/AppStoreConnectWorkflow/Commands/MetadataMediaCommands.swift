import AppStoreConnectCore
import AppStoreConnectPublicAPI
import Foundation

public struct AppStoreConnectMetadataValidationInput: Codable, Sendable, Equatable {
    public var path: String

    public init(path: String) {
        self.path = path
    }
}

public struct AppStoreConnectMetadataValidationIssue: Codable, Sendable, Equatable {
    public var path: String
    public var message: String

    public init(path: String, message: String) {
        self.path = path
        self.message = message
    }
}

public struct AppStoreConnectMetadataValidationResult: Codable, Sendable, Equatable {
    public var path: String
    public var checkedJSONFiles: Int
    public var valid: Bool
    public var issues: [AppStoreConnectMetadataValidationIssue]

    public init(
        path: String,
        checkedJSONFiles: Int,
        valid: Bool? = nil,
        issues: [AppStoreConnectMetadataValidationIssue]
    ) {
        self.path = path
        self.checkedJSONFiles = checkedJSONFiles
        self.valid = valid ?? issues.isEmpty
        self.issues = issues
    }
}

public struct AppStoreConnectMetadataPlanInput: Codable, Sendable, Equatable {
    public var appID: String?
    public var appStoreVersionID: String?
    public var locale: String?
    public var path: String?
    public var localizationID: String?
    public var keywords: String?

    public init(
        appID: String? = nil,
        appStoreVersionID: String? = nil,
        locale: String? = nil,
        path: String? = nil,
        localizationID: String? = nil,
        keywords: String? = nil
    ) {
        self.appID = appID
        self.appStoreVersionID = appStoreVersionID
        self.locale = locale
        self.path = path
        self.localizationID = localizationID
        self.keywords = keywords
    }
}

public enum AppStoreConnectMetadataCommands {
    public static func validate(
        _ input: AppStoreConnectMetadataValidationInput,
        fileManager: FileManager = .default
    ) -> AppStoreConnectMetadataValidationResult {
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: input.path, isDirectory: &isDirectory) else {
            return AppStoreConnectMetadataValidationResult(
                path: input.path,
                checkedJSONFiles: 0,
                issues: [.init(path: input.path, message: "Path does not exist.")]
            )
        }

        let urls: [URL]
        if isDirectory.boolValue {
            let root = URL(fileURLWithPath: input.path)
            urls = (fileManager.enumerator(at: root, includingPropertiesForKeys: [.isRegularFileKey])?
                .compactMap { $0 as? URL } ?? [])
                .filter { $0.pathExtension.lowercased() == "json" }
        } else {
            urls = [URL(fileURLWithPath: input.path)]
        }

        var issues: [AppStoreConnectMetadataValidationIssue] = []
        var checked = 0
        for url in urls.sorted(by: { $0.path < $1.path }) {
            guard url.pathExtension.lowercased() == "json" else {
                continue
            }
            checked += 1
            do {
                let data = try Data(contentsOf: url)
                _ = try JSONSerialization.jsonObject(with: data)
            } catch {
                issues.append(.init(path: url.path, message: "Invalid JSON: \(error.localizedDescription)"))
            }
        }

        if checked == 0 {
            issues.append(.init(path: input.path, message: "No JSON metadata files found."))
        }

        return AppStoreConnectMetadataValidationResult(
            path: input.path,
            checkedJSONFiles: checked,
            issues: issues
        )
    }

    public static func planPull(_ input: AppStoreConnectMetadataPlanInput) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: "metadata_pull",
            commandDescription: "Plan metadata pull into \(input.path ?? ".").",
            source: .localOnly,
            mutates: false,
            inputs: compactInputs([
                ("appID", input.appID),
                ("appStoreVersionID", input.appStoreVersionID),
                ("locale", input.locale),
                ("path", input.path),
            ])
        )
    }

    public static func planPush(_ input: AppStoreConnectMetadataPlanInput) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: "metadata_push",
            commandDescription: "Plan metadata push from \(input.path ?? ".").",
            source: .localOnly,
            inputs: compactInputs([
                ("appID", input.appID),
                ("appStoreVersionID", input.appStoreVersionID),
                ("locale", input.locale),
                ("path", input.path),
            ])
        )
    }

    public static func planKeywords(_ input: AppStoreConnectMetadataPlanInput) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.AppStoreVersionLocalizationsUpdateInstance.id,
            commandDescription: "Plan App Store version localization keyword update.",
            source: .publicAPIBacked,
            inputs: compactInputs([
                ("localizationID", input.localizationID),
                ("keywords", input.keywords),
            ])
        )
    }

    private static func compactInputs(_ pairs: [(String, String?)]) -> [String: String] {
        Dictionary(uniqueKeysWithValues: pairs.compactMap { key, value in
            value.map { (key, $0) }
        })
    }
}

public struct AppStoreConnectMediaAssetSetViewInput: Codable, Sendable, Equatable {
    public var id: String
    public var includeAssets: Bool
    public var limit: Int?

    public init(id: String, includeAssets: Bool = true, limit: Int? = nil) {
        self.id = id
        self.includeAssets = includeAssets
        self.limit = limit
    }
}

public struct AppStoreConnectMediaAssetViewInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectScreenshotSetSummary: Codable, Sendable, Equatable {
    public var id: String
    public var displayType: String?
    public var screenshotIDs: [String]

    public init(id: String, displayType: String?, screenshotIDs: [String]) {
        self.id = id
        self.displayType = displayType
        self.screenshotIDs = screenshotIDs
    }
}

public struct AppStoreConnectScreenshotSummary: Codable, Sendable, Equatable {
    public var id: String
    public var fileName: String?
    public var fileSize: Int?
    public var assetType: String?
    public var assetState: String?
    public var sourceFileChecksum: String?
    public var screenshotSetID: String?

    public init(
        id: String,
        fileName: String?,
        fileSize: Int?,
        assetType: String?,
        assetState: String?,
        sourceFileChecksum: String?,
        screenshotSetID: String?
    ) {
        self.id = id
        self.fileName = fileName
        self.fileSize = fileSize
        self.assetType = assetType
        self.assetState = assetState
        self.sourceFileChecksum = sourceFileChecksum
        self.screenshotSetID = screenshotSetID
    }
}

public struct AppStoreConnectPreviewSetSummary: Codable, Sendable, Equatable {
    public var id: String
    public var previewType: String?
    public var previewIDs: [String]

    public init(id: String, previewType: String?, previewIDs: [String]) {
        self.id = id
        self.previewType = previewType
        self.previewIDs = previewIDs
    }
}

public struct AppStoreConnectPreviewSummary: Codable, Sendable, Equatable {
    public var id: String
    public var fileName: String?
    public var fileSize: Int?
    public var mimeType: String?
    public var previewFrameTimeCode: String?
    public var assetState: String?
    public var videoState: String?
    public var sourceFileChecksum: String?
    public var previewSetID: String?

    public init(
        id: String,
        fileName: String?,
        fileSize: Int?,
        mimeType: String?,
        previewFrameTimeCode: String?,
        assetState: String?,
        videoState: String?,
        sourceFileChecksum: String?,
        previewSetID: String?
    ) {
        self.id = id
        self.fileName = fileName
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.previewFrameTimeCode = previewFrameTimeCode
        self.assetState = assetState
        self.videoState = videoState
        self.sourceFileChecksum = sourceFileChecksum
        self.previewSetID = previewSetID
    }
}

public typealias AppStoreConnectScreenshotSetResult = AppStoreConnectResourceResult<AppStoreConnectScreenshotSetSummary>
public typealias AppStoreConnectScreenshotResult = AppStoreConnectResourceResult<AppStoreConnectScreenshotSummary>
public typealias AppStoreConnectPreviewSetResult = AppStoreConnectResourceResult<AppStoreConnectPreviewSetSummary>
public typealias AppStoreConnectPreviewResult = AppStoreConnectResourceResult<AppStoreConnectPreviewSummary>

public extension PublicAPIReadCommands {
    func getAppScreenshotSet(
        _ input: AppStoreConnectMediaAssetSetViewInput
    ) async throws -> AppStoreConnectScreenshotSetResult {
        let output = try await client.mediaAssets.getAppScreenshotSet(
            id: input.id,
            query: appScreenshotSetQuery(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectScreenshotSetResult(data: Self.screenshotSetSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected screenshot set response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Screenshot set lookup did not return 200 ok.")
        }
    }

    func getAppScreenshot(
        _ input: AppStoreConnectMediaAssetViewInput
    ) async throws -> AppStoreConnectScreenshotResult {
        let output = try await client.mediaAssets.getAppScreenshot(id: input.id)

        switch output {
        case let .ok(response):
            return AppStoreConnectScreenshotResult(data: Self.screenshotSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected screenshot response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Screenshot lookup did not return 200 ok.")
        }
    }

    func getAppPreviewSet(
        _ input: AppStoreConnectMediaAssetSetViewInput
    ) async throws -> AppStoreConnectPreviewSetResult {
        let output = try await client.mediaAssets.getAppPreviewSet(
            id: input.id,
            query: appPreviewSetQuery(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectPreviewSetResult(data: Self.previewSetSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected app preview set response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "App preview set lookup did not return 200 ok.")
        }
    }

    func getAppPreview(
        _ input: AppStoreConnectMediaAssetViewInput
    ) async throws -> AppStoreConnectPreviewResult {
        let output = try await client.mediaAssets.getAppPreview(id: input.id)

        switch output {
        case let .ok(response):
            return AppStoreConnectPreviewResult(data: Self.previewSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected app preview response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "App preview lookup did not return 200 ok.")
        }
    }

    private func appScreenshotSetQuery(
        from input: AppStoreConnectMediaAssetSetViewInput
    ) -> Operations.AppScreenshotSetsGetInstance.Input.Query {
        var query = Operations.AppScreenshotSetsGetInstance.Input.Query()
        if input.includeAssets {
            query.include = [.appScreenshots]
            query.fields_lbrack_appScreenshots_rbrack_ = [
                .fileName,
                .fileSize,
                .assetType,
                .assetDeliveryState,
                .sourceFileChecksum,
                .appScreenshotSet,
            ]
            query.limit_lbrack_appScreenshots_rbrack_ = input.limit
        }
        return query
    }

    private func appPreviewSetQuery(
        from input: AppStoreConnectMediaAssetSetViewInput
    ) -> Operations.AppPreviewSetsGetInstance.Input.Query {
        var query = Operations.AppPreviewSetsGetInstance.Input.Query()
        if input.includeAssets {
            query.include = [.appPreviews]
            query.fields_lbrack_appPreviews_rbrack_ = [
                .fileName,
                .fileSize,
                .mimeType,
                .previewFrameTimeCode,
                .assetDeliveryState,
                .videoDeliveryState,
                .sourceFileChecksum,
                .appPreviewSet,
            ]
            query.limit_lbrack_appPreviews_rbrack_ = input.limit
        }
        return query
    }

    private static func screenshotSetSummary(
        _ set: Components.Schemas.AppScreenshotSet
    ) -> AppStoreConnectScreenshotSetSummary {
        AppStoreConnectScreenshotSetSummary(
            id: set.id,
            displayType: set.attributes?.screenshotDisplayType?.rawValue,
            screenshotIDs: set.relationships?.appScreenshots?.data?.map(\.id) ?? []
        )
    }

    private static func screenshotSummary(
        _ screenshot: Components.Schemas.AppScreenshot
    ) -> AppStoreConnectScreenshotSummary {
        AppStoreConnectScreenshotSummary(
            id: screenshot.id,
            fileName: screenshot.attributes?.fileName,
            fileSize: screenshot.attributes?.fileSize,
            assetType: screenshot.attributes?.assetType,
            assetState: screenshot.attributes?.assetDeliveryState?.state?.rawValue,
            sourceFileChecksum: screenshot.attributes?.sourceFileChecksum,
            screenshotSetID: screenshot.relationships?.appScreenshotSet?.data?.id
        )
    }

    private static func previewSetSummary(
        _ set: Components.Schemas.AppPreviewSet
    ) -> AppStoreConnectPreviewSetSummary {
        AppStoreConnectPreviewSetSummary(
            id: set.id,
            previewType: set.attributes?.previewType?.rawValue,
            previewIDs: set.relationships?.appPreviews?.data?.map(\.id) ?? []
        )
    }

    private static func previewSummary(
        _ preview: Components.Schemas.AppPreview
    ) -> AppStoreConnectPreviewSummary {
        AppStoreConnectPreviewSummary(
            id: preview.id,
            fileName: preview.attributes?.fileName,
            fileSize: preview.attributes?.fileSize,
            mimeType: preview.attributes?.mimeType,
            previewFrameTimeCode: preview.attributes?.previewFrameTimeCode,
            assetState: preview.attributes?.assetDeliveryState?.state?.rawValue,
            videoState: preview.attributes?.videoDeliveryState?.state?.rawValue,
            sourceFileChecksum: preview.attributes?.sourceFileChecksum,
            previewSetID: preview.relationships?.appPreviewSet?.data?.id
        )
    }
}
