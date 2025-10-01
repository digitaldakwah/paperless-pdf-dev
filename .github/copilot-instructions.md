# GitHub Copilot Instructions for Paperless PDF Viewer Development

## Project Context

This repository contains a **minimal, lightweight development environment** for customizing the **PDF.js interactive viewer** in Paperless-NGX. It's specifically designed for developing interactive PDF features like audio annotations, JavaScript execution, enhanced hyperlinks, and multimedia support for the **Digital Dakwah Platform**.

## Key Information for Copilot

### Project Purpose
- **Primary Goal**: Develop interactive PDF viewer with multimedia support (audio, video, JavaScript)
- **Use Case**: Islamic educational materials with Quran recitation, Arabic text, and interactive features
- **Approach**: Minimal Docker container cloned from Paperless-NGX (~2GB vs 7GB+ production)
- **Development Focus**: PDF.js customization with hot-reload, no rebuilds needed

### Architecture Overview

**Technology Stack:**
- **Base**: Official Paperless-NGX container (ghcr.io/paperless-ngx/paperless-ngx:latest)
- **PDF Viewer**: PDF.js (Mozilla) - bundled with Paperless-NGX
- **Frontend**: Angular-based (pre-compiled in Paperless-NGX)
- **Backend**: Django (Python)
- **Database**: PostgreSQL 17 (Alpine)
- **Queue**: Redis 8 (Alpine)
- **PDF Processing**: Gotenberg + Tika

**Container Services (5 total):**
1. `webserver` - Paperless-NGX with PDF.js customization (~800MB)
2. `db` - PostgreSQL 17-alpine (~240MB)
3. `broker` - Redis 8-alpine (~40MB)
4. `gotenberg` - PDF processing with JS enabled (~400MB)
5. `tika` - Document parsing (~500MB)

**What's REMOVED (vs production):**
- ❌ AI/RAG services (paperless-ai, paperless-ai-rag) - saves ~5GB
- ❌ Extra language support (kept English only for dev)
- ❌ Build tools (Angular CLI, TypeScript - using pre-compiled)
- ❌ Production security hardening (relaxed for development)

### Key Files & Directories

```
paperless-pdf-dev/
├── Dockerfile                      # Minimal dev container (~800MB)
├── docker-compose.yml              # 5-container stack (port 8003)
├── README.md                       # Comprehensive documentation
├── CHANGELOG.md                    # Version history
├── LICENSE                         # Apache 2.0
├── .gitignore                      # Git exclusions
│
├── config/
│   └── pdf-viewer-config.js       # PDF.js configuration (HOT-RELOAD)
│
├── pdfjs-custom/
│   ├── lib/                       # PDF.js library files
│   │   ├── pdf.min.mjs           # Main library (382KB) - extracted from container
│   │   └── pdf.worker.min.mjs    # Worker thread (1.4MB) - extracted from container
│   ├── backup/                    # Automatic backups
│   └── config/                    # Additional configs
│
├── scripts/
│   └── setup.sh                   # Quick start automation
│
├── consume/                        # PDF upload directory
├── export/                         # Export directory
└── assets/                         # Custom assets
```

### Development Workflow

**Hot-Reload Development (NO REBUILDS):**
1. Edit `config/pdf-viewer-config.js` → Changes apply immediately via volume mount
2. Edit `pdfjs-custom/lib/*.mjs` → Restart container only (`docker compose restart webserver`)
3. Test PDFs → Upload to `consume/` directory
4. View logs → `docker compose logs -f webserver`

**Volume Mounts (Critical for hot-reload):**
- `./config/pdf-viewer-config.js` → `/usr/src/paperless/static-custom/pdf-config.js` (read-only)
- `./pdfjs-custom/` → `/usr/src/paperless/pdfjs-dev/` (read-write)
- `./consume/` → `/usr/src/paperless/consume/` (upload directory)
- `./export/` → `/usr/src/paperless/export/` (export directory)

### Interactive PDF Features Implementation

**1. Audio Annotations 🔊**
- **Goal**: Embed MP3/WAV/OGG audio in PDFs (Quran recitation)
- **Config**: `PAPERLESS_PDFJS_CONFIG.audioAnnotations.enabled = true`
- **Handler**: Custom `onAudioAnnotation()` function creates HTML5 `<audio>` elements
- **Testing**: Create PDF with audio in Adobe Acrobat → Upload to consume/

**2. JavaScript Execution 📜**
- **Goal**: Run PDF embedded scripts (form calculations, validations)
- **Security**: Sandboxed execution with allowed API list
- **Config**: `PAPERLESS_PDFJS_CONFIG.javascript.enabled = true`
- **Supported APIs**: `app.alert()`, `this.getField()`, `AFSimple_Calculate()`, etc.
- **Timeout**: 5 seconds maximum

**3. Enhanced Hyperlinks 🔗**
- **Goal**: External link confirmation, internal navigation, custom handlers
- **Config**: `PAPERLESS_PDFJS_CONFIG.hyperlinks.confirmExternalLinks = true`
- **Handler**: Custom `onLinkClick()` intercepts all link clicks
- **Features**: Confirmation dialogs, tracking, custom actions

**4. Interactive Forms 📝**
- **Goal**: Fillable forms with calculations and validation
- **Config**: `PAPERLESS_PDFJS_CONFIG.renderInteractiveForms = true`
- **Support**: Text fields, checkboxes, dropdowns, signatures, auto-calculations

**5. Islamic Library Features 🕌**
- **RTL Support**: `defaultTextDirection: 'rtl'` for Arabic
- **Quran Audio**: Integration with recitation audio
- **Arabic Fonts**: `enableArabicFonts: true`
- **Tajweed**: Highlighting support

### Code Style & Patterns

**When suggesting code changes:**

1. **Always maintain Paperless-NGX compatibility** - Use official APIs
2. **Use volume mounts over rebuilds** - Prefer config files over Dockerfile changes
3. **Security first for JavaScript execution** - Always use sandboxed mode
4. **Minimal dependencies** - Don't add npm packages unless absolutely necessary
5. **Comment Islamic features** - Document Quran, Arabic, RTL-specific code

**JavaScript Configuration Pattern:**
```javascript
// config/pdf-viewer-config.js
PAPERLESS_PDFJS_CONFIG.featureName = {
  enabled: true,
  // Configuration options
};

PAPERLESS_PDFJS_CONFIG.onEventName = function(data) {
  // Custom handler
  return result;
};
```

**Docker Pattern:**
```dockerfile
# Minimal installation
RUN apt-get update && apt-get install -y --no-install-recommends \
    package1 \
    package2 \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean
```

**Volume Mount Pattern:**
```yaml
volumes:
  - ./local-file:/container/path:rw  # Read-write for development
  - ./config-file:/container/config:ro  # Read-only for safety
```

### Common Tasks & Solutions

**Task: "Add new interactive feature"**
→ Edit `config/pdf-viewer-config.js`, add config object and event handler

**Task: "PDF.js not loading"**
→ Run `docker compose exec webserver /usr/src/paperless/dev-scripts/extract-pdfjs.sh`

**Task: "Changes not reflecting"**
→ Check volume mounts, hard refresh browser (Ctrl+F5), verify file in container

**Task: "Container won't start"**
→ Check logs `docker compose logs webserver`, verify disk space, check port 8003

**Task: "Need to debug PDF rendering"**
→ Browser console (F12), filter for "pdfjs", check `PDFJS_DEV_MODE=true`

### Environment Variables (docker-compose.yml)

**PDF.js Features:**
- `PAPERLESS_PDF_ENABLE_AUDIO=true` - Audio annotations
- `PAPERLESS_PDF_ENABLE_JAVASCRIPT=true` - JS execution
- `PAPERLESS_PDF_ENABLE_HYPERLINKS=true` - Enhanced links
- `PAPERLESS_PDF_INTERACTIVE_MODE=true` - All interactive features

**Development:**
- `PAPERLESS_DEBUG=true` - Enable debug mode
- `PAPERLESS_ENABLE_COMPRESSION=false` - Easier debugging
- `PAPERLESS_OCR_MODE=skip` - Faster testing (skip OCR)

**Access:**
- Port: `8003` (vs 8001 production)
- Admin: `admin/admin` (dev only!)
- API: `http://localhost:8003/api/`

### Testing Guidelines

**When suggesting tests:**

1. **PDF Creation**: Use Adobe Acrobat for interactive features (audio, forms, JS)
2. **Upload Methods**: 
   - Copy to `./consume/` directory
   - API: `POST /api/documents/post_document/`
3. **Browser Testing**: Chrome DevTools Console (F12) for PDF.js logs
4. **Container Testing**: `docker compose exec webserver bash`

**Test PDF Checklist:**
- [ ] Audio annotation (sound clip embedded)
- [ ] JavaScript (form calculation)
- [ ] External hyperlink (with confirmation)
- [ ] Internal navigation (page jump)
- [ ] Fillable form fields
- [ ] Arabic text (RTL rendering)

### Security Considerations

**Always enforce when suggesting code:**

1. **JavaScript Sandbox**: Never disable `sandbox: true`
2. **Allowed APIs**: Whitelist only necessary PDF JavaScript APIs
3. **External Links**: Always confirm before opening (`confirmExternalLinks: true`)
4. **Timeout**: Limit script execution (5s default)
5. **File Size**: Enforce limits (10MB audio, 50MB video)

### Integration Points

**Paperless-NGX APIs used:**
- Document upload: `/api/documents/post_document/`
- Document retrieval: `/api/documents/{id}/`
- PDF download: `/api/documents/{id}/download/`
- Preview: `/api/documents/{id}/preview/`

**PDF.js Initialization:**
```javascript
pdfjsLib.GlobalWorkerOptions.workerSrc = PAPERLESS_PDFJS_CONFIG.workerSrc;
const loadingTask = pdfjsLib.getDocument({
  url: pdfUrl,
  ...PAPERLESS_PDFJS_CONFIG,
});
```

### Performance Optimization

**Current optimizations:**
- Alpine-based services (db, broker) - 60% size reduction
- Pre-compiled frontend (no build tools in container)
- Volume mounts (no rebuilds)
- Minimal OCR (skip mode for dev)
- Single worker (dev environment)

**Don't suggest:**
- Adding Angular CLI to container (use pre-compiled)
- Installing TypeScript (not needed)
- Full language support (keep minimal for dev)
- AI/RAG services (separate from PDF development)

### Git Workflow

**Branch strategy:**
- `main` - Stable releases
- `develop` - Active development
- `feature/*` - New features
- `fix/*` - Bug fixes

**Commit message format:**
```
feat: Add audio annotation support
fix: PDF.js worker not loading
docs: Update README with new examples
chore: Update dependencies
```

### Quick Commands Reference

**For suggesting to users:**

```bash
# Start environment
./scripts/setup.sh

# Manual start
docker compose up --build -d

# View logs
docker compose logs -f webserver

# Shell access
docker compose exec webserver bash

# Restart (after config changes)
docker compose restart webserver

# Extract PDF.js
docker compose exec webserver /usr/src/paperless/dev-scripts/extract-pdfjs.sh

# Stop
docker compose down

# Clean everything
docker compose down -v && docker system prune -af
```

### External Resources

- PDF.js Docs: https://mozilla.github.io/pdf.js/
- Paperless-NGX: https://docs.paperless-ngx.com/
- GitHub: https://github.com/digitaldakwah/paperless-pdf-dev

---

## Summary for Copilot

**This is a MINIMAL development environment for PDF.js customization:**
- 🎯 Focus on interactive PDF features (audio, JS, hyperlinks, forms)
- 📦 Lightweight (~2GB) vs production (~7GB+)
- 🔥 Hot-reload via volume mounts (no rebuilds)
- 🕌 Islamic content support (Arabic, RTL, Quran audio)
- 🐳 5 containers only (no AI/RAG)
- 🚀 Fast startup (<60s)
- ✅ 100% Paperless-NGX compatible

**When assisting with this project:**
1. Prefer config files over Dockerfile changes
2. Maintain framework compatibility
3. Security-first for JavaScript execution
4. Document Islamic/Arabic features clearly
5. Suggest volume-mounted solutions
6. Keep it minimal and lightweight
