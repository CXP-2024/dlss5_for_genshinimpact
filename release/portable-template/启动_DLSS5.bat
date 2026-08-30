@echo off
setlocal
chcp 65001 >nul
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0配置并启动.ps1"
if errorlevel 1 pause
endlocal
