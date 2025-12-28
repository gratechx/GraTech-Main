FROM python:3.11-slim

WORKDIR /app

# تثبيت المتطلبات
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# نسخ الكود
COPY src/ ./src/
COPY config/ ./config/

# سيتم تعيين متغيرات البيئة بواسطة Azure Container Apps
# لا حاجة لنسخ .env.production

# تعريف المنفذ
EXPOSE 8000

# تشغيل التطبيق
CMD ["python", "src/main.py"]
