// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
// Copyright (c) 2026 Xudong Xu

#if ASC_EXPERIMENTAL
  import AppStoreConnectCore
  import AppStoreConnectWebSession
  import Darwin
  import Foundation
  import Testing

  @Test func sessionFileIsPrivateAcrossCreationAndReplacement() async throws {
    // The child process isolates umask from concurrently running tests.
    await #expect(processExitsWith: .success) {
      let directory = try storageFixtureDirectory("permissions")
      defer { try? FileManager.default.removeItem(at: directory) }
      let file = directory.appendingPathComponent("session.json")
      let store = WebSessionFileStore(fileURL: file)
      let initial = WebSession(cookies: ["session": "first"], source: .environment)
      let replacement = WebSession(cookies: ["session": "second"], source: .environment)
      for mask: mode_t in [0o000, 0o022, 0o077] {
        umask(mask)
        try store.save(initial)
        #expect(try filePermissions(file) == 0o600)
        try FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: file.path)
        try store.save(replacement)
        #expect(try filePermissions(file) == 0o600)
        #expect(try store.load()?.cookieValues == ["session": "second"])
        #expect(
          try FileManager.default.contentsOfDirectory(atPath: directory.path) == ["session.json"])
        try FileManager.default.removeItem(at: file)
      }
    }
  }

  @Test func sessionSaveReplacesSymlinkWithoutWritingItsTarget() throws {
    let directory = try storageFixtureDirectory("symlink")
    defer { try? FileManager.default.removeItem(at: directory) }
    let target = directory.appendingPathComponent("target.txt")
    try Data("unchanged".utf8).write(to: target)
    let file = directory.appendingPathComponent("session.json")
    try FileManager.default.createSymbolicLink(at: file, withDestinationURL: target)

    let store = WebSessionFileStore(fileURL: file)
    try store.save(WebSession(cookies: ["session": "fixture"], source: .environment))

    #expect(try String(contentsOf: target, encoding: .utf8) == "unchanged")
    #expect(try filePermissions(file) == 0o600)
    let attributes = try FileManager.default.attributesOfItem(atPath: file.path)
    #expect(attributes[.type] as? FileAttributeType == .typeRegular)
    #expect(try store.load()?.cookieValues == ["session": "fixture"])
  }

  @Test func sessionSaveRejectsDirectoryWritableByOthers() throws {
    let directory = try storageFixtureDirectory("directory-permissions")
    defer { try? FileManager.default.removeItem(at: directory) }
    try FileManager.default.setAttributes([.posixPermissions: 0o777], ofItemAtPath: directory.path)
    let store = WebSessionFileStore(fileURL: directory.appendingPathComponent("session.json"))
    #expect(
      throws: AppStoreConnectError.authenticationFailed(
        "Web session directory must be owned by the current user and not writable by others.")
    ) {
      try store.save(WebSession(cookies: ["session": "fixture"], source: .environment))
    }
    #expect(try FileManager.default.contentsOfDirectory(atPath: directory.path).isEmpty)
  }

  @Test func failedSessionReplacementRemovesStagingFile() throws {
    let directory = try storageFixtureDirectory("failed-replacement")
    defer { try? FileManager.default.removeItem(at: directory) }
    let file = directory.appendingPathComponent("session.json", isDirectory: true)
    try FileManager.default.createDirectory(at: file, withIntermediateDirectories: true)
    let store = WebSessionFileStore(fileURL: file)
    #expect(throws: POSIXError.self) {
      try store.save(WebSession(cookies: ["session": "fixture"], source: .environment))
    }
    #expect(try FileManager.default.contentsOfDirectory(atPath: directory.path) == ["session.json"])
  }

  private func storageFixtureDirectory(_ name: String) throws -> URL {
    let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
      .deletingLastPathComponent().deletingLastPathComponent()
    let directory = root.appendingPathComponent(".build/test-fixtures/web-session-\(name)")
    try FileManager.default.createDirectory(
      at: directory, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o755])
    return directory
  }

  private func filePermissions(_ url: URL) throws -> Int {
    let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
    return try #require(attributes[.posixPermissions] as? Int)
  }
#endif
