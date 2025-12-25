# ============================================================================
# GraTech Platform - Azure Deployment Script
# Complete deployment to Azure Container Apps
# ============================================================================

param(
    [string]$ResourceGroup = "rg-cometx-prod",
    [string]$Location = "uaenorth",
    [string]$AppName = "gratech-backend",
    [string]$Environment = "cometx-env",
    [string]$Registry = "cometxregistry",
    [switch]$SkipBuild
)

Write-Host "
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║        🚀 GraTech Platform - Azure Deployment               ║
║                                                              ║
║    Deploying Backend API to Azure Container Apps            ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
" -ForegroundColor Cyan

Write-Host "`n📋 Deployment Configuration:" -ForegroundColor Yellow
Write-Host "   • Resource Group: $ResourceGroup" -ForegroundColor White
Write-Host "   • Location: $Location" -ForegroundColor White
Write-Host "   • App Name: $AppName" -ForegroundColor White
Write-Host "   • Environment: $Environment" -ForegroundColor White
Write-Host "   • Registry: $Registry" -ForegroundColor White

Write-Host "`n🔐 Step 1: Azure Login..." -ForegroundColor Yellow
Write-Host "   → Checking Azure CLI..." -NoNewline

try {
    $currentAccount = az account show 2>$null | ConvertFrom-Json
    Write-Host " ✅" -ForegroundColor Green
    Write-Host "   → Logged in as: $($currentAccount.user.name)" -ForegroundColor Cyan
    Write-Host "   → Subscription: $($currentAccount.name)" -ForegroundColor Cyan
} catch {
    Write-Host " ❌ Not logged in" -ForegroundColor Red
    Write-Host "   → Logging in..." -NoNewline
    az login
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅" -ForegroundColor Green
    } else {
        Write-Host " ❌ Failed" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n📦 Step 2: Checking .env.production..." -ForegroundColor Yellow

if (-not (Test-Path ".env.production")) {
    Write-Host "   ❌ .env.production not found!" -ForegroundColor Red
    Write-Host "   → Please create it from .env.production.template" -ForegroundColor Yellow
    exit 1
}

# Read environment variables
$envVars = @{}
Get-Content ".env.production" | ForEach-Object {
    if ($_ -match "^([^#][^=]+)=(.+)$") {
        $envVars[$Matches[1].Trim()] = $Matches[2].Trim()
    }
}

Write-Host "   → Found $($envVars.Count) environment variables ✅" -ForegroundColor Green

# Validate required keys
$requiredKeys = @(
    "AZURE_FOUNDRY_API_KEY",
    "AZURE_FOUNDRY_ENDPOINT"
)

$missingKeys = $requiredKeys | Where-Object { -not $envVars.ContainsKey($_) -or $envVars[$_] -like "*YOUR*" -or $envVars[$_] -like "*REPLACE*" }

if ($missingKeys.Count -gt 0) {
    Write-Host "   ⚠️  Warning: Some keys may need updating:" -ForegroundColor Yellow
    $missingKeys | ForEach-Object { Write-Host "      - $_" -ForegroundColor Yellow }
    Write-Host "   → Continue anyway? (Y/N): " -NoNewline -ForegroundColor Yellow
    $response = Read-Host
    if ($response -ne "Y" -and $response -ne "y") {
        Write-Host "   → Deployment cancelled" -ForegroundColor Red
        exit 0
    }
}

if (-not $SkipBuild) {
    Write-Host "`n🏗️  Step 3: Building Docker Image..." -ForegroundColor Yellow
    Write-Host "   → Building image..." -NoNewline
    
    docker build -t ${AppName}:latest .
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅" -ForegroundColor Green
    } else {
        Write-Host " ❌ Build failed" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "`n⏭️  Step 3: Skipping build (--SkipBuild flag)" -ForegroundColor Yellow
}

Write-Host "`n☁️  Step 4: Checking Azure Resources..." -ForegroundColor Yellow

# Check Resource Group
Write-Host "   → Checking Resource Group..." -NoNewline
$rgExists = az group exists --name $ResourceGroup
if ($rgExists -eq "true") {
    Write-Host " ✅ Exists" -ForegroundColor Green
} else {
    Write-Host " ⚠️  Creating..." -ForegroundColor Yellow
    az group create --name $ResourceGroup --location $Location | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "      ✅ Created" -ForegroundColor Green
    } else {
        Write-Host "      ❌ Failed" -ForegroundColor Red
        exit 1
    }
}

# Check Container Registry
Write-Host "   → Checking Container Registry..." -NoNewline
$registryExists = az acr show --name $Registry --resource-group $ResourceGroup 2>$null
if ($registryExists) {
    Write-Host " ✅ Exists" -ForegroundColor Green
} else {
    Write-Host " ⚠️  Creating..." -ForegroundColor Yellow
    az acr create `
        --name $Registry `
        --resource-group $ResourceGroup `
        --location $Location `
        --sku Basic `
        --admin-enabled true | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "      ✅ Created" -ForegroundColor Green
    } else {
        Write-Host "      ❌ Failed" -ForegroundColor Red
        exit 1
    }
}

# Check Container Apps Environment
Write-Host "   → Checking Container Apps Environment..." -NoNewline
$envExists = az containerapp env show --name $Environment --resource-group $ResourceGroup 2>$null
if ($envExists) {
    Write-Host " ✅ Exists" -ForegroundColor Green
} else {
    Write-Host " ⚠️  Creating..." -ForegroundColor Yellow
    az containerapp env create `
        --name $Environment `
        --resource-group $ResourceGroup `
        --location $Location | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "      ✅ Created" -ForegroundColor Green
    } else {
        Write-Host "      ❌ Failed" -ForegroundColor Red
        exit 1
    }
}

if (-not $SkipBuild) {
    Write-Host "`n📤 Step 5: Pushing to Container Registry..." -ForegroundColor Yellow
    
    # Get ACR credentials
    $acrCreds = az acr credential show --name $Registry --output json | ConvertFrom-Json
    $acrServer = "${Registry}.azurecr.io"
    
    Write-Host "   → Logging in to ACR..." -NoNewline
    echo $acrCreds.passwords[0].value | docker login $acrServer -u $Registry --password-stdin | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅" -ForegroundColor Green
    } else {
        Write-Host " ❌" -ForegroundColor Red
        exit 1
    }
    
    # Tag image
    Write-Host "   → Tagging image..." -NoNewline
    docker tag ${AppName}:latest ${acrServer}/${AppName}:latest
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅" -ForegroundColor Green
    } else {
        Write-Host " ❌" -ForegroundColor Red
        exit 1
    }
    
    # Push image
    Write-Host "   → Pushing image..." -NoNewline
    docker push ${acrServer}/${AppName}:latest | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅" -ForegroundColor Green
    } else {
        Write-Host " ❌" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n🚀 Step 6: Deploying Container App..." -ForegroundColor Yellow

# Prepare environment variables for deployment
$envVarArgs = @()
foreach ($key in $envVars.Keys) {
    $envVarArgs += "${key}=$($envVars[$key])"
}

$acrServer = "${Registry}.azurecr.io"
$acrCreds = az acr credential show --name $Registry --output json | ConvertFrom-Json

Write-Host "   → Creating/Updating Container App..." -NoNewline

az containerapp create `
    --name $AppName `
    --resource-group $ResourceGroup `
    --environment $Environment `
    --image "${acrServer}/${AppName}:latest" `
    --target-port 8000 `
    --ingress external `
    --registry-server $acrServer `
    --registry-username $Registry `
    --registry-password $acrCreds.passwords[0].value `
    --cpu 1.0 `
    --memory 2.0Gi `
    --min-replicas 1 `
    --max-replicas 3 `
    --env-vars $envVarArgs | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host " ✅" -ForegroundColor Green
} else {
    Write-Host " ❌" -ForegroundColor Red
    Write-Host "`n   Trying update instead..." -ForegroundColor Yellow
    
    az containerapp update `
        --name $AppName `
        --resource-group $ResourceGroup `
        --image "${acrServer}/${AppName}:latest" `
        --set-env-vars $envVarArgs | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   → Update successful ✅" -ForegroundColor Green
    } else {
        Write-Host "   → Update failed ❌" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n✅ Step 7: Getting App URL..." -ForegroundColor Yellow

$appInfo = az containerapp show `
    --name $AppName `
    --resource-group $ResourceGroup `
    --query "{fqdn:properties.configuration.ingress.fqdn, provisioningState:properties.provisioningState}" `
    --output json | ConvertFrom-Json

$appUrl = "https://$($appInfo.fqdn)"

Write-Host "
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║              ✅ Deployment Complete! 🎉                     ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
" -ForegroundColor Green

Write-Host "`n🌐 App URL:" -ForegroundColor Cyan
Write-Host "   • API: $appUrl" -ForegroundColor White
Write-Host "   • Docs: $appUrl/docs" -ForegroundColor White
Write-Host "   • Health: $appUrl/health" -ForegroundColor White
Write-Host "   • Models: $appUrl/api/models" -ForegroundColor White

Write-Host "`n📊 Status:" -ForegroundColor Cyan
Write-Host "   • Provisioning State: $($appInfo.provisioningState)" -ForegroundColor White

Write-Host "`n🧪 Testing Deployment..." -ForegroundColor Yellow
Write-Host "   → Checking health endpoint..." -NoNewline

Start-Sleep -Seconds 5  # Wait for app to be ready

try {
    $response = Invoke-WebRequest -Uri "$appUrl/health" -TimeoutSec 10 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host " ✅ Healthy" -ForegroundColor Green
        $health = $response.Content | ConvertFrom-Json
        Write-Host "   → Status: $($health.status)" -ForegroundColor Green
        Write-Host "   → Version: $($health.version)" -ForegroundColor Green
    }
} catch {
    Write-Host " ⚠️  Not ready yet (may take a few minutes)" -ForegroundColor Yellow
}

Write-Host "`n📝 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Test API: curl $appUrl/health" -ForegroundColor White
Write-Host "   2. View Docs: Open $appUrl/docs" -ForegroundColor White
Write-Host "   3. Check Logs: az containerapp logs show --name $AppName --resource-group $ResourceGroup --follow" -ForegroundColor White
Write-Host "   4. Monitor: Azure Portal → Container Apps → $AppName" -ForegroundColor White

Write-Host "`n💬 Useful Commands:" -ForegroundColor Cyan
Write-Host "   • View logs: az containerapp logs show -n $AppName -g $ResourceGroup --follow" -ForegroundColor White
Write-Host "   • Restart: az containerapp restart -n $AppName -g $ResourceGroup" -ForegroundColor White
Write-Host "   • Scale: az containerapp update -n $AppName -g $ResourceGroup --min-replicas 2" -ForegroundColor White
Write-Host "   • Delete: az containerapp delete -n $AppName -g $ResourceGroup" -ForegroundColor White

Write-Host "`n🇸🇦 Made with ❤️  in Saudi Arabia | Vision 2030" -ForegroundColor Magenta
Write-Host "`nPress any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
