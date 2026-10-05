#if ASC_PUBLIC_API_CLOUD
import AppStoreConnectCore
import AppStoreConnectPublicAPI
import Foundation

public struct AppStoreConnectXcodeCloudProductListInput: Codable, Sendable, Equatable {
    public var productTypes: [String]
    public var appIDs: [String]
    public var fields: [String]
    public var includeApp: Bool
    public var includeBundleID: Bool
    public var includePrimaryRepositories: Bool
    public var limit: Int?
    public var primaryRepositoriesLimit: Int?

    public init(
        productTypes: [String] = [],
        appIDs: [String] = [],
        fields: [String] = [],
        includeApp: Bool = false,
        includeBundleID: Bool = false,
        includePrimaryRepositories: Bool = false,
        limit: Int? = nil,
        primaryRepositoriesLimit: Int? = nil
    ) {
        self.productTypes = productTypes
        self.appIDs = appIDs
        self.fields = fields
        self.includeApp = includeApp
        self.includeBundleID = includeBundleID
        self.includePrimaryRepositories = includePrimaryRepositories
        self.limit = limit
        self.primaryRepositoriesLimit = primaryRepositoriesLimit
    }
}

public struct AppStoreConnectXcodeCloudProductViewInput: Codable, Sendable, Equatable {
    public var id: String
    public var fields: [String]
    public var includeApp: Bool
    public var includeBundleID: Bool
    public var includePrimaryRepositories: Bool
    public var primaryRepositoriesLimit: Int?

    public init(
        id: String,
        fields: [String] = [],
        includeApp: Bool = false,
        includeBundleID: Bool = false,
        includePrimaryRepositories: Bool = false,
        primaryRepositoriesLimit: Int? = nil
    ) {
        self.id = id
        self.fields = fields
        self.includeApp = includeApp
        self.includeBundleID = includeBundleID
        self.includePrimaryRepositories = includePrimaryRepositories
        self.primaryRepositoriesLimit = primaryRepositoriesLimit
    }
}

public struct AppStoreConnectXcodeCloudWorkflowListInput: Codable, Sendable, Equatable {
    public var productID: String
    public var fields: [String]
    public var includeProduct: Bool
    public var includeRepository: Bool
    public var includeXcodeVersion: Bool
    public var includeMacOSVersion: Bool
    public var limit: Int?

    public init(
        productID: String,
        fields: [String] = [],
        includeProduct: Bool = false,
        includeRepository: Bool = false,
        includeXcodeVersion: Bool = false,
        includeMacOSVersion: Bool = false,
        limit: Int? = nil
    ) {
        self.productID = productID
        self.fields = fields
        self.includeProduct = includeProduct
        self.includeRepository = includeRepository
        self.includeXcodeVersion = includeXcodeVersion
        self.includeMacOSVersion = includeMacOSVersion
        self.limit = limit
    }
}

public struct AppStoreConnectXcodeCloudWorkflowViewInput: Codable, Sendable, Equatable {
    public var id: String
    public var fields: [String]
    public var includeProduct: Bool
    public var includeRepository: Bool
    public var includeXcodeVersion: Bool
    public var includeMacOSVersion: Bool

    public init(
        id: String,
        fields: [String] = [],
        includeProduct: Bool = false,
        includeRepository: Bool = false,
        includeXcodeVersion: Bool = false,
        includeMacOSVersion: Bool = false
    ) {
        self.id = id
        self.fields = fields
        self.includeProduct = includeProduct
        self.includeRepository = includeRepository
        self.includeXcodeVersion = includeXcodeVersion
        self.includeMacOSVersion = includeMacOSVersion
    }
}

public struct AppStoreConnectXcodeCloudBuildRunListInput: Codable, Sendable, Equatable {
    public var workflowID: String?
    public var productID: String?
    public var buildIDs: [String]
    public var sort: [String]
    public var fields: [String]
    public var includeBuilds: Bool
    public var includeWorkflow: Bool
    public var includeProduct: Bool
    public var includeSourceBranchOrTag: Bool
    public var includeDestinationBranch: Bool
    public var includePullRequest: Bool
    public var limit: Int?
    public var buildsLimit: Int?

    public init(
        workflowID: String? = nil,
        productID: String? = nil,
        buildIDs: [String] = [],
        sort: [String] = [],
        fields: [String] = [],
        includeBuilds: Bool = false,
        includeWorkflow: Bool = false,
        includeProduct: Bool = false,
        includeSourceBranchOrTag: Bool = false,
        includeDestinationBranch: Bool = false,
        includePullRequest: Bool = false,
        limit: Int? = nil,
        buildsLimit: Int? = nil
    ) {
        self.workflowID = workflowID
        self.productID = productID
        self.buildIDs = buildIDs
        self.sort = sort
        self.fields = fields
        self.includeBuilds = includeBuilds
        self.includeWorkflow = includeWorkflow
        self.includeProduct = includeProduct
        self.includeSourceBranchOrTag = includeSourceBranchOrTag
        self.includeDestinationBranch = includeDestinationBranch
        self.includePullRequest = includePullRequest
        self.limit = limit
        self.buildsLimit = buildsLimit
    }
}

public struct AppStoreConnectXcodeCloudBuildRunViewInput: Codable, Sendable, Equatable {
    public var id: String
    public var fields: [String]
    public var includeBuilds: Bool
    public var includeWorkflow: Bool
    public var includeProduct: Bool
    public var includeSourceBranchOrTag: Bool
    public var includeDestinationBranch: Bool
    public var includePullRequest: Bool
    public var buildsLimit: Int?

    public init(
        id: String,
        fields: [String] = [],
        includeBuilds: Bool = false,
        includeWorkflow: Bool = false,
        includeProduct: Bool = false,
        includeSourceBranchOrTag: Bool = false,
        includeDestinationBranch: Bool = false,
        includePullRequest: Bool = false,
        buildsLimit: Int? = nil
    ) {
        self.id = id
        self.fields = fields
        self.includeBuilds = includeBuilds
        self.includeWorkflow = includeWorkflow
        self.includeProduct = includeProduct
        self.includeSourceBranchOrTag = includeSourceBranchOrTag
        self.includeDestinationBranch = includeDestinationBranch
        self.includePullRequest = includePullRequest
        self.buildsLimit = buildsLimit
    }
}

public struct AppStoreConnectXcodeCloudBuildActionListInput: Codable, Sendable, Equatable {
    public var buildRunID: String
    public var fields: [String]
    public var includeBuildRun: Bool
    public var limit: Int?

    public init(
        buildRunID: String,
        fields: [String] = [],
        includeBuildRun: Bool = false,
        limit: Int? = nil
    ) {
        self.buildRunID = buildRunID
        self.fields = fields
        self.includeBuildRun = includeBuildRun
        self.limit = limit
    }
}

public struct AppStoreConnectXcodeCloudBuildActionViewInput: Codable, Sendable, Equatable {
    public var id: String
    public var fields: [String]
    public var includeBuildRun: Bool

    public init(id: String, fields: [String] = [], includeBuildRun: Bool = false) {
        self.id = id
        self.fields = fields
        self.includeBuildRun = includeBuildRun
    }
}

public struct AppStoreConnectXcodeCloudArtifactListInput: Codable, Sendable, Equatable {
    public var buildActionID: String
    public var fields: [String]
    public var logOnly: Bool
    public var limit: Int?

    public init(buildActionID: String, fields: [String] = [], logOnly: Bool = false, limit: Int? = nil) {
        self.buildActionID = buildActionID
        self.fields = fields
        self.logOnly = logOnly
        self.limit = limit
    }
}

public struct AppStoreConnectXcodeCloudArtifactViewInput: Codable, Sendable, Equatable {
    public var id: String
    public var fields: [String]

    public init(id: String, fields: [String] = []) {
        self.id = id
        self.fields = fields
    }
}

public struct AppStoreConnectXcodeCloudProductSummary: Codable, Sendable, Equatable {
    public var id: String
    public var name: String?
    public var productType: String?
    public var createdDate: Date?
    public var appID: String?
    public var bundleID: String?
    public var primaryRepositoryIDs: [String]

    public init(
        id: String,
        name: String? = nil,
        productType: String? = nil,
        createdDate: Date? = nil,
        appID: String? = nil,
        bundleID: String? = nil,
        primaryRepositoryIDs: [String] = []
    ) {
        self.id = id
        self.name = name
        self.productType = productType
        self.createdDate = createdDate
        self.appID = appID
        self.bundleID = bundleID
        self.primaryRepositoryIDs = primaryRepositoryIDs
    }
}

public struct AppStoreConnectXcodeCloudWorkflowSummary: Codable, Sendable, Equatable {
    public var id: String
    public var name: String?
    public var description: String?
    public var isEnabled: Bool?
    public var isLockedForEditing: Bool?
    public var clean: Bool?
    public var containerFilePath: String?
    public var lastModifiedDate: Date?
    public var productID: String?
    public var repositoryID: String?
    public var xcodeVersionID: String?
    public var macOSVersionID: String?

    public init(
        id: String,
        name: String? = nil,
        description: String? = nil,
        isEnabled: Bool? = nil,
        isLockedForEditing: Bool? = nil,
        clean: Bool? = nil,
        containerFilePath: String? = nil,
        lastModifiedDate: Date? = nil,
        productID: String? = nil,
        repositoryID: String? = nil,
        xcodeVersionID: String? = nil,
        macOSVersionID: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.isEnabled = isEnabled
        self.isLockedForEditing = isLockedForEditing
        self.clean = clean
        self.containerFilePath = containerFilePath
        self.lastModifiedDate = lastModifiedDate
        self.productID = productID
        self.repositoryID = repositoryID
        self.xcodeVersionID = xcodeVersionID
        self.macOSVersionID = macOSVersionID
    }
}

public struct AppStoreConnectXcodeCloudBuildRunSummary: Codable, Sendable, Equatable {
    public var id: String
    public var number: Int?
    public var executionProgress: String?
    public var completionStatus: String?
    public var startReason: String?
    public var cancelReason: String?
    public var createdDate: Date?
    public var startedDate: Date?
    public var finishedDate: Date?
    public var isPullRequestBuild: Bool?
    public var sourceCommitSHA: String?
    public var destinationCommitSHA: String?
    public var workflowID: String?
    public var productID: String?
    public var buildIDs: [String]

    public init(
        id: String,
        number: Int? = nil,
        executionProgress: String? = nil,
        completionStatus: String? = nil,
        startReason: String? = nil,
        cancelReason: String? = nil,
        createdDate: Date? = nil,
        startedDate: Date? = nil,
        finishedDate: Date? = nil,
        isPullRequestBuild: Bool? = nil,
        sourceCommitSHA: String? = nil,
        destinationCommitSHA: String? = nil,
        workflowID: String? = nil,
        productID: String? = nil,
        buildIDs: [String] = []
    ) {
        self.id = id
        self.number = number
        self.executionProgress = executionProgress
        self.completionStatus = completionStatus
        self.startReason = startReason
        self.cancelReason = cancelReason
        self.createdDate = createdDate
        self.startedDate = startedDate
        self.finishedDate = finishedDate
        self.isPullRequestBuild = isPullRequestBuild
        self.sourceCommitSHA = sourceCommitSHA
        self.destinationCommitSHA = destinationCommitSHA
        self.workflowID = workflowID
        self.productID = productID
        self.buildIDs = buildIDs
    }
}

public struct AppStoreConnectXcodeCloudBuildActionSummary: Codable, Sendable, Equatable {
    public var id: String
    public var name: String?
    public var actionType: String?
    public var executionProgress: String?
    public var completionStatus: String?
    public var isRequiredToPass: Bool?
    public var startedDate: Date?
    public var finishedDate: Date?
    public var buildRunID: String?

    public init(
        id: String,
        name: String? = nil,
        actionType: String? = nil,
        executionProgress: String? = nil,
        completionStatus: String? = nil,
        isRequiredToPass: Bool? = nil,
        startedDate: Date? = nil,
        finishedDate: Date? = nil,
        buildRunID: String? = nil
    ) {
        self.id = id
        self.name = name
        self.actionType = actionType
        self.executionProgress = executionProgress
        self.completionStatus = completionStatus
        self.isRequiredToPass = isRequiredToPass
        self.startedDate = startedDate
        self.finishedDate = finishedDate
        self.buildRunID = buildRunID
    }
}

public struct AppStoreConnectXcodeCloudArtifactSummary: Codable, Sendable, Equatable {
    public var id: String
    public var fileType: String?
    public var fileName: String?
    public var fileSize: Int?
    public var downloadURL: String?

    public init(
        id: String,
        fileType: String? = nil,
        fileName: String? = nil,
        fileSize: Int? = nil,
        downloadURL: String? = nil
    ) {
        self.id = id
        self.fileType = fileType
        self.fileName = fileName
        self.fileSize = fileSize
        self.downloadURL = downloadURL
    }
}

public typealias AppStoreConnectXcodeCloudProductListResult = AppStoreConnectListResult<AppStoreConnectXcodeCloudProductSummary>
public typealias AppStoreConnectXcodeCloudProductResult = AppStoreConnectResourceResult<AppStoreConnectXcodeCloudProductSummary>
public typealias AppStoreConnectXcodeCloudWorkflowListResult = AppStoreConnectListResult<AppStoreConnectXcodeCloudWorkflowSummary>
public typealias AppStoreConnectXcodeCloudWorkflowResult = AppStoreConnectResourceResult<AppStoreConnectXcodeCloudWorkflowSummary>
public typealias AppStoreConnectXcodeCloudBuildRunListResult = AppStoreConnectListResult<AppStoreConnectXcodeCloudBuildRunSummary>
public typealias AppStoreConnectXcodeCloudBuildRunResult = AppStoreConnectResourceResult<AppStoreConnectXcodeCloudBuildRunSummary>
public typealias AppStoreConnectXcodeCloudBuildActionListResult = AppStoreConnectListResult<AppStoreConnectXcodeCloudBuildActionSummary>
public typealias AppStoreConnectXcodeCloudBuildActionResult = AppStoreConnectResourceResult<AppStoreConnectXcodeCloudBuildActionSummary>
public typealias AppStoreConnectXcodeCloudArtifactListResult = AppStoreConnectListResult<AppStoreConnectXcodeCloudArtifactSummary>
public typealias AppStoreConnectXcodeCloudArtifactResult = AppStoreConnectResourceResult<AppStoreConnectXcodeCloudArtifactSummary>

public extension PublicAPIReadCommands {
    func listXcodeCloudProducts(
        _ input: AppStoreConnectXcodeCloudProductListInput = .init()
    ) async throws -> AppStoreConnectXcodeCloudProductListResult {
        let output = try await client.openAPI.ciProductsGetCollection(
            query: xcodeCloudProductListQuery(from: input)
        )

        switch output {
        case let .ok(response):
            let body = try response.body.json
            return AppStoreConnectXcodeCloudProductListResult(
                data: body.data.map(Self.xcodeCloudProductSummary),
                next: body.links.next
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected Xcode Cloud products response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Xcode Cloud products listing did not return 200 ok.")
        }
    }

    func getXcodeCloudProduct(
        _ input: AppStoreConnectXcodeCloudProductViewInput
    ) async throws -> AppStoreConnectXcodeCloudProductResult {
        let output = try await client.openAPI.ciProductsGetInstance(
            path: .init(id: input.id),
            query: xcodeCloudProductViewQuery(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectXcodeCloudProductResult(
                data: Self.xcodeCloudProductSummary(try response.body.json.data)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected Xcode Cloud product response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Xcode Cloud product lookup did not return 200 ok.")
        }
    }

    func listXcodeCloudWorkflows(
        _ input: AppStoreConnectXcodeCloudWorkflowListInput
    ) async throws -> AppStoreConnectXcodeCloudWorkflowListResult {
        let output = try await client.openAPI.ciProductsWorkflowsGetToManyRelated(
            path: .init(id: input.productID),
            query: xcodeCloudWorkflowListQuery(from: input)
        )

        switch output {
        case let .ok(response):
            let body = try response.body.json
            return AppStoreConnectXcodeCloudWorkflowListResult(
                data: body.data.map(Self.xcodeCloudWorkflowSummary),
                next: body.links.next
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected Xcode Cloud workflows response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Xcode Cloud workflows listing did not return 200 ok.")
        }
    }

    func getXcodeCloudWorkflow(
        _ input: AppStoreConnectXcodeCloudWorkflowViewInput
    ) async throws -> AppStoreConnectXcodeCloudWorkflowResult {
        let output = try await client.openAPI.ciWorkflowsGetInstance(
            path: .init(id: input.id),
            query: xcodeCloudWorkflowViewQuery(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectXcodeCloudWorkflowResult(
                data: Self.xcodeCloudWorkflowSummary(try response.body.json.data)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected Xcode Cloud workflow response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Xcode Cloud workflow lookup did not return 200 ok.")
        }
    }

    func listXcodeCloudBuildRuns(
        _ input: AppStoreConnectXcodeCloudBuildRunListInput
    ) async throws -> AppStoreConnectXcodeCloudBuildRunListResult {
        if let workflowID = input.workflowID {
            let output = try await client.openAPI.ciWorkflowsBuildRunsGetToManyRelated(
                path: .init(id: workflowID),
                query: xcodeCloudWorkflowBuildRunListQuery(from: input)
            )

            switch output {
            case let .ok(response):
                let body = try response.body.json
                return AppStoreConnectXcodeCloudBuildRunListResult(
                    data: body.data.map(Self.xcodeCloudBuildRunSummary),
                    next: body.links.next
                )
            case let .undocumented(statusCode, _):
                throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected Xcode Cloud workflow build runs response.")
            default:
                throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Xcode Cloud workflow build runs listing did not return 200 ok.")
            }
        }

        guard let productID = input.productID else {
            throw AppStoreConnectError.invalidConfiguration("Xcode Cloud build run listing requires a productID or workflowID.")
        }

        let output = try await client.openAPI.ciProductsBuildRunsGetToManyRelated(
            path: .init(id: productID),
            query: xcodeCloudProductBuildRunListQuery(from: input)
        )

        switch output {
        case let .ok(response):
            let body = try response.body.json
            return AppStoreConnectXcodeCloudBuildRunListResult(
                data: body.data.map(Self.xcodeCloudBuildRunSummary),
                next: body.links.next
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected Xcode Cloud product build runs response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Xcode Cloud product build runs listing did not return 200 ok.")
        }
    }

    func getXcodeCloudBuildRun(
        _ input: AppStoreConnectXcodeCloudBuildRunViewInput
    ) async throws -> AppStoreConnectXcodeCloudBuildRunResult {
        let output = try await client.openAPI.ciBuildRunsGetInstance(
            path: .init(id: input.id),
            query: xcodeCloudBuildRunViewQuery(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectXcodeCloudBuildRunResult(
                data: Self.xcodeCloudBuildRunSummary(try response.body.json.data)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected Xcode Cloud build run response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Xcode Cloud build run lookup did not return 200 ok.")
        }
    }

    func listXcodeCloudBuildActions(
        _ input: AppStoreConnectXcodeCloudBuildActionListInput
    ) async throws -> AppStoreConnectXcodeCloudBuildActionListResult {
        let output = try await client.openAPI.ciBuildRunsActionsGetToManyRelated(
            path: .init(id: input.buildRunID),
            query: xcodeCloudBuildActionListQuery(from: input)
        )

        switch output {
        case let .ok(response):
            let body = try response.body.json
            return AppStoreConnectXcodeCloudBuildActionListResult(
                data: body.data.map(Self.xcodeCloudBuildActionSummary),
                next: body.links.next
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected Xcode Cloud build actions response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Xcode Cloud build actions listing did not return 200 ok.")
        }
    }

    func getXcodeCloudBuildAction(
        _ input: AppStoreConnectXcodeCloudBuildActionViewInput
    ) async throws -> AppStoreConnectXcodeCloudBuildActionResult {
        let output = try await client.openAPI.ciBuildActionsGetInstance(
            path: .init(id: input.id),
            query: xcodeCloudBuildActionViewQuery(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectXcodeCloudBuildActionResult(
                data: Self.xcodeCloudBuildActionSummary(try response.body.json.data)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected Xcode Cloud build action response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Xcode Cloud build action lookup did not return 200 ok.")
        }
    }

    func listXcodeCloudArtifacts(
        _ input: AppStoreConnectXcodeCloudArtifactListInput
    ) async throws -> AppStoreConnectXcodeCloudArtifactListResult {
        let output = try await client.openAPI.ciBuildActionsArtifactsGetToManyRelated(
            path: .init(id: input.buildActionID),
            query: xcodeCloudArtifactListQuery(from: input)
        )

        switch output {
        case let .ok(response):
            let body = try response.body.json
            let artifacts = body.data
                .map(Self.xcodeCloudArtifactSummary)
                .filter { !input.logOnly || $0.fileType == "LOG_BUNDLE" }
            return AppStoreConnectXcodeCloudArtifactListResult(data: artifacts, next: body.links.next)
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected Xcode Cloud artifacts response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Xcode Cloud artifacts listing did not return 200 ok.")
        }
    }

    func getXcodeCloudArtifact(
        _ input: AppStoreConnectXcodeCloudArtifactViewInput
    ) async throws -> AppStoreConnectXcodeCloudArtifactResult {
        let output = try await client.openAPI.ciArtifactsGetInstance(
            path: .init(id: input.id),
            query: xcodeCloudArtifactViewQuery(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectXcodeCloudArtifactResult(
                data: Self.xcodeCloudArtifactSummary(try response.body.json.data)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected Xcode Cloud artifact response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Xcode Cloud artifact lookup did not return 200 ok.")
        }
    }
}

private extension PublicAPIReadCommands {
    func xcodeCloudProductListQuery(
        from input: AppStoreConnectXcodeCloudProductListInput
    ) -> Operations.CiProductsGetCollection.Input.Query {
        var query = Operations.CiProductsGetCollection.Input.Query()
        query.filter_lbrack_productType_rbrack_ = input.productTypes.compactMap {
            Operations.CiProductsGetCollection.Input.Query
                .FilterLbrackProductTypeRbrackPayloadPayload(rawValue: $0.uppercased())
        }.nilIfEmpty
        query.filter_lbrack_app_rbrack_ = input.appIDs.nilIfEmpty
        query.fields_lbrack_ciProducts_rbrack_ = input.fields.compactMap {
            Operations.CiProductsGetCollection.Input.Query
                .FieldsLbrackCiProductsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
        query.include = xcodeCloudProductListIncludes(from: input)
        query.limit = input.limit
        query.limit_lbrack_primaryRepositories_rbrack_ = input.primaryRepositoriesLimit
        return query
    }

    func xcodeCloudProductViewQuery(
        from input: AppStoreConnectXcodeCloudProductViewInput
    ) -> Operations.CiProductsGetInstance.Input.Query {
        var query = Operations.CiProductsGetInstance.Input.Query()
        query.fields_lbrack_ciProducts_rbrack_ = input.fields.compactMap {
            Operations.CiProductsGetInstance.Input.Query
                .FieldsLbrackCiProductsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
        query.include = xcodeCloudProductViewIncludes(from: input)
        query.limit_lbrack_primaryRepositories_rbrack_ = input.primaryRepositoriesLimit
        return query
    }

    func xcodeCloudWorkflowListQuery(
        from input: AppStoreConnectXcodeCloudWorkflowListInput
    ) -> Operations.CiProductsWorkflowsGetToManyRelated.Input.Query {
        var query = Operations.CiProductsWorkflowsGetToManyRelated.Input.Query()
        query.fields_lbrack_ciWorkflows_rbrack_ = input.fields.compactMap {
            Operations.CiProductsWorkflowsGetToManyRelated.Input.Query
                .FieldsLbrackCiWorkflowsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
        query.include = xcodeCloudWorkflowListIncludes(from: input)
        query.limit = input.limit
        return query
    }

    func xcodeCloudWorkflowViewQuery(
        from input: AppStoreConnectXcodeCloudWorkflowViewInput
    ) -> Operations.CiWorkflowsGetInstance.Input.Query {
        var query = Operations.CiWorkflowsGetInstance.Input.Query()
        query.fields_lbrack_ciWorkflows_rbrack_ = input.fields.compactMap {
            Operations.CiWorkflowsGetInstance.Input.Query
                .FieldsLbrackCiWorkflowsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
        query.include = xcodeCloudWorkflowViewIncludes(from: input)
        return query
    }

    func xcodeCloudProductBuildRunListQuery(
        from input: AppStoreConnectXcodeCloudBuildRunListInput
    ) -> Operations.CiProductsBuildRunsGetToManyRelated.Input.Query {
        var query = Operations.CiProductsBuildRunsGetToManyRelated.Input.Query()
        query.filter_lbrack_builds_rbrack_ = input.buildIDs.nilIfEmpty
        query.sort = input.sort.compactMap {
            Operations.CiProductsBuildRunsGetToManyRelated.Input.Query.SortPayloadPayload(rawValue: $0)
        }.nilIfEmpty
        query.fields_lbrack_ciBuildRuns_rbrack_ = input.fields.compactMap {
            Operations.CiProductsBuildRunsGetToManyRelated.Input.Query
                .FieldsLbrackCiBuildRunsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
        query.include = xcodeCloudProductBuildRunIncludes(from: input)
        query.limit = input.limit
        query.limit_lbrack_builds_rbrack_ = input.buildsLimit
        return query
    }

    func xcodeCloudWorkflowBuildRunListQuery(
        from input: AppStoreConnectXcodeCloudBuildRunListInput
    ) -> Operations.CiWorkflowsBuildRunsGetToManyRelated.Input.Query {
        var query = Operations.CiWorkflowsBuildRunsGetToManyRelated.Input.Query()
        query.filter_lbrack_builds_rbrack_ = input.buildIDs.nilIfEmpty
        query.sort = input.sort.compactMap {
            Operations.CiWorkflowsBuildRunsGetToManyRelated.Input.Query.SortPayloadPayload(rawValue: $0)
        }.nilIfEmpty
        query.fields_lbrack_ciBuildRuns_rbrack_ = input.fields.compactMap {
            Operations.CiWorkflowsBuildRunsGetToManyRelated.Input.Query
                .FieldsLbrackCiBuildRunsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
        query.include = xcodeCloudWorkflowBuildRunIncludes(from: input)
        query.limit = input.limit
        query.limit_lbrack_builds_rbrack_ = input.buildsLimit
        return query
    }

    func xcodeCloudBuildRunViewQuery(
        from input: AppStoreConnectXcodeCloudBuildRunViewInput
    ) -> Operations.CiBuildRunsGetInstance.Input.Query {
        var query = Operations.CiBuildRunsGetInstance.Input.Query()
        query.fields_lbrack_ciBuildRuns_rbrack_ = input.fields.compactMap {
            Operations.CiBuildRunsGetInstance.Input.Query
                .FieldsLbrackCiBuildRunsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
        query.include = xcodeCloudBuildRunViewIncludes(from: input)
        query.limit_lbrack_builds_rbrack_ = input.buildsLimit
        return query
    }

    func xcodeCloudBuildActionListQuery(
        from input: AppStoreConnectXcodeCloudBuildActionListInput
    ) -> Operations.CiBuildRunsActionsGetToManyRelated.Input.Query {
        var query = Operations.CiBuildRunsActionsGetToManyRelated.Input.Query()
        query.fields_lbrack_ciBuildActions_rbrack_ = input.fields.compactMap {
            Operations.CiBuildRunsActionsGetToManyRelated.Input.Query
                .FieldsLbrackCiBuildActionsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
        query.include = input.includeBuildRun ? [.buildRun] : nil
        query.limit = input.limit
        return query
    }

    func xcodeCloudBuildActionViewQuery(
        from input: AppStoreConnectXcodeCloudBuildActionViewInput
    ) -> Operations.CiBuildActionsGetInstance.Input.Query {
        var query = Operations.CiBuildActionsGetInstance.Input.Query()
        query.fields_lbrack_ciBuildActions_rbrack_ = input.fields.compactMap {
            Operations.CiBuildActionsGetInstance.Input.Query
                .FieldsLbrackCiBuildActionsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
        query.include = input.includeBuildRun ? [.buildRun] : nil
        return query
    }

    func xcodeCloudArtifactListQuery(
        from input: AppStoreConnectXcodeCloudArtifactListInput
    ) -> Operations.CiBuildActionsArtifactsGetToManyRelated.Input.Query {
        var query = Operations.CiBuildActionsArtifactsGetToManyRelated.Input.Query()
        query.fields_lbrack_ciArtifacts_rbrack_ = input.fields.compactMap {
            Operations.CiBuildActionsArtifactsGetToManyRelated.Input.Query
                .FieldsLbrackCiArtifactsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
        query.limit = input.limit
        return query
    }

    func xcodeCloudArtifactViewQuery(
        from input: AppStoreConnectXcodeCloudArtifactViewInput
    ) -> Operations.CiArtifactsGetInstance.Input.Query {
        var query = Operations.CiArtifactsGetInstance.Input.Query()
        query.fields_lbrack_ciArtifacts_rbrack_ = input.fields.compactMap {
            Operations.CiArtifactsGetInstance.Input.Query
                .FieldsLbrackCiArtifactsRbrackPayloadPayload(rawValue: $0)
        }.nilIfEmpty
        return query
    }

    func xcodeCloudProductListIncludes(
        from input: AppStoreConnectXcodeCloudProductListInput
    ) -> Operations.CiProductsGetCollection.Input.Query.IncludePayload? {
        var include: Operations.CiProductsGetCollection.Input.Query.IncludePayload = []
        if input.includeApp {
            include.append(.app)
        }
        if input.includeBundleID {
            include.append(.bundleId)
        }
        if input.includePrimaryRepositories {
            include.append(.primaryRepositories)
        }
        return include.nilIfEmpty
    }

    func xcodeCloudProductViewIncludes(
        from input: AppStoreConnectXcodeCloudProductViewInput
    ) -> Operations.CiProductsGetInstance.Input.Query.IncludePayload? {
        var include: Operations.CiProductsGetInstance.Input.Query.IncludePayload = []
        if input.includeApp {
            include.append(.app)
        }
        if input.includeBundleID {
            include.append(.bundleId)
        }
        if input.includePrimaryRepositories {
            include.append(.primaryRepositories)
        }
        return include.nilIfEmpty
    }

    func xcodeCloudWorkflowListIncludes(
        from input: AppStoreConnectXcodeCloudWorkflowListInput
    ) -> Operations.CiProductsWorkflowsGetToManyRelated.Input.Query.IncludePayload? {
        var include: Operations.CiProductsWorkflowsGetToManyRelated.Input.Query.IncludePayload = []
        if input.includeProduct {
            include.append(.product)
        }
        if input.includeRepository {
            include.append(.repository)
        }
        if input.includeXcodeVersion {
            include.append(.xcodeVersion)
        }
        if input.includeMacOSVersion {
            include.append(.macOsVersion)
        }
        return include.nilIfEmpty
    }

    func xcodeCloudWorkflowViewIncludes(
        from input: AppStoreConnectXcodeCloudWorkflowViewInput
    ) -> Operations.CiWorkflowsGetInstance.Input.Query.IncludePayload? {
        var include: Operations.CiWorkflowsGetInstance.Input.Query.IncludePayload = []
        if input.includeProduct {
            include.append(.product)
        }
        if input.includeRepository {
            include.append(.repository)
        }
        if input.includeXcodeVersion {
            include.append(.xcodeVersion)
        }
        if input.includeMacOSVersion {
            include.append(.macOsVersion)
        }
        return include.nilIfEmpty
    }

    func xcodeCloudProductBuildRunIncludes(
        from input: AppStoreConnectXcodeCloudBuildRunListInput
    ) -> Operations.CiProductsBuildRunsGetToManyRelated.Input.Query.IncludePayload? {
        var include: Operations.CiProductsBuildRunsGetToManyRelated.Input.Query.IncludePayload = []
        if input.includeBuilds {
            include.append(.builds)
        }
        if input.includeWorkflow {
            include.append(.workflow)
        }
        if input.includeProduct {
            include.append(.product)
        }
        if input.includeSourceBranchOrTag {
            include.append(.sourceBranchOrTag)
        }
        if input.includeDestinationBranch {
            include.append(.destinationBranch)
        }
        if input.includePullRequest {
            include.append(.pullRequest)
        }
        return include.nilIfEmpty
    }

    func xcodeCloudWorkflowBuildRunIncludes(
        from input: AppStoreConnectXcodeCloudBuildRunListInput
    ) -> Operations.CiWorkflowsBuildRunsGetToManyRelated.Input.Query.IncludePayload? {
        var include: Operations.CiWorkflowsBuildRunsGetToManyRelated.Input.Query.IncludePayload = []
        if input.includeBuilds {
            include.append(.builds)
        }
        if input.includeWorkflow {
            include.append(.workflow)
        }
        if input.includeProduct {
            include.append(.product)
        }
        if input.includeSourceBranchOrTag {
            include.append(.sourceBranchOrTag)
        }
        if input.includeDestinationBranch {
            include.append(.destinationBranch)
        }
        if input.includePullRequest {
            include.append(.pullRequest)
        }
        return include.nilIfEmpty
    }

    func xcodeCloudBuildRunViewIncludes(
        from input: AppStoreConnectXcodeCloudBuildRunViewInput
    ) -> Operations.CiBuildRunsGetInstance.Input.Query.IncludePayload? {
        var include: Operations.CiBuildRunsGetInstance.Input.Query.IncludePayload = []
        if input.includeBuilds {
            include.append(.builds)
        }
        if input.includeWorkflow {
            include.append(.workflow)
        }
        if input.includeProduct {
            include.append(.product)
        }
        if input.includeSourceBranchOrTag {
            include.append(.sourceBranchOrTag)
        }
        if input.includeDestinationBranch {
            include.append(.destinationBranch)
        }
        if input.includePullRequest {
            include.append(.pullRequest)
        }
        return include.nilIfEmpty
    }

    static func xcodeCloudProductSummary(
        _ product: Components.Schemas.CiProduct
    ) -> AppStoreConnectXcodeCloudProductSummary {
        AppStoreConnectXcodeCloudProductSummary(
            id: product.id,
            name: product.attributes?.name,
            productType: product.attributes?.productType?.rawValue,
            createdDate: product.attributes?.createdDate,
            appID: product.relationships?.app?.data?.id,
            bundleID: product.relationships?.bundleId?.data?.id,
            primaryRepositoryIDs: product.relationships?.primaryRepositories?.data?.map(\.id) ?? []
        )
    }

    static func xcodeCloudWorkflowSummary(
        _ workflow: Components.Schemas.CiWorkflow
    ) -> AppStoreConnectXcodeCloudWorkflowSummary {
        AppStoreConnectXcodeCloudWorkflowSummary(
            id: workflow.id,
            name: workflow.attributes?.name,
            description: workflow.attributes?.description,
            isEnabled: workflow.attributes?.isEnabled,
            isLockedForEditing: workflow.attributes?.isLockedForEditing,
            clean: workflow.attributes?.clean,
            containerFilePath: workflow.attributes?.containerFilePath,
            lastModifiedDate: workflow.attributes?.lastModifiedDate,
            productID: workflow.relationships?.product?.data?.id,
            repositoryID: workflow.relationships?.repository?.data?.id,
            xcodeVersionID: workflow.relationships?.xcodeVersion?.data?.id,
            macOSVersionID: workflow.relationships?.macOsVersion?.data?.id
        )
    }

    static func xcodeCloudBuildRunSummary(
        _ run: Components.Schemas.CiBuildRun
    ) -> AppStoreConnectXcodeCloudBuildRunSummary {
        AppStoreConnectXcodeCloudBuildRunSummary(
            id: run.id,
            number: run.attributes?.number,
            executionProgress: run.attributes?.executionProgress?.rawValue,
            completionStatus: run.attributes?.completionStatus?.rawValue,
            startReason: run.attributes?.startReason?.rawValue,
            cancelReason: run.attributes?.cancelReason?.rawValue,
            createdDate: run.attributes?.createdDate,
            startedDate: run.attributes?.startedDate,
            finishedDate: run.attributes?.finishedDate,
            isPullRequestBuild: run.attributes?.isPullRequestBuild,
            sourceCommitSHA: run.attributes?.sourceCommit?.commitSha,
            destinationCommitSHA: run.attributes?.destinationCommit?.commitSha,
            workflowID: run.relationships?.workflow?.data?.id,
            productID: run.relationships?.product?.data?.id,
            buildIDs: run.relationships?.builds?.data?.map(\.id) ?? []
        )
    }

    static func xcodeCloudBuildActionSummary(
        _ action: Components.Schemas.CiBuildAction
    ) -> AppStoreConnectXcodeCloudBuildActionSummary {
        AppStoreConnectXcodeCloudBuildActionSummary(
            id: action.id,
            name: action.attributes?.name,
            actionType: action.attributes?.actionType?.rawValue,
            executionProgress: action.attributes?.executionProgress?.rawValue,
            completionStatus: action.attributes?.completionStatus?.rawValue,
            isRequiredToPass: action.attributes?.isRequiredToPass,
            startedDate: action.attributes?.startedDate,
            finishedDate: action.attributes?.finishedDate,
            buildRunID: action.relationships?.buildRun?.data?.id
        )
    }

    static func xcodeCloudArtifactSummary(
        _ artifact: Components.Schemas.CiArtifact
    ) -> AppStoreConnectXcodeCloudArtifactSummary {
        AppStoreConnectXcodeCloudArtifactSummary(
            id: artifact.id,
            fileType: artifact.attributes?.fileType?.rawValue,
            fileName: artifact.attributes?.fileName,
            fileSize: artifact.attributes?.fileSize,
            downloadURL: artifact.attributes?.downloadUrl
        )
    }
}

private extension Array {
    var nilIfEmpty: Self? {
        isEmpty ? nil : self
    }
}
#endif
