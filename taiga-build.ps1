
# Location of vcvarsall.bat (for compiling libcurl)
$vs = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"
# Location of msbuild (for compiling Taiga)
$msbuild = "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe"
# Location of Taiga source code
$taiga = "$env:USERPROFILE\Documents\Git\taiga"

$dir = $PSScriptRoot

# Setup config
$quickBuild = read-host "[Script] Quick build?"
if ($quickBuild -eq "yes" -or $quickBuild -eq "y") {
    $release = "release"
    $build = "build"
    $openBuild = "yes"
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
cd $taiga\deps\src\curl\winbuild
Invoke-BatchFile $vs

if ($build -eq "rebuild") {
    Remove-Item -Recurse -Force ..\builds
}

write-output "[Script] Building libcurl ($release)..."
if ($release -eq "debug") { nmake /f Makefile.vc mode=static RTLIBCFG=static VC=14 DEBUG=yes }
else { nmake /f Makefile.vc mode=static RTLIBCFG=static VC=14 }
write-output "`n[Script] Build finished."
write-output "[Script] Copying $release library..."
robocopy /s /is ..\builds\libcurl-vc14-x86-$release-static-ipv6-sspi-winssl\lib $taiga\deps\lib
write-output "[Script] Copy complete.`n"

cd $dir

# Compiling Taiga
write-output "[Script] Building Taiga...`n"
if ($msbuild) { & $msbuild $taiga\project\vs2015\Taiga.vcxproj /t:$build /p:Configuration=$release }
else { msbuild $taiga\project\vs2015\Taiga.vcxproj /t:$build /p:Configuration=$release }
write-output "`n[Script] Build finished."

if (!($openBuild)) {
    $openBuild = read-host "[Script] Would you like to open the builds folder?"
}
if ($openBuild -eq "yes" -or $openBuild -eq "y") {
    Invoke-Item $taiga\bin\$release
}

read-host -prompt "`n[Script] Press enter to exit"
