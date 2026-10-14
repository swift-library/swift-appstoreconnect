// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import Foundation

/// Distributes object constraints into alternatives before typed generation.
/// The generator otherwise ignores properties beside an anyOf or oneOf.
enum OpenAPICompositionNormalizer {
  static func normalize(_ value: Any) throws -> Any {
    if let array = value as? [Any] {
      return try array.map(normalize)
    }
    guard let schema = value as? [String: Any] else { return value }
    return try normalizeObject(schema)
  }

  private static func normalizeObject(_ input: [String: Any]) throws -> [String: Any] {
    var schema = input
    for key in schema.keys.sorted() {
      if let value = schema[key] { schema[key] = try normalize(value) }
    }
    for composition in ["anyOf", "oneOf"] {
      guard let branches = schema[composition] as? [[String: Any]],
        schema["properties"] != nil || schema["required"] != nil
      else { continue }
      let objectKeys = [
        "type", "properties", "required", "additionalProperties",
        "minProperties", "maxProperties",
      ]
      var constraints: [String: Any] = [:]
      for key in objectKeys {
        constraints[key] = schema.removeValue(forKey: key)
      }
      schema[composition] = try branches.map { try intersect(constraints, $0) }
    }
    return schema
  }

  private static func intersect(_ base: [String: Any], _ branch: [String: Any]) throws
    -> [String: Any]
  {
    var result = base
    for (key, value) in branch {
      guard let previous = result[key] else {
        result[key] = value
        continue
      }
      if key == "required", let left = previous as? [String], let right = value as? [String] {
        result[key] = Array(Set(left + right)).sorted()
      } else if key == "properties", let left = previous as? [String: Any],
        let right = value as? [String: Any]
      {
        var properties = left
        for (name, property) in right {
          if let inherited = left[name] as? [String: Any],
            let constraint = property as? [String: Any]
          {
            properties[name] = try intersect(inherited, constraint)
          } else {
            properties[name] = property
          }
        }
        result[key] = properties
      } else if key == "description" || key == "title" || key == "example" {
        result[key] = value
      } else if !NSDictionary(dictionary: [key: previous]).isEqual(to: [key: value]) {
        throw GeneratorCommandError.validationFailed(
          "conflicting \(key) constraints in an object composition")
      }
    }
    return try normalizeObject(result)
  }
}
