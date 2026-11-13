$utf8 = New-Object System.Text.UTF8Encoding($false)

function Yama($yol, $eski, $yeni) {
  $t = [System.IO.File]::ReadAllText($yol, $utf8)
  if ($t.Contains("kartlar2")) { Write-Host "ATLANDI (zaten ekli): $yol"; return }
  foreach ($i in 0..($eski.Count - 1)) {
    if (-not $t.Contains($eski[$i])) { Write-Host "BULUNAMADI: $yol -> $($eski[$i])"; return }
    $t = $t.Replace($eski[$i], $yeni[$i])
  }
  [System.IO.File]::WriteAllText($yol, $t, $utf8)
  Write-Host "TAMAM: $yol"
}

Yama "lib\kart_secici.dart" @(
  "import 'karar.dart';",
  "...kararlar,"
) @(
  "import 'karar.dart';`nimport 'kartlar2.dart';",
  "...kararlar,`n  ...yeniKararlar,"
)

Yama "lib\dil.dart" @(
  "import 'diller/tr_kartlar.dart';",
  "import 'diller/en_kartlar.dart';",
  "...trKartlar,",
  "...enKartlar,"
) @(
  "import 'diller/tr_kartlar.dart';`nimport 'diller/tr_kartlar2.dart';",
  "import 'diller/en_kartlar.dart';`nimport 'diller/en_kartlar2.dart';",
  "...trKartlar,`n    ...trKartlar2,",
  "...enKartlar,`n    ...enKartlar2,"
)