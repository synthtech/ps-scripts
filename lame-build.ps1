# Location of vcvars32.bat
$VcVars = "${env:PROGRAMFILES(X86)}\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"

$Dir = $PSScriptRoot


Invoke-BatchFile $VcVars
Invoke-BatchFile lame.bat

Write-Output "[lame-build] Building LAME..."
copy configMS.h config.h
nmake /f Makefile.MSVC VC=15 MACHINE=x64
Write-Output "`n[lame-build] Build finished."

Set-Location $Dir

Read-Host -Prompt "`n[lame-build] Press any key to exit"
