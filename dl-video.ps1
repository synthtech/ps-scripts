# User agent
$agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.75 Safari/537.36"
# Default download directory
$default = "$env:USERPROFILE\Videos"

$dir = $PSScriptRoot

$ytdl = read-host "Update youtube-dl?"
if (!($ytdl)) { $ytdl = "n" }
$dl = read-host "Enter the directory"
if (!($dl)) { $dl = $default }
while(!($url)) { $url = read-host "Enter the url" }

if ($ytdl -eq "yes" -or $ytdl -eq "y") { Start-Process powershell -Verb runAs -ArgumentList "pip install -U youtube-dl" }
cd $dl
if ($url -match "nicovideo.jp") { youtube-dl --user-agent $agent --netrc $url }
else { youtube-dl --user-agent $agent $url }

cd $dir
