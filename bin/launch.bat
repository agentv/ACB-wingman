@echo off
:: launch.bat — Open the portable ACB VS Code instance.
:: Pass an optional path as the first argument to open a specific folder.
setlocal

set "SCRIPT_DIR=%~dp0"
set "ROOT=%SCRIPT_DIR%.."
pushd "%ROOT%"
set "ROOT=%CD%"
popd

set "PORTABLE_APP=%ROOT%\VSCode"
set "DATA_DIR=%ROOT%\code-portable-data"
set "CODE_EXE=%PORTABLE_APP%\Code.exe"

if "%~1"=="" (
    set "WORKSPACE=%ROOT%\workspace-template"
) else (
    set "WORKSPACE=%~1"
)

if not exist "%CODE_EXE%" (
    echo X  Portable VS Code not found. Run bin\setup.bat first.
    exit /b 1
)
if not exist "%DATA_DIR%" (
    echo X  Portable data dir missing. Run bin\setup.bat first.
    exit /b 1
)

:: On Windows, portable mode is active when a "data" folder exists inside the
:: app folder — setup.bat creates it. We pass explicit flags as a belt-and-
:: suspenders guarantee, and to allow the data dir to live outside the app dir.
start "" "%CODE_EXE%" ^
    --user-data-dir "%DATA_DIR%\user-data" ^
    --extensions-dir "%DATA_DIR%\extensions" ^
    "%WORKSPACE%"
endlocal
