# 🔧 استكشاف الأخطاء وحلها - GraTech Platform

## المشاكل الشائعة والحلول

### 1. خطأ: "Unknown model: claude-opus-4-5"

**الأعراض:**
```json
{
  "error": {
    "code": "unknown_model",
    "message": "Unknown model: claude-opus-4-5"
  }
}
```

**السبب:**
- التطبيق يحاول استخدام النموذج من endpoint غير صحيح
- النموذج غير مضاف في `config/models.json`

**الحل:**
1. تأكد من وجود ملف `config/models.json`
2. تأكد من صحة التكوين:
```json
{
  "claude-opus-4-5": {
    "provider": "azure-foundry",
    "endpoint": "https://alshammaris-2770-resource.services.ai.azure.com/api/projects/alshammaris-2770",
    "deployment": "claude-opus-4-5",
    "apiVersion": "2025-11-15-preview"
  }
}
```
3. أعد تشغيل الخادم

---

### 2. خطأ: "API key not found"

**الأعراض:**
```
KeyError: 'AZURE_OPENAI_API_KEY'
```

**السبب:**
- ملف `.env.production` غير موجود أو فارغ
- المفتاح غير محدد

**الحل:**
1. انسخ القالب:
```bash
cp .env.production.template .env.production
```

2. احصل على المفاتيح:

**لـ Azure OpenAI:**
```bash
az cognitiveservices account keys list \
  --name gratech-aoai \
  --resource-group <your-rg>
```

أو من البوابة: Azure Portal → Cognitive Services → gratech-aoai → Keys

**لـ Azure Foundry:**
المفتاح موجود بالفعل في القالب.

3. أضف المفاتيح في `.env.production`

---

### 3. خطأ: "Connection timeout"

**الأعراض:**
```
httpx.ConnectTimeout: timed out
```

**الأسباب المحتملة:**
- مشكلة في الشبكة
- Firewall يحجب الاتصال
- Endpoint غير صحيح
- المفتاح منتهي أو غير صحيح

**الحل:**
1. اختبر الاتصال بالإنترنت:
```bash
ping 8.8.8.8
```

2. اختبر الاتصال بـ Azure:
```bash
curl https://gratech-aoai.openai.azure.com/
```

3. تأكد من صحة المفاتيح:
```bash
python test.py test
```

4. تحقق من Firewall/Proxy:
```bash
# إذا كنت خلف proxy
export HTTPS_PROXY=http://proxy:port
```

---

### 4. خطأ: "Rate limit exceeded"

**الأعراض:**
```json
{
  "error": {
    "code": "429",
    "message": "Requests to the ChatCompletions_Create Operation have exceeded rate limit"
  }
}
```

**السبب:**
- تجاوزت حد الطلبات المسموح (RPM/TPM)

**الحل:**
1. انتظر دقيقة واحدة
2. قلل عدد الطلبات
3. اطلب زيادة Quota:
   - Azure Portal → Cognitive Services → Quotas
   - أو املأ نموذج الطلب

---

### 5. خطأ: "Invalid API key"

**الأعراض:**
```json
{
  "error": {
    "code": "401",
    "message": "Access denied due to invalid subscription key"
  }
}
```

**السبب:**
- المفتاح خاطئ أو منتهي
- المفتاح من حساب مختلف

**الحل:**
1. احصل على مفتاح جديد:
```bash
az cognitiveservices account keys regenerate \
  --name gratech-aoai \
  --resource-group <your-rg> \
  --key-name key1
```

2. حدّث `.env.production`
3. أعد تشغيل الخادم

---

### 6. خطأ: "Module not found"

**الأعراض:**
```python
ModuleNotFoundError: No module named 'fastapi'
```

**السبب:**
- المكتبات غير مثبتة
- Virtual environment غير مفعّل

**الحل:**
```bash
# تثبيت المكتبات
pip install -r requirements.txt

# أو إنشاء virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
.\venv\Scripts\activate   # Windows
pip install -r requirements.txt
```

---

### 7. مشكلة: النموذج بطيء جداً

**الأعراض:**
- الاستجابة تستغرق أكثر من 30 ثانية

**الأسباب المحتملة:**
- `max_tokens` كبير جداً
- النموذج مشغول
- مشكلة في الشبكة

**الحل:**
1. قلل `max_tokens`:
```python
await gateway.chat(
    model="gpt-4o",
    messages=messages,
    max_tokens=500  # بدلاً من 4000
)
```

2. استخدم نموذج أسرع:
```python
model="o3-mini"  # أسرع من gpt-4o
```

3. زد timeout:
```python
async with httpx.AsyncClient(timeout=120.0) as client:
    ...
```

---

### 8. خطأ في Docker: "Cannot connect to Docker daemon"

**الأعراض:**
```
error during connect: This error may indicate that the docker daemon is not running
```

**الحل:**
```bash
# Windows
Start-Service docker

# Linux
sudo systemctl start docker

# Mac
open -a Docker
```

---

### 9. خطأ في Azure: "Resource group not found"

**الأعراض:**
```
ResourceGroupNotFound: Resource group 'gratech-cometx_group' could not be found
```

**الحل:**
1. أنشئ Resource Group:
```bash
az group create \
  --name gratech-cometx_group \
  --location uaenorth
```

2. أو عدّل السكريبت لاستخدام RG موجود:
```powershell
.\deploy-azure.ps1 -ResourceGroup "your-existing-rg"
```

---

### 10. مشكلة: النماذج لا تظهر في `/api/models`

**السبب:**
- ملف `config/models.json` غير موجود أو تالف

**الحل:**
1. تأكد من وجود الملف:
```bash
ls config/models.json
```

2. تحقق من صحة JSON:
```bash
python -m json.tool config/models.json
```

3. إذا كان تالفاً، استعد النسخة الأصلية من المستودع

---

## أدوات التشخيص

### اختبار شامل
```bash
python test.py test
```

### اختبار نموذج محدد
```bash
python test.py model gpt-4o "مرحباً"
```

### فحص الصحة
```bash
curl http://localhost:8000/health
```

### السجلات
```bash
# محلياً
tail -f logs/app.log

# على Azure
az containerapp logs show \
  --name cometx-backend \
  --resource-group gratech-cometx_group \
  --follow
```

---

## الحصول على المساعدة

إذا استمرت المشكلة:

1. **راجع الوثائق:**
   - `README.md`
   - `QUICKSTART.md`
   - `/docs` على الخادم

2. **افحص السجلات:**
   ```bash
   python src/main.py --debug
   ```

3. **اتصل بالدعم:**
   - البريد: admin@gratech.sa
   - الموقع: https://gratech.sa

---

**"لا تقلق، كل مشكلة لها حل!"** 💪
