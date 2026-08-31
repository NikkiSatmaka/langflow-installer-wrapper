# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Non-technical users who want to try Langflow but aren't comfortable with Python, pip, or command line tools. These users need a simple, one-click solution that handles all technical setup automatically.

## Product Purpose

Provide single-click installers for Langflow on Windows, macOS, and Linux that require no administrative privileges. Success means users can install and run Langflow without understanding Python environments, package managers, or terminal commands.

## Positioning

The installer eliminates the technical barriers that prevent non-technical users from trying Langflow. Unlike manual installation guides, this requires zero command-line knowledge and works without admin rights, making Langflow accessible to anyone with a computer.

## Operating Context

- Users download a zip file from GitHub Releases
- Double-click a launcher file (`.bat`, `.command`, or `.sh`)
- Follow a simple menu prompt to install
- Desktop shortcuts are created for easy access
- The installer handles Python, uv, and Langflow setup automatically

## Capabilities and Constraints

- **Cross-platform**: Windows 10/11, macOS 12+, and Linux
- **No admin rights**: All installations occur under user profile directories
- **Idempotent**: Safe to re-run; checks dependencies before acting
- **Version pinned**: Langflow 1.11.5 with Python 3.12
- **uv package manager**: Self-bootstrapping, no pre-installed Python required
- **Desktop shortcuts**: Created for starting and stopping Langflow
- **Browser auto-launch**: Opens `http://127.0.0.1:7860` when ready

## Brand Commitments

- Author attribution displayed on every script run (GitHub + LinkedIn)
- MIT licensed
- GitHub stars encouraged as primary feedback mechanism

## Evidence on Hand

- Landing page: `docs/index.html` (GitHub Pages)
- Installation scripts: `src/install-langflow-script.ps1` (Windows), `src/install-langflow.sh` (macOS/Linux)
- Troubleshooting documentation: `docs/TROUBLESHOOTING.md`, `docs/GATEKEEPER.md`
- CI/CD: Automated verification and release workflows

## Product Principles

1. **Simplicity over flexibility**: One-click install with sensible defaults, no configuration options
2. **No admin rights**: Everything installs under user profile directories
3. **Idempotent operations**: Safe to re-run without side effects
4. **Clear error messages**: Users understand what went wrong and how to fix it
5. **Platform-native behavior**: Each platform uses appropriate tools and conventions
