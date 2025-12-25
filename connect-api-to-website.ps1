# ============================================================================
# Update gratech.sa to use new API
# تحديث الموقع ليستخدم API الجديد
# ============================================================================

param(
    [string]$Domain = "gratech.sa",
    [string]$NewApiUrl = "https://gratech-api.lemondune-e5f760db.uaenorth.azurecontainerapps.io",
    [string]$OldApiUrl = "https://ameen-api-func.azurewebsites.net"
)

Write-Host "
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║        🔗 Connecting gratech.sa to New API                  ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
" -ForegroundColor Cyan

Write-Host "`n📋 Configuration:" -ForegroundColor Yellow
Write-Host "   • Domain: $Domain" -ForegroundColor White
Write-Host "   • Old API: $OldApiUrl" -ForegroundColor Yellow
Write-Host "   • New API: $NewApiUrl" -ForegroundColor Green

Write-Host "`n🎯 Options:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   1️⃣  Add Custom Domain (api.gratech.sa)" -ForegroundColor White
Write-Host "   2️⃣  Update Frontend to point to new API" -ForegroundColor White
Write-Host "   3️⃣  Keep both APIs (load balancing)" -ForegroundColor White
Write-Host ""

Write-Host "📝 Option 1: Add Custom Domain (Recommended)" -ForegroundColor Cyan
Write-Host "   This creates: api.gratech.sa → New API" -ForegroundColor White
Write-Host ""
Write-Host "   Steps:" -ForegroundColor Yellow
Write-Host "   1. Add DNS CNAME record:" -ForegroundColor White
Write-Host "      Name: api" -ForegroundColor White
Write-Host "      Value: gratech-api.lemondune-e5f760db.uaenorth.azurecontainerapps.io" -ForegroundColor White
Write-Host ""
Write-Host "   2. Add custom domain to Container App:" -ForegroundColor White
Write-Host "      az containerapp hostname add \" -ForegroundColor Gray
Write-Host "        --name gratech-api \" -ForegroundColor Gray
Write-Host "        --resource-group rg-gratech-prod \" -ForegroundColor Gray
Write-Host "        --hostname api.gratech.sa" -ForegroundColor Gray
Write-Host ""

Write-Host "📝 Option 2: Update Frontend (Easiest)" -ForegroundColor Cyan
Write-Host "   Update the frontend code to use new API URL" -ForegroundColor White
Write-Host ""
Write-Host "   Find and replace:" -ForegroundColor Yellow
Write-Host "   OLD: https://ameen-api-func.azurewebsites.net" -ForegroundColor Red
Write-Host "   NEW: https://gratech-api.lemondune-e5f760db.uaenorth.azurecontainerapps.io" -ForegroundColor Green
Write-Host ""

Write-Host "📝 Option 3: Azure Front Door (Advanced)" -ForegroundColor Cyan
Write-Host "   Load balance between both APIs" -ForegroundColor White
Write-Host "   - Health checks" -ForegroundColor White
Write-Host "   - Automatic failover" -ForegroundColor White
Write-Host "   - CDN caching" -ForegroundColor White
Write-Host ""

Write-Host "❓ Which option do you prefer?" -ForegroundColor Yellow
Write-Host "   Type 1, 2, or 3 and press Enter: " -NoNewline -ForegroundColor White
$choice = Read-Host

switch ($choice) {
    "1" {
        Write-Host "`n🔗 Setting up Custom Domain..." -ForegroundColor Cyan
        
        Write-Host "`n📋 Step 1: Add DNS Record" -ForegroundColor Yellow
        Write-Host "   Go to your DNS provider and add:" -ForegroundColor White
        Write-Host ""
        Write-Host "   Type: CNAME" -ForegroundColor Cyan
        Write-Host "   Name: api" -ForegroundColor Cyan
        Write-Host "   Value: gratech-api.lemondune-e5f760db.uaenorth.azurecontainerapps.io" -ForegroundColor Cyan
        Write-Host "   TTL: 3600" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "   Press Enter when DNS is configured..." -ForegroundColor Yellow
        Read-Host
        
        Write-Host "`n📋 Step 2: Add to Container App..." -ForegroundColor Yellow
        Write-Host "   → Adding hostname..." -NoNewline
        
        az containerapp hostname add `
            --name gratech-api `
            --resource-group rg-gratech-prod `
            --hostname api.gratech.sa
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host " ✅" -ForegroundColor Green
            Write-Host "`n✅ Done! Your API is now at: https://api.gratech.sa" -ForegroundColor Green
        } else {
            Write-Host " ❌" -ForegroundColor Red
            Write-Host "   Manual steps needed - check Azure Portal" -ForegroundColor Yellow
        }
    }
    
    "2" {
        Write-Host "`n📝 Frontend Update Guide:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "   1. Find your frontend files (index.html, app.js, etc.)" -ForegroundColor White
        Write-Host ""
        Write-Host "   2. Search for: ameen-api-func.azurewebsites.net" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "   3. Replace with: gratech-api.lemondune-e5f760db.uaenorth.azurecontainerapps.io" -ForegroundColor Green
        Write-Host ""
        Write-Host "   4. Test locally" -ForegroundColor White
        Write-Host ""
        Write-Host "   5. Deploy to gratech.sa" -ForegroundColor White
        Write-Host ""
        Write-Host "   Example:" -ForegroundColor Cyan
        Write-Host "   OLD: fetch('https://ameen-api-func.azurewebsites.net/api/chat')" -ForegroundColor Red
        Write-Host "   NEW: fetch('https://gratech-api.lemondune-e5f760db.uaenorth.azurecontainerapps.io/api/chat')" -ForegroundColor Green
        Write-Host ""
    }
    
    "3" {
        Write-Host "`n🌐 Azure Front Door Setup:" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "   Creating Front Door configuration..." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "   This will:" -ForegroundColor White
        Write-Host "   • Create: https://api.gratech.sa" -ForegroundColor Green
        Write-Host "   • Backend 1: New API (Primary)" -ForegroundColor White
        Write-Host "   • Backend 2: Old API (Fallback)" -ForegroundColor White
        Write-Host "   • Health Checks: Every 30s" -ForegroundColor White
        Write-Host "   • Auto Failover: Enabled" -ForegroundColor White
        Write-Host ""
        Write-Host "   ⚠️  This requires Azure Front Door (paid service)" -ForegroundColor Yellow
        Write-Host ""
    }
    
    default {
        Write-Host "`n⚠️  Invalid choice. Run script again." -ForegroundColor Yellow
    }
}

Write-Host "`n📊 Current Status:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   🌐 Frontend: https://www.gratech.sa" -ForegroundColor White
Write-Host "   🔗 Old API: https://ameen-api-func.azurewebsites.net ✅" -ForegroundColor Yellow
Write-Host "   🔗 New API: https://gratech-api.lemondune-e5f760db.uaenorth.azurecontainerapps.io ✅" -ForegroundColor Green
Write-Host ""

Write-Host "`n💡 Recommendation:" -ForegroundColor Cyan
Write-Host "   Start with Option 2 (Update Frontend)" -ForegroundColor Green
Write-Host "   Then add Option 1 (Custom Domain)" -ForegroundColor Green
Write-Host "   Later consider Option 3 (Front Door) for production" -ForegroundColor White

Write-Host "`n🇸🇦 Made with ❤️  in Saudi Arabia | Vision 2030" -ForegroundColor Magenta
Write-Host "`nPress any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
