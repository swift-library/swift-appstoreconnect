import AppStoreConnectCore
import AppStoreConnectPublicAPI
import Foundation
import OpenAPIRuntime

public struct AppStoreConnectAnalyticsReportViewInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectAnalyticsReportRequestCreateInput: Codable, Sendable, Equatable {
    public var appID: String
    public var accessType: String

    public init(appID: String, accessType: String = "ONE_TIME_SNAPSHOT") {
        self.appID = appID
        self.accessType = accessType
    }
}

public struct AppStoreConnectAnalyticsReportRequestViewInput: Codable, Sendable, Equatable {
    public var id: String
    public var includeReports: Bool
    public var reportLimit: Int?

    public init(id: String, includeReports: Bool = true, reportLimit: Int? = nil) {
        self.id = id
        self.includeReports = includeReports
        self.reportLimit = reportLimit
    }
}

public struct AppStoreConnectAnalyticsReportRequestDeleteInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectAnalyticsReportSegmentViewInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectAnalyticsReportInstanceViewInput: Codable, Sendable, Equatable {
    public var id: String

    public init(id: String) {
        self.id = id
    }
}

public struct AppStoreConnectSalesReportDownloadInput: Codable, Sendable, Equatable {
    public var vendorNumber: String
    public var reportType: String
    public var reportSubType: String
    public var frequency: String
    public var reportDate: String?
    public var version: String?
    public var outputPath: String?

    public init(
        vendorNumber: String,
        reportType: String,
        reportSubType: String,
        frequency: String,
        reportDate: String? = nil,
        version: String? = nil,
        outputPath: String? = nil
    ) {
        self.vendorNumber = vendorNumber
        self.reportType = reportType
        self.reportSubType = reportSubType
        self.frequency = frequency
        self.reportDate = reportDate
        self.version = version
        self.outputPath = outputPath
    }
}

public struct AppStoreConnectFinanceReportDownloadInput: Codable, Sendable, Equatable {
    public var vendorNumber: String
    public var reportType: String
    public var regionCode: String
    public var reportDate: String
    public var outputPath: String?

    public init(
        vendorNumber: String,
        reportType: String,
        regionCode: String,
        reportDate: String,
        outputPath: String? = nil
    ) {
        self.vendorNumber = vendorNumber
        self.reportType = reportType
        self.regionCode = regionCode
        self.reportDate = reportDate
        self.outputPath = outputPath
    }
}

#if ASC_PUBLIC_API_REPORTS
public struct AppStoreConnectPerformanceMetricsInput: Codable, Sendable, Equatable {
    public var appID: String?
    public var buildID: String?
    public var platform: String?
    public var metricType: String?
    public var deviceTypes: [String]
    public var outputPath: String?

    public init(
        appID: String? = nil,
        buildID: String? = nil,
        platform: String? = nil,
        metricType: String? = nil,
        deviceTypes: [String] = [],
        outputPath: String? = nil
    ) {
        self.appID = appID
        self.buildID = buildID
        self.platform = platform
        self.metricType = metricType
        self.deviceTypes = deviceTypes
        self.outputPath = outputPath
    }
}
#endif

public struct AppStoreConnectAnalyticsReportSummary: Codable, Sendable, Equatable {
    public var id: String
    public var category: String?
    public var name: String?

    public init(id: String, category: String? = nil, name: String? = nil) {
        self.id = id
        self.category = category
        self.name = name
    }
}

public struct AppStoreConnectAnalyticsReportRequestSummary: Codable, Sendable, Equatable {
    public var id: String
    public var accessType: String?
    public var stoppedDueToInactivity: Bool?
    public var reportIDs: [String]
    public var includedReports: [AppStoreConnectAnalyticsReportSummary]

    public init(
        id: String,
        accessType: String? = nil,
        stoppedDueToInactivity: Bool? = nil,
        reportIDs: [String] = [],
        includedReports: [AppStoreConnectAnalyticsReportSummary] = []
    ) {
        self.id = id
        self.accessType = accessType
        self.stoppedDueToInactivity = stoppedDueToInactivity
        self.reportIDs = reportIDs
        self.includedReports = includedReports
    }
}

public struct AppStoreConnectAnalyticsReportSegmentSummary: Codable, Sendable, Equatable {
    public var id: String
    public var checksum: String?
    public var sizeInBytes: Int?
    public var url: String?

    public init(id: String, checksum: String? = nil, sizeInBytes: Int? = nil, url: String? = nil) {
        self.id = id
        self.checksum = checksum
        self.sizeInBytes = sizeInBytes
        self.url = url
    }
}

public struct AppStoreConnectAnalyticsReportInstanceSummary: Codable, Sendable, Equatable {
    public var id: String
    public var granularity: String?
    public var processingDate: String?

    public init(id: String, granularity: String? = nil, processingDate: String? = nil) {
        self.id = id
        self.granularity = granularity
        self.processingDate = processingDate
    }
}

public struct AppStoreConnectReportDownloadSummary: Codable, Sendable, Equatable {
    public var kind: String
    public var operationID: String
    public var outputPath: String
    public var byteCount: Int
    public var vendorNumber: String
    public var reportType: String
    public var reportSubType: String?
    public var frequency: String?
    public var regionCode: String?
    public var reportDate: String?
    public var version: String?

    public init(
        kind: String,
        operationID: String,
        outputPath: String,
        byteCount: Int,
        vendorNumber: String,
        reportType: String,
        reportSubType: String? = nil,
        frequency: String? = nil,
        regionCode: String? = nil,
        reportDate: String? = nil,
        version: String? = nil
    ) {
        self.kind = kind
        self.operationID = operationID
        self.outputPath = outputPath
        self.byteCount = byteCount
        self.vendorNumber = vendorNumber
        self.reportType = reportType
        self.reportSubType = reportSubType
        self.frequency = frequency
        self.regionCode = regionCode
        self.reportDate = reportDate
        self.version = version
    }
}

#if ASC_PUBLIC_API_REPORTS
public struct AppStoreConnectPerformanceMetricsSummary: Codable, Sendable, Equatable {
    public var scope: String
    public var operationID: String
    public var appID: String?
    public var buildID: String?
    public var version: String?
    public var productDataCount: Int
    public var metricCategoryCount: Int
    public var metricCount: Int
    public var datasetCount: Int
    public var pointCount: Int
    public var regressionCount: Int
    public var trendingUpCount: Int
    public var metricCategories: [String]
    public var metrics: [String]

    public init(
        scope: String,
        operationID: String,
        appID: String? = nil,
        buildID: String? = nil,
        version: String? = nil,
        productDataCount: Int,
        metricCategoryCount: Int,
        metricCount: Int,
        datasetCount: Int,
        pointCount: Int,
        regressionCount: Int,
        trendingUpCount: Int,
        metricCategories: [String],
        metrics: [String]
    ) {
        self.scope = scope
        self.operationID = operationID
        self.appID = appID
        self.buildID = buildID
        self.version = version
        self.productDataCount = productDataCount
        self.metricCategoryCount = metricCategoryCount
        self.metricCount = metricCount
        self.datasetCount = datasetCount
        self.pointCount = pointCount
        self.regressionCount = regressionCount
        self.trendingUpCount = trendingUpCount
        self.metricCategories = metricCategories
        self.metrics = metrics
    }
}

public struct AppStoreConnectPerformanceMetricsDownloadSummary: Codable, Sendable, Equatable {
    public var outputPath: String
    public var byteCount: Int
    public var metrics: AppStoreConnectPerformanceMetricsSummary

    public init(outputPath: String, byteCount: Int, metrics: AppStoreConnectPerformanceMetricsSummary) {
        self.outputPath = outputPath
        self.byteCount = byteCount
        self.metrics = metrics
    }
}
#endif

public typealias AppStoreConnectAnalyticsReportResult = AppStoreConnectResourceResult<AppStoreConnectAnalyticsReportSummary>
public typealias AppStoreConnectAnalyticsReportRequestResult = AppStoreConnectResourceResult<AppStoreConnectAnalyticsReportRequestSummary>
public typealias AppStoreConnectAnalyticsReportSegmentResult = AppStoreConnectResourceResult<AppStoreConnectAnalyticsReportSegmentSummary>
public typealias AppStoreConnectAnalyticsReportInstanceResult = AppStoreConnectResourceResult<AppStoreConnectAnalyticsReportInstanceSummary>
public typealias AppStoreConnectReportDownloadResult = AppStoreConnectResourceResult<AppStoreConnectReportDownloadSummary>
#if ASC_PUBLIC_API_REPORTS
public typealias AppStoreConnectPerformanceMetricsResult = AppStoreConnectResourceResult<AppStoreConnectPerformanceMetricsSummary>
public typealias AppStoreConnectPerformanceMetricsDownloadResult = AppStoreConnectResourceResult<AppStoreConnectPerformanceMetricsDownloadSummary>
#endif

public extension PublicAPIReadCommands {
    func getAnalyticsReport(
        _ input: AppStoreConnectAnalyticsReportViewInput
    ) async throws -> AppStoreConnectAnalyticsReportResult {
        let output = try await client.reports.getAnalyticsReport(id: input.id)

        switch output {
        case let .ok(response):
            return AppStoreConnectAnalyticsReportResult(data: Self.analyticsReportSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected analytics report response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Analytics report lookup did not return 200 ok.")
        }
    }

    func getAnalyticsReportRequest(
        _ input: AppStoreConnectAnalyticsReportRequestViewInput
    ) async throws -> AppStoreConnectAnalyticsReportRequestResult {
        let output = try await client.reports.getAnalyticsReportRequest(
            id: input.id,
            query: .init(
                include: input.includeReports ? [.reports] : nil,
                limit_lbrack_reports_rbrack_: input.reportLimit
            )
        )

        switch output {
        case let .ok(response):
            let body = try response.body.json
            return AppStoreConnectAnalyticsReportRequestResult(
                data: Self.analyticsReportRequestSummary(body.data, included: body.included ?? [])
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected analytics report request response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Analytics report request lookup did not return 200 ok.")
        }
    }

    func getAnalyticsReportSegment(
        _ input: AppStoreConnectAnalyticsReportSegmentViewInput
    ) async throws -> AppStoreConnectAnalyticsReportSegmentResult {
        let output = try await client.reports.getAnalyticsReportSegment(id: input.id)

        switch output {
        case let .ok(response):
            return AppStoreConnectAnalyticsReportSegmentResult(data: Self.analyticsReportSegmentSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected analytics report segment response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Analytics report segment lookup did not return 200 ok.")
        }
    }

    func getAnalyticsReportInstance(
        _ input: AppStoreConnectAnalyticsReportInstanceViewInput
    ) async throws -> AppStoreConnectAnalyticsReportInstanceResult {
        let output = try await client.reports.getAnalyticsReportInstance(id: input.id)

        switch output {
        case let .ok(response):
            return AppStoreConnectAnalyticsReportInstanceResult(data: Self.analyticsReportInstanceSummary(try response.body.json.data))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected analytics report instance response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Analytics report instance lookup did not return 200 ok.")
        }
    }

    func downloadSalesReport(
        _ input: AppStoreConnectSalesReportDownloadInput
    ) async throws -> AppStoreConnectReportDownloadResult {
        let output = try await client.reports.listSalesReports(query: try salesReportQuery(from: input))

        switch output {
        case let .ok(response):
            let body = try response.body.applicationAGzip
            let url = try destinationURL(for: input.outputPath, prefix: "sales-report", extension: "gz")
            let byteCount = try await write(body, to: url)
            return AppStoreConnectReportDownloadResult(data: .init(
                kind: "sales",
                operationID: Operations.SalesReportsGetCollection.id,
                outputPath: url.path,
                byteCount: byteCount,
                vendorNumber: input.vendorNumber,
                reportType: input.reportType,
                reportSubType: input.reportSubType,
                frequency: input.frequency,
                reportDate: input.reportDate,
                version: input.version
            ))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected sales report response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Sales report download did not return 200 ok.")
        }
    }

    func downloadFinanceReport(
        _ input: AppStoreConnectFinanceReportDownloadInput
    ) async throws -> AppStoreConnectReportDownloadResult {
        let output = try await client.reports.listFinanceReports(query: try financeReportQuery(from: input))

        switch output {
        case let .ok(response):
            let body = try response.body.applicationAGzip
            let url = try destinationURL(for: input.outputPath, prefix: "finance-report", extension: "gz")
            let byteCount = try await write(body, to: url)
            return AppStoreConnectReportDownloadResult(data: .init(
                kind: "finance",
                operationID: Operations.FinanceReportsGetCollection.id,
                outputPath: url.path,
                byteCount: byteCount,
                vendorNumber: input.vendorNumber,
                reportType: input.reportType,
                regionCode: input.regionCode,
                reportDate: input.reportDate
            ))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected finance report response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Finance report download did not return 200 ok.")
        }
    }

#if ASC_PUBLIC_API_REPORTS
    func getPerformanceMetrics(
        _ input: AppStoreConnectPerformanceMetricsInput
    ) async throws -> AppStoreConnectPerformanceMetricsResult {
        try validatePerformanceSelector(input)
        if let appID = input.appID {
            return try await getAppPerformanceMetrics(input, appID: appID)
        }
        return try await getBuildPerformanceMetrics(input, buildID: input.buildID!)
    }

    func downloadPerformanceMetrics(
        _ input: AppStoreConnectPerformanceMetricsInput
    ) async throws -> AppStoreConnectPerformanceMetricsDownloadResult {
        try validatePerformanceSelector(input)
        let body: Components.Schemas.XcodeMetrics
        let summary: AppStoreConnectPerformanceMetricsSummary

        if let appID = input.appID {
            let output = try await client.openAPI.appsPerfPowerMetricsGetToManyRelated(
                path: .init(id: appID),
                query: try appPerformanceMetricsQuery(from: input)
            )
            switch output {
            case let .ok(response):
                body = try response.body.applicationVnd_apple_xcodeMetricsJson
                summary = Self.performanceMetricsSummary(
                    body,
                    scope: "app",
                    operationID: Operations.AppsPerfPowerMetricsGetToManyRelated.id,
                    appID: appID
                )
            case let .undocumented(statusCode, _):
                throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected app performance metrics response.")
            default:
                throw AppStoreConnectError.requestFailed(statusCode: -1, message: "App performance metrics lookup did not return 200 ok.")
            }
        } else {
            let buildID = input.buildID!
            let output = try await client.openAPI.buildsPerfPowerMetricsGetToManyRelated(
                path: .init(id: buildID),
                query: try buildPerformanceMetricsQuery(from: input)
            )
            switch output {
            case let .ok(response):
                body = try response.body.applicationVnd_apple_xcodeMetricsJson
                summary = Self.performanceMetricsSummary(
                    body,
                    scope: "build",
                    operationID: Operations.BuildsPerfPowerMetricsGetToManyRelated.id,
                    buildID: buildID
                )
            case let .undocumented(statusCode, _):
                throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected build performance metrics response.")
            default:
                throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Build performance metrics lookup did not return 200 ok.")
            }
        }

        let url = try destinationURL(for: input.outputPath, prefix: "performance-metrics", extension: "json")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let byteCount = try write(encoder.encode(body), to: url)
        return AppStoreConnectPerformanceMetricsDownloadResult(data: .init(
            outputPath: url.path,
            byteCount: byteCount,
            metrics: summary
        ))
    }
#endif

    private func salesReportQuery(
        from input: AppStoreConnectSalesReportDownloadInput
    ) throws -> Operations.SalesReportsGetCollection.Input.Query {
        try .init(
            filter_lbrack_vendorNumber_rbrack_: [input.vendorNumber],
            filter_lbrack_reportType_rbrack_: [
                requiredSalesReportType(input.reportType),
            ],
            filter_lbrack_reportSubType_rbrack_: [
                requiredSalesReportSubType(input.reportSubType),
            ],
            filter_lbrack_frequency_rbrack_: [
                requiredSalesReportFrequency(input.frequency),
            ],
            filter_lbrack_reportDate_rbrack_: input.reportDate.map { [$0] },
            filter_lbrack_version_rbrack_: input.version.map { [$0] }
        )
    }

    private func financeReportQuery(
        from input: AppStoreConnectFinanceReportDownloadInput
    ) throws -> Operations.FinanceReportsGetCollection.Input.Query {
        try .init(
            filter_lbrack_vendorNumber_rbrack_: [input.vendorNumber],
            filter_lbrack_reportType_rbrack_: [
                requiredFinanceReportType(input.reportType),
            ],
            filter_lbrack_regionCode_rbrack_: [input.regionCode],
            filter_lbrack_reportDate_rbrack_: [input.reportDate]
        )
    }

#if ASC_PUBLIC_API_REPORTS
    private func getAppPerformanceMetrics(
        _ input: AppStoreConnectPerformanceMetricsInput,
        appID: String
    ) async throws -> AppStoreConnectPerformanceMetricsResult {
        let output = try await client.openAPI.appsPerfPowerMetricsGetToManyRelated(
            path: .init(id: appID),
            query: try appPerformanceMetricsQuery(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectPerformanceMetricsResult(data: Self.performanceMetricsSummary(
                try response.body.applicationVnd_apple_xcodeMetricsJson,
                scope: "app",
                operationID: Operations.AppsPerfPowerMetricsGetToManyRelated.id,
                appID: appID
            ))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected app performance metrics response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "App performance metrics lookup did not return 200 ok.")
        }
    }

    private func getBuildPerformanceMetrics(
        _ input: AppStoreConnectPerformanceMetricsInput,
        buildID: String
    ) async throws -> AppStoreConnectPerformanceMetricsResult {
        let output = try await client.openAPI.buildsPerfPowerMetricsGetToManyRelated(
            path: .init(id: buildID),
            query: try buildPerformanceMetricsQuery(from: input)
        )

        switch output {
        case let .ok(response):
            return AppStoreConnectPerformanceMetricsResult(data: Self.performanceMetricsSummary(
                try response.body.applicationVnd_apple_xcodeMetricsJson,
                scope: "build",
                operationID: Operations.BuildsPerfPowerMetricsGetToManyRelated.id,
                buildID: buildID
            ))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected build performance metrics response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Build performance metrics lookup did not return 200 ok.")
        }
    }

    private func appPerformanceMetricsQuery(
        from input: AppStoreConnectPerformanceMetricsInput
    ) throws -> Operations.AppsPerfPowerMetricsGetToManyRelated.Input.Query {
        try .init(
            filter_lbrack_platform_rbrack_: input.platform.map { [try requiredAppPerformancePlatform($0)] },
            filter_lbrack_metricType_rbrack_: input.metricType.map { [try requiredAppPerformanceMetricType($0)] },
            filter_lbrack_deviceType_rbrack_: input.deviceTypes.isEmpty ? nil : input.deviceTypes
        )
    }

    private func buildPerformanceMetricsQuery(
        from input: AppStoreConnectPerformanceMetricsInput
    ) throws -> Operations.BuildsPerfPowerMetricsGetToManyRelated.Input.Query {
        try .init(
            filter_lbrack_platform_rbrack_: input.platform.map { [try requiredBuildPerformancePlatform($0)] },
            filter_lbrack_metricType_rbrack_: input.metricType.map { [try requiredBuildPerformanceMetricType($0)] },
            filter_lbrack_deviceType_rbrack_: input.deviceTypes.isEmpty ? nil : input.deviceTypes
        )
    }

    fileprivate static func performanceMetricsSummary(
        _ metrics: Components.Schemas.XcodeMetrics,
        scope: String,
        operationID: String,
        appID: String? = nil,
        buildID: String? = nil
    ) -> AppStoreConnectPerformanceMetricsSummary {
        let productData = metrics.productData ?? []
        let metricCategories = productData.flatMap { $0.metricCategories ?? [] }
        let metricPayloads = metricCategories.flatMap { $0.metrics ?? [] }
        let datasets = metricPayloads.flatMap { $0.datasets ?? [] }
        let points = datasets.flatMap { $0.points ?? [] }
        let categoryNames = Array(Set(metricCategories.compactMap { $0.identifier?.rawValue })).sorted()
        let metricNames = Array(Set(metricPayloads.compactMap(\.identifier))).sorted()

        return AppStoreConnectPerformanceMetricsSummary(
            scope: scope,
            operationID: operationID,
            appID: appID,
            buildID: buildID,
            version: metrics.version,
            productDataCount: productData.count,
            metricCategoryCount: metricCategories.count,
            metricCount: metricPayloads.count,
            datasetCount: datasets.count,
            pointCount: points.count,
            regressionCount: metrics.insights?.regressions?.count ?? 0,
            trendingUpCount: metrics.insights?.trendingUp?.count ?? 0,
            metricCategories: categoryNames,
            metrics: metricNames
        )
    }

    private func validatePerformanceSelector(_ input: AppStoreConnectPerformanceMetricsInput) throws {
        let hasApp = input.appID?.isEmpty == false
        let hasBuild = input.buildID?.isEmpty == false
        guard hasApp != hasBuild else {
            throw AppStoreConnectError.invalidConfiguration("Specify exactly one of appID or buildID for performance metrics.")
        }
    }
#endif

    fileprivate static func analyticsReportSummary(
        _ report: Components.Schemas.AnalyticsReport
    ) -> AppStoreConnectAnalyticsReportSummary {
        AppStoreConnectAnalyticsReportSummary(
            id: report.id,
            category: report.attributes?.category?.rawValue,
            name: report.attributes?.name
        )
    }

    fileprivate static func analyticsReportRequestSummary(
        _ request: Components.Schemas.AnalyticsReportRequest,
        included: [Components.Schemas.AnalyticsReport] = []
    ) -> AppStoreConnectAnalyticsReportRequestSummary {
        AppStoreConnectAnalyticsReportRequestSummary(
            id: request.id,
            accessType: request.attributes?.accessType?.rawValue,
            stoppedDueToInactivity: request.attributes?.stoppedDueToInactivity,
            reportIDs: request.relationships?.reports?.data?.map(\.id) ?? [],
            includedReports: included.map(analyticsReportSummary)
        )
    }

    fileprivate static func analyticsReportSegmentSummary(
        _ segment: Components.Schemas.AnalyticsReportSegment
    ) -> AppStoreConnectAnalyticsReportSegmentSummary {
        AppStoreConnectAnalyticsReportSegmentSummary(
            id: segment.id,
            checksum: segment.attributes?.checksum,
            sizeInBytes: segment.attributes?.sizeInBytes,
            url: segment.attributes?.url
        )
    }

    fileprivate static func analyticsReportInstanceSummary(
        _ instance: Components.Schemas.AnalyticsReportInstance
    ) -> AppStoreConnectAnalyticsReportInstanceSummary {
        AppStoreConnectAnalyticsReportInstanceSummary(
            id: instance.id,
            granularity: instance.attributes?.granularity?.rawValue,
            processingDate: instance.attributes?.processingDate
        )
    }
}

public extension PublicAPIWriteCommands {
    static func planCreateAnalyticsReportRequest(
        _ input: AppStoreConnectAnalyticsReportRequestCreateInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.AnalyticsReportRequestsCreateInstance.id,
            commandDescription: "Create analytics report request for app \(input.appID).",
            inputs: [
                "accessType": input.accessType,
                "appID": input.appID,
            ]
        )
    }

    static func planDeleteAnalyticsReportRequest(
        _ input: AppStoreConnectAnalyticsReportRequestDeleteInput
    ) -> AppStoreConnectPublicAPIMutationPlan {
        AppStoreConnectPublicAPIMutationPlan(
            operationID: Operations.AnalyticsReportRequestsDeleteInstance.id,
            commandDescription: "Delete analytics report request \(input.id).",
            inputs: ["id": input.id]
        )
    }

    func createAnalyticsReportRequest(
        _ input: AppStoreConnectAnalyticsReportRequestCreateInput
    ) async throws -> AppStoreConnectAnalyticsReportRequestResult {
        let output = try await client.reports.createAnalyticsReportRequest(
            body: try analyticsReportRequestCreateBody(from: input)
        )

        switch output {
        case let .created(response):
            return AppStoreConnectAnalyticsReportRequestResult(
                data: PublicAPIReadCommands.analyticsReportRequestSummary(try response.body.json.data)
            )
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected analytics report request create response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Analytics report request create did not return 201 created.")
        }
    }

    func deleteAnalyticsReportRequest(
        _ input: AppStoreConnectAnalyticsReportRequestDeleteInput
    ) async throws -> AppStoreConnectMutationAcknowledgementResult {
        let output = try await client.reports.deleteAnalyticsReportRequest(id: input.id)

        switch output {
        case .noContent:
            return AppStoreConnectMutationAcknowledgementResult(data: .init(
                operationID: Operations.AnalyticsReportRequestsDeleteInstance.id,
                resourceType: "analyticsReportRequests",
                id: input.id,
                status: "deleted"
            ))
        case let .undocumented(statusCode, _):
            throw AppStoreConnectError.requestFailed(statusCode: statusCode, message: "Unexpected analytics report request delete response.")
        default:
            throw AppStoreConnectError.requestFailed(statusCode: -1, message: "Analytics report request delete did not return 204 no content.")
        }
    }

    private func analyticsReportRequestCreateBody(
        from input: AppStoreConnectAnalyticsReportRequestCreateInput
    ) throws -> Operations.AnalyticsReportRequestsCreateInstance.Input.Body {
        .json(.init(data: .init(
            attributes: .init(accessType: try requiredAnalyticsAccessType(input.accessType)),
            relationships: .init(app: .init(data: .init(id: input.appID, _type: .apps))),
            _type: .analyticsReportRequests
        )))
    }
}

private func requiredAnalyticsAccessType(
    _ value: String
) throws -> Components.Schemas.AnalyticsReportRequestCreateRequest.DataPayload.AttributesPayload.AccessTypePayload {
    guard let result = Components.Schemas.AnalyticsReportRequestCreateRequest.DataPayload.AttributesPayload.AccessTypePayload(
        rawValue: value
    ) else {
        throw AppStoreConnectError.invalidConfiguration("Unsupported analytics report access type: \(value).")
    }
    return result
}

private func requiredSalesReportType(
    _ value: String
) throws -> Operations.SalesReportsGetCollection.Input.Query.FilterLbrackReportTypeRbrackPayloadPayload {
    guard let result = Operations.SalesReportsGetCollection.Input.Query.FilterLbrackReportTypeRbrackPayloadPayload(
        rawValue: value
    ) else {
        throw AppStoreConnectError.invalidConfiguration("Unsupported sales report type: \(value).")
    }
    return result
}

private func requiredSalesReportSubType(
    _ value: String
) throws -> Operations.SalesReportsGetCollection.Input.Query.FilterLbrackReportSubTypeRbrackPayloadPayload {
    guard let result = Operations.SalesReportsGetCollection.Input.Query.FilterLbrackReportSubTypeRbrackPayloadPayload(
        rawValue: value
    ) else {
        throw AppStoreConnectError.invalidConfiguration("Unsupported sales report subtype: \(value).")
    }
    return result
}

private func requiredSalesReportFrequency(
    _ value: String
) throws -> Operations.SalesReportsGetCollection.Input.Query.FilterLbrackFrequencyRbrackPayloadPayload {
    guard let result = Operations.SalesReportsGetCollection.Input.Query.FilterLbrackFrequencyRbrackPayloadPayload(
        rawValue: value
    ) else {
        throw AppStoreConnectError.invalidConfiguration("Unsupported sales report frequency: \(value).")
    }
    return result
}

private func requiredFinanceReportType(
    _ value: String
) throws -> Operations.FinanceReportsGetCollection.Input.Query.FilterLbrackReportTypeRbrackPayloadPayload {
    guard let result = Operations.FinanceReportsGetCollection.Input.Query.FilterLbrackReportTypeRbrackPayloadPayload(
        rawValue: value
    ) else {
        throw AppStoreConnectError.invalidConfiguration("Unsupported finance report type: \(value).")
    }
    return result
}

#if ASC_PUBLIC_API_REPORTS
private func requiredAppPerformancePlatform(
    _ value: String
) throws -> Operations.AppsPerfPowerMetricsGetToManyRelated.Input.Query.FilterLbrackPlatformRbrackPayloadPayload {
    let normalized = normalizedPerformanceFilter(value)
    guard let result = Operations.AppsPerfPowerMetricsGetToManyRelated.Input.Query.FilterLbrackPlatformRbrackPayloadPayload(
        rawValue: normalized
    ) else {
        throw AppStoreConnectError.invalidConfiguration("Unsupported app performance platform: \(value).")
    }
    return result
}

private func requiredBuildPerformancePlatform(
    _ value: String
) throws -> Operations.BuildsPerfPowerMetricsGetToManyRelated.Input.Query.FilterLbrackPlatformRbrackPayloadPayload {
    let normalized = normalizedPerformanceFilter(value)
    guard let result = Operations.BuildsPerfPowerMetricsGetToManyRelated.Input.Query.FilterLbrackPlatformRbrackPayloadPayload(
        rawValue: normalized
    ) else {
        throw AppStoreConnectError.invalidConfiguration("Unsupported build performance platform: \(value).")
    }
    return result
}

private func requiredAppPerformanceMetricType(
    _ value: String
) throws -> Operations.AppsPerfPowerMetricsGetToManyRelated.Input.Query.FilterLbrackMetricTypeRbrackPayloadPayload {
    let normalized = normalizedPerformanceFilter(value)
    guard let result = Operations.AppsPerfPowerMetricsGetToManyRelated.Input.Query.FilterLbrackMetricTypeRbrackPayloadPayload(
        rawValue: normalized
    ) else {
        throw AppStoreConnectError.invalidConfiguration("Unsupported app performance metric type: \(value).")
    }
    return result
}

private func requiredBuildPerformanceMetricType(
    _ value: String
) throws -> Operations.BuildsPerfPowerMetricsGetToManyRelated.Input.Query.FilterLbrackMetricTypeRbrackPayloadPayload {
    let normalized = normalizedPerformanceFilter(value)
    guard let result = Operations.BuildsPerfPowerMetricsGetToManyRelated.Input.Query.FilterLbrackMetricTypeRbrackPayloadPayload(
        rawValue: normalized
    ) else {
        throw AppStoreConnectError.invalidConfiguration("Unsupported build performance metric type: \(value).")
    }
    return result
}

private func normalizedPerformanceFilter(_ value: String) -> String {
    value.trimmingCharacters(in: .whitespacesAndNewlines)
        .replacingOccurrences(of: "-", with: "_")
        .uppercased()
}
#endif

private func destinationURL(
    for outputPath: String?,
    prefix: String,
    extension pathExtension: String
) throws -> URL {
    if let outputPath, !outputPath.isEmpty {
        return URL(fileURLWithPath: outputPath)
    }

    return FileManager.default.temporaryDirectory
        .appendingPathComponent("\(prefix)-\(UUID().uuidString)")
        .appendingPathExtension(pathExtension)
}

@discardableResult
private func write(_ data: Data, to url: URL) throws -> Int {
    let directory = url.deletingLastPathComponent()
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    try data.write(to: url, options: [.atomic])
    return data.count
}

@discardableResult
private func write(_ body: HTTPBody, to url: URL) async throws -> Int {
    let data = try await Data(collecting: body, upTo: 256 * 1024 * 1024)
    let directory = url.deletingLastPathComponent()
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    try data.write(to: url, options: [.atomic])
    return data.count
}
