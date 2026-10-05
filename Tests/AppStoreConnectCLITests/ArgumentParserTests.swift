// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

import Foundation
import Testing

@testable import AppStoreConnectCLI

@Test func parserErrorsRedactSensitiveShellNames() {
  let token = "eyJ0ZXN0.eyJmaXh0dXJl.c2lnbmF0dXJl"
  let key = FileManager.default.temporaryDirectory
    .appendingPathComponent("Private Keys/AuthKey.P8").path
  for value in [token, key] {
    let arguments = ["--generate-completion-script", value]
    do {
      _ = try AppStoreConnectCommandLineMain.parseAsRoot(arguments)
      Issue.record("Expected completion parsing to request a script.")
    } catch {
      let result = AppStoreConnectCommandLineMain.renderedError(
        error, arguments: arguments, environment: [:])
      #expect(result.exitCode == 64)
      #expect(result.stdout.isEmpty)
      #expect(!result.stderr.contains(value))
      #expect(result.stderr.contains("[REDACTED]"))
      #expect(result.stderr.contains("zsh bash fish"))
    }
  }
}
