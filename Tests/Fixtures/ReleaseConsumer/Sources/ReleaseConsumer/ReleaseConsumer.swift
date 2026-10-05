// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import AppStoreConnectCore
import AppStoreConnectIrisAPI
import AppStoreConnectPublicAPI
import AppStoreConnectWebSession
import AppStoreConnectWorkflow

public func inspectLibraryUsage() {
  let request = AppStoreConnectRequest(method: .get, path: "/v1/apps")
  let credential = AppStoreConnectBearerToken(token: "example-token")
  let client = AppStoreConnectPublicClient(
    client: Client.appStoreConnectURLSession(credential: credential)
  )
  let workflow = WorkflowRunner().dryRun(.publishAppStore)
  _ = (request, client.apps, workflow.steps)
}
