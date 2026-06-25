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

1. [Download the latest release](https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/latest/download/langflow-installer-win.zip) (or visit the [landing page](https://nikkisatmaka.github.io/langflow-installer-wrapper/) for a simpler experience)
2. Extract the zip anywhere
3. Double-click **`Install Langflow.bat`**

That's it. The script will:
- Install `uv` (self-bootstrapping package manager)
- Download Python 3.12
- Create a virtual environment in `%USERPROFILE%\langflow\`
- Install Langflow 1.9.6
- Create a desktop shortcut (`Langflow.lnk`)

After install, double-click the desktop shortcut. A terminal window will open, and your browser will launch automatically once the Langflow server is ready at `http://127.0.0.1:7860`.

> **Having trouble?** See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for Smart App Control and antivirus help.

## Prerequisites

None. The script works on a fresh Windows 10/11 install with no pre-installed Python or package manager.

## Usage Notes

- **Keep the terminal window open** — The Langflow server runs inside the terminal window that opens when you double-click the desktop shortcut. Closing it will stop the server and the browser page will stop working.
- **Wait and refresh** — The browser opens ~30 seconds after launching. If the page doesn't load right away, wait a few more seconds and refresh the page — Langflow is still starting up.

## Running manually

If you prefer PowerShell directly:

```powershell
powershell -ExecutionPolicy Bypass -File src\install-langflow-script.ps1
```

## Uninstall

Re-run the script and select **Uninstall**. This removes:
- `%USERPROFILE%\langflow\` (venv + Langflow)
- Desktop shortcut
- Optionally Python 3.12

`uv` is kept — it may be useful for other projects.

## Files

| File | Purpose |
|------|---------|
| `Install Langflow.bat` | Double-click launcher (bypasses execution policy) |
| `src/install-langflow-script.ps1` | Main installer/uninstaller script |
| `src/uv-install.ps1` | Bundled uv bootstrapper (from astral.sh) |
| `CONTRACT.md` | Formal requirements specification |
| `README.md` | This file |
| `docs/TROUBLESHOOTING.md` | Common issues and fixes |

## Author

**Nikki Satmaka**
- GitHub: https://github.com/NikkiSatmaka/
- LinkedIn: https://linkedin.com/in/nikkisatmaka/

## License

MIT
