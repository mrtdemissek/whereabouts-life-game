# Whereabouts tani betigi: performans sorununda sistemin durumunu dosyaya yazar.
# Kullanim (uygulama yavasken, proje klasorunde):  .\tani.ps1
$ErrorActionPreference = "SilentlyContinue"
Set-Location $PSScriptRoot
$cikti = Join-Path $PSScriptRoot "tani_sonucu.txt"
"Tani zamani: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File $cikti -Encoding utf8

"`n=== bellek ve islemci ===" | Out-File $cikti -Append -Encoding utf8
$os = Get-CimInstance Win32_OperatingSystem
"Toplam RAM (GB): {0:N1}" -f ($os.TotalVisibleMemorySize / 1MB) | Out-File $cikti -Append -Encoding utf8
"Bos RAM (GB): {0:N1}" -f ($os.FreePhysicalMemory / 1MB) | Out-File $cikti -Append -Encoding utf8
$cpu = Get-CimInstance Win32_Processor
"Islemci: $($cpu.Name) | cekirdek: $($cpu.NumberOfLogicalProcessors) | yuk: $($cpu.LoadPercentage)%" | Out-File $cikti -Append -Encoding utf8

"`n=== ilgili islemler (ad, adet, toplam RAM MB, toplam CPU sn) ===" | Out-File $cikti -Append -Encoding utf8
Get-Process | Where-Object { $_.ProcessName -match 'dart|flutter|java|qemu|emulator|adb|studio|gradle|crashpad|Code' } |
    Group-Object ProcessName | ForEach-Object {
        $ram = ($_.Group | Measure-Object WorkingSet64 -Sum).Sum / 1MB
        $sn = ($_.Group | Measure-Object CPU -Sum).Sum
        "{0,-28} adet:{1,3}  RAM:{2,8:N0} MB  CPU:{3,8:N0} sn" -f $_.Name, $_.Count, $ram, $sn
    } | Out-File $cikti -Append -Encoding utf8

"`n=== en cok RAM kullanan 8 islem ===" | Out-File $cikti -Append -Encoding utf8
Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 8 |
    ForEach-Object { "{0,-28} RAM:{1,8:N0} MB" -f $_.ProcessName, ($_.WorkingSet64 / 1MB) } |
    Out-File $cikti -Append -Encoding utf8

"`n=== cihazlar ===" | Out-File $cikti -Append -Encoding utf8
cmd /c "adb devices -l 2>&1" | Out-File $cikti -Append -Encoding utf8
"cihaz mimarisi:" | Out-File $cikti -Append -Encoding utf8
cmd /c "adb shell getprop ro.product.cpu.abilist 2>&1" | Out-File $cikti -Append -Encoding utf8
"kurulu uygulama mimarisi:" | Out-File $cikti -Append -Encoding utf8
cmd /c "adb shell pm dump io.github.mrtdemissek.whereabouts 2>&1" | Select-String -Pattern "primaryCpuAbi|versionName|flags=|DEBUGGABLE" | Select-Object -First 6 | Out-File $cikti -Append -Encoding utf8

"`n=== flutter surumu ===" | Out-File $cikti -Append -Encoding utf8
cmd /c "flutter --version 2>&1" | Select-Object -First 3 | Out-File $cikti -Append -Encoding utf8

Write-Host "Tani yazildi: $cikti"
