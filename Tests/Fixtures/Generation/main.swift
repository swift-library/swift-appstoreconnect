// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import Foundation

var checks = 0
@MainActor
func roundTrip<T: Codable>(_ type: T.Type, _ object: [String: Any]) throws {
  let input = try JSONSerialization.data(withJSONObject: object)
  let decoded = try JSONDecoder().decode(type, from: input)
  let encoded = try JSONEncoder().encode(decoded)
  let output = try JSONSerialization.jsonObject(with: encoded) as! NSDictionary
  precondition(output.isEqual(to: object), "Round trip changed \(object) to \(output)")
  checks += 1
}
@MainActor
func missingKeyFails<T: Decodable>(_ type: T.Type, _ object: [String: Any]) throws {
  do {
    _ = try JSONDecoder().decode(type, from: JSONSerialization.data(withJSONObject: object))
    preconditionFailure("Missing required key decoded successfully")
  } catch DecodingError.keyNotFound {
    checks += 1
  }
}
@MainActor
func verifyNullability<T: Codable>(_ type: T.Type, extras: [String: Any] = [:]) throws {
  let baseline: [String: Any] = ["text": "value", "choice": "alpha"]
  for key in ["text", "choice", "optionalText", "optionalChoice"] {
    for value in [key.hasSuffix("Choice") || key == "choice" ? "beta" : "another", NSNull()]
      as [Any]
    {
      var object = baseline.merging(extras) { _, new in new }
      object[key] = value
      try roundTrip(type, object)
    }
    var absent = baseline.merging(extras) { _, new in new }
    absent.removeValue(forKey: key)
    if key.hasPrefix("optional") {
      try roundTrip(type, absent)
    } else {
      try missingKeyFails(type, absent)
    }
  }
}
try verifyNullability(Components.Schemas.Nullability.self)
try verifyNullability(Components.Schemas.ClosedNullability.self)
try verifyNullability(Components.Schemas.OpenNullability.self, extras: ["extra": 7])
try verifyNullability(Components.Schemas.TypedOpenNullability.self, extras: ["extra": 7])
for value in ["value", NSNull()] as [Any] {
  try roundTrip(
    Components.Schemas.ArrayNullability.self,
    ["entries": [["text": value, "choice": NSNull(), "optionalText": NSNull()]]])
  try roundTrip(Components.Schemas.NullableTarget.self, ["value": value])
  try roundTrip(
    Components.Schemas.NullableTarget.self, ["value": value, "optionalValue": NSNull()])
  try roundTrip(
    Components.Schemas.Composed.self, ["kind": "first", "attributes": ["field": value]])
}
try roundTrip(
  Components.Schemas.NullableTarget.self, ["value": NSNull(), "optionalValue": "value"])
try missingKeyFails(Components.Schemas.NullableTarget.self, [:])
try missingKeyFails(Components.Schemas.ArrayNullability.self, ["entries": [["choice": "alpha"]]])
for value in ["alpha", NSNull()] as [Any] {
  try roundTrip(
    Components.Schemas.Composed.self, ["kind": "second", "attributes": ["choice": value]])
}
let missing = try JSONDecoder().decode(
  Components.Schemas.Nullability.self,
  from: Data(#"{"text":null,"choice":null}"#.utf8))
precondition(missing.optionalText == nil && missing.optionalChoice == nil)
let explicit = try JSONDecoder().decode(
  Components.Schemas.Nullability.self,
  from: Data(#"{"text":null,"choice":null,"optionalText":null,"optionalChoice":null}"#.utf8))
precondition(explicit.optionalText != nil && explicit.optionalText! == nil)
precondition(explicit.optionalChoice != nil && explicit.optionalChoice! == nil)
checks += 3
let appleCases =
  try JSONSerialization.jsonObject(
    with: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))) as! [[String: Any]]
for entry in appleCases {
  let object = entry["value"] as! [String: Any]
  if entry["schema"] as! String == "AppAssetLibraryPlacementOrderingRequestCreateRequest" {
    try roundTrip(
      Components.Schemas.AppAssetLibraryPlacementOrderingRequestCreateRequest.self, object)
  } else {
    try roundTrip(Components.Schemas.AppAssetLibraryPlacementCreateRequest.self, object)
  }
}
print("Generation regression checks passed: \(checks)")
try JSONSerialization.data(
  withJSONObject: ["checks": checks, "status": "passed"], options: [.sortedKeys]
)
.write(to: URL(fileURLWithPath: CommandLine.arguments[2]))
