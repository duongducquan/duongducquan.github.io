$ErrorActionPreference = "Stop"
$p = "D:\duongducquan\_cur_index.html"
$html = Get-Content -Raw -Encoding Unicode $p

# 1. Favicon + og:image + twitter:image
$rep1 = '<link rel="icon" type="image/png" href="quan-avatar-logo.png">' + "`r`n" + '<meta property="og:image" content="https://duongducquan.github.io/quan-avatar-logo.png">' + "`r`n" + '<meta name="twitter:image" content="https://duongducquan.github.io/quan-avatar-logo.png">'
$html = $html.Replace('<link rel="icon" type="image/png" href="/favicon.png">', $rep1)

# 2. CSS for logo + gallery
$cssAdd = @'
.logo-q{width:150px;height:150px;display:block;object-fit:cover;border-radius:50%;border:3px solid var(--accent);box-shadow:0 0 30px rgba(11,107,87,.35);margin-bottom:16px}
.gallery{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:16px;margin-top:18px}
.gitem{margin:0;border:1px solid var(--line);border-radius:10px;overflow:hidden;background:var(--surface)}
.gitem img{width:100%;height:280px;object-fit:cover;display:block}
.gitem figcaption{padding:10px 12px;font-size:.9rem;color:var(--muted)}
.gitem a{display:block}
'@
$pattern = 'ul\.tags li\{background:var\(--accent-soft\);color:var\(--accent\);border-radius:999px;padding:2px 12px;font-size:\.92rem\}'
$html = [regex]::Replace($html, $pattern, { param($m) $m.Value + "`r`n" + $cssAdd.TrimEnd() })

# 3. Logo image in hero
$html = [regex]::Replace($html, '<header class="hero">\s*\r?\n\s*<div class="wrap">',
( '<header class="hero">' + "`r`n" + '  <div class="wrap">' + "`r`n" + '    <img class="logo-q" src="quan-avatar-logo.png" alt="DuongDucQuan - Full Stack Web Developer" width="150" height="150">' ))

# 4. Gallery: 44 images (31 hinhtngan + gemini + 12 images/)
$hinhtngan = @(
  'anh1.jpg.jpg','anh2.jpg','anh3.jpg','anh4.jpg','anh5.jpg','anh6.jpg','anh7.jpg','anh8.jpg','anh9.jpg','anh10.jpg',
  'avara.jpg.jpg','z7384682605918_83a60727b5cd329fd90db8fd4859cfa9.jpg','z7384682606203_9dde1a794d2808d761029ce8cb5a3468.jpg',
  'z7384682613517_b5f728afc6add53f9995829d0e1208cf.jpg','z7384682619566_f292add528c52fb7ed613890d3c85c83.jpg',
  'z7384682623197_f5991f3f9178e9a30ae4e42202065e7e.jpg','z7384682665019_cb9ebe0108ec608b50942ff089ed2199.jpg',
  'z7384682680565_8f5d23844214bdc1e277690f5b749d9f.jpg','z7384682689444_84a53c95875616643e9a432768f0cd2f.jpg',
  'z7384682689754_3d750d5ae05988cf24a3d42cc7cae9c3.jpg','z7384682693739_f2a8ba98dbcf1100090e7c335f612dcc.jpg',
  'z7384688935919_973b5c2dc6faa806bfcafef78f39d85e.jpg','anh23-portrait.jpg','anh24-fullstack.jpg','anh25-ngan.jpg',
  'anh26-selfie.jpg','1794214182787_50335361023664679_3575292183984077832_7da0e86600586bc33acceb8eefa19479.jpg',
  '1794214182825_50335361023664679_3575292183984077832_97ab549be3d5f196b28d9fc56bba560d.jpg',
  '1794214226783_50335361023664679_3575292183984077832_cdf503bf48e18cbfcafced92581ae9bd.jpg',
  '1794214226852_50335361023664679_3575292183984077832_c843732cce6c6f85e8e1d45078fa0da7.jpg',
  '1794214240552_50335361023664679_3575292183984077832_17103d67467907c956e1e55607369047.jpg'
)
$imgs = @('anh-2.jpg','anh-3.jpg','anh-4.jpg','anh-5.jpg','anh-6.jpg','anh-7.jpg','anh-8.jpg','anh-9.jpg','anh-10.jpg','anh-11.jpg','anh-12.jpg','anh-13.jpg')
$all = @($hinhtngan | ForEach-Object { "hinhtngan/$_" }) + @('Gemini_Generated_Image_grntkogrntkogrnt.png') + @($imgs | ForEach-Object { "images/$_" })

$gallery = ""
$n = 0
foreach ($f in $all) {
  $n++
  $alt = "Anh $n Duong Duc Quan - DuongDucQuan"
  $cap = "Anh $n - Duong Duc Quan"
  $gallery += "    <figure class=`"gitem`"><a href=`"$f`" target=`"_blank`" rel=`"noopener`"><img src=`"$f`" alt=`"$alt`" loading=`"lazy`"></a><figcaption>$cap</figcaption></figure>`r`n"
}
$section = "<section id=`"bo-suu-tap-anh`">`r`n  <h2>Bo suu tap anh cua Duong Duc Quan (44 anh)</h2>`r`n  <p>Tong hop 44 anh cua Duong Duc Quan (DuongDucQuan) - Full Stack Web Developer tai TP.HCM. Bam vao anh de xem kich thuoc goc.</p>`r`n  <div class=`"gallery`">`r`n" + $gallery + "  </div>`r`n</section>`r`n"
$html = $html -replace '</article>', $section

Set-Content -Path $p -Value $html -Encoding Unicode
Write-Output "OK - gallery count: $n"
