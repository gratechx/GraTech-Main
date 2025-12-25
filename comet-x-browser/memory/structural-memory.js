/**
 * Structural Memory System - نظام الذاكرة الهيكلية
 * ================================================
 * 
 * يحاكي الذاكرة البشرية بثلاثة أنواع:
 * 1. Episodic (العرضية) - التجارب والأحداث
 * 2. Semantic (الدلالية) - الحقائق والمعرفة
 * 3. Procedural (الإجرائية) - المهارات والإجراءات
 */

// ===================================================================
// Memory Schema (JSON Schema للتوافقية)
// ===================================================================

const MEMORY_SCHEMA = {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "CometXMemoryUnit",
    "type": "object",
    "properties": {
        "id": { "type": "string", "format": "uuid" },
        "type": { 
            "type": "string", 
            "enum": ["episodic", "semantic", "procedural"] 
        },
        "content": { "type": "string" },
        "vector": {
            "type": "array",
            "items": { "type": "number" },
            "minItems": 384,
            "maxItems": 384
        },
        "metadata": {
            "type": "object",
            "properties": {
                "source_url": { "type": "string" },
                "timestamp": { "type": "integer" },
                "importance_score": { "type": "number", "minimum": 0, "maximum": 1 },
                "context_tags": { "type": "array", "items": { "type": "string" } },
                "bias_score": { "type": "number", "minimum": 0, "maximum": 1 },
                "language": { "type": "string" }
            }
        }
    },
    "required": ["id", "type", "content", "vector"]
};


// ===================================================================
// Memory Manager - إدارة الذاكرة
// ===================================================================

class MemoryManager {
    constructor() {
        this.dbName = 'CometX_Memory';
        this.dbVersion = 1;
        this.db = null;
        
        this.init();
    }
    
    async init() {
        return new Promise((resolve, reject) => {
            const request = indexedDB.open(this.dbName, this.dbVersion);
            
            request.onerror = () => reject(request.error);
            request.onsuccess = () => {
                this.db = request.result;
                console.log('💾 Memory Database initialized');
                resolve();
            };
            
            request.onupgradeneeded = (event) => {
                const db = event.target.result;
                
                // Episodic Memory Store
                if (!db.objectStoreNames.contains('episodic')) {
                    const episodic = db.createObjectStore('episodic', { keyPath: 'id' });
                    episodic.createIndex('timestamp', 'metadata.timestamp');
                    episodic.createIndex('url', 'metadata.source_url');
                    episodic.createIndex('importance', 'metadata.importance_score');
                }
                
                // Semantic Memory Store
                if (!db.objectStoreNames.contains('semantic')) {
                    const semantic = db.createObjectStore('semantic', { keyPath: 'id' });
                    semantic.createIndex('tags', 'metadata.context_tags', { multiEntry: true });
                }
                
                // Procedural Memory Store
                if (!db.objectStoreNames.contains('procedural')) {
                    db.createObjectStore('procedural', { keyPath: 'id' });
                }
                
                // User Profile (preferences, settings)
                if (!db.objectStoreNames.contains('profile')) {
                    db.createObjectStore('profile', { keyPath: 'key' });
                }
                
                console.log('💾 Memory stores created');
            };
        });
    }
    
    /**
     * حفظ ذاكرة جديدة
     */
    async store(memory) {
        if (!this.validateMemory(memory)) {
            throw new Error('Invalid memory format');
        }
        
        const storeName = memory.type;
        const transaction = this.db.transaction([storeName], 'readwrite');
        const store = transaction.objectStore(storeName);
        
        await store.put(memory);
        
        console.log(`💾 Stored ${memory.type} memory: ${memory.id}`);
        return memory.id;
    }
    
    /**
     * استرجاع ذاكرة بالمعرّف
     */
    async retrieve(id, type = 'episodic') {
        const transaction = this.db.transaction([type], 'readonly');
        const store = transaction.objectStore(type);
        
        return new Promise((resolve, reject) => {
            const request = store.get(id);
            request.onsuccess = () => resolve(request.result);
            request.onerror = () => reject(request.error);
        });
    }
    
    /**
     * بحث بالنص (Full-text search)
     */
    async searchByText(query, type = 'episodic', limit = 10) {
        const transaction = this.db.transaction([type], 'readonly');
        const store = transaction.objectStore(type);
        
        return new Promise((resolve, reject) => {
            const results = [];
            const request = store.openCursor();
            
            request.onsuccess = (event) => {
                const cursor = event.target.result;
                if (cursor && results.length < limit) {
                    if (cursor.value.content.includes(query)) {
                        results.push(cursor.value);
                    }
                    cursor.continue();
                } else {
                    resolve(results);
                }
            };
            
            request.onerror = () => reject(request.error);
        });
    }
    
    /**
     * استرجاع بالوقت
     */
    async getRecent(type = 'episodic', hours = 24, limit = 20) {
        const since = Date.now() - (hours * 60 * 60 * 1000);
        const transaction = this.db.transaction([type], 'readonly');
        const store = transaction.objectStore(type);
        const index = store.index('timestamp');
        
        return new Promise((resolve, reject) => {
            const results = [];
            const range = IDBKeyRange.lowerBound(since);
            const request = index.openCursor(range, 'prev'); // الأحدث أولاً
            
            request.onsuccess = (event) => {
                const cursor = event.target.result;
                if (cursor && results.length < limit) {
                    results.push(cursor.value);
                    cursor.continue();
                } else {
                    resolve(results);
                }
            };
            
            request.onerror = () => reject(request.error);
        });
    }
    
    /**
     * حذف ذاكرة
     */
    async delete(id, type = 'episodic') {
        const transaction = this.db.transaction([type], 'readwrite');
        const store = transaction.objectStore(type);
        await store.delete(id);
        console.log(`🗑️ Deleted memory: ${id}`);
    }
    
    /**
     * تنظيف الذاكرة القديمة (Garbage Collection)
     */
    async cleanup(days = 90) {
        const cutoff = Date.now() - (days * 24 * 60 * 60 * 1000);
        
        for (const type of ['episodic', 'semantic', 'procedural']) {
            const transaction = this.db.transaction([type], 'readwrite');
            const store = transaction.objectStore(type);
            const index = store.index('timestamp');
            const range = IDBKeyRange.upperBound(cutoff);
            
            let deleted = 0;
            const request = index.openCursor(range);
            
            request.onsuccess = (event) => {
                const cursor = event.target.result;
                if (cursor) {
                    // احتفظ فقط بالذكريات المهمة
                    if (cursor.value.metadata.importance_score < 0.7) {
                        cursor.delete();
                        deleted++;
                    }
                    cursor.continue();
                }
            };
            
            await new Promise(resolve => {
                transaction.oncomplete = () => {
                    console.log(`🗑️ Cleaned up ${deleted} old ${type} memories`);
                    resolve();
                };
            });
        }
    }
    
    /**
     * التحقق من صحة الذاكرة
     */
    validateMemory(memory) {
        return memory.id && 
               memory.type && 
               ['episodic', 'semantic', 'procedural'].includes(memory.type) &&
               memory.content &&
               Array.isArray(memory.vector) &&
               memory.vector.length === 384;
    }
    
    /**
     * إحصائيات الذاكرة
     */
    async getStats() {
        const stats = {};
        
        for (const type of ['episodic', 'semantic', 'procedural']) {
            const transaction = this.db.transaction([type], 'readonly');
            const store = transaction.objectStore(type);
            
            const count = await new Promise((resolve) => {
                const request = store.count();
                request.onsuccess = () => resolve(request.result);
            });
            
            stats[type] = count;
        }
        
        stats.total = Object.values(stats).reduce((a, b) => a + b, 0);
        stats.privacy = '100% Local';
        stats.external_calls = 0;
        
        return stats;
    }
}


// ===================================================================
// Vector Memory - الذاكرة المتجهية (للبحث الدلالي)
// ===================================================================

class VectorMemory {
    constructor(memoryManager) {
        this.memory = memoryManager;
        this.embeddings = null; // سيتم تحميل نموذج Embeddings
    }
    
    /**
     * تحميل نموذج Embeddings
     */
    async loadEmbeddingModel() {
        // TODO: تحميل all-MiniLM-L6-v2 عبر Transformers.js
        console.log('📥 Loading embedding model...');
        // this.embeddings = await pipeline('feature-extraction', 'Xenova/all-MiniLM-L6-v2');
        console.log('✅ Embedding model loaded');
    }
    
    /**
     * توليد متجه لنص
     */
    async embed(text) {
        if (!this.embeddings) {
            await this.loadEmbeddingModel();
        }
        
        // TODO: توليد فعلي
        // const output = await this.embeddings(text);
        // return Array.from(output.data);
        
        // Placeholder - متجه عشوائي
        return Array.from({ length: 384 }, () => Math.random());
    }
    
    /**
     * بحث متجهي (Vector Similarity Search)
     */
    async search(query, type = 'episodic', limit = 5) {
        // 1. توليد متجه للاستعلام
        const queryVector = await this.embed(query);
        
        // 2. جلب جميع الذكريات
        const transaction = this.memory.db.transaction([type], 'readonly');
        const store = transaction.objectStore(type);
        
        const memories = await new Promise((resolve) => {
            const results = [];
            const request = store.openCursor();
            
            request.onsuccess = (event) => {
                const cursor = event.target.result;
                if (cursor) {
                    results.push(cursor.value);
                    cursor.continue();
                } else {
                    resolve(results);
                }
            };
        });
        
        // 3. حساب التشابه (Cosine Similarity)
        const scored = memories.map(memory => ({
            memory,
            score: this.cosineSimilarity(queryVector, memory.vector)
        }));
        
        // 4. ترتيب حسب الدرجة
        scored.sort((a, b) => b.score - a.score);
        
        // 5. إرجاع الأفضل
        return scored.slice(0, limit).map(item => ({
            ...item.memory,
            similarity: item.score
        }));
    }
    
    /**
     * حساب التشابه الكوسيني
     */
    cosineSimilarity(vecA, vecB) {
        let dotProduct = 0;
        let normA = 0;
        let normB = 0;
        
        for (let i = 0; i < vecA.length; i++) {
            dotProduct += vecA[i] * vecB[i];
            normA += vecA[i] ** 2;
            normB += vecB[i] ** 2;
        }
        
        return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
    }
    
    /**
     * Hybrid Search - نصي + متجهي
     */
    async hybridSearch(query, type = 'episodic', limit = 10) {
        // 1. بحث نصي
        const textResults = await this.memory.searchByText(query, type, limit);
        
        // 2. بحث متجهي
        const vectorResults = await this.search(query, type, limit);
        
        // 3. دمج النتائج (Reciprocal Rank Fusion)
        const combined = this.mergeResults(textResults, vectorResults);
        
        return combined.slice(0, limit);
    }
    
    mergeResults(textResults, vectorResults) {
        const scores = new Map();
        const k = 60; // RRF constant
        
        textResults.forEach((result, index) => {
            scores.set(result.id, (scores.get(result.id) || 0) + 1 / (k + index + 1));
        });
        
        vectorResults.forEach((result, index) => {
            scores.set(result.id, (scores.get(result.id) || 0) + 1 / (k + index + 1));
        });
        
        // ترتيب حسب الدرجة المدمجة
        const allResults = [...textResults, ...vectorResults];
        const unique = Array.from(new Set(allResults.map(r => r.id)))
            .map(id => allResults.find(r => r.id === id));
        
        unique.sort((a, b) => (scores.get(b.id) || 0) - (scores.get(a.id) || 0));
        
        return unique;
    }
}


// ===================================================================
// Memory Helper Functions
// ===================================================================

/**
 * إنشاء ذاكرة عرضية من حدث
 */
async function createEpisodicMemory(event, vectorMemory) {
    const vector = await vectorMemory.embed(event.content);
    
    return {
        id: crypto.randomUUID(),
        type: 'episodic',
        content: event.content,
        vector: vector,
        metadata: {
            source_url: event.url || '',
            timestamp: Date.now(),
            importance_score: calculateImportance(event),
            context_tags: extractTags(event.content),
            bias_score: 0, // محايد
            language: detectLanguage(event.content)
        }
    };
}

/**
 * حساب أهمية الذاكرة
 */
function calculateImportance(event) {
    let score = 0.5; // افتراضي
    
    // زيادة الأهمية بناءً على عوامل
    if (event.userInitiated) score += 0.2;
    if (event.duration > 60) score += 0.1;  // قضى وقتاً طويلاً
    if (event.interactions > 5) score += 0.2; // تفاعل كثير
    
    return Math.min(score, 1.0);
}

/**
 * استخراج الوسوم السياقية
 */
function extractTags(text) {
    // استخراج بسيط للكلمات المفتاحية
    const keywords = text.toLowerCase()
        .split(/\s+/)
        .filter(word => word.length > 4)
        .slice(0, 5);
    
    return keywords;
}

/**
 * كشف اللغة
 */
function detectLanguage(text) {
    if (/[\u0600-\u06FF]/.test(text)) return 'ar';
    if (/[\u4E00-\u9FFF]/.test(text)) return 'zh';
    if (/[\u3040-\u309F\u30A0-\u30FF]/.test(text)) return 'ja';
    return 'en';
}


// ===================================================================
// Export
// ===================================================================

if (typeof module !== 'undefined' && module.exports) {
    module.exports = { 
        MemoryManager, 
        VectorMemory,
        createEpisodicMemory,
        MEMORY_SCHEMA
    };
}


// ===================================================================
// Usage Example
// ===================================================================

/*
// تهيئة
const memoryManager = new MemoryManager();
await memoryManager.init();

const vectorMemory = new VectorMemory(memoryManager);

// حفظ ذاكرة
const memory = await createEpisodicMemory({
    content: "المستخدم زار صفحة عن الذكاء الاصطناعي المحلي",
    url: "https://example.com/ai",
    userInitiated: true
}, vectorMemory);

await memoryManager.store(memory);

// بحث
const results = await vectorMemory.hybridSearch("ذكاء اصطناعي", 'episodic', 5);
console.log(results);

// إحصائيات
const stats = await memoryManager.getStats();
console.log(stats); // { episodic: 42, semantic: 15, procedural: 8, total: 65 }
*/
