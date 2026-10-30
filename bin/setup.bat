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

:: ── 1. Get VS Code ───────────────────────────────────────────────────────────
if exist "%PORTABLE_APP%\Code.exe" (
    echo ^>  Portable VS Code already present, skipping.
) else if exist "%VSCODE_SRC%\Code.exe" (
    echo ^>  Copying VS Code from %VSCODE_SRC% ...
    xcopy /E /I /Q /Y "%VSCODE_SRC%" "%PORTABLE_APP%" >nul
    if errorlevel 1 (
        echo X  Failed to copy VS Code.
        exit /b 1
    )
    echo V  VS Code copied.
) else (
    echo ^>  VS Code not found -- running bootstrap to download it...
    call "%SCRIPT_DIR%bootstrap.bat"
    if errorlevel 1 exit /b 1
)

:: ── 2. Create portable data dir (activates portable mode) ────────────────────
if not exist "%PORTABLE_APP%\data\extensions" mkdir "%PORTABLE_APP%\data\extensions"
if not exist "%PORTABLE_APP%\data\user-data\User" mkdir "%PORTABLE_APP%\data\user-data\User"
echo V  Portable data directory ready.

:: On Windows, portable mode uses a "data" folder INSIDE the app folder.
:: We keep code-portable-data for the snapshot/reset workflow and sync on launch.
if not exist "%DATA_DIR%\extensions" mkdir "%DATA_DIR%\extensions"
if not exist "%DATA_DIR%\user-data\User" mkdir "%DATA_DIR%\user-data\User"

:: ── 3. Copy ACB extensions from local install (if not already present) ────────
set "PACK_FOUND=0"
for /D %%D in ("%DATA_DIR%\extensions\salesforce.mule-dx-*") do set "PACK_FOUND=1"

if "%PACK_FOUND%"=="1" (
    echo ^>  Extensions already present (installed by bootstrap^), skipping copy.
) else if exist "%VSCODE_EXT_SRC%" (
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
    echo ^>  Extensions copied: !COPIED!
) else (
    echo X  No extensions in portable dir and no local VS Code extensions found.
    echo    Run bin\bootstrap.bat manually or install VS Code with ACB extensions first.
    exit /b 1
)

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
