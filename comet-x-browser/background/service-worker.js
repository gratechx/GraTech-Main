/**
 * 🧠 Comet-X Service Worker - Executive Lobe
 * The orchestrator of all operations
 * Manages state, memory, and coordinates between lobes
 */

// ============================================================================
// 1. INITIALIZATION & LIFECYCLE
// ============================================================================

console.log('🚀 Comet-X Service Worker - Initializing...');

// Keep-alive mechanism (prevent premature termination)
let keepAliveInterval = null;

chrome.runtime.onInstalled.addListener(async (details) => {
  console.log('📦 Extension installed:', details.reason);
  
  if (details.reason === 'install') {
    await initializeExtension();
  } else if (details.reason === 'update') {
    await handleUpdate(details.previousVersion);
  }
  
  // Start keep-alive
  startKeepAlive();
});

chrome.runtime.onStartup.addListener(() => {
  console.log('🔄 Browser started - Rehydrating state...');
  rehydrateState();
  startKeepAlive();
});

// ============================================================================
// 2. KEEP-ALIVE MECHANISM (MV3 Workaround)
// ============================================================================

function startKeepAlive() {
  // Use alarms API to keep service worker alive
  chrome.alarms.create('keepAlive', { periodInMinutes: 0.5 });
  
  console.log('💓 Keep-alive started');
}

chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === 'keepAlive') {
    // Heartbeat - just being alive keeps the worker running
    // console.log('💓 Heartbeat');
  }
});

// ============================================================================
// 3. STATE MANAGEMENT (Hot & Cold Storage)
// ============================================================================

class StateManager {
  constructor() {
    this.hotCache = new Map(); // In-memory (fast)
  }
  
  // Hot state (session storage - survives worker restarts)
  async getHot(key) {
    if (this.hotCache.has(key)) {
      return this.hotCache.get(key);
    }
    
    const result = await chrome.storage.session.get(key);
    const value = result[key];
    
    if (value) {
      this.hotCache.set(key, value);
    }
    
    return value;
  }
  
  async setHot(key, value) {
    this.hotCache.set(key, value);
    await chrome.storage.session.set({ [key]: value });
  }
  
  // Cold state (local storage - permanent)
  async getCold(key) {
    const result = await chrome.storage.local.get(key);
    return result[key];
  }
  
  async setCold(key, value) {
    await chrome.storage.local.set({ [key]: value });
  }
}

const stateManager = new StateManager();

// ============================================================================
// 4. MESSAGE PASSING ARCHITECTURE
// ============================================================================

// Message bus for inter-lobe communication
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  console.log('📨 Message received:', message.type, 'from:', sender.tab?.id || 'extension');
  
  handleMessage(message, sender)
    .then(sendResponse)
    .catch(error => {
      console.error('❌ Message handling error:', error);
      sendResponse({ error: error.message });
    });
  
  return true; // Keep channel open for async response
});

async function handleMessage(message, sender) {
  const { type, payload } = message;
  
  switch (type) {
    case 'INIT_COMET':
      return await initializeComet(sender.tab?.id);
    
    case 'PAGE_CONTEXT':
      return await processPageContext(payload, sender.tab?.id);
    
    case 'USER_QUERY':
      return await processUserQuery(payload, sender.tab?.id);
    
    case 'SAVE_MEMORY':
      return await saveMemory(payload);
    
    case 'RETRIEVE_MEMORY':
      return await retrieveMemory(payload);
    
    case 'OPEN_SIDEBAR':
      return await openSidebar(sender.tab?.id);
    
    case 'HEALTH_CHECK':
      return { status: 'healthy', timestamp: Date.now() };
    
    default:
      console.warn('⚠️  Unknown message type:', type);
      return { error: 'Unknown message type' };
  }
}

// ============================================================================
// 5. OFFSCREEN DOCUMENT MANAGEMENT (Cognitive Lobe)
// ============================================================================

let offscreenDocumentCreated = false;

async function ensureOffscreenDocument() {
  if (offscreenDocumentCreated) {
    return true;
  }
  
  try {
    await chrome.offscreen.createDocument({
      url: chrome.runtime.getURL('offscreen/cognitive.html'),
      reasons: ['LOCAL_STORAGE'], // Reasons for keeping it alive
      justification: 'Run AI models and heavy computations'
    });
    
    offscreenDocumentCreated = true;
    console.log('🧠 Cognitive Lobe (Offscreen) created');
    
    return true;
  } catch (error) {
    if (error.message.includes('already exists')) {
      offscreenDocumentCreated = true;
      return true;
    }
    
    console.error('❌ Failed to create Offscreen Document:', error);
    return false;
  }
}

// Send message to Cognitive Lobe
async function sendToCognitive(message) {
  await ensureOffscreenDocument();
  
  return new Promise((resolve, reject) => {
    chrome.runtime.sendMessage(
      { target: 'cognitive', ...message },
      (response) => {
        if (chrome.runtime.lastError) {
          reject(chrome.runtime.lastError);
        } else {
          resolve(response);
        }
      }
    );
  });
}

// ============================================================================
// 6. CORE OPERATIONS
// ============================================================================

async function initializeExtension() {
  console.log('🎬 Initializing Comet-X for the first time...');
  
  // Set default configuration
  await stateManager.setCold('config', {
    version: '0.1.0',
    installedAt: Date.now(),
    theme: 'dark',
    color: '#1ABC9C',
    modelPreference: 'local',
    privacyMode: true
  });
  
  // Initialize memory database
  await stateManager.setCold('memory', {
    episodic: [],
    semantic: {},
    procedural: {}
  });
  
  // Create context menu
  chrome.contextMenus.create({
    id: 'comet-summarize',
    title: 'Summarize with Comet-X',
    contexts: ['selection', 'page']
  });
  
  chrome.contextMenus.create({
    id: 'comet-explain',
    title: 'Explain this',
    contexts: ['selection']
  });
  
  console.log('✅ Extension initialized');
}

async function handleUpdate(previousVersion) {
  console.log(`🔄 Updated from ${previousVersion} to 0.1.0`);
  // Migration logic here if needed
}

async function rehydrateState() {
  console.log('💧 Rehydrating state from storage...');
  
  // Load critical state into hot cache
  const config = await stateManager.getCold('config');
  if (config) {
    await stateManager.setHot('config', config);
  }
  
  console.log('✅ State rehydrated');
}

async function initializeComet(tabId) {
  console.log('🌟 Initializing Comet for tab:', tabId);
  
  // Initialize cognitive lobe
  await ensureOffscreenDocument();
  
  // Load user configuration
  const config = await stateManager.getHot('config');
  
  return {
    success: true,
    config,
    message: 'Comet-X initialized'
  };
}

async function processPageContext(context, tabId) {
  console.log('📄 Processing page context for tab:', tabId);
  
  // Store context in hot state
  await stateManager.setHot(`tab_${tabId}_context`, {
    ...context,
    timestamp: Date.now()
  });
  
  // Send to cognitive lobe for analysis
  const analysis = await sendToCognitive({
    type: 'ANALYZE_PAGE',
    payload: context
  });
  
  return {
    success: true,
    analysis
  };
}

async function processUserQuery(query, tabId) {
  console.log('💬 Processing query:', query);
  
  // Get page context
  const context = await stateManager.getHot(`tab_${tabId}_context`);
  
  // Retrieve relevant memories
  const memories = await retrieveMemory({
    query: query.text,
    limit: 5
  });
  
  // Send to cognitive lobe for reasoning
  const response = await sendToCognitive({
    type: 'PROCESS_QUERY',
    payload: {
      query,
      context,
      memories
    }
  });
  
  // Save interaction to episodic memory
  await saveMemory({
    type: 'episodic',
    content: {
      query: query.text,
      response: response.text,
      context: context?.title || 'Unknown',
      timestamp: Date.now()
    }
  });
  
  return response;
}

async function saveMemory(memory) {
  console.log('💾 Saving memory:', memory.type);
  
  const allMemories = await stateManager.getCold('memory') || {
    episodic: [],
    semantic: {},
    procedural: {}
  };
  
  if (memory.type === 'episodic') {
    allMemories.episodic.push(memory.content);
    
    // Keep only last 1000 episodes
    if (allMemories.episodic.length > 1000) {
      allMemories.episodic = allMemories.episodic.slice(-1000);
    }
  } else if (memory.type === 'semantic') {
    Object.assign(allMemories.semantic, memory.content);
  } else if (memory.type === 'procedural') {
    Object.assign(allMemories.procedural, memory.content);
  }
  
  await stateManager.setCold('memory', allMemories);
  
  return { success: true };
}

async function retrieveMemory(query) {
  console.log('🔍 Retrieving memories for:', query.query);
  
  const allMemories = await stateManager.getCold('memory');
  
  // Simple retrieval for now (will be enhanced with vector search)
  const recentEpisodes = allMemories.episodic.slice(-query.limit || -10);
  
  return {
    episodic: recentEpisodes,
    semantic: allMemories.semantic,
    procedural: allMemories.procedural
  };
}

async function openSidebar(tabId) {
  console.log('📂 Opening sidebar for tab:', tabId);
  
  await chrome.sidePanel.open({ tabId });
  
  return { success: true };
}

// ============================================================================
// 7. CONTEXT MENU HANDLERS
// ============================================================================

chrome.contextMenus.onClicked.addListener(async (info, tab) => {
  console.log('📋 Context menu clicked:', info.menuItemId);
  
  if (info.menuItemId === 'comet-summarize') {
    // Send message to content script to summarize
    chrome.tabs.sendMessage(tab.id, {
      type: 'SUMMARIZE_PAGE'
    });
  } else if (info.menuItemId === 'comet-explain') {
    // Explain selected text
    chrome.tabs.sendMessage(tab.id, {
      type: 'EXPLAIN_SELECTION',
      payload: { text: info.selectionText }
    });
  }
});

// ============================================================================
// 8. TAB MANAGEMENT
// ============================================================================

chrome.tabs.onActivated.addListener(async (activeInfo) => {
  console.log('🔄 Tab activated:', activeInfo.tabId);
  // Could update UI or load context here
});

chrome.tabs.onRemoved.addListener(async (tabId) => {
  console.log('🗑️  Tab closed:', tabId);
  // Clean up tab-specific state
  await stateManager.setHot(`tab_${tabId}_context`, null);
});

// ============================================================================
// 9. ERROR HANDLING
// ============================================================================

self.addEventListener('error', (event) => {
  console.error('❌ Service Worker error:', event.error);
});

self.addEventListener('unhandledrejection', (event) => {
  console.error('❌ Unhandled promise rejection:', event.reason);
});

// ============================================================================
// 10. EXPORTS & STATUS
// ============================================================================

console.log('✅ Comet-X Service Worker - Ready!');
console.log('💚 Executive Lobe online');
console.log('🇸🇦 Neural Sovereignty | Vision 2030');

// Export for testing
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    stateManager,
    handleMessage,
    saveMemory,
    retrieveMemory
  };
}
