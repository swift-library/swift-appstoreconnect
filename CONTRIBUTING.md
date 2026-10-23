# Contributing

By submitting a contribution, you confirm your right to license it under
[the package license](LICENSE.txt).

External contributions are welcome. Use a Conventional Commit PR title and
follow `.swift-format`. Maintainers follow the shared
[signing instructions](https://github.com/swift-library/.github/blob/master/MAINTENANCE.md#signing).
Run these checks before opening a pull request:

```sh
swift build
swift test
swift build -c release
xcrun swift-format lint --strict --configuration .swift-format --recursive Package.swift Sources Tests Plugins
scripts/check-spec
scripts/check-generation
```

[`.github/swift-package.json`](.github/swift-package.json) declares the compiler
and trait matrix, platform builds, DocC targets, terminal demo, and repository
commands, including CLI version and shell completion checks. CI builds and
tests with Xcode 26.6 on macOS 26. Default traits always run; `traits` lists
only additional trait sets. Required checks are `policy / policy` and
`validate / result`.

Review the [release facts and mechanics](Documentation/Reference/Release.md)
and the [swift-library versioning standard](https://github.com/swift-library/.github/blob/master/VERSIONING.md)
when changing compatibility, requirements or release inputs.
