import importlib.util
import io
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
SCRIPT = Path(__file__).resolve().parents[1] / "scripts/upstream-version.py"
SPEC = importlib.util.spec_from_file_location("upstream_version", SCRIPT)
UPSTREAM_VERSION = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(UPSTREAM_VERSION)


class UpdateVersionTests(unittest.TestCase):
    def test_update_version_preserves_utf8_shell_script_content(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "src").mkdir()
            (root / "src/install-langflow-script.ps1").write_text(
                '\ufeff$LangflowVersion = "1.0.0"\n', encoding="utf-8"
            )
            (root / "src/install-langflow.sh").write_text(
                'LANGFLOW_VERSION="1.0.0"\n# 🐐\n', encoding="utf-8"
            )
            (root / "src/requirements.txt").write_text(
                "langflow[bundles,postgresql]==1.0.0\n", encoding="utf-8"
            )
            original_root = UPSTREAM_VERSION.ROOT
            UPSTREAM_VERSION.ROOT = root
            real_io_open = io.open

            def windows_default_encoding(*args, **kwargs):
                if "b" not in args[1]:
                    args = list(args)
                    if len(args) > 3:
                        args[3] = args[3] if args[3] not in (None, "locale") else "cp1252"
                    else:
                        kwargs.setdefault("encoding", "cp1252")
                return real_io_open(*args, **kwargs)

            try:
                with patch("io.open", side_effect=windows_default_encoding):
                    UPSTREAM_VERSION.update_version("1.2.3")
            finally:
                UPSTREAM_VERSION.ROOT = original_root

            shell = (root / "src/install-langflow.sh").read_text(encoding="utf-8")
            self.assertEqual(shell, 'LANGFLOW_VERSION="1.2.3"\n# 🐐\n')


if __name__ == "__main__":
    unittest.main()
