# Restore ALL hinhtngan photos from git history, remove other image folders, rebuild gallery
Set-Location d:\duongducquan

# 1) Restore every hinhtngan file that ever existed in duong-duc-quan history
$tree = git ls-tree -r c01b185 --name-only | Select-String "^hinhtngan/"
foreach ($t in $tree) {
  $f = $t.ToString()
  $dest = Join-Path "d:\duongducquan" ($f -replace '/', '\')
  New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
  git cat-file -p "c01b185:$f" > $dest
  Write-Output "Restored: $f"
}

# Also restore matching thumbs for those photos
$thumbs = git ls-tree -r c01b185 --name-only | Select-String "^thumb/"
foreach ($t in $thumbs) {
  $f = $t.ToString()
  $dest = Join-Path "d:\duongducquan" ($f -replace '/', '\')
  New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
  git cat-file -p "c01b185:$f" > $dest
}

# 2) Delete OTHER image sources: images/ folder + Gemini png (not needed)
git rm -r --cached images -q 2>$null
Remove-Item d:\duongducquan\images -Recurse -Force -ErrorAction SilentlyContinue
git rm --cached Gemini_Generated_Image_grntkogrntkogrnt.png -q 2>$null
Remove-Item d:\duongducquan\Gemini_Generated_Image_grntkogrntkogrnt.png -Force -ErrorAction SilentlyContinue

# 3) Rebuild gallery in index.html: one figure per hinhtngan photo
$content = [IO.File]::ReadAllText("d:\duongducquan\index.html")
$photoFiles = Get-ChildItem d:\duongducquan\hinhtngan -Filter *.jpg | Sort-Object Name
$i = 0
$figs = @()
foreach ($p in $photoFiles) {
  $i++
  $t = "hinhtngan/" + $p.Name
  $figs += '<figure class="gitem" data-src="' + $t + '" data-cap="Ảnh ' + $i + ': Dương Đức Quân"><img src="' + $t + '" alt="Ảnh ' + $i + ' Dương Đức Quân – DuongDucQuan Full Stack Developer" loading="lazy"><figcaption>Ảnh ' + $i + ' · Dương Đức Quân</figcaption><span class="zoom">⤢ Phóng to</span><div class="desc"><b>Dương Đức Quân</b> – DuongDucQuan, Full Stack Developer tại TP.HCM.</div></figure>'
}
$galleryBlock = "`r`n    " + ($figs -join "`r`n    ") + "`r`n  "

$newHtml = [regex]::Replace($content, '(?s)<div class="gallery" id="gallery">.*?</div>', ('<div class="gallery" id="gallery">' + $galleryBlock))
# Replace schema image array with hinhtngan images
$schemaImgs = ($photoFiles | ForEach-Object { '{"@type":"ImageObject","contentUrl":"https://duongducquan.github.io/duong-duc-quan/hinhtngan/' + $_.Name + '","name":"Ảnh Dương Đức Quân ' + $_.Name + '"}' }) -join ",`r`n        "
$newHtml = [regex]::Replace($newHtml, '(?s)"image": \[.*?\]', '"image": [' + "`r`n        " + $schemaImgs + "`r`n        ]")

[IO.File]::WriteAllText("d:\duongducquan\index.html", $newHtml, (New-Object System.Text.UTF8Encoding($false)))
Write-Output ("Gallery figures: " + $figs.Count)

git add -A
git commit -m "Upload full hinhtngan photo collection, remove other images"
git push duong-duc-quan main
