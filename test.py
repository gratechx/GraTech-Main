"""
اختبار شامل لجميع النماذج في GraTech Platform
"""

import asyncio
import sys
sys.path.append('src')

from api.gateway import AIGateway


async def test_all_models():
    """اختبار الاتصال بجميع النماذج"""
    
    print("=" * 60)
    print("🧪 اختبار منصة GraTech AI - جميع النماذج")
    print("=" * 60)
    print()
    
    gateway = AIGateway()
    
    # 1. عرض النماذج المتاحة
    print("📋 النماذج المتاحة:")
    print("-" * 60)
    for model in gateway.list_models():
        print(f"✓ {model['name']}")
        print(f"  الوصف: {model['description']}")
        print(f"  المزود: {model['provider']}")
        print(f"  المنطقة: {model['region']}")
        print()
    
    # 2. اختبار كل نموذج
    test_message = "مرحباً! قل لي شيئاً قصيراً عن نفسك."
    
    print("\n" + "=" * 60)
    print("🔬 اختبار الاتصال بكل نموذج:")
    print("=" * 60)
    print()
    
    results = {}
    
    for model_name in gateway.config['models'].keys():
        print(f"📡 اختبار: {model_name}")
        print("-" * 40)
        
        try:
            response = await gateway.chat(
                model=model_name,
                messages=[{'role': 'user', 'content': test_message}],
                max_tokens=100
            )
            
            # استخراج النص
            if 'choices' in response:
                text = response['choices'][0]['message']['content']
            elif 'content' in response:
                text = response['content'][0]['text']
            else:
                text = str(response)
            
            print(f"✅ نجح!")
            print(f"الرد: {text[:150]}...")
            results[model_name] = "✅ يعمل"
            
        except Exception as e:
            print(f"❌ فشل!")
            print(f"الخطأ: {str(e)}")
            results[model_name] = f"❌ خطأ: {str(e)[:50]}"
        
        print()
    
    # 3. ملخص النتائج
    print("\n" + "=" * 60)
    print("📊 ملخص النتائج:")
    print("=" * 60)
    print()
    
    for model, status in results.items():
        print(f"{model:20} → {status}")
    
    # 4. حساب معدل النجاح
    success_count = sum(1 for s in results.values() if "✅" in s)
    total_count = len(results)
    success_rate = (success_count / total_count) * 100
    
    print()
    print("=" * 60)
    print(f"✨ معدل النجاح: {success_count}/{total_count} ({success_rate:.1f}%)")
    print("=" * 60)
    
    if success_rate == 100:
        print("\n🎉 ممتاز! جميع النماذج تعمل بنجاح!")
    elif success_rate >= 60:
        print("\n⚠️  تحذير: بعض النماذج لا تعمل. راجع المفاتيح والإعدادات.")
    else:
        print("\n❌ خطأ: معظم النماذج لا تعمل. تحقق من:")
        print("   1. ملف .env.production يحتوي على المفاتيح الصحيحة")
        print("   2. الاتصال بالإنترنت")
        print("   3. صلاحيات Azure")


async def test_specific_model(model_name: str, question: str):
    """اختبار نموذج محدد بسؤال محدد"""
    
    print(f"\n🎯 اختبار {model_name} مع سؤال مخصص:")
    print("=" * 60)
    print(f"السؤال: {question}")
    print("-" * 60)
    
    gateway = AIGateway()
    
    try:
        response = await gateway.chat(
            model=model_name,
            messages=[{'role': 'user', 'content': question}],
            temperature=0.7,
            max_tokens=500
        )
        
        # استخراج النص
        if 'choices' in response:
            text = response['choices'][0]['message']['content']
        elif 'content' in response:
            text = response['content'][0]['text']
        else:
            text = str(response)
        
        print(f"✅ الرد:\n{text}")
        print("=" * 60)
        
    except Exception as e:
        print(f"❌ خطأ: {str(e)}")
        print("=" * 60)


async def interactive_test():
    """وضع تفاعلي لاختبار النماذج"""
    
    gateway = AIGateway()
    
    print("\n" + "=" * 60)
    print("💬 الوضع التفاعلي - GraTech AI")
    print("=" * 60)
    print()
    print("اكتب 'exit' للخروج، 'models' لعرض النماذج")
    print()
    
    # اختيار النموذج
    models = list(gateway.config['models'].keys())
    print("النماذج المتاحة:")
    for i, model in enumerate(models, 1):
        print(f"{i}. {model}")
    
    choice = input("\nاختر رقم النموذج: ").strip()
    
    try:
        model_name = models[int(choice) - 1]
        print(f"\n✓ تم اختيار: {model_name}\n")
    except:
        print("❌ اختيار غير صحيح. استخدام النموذج الافتراضي: gpt-4o")
        model_name = "gpt-4o"
    
    # المحادثة
    messages = []
    
    while True:
        user_input = input("أنت: ").strip()
        
        if user_input.lower() == 'exit':
            print("\n👋 وداعاً!")
            break
        
        if user_input.lower() == 'models':
            print("\nالنماذج المتاحة:")
            for model in gateway.list_models():
                print(f"  • {model['name']}: {model['description']}")
            print()
            continue
        
        if not user_input:
            continue
        
        messages.append({'role': 'user', 'content': user_input})
        
        try:
            print(f"\n{model_name}: ", end="", flush=True)
            
            response = await gateway.chat(
                model=model_name,
                messages=messages,
                temperature=0.7,
                max_tokens=2000
            )
            
            # استخراج النص
            if 'choices' in response:
                text = response['choices'][0]['message']['content']
            elif 'content' in response:
                text = response['content'][0]['text']
            else:
                text = str(response)
            
            print(text)
            print()
            
            messages.append({'role': 'assistant', 'content': text})
            
        except Exception as e:
            print(f"❌ خطأ: {str(e)}\n")


if __name__ == '__main__':
    import sys
    
    if len(sys.argv) > 1:
        command = sys.argv[1]
        
        if command == 'test':
            # اختبار جميع النماذج
            asyncio.run(test_all_models())
        
        elif command == 'model' and len(sys.argv) > 3:
            # اختبار نموذج محدد
            model_name = sys.argv[2]
            question = ' '.join(sys.argv[3:])
            asyncio.run(test_specific_model(model_name, question))
        
        elif command == 'interactive':
            # وضع تفاعلي
            asyncio.run(interactive_test())
        
        else:
            print("الاستخدام:")
            print("  python test.py test                    # اختبار جميع النماذج")
            print("  python test.py model <name> <question> # اختبار نموذج محدد")
            print("  python test.py interactive             # وضع تفاعلي")
    
    else:
        # افتراضياً: اختبار جميع النماذج
        asyncio.run(test_all_models())
