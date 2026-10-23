# Release

Version rules for swift-appstoreconnect, covering tags, release timing, choosing
the next version and the changelog, are in
[VERSIONING](https://github.com/swift-library/.github/blob/master/VERSIONING.md).
This document records the repository's release facts and mechanics.

## Components and Version Sources

| Shipped component | Version source | Derived fields and checks |
| --- | --- | --- |
| swift-appstoreconnect package and CLI | [`VERSION`](../../VERSION), selected by [`.github/release.json`](../../.github/release.json) | The CLI version is generated at build time. The `cli` validation command compares `--version` with `VERSION`; [`CHANGELOG.md`](../../CHANGELOG.md) supplies release notes. |

## Compatibility Surface

Compatibility includes typed Public API requests, domain traits, credentials,
workflow plans and serialized output, CLI options, and compiler/platform
requirements. WebSession and Iris APIs require the default-off `Experimental`
trait.

## Dependencies and Validation

The package requires Swift 6.3, iOS 18, macOS 15, tvOS 18, watchOS 11 or visionOS 2.
[`.github/release.json`](../../.github/release.json) records the minimum Swift
version and maintained platform generations.
[`.github/swift-package.json`](../../.github/swift-package.json) owns validation:

- Standalone Swift 6.3.3 with Xcode 26.0.1 SDKs on macOS 15, and Xcode 26.6 on
  macOS 26, each test and build the default, disabled-default, `PublicAPIFull`,
  and `Experimental` with defaults trait configurations using SwiftPM's native
  build engine.
- Strict formatting covers `Package.swift`, `Sources`, `Tests`, and `Plugins`.
- Generic iOS, tvOS, watchOS, and visionOS builds use the
  `AppStoreConnectWorkflow` scheme, which depends on all five library modules.
- DocC builds the six target-local catalogs with warnings as errors.
- The [terminal demo](TerminalDemo.md) checks a fresh release CLI recording.
- Repository commands verify the locked specification, generated serialization,
  CLI version, help, shell completions, and a workflow dry-run.

The OpenAPI generator executable is pinned to an exact version so builds
produce the reviewed generated Swift source. Dependency and specification
notices remain with their owning inputs. Live API integration requires caller
credentials and is opt-in. Local Xcode process execution requires macOS.

## Local Checks

```sh
swift build
swift test
swift build -c release
xcrun swift-format lint --strict --configuration .swift-format --recursive Package.swift Sources Tests Plugins
scripts/check-spec
scripts/check-generation
```

The `commands` entries in `.github/swift-package.json` also provide the CLI
checks. `scripts/check-generation` compiles generated serialization regression
fixtures against the resolved runtime dependencies. `scripts/check-spec`
verifies the unmodified Apple schema and archive; the weekly drift workflow
uses its `--online` option to report updates without changing the lock.
Temporary OpenAPI check results are written under `.build/release-validation`;
the generation check removes its scratch package after success.

## Acceptance and Publication

Required checks are `policy / policy` and `validate / result`. The shared
validation workflow reads `.github/swift-package.json`; the policy workflow
also validates the release declaration.

Pushing an accepted signed annotated `vX.Y.Z` tag starts
[`Release`](../../.github/workflows/release.yml). It validates the tagged commit
before the shared release workflow verifies the tag, version declaration, and
changelog and publishes the release notes.
