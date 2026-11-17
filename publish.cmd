@echo off
rem Refresh README index, commit and push everything.  Usage: publish.cmd [-Message "notes: ..."]
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\publish.ps1" %*
if errorlevel 1 (
  echo.
  echo [publish] failed. See the error above.
  pause
)
