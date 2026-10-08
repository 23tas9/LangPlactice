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
rem Walk up from the file to the folder that has pubspec.yaml (the Flutter project root).
set "dir=%~dp1"
:find_pubspec
if exist "%dir%pubspec.yaml" goto :run_flutter
for %%I in ("%dir%..") do set "parent=%%~fI"
if not "%parent:~-1%"=="\" set "parent=%parent%\"
if /i "%parent%"=="%dir%" (
    echo pubspec.yaml was not found above "%~1".
    goto :end
)
set "dir=%parent%"
goto :find_pubspec

:run_flutter
cd /d "%dir%"
call flutter run -d windows
goto :end

:end
echo.