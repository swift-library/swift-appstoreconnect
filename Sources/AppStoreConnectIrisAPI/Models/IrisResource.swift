// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

#if ASC_EXPERIMENTAL
  import Foundation

  public struct IrisDocument: Codable, Sendable, Equatable {
    public var data: [IrisResource]
    public var included: [IrisResource]?
    public var links: [String: IrisJSONValue]?
    public var meta: [String: IrisJSONValue]?

    public init(
      data: [IrisResource],
      included: [IrisResource]? = nil,
      links: [String: IrisJSONValue]? = nil,
      meta: [String: IrisJSONValue]? = nil
    ) {
      self.data = data
      self.included = included
      self.links = links
      self.meta = meta
    }
  }

  public struct IrisResource: Codable, Sendable, Equatable {
    public var type: String
    public var id: String
    public var attributes: [String: IrisJSONValue]?
    public var relationships: [String: IrisJSONValue]?
    public var links: [String: IrisJSONValue]?

    public init(
      type: String,
      id: String,
      attributes: [String: IrisJSONValue]? = nil,
      relationships: [String: IrisJSONValue]? = nil,
      links: [String: IrisJSONValue]? = nil
    ) {
      self.type = type
      self.id = id
      self.attributes = attributes
      self.relationships = relationships
      self.links = links
    }
  }

  public typealias AppStoreVersionStateChangesResponse = IrisDocument

#endif
