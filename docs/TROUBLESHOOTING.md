# Troubleshooting

## Smart App Control blocks the installer (Windows)

Windows Smart App Control may block `Install Langflow.bat` because it runs an unsigned PowerShell script from the internet. This is a false positive — the script is fully open source and auditable.

**To fix:**
1. Open **Windows Security** → **App & browser control** → **Smart App Control**
2. Set it to **Off** (or **Evaluate** if available)
3. Run the installer
4. Re-enable Smart App Control afterwards

> The script is safe. It only installs Langflow in `%USERPROFILE%\langflow\` using `uv` — no system modifications, no admin rights required.

## Antivirus flags the installer (Windows)

Some antivirus software (Kaspersky, Total Security) may flag the `uv pip install` step or the `irm | iex` pattern. Starting from v1.1.4, the installer uses `uv-install.ps1` (fetched from upstream at package time) instead of using `irm | iex`. If your AV still blocks it, add an exclusion for `%USERPROFILE%\langflow\`.

## Uninstall doesn't clean up everything

Run the installer again and select **Uninstall**. This removes:
- `%USERPROFILE%\langflow\` or `~/langflow/` (venv + Langflow)
- Desktop shortcut
- Optionally Python 3.12

`uv` is kept — it may be useful for other projects. To remove uv manually:
- **Windows**: Delete `%USERPROFILE%\.local\bin\uv.exe` and related files
- **macOS/Linux**: Run `rm -rf ~/.local/bin/uv` and related files

## macOS security warning when opening .command file

The first time you double-click `Install Langflow.command` (or the desktop shortcut), macOS may show: *"Langflow.command cannot be opened because it is from an unidentified developer."*

**To fix:** Right-click the file and select **Open**, then click **Open** in the dialog. This one-time step adds the file to your security exceptions.

## Install fails on an Intel (x86_64) Mac

The installer bundles a pre-built `litellm` wheel for Apple Silicon (arm64) only. Langflow 1.11.2 requires `litellm>=1.93`, which publishes no macOS wheels, so on Intel Macs the install must compile it from source and fails if Xcode Command Line Tools and Rust are not installed.

**To fix:** install Xcode Command Line Tools and Rust, then re-run the installer:

```bash
xcode-select --install
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Apple Silicon (M-series) Macs are unaffected — they use the bundled wheel.

## Linux desktop shortcut doesn't appear

Some Linux desktop environments (GNOME, KDE) may not immediately show the shortcut in the app menu. Try logging out and back in, or running `update-desktop-database ~/.local/share/applications/` in a terminal.

If the desktop shortcut file (`langflow.desktop`) appears as a text file, you may need to make it executable:
```bash
chmod +x ~/Desktop/langflow.desktop
```

## PyTorch fails to install or load (Windows)

Some packages (for example PyTorch) require the Visual C++ Redistributable. If it is missing, `uv pip install` may fail with an error about `VCRUNTIME140.dll` or `msvcp140.dll`.

**To fix:**
1. Download the Visual C++ Redistributable (x64) from Microsoft: <https://aka.ms/vc14/vc_redist.x64.exe>
2. Run the installer and follow the prompts (you may need to approve a UAC prompt).
3. Re-run the Langflow installer and choose **Install**.

> The redistributable is safe and published by Microsoft. Many Python packages with native C++ extensions (including PyTorch) depend on it.

## Langflow won't start or behaves oddly

Corrupted cache or stale data can cause Langflow to fail on startup or act unexpectedly. Deleting its cache gives it a clean slate.

**To fix:** stop Langflow, then delete its cache directory:

- **Windows**: Delete `C:\Users\<you>\AppData\Local\langflow` (or run `rmdir /s "%LOCALAPPDATA%\langflow"` in a terminal)
- **macOS**: Delete `~/Library/Caches/langflow` (or run `rm -rf ~/Library/Caches/langflow`)
- **Linux**: Delete `~/.cache/langflow` (or run `rm -rf ~/.cache/langflow`)

Then start Langflow again from the desktop shortcut. Your installed packages stay in place — only cached data is removed.
