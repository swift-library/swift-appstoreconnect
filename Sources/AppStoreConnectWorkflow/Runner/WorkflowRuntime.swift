import AppStoreConnectCore
import AppStoreConnectPublicAPI
import Foundation

public struct WorkflowRuntimeConfiguration: Sendable, Equatable {
    public var environment: [String: String]
    public var bearerTokenVariable: String

    public init(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        bearerTokenVariable: String = "ASC_API_TOKEN"
    ) {
        self.environment = environment
        self.bearerTokenVariable = bearerTokenVariable
    }
}

public enum WorkflowRuntime {
    public static func publicReadCommands(
        configuration: WorkflowRuntimeConfiguration = WorkflowRuntimeConfiguration()
    ) throws -> PublicAPIReadCommands {
        PublicAPIReadCommands(
            client: try publicClient(configuration: configuration)
        )
    }

    public static func publicWriteCommands(
        configuration: WorkflowRuntimeConfiguration = WorkflowRuntimeConfiguration()
    ) throws -> PublicAPIWriteCommands {
        PublicAPIWriteCommands(
            client: try publicClient(configuration: configuration)
        )
    }

    public static func publicReleaseReadinessWorkflow(
        configuration: WorkflowRuntimeConfiguration = WorkflowRuntimeConfiguration()
    ) throws -> PublicReleaseReadinessWorkflow {
        PublicReleaseReadinessWorkflow(
            client: try publicClient(configuration: configuration)
        )
    }

    public static func authCommands(
        configuration: WorkflowRuntimeConfiguration = WorkflowRuntimeConfiguration()
    ) -> AppStoreConnectAuthCommands {
        AppStoreConnectAuthCommands(environment: configuration.environment)
    }

    public static func xcodeCommands(
        runner: AppStoreConnectLocalToolRunner = .live
    ) -> AppStoreConnectXcodeCommands {
        AppStoreConnectXcodeCommands(runner: runner)
    }

    private static func publicClient(
        configuration: WorkflowRuntimeConfiguration
    ) throws -> AppStoreConnectPublicClient {
        guard let token = configuration.environment[configuration.bearerTokenVariable], !token.isEmpty else {
            throw AppStoreConnectError.authenticationFailed(
                "Missing \(configuration.bearerTokenVariable) bearer token for public API workflow execution."
            )
        }

        return AppStoreConnectPublicClient(
            client: Client.appStoreConnectURLSession(
                credential: AppStoreConnectBearerToken(token: token)
            )
        )
    }

    public static func executionContext(
        configuration: WorkflowRuntimeConfiguration = WorkflowRuntimeConfiguration()
    ) throws -> WorkflowExecutionContext {
        let workflow = try publicReleaseReadinessWorkflow(configuration: configuration)

        return WorkflowExecutionContext { input in
            await workflow.run(input)
        }
    }
}
