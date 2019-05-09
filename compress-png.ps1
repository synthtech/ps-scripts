while (!($imgin)) { $imgin = read-host "Enter the input filename" }
while (!($imgout)) { $imgout = read-host "Enter the output filename" }
$app = read-host "Compression level (quality|size}"
if (!($app)) { $app = "size" }

if ($app -eq "quality" -or $app -eq "q") {
    optipng -strip all -out $imgout $imgin
} elseif ($app -eq "size" -or $app -eq "s") {
    pngquant --strip -o $imgout $imgin
}
