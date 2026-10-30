import importlib.util
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/prepare-release.py"
SPEC = importlib.util.spec_from_file_location("prepare_release", SCRIPT)
PREPARE_RELEASE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(PREPARE_RELEASE)


class PrepareReleaseTests(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary_directory.name)
        (self.root / "src").mkdir()
        (self.root / "src/install-langflow-script.ps1").write_text(
            '\ufeff$ScriptVersion    = "1.2.3"\n', encoding="utf-8"
        )
        (self.root / "src/install-langflow.sh").write_text(
            'SCRIPT_VERSION="1.2.3"\n', encoding="utf-8"
        )
        (self.root / "CHANGELOG.md").write_text(
            "# Changelog\n\n## Unreleased\n\n"
            "- fix: correct launch behavior\n\n"
            "## v1.2.3 (2026-01-01)\n\n- feat: prior feature\n",
            encoding="utf-8",
        )
        self.original_root = PREPARE_RELEASE.ROOT
        PREPARE_RELEASE.ROOT = self.root

    def tearDown(self):
        PREPARE_RELEASE.ROOT = self.original_root
        self.temporary_directory.cleanup()

    def test_updates_both_scripts_and_promotes_unreleased_entries(self):
        PREPARE_RELEASE.prepare_release("v1.2.4", "2026-03-04")

        powershell = (self.root / "src/install-langflow-script.ps1").read_text(encoding="utf-8-sig")
        bash = (self.root / "src/install-langflow.sh").read_text(encoding="utf-8")
        changelog = (self.root / "CHANGELOG.md").read_text(encoding="utf-8")
        self.assertIn('$ScriptVersion    = "1.2.4"', powershell)
        self.assertIn('SCRIPT_VERSION="1.2.4"', bash)
        self.assertIn("## v1.2.4 (2026-03-04)\n\n- fix: correct launch behavior", changelog)
        self.assertTrue(changelog.startswith("# Changelog\n\n## Unreleased\n\n## v1.2.4"))
        self.assertIn("## v1.2.3 (2026-01-01)", changelog)

    def test_rejects_existing_release_without_modifying_files(self):
        before = (self.root / "CHANGELOG.md").read_text(encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "already contains"):
            PREPARE_RELEASE.prepare_release("v1.2.3", "2026-03-04")
        self.assertEqual((self.root / "CHANGELOG.md").read_text(encoding="utf-8"), before)

    def test_rejects_mismatched_script_pins(self):
        shell = self.root / "src/install-langflow.sh"
        shell.write_text('SCRIPT_VERSION="1.2.2"\n', encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "do not match"):
            PREPARE_RELEASE.prepare_release("v1.2.4", "2026-03-04")


if __name__ == "__main__":
    unittest.main()
