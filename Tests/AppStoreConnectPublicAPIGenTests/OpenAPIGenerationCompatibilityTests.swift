// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import Foundation
import Testing

@testable import AppStoreConnectPublicAPIGenCore

@Test(arguments: ["anyOf", "oneOf"])
func compositionDistributesRequiredObjectProperties(_ keyword: String) throws {
  let input: [String: Any] = [
    "type": "object",
    "required": ["kind"],
    "properties": [
      "kind": ["type": "string"],
      "payload": [
        "type": "object", "properties": ["value": ["type": "string", "nullable": true]],
      ],
    ],
    keyword: [["required": ["payload"], "properties": ["payload": ["required": ["value"]]]]],
  ]
  let result = try #require(try OpenAPICompositionNormalizer.normalize(input) as? [String: Any])
  let branches = try #require(result[keyword] as? [[String: Any]])
  #expect(result["properties"] == nil)
  #expect(branches.first?["required"] as? [String] == ["kind", "payload"])
  let properties = try #require(branches.first?["properties"] as? [String: Any])
  let payload = try #require(properties["payload"] as? [String: Any])
  #expect(payload["required"] as? [String] == ["value"])
  let nested = try #require(payload["properties"] as? [String: Any])
  #expect((nested["value"] as? [String: Any])?["nullable"] as? Bool == true)
  let repeated = try #require(try OpenAPICompositionNormalizer.normalize(result) as? [String: Any])
  #expect(NSDictionary(dictionary: result).isEqual(to: repeated))
}

@Test func conflictingCompositionFailsBeforeGeneration() {
  let input: [String: Any] = [
    "type": "object", "properties": ["field": ["type": "string"]],
    "anyOf": [["properties": ["field": ["type": "integer"]]]],
  ]
  #expect(throws: GeneratorCommandError.self) {
    try OpenAPICompositionNormalizer.normalize(input)
  }
}

@Test func serializationAdapterRejectsUnexpectedMemberwiseInitializer() throws {
  let schema = Data(
    #"{"components":{"schemas":{"Example":{"properties":{"value":{"type":"string","nullable":true}}}}}}"#
      .utf8)
  let source = """
    public struct Example: Codable, Hashable, Sendable {
        /// - Remark: Generated from `#/components/schemas/Example/value`.
        public var value: Swift.String?
        public enum CodingKeys: String, CodingKey {
            case value
        }
    }
    """
  #expect(throws: GeneratorCommandError.self) {
    try OpenAPISerializationAdapter().adapt(source: source, schemaData: schema)
  }
}
