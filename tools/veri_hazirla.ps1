$ErrorActionPreference = 'Stop'

# Oyundaki ulkelerin kodlari
$json = Get-Content -Raw -Encoding UTF8 'assets\ulkeler.json' | ConvertFrom-Json
$ulkeKodlari = @($json | ForEach-Object { $_.kod })

# Gosterge tanimlari
# yon: 'yuksek' = yuksek deger riskli, 'dusuk' = yuksek deger iyi (risk ters cevrilir)
# eksik: 'sifir' = veri yoksa risk 0, 'bos' = veri yoksa bilinmiyor (null)
# olcek: 'yuzdelik' ya da 'log'
$tanimlar = @(
  @{ alan='siyasi_baski';   kod='GOV_WGI_VA.EST'; kaynak=3; yon='dusuk';  eksik='bos';   olcek='yuzdelik' },
  @{ alan='istikrarsizlik'; kod='GOV_WGI_PV.EST'; kaynak=3; yon='dusuk';  eksik='bos';   olcek='yuzdelik' },
  @{ alan='enflasyon';      kod='FP.CPI.TOTL.ZG'; kaynak=2; yon='yuksek'; eksik='bos';   olcek='yuzdelik' },
  @{ alan='yoksulluk';      kod='SI.POV.DDAY';    kaynak=2; yon='yuksek'; eksik='bos';   olcek='yuzdelik' },
  @{ alan='issizlik';       kod='SL.UEM.TOTL.ZS'; kaynak=2; yon='yuksek'; eksik='bos';   olcek='yuzdelik' },
  @{ alan='siddet';         kod='VC.IHR.PSRC.P5'; kaynak=2; yon='yuksek'; eksik='bos';   olcek='yuzdelik' },
  @{ alan='catisma';        kod='VC.BTL.DETH';    kaynak=2; yon='yuksek'; eksik='sifir'; olcek='log' },
  @{ alan='trafik';         kod='SH.STA.TRAF.P5'; kaynak=2; yon='yuksek'; eksik='bos';   olcek='yuzdelik' },
  @{ alan='sitma';          kod='SH.MLR.INCD.P3'; kaynak=2; yon='yuksek'; eksik='sifir'; olcek='yuzdelik' },
  @{ alan='verem';          kod='SH.TBS.INCD';    kaynak=2; yon='yuksek'; eksik='bos';   olcek='yuzdelik' },
  @{ alan='aclik';          kod='SN.ITK.DEFC.ZS'; kaynak=2; yon='yuksek'; eksik='bos';   olcek='yuzdelik' },
  @{ alan='su';             kod='SH.H2O.SMDW.ZS'; kaynak=2; yon='dusuk';  eksik='bos';   olcek='yuzdelik' }
)

# Bir gostergenin her ulke icin en son bos olmayan degerini ceker
function Veri-Cek($kod, $kaynak) {
  $sonuc = @{}
  $ek = ''
  if ($kaynak -eq 3) { $ek = '&source=3' }

  # Once her ulkenin en son degerini dogrudan iste
  $url = "https://api.worldbank.org/v2/country/all/indicator/${kod}?format=json&mrnev=1&per_page=1000$ek"
  $r = $null
  try { $r = Invoke-RestMethod $url } catch { }
  if ($null -ne $r -and $r.Count -ge 2 -and $null -ne $r[1]) {
    foreach ($satir in $r[1]) {
      if ($null -ne $satir.value) { $sonuc[$satir.countryiso3code] = [double]$satir.value }
    }
  }

  # Olmadiysa: son yillari cekip her ulke icin en yenisini sec
  if ($sonuc.Count -eq 0) {
    $url2 = "https://api.worldbank.org/v2/country/all/indicator/${kod}?format=json&date=2015:2025&per_page=20000$ek"
    $r2 = Invoke-RestMethod $url2
    $yil = @{}
    if ($r2.Count -ge 2 -and $null -ne $r2[1]) {
      foreach ($satir in $r2[1]) {
        if ($null -eq $satir.value) { continue }
        $k = $satir.countryiso3code
        $y = [int]$satir.date
        if (-not $yil.ContainsKey($k) -or $y -gt $yil[$k]) {
          $yil[$k] = $y
          $sonuc[$k] = [double]$satir.value
        }
      }
    }
  }
  return $sonuc
}

# Degerleri 0-1 arasi risk skoruna cevirir
function Risk-Hesapla($degerler, $tan) {
  $anahtarlar = @($degerler.Keys)
  $n = $anahtarlar.Count
  $risk = @{}
  if ($n -eq 0) { return $risk }
  if ($tan.olcek -eq 'log') {
    $maks = ($degerler.Values | Measure-Object -Maximum).Maximum
    foreach ($k in $anahtarlar) {
      $v = [math]::Max($degerler[$k], 0)
      if ($maks -gt 0) { $risk[$k] = [math]::Log(1 + $v) / [math]::Log(1 + $maks) } else { $risk[$k] = 0.0 }
    }
  } else {
    foreach ($k in $anahtarlar) {
      $v = $degerler[$k]
      $kucuk = @($anahtarlar | Where-Object { $degerler[$_] -lt $v }).Count
      $esit = @($anahtarlar | Where-Object { $degerler[$_] -eq $v }).Count
      if ($n -gt 1) { $risk[$k] = ($kucuk + ($esit - 1) / 2.0) / ($n - 1) } else { $risk[$k] = 0.5 }
    }
  }
  if ($tan.yon -eq 'dusuk') {
    foreach ($k in @($risk.Keys)) { $risk[$k] = 1 - $risk[$k] }
  }
  return $risk
}

$tumRisk = @{}
foreach ($t in $tanimlar) {
  Write-Host "Cekiliyor: $($t.kod)"
  try { $ham = Veri-Cek $t.kod $t.kaynak } catch { Write-Host "  HATA: $($t.kod) okunamadi"; $ham = @{} }
  $filtre = @{}
  foreach ($k in $ulkeKodlari) { if ($ham.ContainsKey($k)) { $filtre[$k] = $ham[$k] } }
  Write-Host "  veri olan ulke: $($filtre.Count) / $($ulkeKodlari.Count)"
  $tumRisk[$t.alan] = Risk-Hesapla $filtre $t
}

$cikti = foreach ($k in $ulkeKodlari) {
  $o = [ordered]@{ kod = $k }
  foreach ($t in $tanimlar) {
    $h = $tumRisk[$t.alan]
    if ($h.ContainsKey($k)) { $o[$t.alan] = [math]::Round($h[$k], 3) }
    elseif ($t.eksik -eq 'sifir') { $o[$t.alan] = 0.0 }
    else { $o[$t.alan] = $null }
  }
  [pscustomobject]$o
}

$metin = $cikti | ConvertTo-Json
[System.IO.File]::WriteAllText("$PWD\assets\riskler.json", $metin, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Yazildi: assets\riskler.json ($(@($cikti).Count) ulke)"