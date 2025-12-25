/**
 * 👁️ Comet-X Content Script - Sensory Lobe
 * The eyes and interface of Comet-X on every webpage
 * Perceives, injects UI, and communicates with Executive Lobe
 */

console.log('👁️ Comet-X Sensory Lobe - Activated');

// ============================================================================
// 1. INITIALIZATION
// ============================================================================

let cometInitialized = false;
let orbElement = null;
let sidebarElement = null;

async function initializeComet() {
  if (cometInitialized) return;
  
  console.log('🌟 Initializing Comet on:', window.location.href);
  
  try {
    // Notify service worker
    const response = await chrome.runtime.sendMessage({
      type: 'INIT_COMET'
    });
    
    console.log('✅ Comet initialized:', response);
    
    // Inject UI elements
    await injectOrb();
    
    // Capture page context
    await capturePageContext();
    
    cometInitialized = true;
  } catch (error) {
    console.error('❌ Comet initialization failed:', error);
  }
}

// ============================================================================
// 2. PAGE CONTEXT CAPTURE
// ============================================================================

async function capturePageContext() {
  const context = {
    url: window.location.href,
    title: document.title,
    domain: window.location.hostname,
    
    // Text content
    bodyText: document.body?.innerText.substring(0, 5000) || '',
    
    // Metadata
    description: document.querySelector('meta[name="description"]')?.content || '',
    keywords: document.querySelector('meta[name="keywords"]')?.content || '',
    
    // Structure
    headings: Array.from(document.querySelectorAll('h1, h2, h3')).map(h => ({
      tag: h.tagName,
      text: h.textContent.trim()
    })).slice(0, 20),
    
    links: Array.from(document.querySelectorAll('a[href]')).length,
    images: Array.from(document.querySelectorAll('img[src]')).length,
    
    // Timestamp
    capturedAt: Date.now()
  };
  
  // Send to service worker
  await chrome.runtime.sendMessage({
    type: 'PAGE_CONTEXT',
    payload: context
  });
  
  console.log('📄 Page context captured');
}

// ============================================================================
// 3. THE ORB - FLOATING UI
// ============================================================================

async function injectOrb() {
  if (orbElement) return; // Already injected
  
  // Create shadow DOM for isolation
  const shadowHost = document.createElement('div');
  shadowHost.id = 'comet-x-orb-host';
  shadowHost.style.cssText = `
    position: fixed;
    bottom: 20px;
    right: 20px;
    z-index: 2147483647;
    width: 60px;
    height: 60px;
  `;
  
  const shadow = shadowHost.attachShadow({ mode: 'open' });
  
  // Orb HTML
  shadow.innerHTML = `
    <style>
      .orb-container {
        position: relative;
        width: 60px;
        height: 60px;
        cursor: pointer;
      }
      
      .orb {
        width: 100%;
        height: 100%;
        border-radius: 50%;
        background: linear-gradient(135deg, #1ABC9C 0%, #16A085 100%);
        box-shadow: 0 4px 20px rgba(26, 188, 156, 0.4);
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s ease;
        animation: pulse 2s infinite;
      }
      
      .orb:hover {
        transform: scale(1.1);
        box-shadow: 0 6px 30px rgba(26, 188, 156, 0.6);
      }
      
      .orb-icon {
        width: 30px;
        height: 30px;
        fill: white;
      }
      
      @keyframes pulse {
        0%, 100% {
          box-shadow: 0 4px 20px rgba(26, 188, 156, 0.4);
        }
        50% {
          box-shadow: 0 4px 30px rgba(26, 188, 156, 0.7);
        }
      }
      
      .orb.thinking {
        animation: spin 1s linear infinite;
      }
      
      @keyframes spin {
        from { transform: rotate(0deg); }
        to { transform: rotate(360deg); }
      }
    </style>
    
    <div class="orb-container">
      <div class="orb" id="comet-orb">
        <svg class="orb-icon" viewBox="0 0 24 24">
          <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
        </svg>
      </div>
    </div>
  `;
  
  document.body.appendChild(shadowHost);
  orbElement = shadowHost;
  
  // Add click handler
  const orb = shadow.getElementById('comet-orb');
  orb.addEventListener('click', () => {
    toggleSidebar();
  });
  
  console.log('⭕ Orb injected');
}

// ============================================================================
// 4. SIDEBAR - CHAT INTERFACE
// ============================================================================

function toggleSidebar() {
  if (sidebarElement) {
    // Remove sidebar
    sidebarElement.remove();
    sidebarElement = null;
    console.log('📂 Sidebar closed');
  } else {
    // Create sidebar
    injectSidebar();
    console.log('📂 Sidebar opened');
  }
}

function injectSidebar() {
  const shadowHost = document.createElement('div');
  shadowHost.id = 'comet-x-sidebar-host';
  shadowHost.style.cssText = `
    position: fixed;
    top: 0;
    right: 0;
    width: 400px;
    height: 100vh;
    z-index: 2147483646;
  `;
  
  const shadow = shadowHost.attachShadow({ mode: 'open' });
  
  shadow.innerHTML = `
    <style>
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }
      
      .sidebar {
        width: 100%;
        height: 100%;
        background: #05261F;
        border-left: 2px solid #1ABC9C;
        display: flex;
        flex-direction: column;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        color: white;
        animation: slideIn 0.3s ease;
      }
      
      @keyframes slideIn {
        from {
          transform: translateX(100%);
        }
        to {
          transform: translateX(0);
        }
      }
      
      .sidebar-header {
        padding: 20px;
        background: linear-gradient(135deg, #1ABC9C 0%, #16A085 100%);
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      
      .sidebar-title {
        font-size: 20px;
        font-weight: 600;
      }
      
      .close-btn {
        background: transparent;
        border: none;
        color: white;
        font-size: 24px;
        cursor: pointer;
        padding: 0;
        width: 30px;
        height: 30px;
        display: flex;
        align-items: center;
        justify-content: center;
      }
      
      .close-btn:hover {
        background: rgba(255, 255, 255, 0.1);
        border-radius: 4px;
      }
      
      .chat-container {
        flex: 1;
        overflow-y: auto;
        padding: 20px;
        display: flex;
        flex-direction: column;
        gap: 15px;
      }
      
      .message {
        max-width: 80%;
        padding: 12px 16px;
        border-radius: 12px;
        line-height: 1.5;
      }
      
      .message.user {
        align-self: flex-end;
        background: #1ABC9C;
        color: white;
      }
      
      .message.assistant {
        align-self: flex-start;
        background: #0D3D35;
        border: 1px solid #1ABC9C;
      }
      
      .input-container {
        padding: 20px;
        border-top: 1px solid #1ABC9C;
        display: flex;
        gap: 10px;
      }
      
      .input-box {
        flex: 1;
        background: #0D3D35;
        border: 1px solid #1ABC9C;
        color: white;
        padding: 12px 16px;
        border-radius: 8px;
        font-size: 14px;
        outline: none;
      }
      
      .input-box:focus {
        border-color: #1ABC9C;
        box-shadow: 0 0 0 2px rgba(26, 188, 156, 0.2);
      }
      
      .send-btn {
        background: #1ABC9C;
        border: none;
        color: white;
        padding: 12px 24px;
        border-radius: 8px;
        cursor: pointer;
        font-weight: 600;
        transition: all 0.2s;
      }
      
      .send-btn:hover {
        background: #16A085;
        transform: translateY(-1px);
      }
      
      .send-btn:active {
        transform: translateY(0);
      }
      
      .welcome-message {
        text-align: center;
        color: #1ABC9C;
        margin-top: 100px;
      }
      
      .welcome-message h2 {
        font-size: 24px;
        margin-bottom: 10px;
      }
      
      .welcome-message p {
        color: #888;
      }
    </style>
    
    <div class="sidebar">
      <div class="sidebar-header">
        <div class="sidebar-title">💚 Comet-X</div>
        <button class="close-btn" id="close-sidebar">×</button>
      </div>
      
      <div class="chat-container" id="chat-container">
        <div class="welcome-message">
          <h2>مرحباً يا سليمان! 💚</h2>
          <p>كيف أقدر أساعدك اليوم؟</p>
        </div>
      </div>
      
      <div class="input-container">
        <input 
          type="text" 
          class="input-box" 
          id="message-input" 
          placeholder="اكتب رسالتك هنا..."
        />
        <button class="send-btn" id="send-btn">Send</button>
      </div>
    </div>
  `;
  
  document.body.appendChild(shadowHost);
  sidebarElement = shadowHost;
  
  // Add event listeners
  const closeBtn = shadow.getElementById('close-sidebar');
  const sendBtn = shadow.getElementById('send-btn');
  const input = shadow.getElementById('message-input');
  const chatContainer = shadow.getElementById('chat-container');
  
  closeBtn.addEventListener('click', () => toggleSidebar());
  
  sendBtn.addEventListener('click', () => sendMessage(input, chatContainer, shadow));
  
  input.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
      sendMessage(input, chatContainer, shadow);
    }
  });
}

async function sendMessage(input, chatContainer, shadow) {
  const text = input.value.trim();
  if (!text) return;
  
  // Clear input
  input.value = '';
  
  // Remove welcome message if exists
  const welcome = shadow.querySelector('.welcome-message');
  if (welcome) welcome.remove();
  
  // Add user message
  addMessage(chatContainer, text, 'user');
  
  // Add thinking indicator
  const thinkingMsg = addMessage(chatContainer, '💭 يفكر...', 'assistant');
  
  try {
    // Send to service worker
    const response = await chrome.runtime.sendMessage({
      type: 'USER_QUERY',
      payload: { text }
    });
    
    // Remove thinking indicator
    thinkingMsg.remove();
    
    // Add assistant response
    addMessage(chatContainer, response.text || 'عذراً، حدث خطأ.', 'assistant');
    
  } catch (error) {
    console.error('❌ Error sending message:', error);
    thinkingMsg.textContent = '❌ عذراً، حدث خطأ في الاتصال.';
  }
}

function addMessage(container, text, sender) {
  const msg = document.createElement('div');
  msg.className = `message ${sender}`;
  msg.textContent = text;
  container.appendChild(msg);
  
  // Scroll to bottom
  container.scrollTop = container.scrollHeight;
  
  return msg;
}

// ============================================================================
// 5. KEYBOARD SHORTCUTS
// ============================================================================

document.addEventListener('keydown', (e) => {
  // Ctrl+Shift+C (or Cmd+Shift+C on Mac)
  if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'C') {
    e.preventDefault();
    toggleSidebar();
  }
});

// ============================================================================
// 6. MESSAGE HANDLERS FROM SERVICE WORKER
// ============================================================================

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  console.log('📨 Message from service worker:', message.type);
  
  if (message.type === 'SUMMARIZE_PAGE') {
    summarizePage();
    sendResponse({ success: true });
  } else if (message.type === 'EXPLAIN_SELECTION') {
    explainSelection(message.payload.text);
    sendResponse({ success: true });
  }
  
  return true;
});

async function summarizePage() {
  console.log('📝 Summarizing page...');
  
  // Open sidebar if not open
  if (!sidebarElement) {
    injectSidebar();
  }
  
  // Show loading in sidebar
  // (Implementation would send to service worker for actual summarization)
  
  alert('📝 تلخيص الصفحة قيد التطوير!');
}

async function explainSelection(text) {
  console.log('💡 Explaining selection:', text);
  alert('💡 شرح النص قيد التطوير!');
}

// ============================================================================
// 7. AUTO-INITIALIZATION
// ============================================================================

// Initialize when page loads
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeComet);
} else {
  initializeComet();
}

// Re-initialize on navigation (for SPAs)
let lastUrl = location.href;
new MutationObserver(() => {
  const url = location.href;
  if (url !== lastUrl) {
    lastUrl = url;
    console.log('🔄 URL changed, re-capturing context');
    capturePageContext();
  }
}).observe(document, { subtree: true, childList: true });

// ============================================================================
// 8. STATUS
// ============================================================================

console.log('✅ Comet-X Sensory Lobe - Ready!');
console.log('👁️ Watching:', window.location.href);
console.log('💚 Press Ctrl+Shift+C to activate');
console.log('🇸🇦 Neural Sovereignty | Vision 2030');
