# Find Visual Studio install path using VSSetup
$VsPath = (Get-VSSetupInstance | Select-VSSetupInstance -Version 16.0).InstallationPath
# Location of vcvars32.bat (for compiling libcurl)
$VcVars = "$VsPath\VC\Auxiliary\Build\vcvars32.bat"
# Location of MsBuild (for compiling Taiga)
$MsBuild = "$VsPath\MSBuild\Current\Bin\MSBuild.exe"
# Location of Taiga source code
$Source = "$env:USERPROFILE\Documents\GitHub\taiga"
# Location of Taiga installation
$Install = "$env:APPDATA\Taiga"

$Dir = Get-Location

function Invoke-BatchFile {
    param([string]$Path)
    $Temp = [IO.Path]::GetTempFileName()
    cmd.exe /c " `"$Path`" && set " > $Temp
    Get-Content $Temp | ForEach-Object {
        if ($_ -match "^(.*?)=(.*)$") {
            [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2])
        }
        else {
            $_
        }
    }
    Remove-Item $Temp
}

# Setup config
$QuickBuild = Read-Host "[taiga-build] Quick build?"
if ($QuickBuild -eq "yes" -or $QuickBuild -eq "y") {
    $Release = "release"
    $Build = "build"
    $CurlBuild = "no"
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
    $Build = Read-Host "[taiga-build] Rebuild source code? (yes|no|curl)"
    if ($Build -eq "yes" -or $Build -eq "y") {
        $Build = "rebuild"
        $CurlBuild = "no"
        Write-Output "[taiga-build] Rebuilding from source."
    } elseif ($Build -eq "no" -or $Build -eq "n") {
        $Build = "build"
        $CurlBuild = "no"
        Write-Output "[taiga-build] Building from source."
    } elseif ($Build -eq "curl") {
        $Build = "rebuild"
        $CurlBuild = "yes"
        Write-Output "[taiga-build] Rebuilding from source including curl."
    } else {
        $Build = "build"
        $CurlBuild = "no"
        Write-Output "[taiga-build] Defaulting to build from source."
    }
}

# Compiling libcurl
Set-Location $Source\deps\src\curl\winbuild
Invoke-BatchFile $VcVars
Invoke-BatchFile $Source\deps\src\curl\buildconf.bat

if ($CurlBuild -eq "yes") {
    if (Test-Path ..\builds) {
        Remove-Item -Recurse -Force ..\builds
    }
}

Write-Output "[taiga-build] Building libcurl ($Release)..."
if ($Release -eq "debug") {
    nmake /f Makefile.vc mode=static RTLIBCFG=static VC=16 MACHINE=x86 DEBUG=yes
}
else {
    nmake /f Makefile.vc mode=static RTLIBCFG=static VC=16 MACHINE=x86
}
Write-Output "`n[taiga-build] Build finished."
Write-Output "[taiga-build] Copying $Release library..."
robocopy /s /is ..\builds\libcurl-vc16-x86-$Release-static-ipv6-sspi-schannel\lib $Source\deps\lib
Write-Output "[taiga-build] Copy complete.`n"

Set-Location $Dir

# Compiling Taiga
Write-Output "[taiga-build] Building Taiga...`n"
if ($MsBuild) {
    & $MsBuild $Source\project\vs2019\Taiga.vcxproj /t:$Build /p:Configuration=$Release
}
else {
    MSBuild $Source\project\vs2019\Taiga.vcxproj /t:$Build /p:Configuration=$Release
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
Set-Location $Dir
