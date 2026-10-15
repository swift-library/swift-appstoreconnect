# SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
# Copyright (c) 2026 Xudong Xu
"""Documentation reuses compiler output while preserving every conversion."""

import importlib.machinery
import importlib.util
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
LOADER = importlib.machinery.SourceFileLoader('check_docs', str(ROOT / 'Scripts/check-docs'))
SPEC = importlib.util.spec_from_loader(LOADER.name, LOADER)
DOCS = importlib.util.module_from_spec(SPEC)
LOADER.exec_module(DOCS)


class DocumentationTests(unittest.TestCase):
    def test_trait_validation_keeps_every_test_and_emits_graphs_once(self):
        source = (ROOT / 'Scripts/check').read_text()
        block = next(block for block in re.findall(r"python3 - <<'PY'\n(.*?)\nPY", source, re.S)
                     if "config['trait_configurations']" in block)
        parent = ROOT / '.build/release-tool-tests'
        parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=parent) as folder:
            root = Path(folder).resolve()
            (root / '.github').mkdir()
            (root / '.build/release-validation').mkdir(parents=True)
            config = json.loads((ROOT / '.github/release.json').read_text())
            (root / '.github/release.json').write_text(json.dumps(config))
            commands = []
            def run(command, **arguments):
                commands.append(command)
                Path(command[command.index('--scratch-path') + 1]).mkdir(parents=True)
                arguments['stdout'].write('Test run with 8 tests passed\n')
                return subprocess.CompletedProcess(command, 0)
            previous = Path.cwd()
            try:
                os.chdir(root)
                with patch.object(subprocess, 'run', side_effect=run):
                    exec(compile(block, 'trait-validation', 'exec'), {})
            finally:
                os.chdir(previous)
            self.assertEqual(len(commands), len(config['trait_configurations']))
            self.assertTrue(all(command[:2] == ['swift', 'test'] for command in commands))
            emitting = [command for command in commands if '-emit-symbol-graph' in command]
            self.assertEqual(len(emitting), 1)
            self.assertEqual(emitting[0][emitting[0].index('--traits') + 1], 'Experimental,default')
            receipt = json.loads((root / '.build/release-validation/traits.json').read_text())
            self.assertEqual([entry['name'] for entry in receipt], [entry['name'] for entry in config['trait_configurations']])
            self.assertTrue(all(entry['test_count'] == 8 for entry in receipt))
            self.assertFalse(any((root / '.build/release-traits').iterdir()))

    def fixture(self, root):
        script = root / 'Scripts/check-docs'
        script.parent.mkdir()
        script.write_text('fixture checker')
        graphs = root / '.build/release-symbol-graphs'
        graphs.mkdir(parents=True)
        for module in DOCS.MODULES:
            (graphs / (module + '.symbols.json')).write_text(json.dumps({'symbols': [
                {'identifier': {'precise': module}, 'location': {'uri': (root / '.build/generated.swift').as_uri()}}]}))
        return script, graphs

    def test_existing_trait_graphs_still_convert_all_modules_and_merge(self):
        parent = ROOT / '.build/release-tool-tests'
        parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=parent) as folder:
            root = Path(folder).resolve()
            script, graphs = self.fixture(root)
            commands = []
            def run(command, **arguments):
                commands.append(command)
                self.assertEqual(command[:2], ['xcrun', 'docc'])
                Path(command[command.index('--output-path') + 1]).mkdir(parents=True)
                return subprocess.CompletedProcess(command, 0)
            with patch.object(DOCS, '__file__', str(script)), patch.object(DOCS.subprocess, 'run', side_effect=run):
                DOCS.main(['--symbol-graphs', str(graphs)])
            conversions = [command for command in commands if command[2] == 'convert']
            self.assertEqual(len(conversions), 6)
            self.assertTrue(all('--warnings-as-errors' in command for command in conversions))
            self.assertEqual([Path(command[3]).parent.name for command in conversions], DOCS.MODULES)
            merge = next(command for command in commands if command[2] == 'merge')
            self.assertEqual(sum(str(argument).endswith('.doccarchive') for argument in merge), 7)
            receipt = json.loads((root / '.build/release-validation/documentation.json').read_text())
            self.assertEqual(receipt['modules'], DOCS.MODULES)
            self.assertEqual(receipt['symbol_graph_source'], 'trait-validation')
            self.assertEqual(len(receipt['symbol_graphs']), 6)
            self.assertTrue((root / '.build/release-validation' / receipt['archive']).is_file())
            self.assertTrue(graphs.is_dir())

    def test_missing_graph_fails_before_conversion(self):
        parent = ROOT / '.build/release-tool-tests'
        parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=parent) as folder:
            root = Path(folder).resolve()
            script, graphs = self.fixture(root)
            (graphs / (DOCS.MODULES[-1] + '.symbols.json')).unlink()
            with patch.object(DOCS, '__file__', str(script)), patch.object(DOCS.subprocess, 'run') as run:
                with self.assertRaisesRegex(RuntimeError, DOCS.MODULES[-1]):
                    DOCS.main(['--symbol-graphs', str(graphs)])
                run.assert_not_called()


if __name__ == '__main__':
    unittest.main()
