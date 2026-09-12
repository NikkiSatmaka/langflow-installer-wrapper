# Langflow Installer

One-click installer for [Langflow](https://github.com/langflow-ai/langflow) **1.12.1** on Windows, macOS, and Linux — no admin rights required.

[![GitHub](https://img.shields.io/badge/GitHub-NikkiSatmaka-181717?style=for-the-badge&logo=github)](https://github.com/NikkiSatmaka/)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-nikkisatmaka-0A66C2?style=for-the-badge&logo=linkedin)](https://linkedin.com/in/nikkisatmaka/)
[![GitHub stars](https://img.shields.io/github/stars/NikkiSatmaka/langflow-installer-wrapper?style=for-the-badge&logo=github)](https://github.com/NikkiSatmaka/langflow-installer-wrapper/stargazers)

> If you find this useful, please star the repo!

## Downloads

| Platform | Download |
|----------|----------|
| Windows 10/11 | [langflow-installer-win.zip](https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/latest/download/langflow-installer-win.zip) |
| macOS 12+ (Apple Silicon only) | [langflow-installer-macos.zip](https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/latest/download/langflow-installer-macos.zip) |
| Linux | [langflow-installer-linux.zip](https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/latest/download/langflow-installer-linux.zip) |

## System Requirements

| Platform | OS | Chip | Hardware |
|----------|----|------|----------|
| Windows | Windows 10 or 11 (2016 or newer, requires Windows PowerShell 5.1) | Any 64-bit x86 CPU | 2+ CPU cores, 2 GB RAM minimum (4 GB+ recommended) |
| macOS | macOS 12+ (Monterey or later) | Apple Silicon (M1 or newer) only — Intel Macs are not supported | 2+ CPU cores, 2 GB RAM minimum (4 GB+ recommended) |
| Linux | Any modern 64-bit Linux distribution | Any | 2+ CPU cores, 2 GB RAM minimum (4 GB+ recommended) |

Langflow is API-driven, so no GPU is required. Allow a few GB of free disk space for Python 3.12, the virtual environment, and Langflow's packages. First launch can take 10–15 minutes on slower machines.

## Quick Start (Windows)

1. [Download the latest Windows release](https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/latest/download/langflow-installer-win.zip)
2. Extract the zip anywhere
3. Double-click **`Install Langflow.bat`**

The script will:
- Install `uv` (self-bootstrapping package manager)
- Download Python 3.12
- Create a virtual environment in `%USERPROFILE%\langflow\`
- Install Langflow 1.12.1 (every non-PyTorch provider bundle, plus PostgreSQL drivers)
- Create desktop shortcuts (`Langflow Web.lnk` and `Stop Langflow.lnk`)

After install, double-click the **Langflow Web** desktop shortcut. A terminal window will open, and your browser will launch automatically once the server is ready at `http://127.0.0.1:7860`. To stop the server, double-click **Stop Langflow**.

> **Having trouble?** See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for Smart App Control and antivirus help.

## Quick Start (macOS)

> **Apple Silicon required**: This installer supports M1 (or newer) Macs only. Intel Macs are not supported — the bundled packages can fail to build there.

1. [Download the macOS release](https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/latest/download/langflow-installer-macos.zip)
2. Extract the zip (double-click in Finder)
3. Double-click **`Install Langflow.command`**

> **Gatekeeper warning**: macOS will block the file the first time. Go to **System Settings > Privacy & Security**, scroll to **Security**, click **Open Anyway** next to the blocked file, then confirm. See the [detailed guide](docs/GATEKEEPER.md) for screenshots. This is one-time per file.

The script will:
- Install `uv` (self-bootstrapping package manager)
- Download Python 3.12
- Create a virtual environment in `~/langflow/`
- Install Langflow 1.12.1 (every non-PyTorch provider bundle, plus PostgreSQL drivers)
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
- Install Langflow 1.12.1 (every non-PyTorch provider bundle, plus PostgreSQL drivers)
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
| `src/uv-install.ps1` | uv bootstrapper (Windows, fetched from upstream at package time) |
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
