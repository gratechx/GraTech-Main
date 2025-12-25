# 🌐 دليل النشر على gratech.sa

## ✅ الوضع الحالي

| العنصر | الحالة | الملاحظات |
|--------|---------|-----------|
| **Domain** | ✅ مسجل | gratech.sa |
| **DNS** | ⚠️ يحتاج إعداد | www.gratech.sa موجه لـ Azure |
| **Backend** | ✅ جاهز | FastAPI + AI Gateway |
| **Frontend** | ✅ جاهز | Landing Page |

---

## 🚀 خطوات النشر

### الطريقة 1: تلقائي (موصى به)

```powershell
# نشر كامل بضغطة واحدة
.\deploy-gratech-sa.ps1
```

### الطريقة 2: يدوي

```powershell
# 1. نشر Backend
.\deploy-azure.ps1 -ResourceGroup "rg-gratech-prod" -Location "uaenorth"

# 2. نشر Frontend
.\deploy-gratech-sa.ps1 -SkipDNS

# 3. إعداد DNS يدوياً (انظر أدناه)
```

---

## 🔧 إعداد DNS

### خيار 1: إذا كان Domain مع Azure DNS

```powershell
# إنشاء DNS Zone
az network dns zone create `
  --name gratech.sa `
  --resource-group rg-gratech-prod

# إضافة CNAME للـ www
az network dns record-set cname set-record `
  --zone-name gratech.sa `
  --resource-group rg-gratech-prod `
  --record-set-name www `
  --cname [YOUR_STATIC_APP].azurestaticapps.net

# إضافة A Record للـ root
az network dns record-set a add-record `
  --zone-name gratech.sa `
  --resource-group rg-gratech-prod `
  --record-set-name @ `
  --ipv4-address [YOUR_IP]
```

### خيار 2: إذا كان Domain مع مزود خارجي (GoDaddy, Namecheap...)

1. سجل دخول على لوحة التحكم
2. اذهب إلى DNS Management
3. أضف السجلات التالية:

| النوع | الاسم | القيمة |
|------|-------|--------|
| CNAME | www | [your-app].azurestaticapps.net |
| A | @ | [Your Azure IP] |
| TXT | _dnsauth | [Verification Token from Azure] |

---

## 🧪 الفحص والاختبار

### 1. فحص DNS

```powershell
# فحص DNS
nslookup gratech.sa
nslookup www.gratech.sa

# أو باستخدام
Resolve-DnsName gratech.sa
```

### 2. فحص الموقع

```powershell
# Backend
curl https://[your-backend].azurecontainerapps.io/health

# Frontend
curl https://gratech.sa
curl https://www.gratech.sa
```

### 3. فحص SSL

```powershell
# تحقق من الشهادة
curl -I https://gratech.sa
```

---

## 🎯 الخطوات المتوقعة

### بعد تشغيل `deploy-gratech-sa.ps1`:

```
✅ Step 1: Azure Login
✅ Step 2: Create Resource Group
✅ Step 3: Deploy Backend API
   → gratech-api deployed to:
   → https://gratech-api--xxx.azurecontainerapps.io
   
✅ Step 4: Create Static Web App
   → Default URL: https://xxx.azurestaticapps.net
   
⚠️  Step 5: Configure DNS
   → Manual configuration needed
   → Add CNAME: gratech.sa → xxx.azurestaticapps.net
   
✅ Step 6: Create Landing Page
✅ Step 7: Deploy to Static Web App
```

---

## 📊 بعد النشر

### URLs المتوقعة:

```
Frontend (Landing):
├── Default: https://xxx.azurestaticapps.net
├── Custom: https://gratech.sa (بعد DNS)
└── Custom: https://www.gratech.sa

Backend API:
├── Base: https://gratech-api--xxx.azurecontainerapps.io
├── Docs: https://gratech-api--xxx.azurecontainerapps.io/docs
└── Health: https://gratech-api--xxx.azurecontainerapps.io/health
```

---

## ⏱️ المدة الزمنية

| الخطوة | المدة المتوقعة |
|--------|-----------------|
| Azure Login | 30 ثانية |
| Backend Deployment | 5-10 دقائق |
| Frontend Deployment | 2-5 دقائق |
| DNS Propagation | 1-24 ساعة |
| SSL Certificate | تلقائي (15-30 دقيقة) |

---

## 🐛 حل المشاكل

### المشكلة 1: "Backend not responding"

```powershell
# فحص Logs
az containerapp logs show `
  --name gratech-api `
  --resource-group rg-gratech-prod `
  --follow
```

### المشكلة 2: "DNS not resolving"

```powershell
# انتظر وحاول مرة أخرى
# DNS قد يأخذ حتى 24 ساعة للانتشار

# فحص من موقع خارجي:
# https://dnschecker.org
```

### المشكلة 3: "SSL Certificate error"

```powershell
# Azure يصدر الشهادة تلقائياً بعد التحقق من DNS
# تأكد من:
# 1. DNS صحيح
# 2. TXT record موجود للتحقق
# 3. انتظر 15-30 دقيقة
```

---

## 💰 التكاليف المتوقعة

| المورد | المستوى | التكلفة/شهر |
|--------|---------|-------------|
| Container App | Basic | ~$30 |
| Static Web App | Free | $0 |
| DNS Zone | Standard | ~$0.50 |
| **المجموع** | | **~$31/شهر** |

---

## 🔐 الأمان

### Checklist:

- [ ] HTTPS فقط (TLS 1.2+)
- [ ] CORS محدد
- [ ] API Keys في Environment Variables
- [ ] Rate limiting مفعّل
- [ ] Firewall rules مضبوطة
- [ ] Monitoring مفعّل

---

## 📞 المساعدة

### إذا واجهت مشاكل:

1. **راجع Logs**: 
   ```powershell
   az containerapp logs show --name gratech-api -g rg-gratech-prod --follow
   ```

2. **فحص الموارد**:
   ```powershell
   az resource list -g rg-gratech-prod --output table
   ```

3. **اتصل بالدعم**:
   - Email: admin@gratech.sa
   - Azure Support: portal.azure.com

---

## ✅ Checklist النشر الكامل

- [ ] تشغيل `deploy-gratech-sa.ps1`
- [ ] Backend deployed
- [ ] Frontend deployed
- [ ] DNS configured
- [ ] SSL certificate active
- [ ] https://gratech.sa يعمل
- [ ] https://www.gratech.sa يعمل
- [ ] API /health يرد 200
- [ ] API /docs يعمل
- [ ] Monitoring مفعّل

---

**🇸🇦 Made with ❤️  in Saudi Arabia | Vision 2030**

"من الرماد ينهض العنقاء" 🔥
