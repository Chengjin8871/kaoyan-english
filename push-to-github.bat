@echo off
setlocal enabledelayedexpansion

rem ============================================================
rem  One-click push for the "kaoyan-english" GitHub repository
rem  Repo : https://github.com/Chengjin8871/kaoyan-english
rem  Usage: double click this file (it pushes its own folder)
rem  NOTE : keep this file pure ASCII (system codepage is 936)
rem ============================================================

cd /d "%~dp0"

echo ============================================================
echo   Kaoyan English - one click push to GitHub
echo   Folder: %~dp0
echo   Repo  : https://github.com/Chengjin8871/kaoyan-english
echo ============================================================
echo.

where git >nul 2>&1
if errorlevel 1 (
  echo [ERROR] git was not found in PATH. Install Git for Windows first.
  goto :end
)

if not exist ".git" (
  echo [ERROR] This folder is not a git repository:
  echo         %~dp0
  goto :end
)

rem GitHub SSH is reachable only on port 443 on this machine.
set "GIT_SSH_COMMAND=ssh -p 443 -o StrictHostKeyChecking=accept-new"

echo [1/3] Staging all changes ...
git add -A
if errorlevel 1 (
  echo [ERROR] git add failed.
  goto :end
)

git diff --cached --quiet
if not errorlevel 1 (
  echo [2/3] Committing ... skipped, nothing new.
  goto :push
)

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HH:mm:ss"') do set "TS=%%i"
if "%TS%"=="" set "TS=manual-update"

echo [2/3] Committing ... %TS%
git commit -m "auto: update study material %TS%"
if errorlevel 1 (
  echo [ERROR] git commit failed.
  goto :end
)
goto :push

:push
echo [3/3] Pushing to GitHub ...
git push origin main
if errorlevel 1 (
  echo.
  echo [ERROR] Push failed.
  echo   - If the remote has newer commits, run:
  echo       git pull --rebase origin main
  echo     then run this script again.
  echo   - If it is an SSH/network problem, check that the port 443 SSH
  echo     key works:  ssh -p 443 -T git@github.com
  goto :end
)

echo.
echo [OK] Push finished. Latest commit:
git log --oneline -1
echo.
echo Repo: https://github.com/Chengjin8871/kaoyan-english

:end
echo.
pause
endlocal
