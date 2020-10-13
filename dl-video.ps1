$agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.121 Safari/537.36"

while(!($url)) { $url = read-host "Enter the url" }

youtube-dlc --user-agent $agent --netrc -v $url
