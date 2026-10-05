// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import AppStoreConnectCore
import Foundation

public enum AppStoreConnectOpenAPIPagination: Sendable {
  public static func links<Page>(from page: Page) -> AppStoreConnectPaginationLinks? {
    if let links = page as? Components.Schemas.PagedDocumentLinks {
      return links.appStoreConnectPaginationLinks
    }

    return Mirror(reflecting: page).children
      .first { $0.label == "links" }
      .flatMap { $0.value as? Components.Schemas.PagedDocumentLinks }
      .map(\.appStoreConnectPaginationLinks)
  }
}

extension Components.Schemas.PagedDocumentLinks {
  public var appStoreConnectPaginationLinks: AppStoreConnectPaginationLinks {
    AppStoreConnectPaginationLinks(
      first: first.flatMap(URL.init(string:)),
      next: next.flatMap(URL.init(string:)),
      selfURL: URL(string: _self)
    )
  }
}

extension RawPublicAPIClient {
  public func nextPage<Page: Decodable & Sendable>(
    after page: Page,
    retryPolicy: AppStoreConnectRetryPolicy = .never,
    decoder: JSONDecoder = AppStoreConnectPublicJSONCoding.makeDecoder()
  ) async throws -> Page? {
    guard let links = AppStoreConnectOpenAPIPagination.links(from: page),
      let request = AppStoreConnectPaginator().nextRequest(
        after: AppStoreConnectRequest(method: .get, path: links.selfURL?.absoluteString ?? ""),
        links: links
      )
    else {
      return nil
    }

    let response = try await send(request, retryPolicy: retryPolicy)
    guard (200...299).contains(response.statusCode) else {
      throw AppStoreConnectError.requestFailed(statusCode: response.statusCode, message: nil)
    }

    do {
      return try decoder.decode(Page.self, from: response.body)
    } catch {
      throw AppStoreConnectError.decodingFailed("Could not decode next page: \(error)")
    }
  }

  public func pages<Page: Decodable & Sendable>(
    startingWith firstPage: Page,
    retryPolicy: AppStoreConnectRetryPolicy = .never,
    decoder: JSONDecoder = AppStoreConnectPublicJSONCoding.makeDecoder()
  ) -> AppStoreConnectOpenAPIPages<Page> {
    AppStoreConnectOpenAPIPages(
      firstPage: firstPage,
      client: self,
      retryPolicy: retryPolicy,
      decoder: decoder
    )
  }
}

public struct AppStoreConnectOpenAPIPages<Page: Decodable & Sendable>: AsyncSequence,
  AsyncIteratorProtocol
{
  public typealias Element = Page

  private var currentPage: Page?
  private let client: RawPublicAPIClient
  private let retryPolicy: AppStoreConnectRetryPolicy
  private let decoder: JSONDecoder

  public init(
    firstPage: Page,
    client: RawPublicAPIClient,
    retryPolicy: AppStoreConnectRetryPolicy = .never,
    decoder: JSONDecoder = AppStoreConnectPublicJSONCoding.makeDecoder()
  ) {
    self.currentPage = firstPage
    self.client = client
    self.retryPolicy = retryPolicy
    self.decoder = decoder
  }

  public mutating func next() async throws -> Page? {
    guard let page = currentPage else {
      return nil
    }

    currentPage = try await client.nextPage(after: page, retryPolicy: retryPolicy, decoder: decoder)
    return page
  }

  public func makeAsyncIterator() -> Self {
    self
  }
}

public enum AppStoreConnectPublicJSONCoding {
  public static func makeDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
      let container = try decoder.singleValueContainer()
      let value = try container.decode(String.self)
      let dateFormatter = ISO8601DateFormatter()
      dateFormatter.formatOptions = [.withInternetDateTime]
      let fractionalDateFormatter = ISO8601DateFormatter()
      fractionalDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

      if let date = dateFormatter.date(from: value) {
        return date
      }

      if let date = fractionalDateFormatter.date(from: value) {
        return date
      }

      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Invalid App Store Connect date: \(value)"
      )
    }
    return decoder
  }
}
