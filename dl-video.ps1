# User agent
$agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.96 Safari/537.36"
# Default download directory
$default = "$env:USERPROFILE\Videos"

$dir = $PSScriptRoot

$dl = read-host "Enter the directory"
if (!($dl)) { $dl = $default }
while(!($url)) { $url = read-host "Enter the url" }

cd $dl
if ($url -match "nicovideo.jp") { youtube-dl --user-agent $agent --netrc $url }
else { youtube-dl --user-agent $agent $url }

cd $dir
