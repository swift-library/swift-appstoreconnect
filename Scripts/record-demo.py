#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
"""Record the README's credential-free CLI preview."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import shlex
import subprocess

root = Path(__file__).resolve().parent.parent
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--executable", type=Path)
args = parser.parse_args()
if args.executable:
    executable = args.executable.resolve()
else:
    products = subprocess.check_output([
        "swift", "build", "--build-system", "native", "-c", "release", "--show-bin-path"
    ], cwd=root, text=True).strip()
    executable = Path(products) / "appstoreconnect"
session = root / ".build/demo-session"
session.mkdir(parents=True, exist_ok=True)
commands = []
for index, argv in enumerate([
    ["--version"],
    ["testflight", "invitations", "create", "--app", "example-app"],
]):
    result = subprocess.run([str(executable), *argv], cwd=session,
                            env={"PATH": os.environ["PATH"]}, text=True, capture_output=True)
    (session / f"stderr-{index}.txt").write_text(result.stderr)
    result.check_returncode()
    commands.append({"command": shlex.join(["appstoreconnect", *argv]),
                     "stdout": result.stdout, "exit_code": result.returncode})
assets = root / "Documentation/Assets"
(assets / "Demo-record.json").write_text(json.dumps({
    "title": "App Store Connect · preview a write", "commands": commands
}, indent=2) + "\n")
provenance = {
    "source_revision": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=root, text=True).strip(),
    "executable_sha256": hashlib.sha256(executable.read_bytes()).hexdigest(),
    "swift": subprocess.check_output(["swift", "--version"], text=True).strip(),
    "environment": "PATH only; no credentials",
    "command_exit_codes": [item["exit_code"] for item in commands],
}
(assets / "Demo-provenance.json").write_text(json.dumps(provenance, indent=2) + "\n")
print("Recorded version and TestFlight invitation preview")
