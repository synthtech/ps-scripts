# User agent
$agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.98 Safari/537.36"
# Default download directory
$default = "$env:USERPROFILE\Videos"
# niconico cookies (must be in Netscape format)
$nicoCookies = "nicovideo-cookies.txt"

$dir = $PSScriptRoot

if ($agent) { $agent = "--user-agent=" + $agent }
$dl = read-host "Enter the directory"
if (!($dl)) { $dl = $default }
while(!($url)) { $url = read-host "Enter the url" }

cd $dl
if ($url -match "nicovideo.jp") { youtube-dl $agent --cookies=$nicoCookies $url }
else { youtube-dl $agent $url }

cd $dir
