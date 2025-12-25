/**
 * 🎨 Comet-X Popup Script
 * Handles popup UI interactions
 */

console.log('🎨 Popup loaded');

// Get current tab
async function getCurrentTab() {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  return tab;
}

// Open sidebar button
document.getElementById('open-sidebar').addEventListener('click', async () => {
  const tab = await getCurrentTab();
  
  // Send message to content script
  chrome.tabs.sendMessage(tab.id, {
    type: 'TOGGLE_SIDEBAR'
  });
  
  window.close();
});

// Summarize page button
document.getElementById('summarize-page').addEventListener('click', async () => {
  const tab = await getCurrentTab();
  
  chrome.tabs.sendMessage(tab.id, {
    type: 'SUMMARIZE_PAGE'
  });
  
  window.close();
});

// Settings button
document.getElementById('open-settings').addEventListener('click', () => {
  chrome.runtime.openOptionsPage();
  window.close();
});

// Load stats
async function loadStats() {
  try {
    const memory = await chrome.storage.local.get('memory');
    
    if (memory.memory) {
      document.getElementById('memories-count').textContent = 
        memory.memory.episodic?.length || 0;
    }
    
    // Could add more stats here
  } catch (error) {
    console.error('Failed to load stats:', error);
  }
}

loadStats();

console.log('✅ Popup ready');
