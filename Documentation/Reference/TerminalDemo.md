# Terminal demonstration

The README shows the executable version and a TestFlight invitation preview.
The recorder runs the built CLI in a temporary home with a fixed environment.
The invitation command produces a dry-run plan without credentials or a network
request. Each command must exit successfully with empty standard error.

[`.github/assets/terminal/script.yml`](../../.github/assets/terminal/script.yml)
owns the commands and expectations. Its version expectation mirrors
[`VERSION`](../../VERSION); the `cli` command in
[`.github/swift-package.json`](../../.github/swift-package.json) also compares
the built executable's version directly with that file.
[`recording.json`](../../.github/assets/terminal/recording.json) contains the
shown commands and their complete standard output.

Build and record from the repository root using the
[`github-readme-design` toolchain](https://github.com/showxu/skills/tree/master/skills/github-readme-design/scripts)
and its declared Node version:

```sh
swift build -c release --product appstoreconnect
node <toolchain>/src/cli.ts terminal record \
  --script .github/assets/terminal/script.yml \
  --executable "$(swift build -c release --show-bin-path)/appstoreconnect" \
  --out .github/assets/terminal/recording.json
```

The shared CI demo job builds the release executable and compares a fresh
recording with `recording.json`. To run that check locally:

```sh
node <toolchain>/src/cli.ts terminal check --recording-only \
  --assets .github/assets/terminal \
  --executable "$(swift build -c release --show-bin-path)/appstoreconnect"
```

The README uses `terminal-dark.svg` and `terminal-light.svg` in the same asset
directory. The toolchain renders these locally from the recording and the
organization's DESIGN and fonts.
