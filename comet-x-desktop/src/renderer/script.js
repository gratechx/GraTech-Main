/**
 * ✨ Comet-X Desktop - Renderer Script
 * The magical interface logic
 */

const chat = document.getElementById('chat');
const input = document.getElementById('input');
const sendBtn = document.getElementById('send');
const closeBtn = document.getElementById('close-btn');

// ============================================================================
// MESSAGE HANDLING
// ============================================================================

async function sendMessage() {
  const text = input.value.trim();
  if (!text) return;
  
  // Clear input
  input.value = '';
  
  // Remove welcome if exists
  const welcome = chat.querySelector('.welcome');
  if (welcome) welcome.remove();
  
  // Add user message
  addMessage(text, 'user');
  
  // Add thinking indicator
  const thinkingDiv = document.createElement('div');
  thinkingDiv.className = 'thinking';
  thinkingDiv.innerHTML = '💭 يفكر<span>.</span><span>.</span><span>.</span>';
  chat.appendChild(thinkingDiv);
  scrollToBottom();
  
  try {
    // Call AI processing
    const response = await window.electronAPI.processQuery(text);
    
    // Remove thinking
    thinkingDiv.remove();
    
    // Add response
    addMessage(response.text, 'assistant');
    
  } catch (error) {
    console.error('Error:', error);
    thinkingDiv.remove();
    addMessage('❌ عذراً، حدث خطأ في المعالجة.', 'assistant');
  }
}

function addMessage(text, sender) {
  const div = document.createElement('div');
  div.className = `message ${sender}`;
  div.textContent = text;
  chat.appendChild(div);
  scrollToBottom();
}

function scrollToBottom() {
  chat.scrollTop = chat.scrollHeight;
}

// ============================================================================
// EVENT LISTENERS
// ============================================================================

sendBtn.addEventListener('click', sendMessage);

input.addEventListener('keypress', (e) => {
  if (e.key === 'Enter') {
    sendMessage();
  }
});

closeBtn.addEventListener('click', async () => {
  await window.electronAPI.hideWindow();
});

// Focus input on window shown
window.electronAPI.onWindowShown(() => {
  input.focus();
});

// ============================================================================
// INITIALIZATION
// ============================================================================

console.log('✨ Comet-X Renderer - Ready!');
console.log('🇸🇦 Neural Sovereignty | Vision 2030');

// Focus input on load
window.addEventListener('load', () => {
  input.focus();
});
