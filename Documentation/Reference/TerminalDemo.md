# Terminal demonstration

The README shows the executable version and a TestFlight invitation preview.
The command runs with a PATH-only environment and without `--confirm`, so it
produces a plan without credentials or a network request. The recording retains
complete standard output and successful exit codes.

Build and record from the repository root:

```sh
swift build --build-system native -c release --product appstoreconnect --force-resolved-versions
python3 Scripts/record-demo.py
```

`Documentation/Assets/Demo-record.json` owns the transcript;
`Demo-provenance.json` records the source revision, executable digest, compiler,
and environment boundary. Raw diagnostics stay in `.build/demo-session`.
The full commit in `.github/presentation.json` pins the shared renderer and
DESIGN.md. `Scripts/check-demo` fetches those public files under
`.build/presentation/shared` and checks both SVG variants. Regenerate with the
fetched renderer and the same inputs, omitting `--check`.
