# Langflow Installer for Windows

One-click installer for [Langflow](https://github.com/langflow-ai/langflow) **1.9.6** on Windows 10/11 — no admin rights required.

```
╔══════════════════════════════════════════════════╗
║            Langflow Installer for Windows        ║
║──────────────────────────────────────────────────║
║  GitHub:  https://github.com/NikkiSatmaka/       ║
║  LinkedIn: https://linkedin.com/in/nikkisatmaka/ ║
╚══════════════════════════════════════════════════╝
```

## Quick Start

1. [Download the latest release](https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/latest)
2. Extract the zip anywhere
3. Double-click **`install-langflow.bat`**

That's it. The script will:
- Install `uv` (self-bootstrapping package manager)
- Download Python 3.13
- Create a virtual environment in `%USERPROFILE%\langflow\`
- Install Langflow 1.9.6
- Create a desktop shortcut (`Langflow.lnk`)

After install, double-click the desktop shortcut and open `http://127.0.0.1:7860`.

## Running manually

If you prefer PowerShell directly:

```powershell
powershell -ExecutionPolicy Bypass -File install-langflow.ps1
```

## Uninstall

Re-run the script and select **Uninstall**. This removes:
- `%USERPROFILE%\langflow\` (venv + Langflow)
- Desktop shortcut
- Optionally Python 3.13

`uv` is kept — it may be useful for other projects.

## Files

| File | Purpose |
|------|---------|
| `install-langflow.ps1` | Main installer/uninstaller script |
| `install-langflow.bat` | Double-click launcher (bypasses execution policy) |
| `CONTRACT.md` | Formal requirements specification |

## Prerequisites

None. The script works on a fresh Windows 10/11 install with no pre-installed Python or package manager.

## Author

**Nikki Satmaka**
- GitHub: https://github.com/NikkiSatmaka/
- LinkedIn: https://linkedin.com/in/nikkisatmaka/

## License

MIT
