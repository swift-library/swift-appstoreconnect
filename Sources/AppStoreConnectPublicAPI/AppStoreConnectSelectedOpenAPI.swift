// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import AppStoreConnectCore
import Foundation
import OpenAPIURLSession

public enum AppStoreConnectSelectedOpenAPI: Sendable {}

extension Client {
  public static func appStoreConnectURLSession(
    serverURL: URL = URL(string: "https://api.appstoreconnect.apple.com")!,
    retryPolicy: AppStoreConnectRetryPolicy = .never
  ) -> Client {
    Client(
      serverURL: serverURL,
      transport: URLSessionTransport(),
      middlewares: [
        AppStoreConnectOpenAPIErrorMiddleware(),
        AppStoreConnectOpenAPIRetryMiddleware(policy: retryPolicy),
      ]
    )
  }
}
