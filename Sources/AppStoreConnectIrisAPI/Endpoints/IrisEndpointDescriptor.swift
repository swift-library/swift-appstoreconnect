import AppStoreConnectCore
import Foundation

public enum IrisEndpointID: String, Codable, Sendable, CaseIterable, Equatable {
    case appStoreVersionStateChanges
}

public enum IrisDriftPolicy: String, Codable, Sendable, CaseIterable, Equatable {
    case failClosed
}

public struct IrisEndpointDescriptor: Codable, Sendable, Equatable {
    public var id: IrisEndpointID
    public var capability: IrisCapability
    public var method: AppStoreConnectHTTPMethod
    public var host: URL
    public var pathTemplate: String
    public var requiredHeaders: [String]
    public var sessionRequirement: String
    public var requestPayload: String
    public var responsePayload: String
    public var observationID: String
    public var observedAt: String
    public var isMutating: Bool
    public var driftPolicy: IrisDriftPolicy

    public init(
        id: IrisEndpointID,
        capability: IrisCapability,
        method: AppStoreConnectHTTPMethod,
        host: URL,
        pathTemplate: String,
        requiredHeaders: [String],
        sessionRequirement: String,
        requestPayload: String,
        responsePayload: String,
        observationID: String,
        observedAt: String,
        isMutating: Bool,
        driftPolicy: IrisDriftPolicy
    ) {
        self.id = id
        self.capability = capability
        self.method = method
        self.host = host
        self.pathTemplate = pathTemplate
        self.requiredHeaders = requiredHeaders
        self.sessionRequirement = sessionRequirement
        self.requestPayload = requestPayload
        self.responsePayload = responsePayload
        self.observationID = observationID
        self.observedAt = observedAt
        self.isMutating = isMutating
        self.driftPolicy = driftPolicy
    }

    public func path(parameters: [String: String]) throws -> String {
        try parameters.reduce(pathTemplate) { partial, element in
            let token = "{\(element.key)}"
            guard partial.contains(token) else {
                throw AppStoreConnectError.invalidConfiguration(
                    "Iris endpoint \(id.rawValue) does not contain path parameter \(element.key)."
                )
            }

            return partial.replacingOccurrences(of: token, with: element.value.irisPathComponent)
        }
    }
}

private extension String {
    var irisPathComponent: String {
        var allowed = CharacterSet.urlPathAllowed
        allowed.remove(charactersIn: "/")
        return addingPercentEncoding(withAllowedCharacters: allowed) ?? self
    }
}
