// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import Foundation

/// Restores JSON key presence and nullability in the pinned generator's models.
public struct OpenAPISerializationAdapter {
  public init() {}

  public func adapt(source: String, schemaData: Data) throws -> String {
    try adapt(sources: ["source": source], schemaData: schemaData)["source", default: ""]
  }

  public func adapt(sources: [String: String], schemaData: Data) throws -> [String: String] {
    let document = try JSONSerialization.jsonObject(with: schemaData)
    var policies: [String: PropertyPolicy] = [:]
    index(document, path: "#", document: document, policies: &policies)
    var mappedPaths: Set<String> = []
    var result: [String: String] = [:]
    for name in sources.keys.sorted() {
      result[name] = try adapt(
        source: sources[name, default: ""], policies: policies, mappedPaths: &mappedPaths)
    }
    let missing = policies.filter { $0.value.nullable && !mappedPaths.contains($0.key) }.keys
      .sorted()
    guard missing.isEmpty else {
      throw failure(
        "nullable schema properties missing from generated source: "
          + missing.joined(separator: ", "))
    }
    return result
  }

  private func adapt(
    source: String, policies: [String: PropertyPolicy], mappedPaths: inout Set<String>
  ) throws -> String {
    let lines = source.components(separatedBy: "\n")
    var arrayPaths: [String: String] = [:]
    for line in lines.indices
    where lines[line].trimmingCharacters(in: .whitespaces).hasPrefix("public typealias ") {
      let declaration = lines[line].trimmingCharacters(in: .whitespaces)
      guard declaration.contains(" = ["), let path = generatedPath(before: line, lines: lines),
        let name = declaration.dropFirst("public typealias ".count).split(separator: " ").first,
        let slash = path.lastIndex(of: "/")
      else { continue }
      arrayPaths[String(path[..<slash]) + "/" + name] = path + "/[]"
    }
    func policyPath(at path: String) -> String? {
      var path = path
      for _ in 0...arrayPaths.count {
        if policies[path] != nil { return path }
        guard
          let prefix = arrayPaths.keys.sorted(by: { $0.count > $1.count }).first(where: {
            path.hasPrefix($0 + "/")
          }), let replacement = arrayPaths[prefix]
        else { return nil }
        path = replacement + path.dropFirst(prefix.count)
      }
      return nil
    }
    var edits: [Edit] = []
    for start in lines.indices {
      let declaration = lines[start].trimmingCharacters(in: .whitespaces)
      guard declaration.hasPrefix("public struct "), declaration.contains(": Codable,") else {
        continue
      }
      let indent = String(lines[start].prefix(while: { $0 == " " }))
      guard let end = ((start + 1)..<lines.count).first(where: { lines[$0] == indent + "}" }) else {
        throw failure("unterminated generated struct")
      }
      let memberIndent = indent + "    "
      var properties: [Property] = []
      for line in (start + 1)..<end where lines[line].hasPrefix(memberIndent + "public var ") {
        let declaration = String(lines[line].dropFirst(memberIndent.count + "public var ".count))
        guard !declaration.contains("{"), let separator = declaration.range(of: ": ") else {
          continue
        }
        let name = String(declaration[..<separator.lowerBound])
        let type = String(declaration[separator.upperBound...])
        let path = generatedPath(before: line, lines: lines).flatMap { policyPath(at: $0) }
        if let path { mappedPaths.insert(path) }
        properties.append(
          Property(name: name, type: type, line: line, policy: path.flatMap { policies[$0] }))
      }
      guard properties.contains(where: { $0.policy?.nullable == true }) else { continue }
      guard
        ((start + 1)..<end).contains(where: {
          lines[$0] == memberIndent + "public enum CodingKeys: String, CodingKey {"
        })
      else { throw failure("nullable object has no generated CodingKeys") }

      for property in properties where property.policy?.nullable == true {
        edits.append(
          Edit(
            range: property.line..<(property.line + 1),
            lines: [
              memberIndent + "public var \(property.name): \(property.adaptedType)"
            ]))
        let prefix = memberIndent + "    " + property.name + ": "
        let inlinePrefix = memberIndent + "public init(" + property.name + ": "
        let parameters = ((start + 1)..<end).filter {
          lines[$0].hasPrefix(prefix) || lines[$0].hasPrefix(inlinePrefix)
        }
        guard parameters.count == 1, let parameter = parameters.first else {
          throw failure("expected one memberwise initializer parameter for \(property.name)")
        }
        let inline = lines[parameter].hasPrefix(inlinePrefix)
        let suffix = inline ? ") {" : (lines[parameter].hasSuffix(",") ? "," : "")
        let defaultValue = property.policy?.required == true ? "" : " = nil"
        edits.append(
          Edit(
            range: parameter..<(parameter + 1),
            lines: [
              (inline ? inlinePrefix : prefix) + property.adaptedType + defaultValue + suffix
            ]))
      }

      for decoding in [true, false] {
        let signature =
          decoding
          ? "public init(from decoder: any Swift.Decoder) throws {"
          : "public func encode(to encoder: any Swift.Encoder) throws {"
        if let methodStart = ((start + 1)..<end).first(where: {
          lines[$0] == memberIndent + signature
        }) {
          guard
            let methodEnd = ((methodStart + 1)..<end).first(where: {
              lines[$0] == memberIndent + "}"
            })
          else { throw failure("unterminated Codable method") }
          var body = lines[(methodStart + 1)..<methodEnd].joined(separator: "\n")
          for property in properties where property.policy?.nullable == true {
            let name = NSRegularExpression.escapedPattern(for: property.name)
            let pattern =
              decoding
              ? #"self\."# + name + #" = try container\.decode(?:IfPresent)?\([\s\S]*?forKey: \."#
                + name + #"\s*\)"#
              : #"try container\.encode(?:IfPresent)?\(\s*(?:self\.)?"# + name + #",\s*forKey: \."#
                + name + #"\s*\)"#
            let expression = try NSRegularExpression(pattern: pattern)
            let matches = expression.matches(in: body, range: NSRange(body.startIndex..., in: body))
            guard matches.count == 1, let match = matches.first,
              let range = Range(match.range, in: body)
            else {
              throw failure("unexpected generated Codable statement for \(property.name)")
            }
            body.replaceSubrange(range, with: statement(property, decoding: decoding))
          }
          edits.append(
            Edit(
              range: (methodStart + 1)..<methodEnd,
              lines: body.components(separatedBy: "\n")))
        } else {
          guard properties.allSatisfy({ $0.policy != nil }) else {
            throw failure(
              "cannot synthesize Codable in \(declaration): unmapped \(properties.filter { $0.policy == nil }.map(\.name))"
            )
          }
          let container =
            decoding
            ? "let container = try decoder.container(keyedBy: CodingKeys.self)"
            : "var container = encoder.container(keyedBy: CodingKeys.self)"
          var method = [memberIndent + signature, memberIndent + "    " + container]
          for property in properties {
            method.append(memberIndent + "    " + statement(property, decoding: decoding))
          }
          method.append(memberIndent + "}")
          edits.append(Edit(range: end..<end, lines: method))
        }
      }
    }
    var result = lines
    // Apply edits from the end so all locations refer to the original source.
    for edit in edits.sorted(by: { $0.range.lowerBound > $1.range.lowerBound }) {
      result.replaceSubrange(edit.range, with: edit.lines)
    }
    return result.joined(separator: "\n")
  }

  private func generatedPath(before line: Int, lines: [String]) -> String? {
    let prefix = "/// - Remark: Generated from `"
    for index in (0..<line).reversed() {
      let text = lines[index].trimmingCharacters(in: .whitespaces)
      if text.hasPrefix(prefix), text.hasSuffix("`.") {
        return String(text.dropFirst(prefix.count).dropLast(2))
      }
      if !text.hasPrefix("///") && !text.hasPrefix("@available(") { return nil }
    }
    return nil
  }

  private func statement(_ property: Property, decoding: Bool) -> String {
    let name = property.name
    let key = ".\(name)"
    if property.policy?.nullable == true {
      if property.policy?.required == true {
        return decoding
          ? "self.\(name) = try container.decode(\(property.valueType)?.self, forKey: \(key))"
          : "try container.encode(self.\(name), forKey: \(key))"
      }
      return decoding
        ? "self.\(name) = container.contains(\(key)) ? .some(try container.decode(\(property.valueType)?.self, forKey: \(key))) : nil"
        : "if let value = self.\(name) { try container.encode(value, forKey: \(key)) }"
    }
    let optional = property.type.hasSuffix("?")
    if decoding {
      let type = optional ? String(property.type.dropLast()) : property.type
      return
        "self.\(name) = try container.decode\(optional ? "IfPresent" : "")(\(type).self, forKey: \(key))"
    }
    return "try container.encode\(optional ? "IfPresent" : "")(self.\(name), forKey: \(key))"
  }

  private func index(
    _ value: Any, path: String, document: Any,
    policies: inout [String: PropertyPolicy]
  ) {
    guard let object = value as? [String: Any] else { return }
    let required = Set(object["required"] as? [String] ?? [])
    for (key, child) in object {
      if key == "properties", let properties = child as? [String: Any] {
        for (name, schema) in properties {
          let propertyPath = path + "/" + name
          policies[propertyPath] = PropertyPolicy(
            required: required.contains(name),
            nullable: isNullable(schema, document: document, seen: []))
          index(schema, path: propertyPath, document: document, policies: &policies)
        }
      } else if ["anyOf", "oneOf", "allOf"].contains(key), let branches = child as? [Any] {
        for (offset, branch) in branches.enumerated() {
          index(branch, path: path + "/value\(offset + 1)", document: document, policies: &policies)
        }
      } else {
        let component = key == "items" ? "[]" : key
        index(child, path: path + "/" + component, document: document, policies: &policies)
      }
    }
  }

  private func isNullable(_ value: Any, document: Any, seen: Set<String>) -> Bool {
    guard let schema = value as? [String: Any] else { return false }
    if schema["nullable"] as? Bool == true { return true }
    guard let reference = schema["$ref"] as? String, reference.hasPrefix("#/"),
      !seen.contains(reference)
    else { return false }
    var target: Any? = document
    for part in reference.dropFirst(2).split(separator: "/") {
      let key = part.replacingOccurrences(of: "~1", with: "/").replacingOccurrences(
        of: "~0", with: "~")
      target = (target as? [String: Any])?[key]
    }
    guard let target else { return false }
    return isNullable(target, document: document, seen: seen.union([reference]))
  }

  private func failure(_ message: String) -> GeneratorCommandError {
    .validationFailed("serialization adapter: " + message)
  }

  private struct PropertyPolicy {
    var required: Bool
    var nullable: Bool
  }

  private struct Property {
    var name: String
    var type: String
    var line: Int
    var policy: PropertyPolicy?
    var valueType: String { type.hasSuffix("?") ? String(type.dropLast()) : type }
    var adaptedType: String { valueType + (policy?.required == true ? "?" : "??") }
  }

  private struct Edit {
    var range: Range<Int>
    var lines: [String]
  }
}
