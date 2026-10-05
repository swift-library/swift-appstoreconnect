// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import Foundation

public struct GeneratedSourceFile: Equatable, Sendable {
  public var relativePath: String
  public var contents: String

  public init(relativePath: String, contents: String) {
    self.relativePath = relativePath
    self.contents = contents
  }
}

public struct GeneratedPublicAPIEmitter: Sendable {
  public init() {}

  public func generatedFiles(schemaURL: URL, audit: SchemaAudit) throws -> [GeneratedSourceFile] {
    let root = try loadRoot(schemaURL: schemaURL)
    let rootComponents = (root["components"] as? [String: Any]) ?? [:]
    let components = (rootComponents["schemas"] as? [String: Any]) ?? [:]
    let paths = (root["paths"] as? [String: Any]) ?? [:]
    let schemaDefinitions = schemaDefinitions(from: components)
    let operations = operationDefinitions(from: paths, components: rootComponents)

    return [
      GeneratedSourceFile(
        relativePath: "AppStoreConnectPublicAPI+Generated.swift",
        contents: supportSource(from: audit, schemas: schemaDefinitions, operations: operations)
      ),
      GeneratedSourceFile(
        relativePath: "Models/AppStoreConnectPublicAPI+Models.swift",
        contents: modelsSource(from: schemaDefinitions)
      ),
      GeneratedSourceFile(
        relativePath: "Operations/AppStoreConnectPublicAPI+Operations.swift",
        contents: operationsSource(from: operations)
      ),
    ]
  }

  public func writeGeneratedPublicAPI(
    schemaURL: URL,
    audit: SchemaAudit,
    outputDirectory: URL
  ) throws -> [URL] {
    let files = try generatedFiles(schemaURL: schemaURL, audit: audit)
    var outputURLs: [URL] = []

    for file in files {
      let outputURL = outputDirectory.appending(path: file.relativePath)
      try FileManager.default.createDirectory(
        at: outputURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
      )
      try file.contents.write(to: outputURL, atomically: true, encoding: .utf8)
      outputURLs.append(outputURL)
    }

    return outputURLs
  }

  public func outputPlan(schemaURL: URL, audit: SchemaAudit) throws -> [GeneratedOutput] {
    let root = try loadRoot(schemaURL: schemaURL)
    let rootComponents = (root["components"] as? [String: Any]) ?? [:]
    let components = (rootComponents["schemas"] as? [String: Any]) ?? [:]
    let paths = (root["paths"] as? [String: Any]) ?? [:]
    let schemas = schemaDefinitions(from: components)
    let operations = operationDefinitions(from: paths, components: rootComponents)
    let schemaCounts = schemaOutputCounts(schemas)

    return [
      GeneratedOutput(
        relativePath: "AppStoreConnectPublicAPI+Generated.swift",
        bucket: "support",
        constructSummary: "schema identity, inventory constants, and JSON fallback value"
      ),
      GeneratedOutput(
        relativePath: "Models/AppStoreConnectPublicAPI+Models.swift",
        bucket: "model",
        constructSummary:
          "\(schemaCounts.objectCount) object structs, \(schemaCounts.enumCount) string enums, \(schemaCounts.dictionaryCount) dictionary aliases, \(schemaCounts.scalarCount) scalar aliases"
      ),
      GeneratedOutput(
        relativePath: "Operations/AppStoreConnectPublicAPI+Operations.swift",
        bucket: "operation",
        constructSummary: "\(operations.count) operation IDs, descriptors, and raw request builders"
      ),
    ]
  }
}

extension GeneratedPublicAPIEmitter {
  fileprivate func loadRoot(schemaURL: URL) throws -> [String: Any] {
    let data = try Data(contentsOf: schemaURL)
    let object = try JSONSerialization.jsonObject(with: data)

    guard let root = object as? [String: Any] else {
      throw OpenAPISchemaAnalyzerError.invalidTopLevelJSON
    }

    return root
  }

  fileprivate func schemaDefinitions(from components: [String: Any]) -> [SchemaDefinition] {
    components.compactMap { name, value in
      guard let schema = value as? [String: Any] else {
        return nil
      }

      return SchemaDefinition(name: name, schema: schema)
    }
    .sorted { $0.name < $1.name }
  }

  fileprivate func operationDefinitions(from paths: [String: Any], components: [String: Any])
    -> [OperationDefinition]
  {
    let methodNames = Set(["get", "put", "post", "delete", "options", "head", "patch", "trace"])
    let componentParameters = (components["parameters"] as? [String: Any]) ?? [:]

    return paths.flatMap { path, value -> [OperationDefinition] in
      guard let pathItem = value as? [String: Any] else {
        return []
      }

      return pathItem.compactMap { method, operationValue -> OperationDefinition? in
        guard
          methodNames.contains(method),
          let operation = operationValue as? [String: Any],
          let operationID = operation["operationId"] as? String
        else {
          return nil
        }

        let pathItemParameters = (pathItem["parameters"] as? [[String: Any]]) ?? []
        let operationParameters = (operation["parameters"] as? [[String: Any]]) ?? []
        let parameters = (pathItemParameters + operationParameters).map {
          resolvedParameter($0, componentParameters: componentParameters)
        }
        let pathParameters =
          parameters
          .filter { $0["in"] as? String == "path" }
          .compactMap { $0["name"] as? String }
          + pathParameterNames(fromTemplate: path)
        let uniquePathParameters = Array(Set(pathParameters)).sorted()
        let queryParameters =
          parameters
          .filter { $0["in"] as? String == "query" }
          .compactMap { $0["name"] as? String }
          .sorted()

        return OperationDefinition(
          operationID: operationID,
          method: method.uppercased(),
          path: path,
          tags: ((operation["tags"] as? [String]) ?? []).sorted(),
          pathParameters: uniquePathParameters,
          queryParameters: queryParameters,
          requestBodyContentTypes: requestBodyContentTypes(from: operation["requestBody"]),
          responseContentTypes: responseContentTypes(from: operation["responses"]),
          successResponseSchema: successResponseSchema(from: operation["responses"])
        )
      }
    }
    .sorted { lhs, rhs in
      if lhs.path == rhs.path {
        return lhs.method < rhs.method
      }
      return lhs.path < rhs.path
    }
  }

  fileprivate func resolvedParameter(
    _ parameter: [String: Any],
    componentParameters: [String: Any]
  ) -> [String: Any] {
    guard
      let reference = parameter["$ref"] as? String,
      reference.hasPrefix("#/components/parameters/")
    else {
      return parameter
    }

    let name = reference.replacingOccurrences(of: "#/components/parameters/", with: "")
    return (componentParameters[name] as? [String: Any]) ?? parameter
  }

  fileprivate func pathParameterNames(fromTemplate path: String) -> [String] {
    var names: [String] = []
    var searchStart = path.startIndex

    while let open = path[searchStart...].firstIndex(of: "{"),
      let close = path[open...].firstIndex(of: "}")
    {
      let nameStart = path.index(after: open)
      if nameStart < close {
        names.append(String(path[nameStart..<close]))
      }
      searchStart = path.index(after: close)
    }

    return names
  }

  fileprivate func requestBodyContentTypes(from value: Any?) -> [String] {
    guard
      let requestBody = value as? [String: Any],
      let content = requestBody["content"] as? [String: Any]
    else {
      return []
    }

    return content.keys.sorted()
  }

  fileprivate func responseContentTypes(from value: Any?) -> [String] {
    guard let responses = value as? [String: Any] else {
      return []
    }

    return responses.values.flatMap { response -> [String] in
      guard
        let response = response as? [String: Any],
        let content = response["content"] as? [String: Any]
      else {
        return []
      }

      return Array(content.keys)
    }
    .sorted()
  }

  fileprivate func successResponseSchema(from value: Any?) -> String? {
    guard let responses = value as? [String: Any] else {
      return nil
    }

    for status in responses.keys.sorted() where status.hasPrefix("2") {
      guard
        let response = responses[status] as? [String: Any],
        let content = response["content"] as? [String: Any]
      else {
        continue
      }

      let schema =
        ((content["application/json"] as? [String: Any])?["schema"] as? [String: Any])
        ?? ((content.values.first as? [String: Any])?["schema"] as? [String: Any])

      if let reference = schema?["$ref"] as? String {
        return reference.replacingOccurrences(of: "#/components/schemas/", with: "")
      }
    }

    return nil
  }

  fileprivate func schemaOutputCounts(_ schemas: [SchemaDefinition]) -> SchemaOutputCounts {
    schemas.reduce(into: SchemaOutputCounts()) { counts, schema in
      if schema.isStringEnum {
        counts.enumCount += 1
      } else if schema.isDictionaryAlias {
        counts.dictionaryCount += 1
      } else if schema.isScalarAlias {
        counts.scalarCount += 1
      } else {
        counts.objectCount += 1
      }
    }
  }
}

extension GeneratedPublicAPIEmitter {
  fileprivate func supportSource(
    from audit: SchemaAudit,
    schemas: [SchemaDefinition],
    operations: [OperationDefinition]
  ) -> String {
    let counts = schemaOutputCounts(schemas)

    return """
      // Generated by AppStoreConnectPublicAPIGen. Do not edit directly.

      public enum AppStoreConnectPublicAPIGenerated {
          public static let schemaTitle = "\(escaped(audit.schema.title))"
          public static let schemaVersion = "\(escaped(audit.schema.version))"
          public static let openAPIVersion = "\(escaped(audit.schema.openapi))"
          public static let pathCount = \(audit.inventory.pathCount)
          public static let operationCount = \(audit.inventory.operationCount)
          public static let schemaCount = \(audit.inventory.schemaCount)
          public static let generatedObjectSchemaCount = \(counts.objectCount)
          public static let generatedEnumSchemaCount = \(counts.enumCount)
          public static let generatedDictionarySchemaCount = \(counts.dictionaryCount)
          public static let generatedScalarSchemaCount = \(counts.scalarCount)
          public static let generatedOperationCount = \(operations.count)
          public static let uploadRelatedOperationCount = \(audit.inventory.uploadRelatedOperationCount)
          public static let explicitlyMappedOneOfConstructCount = \(audit.inventory.constructCounts.oneOf)
      }

      public indirect enum AppStoreConnectJSONValue: Codable, Sendable, Equatable {
          case null
          case bool(Bool)
          case number(Double)
          case string(String)
          case array([AppStoreConnectJSONValue])
          case object([String: AppStoreConnectJSONValue])

          public init(from decoder: Decoder) throws {
              let container = try decoder.singleValueContainer()

              if container.decodeNil() {
                  self = .null
              } else if let value = try? container.decode(Bool.self) {
                  self = .bool(value)
              } else if let value = try? container.decode(Double.self) {
                  self = .number(value)
              } else if let value = try? container.decode(String.self) {
                  self = .string(value)
              } else if let value = try? container.decode([AppStoreConnectJSONValue].self) {
                  self = .array(value)
              } else {
                  self = .object(try container.decode([String: AppStoreConnectJSONValue].self))
              }
          }

          public func encode(to encoder: Encoder) throws {
              var container = encoder.singleValueContainer()

              switch self {
              case .null:
                  try container.encodeNil()
              case let .bool(value):
                  try container.encode(value)
              case let .number(value):
                  try container.encode(value)
              case let .string(value):
                  try container.encode(value)
              case let .array(value):
                  try container.encode(value)
              case let .object(value):
                  try container.encode(value)
              }
          }
      }

      """
  }

  fileprivate func modelsSource(from schemas: [SchemaDefinition]) -> String {
    var source = """
      // Generated by AppStoreConnectPublicAPIGen. Do not edit directly.

      import Foundation

      """

    for schema in schemas {
      source += modelSource(for: schema)
      source += "\n"
    }

    return source
  }

  fileprivate func modelSource(for schema: SchemaDefinition) -> String {
    if schema.isStringEnum {
      return enumSource(for: schema)
    }

    if schema.isDictionaryAlias {
      let valueType = swiftType(for: schema.additionalPropertiesSchema ?? [:])
      return "public typealias \(schema.name) = [String: \(valueType)]\n"
    }

    if schema.isScalarAlias {
      return "public typealias \(schema.name) = \(swiftType(for: schema.schema))\n"
    }

    let rawProperties = (schema.schema["properties"] as? [String: Any]) ?? [:]
    let required = Set((schema.schema["required"] as? [String]) ?? [])
    let properties = makeProperties(rawProperties: rawProperties, required: required)

    var source = "public struct \(schema.name): Codable, Sendable, Equatable {\n"

    if properties.isEmpty {
      source += "    public init() {}\n"
      source += "}\n"
      return source
    }

    for property in properties {
      source += "    public var \(property.swiftName): \(property.typeName)\n"
    }

    source += "\n"
    source += "    public init(\n"
    source += properties.map { property in
      let defaultValue = property.isOptional ? " = nil" : ""
      return "        \(property.swiftName): \(property.typeName)\(defaultValue)"
    }
    .joined(separator: ",\n")
    source += "\n    ) {\n"

    for property in properties {
      source += "        self.\(property.swiftName) = \(property.swiftName)\n"
    }

    source += "    }\n"

    if properties.contains(where: { $0.swiftName != $0.codingName }) {
      source += "\n"
      source += "    public enum CodingKeys: String, CodingKey {\n"
      for property in properties {
        source += "        case \(property.swiftName) = \"\(escaped(property.codingName))\"\n"
      }
      source += "    }\n"
    }

    source += "}\n"
    return source
  }

  fileprivate func enumSource(for schema: SchemaDefinition) -> String {
    let values = (schema.schema["enum"] as? [String]) ?? []
    var usedCases: Set<String> = []
    var source = "public enum \(schema.name): String, Codable, Sendable, CaseIterable {\n"

    for (index, value) in values.enumerated() {
      var caseName = enumCaseName(for: value)
      if caseName.isEmpty || usedCases.contains(caseName) {
        caseName = "value\(index)"
      }
      usedCases.insert(caseName)
      source += "    case \(caseName) = \"\(escaped(value))\"\n"
    }

    source += "}\n"
    return source
  }

  fileprivate func operationsSource(from operations: [OperationDefinition]) -> String {
    var usedCases: Set<String> = []
    let operationCases = operations.enumerated().map { index, operation -> OperationCase in
      var name = lowerCamelIdentifier(from: operation.operationID)
      if name.isEmpty || usedCases.contains(name) {
        name = "operation\(index)"
      }
      usedCases.insert(name)
      return OperationCase(name: name, operation: operation)
    }

    var source = """
      // Generated by AppStoreConnectPublicAPIGen. Do not edit directly.

      import AppStoreConnectCore
      import Foundation

      public enum AppStoreConnectPublicAPIGeneratedRequestError: Error, Sendable, Equatable {
          case missingPathParameter(String)
      }

      public struct AppStoreConnectPublicAPIOperationDescriptor: Sendable, Equatable {
          public var operationID: AppStoreConnectPublicAPIOperationID
          public var method: AppStoreConnectHTTPMethod
          public var pathTemplate: String
          public var tags: [String]
          public var pathParameters: [String]
          public var queryParameters: [String]
          public var requestBodyContentTypes: [String]
          public var responseContentTypes: [String]
          public var successResponseSchema: String?

          public init(
              operationID: AppStoreConnectPublicAPIOperationID,
              method: AppStoreConnectHTTPMethod,
              pathTemplate: String,
              tags: [String] = [],
              pathParameters: [String] = [],
              queryParameters: [String] = [],
              requestBodyContentTypes: [String] = [],
              responseContentTypes: [String] = [],
              successResponseSchema: String? = nil
          ) {
              self.operationID = operationID
              self.method = method
              self.pathTemplate = pathTemplate
              self.tags = tags
              self.pathParameters = pathParameters
              self.queryParameters = queryParameters
              self.requestBodyContentTypes = requestBodyContentTypes
              self.responseContentTypes = responseContentTypes
              self.successResponseSchema = successResponseSchema
          }

          public func makeRequest(
              pathParameters values: [String: String] = [:],
              queryItems: [AppStoreConnectQueryItem] = [],
              headers: [String: String] = [:],
              body: Data? = nil
          ) throws -> AppStoreConnectRequest {
              var path = pathTemplate

              for name in pathParameters {
                  guard let value = values[name] else {
                      throw AppStoreConnectPublicAPIGeneratedRequestError.missingPathParameter(name)
                  }

                  let escapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? value
                  path = path.replacingOccurrences(of: "{\\(name)}", with: escapedValue)
              }

              return AppStoreConnectRequest(
                  method: method,
                  path: path,
                  queryItems: queryItems,
                  headers: headers,
                  body: body
              )
          }
      }

      public enum AppStoreConnectPublicAPIOperationID: String, CaseIterable, Sendable {

      """

    for operationCase in operationCases {
      source +=
        "    case \(operationCase.name) = \"\(escaped(operationCase.operation.operationID))\"\n"
    }

    source += """
      }

      public extension AppStoreConnectPublicAPIOperationID {
          var descriptor: AppStoreConnectPublicAPIOperationDescriptor {
              Self.descriptor(for: self)
          }

          static var allDescriptors: [AppStoreConnectPublicAPIOperationDescriptor] {
              allCases.map(\\.descriptor)
          }

          static func descriptor(for operationID: AppStoreConnectPublicAPIOperationID) -> AppStoreConnectPublicAPIOperationDescriptor {
              switch operationID {

      """

    for operationCase in operationCases {
      source += operationDescriptorCaseSource(operationCase)
    }

    source += """
              }
          }
      }

      """

    return source
  }

  fileprivate func operationDescriptorCaseSource(_ operationCase: OperationCase) -> String {
    let operation = operationCase.operation
    let methodCase = operation.method.lowercased()

    return """
              case .\(operationCase.name):
                  AppStoreConnectPublicAPIOperationDescriptor(
                      operationID: .\(operationCase.name),
                      method: .\(methodCase),
                      pathTemplate: "\(escaped(operation.path))",
                      tags: \(stringArrayLiteral(operation.tags)),
                      pathParameters: \(stringArrayLiteral(operation.pathParameters)),
                      queryParameters: \(stringArrayLiteral(operation.queryParameters)),
                      requestBodyContentTypes: \(stringArrayLiteral(operation.requestBodyContentTypes)),
                      responseContentTypes: \(stringArrayLiteral(operation.responseContentTypes)),
                      successResponseSchema: \(optionalStringLiteral(operation.successResponseSchema))
                  )

      """
  }
}

extension GeneratedPublicAPIEmitter {
  fileprivate func makeProperties(rawProperties: [String: Any], required: Set<String>)
    -> [GeneratedProperty]
  {
    var usedNames: Set<String> = []

    return rawProperties.keys.sorted().compactMap { codingName -> GeneratedProperty? in
      guard let schema = rawProperties[codingName] as? [String: Any] else {
        return nil
      }

      var swiftName = propertyName(for: codingName)
      if usedNames.contains(swiftName) {
        var index = 2
        while usedNames.contains("\(swiftName)\(index)") {
          index += 1
        }
        swiftName = "\(swiftName)\(index)"
      }
      usedNames.insert(swiftName)

      let isNullable = schema["nullable"] as? Bool == true
      let isRequired = required.contains(codingName) && !isNullable
      let baseType = swiftType(for: schema)
      let typeName = isRequired ? baseType : "\(baseType)?"

      return GeneratedProperty(
        codingName: codingName,
        swiftName: swiftName,
        typeName: typeName,
        isOptional: !isRequired
      )
    }
  }

  fileprivate func swiftType(for schema: [String: Any]) -> String {
    if let reference = schema["$ref"] as? String {
      return reference.replacingOccurrences(of: "#/components/schemas/", with: "")
    }

    if schema["oneOf"] != nil || schema["anyOf"] != nil || schema["allOf"] != nil {
      return "AppStoreConnectJSONValue"
    }

    guard let type = schema["type"] as? String else {
      return "AppStoreConnectJSONValue"
    }

    switch type {
    case "string":
      return "String"
    case "integer":
      return "Int"
    case "number":
      return "Double"
    case "boolean":
      return "Bool"
    case "array":
      let itemSchema = (schema["items"] as? [String: Any]) ?? [:]
      return "[\(swiftType(for: itemSchema))]"
    case "object":
      if let additionalProperties = schema["additionalProperties"] as? [String: Any] {
        return "[String: \(swiftType(for: additionalProperties))]"
      }
      return "AppStoreConnectJSONValue"
    default:
      return "AppStoreConnectJSONValue"
    }
  }

  fileprivate func propertyName(for codingName: String) -> String {
    let candidate = lowerCamelIdentifier(from: codingName)
    if candidate.isEmpty {
      return "value"
    }
    if swiftKeywords.contains(candidate) {
      return "\(candidate)Value"
    }
    return candidate
  }

  fileprivate func enumCaseName(for value: String) -> String {
    let candidate = lowerCamelIdentifier(from: value)
    if candidate.isEmpty {
      return "value"
    }
    if swiftKeywords.contains(candidate) {
      return "\(candidate)Value"
    }
    return candidate
  }

  fileprivate func lowerCamelIdentifier(from value: String) -> String {
    let parts =
      value
      .split { !$0.isLetter && !$0.isNumber }
      .map(String.init)
      .filter { !$0.isEmpty }

    guard let first = parts.first else {
      return ""
    }

    let joined =
      identifierWord(first, position: .first)
      + parts.dropFirst().map {
        identifierWord($0, position: .subsequent)
      }.joined()

    guard let firstCharacter = joined.first, firstCharacter.isLetter || firstCharacter == "_" else {
      return "value\(joined)"
    }

    return joined
  }

  fileprivate func identifierWord(_ value: String, position: IdentifierWordPosition) -> String {
    if value == value.uppercased() {
      let lowered = value.lowercased()
      return position == .first
        ? lowered
        : lowered.prefix(1).uppercased() + String(lowered.dropFirst())
    }

    switch position {
    case .first:
      return value.prefix(1).lowercased() + String(value.dropFirst())
    case .subsequent:
      return value.prefix(1).uppercased() + String(value.dropFirst())
    }
  }

  fileprivate var swiftKeywords: Set<String> {
    [
      "Self", "actor", "as", "associatedtype", "async", "await", "break", "case", "catch",
      "class", "continue", "default", "defer", "deinit", "do", "else", "enum", "extension",
      "fallthrough", "false", "fileprivate", "for", "func", "guard", "if", "import", "in",
      "indirect", "init", "inout", "internal", "is", "let", "nil", "nonisolated", "open",
      "operator", "private", "protocol", "public", "repeat", "rethrows", "return", "self",
      "some", "static", "struct", "subscript", "super", "switch", "throws", "throw", "true",
      "try", "typealias", "var", "where", "while",
    ]
  }

  fileprivate func escaped(_ value: String) -> String {
    value
      .replacingOccurrences(of: "\\", with: "\\\\")
      .replacingOccurrences(of: "\"", with: "\\\"")
  }

  fileprivate func stringArrayLiteral(_ values: [String]) -> String {
    "[" + values.map { "\"\(escaped($0))\"" }.joined(separator: ", ") + "]"
  }

  fileprivate func optionalStringLiteral(_ value: String?) -> String {
    guard let value else {
      return "nil"
    }

    return "\"\(escaped(value))\""
  }
}

private struct SchemaDefinition {
  var name: String
  var schema: [String: Any]

  var isStringEnum: Bool {
    schema["type"] as? String == "string" && schema["enum"] != nil
  }

  var isDictionaryAlias: Bool {
    additionalPropertiesSchema != nil && (schema["properties"] as? [String: Any]) == nil
  }

  var isScalarAlias: Bool {
    let type = schema["type"] as? String
    return type == "string" || type == "integer" || type == "number" || type == "boolean"
  }

  var additionalPropertiesSchema: [String: Any]? {
    schema["additionalProperties"] as? [String: Any]
  }
}

private struct GeneratedProperty {
  var codingName: String
  var swiftName: String
  var typeName: String
  var isOptional: Bool
}

private struct OperationDefinition {
  var operationID: String
  var method: String
  var path: String
  var tags: [String]
  var pathParameters: [String]
  var queryParameters: [String]
  var requestBodyContentTypes: [String]
  var responseContentTypes: [String]
  var successResponseSchema: String?
}

private struct OperationCase {
  var name: String
  var operation: OperationDefinition
}

private struct SchemaOutputCounts {
  var objectCount = 0
  var enumCount = 0
  var dictionaryCount = 0
  var scalarCount = 0
}

private enum IdentifierWordPosition {
  case first
  case subsequent
}
