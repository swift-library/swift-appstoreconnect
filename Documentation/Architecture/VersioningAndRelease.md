# Versioning and Release

swift-appstoreconnect follows the [shared release standard](https://github.com/swift-library/.github/blob/master/VERSIONING.md).
`VERSION` declares the package version and generates the CLI version at build
time. `CHANGELOG.md` records release notes. `.github/release.json` owns compiler,
platform, trait and consumer-scope inputs for validation.

## Compatibility surface

Compatibility includes typed Public API requests, domain traits, credentials,
workflow plans and serialized output, CLI options, and compiler/platform requirements.
WebSession and Iris APIs require the default-off `Experimental` trait.

## Requirements and validation

The package requires Swift 6.3, iOS 18, macOS 15, tvOS 18, watchOS 11 or visionOS 2.
The maintained system window covers iOS/tvOS 18/26/27, macOS 15/26/27,
watchOS 11/26/27 and visionOS 2/26/27. CI combines standalone Swift 6.3.3 with
Xcode 26.0.1 SDKs on macOS 15 and uses Xcode 26.6 on macOS 26.
Strict formatting runs separately.

Both compiler lanes validate SwiftPM consumers. The macOS 26 lane also
validates Xcode consumers on every declared Apple platform. Xcode's package
resolver must support the manifest's Swift tools version; installing a separate
Swift compiler does not update an older Xcode's resolver. The macOS 15 lane
therefore selects the `swiftpm` consumer scope. Local `Scripts/check` defaults
to the complete consumer scope and requires Xcode 26.4 or later.

Repository tests, release builds and symbol extraction use SwiftPM's native
build engine. Consumer checks use the toolchain's default engine and Xcode.
Each trait configuration uses an independent build directory; validation retains
its logs and removes the generated products after a successful run.

`Scripts/check` first compiles generated serialization regression fixtures against
the resolved runtime dependencies, then tests default traits, disabled default traits, `PublicAPIFull`
and `Experimental` with defaults. WebSession and Iris products compile empty
when `Experimental` is disabled. Public API code generation always includes
the baseline needed by the Workflow and CLI; domain traits select additional
operations. The CLI version is generated from `VERSION` at build time.

An independent SwiftPM consumer measures its clean default-trait build. An
Xcode framework consumer links the five public library products and compiles
usage on every declared Apple platform. Its project uses the same dependency
lock as the SwiftPM consumer and the deployment floors from release.json. Live API integration
is opt-in and excluded from public CI. Local Xcode process execution requires
macOS. `Scripts/check-spec` verifies the unmodified Apple schema and archive;
the weekly drift workflow reports updates without changing the lock.

The OpenAPI generator executable is pinned to an exact version so consumers
produce the reviewed generated Swift source. Dependency and specification
notices remain with their owning inputs. Evidence belongs in
`.build/release-validation`. Module DocC catalogs are colocated with their targets.
