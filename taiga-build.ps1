# Location of vcvars32.bat (for compiling libcurl)
$VcVars = "${env:PROGRAMFILES(X86)}\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars32.bat"
# Location of MsBuild (for compiling Taiga)
$MsBuild = "${env:PROGRAMFILES(X86)}\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe"
# Location of Taiga source code
$Source = "$env:USERPROFILE\Documents\Git\taiga"
# Location of Taiga installation
$Install = "$env:APPDATA\Taiga"
# Windows version
$Platform = "10.0.17134.0"

$Dir = $PSScriptRoot

# Setup config
$QuickBuild = Read-Host "[taiga-build] Quick build?"
if ($QuickBuild -eq "yes" -or $QuickBuild -eq "y") {
    $Release = "release"
    $Build = "build"
    $CopyBuild = "yes"
}

if (!($Release)) {
    $Release = Read-Host "[taiga-build] Build configuration? (release|debug)"
    if ($Release -eq "release" -or $Release -eq "r") {
        $Release = "release"
        Write-Output "[taiga-build] Using release config."
    } elseif ($Release -eq "debug" -or $Release -eq "d") {
        $Release = "debug"
        Write-Output "[taiga-build] Using debug config."
    } else {
        $Release = "release"
        Write-Output "[taiga-build] Defaulting to release config."
    }
}

if (!($Build)) {
    $Build = Read-Host "[taiga-build] Rebuild source code? (yes|no)"
    if ($Build -eq "yes" -or $Build -eq "y") {
        $Build = "rebuild"
        Write-Output "[taiga-build] Rebuilding from source."
    } elseif ($Build -eq "no" -or $Build -eq "n") {
        $Build = "build"
        Write-Output "[taiga-build] Building from source."
    } else {
        $Build = "build"
        Write-Output "[taiga-build] Defaulting to build from source."
    }
}

# Compiling libcurl
Set-Location $Source\deps\src\curl\winbuild
Invoke-BatchFile $VcVars
Invoke-BatchFile $Source\deps\src\curl\buildconf.bat

if ($Build -eq "rebuild") {
    Remove-Item -Recurse -Force ..\builds
}

Write-Output "[taiga-build] Building libcurl ($Release)..."
if ($Release -eq "debug") {
    nmake /f Makefile.vc mode=static RTLIBCFG=static VC=15 MACHINE=x86 DEBUG=yes
}
else {
    nmake /f Makefile.vc mode=static RTLIBCFG=static VC=15 MACHINE=x86
}
Write-Output "`n[taiga-build] Build finished."
Write-Output "[taiga-build] Copying $Release library..."
robocopy /s /is ..\builds\libcurl-vc15-x86-$Release-static-ipv6-sspi-winssl\lib $Source\deps\lib
Write-Output "[taiga-build] Copy complete.`n"

Set-Location $Dir

# Compiling Taiga
Write-Output "[taiga-build] Building Taiga...`n"
if ($MsBuild) {
    & $MsBuild $Source\project\vs2017\Taiga.vcxproj /t:$Build /p:Configuration=$Release /p:WindowsTargetPlatformVersion=$Platform
}
else {
    MsBuild $Source\project\vs2017\Taiga.vcxproj /t:$Build /p:Configuration=$Release /p:WindowsTargetPlatformVersion=$Platform
}
Write-Output "`n[taiga-build] Build finished."

# Copy executable
if (!($CopyBuild)) {
    $CopyBuild = Read-Host "[taiga-build] Would you like to copy the build to your Taiga folder?"
}
if ($CopyBuild -eq "yes" -or $CopyBuild -eq "y") {
    if (Get-Process taiga -ErrorAction SilentlyContinue) {
        Stop-Process -Name taiga -Force
    }
    Copy-Item $Source\bin\$Release\Taiga.exe -Destination $Install
}

Read-Host -Prompt "`n[taiga-build] Press any key to exit"
