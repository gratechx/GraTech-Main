# ============================================================================
# Deploy to gratech.sa - Complete Deployment Script
# نشر كامل على gratech.sa
# ============================================================================

param(
    [string]$Domain = "gratech.sa",
    [string]$ResourceGroup = "rg-gratech-prod",
    [string]$Location = "uaenorth",
    [switch]$SkipDNS
)

Write-Host "
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║        🌐 Deploying to $Domain                      ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
" -ForegroundColor Cyan

Write-Host "`n🔐 Step 1: Azure Login..." -ForegroundColor Yellow
try {
    $account = az account show 2>$null | ConvertFrom-Json
    Write-Host "   ✅ Logged in as: $($account.user.name)" -ForegroundColor Green
} catch {
    Write-Host "   → Logging in..." -NoNewline
    az login
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅" -ForegroundColor Green
    } else {
        Write-Host " ❌" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n📦 Step 2: Creating Resource Group..." -ForegroundColor Yellow
$rgExists = az group exists --name $ResourceGroup
if ($rgExists -eq "true") {
    Write-Host "   ✅ Resource Group exists" -ForegroundColor Green
} else {
    Write-Host "   → Creating..." -NoNewline
    az group create --name $ResourceGroup --location $Location | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅" -ForegroundColor Green
    } else {
        Write-Host " ❌" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n🌐 Step 3: Deploying Backend API..." -ForegroundColor Yellow
Write-Host "   → Running deploy-azure.ps1..." -ForegroundColor Cyan

# Call the existing deployment script
& ".\deploy-azure.ps1" -ResourceGroup $ResourceGroup -Location $Location -AppName "gratech-api"

if ($LASTEXITCODE -ne 0) {
    Write-Host "   ❌ Backend deployment failed" -ForegroundColor Red
    exit 1
}

# Get the app URL
$appInfo = az containerapp show `
    --name "gratech-api" `
    --resource-group $ResourceGroup `
    --query "{fqdn:properties.configuration.ingress.fqdn}" `
    --output json | ConvertFrom-Json

$backendUrl = "https://$($appInfo.fqdn)"
Write-Host "   ✅ Backend deployed at: $backendUrl" -ForegroundColor Green

Write-Host "`n🎨 Step 4: Creating Static Web App for Frontend..." -ForegroundColor Yellow

$frontendName = "gratech-frontend"

Write-Host "   → Creating Static Web App..." -NoNewline
az staticwebapp create `
    --name $frontendName `
    --resource-group $ResourceGroup `
    --location $Location `
    --sku Free `
    --output none

if ($LASTEXITCODE -eq 0) {
    Write-Host " ✅" -ForegroundColor Green
} else {
    Write-Host " ⚠️  May already exist" -ForegroundColor Yellow
}

# Get the default hostname
$staticApp = az staticwebapp show `
    --name $frontendName `
    --resource-group $ResourceGroup `
    --output json | ConvertFrom-Json

$defaultHostname = $staticApp.defaultHostname
Write-Host "   → Default URL: https://$defaultHostname" -ForegroundColor Cyan

if (-not $SkipDNS) {
    Write-Host "`n🔗 Step 5: Configuring Custom Domain..." -ForegroundColor Yellow
    
    Write-Host "   → Adding custom domain $Domain..." -NoNewline
    az staticwebapp hostname set `
        --name $frontendName `
        --resource-group $ResourceGroup `
        --hostname $Domain `
        --output none 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅" -ForegroundColor Green
    } else {
        Write-Host " ⚠️  Manual configuration needed" -ForegroundColor Yellow
    }
    
    Write-Host "`n   📋 DNS Configuration Required:" -ForegroundColor Cyan
    Write-Host "   Add these records to your DNS provider:" -ForegroundColor White
    Write-Host ""
    Write-Host "   Record Type: CNAME" -ForegroundColor Yellow
    Write-Host "   Name: $Domain" -ForegroundColor White
    Write-Host "   Value: $defaultHostname" -ForegroundColor White
    Write-Host ""
    Write-Host "   Record Type: TXT (for verification)" -ForegroundColor Yellow
    Write-Host "   Name: _dnsauth.$Domain" -ForegroundColor White
    Write-Host "   Value: [Will be provided in Azure Portal]" -ForegroundColor White
    Write-Host ""
}

Write-Host "`n📄 Step 6: Creating Landing Page..." -ForegroundColor Yellow

# Create a simple index.html for deployment
$indexHtml = @"
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GraTech - منصة الذكاء الاصطناعي السيادية</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #05261F 0%, #0a0a0a 100%);
            color: #ffffff;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .container {
            max-width: 800px;
            text-align: center;
        }
        .logo {
            width: 100px;
            height: 100px;
            margin: 0 auto 30px;
            border-radius: 50%;
            background: radial-gradient(circle at 30% 30%, #1ABC9C, #05261F);
            box-shadow: 0 0 50px rgba(26, 188, 156, 0.6);
            animation: pulse 3s ease-in-out infinite;
        }
        @keyframes pulse {
            0%, 100% { transform: scale(1); box-shadow: 0 0 50px rgba(26, 188, 156, 0.6); }
            50% { transform: scale(1.05); box-shadow: 0 0 80px rgba(26, 188, 156, 0.9); }
        }
        h1 {
            color: #1ABC9C;
            font-size: 3rem;
            margin-bottom: 20px;
        }
        .tagline {
            font-size: 1.5rem;
            color: #888;
            margin-bottom: 40px;
        }
        .features {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 40px 0;
        }
        .feature {
            background: rgba(26, 188, 156, 0.1);
            border: 2px solid #1ABC9C;
            border-radius: 10px;
            padding: 20px;
        }
        .feature-icon { font-size: 2rem; margin-bottom: 10px; }
        .feature-title { color: #1ABC9C; font-weight: bold; margin-bottom: 5px; }
        .cta {
            margin-top: 40px;
        }
        .btn {
            background: #1ABC9C;
            color: #05261F;
            padding: 15px 40px;
            border: none;
            border-radius: 8px;
            font-size: 1.2rem;
            font-weight: bold;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
        }
        .btn:hover {
            background: #16a085;
            transform: scale(1.05);
        }
        .api-link {
            margin-top: 20px;
            color: #888;
        }
        .api-link a {
            color: #1ABC9C;
            text-decoration: none;
        }
        .api-link a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo"></div>
        <h1>GraTech</h1>
        <div class="tagline">منصة الذكاء الاصطناعي السيادية 🇸🇦</div>
        
        <div class="features">
            <div class="feature">
                <div class="feature-icon">🔒</div>
                <div class="feature-title">خصوصية 100%</div>
                <div>كل شيء محلي</div>
            </div>
            <div class="feature">
                <div class="feature-icon">⚖️</div>
                <div class="feature-title">محايد تماماً</div>
                <div>لا انحياز</div>
            </div>
            <div class="feature">
                <div class="feature-icon">🧠</div>
                <div class="feature-title">ذكاء متقدم</div>
                <div>أقوى النماذج</div>
            </div>
            <div class="feature">
                <div class="feature-icon">🇸🇦</div>
                <div class="feature-title">سيادة رقمية</div>
                <div>Vision 2030</div>
            </div>
        </div>
        
        <div class="cta">
            <a href="/docs" class="btn">📚 API Documentation</a>
        </div>
        
        <div class="api-link">
            <p>Backend API: <a href="$backendUrl" target="_blank">$backendUrl</a></p>
        </div>
        
        <p style="margin-top: 40px; color: #888; font-size: 0.9rem;">
            "من الرماد ينهض العنقاء" 🔥<br>
            صُنع بـ ❤️ في المملكة العربية السعودية
        </p>
    </div>
</body>
</html>
"@

New-Item -ItemType Directory -Path "deploy-temp" -Force | Out-Null
$indexHtml | Out-File -FilePath "deploy-temp/index.html" -Encoding UTF8

Write-Host "   ✅ Landing page created" -ForegroundColor Green

Write-Host "`n📤 Step 7: Deploying to Static Web App..." -ForegroundColor Yellow
Write-Host "   → Getting deployment token..." -NoNewline

$deployToken = az staticwebapp secrets list `
    --name $frontendName `
    --resource-group $ResourceGroup `
    --query "properties.apiKey" `
    --output tsv

if ($deployToken) {
    Write-Host " ✅" -ForegroundColor Green
    
    Write-Host "   → Deploying files..." -NoNewline
    # Using Azure CLI to deploy
    az staticwebapp deploy `
        --name $frontendName `
        --resource-group $ResourceGroup `
        --app-location "deploy-temp" `
        --output none
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅" -ForegroundColor Green
    } else {
        Write-Host " ⚠️  Manual deployment needed" -ForegroundColor Yellow
    }
} else {
    Write-Host " ⚠️  Could not get deployment token" -ForegroundColor Yellow
}

Write-Host "
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║              ✅ Deployment Complete! 🎉                     ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
" -ForegroundColor Green

Write-Host "`n🌐 Your URLs:" -ForegroundColor Cyan
Write-Host "   • Frontend: https://$defaultHostname" -ForegroundColor White
Write-Host "   • Backend API: $backendUrl" -ForegroundColor White
Write-Host "   • API Docs: $backendUrl/docs" -ForegroundColor White

if (-not $SkipDNS) {
    Write-Host "`n📋 Next Steps for Custom Domain:" -ForegroundColor Yellow
    Write-Host "   1. Go to your DNS provider (e.g., GoDaddy, Namecheap)" -ForegroundColor White
    Write-Host "   2. Add CNAME record: $Domain → $defaultHostname" -ForegroundColor White
    Write-Host "   3. Wait for DNS propagation (up to 24 hours)" -ForegroundColor White
    Write-Host "   4. Verify: https://$Domain" -ForegroundColor White
}

Write-Host "`n🧪 Testing..." -ForegroundColor Yellow
Write-Host "   → Checking backend health..." -NoNewline
Start-Sleep -Seconds 5

try {
    $response = Invoke-WebRequest -Uri "$backendUrl/health" -TimeoutSec 10 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host " ✅ Healthy" -ForegroundColor Green
    }
} catch {
    Write-Host " ⚠️  Not ready yet (may take a few minutes)" -ForegroundColor Yellow
}

Write-Host "`n📊 Deployment Summary:" -ForegroundColor Cyan
Write-Host "   • Resource Group: $ResourceGroup" -ForegroundColor White
Write-Host "   • Location: $Location" -ForegroundColor White
Write-Host "   • Backend: gratech-api" -ForegroundColor White
Write-Host "   • Frontend: $frontendName" -ForegroundColor White
Write-Host "   • Domain: $Domain" -ForegroundColor White

Write-Host "`n🇸🇦 Made with ❤️  in Saudi Arabia | Vision 2030" -ForegroundColor Magenta
Write-Host "`nPress any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
