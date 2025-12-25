# 🧹 Azure Cleanup Script - تنظيف الموارد الزائدة

Write-Host "
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║        🧹 Azure Resources Cleanup                           ║
║           تنظيف الموارد الزائدة                            ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
" -ForegroundColor Yellow

Write-Host "`n⚠️  WARNING: This will delete unused resources!" -ForegroundColor Red
Write-Host "   Review carefully before proceeding." -ForegroundColor Yellow

## 📊 Current Resources Analysis

Write-Host "`n📊 Current Resources:" -ForegroundColor Cyan

# Get all resource groups
$allGroups = az group list | ConvertFrom-Json

Write-Host "`n🗂️  Resource Groups ($($allGroups.Count) total):" -ForegroundColor Yellow

# Categorize groups
$active = @()
$suspected = @()
$empty = @()

foreach ($group in $allGroups) {
    $resources = az resource list --resource-group $group.name | ConvertFrom-Json
    $count = $resources.Count
    
    $info = [PSCustomObject]@{
        Name = $group.name
        Location = $group.location
        Resources = $count
    }
    
    if ($count -eq 0) {
        $empty += $info
    } elseif ($group.name -match "Default|NetworkWatcher|auto-alerts|managed") {
        $suspected += $info
    } else {
        $active += $info
    }
}

## Active Groups (Keep These!)
Write-Host "`n✅ Active Groups (Keep):" -ForegroundColor Green
$active | Format-Table -AutoSize

## Suspected Duplicates/Unused
Write-Host "`n⚠️  Suspected Duplicates/Unused:" -ForegroundColor Yellow
$suspected | Format-Table -AutoSize

## Empty Groups
Write-Host "`n🗑️  Empty Groups (Can Delete):" -ForegroundColor Red
$empty | Format-Table -AutoSize

## Analysis Summary
Write-Host "`n📈 Summary:" -ForegroundColor Cyan
Write-Host "   • Active: $($active.Count)" -ForegroundColor Green
Write-Host "   • Suspected: $($suspected.Count)" -ForegroundColor Yellow
Write-Host "   • Empty: $($empty.Count)" -ForegroundColor Red

## Recommendations

Write-Host "`n🎯 Recommendations:" -ForegroundColor Cyan

Write-Host "`n1️⃣  Keep These (Active):" -ForegroundColor Green
Write-Host "   • rg-gratech-prod (NEW Backend API)" -ForegroundColor White
Write-Host "   • gratech-cometx_group (Comet-X)" -ForegroundColor White

Write-Host "`n2️⃣  Review These (Possibly Old):" -ForegroundColor Yellow
Write-Host "   • rg-sovereign-agent (Old? Check contents)" -ForegroundColor White
Write-Host "   • rg-ameen-ai-prod (Ameen - still needed?)" -ForegroundColor White
Write-Host "   • rg-comet-x (Duplicate of gratech-cometx?)" -ForegroundColor White
Write-Host "   • rg-cometopus (Unknown - check)" -ForegroundColor White

Write-Host "`n3️⃣  Safe to Delete:" -ForegroundColor Red
Write-Host "   • DefaultResourceGroup-* (Auto-created, usually empty)" -ForegroundColor White
Write-Host "   • NetworkWatcherRG (Auto-created)" -ForegroundColor White
Write-Host "   • azureapp-auto-alerts-* (Auto-created)" -ForegroundColor White
Write-Host "   • Empty groups" -ForegroundColor White

## Interactive Cleanup

Write-Host "`n💡 What would you like to do?" -ForegroundColor Cyan
Write-Host "   1. Delete EMPTY groups only (safest)" -ForegroundColor Green
Write-Host "   2. Delete empty + suspected unused" -ForegroundColor Yellow
Write-Host "   3. Show detailed contents of each group (before deleting)" -ForegroundColor White
Write-Host "   4. Exit (manual cleanup)" -ForegroundColor Gray

$choice = Read-Host "`nEnter choice (1-4)"

switch ($choice) {
    "1" {
        Write-Host "`n🗑️  Deleting empty groups..." -ForegroundColor Yellow
        
        if ($empty.Count -eq 0) {
            Write-Host "   ℹ️  No empty groups found!" -ForegroundColor Cyan
        } else {
            foreach ($group in $empty) {
                Write-Host "   → Deleting: $($group.Name)" -NoNewline
                az group delete --name $group.Name --yes --no-wait 2>$null
                Write-Host " ✅" -ForegroundColor Green
            }
            Write-Host "`n   ✅ Deletion queued (runs in background)" -ForegroundColor Green
        }
    }
    
    "2" {
        Write-Host "`n🗑️  Deleting empty + suspected..." -ForegroundColor Yellow
        Write-Host "   ⚠️  Are you sure? (y/N): " -NoNewline
        $confirm = Read-Host
        
        if ($confirm -eq "y" -or $confirm -eq "Y") {
            $toDelete = $empty + $suspected
            foreach ($group in $toDelete) {
                Write-Host "   → Deleting: $($group.Name)" -NoNewline
                az group delete --name $group.Name --yes --no-wait 2>$null
                Write-Host " ✅" -ForegroundColor Green
            }
            Write-Host "`n   ✅ Deletion queued" -ForegroundColor Green
        } else {
            Write-Host "   Cancelled." -ForegroundColor Gray
        }
    }
    
    "3" {
        Write-Host "`n📋 Detailed Contents:" -ForegroundColor Cyan
        
        foreach ($group in ($active + $suspected)) {
            Write-Host "`n📂 $($group.Name) ($($group.Resources) resources):" -ForegroundColor Yellow
            az resource list --resource-group $group.Name --query "[].{Name:name, Type:type}" --output table
        }
    }
    
    "4" {
        Write-Host "`n👋 Exiting. No changes made." -ForegroundColor Gray
    }
    
    default {
        Write-Host "`n❌ Invalid choice." -ForegroundColor Red
    }
}

## Generate Cleanup Report

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$reportPath = "CLEANUP_REPORT_$timestamp.md"

$report = @"
# 🧹 Azure Cleanup Report

**Date**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Summary

- **Total Resource Groups**: $($allGroups.Count)
- **Active (Keep)**: $($active.Count)
- **Suspected (Review)**: $($suspected.Count)
- **Empty (Delete)**: $($empty.Count)

## Active Groups (✅ Keep)

``````
$($active | Format-Table -AutoSize | Out-String)
``````

## Suspected Unused (⚠️ Review)

``````
$($suspected | Format-Table -AutoSize | Out-String)
``````

## Empty Groups (🗑️ Can Delete)

``````
$($empty | Format-Table -AutoSize | Out-String)
``````

## Recommendations

### 1. Container Apps Analysis

Current Container Apps:
- **gratech-api** (rg-gratech-prod) ✅ NEW - Keep
- **cometx-backend/frontend** (gratech-cometx_group) ⚠️ Review
- **backend/frontend** (rg-sovereign-agent) ⚠️ Old? Check if needed

**Action**: Decide which Container Apps to keep.

### 2. Duplicate Resource Groups

Possible duplicates:
- **rg-comet-x** vs **gratech-cometx_group**
- **rg-cometopus** vs other Comet projects

**Action**: Consolidate into one group.

### 3. Cost Optimization

High-cost resources to review:
- Multiple Container Apps running simultaneously
- Unused App Service Plans
- Old AI deployments

**Action**: Stop or delete unused deployments.

---

**Next Steps:**
1. Review active groups contents
2. Delete empty groups safely
3. Consolidate duplicates
4. Monitor costs after cleanup

**Generated**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@

$report | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "`n📄 Report saved: $reportPath" -ForegroundColor Green
Write-Host "`n🇸🇦 Cleanup script complete!" -ForegroundColor Magenta
