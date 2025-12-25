# ============================================================================
# GraTech Platform - Setup Script
# سكريبت إعداد تلقائي كامل للمنصة
# ============================================================================

Write-Host "
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║        🚀 GraTech Platform - Complete Setup 🚀              ║
║                                                              ║
║    Backend API + Comet-X Browser + Full Integration         ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
" -ForegroundColor Cyan

Write-Host "`n🔍 Step 1: Checking prerequisites..." -ForegroundColor Yellow

# Check Python
Write-Host "   → Checking Python..." -NoNewline
try {
    $pythonVersion = python --version 2>&1
    if ($pythonVersion -match "Python 3\.([0-9]+)") {
        $minorVersion = [int]$Matches[1]
        if ($minorVersion -ge 10) {
            Write-Host " ✅ $pythonVersion" -ForegroundColor Green
        } else {
            Write-Host " ❌ Python 3.10+ required" -ForegroundColor Red
            exit 1
        }
    }
} catch {
    Write-Host " ❌ Python not found" -ForegroundColor Red
    Write-Host "   Please install Python 3.10+ from https://python.org" -ForegroundColor Yellow
    exit 1
}

# Check pip
Write-Host "   → Checking pip..." -NoNewline
try {
    pip --version | Out-Null
    Write-Host " ✅" -ForegroundColor Green
} catch {
    Write-Host " ❌ pip not found" -ForegroundColor Red
    exit 1
}

# Check Chrome
Write-Host "   → Checking Chrome..." -NoNewline
$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (Test-Path $chromePath) {
    Write-Host " ✅" -ForegroundColor Green
} else {
    Write-Host " ⚠️  Chrome not found (optional for Comet-X)" -ForegroundColor Yellow
}

Write-Host "`n📦 Step 2: Setting up environment..." -ForegroundColor Yellow

# Check .env file
if (-not (Test-Path ".env.production")) {
    Write-Host "   → Creating .env.production from template..." -NoNewline
    Copy-Item ".env.production.template" ".env.production"
    Write-Host " ✅" -ForegroundColor Green
    
    Write-Host "`n   ⚠️  IMPORTANT: Please edit .env.production and add your API keys!" -ForegroundColor Yellow
    Write-Host "   Press Enter after editing the file..." -ForegroundColor Yellow
    
    # Open in notepad
    Start-Process notepad ".env.production"
    Read-Host
} else {
    Write-Host "   → .env.production exists ✅" -ForegroundColor Green
}

Write-Host "`n📥 Step 3: Installing Python dependencies..." -ForegroundColor Yellow

# Install requirements
Write-Host "   → Installing packages..." -NoNewline
pip install -r requirements.txt --quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host " ✅" -ForegroundColor Green
} else {
    Write-Host " ❌ Failed to install dependencies" -ForegroundColor Red
    exit 1
}

Write-Host "`n🌐 Step 4: Setting up Comet-X Browser..." -ForegroundColor Yellow

$cometxPath = "comet-x-browser"
if (Test-Path $cometxPath) {
    Write-Host "   → Comet-X files found ✅" -ForegroundColor Green
    
    if (Test-Path $chromePath) {
        Write-Host "`n   📌 To install Comet-X:" -ForegroundColor Cyan
        Write-Host "      1. Open Chrome: chrome://extensions" -ForegroundColor White
        Write-Host "      2. Enable 'Developer mode'" -ForegroundColor White
        Write-Host "      3. Click 'Load unpacked'" -ForegroundColor White
        Write-Host "      4. Select folder: $(Resolve-Path $cometxPath)" -ForegroundColor White
        Write-Host "`n   Press Enter when ready to continue..." -ForegroundColor Yellow
        Read-Host
    }
} else {
    Write-Host "   ⚠️  Comet-X folder not found" -ForegroundColor Yellow
}

Write-Host "`n🚀 Step 5: Starting Backend API..." -ForegroundColor Yellow

# Start backend in background
Write-Host "   → Starting FastAPI server..." -NoNewline
$backendJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    python src/main.py
}
Start-Sleep -Seconds 3

# Check if backend is running
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/health" -TimeoutSec 5 -ErrorAction Stop
    Write-Host " ✅" -ForegroundColor Green
    Write-Host "   → Backend running at http://localhost:8000" -ForegroundColor Green
} catch {
    Write-Host " ❌ Failed to start" -ForegroundColor Red
    Stop-Job $backendJob
    Remove-Job $backendJob
    exit 1
}

Write-Host "`n✅ Step 6: Opening services..." -ForegroundColor Yellow

# Open Swagger UI
Write-Host "   → Opening API docs..." -NoNewline
Start-Process "http://localhost:8000/docs"
Write-Host " ✅" -ForegroundColor Green

# Open Comet-X if Chrome is available
if (Test-Path $chromePath) {
    Write-Host "   → Opening Chrome with Comet-X..." -NoNewline
    Start-Process $chromePath "chrome://newtab"
    Write-Host " ✅" -ForegroundColor Green
}

Write-Host "
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║              ✅ Setup Complete! 🎉                          ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
" -ForegroundColor Green

Write-Host "📡 Backend API:" -ForegroundColor Cyan
Write-Host "   • Docs: http://localhost:8000/docs" -ForegroundColor White
Write-Host "   • Health: http://localhost:8000/health" -ForegroundColor White
Write-Host "   • Models: http://localhost:8000/api/models" -ForegroundColor White

Write-Host "`n🌐 Comet-X Browser:" -ForegroundColor Cyan
Write-Host "   • New Tab: Open a new tab in Chrome" -ForegroundColor White
Write-Host "   • Chat: Press Ctrl+Shift+C" -ForegroundColor White
Write-Host "   • Settings: Click on the Orb" -ForegroundColor White

Write-Host "`n📚 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Test the API: curl http://localhost:8000/health" -ForegroundColor White
Write-Host "   2. Try Comet-X: Open a new Chrome tab" -ForegroundColor White
Write-Host "   3. Read docs: README.md, QUICKSTART.md" -ForegroundColor White

Write-Host "`n🛑 To stop the backend:" -ForegroundColor Yellow
Write-Host "   Press Ctrl+C or close this window" -ForegroundColor White

Write-Host "`n💬 Need help?" -ForegroundColor Cyan
Write-Host "   • Email: admin@gratech.sa" -ForegroundColor White
Write-Host "   • Twitter: @CometXApp" -ForegroundColor White
Write-Host "   • Docs: README.md" -ForegroundColor White

Write-Host "`n🇸🇦 Made with ❤️  in Saudi Arabia | Vision 2030" -ForegroundColor Magenta

Write-Host "`nPress Ctrl+C to stop the backend...`n" -ForegroundColor Yellow

# Keep backend running
try {
    Wait-Job $backendJob
} finally {
    Stop-Job $backendJob -ErrorAction SilentlyContinue
    Remove-Job $backendJob -ErrorAction SilentlyContinue
    Write-Host "`n✅ Backend stopped. Goodbye!" -ForegroundColor Green
}
