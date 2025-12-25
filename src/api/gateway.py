"""
GraTech AI Gateway - بوابة موحدة لجميع النماذج
يدعم: GPT-4o, GPT-4.1, Claude Opus 4.5, DeepSeek R1, O3-mini
"""

import os
import json
from typing import Dict, Optional, List
from enum import Enum
import httpx
from dotenv import load_dotenv

load_dotenv()

class ModelProvider(Enum):
    AZURE_OPENAI = "azure-openai"
    AZURE_FOUNDRY = "azure-foundry"

class AIGateway:
    """بوابة موحدة للاتصال بجميع نماذج الذكاء الاصطناعي"""
    
    def __init__(self):
        # تحميل تكوين النماذج
        with open('config/models.json', 'r', encoding='utf-8') as f:
            self.config = json.load(f)
        
        # مفاتيح API
        self.openai_key = os.getenv('AZURE_OPENAI_API_KEY')
        self.foundry_key = os.getenv('AZURE_FOUNDRY_API_KEY')
        
    async def chat(
        self,
        model: str,
        messages: List[Dict[str, str]],
        temperature: float = 0.7,
        max_tokens: int = 4000,
        **kwargs
    ) -> Dict:
        """
        إرسال رسالة إلى أي نموذج
        
        Args:
            model: اسم النموذج (gpt-4o, claude-opus-4-5, etc.)
            messages: قائمة الرسائل
            temperature: درجة الإبداع (0-1)
            max_tokens: الحد الأقصى للرموز
            
        Returns:
            استجابة النموذج
        """
        
        if model not in self.config['models']:
            raise ValueError(f"النموذج '{model}' غير متاح. النماذج المتاحة: {list(self.config['models'].keys())}")
        
        model_config = self.config['models'][model]
        provider = model_config['provider']
        
        if provider == ModelProvider.AZURE_OPENAI.value:
            return await self._call_azure_openai(model_config, messages, temperature, max_tokens, **kwargs)
        elif provider == ModelProvider.AZURE_FOUNDRY.value:
            return await self._call_azure_foundry(model_config, messages, temperature, max_tokens, **kwargs)
        else:
            raise ValueError(f"مزود غير مدعوم: {provider}")
    
    async def _call_azure_openai(
        self,
        config: Dict,
        messages: List[Dict[str, str]],
        temperature: float,
        max_tokens: int,
        **kwargs
    ) -> Dict:
        """استدعاء Azure OpenAI"""
        
        url = f"{config['endpoint']}openai/deployments/{config['deployment']}/chat/completions?api-version={config['apiVersion']}"
        
        headers = {
            'api-key': self.openai_key,
            'Content-Type': 'application/json'
        }
        
        payload = {
            'messages': messages,
            'temperature': temperature,
            'max_tokens': max_tokens,
            **kwargs
        }
        
        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(url, json=payload, headers=headers)
            response.raise_for_status()
            return response.json()
    
    async def _call_azure_foundry(
        self,
        config: Dict,
        messages: List[Dict[str, str]],
        temperature: float,
        max_tokens: int,
        **kwargs
    ) -> Dict:
        """استدعاء Azure AI Foundry (Claude, DeepSeek)"""
        
        # للنماذج من Anthropic نستخدم Messages API
        if 'claude' in config['deployment'].lower():
            url = f"{config['endpoint']}/models/{config['deployment']}/chat/completions?api-version={config['apiVersion']}"
        else:
            url = f"{config['endpoint']}/chat/completions?api-version={config['apiVersion']}"
        
        headers = {
            'api-key': self.foundry_key,
            'Content-Type': 'application/json'
        }
        
        payload = {
            'model': config['deployment'],
            'messages': messages,
            'temperature': temperature,
            'max_tokens': max_tokens,
            **kwargs
        }
        
        async with httpx.AsyncClient(timeout=120.0) as client:
            response = await client.post(url, json=payload, headers=headers)
            
            if response.status_code != 200:
                error_detail = response.text
                raise Exception(f"خطأ في استدعاء {config['deployment']}: {response.status_code} - {error_detail}")
            
            return response.json()
    
    def list_models(self) -> List[Dict]:
        """الحصول على قائمة جميع النماذج المتاحة"""
        return [
            {
                'name': name,
                'description': info['description'],
                'provider': info['provider'],
                'region': info['region']
            }
            for name, info in self.config['models'].items()
        ]
    
    async def test_connection(self, model: str) -> bool:
        """اختبار الاتصال بنموذج معين"""
        try:
            result = await self.chat(
                model=model,
                messages=[{'role': 'user', 'content': 'مرحباً'}],
                max_tokens=50
            )
            return True
        except Exception as e:
            print(f"فشل الاتصال بـ {model}: {e}")
            return False


# مثال على الاستخدام
async def main():
    gateway = AIGateway()
    
    # اختبار جميع النماذج
    print("🧪 اختبار الاتصال بجميع النماذج...\n")
    
    for model_name in gateway.config['models'].keys():
        print(f"📡 اختبار {model_name}...")
        success = await gateway.test_connection(model_name)
        status = "✅ يعمل" if success else "❌ فشل"
        print(f"   {status}\n")
    
    # مثال على محادثة
    print("\n💬 مثال على محادثة مع Claude Opus:")
    response = await gateway.chat(
        model='claude-opus-4-5',
        messages=[
            {'role': 'user', 'content': 'اشرح لي الذكاء الاصطناعي بطريقة بسيطة'}
        ]
    )
    print(response)


if __name__ == '__main__':
    import asyncio
    asyncio.run(main())
