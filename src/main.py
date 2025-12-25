"""
GraTech FastAPI Backend
API خلفية كاملة لمنصة GraTech
"""

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import os
from dotenv import load_dotenv

from api.gateway import AIGateway

load_dotenv()

app = FastAPI(
    title="GraTech AI Platform",
    description="منصة الذكاء الاصطناعي المتقدمة - بيت الحكمة",
    version="1.0.0"
)

# إعدادات CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("CORS_ORIGINS", "*").split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# تهيئة البوابة
gateway = AIGateway()


# Models
class Message(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    model: str
    messages: List[Message]
    temperature: Optional[float] = 0.7
    max_tokens: Optional[int] = 4000


class ChatResponse(BaseModel):
    model: str
    response: str
    usage: dict


# Routes
@app.get("/")
async def root():
    """الصفحة الرئيسية"""
    return {
        "app": "GraTech AI Platform",
        "version": "1.0.0",
        "status": "healthy",
        "message": "🚀 بيت الحكمة - الإنسان أولاً"
    }


@app.get("/health")
async def health_check():
    """فحص صحة النظام"""
    return {
        "status": "healthy",
        "message": "GraTech Platform is running!",
        "timestamp": "2025-12-25T00:00:00Z",
        "version": "1.0.0"
    }


@app.get("/api/models")
async def list_models():
    """قائمة جميع النماذج المتاحة"""
    return {
        "models": gateway.list_models(),
        "default": gateway.config['default'],
        "fallback": gateway.config['fallback']
    }


@app.post("/api/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """
    إرسال رسالة إلى نموذج AI
    
    يدعم:
    - gpt-4o
    - gpt-4.1
    - claude-opus-4-5
    - deepseek-r1
    - o3-mini
    """
    try:
        messages = [msg.dict() for msg in request.messages]
        
        result = await gateway.chat(
            model=request.model,
            messages=messages,
            temperature=request.temperature,
            max_tokens=request.max_tokens
        )
        
        # استخراج النص من الاستجابة
        if 'choices' in result:
            response_text = result['choices'][0]['message']['content']
            usage = result.get('usage', {})
        elif 'content' in result:
            response_text = result['content'][0]['text']
            usage = result.get('usage', {})
        else:
            response_text = str(result)
            usage = {}
        
        return ChatResponse(
            model=request.model,
            response=response_text,
            usage=usage
        )
    
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"خطأ في معالجة الطلب: {str(e)}"
        )


@app.post("/api/test/{model}")
async def test_model(model: str):
    """اختبار اتصال نموذج معين"""
    try:
        success = await gateway.test_connection(model)
        return {
            "model": model,
            "status": "connected" if success else "failed",
            "available": success
        }
    except Exception as e:
        return {
            "model": model,
            "status": "error",
            "error": str(e),
            "available": False
        }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=int(os.getenv("PORT", 8000)),
        log_level="info"
    )
