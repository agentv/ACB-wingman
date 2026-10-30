@echo off
:: setup.bat — First-time setup for ACB-wingman portable VS Code (Windows)
:: Run once to build the portable environment and bake a clean snapshot.
setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "ROOT=%SCRIPT_DIR%.."

:: Resolve ROOT to an absolute path without trailing backslash
pushd "%ROOT%"
set "ROOT=%CD%"
popd

set "VSCODE_SRC=%LOCALAPPDATA%\Programs\Microsoft VS Code"
set "PORTABLE_APP=%ROOT%\VSCode"
set "DATA_DIR=%ROOT%\code-portable-data"
set "SNAPSHOT_DIR=%ROOT%\snapshots\clean"
set "VSCODE_EXT_SRC=%USERPROFILE%\.vscode\extensions"

:: ACB extension prefixes to copy
set ACB_EXTENSIONS=salesforce.mule-dx-extension-pack salesforce.mule-dx-vscode salesforce.mule-dx-mule-dev-component salesforce.mule-dx-runtime salesforce.mule-dx-api-component salesforce.mule-dx-apikit-component salesforce.mule-dx-data-weave-client salesforce.mule-dx-dependencies salesforce.mule-dx-munit-component

echo.

:: ── 1. Copy VS Code (if not already present) ─────────────────────────────────
if exist "%PORTABLE_APP%\Code.exe" (
    echo ^>  Portable VS Code already present, skipping copy.
) else (
    echo ^>  Copying VS Code from %VSCODE_SRC% ...
    if not exist "%VSCODE_SRC%\Code.exe" (
        echo X  VS Code not found at %VSCODE_SRC%.
        echo    Download from https://code.visualstudio.com and install, then re-run.
        exit /b 1
    )
    xcopy /E /I /Q /Y "%VSCODE_SRC%" "%PORTABLE_APP%" >nul
    if errorlevel 1 (
        echo X  Failed to copy VS Code.
        exit /b 1
    )
    echo V  VS Code copied.
)

:: ── 2. Create portable data dir (activates portable mode) ────────────────────
if not exist "%PORTABLE_APP%\data\extensions" mkdir "%PORTABLE_APP%\data\extensions"
if not exist "%PORTABLE_APP%\data\user-data\User" mkdir "%PORTABLE_APP%\data\user-data\User"
echo V  Portable data directory ready.

:: On Windows, portable mode uses a "data" folder INSIDE the app folder.
:: We keep code-portable-data for the snapshot/reset workflow and sync on launch.
if not exist "%DATA_DIR%\extensions" mkdir "%DATA_DIR%\extensions"
if not exist "%DATA_DIR%\user-data\User" mkdir "%DATA_DIR%\user-data\User"

:: ── 3. Copy ACB extensions from local VS Code install ────────────────────────
echo ^>  Copying ACB extensions from %VSCODE_EXT_SRC% ...
set /a COPIED=0

for %%E in (%ACB_EXTENSIONS%) do (
    for /D %%D in ("%VSCODE_EXT_SRC%\%%E-*") do (
        set "EXTNAME=%%~nxD"
        set "DEST=%DATA_DIR%\extensions\!EXTNAME!"
        if exist "!DEST!" (
            echo ^!    Already present: !EXTNAME!
        ) else (
            xcopy /E /I /Q /Y "%%D" "!DEST!" >nul
            if errorlevel 1 (
                echo X    Failed to copy: !EXTNAME!
            ) else (
                echo V    Copied: !EXTNAME!
                set /a COPIED+=1
            )
        )
    )
)
echo ^>  Extensions copied: %COPIED%

:: ── 4. Write baseline VS Code settings ───────────────────────────────────────
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

:: ── 5. Sync data dir into portable app data folder ───────────────────────────
xcopy /E /I /Q /Y "%DATA_DIR%\extensions" "%PORTABLE_APP%\data\extensions" >nul
xcopy /E /I /Q /Y "%DATA_DIR%\user-data"  "%PORTABLE_APP%\data\user-data"  >nul
echo V  Portable app data synced.

:: ── 6. Bake the clean snapshot ────────────────────────────────────────────────
echo ^>  Baking clean snapshot to %SNAPSHOT_DIR% ...
if not exist "%SNAPSHOT_DIR%" mkdir "%SNAPSHOT_DIR%"
if exist "%SNAPSHOT_DIR%\extensions" rmdir /S /Q "%SNAPSHOT_DIR%\extensions"
if exist "%SNAPSHOT_DIR%\user-data"  rmdir /S /Q "%SNAPSHOT_DIR%\user-data"
xcopy /E /I /Q /Y "%DATA_DIR%\extensions" "%SNAPSHOT_DIR%\extensions" >nul
xcopy /E /I /Q /Y "%DATA_DIR%\user-data"  "%SNAPSHOT_DIR%\user-data"  >nul
echo V  Clean snapshot saved.

echo.
echo ===================================================
echo  Setup complete.
echo  Launch:  bin\launch.bat
echo  Reset:   bin\reset.bat
echo ===================================================
endlocal
