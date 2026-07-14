<#
.SYNOPSIS
    Stop the Langflow server on Windows.
.DESCRIPTION
    Finds the Langflow server process by port 7860 or window title and terminates it.
.NOTES
    Author: Nikki Satmaka
    GitHub:  https://github.com/NikkiSatmaka/
    LinkedIn: https://linkedin.com/in/nikkisatmaka/
#>

#Requires -Version 5.1

$Port = 7860
$found = $false

# ── Helpers ──
function Write-Info  { Write-Host " $($args[0])" -ForegroundColor Cyan }
function Write-Ok    { Write-Host " ✓ $($args[0])" -ForegroundColor Green }
function Write-Fail  { Write-Host " ✗ $($args[0])" -ForegroundColor Red }
function Write-Warn  { Write-Host " ⚠ $($args[0])" -ForegroundColor Yellow }

# ── Banner ──
Clear-Host
$G = "$([char]0x1b)[32m"
$C = "$([char]0x1b)[36m"
$R = "$([char]0x1b)[0m"
$B = "$([char]0x1b)[1m"

Write-Host "${G}╔══════════════════════════════════════════════════╗${R}"
Write-Host "${G}║${C}${B}           Stop Langflow Server               ${G}║${R}"
Write-Host "${G}║──────────────────────────────────────────────────║${R}"
Write-Host "${G}║${R}  GitHub:  https://github.com/NikkiSatmaka/       ${G}║${R}"
Write-Host "${G}║${R}  LinkedIn: https://linkedin.com/in/nikkisatmaka/ ${G}║${R}"
Write-Host "${G}╚══════════════════════════════════════════════════╝${R}"
Write-Host ""

# ── Stop Logic ──

# Method 1: Find by port via netstat
try {
    $connections = netstat -ano | Select-String ":$Port "
    if ($connections) {
        $pids = $connections | ForEach-Object {
            ($_ -split '\s+')[-1]
        } | Select-Object -Unique

        foreach ($pid in $pids) {
            Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue | Out-Null
            $found = $true
        }
    }
}
catch {
    # netstat not available
}

# Method 2: Find by window title (start /MIN "Langflow Server")
if (-not $found) {
    try {
        $procs = Get-Process | Where-Object { $_.MainWindowTitle -eq "Langflow Server" }
        if ($procs) {
            $procs | Stop-Process -Force -ErrorAction SilentlyContinue
            $found = $true
        }
    }
    catch {}
}

# Method 3: Find langflow-related uv processes
if (-not $found) {
    try {
        Get-Process -Name "uv" -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $cmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($_.Id)").CommandLine
                if ($cmdLine -match "langflow") {
                    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue | Out-Null
                    $found = $true
                }
            }
            catch {}
        }
    }
    catch {}
}

if ($found) {
    Write-Ok "Langflow server stopped."
}
else {
    Write-Warn "No running Langflow server found."
}

Write-Host ""
pause
