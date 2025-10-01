# 📚 Paperless-NGX Interactive PDF Viewer Development

[![Docker](https://img.shields.io/badge/Docker-Ready-blue?logo=docker)](https://www.docker.com/)
[![PDF.js](https://img.shields.io/badge/PDF.js-Mozilla-orange)](https://mozilla.github.io/pdf.js/)
[![Paperless-NGX](https://img.shields.io/badge/Paperless--NGX-Compatible-green)](https://github.com/paperless-ngx/paperless-ngx)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

**Minimal & Lightweight Paperless-NGX clone for developing interactive PDF viewer features**

🎯 **Purpose**: Develop and test custom PDF.js features (audio, JavaScript, hyperlinks, multimedia) without the overhead of the full Paperless-AI stack.

📦 **Size**: ~2GB total (75% smaller than production)  
🚀 **Startup**: <60 seconds  
🔧 **Hot-reload**: Edit files without rebuilding containers

---

## 📋 Table of Contents

- [Features](#-features)
- [Quick Start](#-quick-start)
- [Architecture](#-architecture)
- [Development Workflow](#-development-workflow)
- [Interactive PDF Features](#-interactive-pdf-features)
- [Configuration](#-configuration)
- [API Reference](#-api-reference)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)

---

## ✨ Features

### 🎨 Interactive PDF Capabilities
- ✅ **Audio Annotations** - Embed and play audio in PDFs (MP3, WAV, OGG)
- ✅ **JavaScript Execution** - Run PDF embedded scripts (sandboxed)
- ✅ **Enhanced Hyperlinks** - External/internal links with confirmation
- ✅ **Interactive Forms** - Fillable fields, calculations, validation
- ✅ **Multimedia Support** - Video, audio, rich media annotations
- ✅ **RTL Support** - Arabic/Islamic text rendering

### 🔧 Development Features
- 🔥 **Hot-reload** - Volume-mounted files for instant updates
- 🐳 **Minimal Stack** - Only 5 containers (vs 11 in production)
- 📦 **Lightweight** - ~2GB total (vs 7GB+ production)
- ⚡ **Fast Build** - Pre-compiled base, minimal dependencies
- 🧪 **Isolated** - Separate from production (port 8003)
- 📊 **Framework Compatible** - 100% Paperless-NGX compatibility

---

## 🚀 Quick Start

### Prerequisites
- Docker 24.0+
- Docker Compose 2.20+
- 4GB RAM minimum
- 10GB disk space

### Installation

```bash
# Clone repository
git clone https://github.com/digitaldakwah/paperless-pdf-dev.git
cd paperless-pdf-dev

# Run setup script
./scripts/setup.sh

# Or manual setup:
docker compose up --build -d
```

### Access

- **Web UI**: http://localhost:8003
- **API**: http://localhost:8003/api/
- **Credentials**: `admin` / `admin` (dev only)

---

## 🏗️ Architecture

### System Overview

```
┌─────────────────────────────────────────────────┐
│           Paperless PDF Viewer Dev              │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────────┐  ┌─────────────────────────┐ │
│  │  Web UI      │  │   PDF.js Custom         │ │
│  │  Port: 8003  │◄─┤   - Audio support       │ │
│  └──────────────┘  │   - JS execution        │ │
│         │          │   - Hyperlinks          │ │
│         ▼          │   - Multimedia          │ │
│  ┌──────────────┐  └─────────────────────────┘ │
│  │  Paperless   │                               │
│  │  Webserver   │  ┌─────────────────────────┐ │
│  │  (~800MB)    │  │   Volume Mounts         │ │
│  └──────┬───────┘  │   - pdfjs-custom/       │ │
│         │          │   - config/             │ │
│         │          │   - consume/            │ │
│         ▼          └─────────────────────────┘ │
│  ┌──────────────┐                               │
│  │  PostgreSQL  │  ┌──────────────────────────┐│
│  │  (Alpine)    │  │  Gotenberg + Tika        ││
│  │  ~240MB      │  │  (PDF Processing)        ││
│  └──────────────┘  └──────────────────────────┘│
│                                                 │
│  ┌──────────────┐                               │
│  │  Redis       │                               │
│  │  (Alpine)    │  Total Size: ~2GB            │
│  │  ~40MB       │                               │
│  └──────────────┘                               │
└─────────────────────────────────────────────────┘
```

### Container Breakdown

| Service | Image | Size | Purpose |
|---------|-------|------|---------|
| `webserver` | paperless-pdf-dev:latest | ~800MB | PDF viewer development |
| `db` | postgres:17-alpine | ~240MB | Database (minimal) |
| `broker` | redis:8-alpine | ~40MB | Task queue |
| `gotenberg` | gotenberg:8-cloudron | ~400MB | PDF processing |
| `tika` | apache/tika:3.0.0-full | ~500MB | Document parsing |
| **Total** | | **~2GB** | 75% reduction |

### What's Removed (vs Production)

❌ **Removed Services** (saves ~5GB):
- `paperless-ai` - AI/RAG not needed for PDF development
- `paperless-ai-rag` - RAG service not needed
- Language packs - Kept minimal (English only)
- Build tools - Using pre-compiled Paperless-NGX

✅ **Kept Services** (essential only):
- Core Paperless-NGX functionality
- PDF.js viewer with customization
- Database and queue (minimal versions)
- PDF processing (Gotenberg/Tika)

---

## 🔧 Development Workflow

### 1. Extract PDF.js Library

```bash
# Automatic extraction on first container start
docker compose up -d

# Manual extraction
docker compose exec webserver /usr/src/paperless/dev-scripts/extract-pdfjs.sh

# Verify
ls -lh pdfjs-custom/lib/
# Output:
# pdf.min.mjs (382KB)
# pdf.worker.min.mjs (1.4MB)
```

### 2. Edit Configuration

```bash
# Edit PDF.js configuration
nano config/pdf-viewer-config.js

# Enable audio annotations
PAPERLESS_PDFJS_CONFIG.audioAnnotations.enabled = true;

# Enable JavaScript execution
PAPERLESS_PDFJS_CONFIG.javascript.enabled = true;

# No rebuild needed - file is volume-mounted!
```

### 3. Customize PDF.js Library

```bash
# Edit main library (advanced)
nano pdfjs-custom/lib/pdf.min.mjs

# Backup first
cp pdfjs-custom/lib/pdf.min.mjs pdfjs-custom/backup/

# Test changes
docker compose restart webserver
```

### 4. Test Interactive PDFs

```bash
# Upload test PDF
cp your-interactive.pdf ./consume/

# Or via API
curl -X POST http://localhost:8003/api/documents/post_document/ \
  -H "Authorization: Token YOUR_TOKEN" \
  -F "document=@test.pdf"

# Watch logs
docker compose logs -f webserver | grep -i "pdf\|audio\|javascript"
```

### 5. Debug & Monitor

```bash
# Shell access
docker compose exec webserver bash

# Check PDF.js files
ls -la /usr/src/paperless/pdfjs-dev/

# View browser console
# Open http://localhost:8003 → F12 Developer Tools

# Check configuration
cat /usr/src/paperless/static-custom/pdf-config.js
```

---

## 🎯 Interactive PDF Features

### 1. Audio Annotations 🔊

**Goal**: Embed audio playback in PDFs (e.g., Quran recitation)

#### Configuration
```javascript
// config/pdf-viewer-config.js
PAPERLESS_PDFJS_CONFIG.audioAnnotations = {
  enabled: true,
  autoPlay: false,
  showControls: true,
  supportedFormats: ['mp3', 'wav', 'ogg', 'webm'],
  maxFileSize: 10 * 1024 * 1024,  // 10MB
};
```

#### Implementation
```javascript
// Custom audio handler
PAPERLESS_PDFJS_CONFIG.onAudioAnnotation = function(annotation) {
  const audio = document.createElement('audio');
  audio.controls = true;
  audio.src = annotation.soundData || annotation.fileUrl;
  
  const container = document.querySelector(
    `[data-annotation-id="${annotation.id}"]`
  );
  if (container) {
    container.appendChild(audio);
  }
  
  return audio;
};
```

#### Testing
Create PDF with audio annotation using Adobe Acrobat:
1. Tools → Rich Media → Add Sound
2. Upload MP3 file
3. Set trigger (click/hover)
4. Save and upload to Paperless

### 2. JavaScript Execution 📜

**Goal**: Run PDF embedded scripts (form calculations, validations)

#### Configuration
```javascript
// config/pdf-viewer-config.js
PAPERLESS_PDFJS_CONFIG.javascript = {
  enabled: true,
  sandbox: true,  // Security
  allowedAPIs: [
    'app.alert',
    'this.getField',
    'this.calculateNow',
    'AFSimple_Calculate',
  ],
  timeout: 5000,
};
```

#### Supported PDF JavaScript APIs
- `app.alert()` - Display alerts
- `app.beep()` - Sound notifications
- `this.getField()` - Form field access
- `this.calculateNow()` - Trigger calculations
- `util.printf()` - Format strings
- `AFSimple_Calculate()` - Auto calculations

#### Example: Form Calculation
```javascript
// PDF JavaScript (in Adobe Acrobat)
// Field "total" calculates sum of "price" + "tax"
var price = this.getField("price").value;
var tax = this.getField("tax").value;
event.value = price + tax;
```

### 3. Enhanced Hyperlinks 🔗

**Goal**: Improved link handling (confirmation, tracking, custom actions)

#### Configuration
```javascript
// config/pdf-viewer-config.js
PAPERLESS_PDFJS_CONFIG.hyperlinks = {
  enabled: true,
  externalLinkTarget: 2,  // Open in new tab
  confirmExternalLinks: true,
  enableInternalLinks: true,
  customLinkHandler: true,
};
```

#### Custom Link Handler
```javascript
PAPERLESS_PDFJS_CONFIG.onLinkClick = function(link) {
  console.log('Link clicked:', link);
  
  // External link confirmation
  if (link.url && link.url.startsWith('http')) {
    const confirmed = confirm(`Open external link?\n${link.url}`);
    return confirmed;
  }
  
  // Internal navigation
  if (link.dest) {
    console.log('Navigating to page:', link.dest);
    return true;
  }
  
  return true;
};
```

#### Link Types Supported
- **External**: HTTP/HTTPS URLs (with confirmation)
- **Internal**: Page navigation, anchors
- **Email**: `mailto:` links
- **File**: Local file references
- **Custom**: JavaScript actions

### 4. Interactive Forms 📝

**Goal**: Fillable forms with validation and calculations

#### Configuration
```javascript
// config/pdf-viewer-config.js
PAPERLESS_PDFJS_CONFIG.renderInteractiveForms = true;
PAPERLESS_PDFJS_CONFIG.enableXfa = true;  // XFA forms
```

#### Features
- Text fields (single/multi-line)
- Checkboxes and radio buttons
- Dropdown lists
- Date pickers
- Signature fields
- Calculations (auto-sum, formulas)
- Validation (required, format, range)

### 5. Multimedia Embedding 🎬

**Goal**: Video, rich media in PDFs

#### Configuration
```javascript
// config/pdf-viewer-config.js
PAPERLESS_PDFJS_CONFIG.videoAnnotations = {
  enabled: true,
  autoPlay: false,
  showControls: true,
  supportedFormats: ['mp4', 'webm', 'ogg'],
  maxFileSize: 50 * 1024 * 1024,  // 50MB
};
```

### 6. Islamic Library Features 🕌

**Goal**: Arabic/Islamic content support

#### Configuration
```javascript
// config/pdf-viewer-config.js
PAPERLESS_PDFJS_CONFIG.islamicLibrary = {
  defaultTextDirection: 'rtl',
  enableArabicFonts: true,
  quranAudio: {
    enabled: true,
    defaultReciter: 'Mishary_Rashid_Alafasy',
    showReciterSelector: true,
  },
  enableTajweedHighlights: true,
  enableTranslationOverlay: true,
};
```

---

## ⚙️ Configuration

### Environment Variables

```bash
# docker-compose.yml or .env file

# PDF.js Interactive Features
PAPERLESS_PDF_ENABLE_AUDIO=true
PAPERLESS_PDF_ENABLE_JAVASCRIPT=true
PAPERLESS_PDF_ENABLE_HYPERLINKS=true
PAPERLESS_PDF_INTERACTIVE_MODE=true

# Development Settings
PAPERLESS_DEBUG=true
PAPERLESS_ENABLE_COMPRESSION=false
PAPERLESS_OCR_MODE=skip  # Faster testing

# Performance
PAPERLESS_TASK_WORKERS=1
PAPERLESS_THREADS_PER_WORKER=1

# Security (dev only!)
PAPERLESS_ALLOWED_HOSTS=*
PAPERLESS_SECRET_KEY=dev-secret-key
```

### Volume Mounts

```yaml
# docker-compose.yml
volumes:
  # PDF.js development (hot-reload)
  - ./pdfjs-custom:/usr/src/paperless/pdfjs-dev:rw
  - ./config/pdf-viewer-config.js:/usr/src/paperless/static-custom/pdf-config.js:ro
  
  # Data persistence
  - data:/usr/src/paperless/data
  - media:/usr/src/paperless/media
  
  # Import/Export
  - ./consume:/usr/src/paperless/consume
  - ./export:/usr/src/paperless/export
```

### Directory Structure

```
paperless-pdf-dev/
├── Dockerfile                      # Minimal development image
├── docker-compose.yml              # 5-container stack
├── README.md                       # This file
├── LICENSE                         # Apache 2.0
│
├── config/
│   └── pdf-viewer-config.js       # PDF.js configuration (hot-reload)
│
├── pdfjs-custom/
│   ├── lib/                       # PDF.js library files
│   │   ├── pdf.min.mjs           # Main library (382KB)
│   │   └── pdf.worker.min.mjs    # Worker (1.4MB)
│   ├── backup/                    # Automatic backups
│   └── config/                    # Additional configs
│
├── scripts/
│   ├── setup.sh                   # Quick start script
│   └── extract-pdfjs.sh           # PDF.js extraction
│
├── consume/                        # Upload directory
├── export/                         # Export directory
├── assets/                         # Custom assets
│
└── docs/
    ├── API.md                      # API documentation
    ├── CUSTOMIZATION.md            # Customization guide
    └── TROUBLESHOOTING.md          # Common issues
```

---

## 📚 API Reference

### PDF.js Configuration Object

```javascript
window.PAPERLESS_PDFJS_CONFIG = {
  // Worker
  workerSrc: '/static/frontend/en-US/assets/js/pdf.worker.min.mjs',
  
  // Interactive features
  enableScripting: true,
  enableAnnotations: true,
  renderInteractiveForms: true,
  
  // Audio
  audioAnnotations: { /* ... */ },
  
  // Hyperlinks
  hyperlinks: { /* ... */ },
  
  // JavaScript
  javascript: { /* ... */ },
  
  // Event handlers
  onLinkClick: function(link) { /* ... */ },
  onAudioAnnotation: function(annotation) { /* ... */ },
  onScriptExecution: function(script, context) { /* ... */ },
};
```

### Initialization

```javascript
// Auto-initialization
window.initializePDFJS();

// Manual PDF loading
const loadingTask = pdfjsLib.getDocument({
  url: '/media/documents/document.pdf',
  ...PAPERLESS_PDFJS_CONFIG,
});

loadingTask.promise.then(pdf => {
  console.log('PDF loaded:', pdf.numPages);
});
```

### API Endpoints

```bash
# Upload document
POST /api/documents/post_document/
Content-Type: multipart/form-data
Authorization: Token YOUR_TOKEN

# Get document
GET /api/documents/{id}/

# Download PDF
GET /api/documents/{id}/download/

# Preview
GET /api/documents/{id}/preview/
```

---

## 🐛 Troubleshooting

### Common Issues

#### 1. PDF.js not loading
```bash
# Check if files exist
docker compose exec webserver ls -la /usr/src/paperless/pdfjs-dev/lib/

# Extract manually
docker compose exec webserver /usr/src/paperless/dev-scripts/extract-pdfjs.sh

# Restart
docker compose restart webserver
```

#### 2. Audio not playing
```javascript
// Check browser console for errors
// Ensure audio format is supported (MP3, WAV, OGG)
// Check PAPERLESS_PDF_ENABLE_AUDIO=true

// Debug
console.log(PAPERLESS_PDFJS_CONFIG.audioAnnotations);
```

#### 3. JavaScript not executing
```javascript
// Security: Ensure sandbox is enabled
PAPERLESS_PDFJS_CONFIG.javascript.sandbox = true;

// Check allowed APIs
console.log(PAPERLESS_PDFJS_CONFIG.javascript.allowedAPIs);

// Browser console should show script execution logs
```

#### 4. Changes not reflecting
```bash
# Clear browser cache (Ctrl+Shift+Del)
# Hard refresh (Ctrl+F5)
# Restart container
docker compose restart webserver

# Check volume mounts
docker compose exec webserver cat /usr/src/paperless/static-custom/pdf-config.js
```

#### 5. Container won't start
```bash
# Check logs
docker compose logs webserver

# Check disk space
df -h

# Rebuild
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Debug Mode

```bash
# Enable verbose logging
docker compose down
docker compose up  # No -d flag

# Or check logs
docker compose logs -f --tail=100 webserver

# Browser console
# F12 → Console tab → Filter: "pdfjs"
```

### Performance Issues

```bash
# Reduce OCR (faster testing)
PAPERLESS_OCR_MODE=skip

# Reduce workers
PAPERLESS_TASK_WORKERS=1
PAPERLESS_THREADS_PER_WORKER=1

# Disable compression
PAPERLESS_ENABLE_COMPRESSION=false
```

---

## 🤝 Contributing

We welcome contributions! Here's how to get started:

### Development Setup

1. Fork this repository
2. Clone your fork
3. Create a feature branch
4. Make your changes
5. Test thoroughly
6. Submit pull request

### Testing Interactive PDFs

```bash
# Create test PDF with Adobe Acrobat
# Add audio, JavaScript, forms, links
# Upload to http://localhost:8003

# Test each feature:
# - Audio playback
# - JavaScript execution
# - Link navigation
# - Form interactions
```

### Code Style

- Follow existing patterns
- Comment complex logic
- Update documentation
- Add tests where possible

### Pull Request Process

1. Update README.md with changes
2. Update CHANGELOG.md
3. Test on fresh install
4. Describe changes clearly
5. Link related issues

---

## 📄 License

Apache License 2.0 - See [LICENSE](LICENSE) for details

Based on:
- **Paperless-NGX**: [GitHub](https://github.com/paperless-ngx/paperless-ngx) (GPL-3.0)
- **PDF.js**: [GitHub](https://github.com/mozilla/pdf.js) (Apache-2.0)

---

## 🔗 Resources

### Documentation
- [PDF.js Documentation](https://mozilla.github.io/pdf.js/)
- [Paperless-NGX Docs](https://docs.paperless-ngx.com/)
- [Docker Compose](https://docs.docker.com/compose/)

### Related Projects
- [Paperless-AI](https://github.com/digitaldakwah/paperless-ai) - Full production stack with AI/RAG
- [Paperless-NGX](https://github.com/paperless-ngx/paperless-ngx) - Original Paperless-NGX
- [PDF.js](https://github.com/mozilla/pdf.js) - Mozilla PDF viewer

### Community
- [Paperless-NGX Discord](https://discord.gg/paperless)
- [GitHub Discussions](https://github.com/digitaldakwah/paperless-pdf-dev/discussions)
- [Issue Tracker](https://github.com/digitaldakwah/paperless-pdf-dev/issues)

---

## 📊 Project Status

**Current Version**: 1.0.0-dev  
**Last Updated**: October 1, 2025  
**Paperless-NGX Version**: Latest (compatible)  
**PDF.js Version**: Bundled with Paperless-NGX

### Roadmap

- [x] Minimal development container
- [x] PDF.js extraction and customization
- [x] Audio annotation support
- [x] JavaScript execution (sandboxed)
- [x] Enhanced hyperlink handling
- [ ] Video annotation support
- [ ] Quran audio integration
- [ ] Tajweed highlighting
- [ ] Translation overlay
- [ ] Mobile viewer optimization
- [ ] Production deployment guide

---

**Made with ❤️ for the Digital Dakwah Platform**

> *"This development environment enables the creation of interactive Islamic educational materials with multimedia PDF support."*

---

## 🚀 Quick Commands Reference

```bash
# Start
./scripts/setup.sh

# Stop
docker compose down

# Logs
docker compose logs -f webserver

# Shell
docker compose exec webserver bash

# Rebuild
docker compose up --build --force-recreate

# Clean
docker compose down -v
docker system prune -af

# Extract PDF.js
docker compose exec webserver /usr/src/paperless/dev-scripts/extract-pdfjs.sh

# Check status
docker compose ps
```

---

**Questions?** Open an issue or discussion on GitHub!
