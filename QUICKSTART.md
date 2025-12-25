# 🚀 GraTech Platform - Quick Start Guide

دليل البدء السريع لتشغيل المنصة كاملة في 5 دقائق!

---

## ✅ المتطلبات

### 1. Backend API:
- Python 3.10+
- pip
- Azure Account (اختياري للنشر)

### 2. Comet-X Browser:
- Google Chrome 138+
- Windows 11 / macOS / Linux

---

## 🎯 البدء السريع (5 دقائق)

### الخطوة 1️⃣: استنساخ المشروع

```bash
git clone https://dev.azure.com/grar00t/gratech/_git/gratech
cd gratech
```

### الخطوة 2️⃣: إعداد Backend

```bash
# نسخ المتغيرات البيئية
cp .env.production.template .env.production

# تحرير الملف وإضافة مفاتيح API
# في Windows:
notepad .env.production

# في Mac/Linux:
nano .env.production
```

**املأ المفاتيح:**
```env
# Azure OpenAI (الحساب الحكومي)
AZURE_OPENAI_KEY=your-key-here
AZURE_OPENAI_ENDPOINT=https://gratech-aoai.openai.azure.com/

# Azure Foundry (الحساب الأكاديمي - للاستعارة فقط)
AZURE_FOUNDRY_KEY=your-key-here
AZURE_FOUNDRY_ENDPOINT=https://alshammaris-2770-resource.services.ai.azure.com/
```

### الخطوة 3️⃣: تثبيت وتشغيل

#### خيار A: تلقائي (موصى به! 🌟)

**Windows:**
```powershell
.\setup.ps1
```

**Mac/Linux:**
```bash
chmod +x setup.sh
./setup.sh
```

#### خيار B: يدوي

```bash
# تثبيت المتطلبات
pip install -r requirements.txt

# تشغيل Backend
python src/main.py
```

### الخطوة 4️⃣: تحميل Comet-X Browser

1. افتح Chrome
2. اذهب إلى: `chrome://extensions`
3. فعّل **"Developer mode"** (أعلى اليمين)
4. اضغط **"Load unpacked"**
5. اختر مجلد: `gratech/comet-x-browser/`

**✅ تم! Comet-X جاهز**

### الخطوة 5️⃣: اختبار

#### Backend API:
افتح: http://localhost:8000/docs

أو:
```bash
curl http://localhost:8000/health
```

#### Comet-X:
1. افتح tab جديد في Chrome
2. يجب أن ترى صفحة Comet-X
3. اضغط **Ctrl+Shift+C** لفتح Chat

---

## 🎮 استخدام سريع

### Backend API:

```bash
# إرسال رسالة
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4o",
    "messages": [
      {"role": "user", "content": "مرحباً!"}
    ]
  }'
```

### Comet-X:

1. **Chat**: اضغط `Ctrl+Shift+C`
2. **تلخيص**: حدد نص → Right Click → "Ask Comet-X"
3. **الذاكرة**: كل شيء يُحفظ تلقائياً
4. **إعدادات**: انقر على الـ Orb → Settings

---

## 🔧 حل المشاكل السريع

### Backend لا يعمل؟

```bash
# تحقق من Python
python --version  # يجب أن يكون 3.10+

# تحقق من المكتبات
pip list | grep fastapi

# أعد التثبيت
pip install -r requirements.txt --force-reinstall
```

### Comet-X لا يظهر؟

1. تأكد أن Chrome 138+
2. Developer mode مفعّل؟
3. أعد تحميل الإضافة:
   - `chrome://extensions`
   - اضغط 🔄 Reload

### API Keys لا تعمل؟

```bash
# تحقق من الملف
cat .env.production  # Mac/Linux
type .env.production  # Windows

# تأكد من عدم وجود مسافات زائدة
# الصيغة الصحيحة:
AZURE_OPENAI_KEY=sk-...
# وليس:
AZURE_OPENAI_KEY = sk-...  ❌
```

---

## 📚 الخطوات التالية

### تعلم المزيد:
- [📖 README الكامل](README.md)
- [🏗️ Architecture](docs/ARCHITECTURE.md)
- [❓ FAQ](FAQ.md)

### جرّب:
- استخدم نماذج مختلفة
- اختبر الذاكرة في Comet-X
- جرّب البحث الدلالي

### طوّر:
- أضف نماذج جديدة في `config/models.json`
- عدّل الواجهة في `comet-x-browser/`
- ساهم في المشروع!

---

## 💬 احتجت مساعدة؟

- **الوثائق**: [README.md](README.md)
- **Troubleshooting**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **البريد**: admin@gratech.sa
- **Twitter**: [@CometXApp](https://twitter.com/CometXApp)

---

**مبروك! 🎉 منصتك جاهزة الآن!**

**🇸🇦 صُنع بـ ❤️ في السعودية | Vision 2030**
