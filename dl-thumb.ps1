# User agent
$agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36"

while(!($url)) { $url = read-host "Enter the url" }

$yt = youtube-dl --user-agent $agent --get-thumbnail $url

if ($yt -match "twitch\.tv\/.*preview(.*)\.jpg") {
    $yt = $yt -replace $Matches[1],""
}
write-host $yt

curl.exe -A $agent -O --url $yt
