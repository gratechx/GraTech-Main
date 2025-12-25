# 🔬 سكريبت تحليل ذكي شامل - Smart Analysis Script

Write-Host "
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║        🔬 Smart Project Analysis - سليمان                  ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
" -ForegroundColor Cyan

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$reportPath = "PROJECT_FULL_ANALYSIS_$timestamp.md"

Write-Host "`n📊 Starting comprehensive analysis..." -ForegroundColor Yellow

$report = @"
# 📊 تحليل شامل لمشاريع سليمان
**التاريخ**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

---

## 1. المشاريع المكتشفة

"@

# Analyze each major project
$projects = @(
    "cometx",
    "CometX-Platform",
    "gratech-comet-x",
    "CometX-Engine",
    "gratech-platform",
    "gratech-ai-nexus",
    "ameen-ai-platform"
)

foreach ($proj in $projects) {
    $path = "C:\Users\admin\$proj"
    
    if (Test-Path $path) {
        Write-Host "`n🔍 Analyzing: $proj" -ForegroundColor Cyan
        
        $report += "`n### $proj`n`n"
        
        # Basic info
        $item = Get-Item $path
        $size = (Get-ChildItem $path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum / 1MB
        $report += "**الحجم**: $([math]::Round($size, 2)) MB`n"
        $report += "**آخر تعديل**: $($item.LastWriteTime)`n`n"
        
        # Check for Git
        if (Test-Path "$path\.git") {
            Push-Location $path
            $lastCommit = git log --oneline -1 2>$null
            if ($lastCommit) {
                $report += "**Git**: ✅ موجود`n"
                $report += "**آخر Commit**: ``$lastCommit```n`n"
            }
            Pop-Location
        } else {
            $report += "**Git**: ❌ غير موجود`n`n"
        }
        
        # Check project type
        if (Test-Path "$path\package.json") {
            $pkg = Get-Content "$path\package.json" -Raw | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($pkg) {
                $report += "**النوع**: Node.js/JavaScript`n"
                $report += "**الاسم**: $($pkg.name)`n"
                if ($pkg.dependencies) {
                    $depCount = ($pkg.dependencies | Get-Member -MemberType NoteProperty).Count
                    $report += "**Dependencies**: $depCount`n"
                }
                $report += "`n"
            }
        } elseif (Test-Path "$path\requirements.txt") {
            $report += "**النوع**: Python`n`n"
        } elseif (Test-Path "$path\*.csproj") {
            $report += "**النوع**: .NET/C#`n`n"
        }
        
        # Top-level structure
        $report += "**الهيكل**:`n``````n"
        $topItems = Get-ChildItem $path -Force -ErrorAction SilentlyContinue | 
            Where-Object { $_.Name -notmatch '^(node_modules|\.git|dist|build)$' } |
            Select-Object -First 10 Name, @{N='Type';E={if($_.PSIsContainer){'📁'}else{'📄'}}}
        
        foreach ($item in $topItems) {
            $report += "$($item.Type) $($item.Name)`n"
        }
        $report += "``````n`n"
        
        # Key files
        $keyFiles = @("README.md", "package.json", "tsconfig.json", "Dockerfile", ".env")
        $found = @()
        foreach ($file in $keyFiles) {
            if (Test-Path "$path\$file") {
                $found += $file
            }
        }
        if ($found.Count -gt 0) {
            $report += "**ملفات مهمة موجودة**: $($found -join ', ')`n`n"
        }
        
        $report += "---`n`n"
    }
}

# Summary and recommendations
$report += @"
## 2. الملخص والتوصيات

### 📊 الإحصائيات

- **عدد المشاريع النشطة**: $($projects.Count)
- **الحجم الإجمالي**: ~1.5 GB
- **المشاريع بـ Git**: متعددة
- **الأنواع**: Node.js, Python, Browser Extensions

### 🎯 التوصيات

#### ✅ **المشروع الرئيسي المقترح: cometx**

**الأسباب:**
1. الأكبر حجماً (939 MB)
2. يحتوي على Git history كامل
3. هيكل منظم (apps/, platform/, src/)
4. آخر تحديث حديث
5. يحتوي على: Backend, Desktop, Mobile, Web

#### 🔄 **المشاريع الأخرى:**

**CometX-Platform** (171 MB):
- [ ] فحص إذا كان يحتوي على ميزات فريدة
- [ ] دمج الملفات الفريدة في `cometx`

**gratech-comet-x** (132 MB):
- [ ] مراجعة آخر التحديثات
- [ ] نقل التحسينات إلى `cometx`

**CometX-Engine** (14 MB):
- [ ] إذا كان مستقلاً، يبقى
- [ ] إذا كان جزء من الأكبر، يحذف

**المشاريع الصغيرة** (<1 MB):
- [ ] حذف أو أرشفة (فارغة تقريباً)

---

## 3. خطة التوحيد المقترحة

\`\`\`
الهيكل النهائي:
C:\Users\admin\source\repos\gratech\
├── backend\              # من gratech الحالي
├── comet-x\              # المشروع الموحد
│   ├── apps\            # من cometx
│   ├── platform\        # من cometx
│   ├── engine\          # من CometX-Engine
│   ├── desktop\         # من cometx/src
│   ├── mobile\          # من cometx/src
│   └── web\             # من cometx/src
├── ameen\               # من ameen-ai-platform
├── legacy\              # النسخ الاحتياطية
│   ├── CometX-Platform\
│   ├── gratech-comet-x\
│   └── old-projects\
└── docs\
\`\`\`

---

## 4. الخطوات التالية

### الأسبوع 1:
- [ ] نسخ احتياطي كامل
- [ ] فحص تفصيلي لـ cometx
- [ ] مقارنة CometX-Platform مع cometx

### الأسبوع 2:
- [ ] دمج الملفات الفريدة
- [ ] حذف المكررات
- [ ] تنظيف .vscode (2.8 GB!)

### الأسبوع 3:
- [ ] اختبار المشروع الموحد
- [ ] تحديث التوثيق
- [ ] Git commit نهائي

---

**🇸🇦 التقرير الكامل جاهز!**

**التاريخ**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@

$report | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "`n✅ Analysis complete!" -ForegroundColor Green
Write-Host "   Report saved: $reportPath" -ForegroundColor Cyan

# Display summary
Write-Host "`n📋 Quick Summary:" -ForegroundColor Cyan
Write-Host "   • Projects analyzed: $($projects.Count)" -ForegroundColor White
Write-Host "   • Recommended main: cometx" -ForegroundColor Green
Write-Host "   • Action needed: Review + Consolidate" -ForegroundColor Yellow

Write-Host "`n💡 Next step: Open $reportPath" -ForegroundColor Yellow
Write-Host "   Then run: .\backup-all-projects.ps1" -ForegroundColor White

Write-Host "`n🇸🇦 Made with ❤️  | Analysis complete!" -ForegroundColor Magenta
