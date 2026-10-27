#!/usr/bin/env python3
"""Select stable PyPI Langflow releases and update the installer pin."""

import json
import re
import sys
from pathlib import Path

VERSION_PATTERN = re.compile(r"^([0-9]+(?:\.[0-9]+)*)$")
ROOT = Path(__file__).resolve().parent.parent


def version_key(version):
    match = VERSION_PATTERN.fullmatch(version)
    if match is None:
        return None
    return tuple(int(part) for part in match.group(1).split("."))


def latest_stable(payload):
    releases = payload.get("releases")
    if not isinstance(releases, dict):
        raise ValueError("PyPI metadata has no releases map")

    candidates = []
    for version, files in releases.items():
        key = version_key(version)
        if key is None or not isinstance(files, list) or not files:
            continue
        if any(not file.get("yanked", False) for file in files):
            candidates.append((key, version))

    if not candidates:
        raise ValueError("PyPI metadata has no non-yanked stable releases")
    return max(candidates)[1]


def current_version():
    source = (ROOT / "src/install-langflow-script.ps1").read_text(encoding="utf-8-sig")
    match = re.search(r'^\$LangflowVersion\s*=\s*"([0-9.]+)"$', source, re.MULTILINE)
    if match is None:
        raise ValueError("Could not read the PowerShell Langflow version pin")
    return match.group(1)


def update_version(version):
    if version_key(version) is None:
        raise ValueError(f"Not a stable numeric version: {version}")

    powershell = ROOT / "src/install-langflow-script.ps1"
    content = powershell.read_text(encoding="utf-8-sig")
    content, ps_count = re.subn(
        r'(^\$LangflowVersion\s*=\s*")[0-9.]+("\s*$)',
        rf"\g<1>{version}\2",
        content,
        count=1,
        flags=re.MULTILINE,
    )
    if ps_count != 1:
        raise ValueError("Expected exactly one PowerShell Langflow version pin")

    bash = ROOT / "src/install-langflow.sh"
    shell_content = bash.read_text()
    shell_content, sh_count = re.subn(
        r'(^LANGFLOW_VERSION=")[0-9.]+("\s*$)',
        rf"\g<1>{version}\2",
        shell_content,
        count=1,
        flags=re.MULTILINE,
    )
    if sh_count != 1:
        raise ValueError("Expected exactly one bash Langflow version pin")

    requirements = ROOT / "src/requirements.txt"
    requirements_content = requirements.read_text()
    requirements_content, req_count = re.subn(
        r"^langflow\[bundles,postgresql\]==[0-9.]+$",
        f"langflow[bundles,postgresql]=={version}",
        requirements_content,
        count=1,
        flags=re.MULTILINE,
    )
    if req_count != 1:
        raise ValueError("Expected exactly one requirements Langflow version pin")
    powershell.write_text("\ufeff" + content, encoding="utf-8")
    bash.write_text(shell_content)
    requirements.write_text(requirements_content)


def update_docs(old_version, version):
    for name in ("README.md", "CONTRACT.md", "AGENTS.md", "docs/index.html"):
        path = ROOT / name
        content = path.read_text()
        if old_version not in content:
            raise ValueError(f"Expected current version {old_version} in {name}")
        path.write_text(content.replace(old_version, version))
    changelog = ROOT / "CHANGELOG.md"
    content = changelog.read_text()
    if not content.startswith("# Changelog\n\n"):
        raise ValueError("Could not add version entry to CHANGELOG.md")
    if "## Unreleased\n" not in content:
        content = content.replace(
            "# Changelog\n\n",
            "# Changelog\n\n## Unreleased\n\n",
            1,
        )
    content = content.replace(
        "## Unreleased\n\n",
        f"## Unreleased\n\n- feat: upgrade Langflow to {version} after all supported platform install checks pass\n\n",
        1,
    )
    changelog.write_text(content)


def main():
    if len(sys.argv) == 2 and sys.argv[1] == "current":
        print(current_version())
    elif len(sys.argv) == 3 and sys.argv[1] == "latest":
        print(latest_stable(json.loads(Path(sys.argv[2]).read_text())))
    elif len(sys.argv) == 3 and sys.argv[1] == "update":
        update_version(sys.argv[2])
    elif len(sys.argv) == 4 and sys.argv[1] == "update-docs":
        update_docs(sys.argv[2], sys.argv[3])
    else:
        raise SystemExit(
            "usage: upstream-version.py current | latest METADATA.json | "
            "update VERSION | update-docs OLD_VERSION VERSION"
        )


if __name__ == "__main__":
    main()
