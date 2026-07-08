# Langflow Installer for Windows, macOS, and Linux

One-click installer for [Langflow](https://github.com/langflow-ai/langflow) **1.10.2** on Windows, macOS, and Linux — no admin rights required.

[![GitHub](https://img.shields.io/badge/GitHub-NikkiSatmaka-181717?style=for-the-badge&logo=github)](https://github.com/NikkiSatmaka/)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-nikkisatmaka-0A66C2?style=for-the-badge&logo=linkedin)](https://linkedin.com/in/nikkisatmaka/)

## Downloads

| Platform | Download |
|----------|----------|
| Windows 10/11 | [langflow-installer-win.zip](https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/latest/download/langflow-installer-win.zip) |
| macOS 12+ | [langflow-installer-macos.zip](https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/latest/download/langflow-installer-macos.zip) |
| Linux | [langflow-installer-linux.zip](https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/latest/download/langflow-installer-linux.zip) |

Visit the [landing page](https://nikkisatmaka.github.io/langflow-installer-wrapper/) for a simpler experience with OS tabs.

## Quick Start (Windows)

1. [Download the latest Windows release](https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/latest/download/langflow-installer-win.zip)
2. Extract the zip anywhere
3. Double-click **`Install Langflow.bat`**

The script will:
- Install `uv` (self-bootstrapping package manager)
- Download Python 3.12
- Create a virtual environment in `%USERPROFILE%\langflow\`
- Install Langflow 1.10.2
- Create a desktop shortcut (`Langflow.lnk`)

After install, double-click the desktop shortcut. A terminal window will open, and your browser will launch automatically once the Langflow server is ready at `http://127.0.0.1:7860`.

> **Having trouble?** See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for Smart App Control and antivirus help.

## Quick Start (macOS)

1. [Download the macOS release](https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/latest/download/langflow-installer-macos.zip)
2. Extract the zip (double-click in Finder)
3. Double-click **`Install Langflow.command`**

If macOS shows a security warning, right-click the file and select **Open**, then click **Open** in the dialog. This is a one-time step.

The script will:
- Install `uv` (self-bootstrapping package manager)
- Download Python 3.12
- Create a virtual environment in `~/langflow/`
- Install Langflow 1.10.2
- Create a desktop shortcut (`Langflow.command`)

After install, double-click the desktop shortcut. Terminal will open, start the server, and open your browser automatically.

## Quick Start (Linux)

1. [Download the Linux release](https://github.com/NikkiSatmaka/langflow-installer-wrapper/releases/latest/download/langflow-installer-linux.zip)
2. Extract the zip
3. Open a terminal in the extracted folder and run `bash Install\ Langflow.sh`

The script will:
- Install `uv` (self-bootstrapping package manager)
- Download Python 3.12
- Create a virtual environment in `~/langflow/`
- Install Langflow 1.10.2
- Create a desktop shortcut in your app menu and on your desktop

After install, launch Langflow from your app menu or desktop shortcut. A terminal will open, start the server, and open your browser automatically.

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
- Desktop shortcut
- Optionally Python 3.12

`uv` is kept — it may be useful for other projects.

## Files

| File | Purpose |
|------|---------|
| `Install Langflow.bat` | Double-click launcher (Windows) |
| `Install Langflow.command` | Double-click launcher (macOS) |
| `Install Langflow.sh` | Launcher (Linux) |
| `src/install-langflow-script.ps1` | Main installer/uninstaller script (Windows) |
| `src/install-langflow.sh` | Main installer/uninstaller script (macOS/Linux) |
| `src/uv-install.ps1` | Bundled uv bootstrapper (Windows) |
| `CONTRACT.md` | Formal requirements specification |
| `README.md` | This file |
| `docs/TROUBLESHOOTING.md` | Common issues and fixes |

## License

MIT
