@echo off
:: bootstrap.bat — Download VS Code and install ACB extensions on a clean Windows machine.
:: Called automatically by setup.bat when VS Code is not found in its default location.
:: Requires internet access and PowerShell (built into Windows 7+).
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "ROOT=%SCRIPT_DIR%.."
pushd "%ROOT%"
set "ROOT=%CD%"
popd

set "PORTABLE_APP=%ROOT%\VSCode"
set "DATA_DIR=%ROOT%\code-portable-data"
set "CODE_CMD=%PORTABLE_APP%\bin\code.cmd"
set "VSCODE_URL=https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-archive"
set "TMP_ZIP=%TEMP%\acb-wingman-vscode.zip"

echo.

:: ── Connectivity check ────────────────────────────────────────────────────────
echo ^>  Checking internet connectivity...
powershell -Command "try { Invoke-WebRequest -Uri 'https://code.visualstudio.com' -UseBasicParsing -TimeoutSec 5 | Out-Null; exit 0 } catch { exit 1 }" >nul 2>&1
if errorlevel 1 (
    echo X  No internet access. Connect to the network and try again.
    exit /b 1
)
echo V  Network reachable.

:: ── Download VS Code (zip archive — no installer needed) ─────────────────────
echo ^>  Downloading VS Code for Windows (64-bit archive)...
echo    This may take a minute...
powershell -Command "Invoke-WebRequest -Uri '%VSCODE_URL%' -OutFile '%TMP_ZIP%' -UseBasicParsing"
if errorlevel 1 (
    echo X  Download failed.
    exit /b 1
)
echo V  Download complete.

:: ── Unpack ────────────────────────────────────────────────────────────────────
echo ^>  Unpacking VS Code into project...
if not exist "%PORTABLE_APP%" mkdir "%PORTABLE_APP%"
powershell -Command "Expand-Archive -Path '%TMP_ZIP%' -DestinationPath '%PORTABLE_APP%' -Force"
if errorlevel 1 (
    echo X  Unzip failed.
    exit /b 1
)
del /Q "%TMP_ZIP%" 2>nul

if not exist "%PORTABLE_APP%\Code.exe" (
    echo X  Unzip succeeded but Code.exe not found in %PORTABLE_APP%. Check disk space.
    exit /b 1
)
echo V  VS Code unpacked.

:: ── Create portable data dirs ─────────────────────────────────────────────────
:: On Windows, portable mode requires a "data" folder INSIDE the app folder.
if not exist "%PORTABLE_APP%\data" mkdir "%PORTABLE_APP%\data"
if not exist "%DATA_DIR%\extensions" mkdir "%DATA_DIR%\extensions"
if not exist "%DATA_DIR%\user-data\User" mkdir "%DATA_DIR%\user-data\User"
echo V  Portable data directory ready.

:: ── Install ACB extensions via CLI ───────────────────────────────────────────
echo ^>  Installing ACB extensions (requires internet -- may take several minutes)...
"%CODE_CMD%" ^
    --extensions-dir "%DATA_DIR%\extensions" ^
    --user-data-dir  "%DATA_DIR%\user-data" ^
    --install-extension salesforce.mule-dx-extension-pack
if errorlevel 1 (
    echo X  Extension install failed. Check your internet connection and try again.
    exit /b 1
)

:: Verify the pack landed
set "PACK_FOUND=0"
for /D %%D in ("%DATA_DIR%\extensions\salesforce.mule-dx-extension-pack-*") do set "PACK_FOUND=1"
if "%PACK_FOUND%"=="0" (
    echo X  Extension install appears to have failed -- pack not found in %DATA_DIR%\extensions.
    exit /b 1
)
echo V  ACB extensions installed.

:: ── Write baseline settings ───────────────────────────────────────────────────
(
echo {
echo   "telemetry.telemetryLevel": "off",
echo   "update.mode": "none",
echo   "extensions.autoUpdate": false,
echo   "extensions.autoCheckUpdates": false,
echo   "workbench.startupEditor": "none",
echo   "editor.fontSize": 14,
echo   "editor.tabSize": 2,
echo   "files.autoSave": "onFocusChange"
echo }
) > "%DATA_DIR%\user-data\User\settings.json"
echo V  Baseline settings written.

echo ^>  Bootstrap complete -- returning to setup.
endlocal
