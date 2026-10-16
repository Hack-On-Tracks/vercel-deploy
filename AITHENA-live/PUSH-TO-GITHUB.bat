@echo off
title Push AITHENA to GitHub (new branch)
cd /d "%~dp0"
setlocal

set REPO=https://github.com/Hack-On-Tracks/AITHENA.git
set BRANCH=live-multi-laptop-monitoring
set DEST=%TEMP%\aithena-push

echo ================================================================
echo   Push this AITHENA project to GitHub on a NEW branch:
echo   %BRANCH%
echo ================================================================
echo.

where git >nul 2>&1
if errorlevel 1 (
  echo  Git is not installed on this PC.
  echo  Install "Git for Windows":  https://git-scm.com/download/win
  echo  ^(or use GitHub Desktop instead^). Then run this file again.
  echo.
  pause
  exit /b
)

echo Cloning your repository...
rmdir /s /q "%DEST%" 2>nul
git clone %REPO% "%DEST%"
if errorlevel 1 (
  echo.
  echo  Clone failed. If you were asked to sign in to GitHub, complete it and run again.
  pause
  exit /b
)

echo Copying project files into the clone...
rem Exclude: the clone's own .git, temp/delete folders, logs, zips, this script,
rem and (critically) the per-device agent configs which contain secrets.
robocopy "%~dp0." "%DEST%" /E /XD .git _to_delete node_modules /XF *.log *.zip PUSH-TO-GITHUB.bat >nul
del /q "%DEST%\agent-config.self.json" "%DEST%\agent-config.friend.json" "%DEST%\agent-config.*.json" 2>nul
rmdir /s /q "%DEST%\server\data" 2>nul

cd /d "%DEST%"
git checkout -b %BRANCH%
git add -A
git -c user.name="%USERNAME%" -c user.email="geocey@gmail.com" commit -m "Add live multi-laptop monitoring (server, agent, wall, topology, tests)" -m "Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"

echo.
echo Pushing branch "%BRANCH%" to GitHub...
git push -u origin %BRANCH%
if errorlevel 1 (
  echo.
  echo  Push failed. A sign-in window may have appeared - complete it, then run this again.
  echo  ^(This repo is yours, so your GitHub login has push access.^)
  pause
  exit /b
)

echo.
echo ================================================================
echo   DONE.  Your branch is live at:
echo   https://github.com/Hack-On-Tracks/AITHENA/tree/%BRANCH%
echo ================================================================
echo.
pause
