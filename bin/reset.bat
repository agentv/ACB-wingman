@echo off
:: reset.bat — Wipe and restore the portable data dir from the clean snapshot.
:: Run between class sessions to get back to a known-good state.
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "ROOT=%SCRIPT_DIR%.."
pushd "%ROOT%"
set "ROOT=%CD%"
popd

set "PORTABLE_APP=%ROOT%\VSCode"
set "DATA_DIR=%ROOT%\code-portable-data"
set "SNAPSHOT_DIR=%ROOT%\snapshots\clean"

echo.

:: Guard: check snapshot exists
if not exist "%SNAPSHOT_DIR%\extensions" (
    echo X  No clean snapshot found. Run bin\setup.bat first.
    exit /b 1
)

:: Guard: make sure VS Code isn't running
tasklist /FI "IMAGENAME eq Code.exe" 2>nul | find /I "Code.exe" >nul
if not errorlevel 1 (
    echo X  VS Code is running. Close it before resetting.
    exit /b 1
)

echo ^>  Resetting portable data dir from clean snapshot...

:: Restore code-portable-data
if exist "%DATA_DIR%\extensions" rmdir /S /Q "%DATA_DIR%\extensions"
if exist "%DATA_DIR%\user-data"  rmdir /S /Q "%DATA_DIR%\user-data"
xcopy /E /I /Q /Y "%SNAPSHOT_DIR%\extensions" "%DATA_DIR%\extensions" >nul
xcopy /E /I /Q /Y "%SNAPSHOT_DIR%\user-data"  "%DATA_DIR%\user-data"  >nul

:: Sync back into the portable app data folder
if exist "%PORTABLE_APP%\data\extensions" rmdir /S /Q "%PORTABLE_APP%\data\extensions"
if exist "%PORTABLE_APP%\data\user-data"  rmdir /S /Q "%PORTABLE_APP%\data\user-data"
xcopy /E /I /Q /Y "%DATA_DIR%\extensions" "%PORTABLE_APP%\data\extensions" >nul
xcopy /E /I /Q /Y "%DATA_DIR%\user-data"  "%PORTABLE_APP%\data\user-data"  >nul

echo V  Reset complete. Environment is clean.
echo.
echo    Launch with: bin\launch.bat
endlocal
