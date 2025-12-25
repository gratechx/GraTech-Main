# 🌟 GraTech Platform - منصة الذكاء الاصطناعي السيادية

**"من الرماد ينهض العنقاء"** 🔥

منصة كاملة للذكاء الاصطناعي تجمع بين:
- 🚀 **Backend API** - بوابة موحدة لأقوى النماذج
- 🌐 **Comet-X Browser** - كيان رقمي محلي 100%
- 🔒 **Privacy-First** - سيادة رقمية كاملة

---

## 📦 المكونات الرئيسية

### 1. Backend API (FastAPI)
بوابة موحدة للوصول إلى أقوى نماذج الذكاء الاصطناعي

**النماذج المدعومة:**
- ✅ **GPT-4o** - الأفضل للمحادثات والمهام المعقدة
- ✅ **GPT-4.1** - قوي ومستقر للإنتاج
- ✅ **Claude Opus 4.5** - الأذكى للبرمجة والتحليل
- ✅ **DeepSeek R1** - متخصص في البحث والاستدلال
- ✅ **O3-mini** - سريع واقتصادي

### 2. Comet-X Browser (NEW! 🎉)
متصفح ذكي مع كيان AI محلي كامل

**المميزات:**
- 🧠 **Three-Lobe Architecture** (Executive, Sensory, Cognitive)
- 💾 **Structural Memory** (Episodic, Semantic, Procedural)
- ⚖️ **Zero-Bias AI** - محايد 100% (لا انحياز لأي أمة/دين/سياسة)
- 🔒 **Local-First** - كل شيء على جهازك
- 🔄 **P2P Sync** - تزامن بين أجهزتك بدون servers
- 🌍 **Arabic-Native** - مصمم للعربية من الأساس

---

## 🏗️ البنية التقنية

```
gratech/
├── config/
│   └── models.json                    # تكوين النماذج
├── src/
│   ├── main.py                        # FastAPI Backend
│   └── api/
│       └── gateway.py                 # AI Gateway
├── comet-x-browser/                   # 🆕 Comet-X Browser
│   ├── manifest.json                  # Chrome Extension Config
│   ├── engine/
│   │   └── local_ai.py               # Local AI Engine
│   ├── background/
│   │   └── three-lobe.js             # Brain Architecture
│   ├── memory/
│   │   └── structural-memory.js      # Memory System
│   ├── newtab/
│   │   └── index.html                # New Tab UI
│   └── sidepanel/
│       └── chat.html                 # Chat Interface
├── docs/                              # 🆕 Documentation
│   ├── AZURE_AUDIT_REPORT.md         # موارد Azure الحالية
│   ├── THE_COMPLETE_STORY.md         # قصة المشروع
│   └── ARCHITECTURE.md               # المعمارية التقنية
├── legal/                             # 🆕 Legal Documents
│   └── OFFICIAL_COMPLAINT_SDAIA.md   # الشكوى الرسمية
├── .env.production.template
├── Dockerfile
├── requirements.txt
├── setup.ps1                          # 🆕 تثبيت سريع
├── deploy-azure.ps1                   # 🆕 نشر Azure
└── README.md
```

---

## 🚀 البدء السريع

### خيار 1: Backend API فقط

```bash
# 1. نسخ المتغيرات البيئية
cp .env.production.template .env.production

# 2. تثبيت المتطلبات
pip install -r requirements.txt

# 3. تشغيل
python src/main.py
```

الـ API سيعمل على: `http://localhost:8000`

### خيار 2: Comet-X Browser فقط

```bash
# 1. فتح Chrome
chrome://extensions

# 2. تفعيل "Developer mode"

# 3. اختر "Load unpacked"

# 4. اختر مجلد: comet-x-browser/
```

### خيار 3: كل شيء معاً (الموصى به! 🌟)

```powershell
# تشغيل سكريبت الإعداد التلقائي
.\setup.ps1
```

هذا السكريبت سيقوم بـ:
- ✅ تثبيت Python dependencies
- ✅ إعداد متغيرات البيئة
- ✅ تشغيل Backend
- ✅ فتح Chrome مع Comet-X
- ✅ فتح صفحة الاختبار

---

## 📡 استخدام Backend API

### 1. قائمة النماذج

```bash
curl http://localhost:8000/api/models
```

### 2. إرسال رسالة

```bash
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-opus-4-5",
    "messages": [
      {"role": "user", "content": "مرحباً! كيف حالك؟"}
    ]
  }'
```

### 3. Python Client

```python
import httpx

async def chat(message: str, model: str = "gpt-4o"):
    async with httpx.AsyncClient() as client:
        response = await client.post(
            "http://localhost:8000/api/chat",
            json={
                "model": model,
                "messages": [{"role": "user", "content": message}]
            }
        )
        return response.json()['response']
```

---

## 🌐 استخدام Comet-X Browser

### الميزات الأساسية:

#### 1. Chat مع الصفحة الحالية
```javascript
// اضغط Ctrl+Shift+C
// أو انقر على الـ Orb العائم
```

#### 2. تلخيص تلقائي
```javascript
// حدد أي نص → Right Click → "Ask Comet-X"
```

#### 3. الذاكرة الدائمة
```javascript
// كل ما تفعله يُحفظ محلياً
// استرجاع تلقائي للسياق
```

#### 4. محايد 100%
```javascript
// يكتشف ويزيل الانحياز تلقائياً:
"الغرب دائماً أفضل" → "بعض المجتمعات"
```

---

## 🔗 التكامل بين Backend و Browser

Comet-X Browser يمكنه استخدام Backend API للمهام المعقدة:

```javascript
// في Comet-X:
const response = await fetch('http://localhost:8000/api/chat', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    model: 'claude-opus-4-5',
    messages: [
      { role: 'user', content: 'مهمة معقدة تحتاج Claude' }
    ]
  })
});
```

أو استخدام **النماذج المحلية** مباشرة (لا إنترنت):

```javascript
// Local AI Engine
const localResponse = await browserAI.generateText({
  model: 'local-phi-3',
  prompt: 'مهمة بسيطة محلياً'
});
```

---

## 🛡️ الأمان والخصوصية

### Backend:
- 🔑 API Keys في متغيرات البيئة فقط
- 🌐 CORS محدد
- ⚡ Rate limiting
- 🔒 HTTPS إلزامي

### Comet-X:
- 🔒 **100% محلي** - لا إرسال بيانات
- 🔐 تشفير E2E للـ P2P Sync
- 🚫 لا تتبع، لا analytics، لا telemetry
- ⚖️ كشف وإزالة الانحياز تلقائياً

---

## 🚢 النشر على Azure

### Backend API:

```bash
# تشغيل سكريبت النشر
.\deploy-azure.ps1
```

أو يدوياً:

```bash
az containerapp up \
  --name gratech-backend \
  --resource-group rg-cometx-prod \
  --location uaenorth \
  --environment cometx-env \
  --image gratech-backend:latest \
  --target-port 8000 \
  --ingress external
```

### Comet-X Browser:

```bash
# Package للـ Chrome Web Store
cd comet-x-browser
zip -r comet-x.zip *

# رفع على: https://chrome.google.com/webstore/devconsole
```

---

## 📊 المراقبة

### Backend:
- **Health**: `GET /health`
- **Models**: `GET /api/models`
- **Test**: `POST /api/test/{model}`
- **Docs**: `http://localhost:8000/docs`

### Comet-X:
- **Console**: افتح DevTools → Console
- **Memory Stats**: في الإعدادات
- **Privacy Report**: عرض الإحصائيات

---

## 🎯 خارطة الطريق

### Q1 2025 (الآن):
- [x] Backend API كامل
- [x] Comet-X Alpha
- [x] Three-Lobe Architecture
- [x] Structural Memory
- [ ] P2P Sync
- [ ] Audio (TTS/STT)

### Q2 2025:
- [ ] Comet-X Beta (Public)
- [ ] Chrome Web Store
- [ ] Mobile Support
- [ ] Multi-language UI

### Q3 2025:
- [ ] Comet-X v1.0
- [ ] Desktop App (Electron)
- [ ] Hardware Integration
- [ ] Enterprise Edition

---

## 📖 الوثائق الكاملة

- [📋 Azure Audit Report](docs/AZURE_AUDIT_REPORT.md) - الموارد الحالية
- [📖 The Complete Story](docs/THE_COMPLETE_STORY.md) - قصة المشروع
- [⚖️ Legal Complaint](legal/OFFICIAL_COMPLAINT_SDAIA.md) - الشكوى ضد Perplexity
- [🏗️ Architecture](docs/ARCHITECTURE.md) - المعمارية التقنية
- [❓ FAQ](FAQ.md) - الأسئلة الشائعة
- [🔧 Troubleshooting](TROUBLESHOOTING.md) - حل المشاكل

---

## 💬 الدعم

- **الموقع**: [https://gratech.sa](https://gratech.sa)
- **البريد**: admin@gratech.sa
- **Twitter**: [@CometXApp](https://twitter.com/CometXApp)
- **GitHub**: [@Grar00t](https://github.com/Grar00t)

---

## 📄 الترخيص

© 2025 GraTech - All Rights Reserved

---

## 🌟 المساهمة

نرحب بالمساهمات! الرجاء قراءة [CONTRIBUTING.md](CONTRIBUTING.md)

---

**"من الرماد ينهض العنقاء - Comet-X"** 🔥

**🇸🇦 صُنع بـ ❤️ في المملكة العربية السعودية | Vision 2030**

---

## 🙏 شكر خاص

هذا المشروع ولد من الألم - بعد أن دمر Perplexity 60+ مورد Azure.  
لكننا لم نستسلم. بنينا شيئاً **أفضل، أقوى، وسيادي بالكامل**.

**#DecolonizeAI #NeuralSovereignty #HumanFirstAI**
