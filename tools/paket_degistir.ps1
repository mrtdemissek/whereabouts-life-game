$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)
$eskiPaket = 'com.example.hayat_oyunu'
$yeniPaket = 'io.github.mrtdemissek.whereabouts'
$eskiIos = 'com.example.hayatOyunu'

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

# Android: namespace ve applicationId
Degistir 'android\app\build.gradle.kts' $eskiPaket $yeniPaket

# Android: MainActivity.kt yeni paket klasorune tasinir
$eskiDosya = 'android\app\src\main\kotlin\com\example\hayat_oyunu\MainActivity.kt'
$yeniKlasor = 'android\app\src\main\kotlin\io\github\mrtdemissek\whereabouts'
if (Test-Path $eskiDosya) {
  $m = [System.IO.File]::ReadAllText((Resolve-Path $eskiDosya).Path)
  if ($m.Contains("package $eskiPaket")) {
    $m = $m.Replace("package $eskiPaket", "package $yeniPaket")
    New-Item -ItemType Directory -Force -Path $yeniKlasor | Out-Null
    $yeniDosya = Join-Path (Resolve-Path $yeniKlasor).Path 'MainActivity.kt'
    [System.IO.File]::WriteAllText($yeniDosya, $m, $utf8)
    Remove-Item $eskiDosya
    # Bos kalan eski klasorleri temizle
    $kok = (Resolve-Path 'android\app\src\main\kotlin').Path
    foreach ($k in @('com\example\hayat_oyunu', 'com\example', 'com')) {
      $yol = Join-Path $kok $k
      if ((Test-Path $yol) -and -not (Get-ChildItem $yol -Force)) { Remove-Item $yol }
    }
    Write-Host "TASINDI:    MainActivity.kt -> $yeniKlasor"
  } else {
    Write-Host "BULUNAMADI: package satiri  [$eskiDosya]"
  }
} else {
  Write-Host "YOK:        $eskiDosya"
}

# iOS: paket kimligi
Degistir 'ios\Runner.xcodeproj\project.pbxproj' $eskiIos $yeniPaket

# Dart paket adi: yalnizca kodda package:hayat_oyunu kullanimi yoksa
$kullanim = Select-String -Path 'lib\*.dart', 'lib\diller\*.dart' -Pattern 'package:hayat_oyunu' -Quiet
if ($kullanim) {
  Write-Host "ATLANDI:    pubspec adi, kodda package:hayat_oyunu kullanimi var"
} else {
  Degistir 'pubspec.yaml' 'name: hayat_oyunu' 'name: whereabouts'
}