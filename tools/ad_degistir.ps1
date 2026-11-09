$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)

# Bir dosyada tam eslesen metni degistirir ve ne oldugunu yazar
function Degistir($yol, $eski, $yeni) {
  if (-not (Test-Path $yol)) { Write-Host "YOK:        $yol"; return }
  $tam = (Resolve-Path $yol).Path
  $m = [System.IO.File]::ReadAllText($tam)
  if ($m.Contains($eski)) {
    $m = $m.Replace($eski, $yeni)
    [System.IO.File]::WriteAllText($tam, $m, $utf8)
    Write-Host "DEGISTI:    $yol   [$eski -> $yeni]"
  } else {
    Write-Host "BULUNAMADI: $yol   [$eski]"
  }
}

# Android: telefonda simgenin altinda gorunen ad
Degistir 'android\app\src\main\AndroidManifest.xml' 'android:label="hayat_oyunu"' 'android:label="Whereabouts"'

# iOS: gorunen ad ve kisa ad
Degistir 'ios\Runner\Info.plist' '<string>Hayat Oyunu</string>' '<string>Whereabouts</string>'
Degistir 'ios\Runner\Info.plist' '<string>hayat_oyunu</string>' '<string>Whereabouts</string>'

# Web: sekme basligi ve manifest
Degistir 'web\index.html' '<title>hayat_oyunu</title>' '<title>Whereabouts</title>'
Degistir 'web\index.html' 'content="hayat_oyunu"' 'content="Whereabouts"'
Degistir 'web\manifest.json' '"name": "hayat_oyunu"' '"name": "Whereabouts"'
Degistir 'web\manifest.json' '"short_name": "hayat_oyunu"' '"short_name": "Whereabouts"'

# Proje aciklamasi
Degistir 'pubspec.yaml' 'description: "A new Flutter project."' 'description: "Whereabouts: a pastel pixel-art life simulation."'