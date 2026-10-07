# Versioning and Release

This document owns the package's version declaration, compatibility policy,
system support window and release acceptance. It adopts the
[swift-library versioning standard](https://github.com/swift-library/.github/blob/master/VERSIONING.md).
Operational commands live in the [Release Guide](../Reference/ReleaseGuide.md).

## Version Authority and Compatibility

`VERSION` owns the repository release version for its library products.
`CHANGELOG.md` owns the matching release notes. `.github/release.json` identifies
these files and owns the package's CI selection. `Scripts/validate-version`
checks them and optionally an existing `vVERSION` tag at HEAD; it leaves version
inputs unchanged.

During 0.x, fixes and compatible additions increment PATCH, and incompatible
changes increment MINOR with an explicit upgrade note. From 1.0.0, compatible
additions increment MINOR and incompatible changes increment MAJOR. Reset lower
components when increasing MINOR or MAJOR. Optional previews use alpha.N, beta.N or rc.N with
positive sequence numbers.

Compatibility includes public Swift APIs, serialized output, and compiler/platform
requirements. Documentation, formatting and CI changes alone do not force a
product release. Library consumers use next-minor bounds during 0.x.

Strict formatting uses one declared formatter toolchain. Compiler compatibility
jobs run the compiler-check scope, and the separate format-check job enforces
the complete formatting configuration. Local checks run both scopes.

## Supported Environments

The supported system window is each platform's latest three major releases.
Package.swift declares Swift tools 6.3 and uses the oldest release in that
window as its deployment floor. `.github/release.json` records the window and
owns compiler and platform validation settings. CI combines the declared
standalone Swift toolchain with the hosted SDK on macOS 15, and uses the
declared Xcode toolchain on macOS 26. Evidence records the selected compiler
and SDKs.

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

`Scripts/check` tests default traits, disabled default traits, `PublicAPIFull`
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

README owns usage and API examples. Add module documentation with the target
as its public API grows.

## Candidate and Publication

Release acceptance uses clean committed source, strict formatting, complete
Swift tests, Release builds, compiler/platform checks
and a fresh consumer. The tested lockfile is enforced for repository
builds; consumer validation also records its independently resolved dependency
graph. The OpenAPI generator executable is pinned to an exact version so
consumers produce the reviewed generated Swift source. Source ownership
and dependency notices are reviewed when dependencies
or incorporated code change.

Validation records the commit/tree, lockfile digest, toolchain, OS, SDK, checker
digest and logs beneath `.build/release-validation`. CI retains those outputs
as artifacts; publication attaches the accepted evidence archive. Revalidate
changed source, dependencies, configuration and checks on the new candidate.

After candidate acceptance, create the immutable version tag and verify a
fresh remote consumer using its SemVer requirement. The release workflow validates
the existing tag, checks its accepted commit and release notes, then publishes
from a separate contents-write job. An interrupted draft can resume when its
notes and evidence agree. Tagged source corrections use a new version.

The latest released line is maintained by default. Weekly dependency and Action
updates receive compatibility, lockfile and CI review before merging. Security
reports use the private route in SECURITY.md. Existing source history and
third-party ownership notices retain their provenance role.
