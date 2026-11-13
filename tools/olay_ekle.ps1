$utf8 = New-Object System.Text.UTF8Encoding($false)

function Yama($yol, $eski, $yeni) {
  $t = [System.IO.File]::ReadAllText($yol, $utf8)
  if ($t.Contains("olay2") -or $t.Contains("olaylar2")) { Write-Host "ATLANDI (zaten ekli): $yol"; return }
  foreach ($i in 0..($eski.Count - 1)) {
    if (-not $t.Contains($eski[$i])) { Write-Host "BULUNAMADI: $yol -> $($eski[$i])"; return }
    $t = $t.Replace($eski[$i], $yeni[$i])
  }
  [System.IO.File]::WriteAllText($yol, $t, $utf8)
  Write-Host "TAMAM: $yol"
}

Yama "lib\kart_secici.dart" @(
  "import 'olaylar.dart';",
  "...olayKartlari,"
) @(
  "import 'olaylar.dart';`nimport 'olaylar2.dart';",
  "...olayKartlari,`n  ...olayKartlari2,"
)

Yama "lib\dil.dart" @(
  "import 'diller/tr_olay.dart';",
  "import 'diller/en_olay.dart';",
  "...trOlay,",
  "...enOlay,"
) @(
  "import 'diller/tr_olay.dart';`nimport 'diller/tr_olay2.dart';",
  "import 'diller/en_olay.dart';`nimport 'diller/en_olay2.dart';",
  "...trOlay,`n    ...trOlay2,",
  "...enOlay,`n    ...enOlay2,"
)