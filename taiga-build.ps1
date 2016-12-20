
# Location of vcvarsall.bat (for compiling libcurl)
$vs = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"
# Location of msbuild (for compiling Taiga)
$msbuild = "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe"
# Location of libcurl source code
$curl = "$env:USERPROFILE\Downloads\curl"
# Location of Taiga source code
$taiga = "$env:USERPROFILE\Documents\Git\taiga"


$dir = $PSScriptRoot

# Compiling libcurl
$buildCurl = read-host "[Script] Build libcurl?"
if ($buildCurl -eq "yes" -or $buildCurl -eq "y") {
    write-output "[Script] Building libcurl..."
    cd $curl\winbuild
    Invoke-BatchFile $vs
    nmake /f Makefile.vc mode=static RTLIBCFG=static VC=14
    write-output "`n[Script] Build finished."
    write-output "[Script] Copying library..."
    robocopy /s /is $curl\builds\libcurl-vc14-x86-release-static-ipv6-sspi-winssl\lib $taiga\deps\lib\
    write-output "[Script] Copy complete.`n"
    cd $dir
}

# Compiling Taiga
$release = read-host "[Script] Use Taiga's debug configuration?"
if ($release -eq "yes" -or $release -eq "y") {
    $release = "/p:Configuration=Debug"
    write-output "[Script] Using debug config."
} else {
    $release = "/p:Configuration=Release"
    write-output "[Script] Using release config."
}

$build = read-host "[Script] Rebuild Taiga from source?"
if ($build -eq "yes" -or $build -eq "y") {
    $build = "/t:Rebuild"
    write-output "[Script] Rebuilding from source."
} else {
    $build = "/t:Build"
    write-output "[Script] Building from source."
}

write-output "[Script] Building Taiga...`n"
if ($msbuild) {
    & $msbuild $taiga\project\vs2015\Taiga.vcxproj $build $release
} else {
    msbuild $taiga\project\vs2015\Taiga.vcxproj $build $release
}
write-output "`n[Script] Build finished."

$openBuild = read-host "[Script] Would you like to open the builds folder?"
if ($openBuild -eq "yes" -or $openBuild -eq "y") {
    if ($release -eq "/p:Configuration=Debug") {
        Invoke-Item $taiga\bin\Debug
    } else {
        Invoke-Item $taiga\bin\Release
    }
}

read-host -prompt "`n[Script] Press enter to exit"
