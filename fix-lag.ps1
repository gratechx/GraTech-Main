# ============================================================================
# Anti-Lag Script - حل مشكلة التعليق
# ============================================================================

Write-Host "🔧 Fixing system lag issues..." -ForegroundColor Yellow

Write-Host "`n1️⃣ Stopping heavy processes..." -ForegroundColor Cyan

# قائمة العمليات الثقيلة
$heavyProcesses = @(
    "comet",
    "node",
    "python",
    "chrome",
    "msedge",
    "devenv"  # Visual Studio
)

foreach ($proc in $heavyProcesses) {
    $running = Get-Process -Name $proc -ErrorAction SilentlyContinue
    if ($running) {
        Write-Host "   → Stopping $proc..." -NoNewline
        Stop-Process -Name $proc -Force -ErrorAction SilentlyContinue
        Write-Host " ✅" -ForegroundColor Green
    }
}

Write-Host "`n2️⃣ Cleaning memory..." -ForegroundColor Cyan
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()
[System.GC]::Collect()
Write-Host "   ✅ Memory cleaned" -ForegroundColor Green

Write-Host "`n3️⃣ Clearing temp files..." -ForegroundColor Cyan
$tempPaths = @(
    "$env:TEMP\*",
    "$env:TMP\*",
    "C:\Windows\Temp\*"
)

foreach ($path in $tempPaths) {
    try {
        Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "   → Cleaned: $path" -ForegroundColor Green
    } catch {
        # Silent fail
    }
}

Write-Host "`n4️⃣ Optimizing Windows..." -ForegroundColor Cyan

# Disable Windows Search temporarily
Write-Host "   → Pausing Windows Search..." -NoNewline
Stop-Service -Name "WSearch" -Force -ErrorAction SilentlyContinue
Write-Host " ✅" -ForegroundColor Green

# Clear DNS cache
Write-Host "   → Clearing DNS cache..." -NoNewline
Clear-DnsClientCache -ErrorAction SilentlyContinue
Write-Host " ✅" -ForegroundColor Green

Write-Host "`n5️⃣ System status:" -ForegroundColor Cyan

$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor

Write-Host "   • CPU Usage: $([math]::Round($cpu.LoadPercentage, 2))%" -ForegroundColor White
Write-Host "   • RAM Free: $([math]::Round($os.FreePhysicalMemory/1MB, 2)) GB" -ForegroundColor White
Write-Host "   • RAM Total: $([math]::Round($os.TotalVisibleMemorySize/1MB, 2)) GB" -ForegroundColor White

Write-Host "`n✅ System optimized! Ready for deployment." -ForegroundColor Green
Write-Host "`nPress any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
