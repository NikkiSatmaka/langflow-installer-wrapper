@echo off
title Stop Langflow Server
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0src\stop-langflow-script.ps1"
pause
