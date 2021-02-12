# Find Visual Studio install path using VSSetup
$VsPath = (Get-VSSetupInstance | Select-VSSetupInstance -Version 16.0).InstallationPath
# Location of vcvars64.bat (for compiling libcurl)
$VcVars = "$VsPath\VC\Auxiliary\Build\vcvars64.bat"
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
$QuickBuild = Read-Host "[Taiga] Quick build?"
if ($QuickBuild -eq "yes" -or $QuickBuild -eq "y") {
    $Release = "release"
    $Build = "build"
    $CurlBuild = "no"
    $CopyBuild = "yes"
}

if (!($Release)) {
    $Release = Read-Host "[Taiga] Build configuration? (release|debug)"
    if ($Release -eq "release" -or $Release -eq "r") {
        $Release = "release"
        Write-Output "[Taiga] Using release config."
    } elseif ($Release -eq "debug" -or $Release -eq "d") {
        $Release = "debug"
        Write-Output "[Taiga] Using debug config."
    } else {
        $Release = "release"
        Write-Output "[Taiga] Defaulting to release config."
    }
}

if (!($Build)) {
    $Build = Read-Host "[Taiga] Rebuild source code? (yes|no|curl)"
    if ($Build -eq "yes" -or $Build -eq "y") {
        $Build = "rebuild"
        $CurlBuild = "no"
        Write-Output "[Taiga] Rebuilding from source."
    } elseif ($Build -eq "no" -or $Build -eq "n") {
        $Build = "build"
        $CurlBuild = "no"
        Write-Output "[Taiga] Building from source."
    } elseif ($Build -eq "curl") {
        $Build = "rebuild"
        $CurlBuild = "yes"
        Write-Output "[Taiga] Rebuilding from source including curl."
    } else {
        $Build = "build"
        $CurlBuild = "no"
        Write-Output "[Taiga] Defaulting to build from source."
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

Write-Output "[Taiga] Building libcurl ($Release)..."
if ($Release -eq "debug") {
    nmake /f Makefile.vc mode=static RTLIBCFG=static VC=16 MACHINE=x64 DEBUG=yes
}
else {
    nmake /f Makefile.vc mode=static RTLIBCFG=static VC=16 MACHINE=x64
}
Write-Output "`n[Taiga] Build finished."
Write-Output "[Taiga] Copying $Release library..."
robocopy /s /is ..\builds\libcurl-vc16-x64-$Release-static-ipv6-sspi-schannel\lib $Source\deps\lib\x64
Write-Output "[Taiga] Copy complete.`n"

Set-Location $Dir

# Compiling Taiga
Write-Output "[Taiga] Building Taiga...`n"
if ($MsBuild) {
    & $MsBuild $Source\project\vs2019\Taiga.vcxproj /t:$Build /p:Configuration=$Release /p:Platform=x64
}
else {
    MSBuild $Source\project\vs2019\Taiga.vcxproj /t:$Build /p:Configuration=$Release /p:Platform=x64
}
Write-Output "`n[Taiga] Build finished."

# Copy executable
if (!($CopyBuild)) {
    $CopyBuild = Read-Host "[Taiga] Would you like to copy the build to your Taiga folder?"
}
if ($CopyBuild -eq "yes" -or $CopyBuild -eq "y") {
    if (Get-Process taiga -ErrorAction SilentlyContinue) {
        Stop-Process -Name taiga -Force
    }
    Copy-Item $Source\bin\x64\$Release\Taiga.exe -Destination $Install
}

Read-Host -Prompt "`n[Taiga] Press any key to exit"
Set-Location $Dir
