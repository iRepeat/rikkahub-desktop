@echo off
setlocal
REM Wrapper that activates MSVC + uses an ASCII target dir, then runs any tauri command.
REM Workaround for two Windows dev quirks:
REM   1. cargo needs MSVC's link.exe; Git Bash's PATH otherwise resolves link to coreutils.
REM   2. CARGO_TARGET_DIR lives outside the project path because the project path contains
REM      non-ASCII characters and some build scripts mishandle that.
REM Auto-detect installed VS 2022 edition (BuildTools / Community / Pro / Enterprise).
for %%E in (BuildTools Community Professional Enterprise) do (
  if exist "C:\Program Files\Microsoft Visual Studio\2022\%%E\VC\Auxiliary\Build\vcvars64.bat" (
    call "C:\Program Files\Microsoft Visual Studio\2022\%%E\VC\Auxiliary\Build\vcvars64.bat" > nul
    goto :vc_ok
  )
)
echo Failed to activate MSVC build tools. Is Visual Studio 2022 installed with the C++ workload?
exit /b 1
:vc_ok
REM vcvars resets PATH; restore cargo + bun on top so the Tauri CLI can find them.
set "PATH=%USERPROFILE%\.cargo\bin;%USERPROFILE%\.bun\bin;%PATH%"
set CARGO_TARGET_DIR=C:\rikkahub-build
cd /d "%~dp0\.."
bun run tauri %*
exit /b %errorlevel%

