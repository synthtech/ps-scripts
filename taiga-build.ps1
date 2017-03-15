
# Location of VsDevCmd.bat (for compiling libcurl)
$vs = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat"
# Location of MsBuild (for compiling Taiga)
$msbuild = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe"
# Location of Taiga source code
$source = "$env:USERPROFILE\Documents\Git\taiga"
# Location of Taiga installation
$install = "$env:APPDATA\Taiga"

$dir = $PSScriptRoot

# Setup config
$quickBuild = read-host "[Script] Quick build?"
if ($quickBuild -eq "yes" -or $quickBuild -eq "y") {
    $release = "release"
    $build = "build"
    $copyBuild = "yes"
}

if (!($release)) {
    $release = read-host "[Script] Build configuration? (release|debug)"
    if ($release -eq "release" -or $release -eq "r") {
        $release = "release"
        write-output "[Script] Using release config."
    } elseif ($release -eq "debug" -or $release -eq "d") {
        $release = "debug"
        write-output "[Script] Using debug config."
    } else {
        $release = "release"
        write-output "[Script] Defaulting to release config."
    }
}

if (!($build)) {
    $build = read-host "[Script] Rebuild source code? (yes|no)"
    if ($build -eq "yes" -or $build -eq "y") {
        $build = "rebuild"
        write-output "[Script] Rebuilding from source."
    } elseif ($build -eq "no" -or $build -eq "n") {
        $build = "build"
        write-output "[Script] Building from source."
    } else {
        $build = "build"
        write-output "[Script] Defaulting to build from source."
    }
}

# Compiling libcurl
cd $source\deps\src\curl\winbuild
Invoke-BatchFile $vs

if ($build -eq "rebuild") {
    Remove-Item -Recurse -Force ..\builds
}

write-output "[Script] Building libcurl ($release)..."
if ($release -eq "debug") { nmake /f Makefile.vc mode=static RTLIBCFG=static VC=15 DEBUG=yes }
else { nmake /f Makefile.vc mode=static RTLIBCFG=static VC=15 }
write-output "`n[Script] Build finished."
write-output "[Script] Copying $release library..."
robocopy /s /is ..\builds\libcurl-vc15-x86-$release-static-ipv6-sspi-winssl\lib $source\deps\lib
write-output "[Script] Copy complete.`n"

cd $dir

# Compiling Taiga
write-output "[Script] Building Taiga...`n"
if ($msbuild) { & $msbuild $source\project\vs2017\Taiga.vcxproj /t:$build /p:Configuration=$release }
else { msbuild $source\project\vs2017\Taiga.vcxproj /t:$build /p:Configuration=$release }
write-output "`n[Script] Build finished."

if (!($copyBuild)) {
    $copyBuild = read-host "[Script] Would you like to copy the build to your Taiga folder?"
}
if ($copyBuild -eq "yes" -or $copyBuild -eq "y") {
    Copy-Item $source\bin\$release\Taiga.exe -destination $install
}

read-host -prompt "`n[Script] Press enter to exit"
