# ✨ Comet-X Desktop - Magical AI Assistant

**النسخة السحرية | The Ghost Lighting Edition**

A magical desktop AI assistant that appears like ghost lighting from Harry Potter! ⚡

---

## 🎯 **What is This?**

Comet-X Desktop هو مساعد ذكي **سحري** يطلع فجأة مثل السحر في هاري بوتر!

**Features:**
- ✨ **Appears magically** - Hotkey summons it
- 💚 **Turquoise theme** - Beautiful Saudi colors
- 🪄 **Ghost lighting effect** - Smooth animations
- ⚡ **Instant** - Fast and responsive
- 🧠 **Smart** - AI-powered responses
- 🇸🇦 **Saudi-made** - Vision 2030 aligned

---

## 🚀 **Installation**

### **Step 1: Install Node.js**

Download from: https://nodejs.org/

### **Step 2: Install Dependencies**

```bash
cd comet-x-desktop
npm install
```

### **Step 3: Run**

```bash
npm start
```

---

## ⚡ **Usage**

### **Summon the Magic:**

**Hotkey:** `Ctrl + Shift + Space`

Press it anywhere, anytime - Comet-X appears! ✨

### **Interface:**

```
╔══════════════════════════╗
║        ✨ Comet-X        ║
║   مساعدك الذكي السيادي  ║
╠══════════════════════════╣
║                          ║
║   💬 Chat appears here   ║
║                          ║
╠══════════════════════════╣
║  [اسأل أي شيء...]  [⚡] ║
╚══════════════════════════╝
```

### **Features:**

- **Chat Interface** - Talk to AI
- **Drag to Move** - Click and drag anywhere
- **Close Button** - Top left (×)
- **System Tray** - Runs in background
- **Auto-hide** - ESC or click outside

---

## 🎨 **Design**

### **Colors:**

```css
Primary: #1ABC9C (Turquoise) 💚
Dark: #05261F (Deep Green)
Glow: Animated gradient
```

### **Animations:**

- ✨ **Appear** - Scale + fade in
- 💫 **Glow** - Rotating gradient border
- 🌊 **Float** - Logo floats up/down
- ⚡ **Send** - Button rotates on hover

---

## 🛠️ **Development**

### **Project Structure:**

```
comet-x-desktop/
├── package.json           # Dependencies
├── src/
│   ├── main/
│   │   └── index.js       # Electron main process
│   ├── renderer/
│   │   ├── index.html     # UI
│   │   └── script.js      # Frontend logic
│   └── preload/
│       └── index.js       # Bridge script
├── assets/
│   └── icons/             # App icons
└── README.md
```

### **Technologies:**

- **Electron** - Desktop framework
- **Node.js** - Backend
- **HTML/CSS/JS** - Frontend
- **IPC** - Inter-process communication

---

## 📦 **Building EXE**

### **For Windows:**

```bash
npm run build:win
```

**Output:** `dist/Comet-X Setup.exe`

### **For Mac:**

```bash
npm run build:mac
```

### **For Linux:**

```bash
npm run build:linux
```

---

## ⚙️  **Configuration**

Config is stored in: `~/.config/comet-x/config.json`

```json
{
  "theme": "dark",
  "color": "#1ABC9C",
  "hotkey": "CommandOrControl+Shift+Space",
  "autoStart": true,
  "alwaysOnTop": true,
  "opacity": 0.95
}
```

---

## 🎯 **Hotkeys**

| Key | Action |
|-----|--------|
| `Ctrl+Shift+Space` | Show/Hide Comet-X |
| `Enter` | Send message |
| `ESC` | Hide window |
| `Ctrl+Q` | Quit app |

---

## 💡 **Tips & Tricks**

### **Always on Top:**

Window stays above all others (configurable)

### **System Tray:**

Right-click tray icon for menu:
- ✨ Show Comet-X
- ⚙️  Settings
- 🇸🇦 About
- 🚪 Quit

### **Drag to Reposition:**

Click anywhere in the window and drag

---

## 🐛 **Troubleshooting**

### **App won't start:**

```bash
# Clear cache
rm -rf node_modules
npm install
npm start
```

### **Hotkey not working:**

Check if another app is using the same shortcut

### **Window not appearing:**

Check system tray - right-click to show

---

## 🔮 **Future Features**

- [ ] Local AI model integration
- [ ] Voice input/output
- [ ] Multiple themes
- [ ] Custom hotkeys
- [ ] Plugins system
- [ ] Arabic speech recognition

---

## 🇸🇦 **Vision 2030**

This magical assistant is built with Saudi pride! 💚

**"من الرماد ينهض العنقاء"**

Built in response to the Perplexity incident - we came back stronger!

---

## 📞 **Contact**

- **Email**: admin@gratech.sa
- **Organization**: GraTech Platform
- **Location**: Saudi Arabia 🇸🇦

---

## 📄 **License**

**Proprietary** - GraTech Platform

---

**Last Updated**: December 25, 2025  
**Version**: 0.1.0  
**Status**: ✨ Magical and Ready! ✨

**🇸🇦 Neural Sovereignty | Digital Independence | Human-First AI**
