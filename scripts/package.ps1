<#
.SYNOPSIS
    Package the Langflow installer into platform-specific zips.
.DESCRIPTION
    Builds all three platform zips using Compress-Archive.
    Output goes to dist/ relative to repo root.
.NOTES
    Usage:  powershell -File scripts/package.ps1 [[-Tag] <string>]
      If Tag is given, both versioned and unversioned zips are produced:
        langflow-installer-{platform}-{tag}.zip
        langflow-installer-{platform}.zip
      Otherwise, only unversioned zips:
        langflow-installer-{platform}.zip
#>

param([string]$Tag = "")

$RepoRoot = Split-Path -Path $PSScriptRoot -Parent
$Dist = Join-Path $RepoRoot "dist"
New-Item -ItemType Directory -Path $Dist -Force | Out-Null

function Package-Platform {
    param([string]$Platform, [string[]]$RootFiles, [string[]]$SrcFiles)

    $tmpdir = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path "$tmpdir\src" -Force | Out-Null

    foreach ($f in $RootFiles) {
        Copy-Item (Join-Path $RepoRoot $f) $tmpdir
    }
    foreach ($f in $SrcFiles) {
        Copy-Item (Join-Path $RepoRoot "src\$f") "$tmpdir\src"
    }

    # Unversioned zip — always produced
    $zipName = "langflow-installer-$Platform.zip"
    $zipPath = Join-Path $Dist $zipName
    Compress-Archive -Path "$tmpdir\*" -DestinationPath $zipPath -Force
    Write-Host "  $zipName"

    # Versioned copy if a tag was given
    if ($Tag) {
        $taggedName = "langflow-installer-${Platform}-${Tag}.zip"
        Copy-Item $zipPath (Join-Path $Dist $taggedName) -Force
        Write-Host "  $taggedName"
    }

    Remove-Item -Path $tmpdir -Recurse -Force
}

Write-Host "Packaging..."

Package-Platform -Platform "win" `
    -RootFiles @("Install Langflow.bat", "Stop Langflow.bat", "LICENSE") `
    -SrcFiles @("install-langflow-script.ps1", "stop-langflow-script.ps1", "uv-install.ps1", "assets/langflow.ico")

Package-Platform -Platform "macos" `
    -RootFiles @("Install Langflow.command", "Stop Langflow.command", "LICENSE") `
    -SrcFiles @("install-langflow.sh", "stop-langflow.sh")

Package-Platform -Platform "linux" `
    -RootFiles @("Install Langflow.sh", "Stop Langflow.sh", "LICENSE") `
    -SrcFiles @("install-langflow.sh", "stop-langflow.sh", "assets/langflow.png")

Write-Host "Done. All zips in $Dist/"
