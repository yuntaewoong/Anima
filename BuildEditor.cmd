@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Scripts\Project.ps1" -Action Build %*
set "ANIMA_EXIT=%ERRORLEVEL%"
if not "%ANIMA_EXIT%"=="0" pause
exit /b %ANIMA_EXIT%
