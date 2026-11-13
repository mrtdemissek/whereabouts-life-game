# Whereabouts kontrol betigi: tek komutla analiz yapar, sonucu dosyaya yazar.
# Kullanim (proje klasorunde):  .\kontrol.ps1
$ErrorActionPreference = "Continue"
Set-Location $PSScriptRoot
$cikti = Join-Path $PSScriptRoot "kontrol_sonucu.txt"

"Kontrol zamani: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File $cikti -Encoding utf8

"`n=== flutter analyze ===" | Out-File $cikti -Append -Encoding utf8
$analiz = cmd /c "flutter analyze 2>&1"
$analiz | Out-File $cikti -Append -Encoding utf8

# Varsa kart dogrulayici da calissin
if (Test-Path "tools\kart_dogrula.dart") {
    "`n=== kart dogrulayici ===" | Out-File $cikti -Append -Encoding utf8
    cmd /c "dart run tools\kart_dogrula.dart 2>&1" | Out-File $cikti -Append -Encoding utf8
}

"`n=== git durumu ===" | Out-File $cikti -Append -Encoding utf8
git status --short 2>&1 | Out-File $cikti -Append -Encoding utf8

$son = ($analiz | Select-Object -Last 3) -join " | "
Write-Host ""
Write-Host "Analiz: $son"
Write-Host "Tam sonuc: $cikti"
