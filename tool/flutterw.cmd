@echo off
setlocal

set "FLUTTER_ROOT=C:\flutter"
set "DART=%FLUTTER_ROOT%\bin\cache\dart-sdk\bin\dart.exe"
set "TOOL=%FLUTTER_ROOT%\packages\flutter_tools\bin\flutter_tools.dart"

if not exist "%DART%" (
  echo Dart SDK not found at %DART%
  exit /b 1
)

if not exist "%TOOL%" (
  echo Flutter tool entrypoint not found at %TOOL%
  exit /b 1
)

"%DART%" "%TOOL%" %*
exit /b %ERRORLEVEL%
