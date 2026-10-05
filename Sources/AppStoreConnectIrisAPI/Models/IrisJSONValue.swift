// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

#if ASC_EXPERIMENTAL
  import Foundation

  public indirect enum IrisJSONValue: Codable, Sendable, Equatable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case array([IrisJSONValue])
    case object([String: IrisJSONValue])
    case null

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
      } else if let value = try? container.decode([IrisJSONValue].self) {
        self = .array(value)
      } else {
        self = .object(try container.decode([String: IrisJSONValue].self))
      }
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()

      switch self {
      case .string(let value):
        try container.encode(value)
      case .number(let value):
        try container.encode(value)
      case .bool(let value):
        try container.encode(value)
      case .array(let value):
        try container.encode(value)
      case .object(let value):
        try container.encode(value)
      case .null:
        try container.encodeNil()
      }
    }

    public var stringValue: String? {
      guard case .string(let value) = self else {
        return nil
      }
      return value
    }
  }

#endif
