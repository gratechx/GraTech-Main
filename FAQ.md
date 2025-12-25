# ❓ الأسئلة الشائعة - GraTech AI Platform

## عام

### س1: ما هي النماذج المدعومة؟

**ج:** المنصة تدعم 5 نماذج قوية:

1. **GPT-4o** - الأفضل للمحادثات الذكية (OpenAI)
2. **GPT-4.1** - قوي ومستقر للإنتاج (OpenAI)
3. **Claude Opus 4.5** - الأذكى للبرمجة (Anthropic)
4. **DeepSeek R1** - متخصص في البحث (DeepSeek)
5. **O3-mini** - سريع واقتصادي (OpenAI)

---

### س2: هل أحتاج حساب Azure؟

**ج:** نعم، تحتاج:
- حساب Azure مع اشتراك نشط
- Azure OpenAI Service (لـ GPT)
- Azure AI Foundry (لـ Claude & DeepSeek)

---

### س3: كم التكلفة؟

**ج:** تعتمد على الاستخدام:

| النموذج | التكلفة التقريبية |
|---------|------------------|
| GPT-4o | $5-15 لكل مليون token |
| GPT-4.1 | $3-10 لكل مليون token |
| Claude Opus | $15-30 لكل مليون token |
| DeepSeek | $1-3 لكل مليون token |
| O3-mini | $0.5-1 لكل مليون token |

💡 **نصيحة:** استخدم O3-mini للمهام البسيطة للتوفير.

---

## التثبيت والإعداد

### س4: ما هي المتطلبات؟

**ج:**
- Python 3.9 أو أحدث
- pip
- Docker (للنشر)
- Azure CLI (للنشر على Azure)

---

### س5: كيف أحصل على مفاتيح API؟

**ج:**

**لـ GPT (Azure OpenAI):**
```bash
az cognitiveservices account keys list \
  --name gratech-aoai \
  --resource-group <your-rg>
```
أو من: Azure Portal → Cognitive Services → Keys

**لـ Claude & DeepSeek:**
المفتاح مضمن في الحساب الأكاديمي:
```
BLB5uqmGGZ2zCJukipGTd5QzQgwCEucsC1vTrmmDHi5hXOw5UqXWJQQJ99BLACHYHv6XJ3w3AAAAACOGT8UC
```

---

### س6: هل يمكنني استخدام المنصة مجاناً؟

**ج:** نعم، لكن مع قيود:
- Azure OpenAI: فترة تجريبية محدودة
- Claude/DeepSeek: عبر الحساب الأكاديمي (للاختبار فقط)

للإنتاج، ستحتاج اشتراك مدفوع.

---

## الاستخدام

### س7: كيف أرسل رسالة لنموذج؟

**ج:** عبر API:

```python
import requests

response = requests.post(
    "http://localhost:8000/api/chat",
    json={
        "model": "gpt-4o",
        "messages": [
            {"role": "user", "content": "مرحباً!"}
        ]
    }
)

print(response.json()['response'])
```

---

### س8: كيف أختار النموذج المناسب؟

**ج:** حسب المهمة:

| المهمة | النموذج الموصى به |
|--------|------------------|
| محادثة عامة | GPT-4o |
| برمجة متقدمة | Claude Opus |
| بحث وتحليل | DeepSeek R1 |
| ترجمة | GPT-4.1 |
| مهام بسيطة | O3-mini |

---

### س9: هل يمكنني استخدام أكثر من نموذج معاً؟

**ج:** نعم! مثال:

```python
# استخدم Claude للبرمجة
code = await gateway.chat(
    model="claude-opus-4-5",
    messages=[{"role": "user", "content": "اكتب كود Python"}]
)

# استخدم GPT لشرح الكود
explanation = await gateway.chat(
    model="gpt-4o",
    messages=[{"role": "user", "content": f"اشرح هذا الكود: {code}"}]
)
```

---

### س10: ما هو الحد الأقصى للرسالة؟

**ج:**

| النموذج | Context Window | Max Output |
|---------|---------------|-----------|
| GPT-4o | 128K tokens | 4K tokens |
| Claude Opus | 200K tokens | 64K tokens |
| DeepSeek | 64K tokens | 8K tokens |

💡 1 token ≈ 0.75 كلمة إنجليزية أو 0.5 كلمة عربية

---

## النشر

### س11: كيف أنشر المنصة على Azure؟

**ج:**

```bash
# طريقة 1: سكريبت تلقائي
.\deploy-azure.ps1

# طريقة 2: يدوياً
docker build -t gratech-backend .
az containerapp up --name gratech-backend ...
```

راجع `README.md` للتفاصيل.

---

### س12: هل يمكنني النشر على خوادم أخرى؟

**ج:** نعم! المنصة تعمل على:
- AWS (EC2, ECS, Lambda)
- Google Cloud (Cloud Run, GKE)
- Heroku
- DigitalOcean
- أي خادم يدعم Docker

---

### س13: كيف أضيف domain مخصص؟

**ج:**

1. في Azure Portal:
   - Container Apps → Settings → Custom domains
   - أضف domain الخاص بك

2. أو عبر CLI:
```bash
az containerapp hostname add \
  --name cometx-backend \
  --resource-group gratech-cometx_group \
  --hostname api.gratech.sa
```

---

## الأمان

### س14: هل المفاتيح آمنة؟

**ج:** نعم، إذا اتبعت الإرشادات:
- ✅ استخدم `.env` files (غير مضافة لـ Git)
- ✅ استخدم Azure Key Vault للإنتاج
- ✅ دوّر المفاتيح دورياً
- ❌ لا تنشر المفاتيح في الكود

---

### س15: كيف أحمي API من الاستخدام غير المصرح؟

**ج:**

1. **إضافة API Key:**
```python
# في main.py
from fastapi.security import HTTPBearer

security = HTTPBearer()

@app.post("/api/chat")
async def chat(request: ChatRequest, credentials = Depends(security)):
    if credentials.credentials != os.getenv("API_KEY"):
        raise HTTPException(401, "Unauthorized")
    ...
```

2. **Rate Limiting:**
```python
from slowapi import Limiter

limiter = Limiter(key_func=get_remote_address)

@app.post("/api/chat")
@limiter.limit("10/minute")
async def chat(...):
    ...
```

3. **CORS:**
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://gratech.sa"],  # فقط دومينك
    ...
)
```

---

## الأداء

### س16: كيف أحسّن السرعة؟

**ج:**

1. استخدم نموذج أسرع (O3-mini)
2. قلل `max_tokens`
3. استخدم caching:
```python
from functools import lru_cache

@lru_cache(maxsize=100)
def get_response(question):
    ...
```
4. استخدم streaming (للردود الطويلة)

---

### س17: كيف أتعامل مع الأحمال الكبيرة؟

**ج:**

1. **Scale out:**
```bash
az containerapp update \
  --name cometx-backend \
  --min-replicas 2 \
  --max-replicas 10
```

2. **Queue system:**
```python
# استخدم Azure Queue أو Redis
from azure.storage.queue import QueueClient
```

3. **Load balancer:**
```bash
az network application-gateway create ...
```

---

## المراقبة

### س18: كيف أراقب الأداء؟

**ج:**

1. **Application Insights:**
```python
from opencensus.ext.azure import metrics_exporter

exporter = metrics_exporter.new_metrics_exporter(
    connection_string=os.getenv("APPINSIGHTS_CONNECTION_STRING")
)
```

2. **Custom metrics:**
```python
@app.middleware("http")
async def log_requests(request, call_next):
    start = time.time()
    response = await call_next(request)
    duration = time.time() - start
    logger.info(f"Request took {duration:.2f}s")
    return response
```

3. **Azure Portal:**
   - Container Apps → Monitoring → Metrics

---

### س19: كيف أتتبع الأخطاء؟

**ج:**

```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/app.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

try:
    result = await gateway.chat(...)
except Exception as e:
    logger.error(f"Error: {e}", exc_info=True)
```

---

## دعم إضافي

### س20: أين أجد المزيد من المساعدة؟

**ج:**

- 📚 **الوثائق:** `README.md`, `QUICKSTART.md`, `TROUBLESHOOTING.md`
- 🌐 **الموقع:** https://gratech.sa
- 📧 **البريد:** admin@gratech.sa
- 💬 **Discord:** [قريباً]
- 📖 **الوثائق التفاعلية:** `http://localhost:8000/docs`

---

**"أي سؤال آخر؟ نحن هنا لمساعدتك!"** 💚
