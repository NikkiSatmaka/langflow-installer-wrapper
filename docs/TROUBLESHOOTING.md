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

Some antivirus software (Kaspersky, Total Security) may flag the `uv pip install` step or the `irm | iex` pattern. Starting from v1.1.4, the installer bundles `uv-install.ps1` instead of using `irm | iex`. If your AV still blocks it, add an exclusion for `%USERPROFILE%\langflow\`.

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

## Linux desktop shortcut doesn't appear

Some Linux desktop environments (GNOME, KDE) may not immediately show the shortcut in the app menu. Try logging out and back in, or running `update-desktop-database ~/.local/share/applications/` in a terminal.

If the desktop shortcut file (`langflow.desktop`) appears as a text file, you may need to make it executable:
```bash
chmod +x ~/Desktop/langflow.desktop
```
