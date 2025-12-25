/**
 * ✨ Comet-X Desktop - Main Process
 * The magical AI assistant that appears like ghost lighting
 * Built with ❤️  in Saudi Arabia 🇸🇦
 */

const { app, BrowserWindow, globalShortcut, Tray, Menu, ipcMain, screen } = require('electron');
const path = require('path');
const Store = require('electron-store');

// Configuration store
const store = new Store({
  defaults: {
    theme: 'dark',
    color: '#1ABC9C',
    hotkey: 'CommandOrControl+Shift+Space',
    autoStart: true,
    alwaysOnTop: true,
    opacity: 0.95
  }
});

let mainWindow = null;
let tray = null;
let isVisible = false;

// ============================================================================
// APP INITIALIZATION
// ============================================================================

app.whenReady().then(() => {
  createMainWindow();
  createTray();
  registerGlobalShortcuts();
  
  console.log('✨ Comet-X Desktop - Ready!');
  console.log('🇸🇦 Neural Sovereignty | Vision 2030');
});

// ============================================================================
// MAIN WINDOW - THE MAGICAL INTERFACE
// ============================================================================

function createMainWindow() {
  const { width, height } = screen.getPrimaryDisplay().workAreaSize;
  
  mainWindow = new BrowserWindow({
    width: 400,
    height: 600,
    x: width - 420,
    y: height - 620,
    frame: false,
    transparent: true,
    alwaysOnTop: store.get('alwaysOnTop'),
    skipTaskbar: true,
    resizable: false,
    show: false,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, '../preload/index.js')
    }
  });
  
  mainWindow.loadFile(path.join(__dirname, '../renderer/index.html'));
  
  // Show with fade-in animation
  mainWindow.once('ready-to-show', () => {
    if (store.get('autoStart')) {
      showWindow();
    }
  });
  
  // Hide on blur (optional)
  mainWindow.on('blur', () => {
    if (!mainWindow.webContents.isDevToolsOpened()) {
      // hideWindow(); // Uncomment if you want auto-hide
    }
  });
  
  // Dev tools in development
  if (process.argv.includes('--dev')) {
    mainWindow.webContents.openDevTools({ mode: 'detach' });
  }
}

// ============================================================================
// SHOW/HIDE WITH MAGIC ✨
// ============================================================================

function showWindow() {
  if (!mainWindow) return;
  
  mainWindow.setOpacity(0);
  mainWindow.show();
  
  // Fade in animation
  let opacity = 0;
  const fadeIn = setInterval(() => {
    opacity += 0.1;
    mainWindow.setOpacity(opacity);
    
    if (opacity >= store.get('opacity')) {
      clearInterval(fadeIn);
    }
  }, 20);
  
  isVisible = true;
  mainWindow.webContents.send('window-shown');
}

function hideWindow() {
  if (!mainWindow) return;
  
  // Fade out animation
  let opacity = store.get('opacity');
  const fadeOut = setInterval(() => {
    opacity -= 0.1;
    mainWindow.setOpacity(opacity);
    
    if (opacity <= 0) {
      clearInterval(fadeOut);
      mainWindow.hide();
    }
  }, 20);
  
  isVisible = false;
  mainWindow.webContents.send('window-hidden');
}

function toggleWindow() {
  if (isVisible) {
    hideWindow();
  } else {
    showWindow();
  }
}

// ============================================================================
// GLOBAL HOTKEY - THE MAGIC SPELL 🪄
// ============================================================================

function registerGlobalShortcuts() {
  const hotkey = store.get('hotkey');
  
  globalShortcut.register(hotkey, () => {
    console.log('✨ Magic spell activated!');
    toggleWindow();
  });
  
  console.log(`🪄 Hotkey registered: ${hotkey}`);
}

// ============================================================================
// SYSTEM TRAY
// ============================================================================

function createTray() {
  const iconPath = path.join(__dirname, '../../assets/icons/tray-icon.png');
  tray = new Tray(iconPath);
  
  const contextMenu = Menu.buildFromTemplate([
    {
      label: '✨ Show Comet-X',
      click: () => showWindow()
    },
    {
      label: '⚙️  Settings',
      click: () => {
        // Open settings window
      }
    },
    { type: 'separator' },
    {
      label: '🇸🇦 About',
      click: () => {
        // Show about dialog
      }
    },
    {
      label: '🚪 Quit',
      click: () => app.quit()
    }
  ]);
  
  tray.setToolTip('Comet-X - Magical AI Assistant');
  tray.setContextMenu(contextMenu);
  
  tray.on('click', () => {
    toggleWindow();
  });
}

// ============================================================================
// IPC HANDLERS
// ============================================================================

ipcMain.handle('get-config', () => {
  return store.store;
});

ipcMain.handle('set-config', (event, key, value) => {
  store.set(key, value);
  return true;
});

ipcMain.handle('hide-window', () => {
  hideWindow();
  return true;
});

ipcMain.handle('process-query', async (event, query) => {
  console.log('💭 Processing query:', query);
  
  // Simulate AI processing
  await new Promise(resolve => setTimeout(resolve, 1500));
  
  return {
    text: `فهمت سؤالك: "${query}"\n\nحالياً في وضع التطوير، لكن قريباً سأستطيع الإجابة بذكاء كامل! 💚\n\n🇸🇦 Neural Sovereignty | Vision 2030`,
    confidence: 0.85
  };
});

// ============================================================================
// APP LIFECYCLE
// ============================================================================

app.on('window-all-closed', () => {
  // Keep running in background (system tray)
  // Don't quit on window close
});

app.on('will-quit', () => {
  globalShortcut.unregisterAll();
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createMainWindow();
  }
});

// ============================================================================
// EXPORTS
// ============================================================================

module.exports = {
  showWindow,
  hideWindow,
  toggleWindow
};
