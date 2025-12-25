# 💚 Comet-X Browser Extension

**Neural Sovereignty Browser | الذكاء السيادي العصبي**

A Chrome extension that brings sovereign AI directly to your browser - local-first, privacy-first, human-first.

---

## 🎯 **Vision**

Comet-X is built in response to the Perplexity incident that destroyed 60+ Azure resources. We're creating an AI companion that:

- ✅ **Runs locally** - Your data never leaves your device
- ✅ **Respects privacy** - No tracking, no telemetry
- ✅ **Human-first** - Designed to augment, not replace
- ✅ **Saudi-owned** - Vision 2030 aligned

---

## 🏗️ **Architecture**

### **Three-Lobe System**

```
┌─────────────────────────────────────────────┐
│           Executive Lobe (Service Worker)    │
│   🧠 Orchestrator - State, Memory, Control  │
└──────────────┬──────────────────────────────┘
               │
       ┌───────┴───────┐
       │               │
┌──────▼──────┐  ┌────▼────────────────────┐
│ Sensory Lobe│  │  Cognitive Lobe         │
│ (Content)   │  │  (Offscreen)            │
│ 👁️ Perceive  │  │  🤔 Think & Process     │
│ 🖼️ Display   │  │  🔬 AI Models           │
└─────────────┘  └─────────────────────────┘
```

### **Memory System**

```
Memory
├── Episodic (Conversations, Events)
├── Semantic (Facts, Knowledge)
└── Procedural (Skills, Patterns)
```

---

## 🚀 **Features**

### **Current (v0.1.0)**

- ✅ **Floating Orb UI** - Always accessible
- ✅ **Chat Sidebar** - Ctrl+Shift+C
- ✅ **Page Context Capture** - Automatic analysis
- ✅ **Memory System** - Persistent storage
- ✅ **Three-Lobe Architecture** - Efficient processing

### **In Development**

- 🔄 **Local AI Model** - Phi-3 Mini via Transformers.js
- 🔄 **Vector Search** - Semantic memory retrieval
- 🔄 **Page Summarization** - One-click summaries
- 🔄 **Smart Context** - Intelligent understanding

### **Planned**

- ⏳ **RAG System** - Retrieval augmented generation
- ⏳ **Multi-modal** - Image understanding
- ⏳ **Bias Detection** - Zero-bias AI
- ⏳ **Arabic-first** - Native Arabic support

---

## 📦 **Installation**

### **Development Mode**

1. Clone the repository:
   ```bash
   git clone https://dev.azure.com/grar00t/gratech/_git/gratech
   cd gratech/comet-x-browser
   ```

2. Open Chrome and go to `chrome://extensions/`

3. Enable "Developer mode" (top right)

4. Click "Load unpacked"

5. Select the `comet-x-browser` folder

6. Done! Look for the 💚 icon in your toolbar

### **Using the Extension**

- **Click the icon** - Open quick actions popup
- **Ctrl+Shift+C** - Toggle chat sidebar
- **Right-click** - Context menu options

---

## 🛠️ **Project Structure**

```
comet-x-browser/
├── manifest.json              # Extension configuration
├── background/
│   └── service-worker.js      # Executive Lobe
├── content/
│   ├── content-script.js      # Sensory Lobe
│   └── styles.css             # Styles
├── offscreen/
│   └── cognitive.html         # Cognitive Lobe
├── ui/
│   ├── popup.html             # Popup UI
│   ├── popup.js               # Popup logic
│   ├── sidebar.html           # Chat sidebar (injected)
│   └── options.html           # Settings page
├── memory/
│   └── index.js               # Memory system
├── parallel/
│   └── worker.js              # Web Workers
└── models/
    └── (AI models cached here)
```

---

## 🧪 **Development**

### **Prerequisites**

- Chrome 88+ (Manifest V3 support)
- Node.js 18+ (for building)
- Basic understanding of Chrome Extensions

### **Setup**

```bash
# Install dependencies (if any)
npm install

# Watch mode (if using build tools)
npm run dev
```

### **Testing**

```bash
# Run tests
npm test

# Lint code
npm run lint
```

---

## 🎨 **Design System**

### **Colors**

```css
Primary:   #1ABC9C (تركواز)
Dark:      #05261F (أخضر داكن)
Secondary: #16A085 (تركواز داكن)
Text:      #FFFFFF (أبيض)
Accent:    #888888 (رمادي)
```

### **Typography**

```css
Font: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto
Sizes: 12px, 14px, 20px, 24px
```

---

## 📝 **Roadmap**

### **Phase 1: Foundation** ✅ (Current)

- [x] Manifest V3 setup
- [x] Three-Lobe Architecture
- [x] Basic UI (Orb + Sidebar)
- [x] State management
- [x] Memory system (basic)

### **Phase 2: Intelligence** 🔄 (Next)

- [ ] Integrate Transformers.js
- [ ] Download Phi-3 Mini model
- [ ] Vector search (Orama)
- [ ] Embeddings generation
- [ ] Smart summarization

### **Phase 3: Features** ⏳

- [ ] Context menu actions
- [ ] Page analysis
- [ ] Bias detection
- [ ] Multi-language support

### **Phase 4: Polish** ⏳

- [ ] Settings UI
- [ ] Themes
- [ ] Keyboard shortcuts
- [ ] Accessibility

---

## 🤝 **Contributing**

We welcome contributions! But please note:

1. **Local-first** - No cloud dependencies
2. **Privacy-first** - No telemetry or tracking
3. **Arabic-first** - RTL and Arabic support
4. **Vision 2030** - Aligned with Saudi digital transformation

### **How to Contribute**

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

## 📄 **License**

**Proprietary** - GraTech Platform

This is part of the GraTech ecosystem responding to the Perplexity incident.

---

## 🙏 **Acknowledgments**

This extension is built in response to losing 60+ Azure resources to Perplexity AI on [incident date].

We didn't give up. We rebuilt stronger.

**"من الرماد ينهض العنقاء"**

---

## 📞 **Contact**

- **Email**: admin@gratech.sa
- **Organization**: GraTech Platform
- **Location**: Saudi Arabia 🇸🇦

---

## 🇸🇦 **Vision 2030**

**Neural Sovereignty | Digital Independence | Human-First AI**

Built with ❤️  in Saudi Arabia for a sovereign digital future.

---

**Last Updated**: December 25, 2025  
**Version**: 0.1.0  
**Status**: Active Development 🚧
