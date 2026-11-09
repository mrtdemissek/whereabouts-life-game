$utf8 = New-Object System.Text.UTF8Encoding($false)

function Yama($yol, $eski, $yeni) {
  $t = [System.IO.File]::ReadAllText($yol, $utf8)
  foreach ($i in 0..($eski.Count - 1)) {
    if (-not $t.Contains($eski[$i])) { Write-Host "BULUNAMADI: $yol -> $($eski[$i])"; return }
    $t = $t.Replace($eski[$i], $yeni[$i])
  }
  [System.IO.File]::WriteAllText($yol, $t, $utf8)
  Write-Host "TAMAM: $yol"
}

$imp = "import 'dart:math';"
$imp2 = "import 'dart:math';`nimport 'tohumlu.dart';"

Yama "lib\gunluk.dart" @($imp, "Random(tohum).nextInt") @($imp2, "Tohumlu(tohum).nextInt")

Yama "lib\muzik.dart" @($imp, "Random(plan.tohum)") @($imp2, "Tohumlu(plan.tohum)")

Yama "lib\karar_ekrani.dart" @(
  $imp,
  "Random(_tohum + tuz * 100003 + y)",
  "Random(_tohum + 4 * 100003 + y).nextDouble()",
  "widget.gunluk ? Random(_tohum) : _r"
) @(
  $imp2,
  "Tohumlu(_tohum + tuz * 100003 + y)",
  "Tohumlu(_tohum + 4 * 100003 + y).nextDouble()",
  "widget.gunluk ? Tohumlu(_tohum) : _r"
)