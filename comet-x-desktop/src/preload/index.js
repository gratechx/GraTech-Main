/**
 * ✨ Comet-X Desktop - Preload Script
 * Bridge between renderer and main process
 */

const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  // Get configuration
  getConfig: () => ipcRenderer.invoke('get-config'),
  
  // Set configuration
  setConfig: (key, value) => ipcRenderer.invoke('set-config', key, value),
  
  // Hide window
  hideWindow: () => ipcRenderer.invoke('hide-window'),
  
  // Process AI query
  processQuery: (query) => ipcRenderer.invoke('process-query', query),
  
  // Listen for window events
  onWindowShown: (callback) => {
    ipcRenderer.on('window-shown', callback);
  },
  
  onWindowHidden: (callback) => {
    ipcRenderer.on('window-hidden', callback);
  }
});

console.log('✨ Preload script loaded');
