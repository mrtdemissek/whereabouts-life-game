$utf8 = New-Object System.Text.UTF8Encoding($false)
$yol = "lib\karar.dart"
$t = [System.IO.File]::ReadAllText($yol, $utf8)

$desen = "(id: 'k24',\s*sol: Etki\(zaman: -10, para: -5, iliski: 15\),\s*sag: Etki\(zaman: 10, iliski: -10\),\s*solEtiket: \{'ailevi'\},)"
$yeni = '${1}' + "`n    minYas: 19,`n    maxYas: 75,"

if (-not [regex]::IsMatch($t, $desen)) { Write-Host "BULUNAMADI: k24"; return }
if ($t -match "id: 'k24',[^)]*\)[^)]*\)[^}]*\},\s*minYas") { Write-Host "ATLANDI (zaten ekli)"; return }
$t = [regex]::Replace($t, $desen, $yeni)
[System.IO.File]::WriteAllText($yol, $t, $utf8)
Write-Host "TAMAM: k24 icin 19-75 yas araligi eklendi"