#!/usr/bin/env python3
"""Prepare installer script versions and finalize the unreleased changelog."""

import re
import sys
from datetime import date, datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TAG_PATTERN = re.compile(r"^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(?:-([0-9A-Za-z.-]+))?$")


def prepare_release(tag, release_date=None):
    if TAG_PATTERN.fullmatch(tag) is None:
        raise ValueError("Release version must be vMAJOR.MINOR.PATCH with an optional prerelease suffix")

    release_date = release_date or datetime.now(timezone.utc).date().isoformat()
    try:
        date.fromisoformat(release_date)
    except ValueError as error:
        raise ValueError(f"Invalid release date: {release_date}") from error

    powershell = ROOT / "src/install-langflow-script.ps1"
    bash = ROOT / "src/install-langflow.sh"
    changelog = ROOT / "CHANGELOG.md"

    ps_content = powershell.read_text(encoding="utf-8-sig")
    sh_content = bash.read_text(encoding="utf-8")
    changelog_content = changelog.read_text(encoding="utf-8")

    ps_match = re.search(r'^\$ScriptVersion\s*=\s*"([0-9]+\.[0-9]+\.[0-9]+(?:-[0-9A-Za-z.-]+)?)"$', ps_content, re.MULTILINE)
    sh_match = re.search(r'^SCRIPT_VERSION="([0-9]+\.[0-9]+\.[0-9]+(?:-[0-9A-Za-z.-]+)?)"$', sh_content, re.MULTILINE)
    if ps_match is None or sh_match is None:
        raise ValueError("Could not read both installer script version pins")
    if ps_match.group(1) != sh_match.group(1):
        raise ValueError("PowerShell and bash script version pins do not match")

    heading = f"## {tag} ({release_date})"
    if re.search(rf"^## {re.escape(tag)}(?:\s|$)", changelog_content, re.MULTILINE):
        raise ValueError(f"Changelog already contains a section for {tag}")

    unreleased = re.search(r"^## Unreleased\s*\n(.*?)(?=^## |\Z)", changelog_content, re.MULTILINE | re.DOTALL)
    if unreleased is None:
        raise ValueError("CHANGELOG.md has no Unreleased section")
    entries = unreleased.group(1).strip()
    if not re.search(r"^- \w+:", entries, re.MULTILINE):
        raise ValueError("Unreleased section has no conventional-commit entries")

    new_changelog = (
        changelog_content[:unreleased.start()]
        + f"## Unreleased\n\n{heading}\n\n{entries}\n\n"
        + changelog_content[unreleased.end():].lstrip("\n")
    )
    powershell.write_text(
        ps_content[:ps_match.start(1)] + tag[1:] + ps_content[ps_match.end(1):],
        encoding="utf-8-sig",
    )
    bash.write_text(
        sh_content[:sh_match.start(1)] + tag[1:] + sh_content[sh_match.end(1):],
        encoding="utf-8",
    )
    changelog.write_text(new_changelog, encoding="utf-8")


def main():
    if len(sys.argv) != 2:
        raise SystemExit("Usage: prepare-release.py vMAJOR.MINOR.PATCH[-prerelease]")
    try:
        prepare_release(sys.argv[1])
    except ValueError as error:
        raise SystemExit(str(error)) from error


if __name__ == "__main__":
    main()
