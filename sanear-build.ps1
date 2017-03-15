# Location of sanear source code
$source = "$env:USERPROFILE\Documents\Git\sanear"
# Location of MsBuild
$msbuild = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe"

$dir = $PSScriptRoot

# Setup config
$quickBuild = read-host "[Script] Quick build?"
if ($quickBuild -eq "yes" -or $quickBuild -eq "y") {
    $release = "release"
    $build = "build"
    $platform = "x64"
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

if (!($platform)) {
    $platform = read-host "[Script] Architecture? (Win32|x64)"
    if ($platform -eq "Win32" -or $platform -eq "x86") {
        $platform = "Win32"
        write-output "[Script] Using Win32 config."
    } elseif ($platform -eq "Win64" -or $platform -eq "x64") {
        $platform = "x64"
        write-output "[Script] Using x64 config."
    } else {
        $platform = "x64"
        write-output "[Script] Defaulting to x64."
    }
}

# Compiling sanear
write-output "[Script] Building sanear...`n"
if ($msbuild) { & $msbuild $source\dll\sanear-dll.sln /t:$build /p:Configuration=$release /p:Platform=$platform }
else { msbuild $source\dll\sanear-dll.sln /t:$build /p:Configuration=$release /p:Platform=$platform }
write-output "`n[Script] Build finished."

read-host -prompt "`n[Script] Press enter to exit"
cd $dir
