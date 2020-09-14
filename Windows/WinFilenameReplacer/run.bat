@echo off
echo %~dp0
powershell -NoProfile -ExecutionPolicy Unrestricted %~dp0\WinFilenameReplacer.ps1 %~dp0
