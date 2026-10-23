@echo off
REM TFCam 0.8.0+ (branch ng67): CommonLibSSE-NG built from the pinned submodule extern\CommonLibSSE-NG. See BUILD.md.
REM VS2022 Community (14.44) environment; the overlay triplet in cmake\ pins vcpkg deps to the same 14.44 toolset.
REM Configures build\ng\release on first run, then builds. POST_BUILD copies TFCam.dll into
REM %SKYRIM_MODS_FOLDER%\FreeCam--Claude, so never run this while the game is running.
set "VS22=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat"
set "VS18=C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvarsall.bat"
if exist "%VS22%" (
    call "%VS22%" amd64
) else if exist "%VS18%" (
    REM Visual Studio 18 ships the 14.44 toolset side by side; keep the compiler at 14.44 as BUILD.md pins it.
    call "%VS18%" amd64 -vcvars_ver=14.44
) else (
    echo === no Visual Studio 2022 or 18 found ===
    exit /b 1
)
set VCPKG_ROOT=C:\vcpkg
cd /d %~dp0
if not exist extern\CommonLibSSE-NG\cmake\CommonLibSSE.cmake (
    echo === extern\CommonLibSSE-NG missing: git submodule update --init --recursive --depth 1 ===
    exit /b 1
)
REM 0.14.1: optional first argument = runtime variant: ALL (default, build\ng\release), SE, AE or VR (build\ng\release-se ...).
set "VARIANT=%~1"
if "%VARIANT%"=="" set "VARIANT=ALL"
set "BDIR=build\ng\release"
if /i not "%VARIANT%"=="ALL" set "BDIR=build\ng\release-%VARIANT%"
if not exist %BDIR%\build.ninja (
    echo === CONFIGURING %VARIANT% ===
    cmake --preset release -B %BDIR% -DTFCAM_RUNTIME=%VARIANT%
    if errorlevel 1 ( echo === CONFIGURE FAILED === & exit /b 1 )
)
echo === BUILDING %VARIANT% ===
cmake --build %BDIR%
if errorlevel 1 ( echo === BUILD FAILED === & exit /b 1 )
echo === BUILD SUCCEEDED (%VARIANT%: %BDIR%\TFCam.dll) ===
