# Location of Sublist3r script
$Source = "$env:USERPROFILE\Documents\Git\Sublist3r"
$Dir = $PSScriptRoot

while(!($Domain)) {
    $Domain = Read-Host "[sublister] Enter a domain"
}

Set-Location $Source
./sublist3r.py -v -e baidu,yahoo,google,bing,ask,netcraft -d $Domain

Read-Host -Prompt "`n[sublister] Press any key to exit"
Set-Location $Dir
