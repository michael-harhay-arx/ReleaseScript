@set CVIDIR=c:\program files (x86)\national instruments\cvi2019
@set CVISHAREDDIR=C:\Program Files (x86)\National Instruments\Shared\CVI
@set CVIPUBDOCSDIR=C:\Users\Public\Documents\National Instruments\CVI
@set CVIPROJPATH=c:\Arxtron\RD25XXX_CICD\Source\TestLib.prj
@set CVIPROJDIR=c:\Arxtron\RD25XXX_CICD\Source
@set CVIPROJNAME=TestLib.prj
@set CVITARGETPATH=c:\Arxtron\RD25XXX_CICD\Source\TestLib.dll
@set CVITARGETDIR=c:\Arxtron\RD25XXX_CICD\Source
@set CVITARGETNAME=TestLib.dll
@set CVIBUILDCONFIG=Release
@set CVITARGETFILEVER=2.0.0.3
@set CVITARGETPRODVER=0.0.0.0
@set CVIVXIPNPDIR=C:\Program Files (x86)\IVI Foundation\VISA\winnt
@set CVIIVIDIR=C:\Program Files (x86)\IVI Foundation\IVI
@set CVIWINDIR=C:\WINDOWS
@set CVISYSDIR=C:\WINDOWS\system32
@pushd "c:\Arxtron\RD25XXX_CICD\Source"
@setlocal
@set _some_build_step_failed=0
copy "%CVITARGETDIR%\*.dll" "C:\Arxtron\Libraries\"
@if %errorlevel% neq 0 (@set _some_build_step_failed=1)
copy "%CVITARGETDIR%\*.lib" "C:\Arxtron\Libraries\"
@if %errorlevel% neq 0 (@set _some_build_step_failed=1)
copy "%CVITARGETDIR%\*.h" "C:\Arxtron\Libraries\"
@if %errorlevel% neq 0 (@set _some_build_step_failed=1)
@exit /b %_some_build_step_failed%
