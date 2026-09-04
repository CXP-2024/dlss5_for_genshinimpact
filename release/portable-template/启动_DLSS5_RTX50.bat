@echo off
setlocal
chcp 65001 >nul
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0payload\_internal\configure_and_start.ps1" -NrProfile rtx50
if errorlevel 1 pause
endlocal
