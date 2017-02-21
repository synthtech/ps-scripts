# Location of Sublist3r script
$source = "$env:USERPROFILE\Documents\Git\Sublist3r"
$dir = $PSScriptRoot

while(!($domain)) { $domain = read-host "[Script] Enter a domain" }

cd $source
python sublist3r.py -e baidu,yahoo,google,bing,ask,netcraft,ssl -d $domain

read-host -prompt "`n[Script] Press enter to exit"
cd $dir
