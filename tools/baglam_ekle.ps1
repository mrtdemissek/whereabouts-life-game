$utf8 = New-Object System.Text.UTF8Encoding($false)

function Yama($yol, $eski, $yeni) {
  $t = [System.IO.File]::ReadAllText($yol, $utf8)
  if ($t.Contains("baglam")) { Write-Host "ATLANDI (zaten ekli): $yol"; return }
  foreach ($i in 0..($eski.Count - 1)) {
    if (-not $t.Contains($eski[$i])) { Write-Host "BULUNAMADI: $yol -> $($eski[$i])"; return }
    $t = $t.Replace($eski[$i], $yeni[$i])
  }
  [System.IO.File]::WriteAllText($yol, $t, $utf8)
  Write-Host "TAMAM: $yol"
}

Yama "lib\kart_secici.dart" @(
  "import 'kartlar2.dart';",
  "...yeniKararlar,"
) @(
  "import 'kartlar2.dart';`nimport 'baglam_kartlari.dart';",
  "...yeniKararlar,`n  ...baglamKararlari,"
)

Yama "lib\dil.dart" @(
  "import 'diller/tr_kartlar2.dart';",
  "import 'diller/en_kartlar2.dart';",
  "...trKartlar2,",
  "...enKartlar2,"
) @(
  "import 'diller/tr_kartlar2.dart';`nimport 'diller/tr_baglam.dart';",
  "import 'diller/en_kartlar2.dart';`nimport 'diller/en_baglam.dart';",
  "...trKartlar2,`n    ...trBaglam,",
  "...enKartlar2,`n    ...enBaglam,"
)

Yama "lib\karar_ekrani.dart" @(
  "import 'konfeti.dart';",
  "gomlek = _gomlekler[g.nextInt(_gomlekler.length)];"
) @(
  "import 'konfeti.dart';`nimport 'baglam.dart';",
  "gomlek = _gomlekler[g.nextInt(_gomlekler.length)];`n    // Hayatın bağlamı: ülkenin koşulları ve yaşanılan yer`n    etiketler.add(ulkeTuru(widget.ulke.omur));`n    etiketler.add(g.nextBool() ? 'kent' : 'kir');"
)