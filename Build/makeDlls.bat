@echo off
setlocal

%TB-PLATFORM-PROJECTS-DRIVE%
path %TB-PLATFORM-PROJECTS-DRIVE%%TB-PLATFORM-PROJECTS-PATH%\Build\Subscripts;%PATH%

set BIN-PATH=%TB-PLATFORM-PROJECTS-PATH%\Bin

call setMyVersion.bat

call makeComponents.bat B

call makeTradeBuildPlatformAssemblyManifest.bat
call makeTradeBuildServiceProvidersAssemblyManifest.bat