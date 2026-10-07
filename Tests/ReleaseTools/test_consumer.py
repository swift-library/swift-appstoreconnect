# SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
# Copyright (c) 2026 Xudong Xu
"""Failure evidence must survive the consumer process and hosted runner."""

import importlib.machinery
import importlib.util
import json
from pathlib import Path
import plistlib
import shutil
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
LOADER = importlib.machinery.SourceFileLoader('check_consumer', str(ROOT / 'Scripts/check-consumer'))
SPEC = importlib.util.spec_from_loader(LOADER.name, LOADER)
CONSUMER = importlib.util.module_from_spec(SPEC)
LOADER.exec_module(CONSUMER)


class ConsumerEvidenceTests(unittest.TestCase):
    def test_consumer_scope_records_only_executed_platforms(self):
        temporary = ROOT / '.build/release-tool-tests'
        temporary.mkdir(parents=True, exist_ok=True)
        for scope in ('all', 'swiftpm'):
            with self.subTest(scope=scope), tempfile.TemporaryDirectory(dir=temporary) as folder:
                root = Path(folder)
                script = root / 'Scripts/check-consumer'
                script.parent.mkdir()
                script.write_text('fixture checker')
                fixture = root / 'Tests/Fixtures/ReleaseConsumer'
                (fixture / 'Sources/ReleaseConsumer').mkdir(parents=True)
                (fixture / 'Package.swift').write_text(
                    '.package(url: "https://github.com/swift-library/swift-appstoreconnect.git", '
                    'revision: "release-candidate")')
                shutil.copytree(ROOT / 'Tests/Fixtures/ReleaseConsumer/ReleaseConsumer.xcodeproj',
                                fixture / 'ReleaseConsumer.xcodeproj')
                catalog = root / 'Sources/Example/Example.docc'
                catalog.mkdir(parents=True)
                (catalog / 'Example.md').write_text('```swift\nimport Foundation\nlet value = 1\n```\n')
                platforms = {'macOS': [15, 26, 27], 'iOS': [18, 26, 27], 'tvOS': [18, 26, 27],
                             'watchOS': [11, 26, 27], 'visionOS': [2, 26, 27]}
                (root / '.github').mkdir()
                (root / '.github/release.json').write_text(json.dumps({'platforms': platforms}))
                commands = []

                def run(command, **arguments):
                    commands.append(command)
                    cwd = Path(arguments['cwd'])
                    if command[:3] == ['swift', 'package', 'resolve']:
                        (cwd / 'Package.resolved').write_text(json.dumps({'pins': []}))
                    elif command[:2] == ['swift', 'build']:
                        (cwd / '.build').mkdir()
                    elif command[0] == 'xcodebuild':
                        project = Path(command[command.index('-project') + 1])
                        graph = plistlib.loads((project / 'project.pbxproj').read_bytes())
                        references = [v for v in graph['objects'].values()
                                      if v['isa'] == 'XCLocalSwiftPackageReference']
                        self.assertEqual(references[0]['relativePath'], str(root))
                        linked = {v['productName'] for v in graph['objects'].values()
                                  if v['isa'] == 'XCSwiftPackageProductDependency'}
                        self.assertEqual(linked, {'AppStoreConnectCore', 'AppStoreConnectPublicAPI',
                                                  'AppStoreConnectWorkflow', 'AppStoreConnectWebSession',
                                                  'AppStoreConnectIrisAPI'})
                        lock = project / 'project.xcworkspace/xcshareddata/swiftpm/Package.resolved'
                        self.assertEqual(lock.read_bytes(), (cwd / 'Package.resolved').read_bytes())
                        Path(command[command.index('-derivedDataPath') + 1]).mkdir()
                    arguments['stdout'].write('consumer diagnostics\n')
                    return subprocess.CompletedProcess(command, 0)

                with patch.object(CONSUMER, '__file__', str(script)), \
                     patch.object(CONSUMER.subprocess, 'run', side_effect=run):
                    CONSUMER.main(['--scope', scope])
                evidence = root / '.build/release-validation'
                receipt = json.loads((evidence / 'consumer.json').read_text())
                self.assertEqual(receipt['scope'], scope)
                self.assertEqual(receipt['snippet_count'], 1)
                self.assertEqual(set(receipt['platforms']), set(platforms) if scope == 'all' else {'macOS'})
                self.assertEqual(sum(c[:2] == ['swift', 'build'] for c in commands), 2)
                destinations = [c[c.index('-destination') + 1] for c in commands if c[0] == 'xcodebuild']
                self.assertEqual(set(destinations), {
                    'generic/platform=iOS Simulator', 'generic/platform=tvOS Simulator',
                    'generic/platform=watchOS Simulator', 'generic/platform=visionOS Simulator',
                } if scope == 'all' else set())
                for check in receipt['checks']:
                    self.assertTrue((evidence / ('consumer-' + check['name'] + '.log')).is_file())
                self.assertFalse((root / '.build/release-consumers/current').exists())

    def test_logs_are_archived_on_success_failure_and_timeout(self):
        temporary = ROOT / '.build/release-tool-tests'
        temporary.mkdir(parents=True, exist_ok=True)
        for outcome in (0, 65, 'timeout'):
            with self.subTest(outcome=outcome), tempfile.TemporaryDirectory(dir=temporary) as folder:
                output = Path(folder)
                evidence = output / 'evidence'
                checks = []

                def run(command, **arguments):
                    arguments['stdout'].write('consumer diagnostics\n')
                    if outcome == 'timeout':
                        raise subprocess.TimeoutExpired(command, 1800)
                    return subprocess.CompletedProcess(command, outcome)

                with patch.object(CONSUMER.subprocess, 'run', side_effect=run):
                    if outcome == 0:
                        CONSUMER.run_check('platform', ['fixture'], cwd=output, output=output,
                                           evidence=evidence, checks=checks)
                    else:
                        exception = subprocess.TimeoutExpired if outcome == 'timeout' else RuntimeError
                        with self.assertRaises(exception):
                            CONSUMER.run_check('platform', ['fixture'], cwd=output, output=output,
                                               evidence=evidence, checks=checks)
                self.assertEqual((evidence / 'consumer-platform.log').read_text(), 'consumer diagnostics\n')
                self.assertEqual(checks[0]['exit_status'], None if outcome == 'timeout' else outcome)


if __name__ == '__main__':
    unittest.main()
