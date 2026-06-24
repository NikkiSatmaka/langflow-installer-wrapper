<#
.SYNOPSIS
    Install or uninstall Langflow on Windows using uv.
.DESCRIPTION
    Bootstraps uv, installs Python 3.12, creates a virtual environment,
    installs Langflow 1.9.6, and creates a desktop shortcut.
    Also supports clean uninstall of all components.
.NOTES
    Author: Nikki Satmaka
    GitHub:  https://github.com/NikkiSatmaka/
    LinkedIn: https://linkedin.com/in/nikkisatmaka/
#>

#Requires -Version 5.1

$ScriptVersion   = "1.0.0"
$LangflowVersion = "1.9.6"
$LangflowDir     = "$env:USERPROFILE\langflow"
$UvBinDir        = "$env:USERPROFILE\.local\bin"
$ShortcutName    = "Langflow.lnk"

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
    Write-Host "${G}║${C}${B}            Langflow Installer for Windows        ${G}║${R}"
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
    $choice = Read-Host "Select an option"
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
    Write-Info "Installing Python 3.12..."
    try {
        uv python install 3.12 2>&1 | Out-Null
    }
    catch {
        Write-Fail "Failed to install Python 3.12: $_"
        return $false
    }

    if (-not (Test-Path "$LangflowDir")) {
        New-Item -ItemType Directory -Path "$LangflowDir" -Force | Out-Null
    }

    Push-Location "$LangflowDir"
    try {
        uv python pin 3.12 2>&1 | Out-Null
    }
    finally {
        Pop-Location
    }

    Write-Ok "Python 3.12 ready"
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

        uv pip install "langflow==$LangflowVersion" 2>&1 | ForEach-Object { Write-Host "   $_" }
        if ($LASTEXITCODE -eq 0) {
            $installOk = $true
        }
        else {
            Write-Warn "Version $LangflowVersion failed -- trying latest..."
            uv pip install langflow 2>&1 | ForEach-Object { Write-Host "   $_" }
            if ($LASTEXITCODE -eq 0) {
                $installOk = $true
            }
        }

        if (-not $installOk) {
            Write-Fail "Langflow installation failed. Check your internet connection and try again."
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
echo Starting Langflow server...
start "Langflow Server" "$uvPath" run langflow run
echo Waiting for Langflow to start (up to 30 seconds)...
timeout /t 30 /nobreak >nul
echo Opening browser...
start "" "http://127.0.0.1:7860"

echo.
echo  +==================================================+
echo  +  IMPORTANT: Do NOT close the "Langflow Server"   +
echo  +  terminal window -- that is where Langflow runs. +
echo  +  Closing it will stop the server.                +
echo  +==================================================+
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
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = $LauncherPath
        $Shortcut.WorkingDirectory = $LangflowDir
        $Shortcut.Description = "Langflow AI Platform (http://127.0.0.1:7860)"
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

# ── Install ────────────────────────────────────────────────────────────────

function Start-Install {
    Write-Info "Starting installation..."
    Write-Host ""

    if (-not (Install-Uv)) { return }
    if (-not (Install-Python)) { return }
    if (-not (Install-LangflowPackage)) { return }
    New-DesktopShortcut | Out-Null

    Write-Host ""
    Write-Host "══════════════════════════════════════════════════" -ForegroundColor Green
    Write-Ok "Langflow $LangflowVersion installed"
    Write-Ok "Desktop shortcut created"
    Write-Host " ➜  Double-click the Langflow desktop shortcut to start" -ForegroundColor Cyan
    Write-Host " ➜  Browser will open automatically at http://127.0.0.1:7860" -ForegroundColor Cyan
    Write-Host "══════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    pause
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

    $removePy = Read-Host "Remove Python 3.12 installed by uv? [y/N]"
    if ($removePy.ToUpper() -eq 'Y') {
        try {
            uv python uninstall 3.12 2>&1 | Out-Null
            Write-Ok "Python 3.12 removed"
        }
        catch {
            Write-Warn "Could not remove Python 3.12: $_"
        }
    }

    Write-Host ""
    Write-Host "══════════════════════════════════════════════════" -ForegroundColor Green
    Write-Ok "Langflow uninstalled"
    Write-Info "  uv was kept — remove manually if desired:"
    Write-Info "    rm -r ""$UvBinDir\uv.exe"" ""$UvBinDir\uvx.exe"" ""$UvBinDir\uvw.exe"""
    Write-Host "══════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    pause
}

# ── Main ───────────────────────────────────────────────────────────────────

function Main {
    Show-Banner

    do {
        $choice = Show-Menu
        switch ($choice) {
            'I' { Start-Install; Show-Banner }
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
