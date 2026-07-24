# Langflow Installer

One-click installer for [Langflow](https://github.com/langflow-ai/langflow) **1.10.3** on Windows, macOS, and Linux — no admin rights required.

[![GitHub](https://img.shields.io/badge/GitHub-NikkiSatmaka-181717?style=for-the-badge&logo=github)](https://github.com/NikkiSatmaka/)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-nikkisatmaka-0A66C2?style=for-the-badge&logo=linkedin)](https://linkedin.com/in/nikkisatmaka/)
[![GitHub stars](https://img.shields.io/github/stars/NikkiSatmaka/langflow-installer-wrapper?style=for-the-badge&logo=github)](https://github.com/NikkiSatmaka/langflow-installer-wrapper/stargazers)

> If you find this useful, please star the repo!

## Downloads

| Platform | Download |
|----------|----------|
| Windows 10/11 | [langflow-installer-win.zip](https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/latest/download/langflow-installer-win.zip) |
| macOS 12+ | [langflow-installer-macos.zip](https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/latest/download/langflow-installer-macos.zip) |
| Linux | [langflow-installer-linux.zip](https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/latest/download/langflow-installer-linux.zip) |

## Quick Start (Windows)

1. [Download the latest Windows release](https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/latest/download/langflow-installer-win.zip)
2. Extract the zip anywhere
3. Double-click **`Install Langflow.bat`**

The script will:
- Install `uv` (self-bootstrapping package manager)
- Download Python 3.12
- Create a virtual environment in `%USERPROFILE%\langflow\`
- Install Langflow 1.10.3
- Create desktop shortcuts (`Langflow Web.lnk` and `Stop Langflow.lnk`)

After install, double-click the **Langflow Web** desktop shortcut. A terminal window will open, and your browser will launch automatically once the server is ready at `http://127.0.0.1:7860`. To stop the server, double-click **Stop Langflow**.

> **Having trouble?** See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for Smart App Control and antivirus help.

## Quick Start (macOS)

1. [Download the macOS release](https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/latest/download/langflow-installer-macos.zip)
2. Extract the zip (double-click in Finder)
3. Double-click **`Install Langflow.command`**

> **Gatekeeper warning**: macOS will block the file the first time. Go to **System Settings > Privacy & Security**, scroll to **Security**, click **Open Anyway** next to the blocked file, then confirm. See the [detailed guide](docs/GATEKEEPER.md) for screenshots. This is one-time per file.

The script will:
- Install `uv` (self-bootstrapping package manager)
- Download Python 3.12
- Create a virtual environment in `~/langflow/`
- Install Langflow 1.10.3
- Create desktop shortcuts (`Langflow Web.command` and `Stop Langflow.command`)

After install, double-click the **Langflow Web** desktop shortcut. Terminal will open, start the server, and open your browser automatically. To stop the server, double-click **Stop Langflow**.

## Quick Start (Linux)

1. [Download the Linux release](https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/latest/download/langflow-installer-linux.zip)
2. Extract the zip
3. Open a terminal in the extracted folder and run `bash Install\ Langflow.sh`

The script will:
- Install `uv` (self-bootstrapping package manager)
- Download Python 3.12
- Create a virtual environment in `~/langflow/`
- Install Langflow 1.10.3
- Create desktop shortcuts in your app menu and on your desktop (for both starting and stopping Langflow)

After install, launch **Langflow Web** from your app menu or desktop shortcut. A terminal will open, start the server, and open your browser automatically. To stop the server, find **Stop Langflow** in your app menu or desktop.

## Running manually

**Windows:**
```powershell
powershell -ExecutionPolicy Bypass -File src\install-langflow-script.ps1
```

**macOS/Linux:**
```bash
bash src/install-langflow.sh
```

## Uninstall

Re-run the installer script and select **Uninstall**. This removes:
- The Langflow directory (venv + Langflow)
- Desktop shortcuts (start and stop)
- Optionally Python 3.12

`uv` is kept — it may be useful for other projects.

## Files

| File | Purpose |
|------|---------|
| `Install Langflow.bat` | Double-click launcher (Windows) |
| `Install Langflow.command` | Double-click launcher (macOS) |
| `Install Langflow.sh` | Launcher (Linux) |
| `Stop Langflow.bat` | Double-click stop launcher (Windows) |
| `Stop Langflow.command` | Double-click stop launcher (macOS) |
| `Stop Langflow.sh` | Stop launcher (Linux) |
| `src/install-langflow-script.ps1` | Main installer/uninstaller script (Windows) |
| `src/install-langflow.sh` | Main installer/uninstaller script (macOS/Linux) |
| `src/stop-langflow-script.ps1` | Stop script (Windows) |
| `src/stop-langflow.sh` | Stop script (macOS/Linux) |
| `src/uv-install.ps1` | Bundled uv bootstrapper (Windows) |
| `scripts/verify.sh` | Pre-commit verification checks |
| `scripts/package.sh` | Cross-platform packaging script (bash) |
| `scripts/package.ps1` | Cross-platform packaging script (PowerShell) |
| `.github/workflows/verify.yml` | CI: PR verification |
| `.github/workflows/release.yml` | CI: Automated release on tag push |
| `docs/TROUBLESHOOTING.md` | Common issues and fixes |
| `docs/GATEKEEPER.md` | macOS Gatekeeper bypass guide |
| `CONTRACT.md` | Formal requirements specification |

## Credits

- The Langflow desktop icon (`src/assets/langflow.png` and `src/assets/langflow.ico`) is from [dashboard-icons](https://github.com/homarr-labs/dashboard-icons) by homarr-labs, licensed under MIT.

## License

MIT
