# Release Guide

Follow the [shared release procedure](https://github.com/swift-library/.github/blob/master/VERSIONING.md#release-procedure)
and [package validation requirements](../Architecture/VersioningAndRelease.md).

Run `Scripts/check` with Xcode 26.4 or later for the complete trait and consumer
matrix. `Scripts/check --compiler-check --consumer-scope swiftpm` provides the
SwiftPM consumer scope for a standalone compiler with an older Xcode resolver.
`Scripts/check` emits documentation symbol graphs during its existing
Experimental trait test build, then converts all six catalogs and merges them
with warnings as errors. `Scripts/check-docs` also supports a standalone clean
symbol-graph build. Public CI uses offline
fixtures; live API access requires explicit caller credentials and remains opt-in.
