@echo off
rem Create today's note and open it.  Usage: new-note.cmd [-Title "..."] [-Date yyyy-MM-dd]
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\new-note.ps1" %*
if errorlevel 1 (
  echo.
  echo [new-note] failed. See the error above.
  pause
)
