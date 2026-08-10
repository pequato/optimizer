# launcher.ps1 - by pequato
Write-Host "[+] Downloading optimizer v1..." -ForegroundColor Cyan
$url = "https://raw.githubusercontent.com/ТВОЙ_НИК/optimizer/main/optimizer.ps1"
$temp = "$env:TEMP\optimizer.ps1"
try {
    Invoke-WebRequest -Uri $url -OutFile $temp -UseBasicParsing
    Write-Host "[+] Starting..." -ForegroundColor Green
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$temp`""
} catch {
    Write-Host "[ERROR] Download failed!" -ForegroundColor Red
    Read-Host "Press Enter"
}
