# SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
# Copyright (c) 2026 Xudong Xu
"""Failure evidence must survive the consumer process and hosted runner."""

import importlib.machinery
import importlib.util
from pathlib import Path
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
