# ============================================================================
# Evidence Collection Script - جمع الأدلة تلقائياً
# ============================================================================

Write-Host "
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     📁 Evidence Collection - Perplexity Incident            ║
║                                                              ║
║     جمع الأدلة تلقائياً من Azure                           ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
" -ForegroundColor Cyan

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$evidenceRoot = "evidence"

Write-Host "`n🔐 Step 1: Azure Login..." -ForegroundColor Yellow
Write-Host "   → Checking Azure CLI..." -NoNewline

try {
    az account show 2>$null | Out-Null
    Write-Host " ✅ Already logged in" -ForegroundColor Green
} catch {
    Write-Host " ⚠️  Not logged in" -ForegroundColor Yellow
    Write-Host "   → Logging in to Azure..." -NoNewline
    az login
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅" -ForegroundColor Green
    } else {
        Write-Host " ❌ Failed to login" -ForegroundColor Red
        exit 1
    }
}

# Get current subscription
$subscription = az account show --query "{name:name, id:id}" -o json | ConvertFrom-Json
Write-Host "   → Subscription: $($subscription.name)" -ForegroundColor Cyan
Write-Host "   → ID: $($subscription.id)" -ForegroundColor Cyan

Write-Host "`n📋 Step 2: Collecting Current Resources..." -ForegroundColor Yellow

# Export current resources
Write-Host "   → Exporting resource list..." -NoNewline
az resource list --output json > "$evidenceRoot/backups/current-resources-$timestamp.json"
if ($LASTEXITCODE -eq 0) {
    Write-Host " ✅" -ForegroundColor Green
    $resourceCount = (Get-Content "$evidenceRoot/backups/current-resources-$timestamp.json" | ConvertFrom-Json).Count
    Write-Host "   → Found $resourceCount resources" -ForegroundColor Green
} else {
    Write-Host " ❌" -ForegroundColor Red
}

# Export resource groups
Write-Host "   → Exporting resource groups..." -NoNewline
az group list --output json > "$evidenceRoot/backups/resource-groups-$timestamp.json"
if ($LASTEXITCODE -eq 0) {
    Write-Host " ✅" -ForegroundColor Green
} else {
    Write-Host " ❌" -ForegroundColor Red
}

# Export Cognitive Services
Write-Host "   → Exporting Cognitive Services..." -NoNewline
az cognitiveservices account list --output json > "$evidenceRoot/backups/cognitive-services-$timestamp.json"
if ($LASTEXITCODE -eq 0) {
    Write-Host " ✅" -ForegroundColor Green
} else {
    Write-Host " ❌" -ForegroundColor Red
}

Write-Host "`n📜 Step 3: Collecting Activity Logs..." -ForegroundColor Yellow

# Calculate date range (last 90 days)
$endDate = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
$startDate = (Get-Date).AddDays(-90).ToString("yyyy-MM-ddTHH:mm:ssZ")

Write-Host "   → Date range: $startDate to $endDate" -ForegroundColor Cyan
Write-Host "   → Fetching activity logs (this may take a while)..." -NoNewline

az monitor activity-log list `
  --start-time $startDate `
  --end-time $endDate `
  --output json > "$evidenceRoot/backups/activity-log-full-$timestamp.json"

if ($LASTEXITCODE -eq 0) {
    Write-Host " ✅" -ForegroundColor Green
    
    # Filter deletion events
    Write-Host "   → Filtering deletion events..." -NoNewline
    $logs = Get-Content "$evidenceRoot/backups/activity-log-full-$timestamp.json" | ConvertFrom-Json
    $deletions = $logs | Where-Object { $_.operationName -like "*delete*" }
    $deletions | ConvertTo-Json -Depth 10 > "$evidenceRoot/backups/deletion-events-$timestamp.json"
    Write-Host " ✅ Found $($deletions.Count) deletion events" -ForegroundColor Green
} else {
    Write-Host " ❌" -ForegroundColor Red
}

Write-Host "`n💰 Step 4: Collecting Cost Data..." -ForegroundColor Yellow

Write-Host "   → Exporting cost analysis..." -NoNewline
try {
    az consumption usage list `
      --start-date $startDate `
      --end-date $endDate `
      --output json > "$evidenceRoot/billing/usage-$timestamp.json" 2>$null
    Write-Host " ✅" -ForegroundColor Green
} catch {
    Write-Host " ⚠️  Limited access to billing" -ForegroundColor Yellow
}

Write-Host "`n📊 Step 5: Generating Summary Report..." -ForegroundColor Yellow

$summary = @"
# Evidence Collection Summary
**Date**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Subscription**: $($subscription.name)
**Subscription ID**: $($subscription.id)

## Current State

### Resources
- **Total Resources**: $resourceCount
- **Resource Groups**: $(((Get-Content "$evidenceRoot/backups/resource-groups-$timestamp.json" | ConvertFrom-Json).Count))
- **Cognitive Services**: $(((Get-Content "$evidenceRoot/backups/cognitive-services-$timestamp.json" | ConvertFrom-Json).Count))

### Activity Logs
- **Date Range**: $startDate to $endDate
- **Deletion Events**: $($deletions.Count)

## Files Generated

\`\`\`
$evidenceRoot/
├── backups/
│   ├── current-resources-$timestamp.json
│   ├── resource-groups-$timestamp.json
│   ├── cognitive-services-$timestamp.json
│   ├── activity-log-full-$timestamp.json
│   └── deletion-events-$timestamp.json
├── billing/
│   └── usage-$timestamp.json
└── COLLECTION_SUMMARY.md (this file)
\`\`\`

## Detailed Resources

### Cognitive Services Available

$(az cognitiveservices account list --query "[].{Name:name, Kind:kind, Location:location, SKU:sku.name}" --output table)

### Current Deployments (alshammaris-2770)

$(az cognitiveservices account deployment list --name alshammaris-2770-resource --resource-group rg-alshammaris-2770 --output table 2>$null)

## Next Steps

1. ✅ Review all JSON files in `backups/`
2. ✅ Check `deletion-events-*.json` for suspicious activity
3. ✅ Take screenshots of Azure Portal
4. ✅ Add video to `video/` folder
5. ✅ Complete the complaint document
6. ✅ Submit to sdaia

## Notes

- All files are timestamped: $timestamp
- Sensitive data (API keys) are NOT included
- Keep these files secure and confidential
- Make backup copies before submission

---

**🇸🇦 For Justice and Digital Sovereignty**
"@

$summary | Out-File -FilePath "$evidenceRoot/COLLECTION_SUMMARY.md" -Encoding UTF8

Write-Host "   → Summary report generated ✅" -ForegroundColor Green

Write-Host "
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║              ✅ Evidence Collection Complete! 🎉            ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
" -ForegroundColor Green

Write-Host "`n📁 Files Generated:" -ForegroundColor Cyan
Get-ChildItem -Path $evidenceRoot -Recurse -File | Select-Object FullName, Length

Write-Host "`n📝 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Review: evidence/COLLECTION_SUMMARY.md" -ForegroundColor White
Write-Host "   2. Screenshots: Take screenshots of Azure Portal" -ForegroundColor White
Write-Host "   3. Video: Place your video in evidence/video/" -ForegroundColor White
Write-Host "   4. Review: All JSON files for accuracy" -ForegroundColor White
Write-Host "   5. Complete: legal/OFFICIAL_COMPLAINT_SDAIA.md" -ForegroundColor White
Write-Host "   6. Submit: Package everything and submit" -ForegroundColor White

Write-Host "`n💬 Need help?" -ForegroundColor Yellow
Write-Host "   • Guide: evidence/EVIDENCE_GUIDE.md" -ForegroundColor White
Write-Host "   • Story: docs/THE_COMPLETE_STORY.md" -ForegroundColor White

Write-Host "`n🇸🇦 Made with ❤️  in Saudi Arabia | Vision 2030" -ForegroundColor Magenta
Write-Host "`nPress any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
