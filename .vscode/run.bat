@echo off
rem This file made with claude code.

rem Called from launch.json on F5. Runs the active file according to its extension.
rem   %1 = full path of the active file
rem Keep this file ASCII only: cmd reads it in the console code page.

setlocal

if "%~1"=="" (
    echo No file was passed to run.bat.
    goto :end
)

if /i "%~x1"==".cpp" goto :cpp
if /i "%~x1"==".dart" goto :dart

echo No run rule for "%~x1" files. Add one to .vscode\run.bat.
goto :end


:cpp
g++ "%~1" -o "%~dpn1.out" -std=c++2b || goto :end
rem Run in a new console window so that the program can read keyboard input.
start "%~nx1" /wait cmd /c ""%~dpn1.out" & pause"
goto :end


:dart
rem launch.json (serverReadyAction) watches for this line and starts the "Flutter"
rem debug configuration, so Flutter runs under the Dart debugger with hot reload.
echo [run.bat] start Flutter debugging
goto :end

:end
echo.