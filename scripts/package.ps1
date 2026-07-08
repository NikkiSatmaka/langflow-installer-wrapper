<#
.SYNOPSIS
    Package the Langflow installer into platform-specific zips.
.DESCRIPTION
    Builds all three platform zips using Compress-Archive.
    Output goes to dist/ relative to repo root.
.NOTES
    Usage:  powershell -File scripts/package.ps1 [[-Tag] <string>]
      If Tag is given, zips are named langflow-installer-{platform}-{tag}.zip
      Otherwise, langflow-installer-{platform}.zip
#>

param([string]$Tag = "")

$RepoRoot = Split-Path -Path $PSScriptRoot -Parent
$Dist = Join-Path $RepoRoot "dist"
New-Item -ItemType Directory -Path $Dist -Force | Out-Null

function Package-Win {
    $tmpdir = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path "$tmpdir\src" -Force | Out-Null

    Copy-Item (Join-Path $RepoRoot "Install Langflow.bat") $tmpdir
    Copy-Item (Join-Path $RepoRoot "Stop Langflow.bat") $tmpdir
    Copy-Item (Join-Path $RepoRoot "LICENSE") $tmpdir
    Copy-Item (Join-Path $RepoRoot "src\install-langflow-script.ps1") "$tmpdir\src"
    Copy-Item (Join-Path $RepoRoot "src\stop-langflow-script.ps1") "$tmpdir\src"
    Copy-Item (Join-Path $RepoRoot "src\uv-install.ps1") "$tmpdir\src"

    $zipName = "langflow-installer-win"
    if ($Tag) { $zipName += "-$Tag" }
    $zipPath = Join-Path $Dist "$zipName.zip"
    Compress-Archive -Path "$tmpdir\*" -DestinationPath $zipPath -Force
    Remove-Item -Path $tmpdir -Recurse -Force
    Write-Host "  $zipName.zip"
}

function Package-Macos {
    $tmpdir = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path "$tmpdir\src" -Force | Out-Null

    Copy-Item (Join-Path $RepoRoot "Install Langflow.command") $tmpdir
    Copy-Item (Join-Path $RepoRoot "Stop Langflow.command") $tmpdir
    Copy-Item (Join-Path $RepoRoot "LICENSE") $tmpdir
    Copy-Item (Join-Path $RepoRoot "src\install-langflow.sh") "$tmpdir\src"
    Copy-Item (Join-Path $RepoRoot "src\stop-langflow.sh") "$tmpdir\src"

    $zipName = "langflow-installer-macos"
    if ($Tag) { $zipName += "-$Tag" }
    $zipPath = Join-Path $Dist "$zipName.zip"
    Compress-Archive -Path "$tmpdir\*" -DestinationPath $zipPath -Force
    Remove-Item -Path $tmpdir -Recurse -Force
    Write-Host "  $zipName.zip"
}

function Package-Linux {
    $tmpdir = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path "$tmpdir\src" -Force | Out-Null

    Copy-Item (Join-Path $RepoRoot "Install Langflow.sh") $tmpdir
    Copy-Item (Join-Path $RepoRoot "Stop Langflow.sh") $tmpdir
    Copy-Item (Join-Path $RepoRoot "LICENSE") $tmpdir
    Copy-Item (Join-Path $RepoRoot "src\install-langflow.sh") "$tmpdir\src"
    Copy-Item (Join-Path $RepoRoot "src\stop-langflow.sh") "$tmpdir\src"

    $zipName = "langflow-installer-linux"
    if ($Tag) { $zipName += "-$Tag" }
    $zipPath = Join-Path $Dist "$zipName.zip"
    Compress-Archive -Path "$tmpdir\*" -DestinationPath $zipPath -Force
    Remove-Item -Path $tmpdir -Recurse -Force
    Write-Host "  $zipName.zip"
}

Write-Host "Packaging..."
Package-Win
Package-Macos
Package-Linux
Write-Host "Done. All zips in $Dist/"
