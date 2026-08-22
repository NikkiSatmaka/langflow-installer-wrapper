<#
.SYNOPSIS
    Install or uninstall Langflow on Windows using uv.
.DESCRIPTION
    Bootstraps uv, installs Python 3.12, creates a virtual environment,
    installs Langflow 1.11.3, and creates a desktop shortcut.
    Also supports clean uninstall of all components.
.NOTES
    Author: Nikki Satmaka
    GitHub:  https://github.com/NikkiSatmaka/
    LinkedIn: https://linkedin.com/in/nikkisatmaka/
#>

#Requires -Version 5.1

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'ScriptVersion',
    Justification = 'Kept as a single source of truth for the script version, mirrored in the bash installer.')]
param()

$ScriptVersion   = "1.9.6"
$LangflowVersion = "1.11.3"
$PythonVersion   = "3.12"
$LangflowDir     = "$env:USERPROFILE\langflow"
$UvBinDir        = "$env:USERPROFILE\.local\bin"
$ShortcutName    = "Langflow Web.lnk"
$ConstraintsFile = "$PSScriptRoot\constraints.txt"

# ── Helpers ────────────────────────────────────────────────────────────────

function Write-Info  { Write-Host " $($args[0])" -ForegroundColor Cyan }
function Write-Ok    { Write-Host " ✓ $($args[0])" -ForegroundColor Green }
function Write-Fail  { Write-Host " ✗ $($args[0])" -ForegroundColor Red }
function Write-Warn  { Write-Host " ⚠ $($args[0])" -ForegroundColor Yellow }

# ── Banner ─────────────────────────────────────────────────────────────────

function Show-Banner {
    Clear-Host
    $G = "$([char]0x1b)[32m"
    $C = "$([char]0x1b)[36m"
    $R = "$([char]0x1b)[0m"
    $B = "$([char]0x1b)[1m"

    Write-Host "${G}╔══════════════════════════════════════════════════╗${R}"
    Write-Host "${G}║${C}${B}                Langflow Installer                ${G}║${R}"
    Write-Host "${G}║──────────────────────────────────────────────────║${R}"
    Write-Host "${G}║${R}  GitHub:  https://github.com/NikkiSatmaka/       ${G}║${R}"
    Write-Host "${G}║${R}  LinkedIn: https://linkedin.com/in/nikkisatmaka/ ${G}║${R}"
    Write-Host "${G}╚══════════════════════════════════════════════════╝${R}"
    Write-Host ""
}

# ── Menu ──────────────────────────────────────────────────────────────────

function Show-Menu {
    Write-Host " [I] Install Langflow $LangflowVersion" -ForegroundColor Yellow
    Write-Host " [U] Uninstall Langflow" -ForegroundColor Yellow
    Write-Host " [Q] Quit" -ForegroundColor Yellow
    Write-Host ""
    $choice = Read-Host "Type I, U, or Q and press Enter"
    Write-Host ""
    return $choice.ToUpper()
}

# ── uv ─────────────────────────────────────────────────────────────────────

function Install-Uv {
    $uv = Get-Command uv -ErrorAction SilentlyContinue
    if (-not $uv) {
        Write-Info "Installing uv..."
        try {
            & "$PSScriptRoot\uv-install.ps1"
        }
        catch {
            Write-Fail "Failed to install uv: $_"
            return $false
        }

        $UserPath = [Environment]::GetEnvironmentVariable('Path', 'User')
        if ($UserPath -notlike "*$UvBinDir*") {
            $NewPath = "$UvBinDir;$UserPath"
            [Environment]::SetEnvironmentVariable('Path', $NewPath, 'User')
        }

        $MachinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
        $UserPath = [Environment]::GetEnvironmentVariable('Path', 'User')
        $env:PATH = "$MachinePath;$UserPath"

        $uv = Get-Command uv -ErrorAction SilentlyContinue
        if (-not $uv) {
            Write-Fail "uv installed but not found on PATH after refresh."
            Write-Info "Try restarting your terminal and running the installer again."
            return $false
        }

        Write-Ok "uv installed ($(uv --version))"
    }
    else {
        Write-Ok "uv already installed ($(uv --version))"
    }
    return $true
}

# ── Python ─────────────────────────────────────────────────────────────────

function Install-Python {
    Write-Info "Installing Python $PythonVersion..."
    try {
        uv python install $PythonVersion 2>&1 | Out-Null
    }
    catch {
        Write-Fail "Failed to install Python ${PythonVersion}: $_"
        return $false
    }

    if (-not (Test-Path "$LangflowDir")) {
        New-Item -ItemType Directory -Path "$LangflowDir" -Force | Out-Null
    }

    Push-Location "$LangflowDir"
    try {
        uv python pin $PythonVersion 2>&1 | Out-Null
    }
    finally {
        Pop-Location
    }

    Write-Ok "Python $PythonVersion ready"
    return $true
}

# ── Langflow ───────────────────────────────────────────────────────────────

function Install-LangflowPackage {
    if (-not (Test-Path "$LangflowDir")) {
        New-Item -ItemType Directory -Path "$LangflowDir" -Force | Out-Null
    }

    Push-Location "$LangflowDir"
    try {
        if (-not (Test-Path ".venv\pyvenv.cfg")) {
            Write-Info "Creating virtual environment..."
            uv venv 2>&1 | Out-Null
            Write-Ok "Virtual environment created"
        }
        else {
            Write-Ok "Virtual environment already exists"
        }

        Write-Info "Installing Langflow $LangflowVersion (this may take a few minutes)..."

        $installOk = $false
        $constraintsArgs = @()
        if (Test-Path $ConstraintsFile) {
            Copy-Item -Path $ConstraintsFile -Destination "$LangflowDir\constraints.txt" -Force
            $constraintsArgs = @("--constraint=constraints.txt")
        }

        uv pip install "langflow==$LangflowVersion" @constraintsArgs 2>&1 | ForEach-Object { Write-Host "   $_" }
        if ($LASTEXITCODE -eq 0) {
            $installOk = $true
        }
        else {
            Write-Warn "Version $LangflowVersion failed -- trying latest..."
            uv pip install langflow @constraintsArgs 2>&1 | ForEach-Object { Write-Host "   $_" }
            if ($LASTEXITCODE -eq 0) {
                $installOk = $true
            }
        }

        if (-not $installOk) {
            Write-Fail "Langflow installation failed. Please report the issue at https://github.com/NikkiSatmaka/langflow-installer-wrapper/issues"
            return $false
        }

        Write-Ok "Langflow installed"
    }
    finally {
        Pop-Location
    }
    return $true
}

# ── Shortcut ───────────────────────────────────────────────────────────────

function New-DesktopShortcut {
    $DesktopPath = [Environment]::GetFolderPath('Desktop')
    $ShortcutPath = "$DesktopPath\$ShortcutName"
    $LauncherPath = "$LangflowDir\run-langflow.bat"

    $uvPath = (Get-Command uv).Source
    if (-not $uvPath) {
        Write-Fail "Cannot find uv.exe on PATH"
        return $false
    }

    $launcherContent = @"
@echo off
title Langflow Server Launcher

echo.
echo  +==================================================+
echo  +            Langflow Server Launcher              +
echo  +--------------------------------------------------+
echo  +  GitHub:  https://github.com/NikkiSatmaka/       +
echo  +  LinkedIn: https://linkedin.com/in/nikkisatmaka/ +
echo  +==================================================+
echo.

cd /d "%~dp0"

echo.
echo  +==================================================+
echo  +  A new minimized terminal window will open with  +
echo  +  the Langflow server logs.                       +
echo  +                                                  +
echo  +  IMPORTANT: Do NOT close that window.            +
echo  +  Closing it will stop the server and the         +
echo  +  browser will no longer work.                    +
echo  +==================================================+
echo.
echo Starting Langflow server...
start /MIN "Langflow Server - KEEP OPEN" "$uvPath" run langflow run
echo.
echo  +==================================================+
echo  +  First launch can take a few minutes.            +
echo  +  That is completely normal, please be patient.   +
echo  +                                                  +
echo  +  Your browser will open by itself as soon as     +
echo  +  Langflow is ready.                              +
echo  +                                                  +
echo  +  Just leave this window open. No action needed.  +
echo  +==================================================+
echo.
set /a waited=0

:waitloop
powershell -NoProfile -Command "try { Invoke-WebRequest -Uri 'http://127.0.0.1:7860/health_check' -UseBasicParsing -TimeoutSec 3 | Out-Null; exit 0 } catch { exit 1 }"
if %errorlevel% equ 0 goto serverready
timeout /t 3 /nobreak >nul
set /a waited+=3
set /a tick=%waited% %% 21
if %tick% neq 0 goto waitloop
if %waited% equ 21 echo Still starting... (%waited% seconds). This is normal on first launch.
if %waited% equ 42 echo Still starting... (%waited% seconds). First launch takes the longest.
if %waited% equ 63 echo Still starting... (%waited% seconds). Thanks for your patience.
if %waited% geq 84 echo Still starting... (%waited% seconds).
if %waited% geq 84 echo If no browser has opened by now, you can also visit http://127.0.0.1:7860 manually.
goto waitloop

:serverready
echo.
echo  +==================================================+
echo  +  Langflow server is ready!                       +
echo  +  Opening browser...                              +
echo  +==================================================+
start "" "http://127.0.0.1:7860"

echo.
echo Press any key to close this launcher...
pause >nul
"@
    try {
        Set-Content -Path $LauncherPath -Value $launcherContent -Encoding Ascii
    }
    catch {
        Write-Warn "Could not create launcher script: $_"
    }

    try {
        if (Test-Path "$PSScriptRoot\assets\langflow.ico") {
            Copy-Item "$PSScriptRoot\assets\langflow.ico" "$LangflowDir\langflow.ico" -Force
        }

        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = $LauncherPath
        $Shortcut.WorkingDirectory = $LangflowDir
        $Shortcut.Description = "Langflow AI Platform (http://127.0.0.1:7860)"
        if (Test-Path "$LangflowDir\langflow.ico") {
            $Shortcut.IconLocation = "$LangflowDir\langflow.ico"
        }
        $Shortcut.Save()

        Write-Ok "Desktop shortcut created: $ShortcutPath"
    }
    catch {
        Write-Warn "Could not create desktop shortcut (COM unavailable)."
        Write-Info "  Run manually: ""$LauncherPath"""
        return $false
    }
    return $true
}

# ── Stop Shortcut ─────────────────────────────────────────────────────────

function New-DesktopStopShortcut {
    $DesktopPath = [Environment]::GetFolderPath('Desktop')
    $StopShortcutPath = "$DesktopPath\Stop Langflow.lnk"
    $StopLauncherPath = "$LangflowDir\stop-langflow.ps1"
    $SourceStopScript = "$PSScriptRoot\stop-langflow-script.ps1"

    if (Test-Path $SourceStopScript) {
        try {
            Copy-Item -Path $SourceStopScript -Destination $StopLauncherPath -Force
        }
        catch {
            Write-Warn "Could not copy stop launcher script: $_"
            return $false
        }
    }
    else {
        Write-Warn "Stop script not found at $SourceStopScript"
        return $false
    }

    try {
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($StopShortcutPath)
        $Shortcut.TargetPath = "powershell.exe"
        $Shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$StopLauncherPath`""
        $Shortcut.WorkingDirectory = $LangflowDir
        $Shortcut.Description = "Stop the Langflow server"
        $Shortcut.Save()

        Write-Ok "Stop shortcut created: $StopShortcutPath"
    }
    catch {
        Write-Warn "Could not create stop desktop shortcut (COM unavailable)."
        Write-Info "  Run manually: powershell -File ""$StopLauncherPath"""
        return $false
    }
    return $true
}

# ── Install ────────────────────────────────────────────────────────────────

function Start-Install {
    Write-Info "Starting installation..."
    Write-Host ""

    if (-not (Install-Uv)) { return $false }
    if (-not (Install-Python)) { return $false }
    if (-not (Install-LangflowPackage)) { return $false }
    New-DesktopShortcut | Out-Null
    New-DesktopStopShortcut | Out-Null

    Write-Host ""
    Write-Host "══════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "  ✓ Langflow $LangflowVersion installed" -ForegroundColor White -BackgroundColor Green
    Write-Ok "Desktop shortcuts created"
    Write-Host ""
    Write-Host "  NEXT STEP:" -ForegroundColor Yellow
    Write-Host "   1. Double-click the 'Langflow Web' shortcut on your Desktop" -ForegroundColor Cyan
    Write-Host "   2. A 'Langflow Server - KEEP OPEN' window starts minimized" -ForegroundColor Cyan
    Write-Host "   3. Your browser opens automatically at http://127.0.0.1:7860" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Keep the 'Langflow Server - KEEP OPEN' window open." -ForegroundColor Yellow
    Write-Host "  Closing it stops the server." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "══════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Read-Host "Installation complete - press Enter to close this window"
    exit 0
}

# ── Uninstall ──────────────────────────────────────────────────────────────

function Start-Uninstall {
    $confirm = Read-Host "Remove Langflow and its virtual environment? [y/N]"
    if ($confirm.ToUpper() -ne 'Y') {
        Write-Info "Uninstall cancelled."
        pause
        return
    }

    if (Test-Path "$LangflowDir") {
        Write-Info "Removing $LangflowDir..."
        try {
            Remove-Item -Path "$LangflowDir" -Recurse -Force
            Write-Ok "Langflow directory removed"
        }
        catch {
            Write-Fail "Could not remove $LangflowDir : $_"
        }
    }
    else {
        Write-Ok "Langflow directory not found — nothing to remove"
    }

    $DesktopPath = [Environment]::GetFolderPath('Desktop')
    $ShortcutPath = "$DesktopPath\$ShortcutName"
    if (Test-Path $ShortcutPath) {
        try {
            Remove-Item -Path $ShortcutPath -Force
            Write-Ok "Desktop shortcut removed"
        }
        catch {
            Write-Warn "Could not remove shortcut: $_"
        }
    }

    $StopShortcutPath = "$DesktopPath\Stop Langflow.lnk"
    if (Test-Path $StopShortcutPath) {
        try {
            Remove-Item -Path $StopShortcutPath -Force
            Write-Ok "Stop shortcut removed"
        }
        catch {
            Write-Warn "Could not remove stop shortcut: $_"
        }
    }

    $removePy = Read-Host "Remove Python $PythonVersion installed by uv? [y/N]"
    if ($removePy.ToUpper() -eq 'Y') {
        try {
            uv python uninstall $PythonVersion 2>&1 | Out-Null
            Write-Ok "Python $PythonVersion removed"
        }
        catch {
            Write-Warn "Could not remove Python ${PythonVersion}: $_"
        }
    }

    Write-Host ""
    Write-Host "══════════════════════════════════════════════════" -ForegroundColor Green
    Write-Ok "Langflow uninstalled"
    Write-Info "  uv was kept — remove manually if desired:"
    Write-Info "    rm -r ""$UvBinDir\uv.exe"" ""$UvBinDir\uvx.exe"" ""$UvBinDir\uvw.exe"""
    Write-Host "══════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Read-Host "Uninstall complete - press Enter to close this window"
    exit 0
}

# ── Main ───────────────────────────────────────────────────────────────────

function Main {
    Show-Banner

    do {
        $choice = Show-Menu
        switch ($choice) {
            'I' {
                if (-not (Start-Install)) {
                    Write-Host ""
                    Write-Warn "Installation failed. Take a screenshot of this screen if you plan to report the issue."
                    pause
                }
                Show-Banner
            }
            'U' { Start-Uninstall; Show-Banner }
            'Q' { exit 0 }
            default {
                Write-Warn "Invalid choice. Press [I], [U], or [Q]."
                Write-Host ""
            }
        }
    } while ($true)
}

Main
