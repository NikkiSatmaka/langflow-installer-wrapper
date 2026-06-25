# Troubleshooting

## Smart App Control blocks the installer

Windows Smart App Control may block `Install Langflow.bat` because it runs an unsigned PowerShell script from the internet. This is a false positive — the script is fully open source and auditable.

**To fix:**
1. Open **Windows Security** → **App & browser control** → **Smart App Control**
2. Set it to **Off** (or **Evaluate** if available)
3. Run the installer
4. Re-enable Smart App Control afterwards

> The script is safe. It only installs Langflow in `%USERPROFILE%\langflow\` using `uv` — no system modifications, no admin rights required.

## Antivirus flags the installer

Some antivirus software (Kaspersky, Total Security) may flag the `uv pip install` step or the `irm | iex` pattern. Starting from v1.1.4, the installer bundles `uv-install.ps1` instead of using `irm | iex`. If your AV still blocks it, add an exclusion for `%USERPROFILE%\langflow\`.

## Uninstall doesn't clean up everything

Run the installer again and select **Uninstall**. This removes:
- `%USERPROFILE%\langflow\` (venv + Langflow)
- Desktop shortcut
- Optionally Python 3.12

`uv` is kept — it may be useful for other projects. To remove uv manually, delete `%USERPROFILE%\.local\bin\uv.exe`, `%USERPROFILE%\.local\bin\uvx.exe`, and `%USERPROFILE%\.local\bin\uvw.exe`.
