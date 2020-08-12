
echo %~dp0
powershell -NoProfile -ExecutionPolicy Unrestricted %~dp0\Get-SysConfig.ps1 %~dp0

pause