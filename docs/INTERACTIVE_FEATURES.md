# Interactive PDF Features - Implementation Guide

## Overview

This document describes the interactive PDF features available in the Paperless PDF Viewer and how to test them.

## Implemented Features

### 1. Audio Annotations 🔊

**Status**: ✅ Configured

**Description**: Embed and play audio files in PDFs (ideal for Quran recitation, language learning)

**Configuration**:

- Enabled in `config/pdf-viewer-config.js`
- Supported formats: MP3, WAV, OGG, WebM
- Max file size: 10MB
- Auto-play: Disabled (requires user interaction)

**How to Test**:

1. Create PDF with audio annotation in Adobe Acrobat:
   - Tools → Rich Media → Add Sound
   - Upload audio file
   - Save PDF
2. Upload to Paperless via `./consume/` directory
3. Open in viewer - audio player should appear

### 2. JavaScript Execution 📜

**Status**: ✅ Configured (Sandboxed)

**Description**: Run PDF embedded JavaScript for form calculations, validations, and automation

**Configuration**:

- Sandboxed execution enabled
- Timeout: 5 seconds
- Allowed APIs: `app.alert`, `this.getField`, `AFSimple_Calculate`, etc.

**How to Test**:

1. Create PDF with JavaScript in Adobe Acrobat:
   - Add form fields (e.g., price, tax, total)
   - Add calculation script: `event.value = this.getField("price").value + this.getField("tax").value`
   - Save PDF
2. Upload and test calculations

### 3. Enhanced Hyperlinks 🔗

**Status**: ✅ Configured

**Description**: Improved link handling with confirmation dialogs and custom actions

**Configuration**:

- External links: Open in new tab with confirmation
- Internal links: Enabled for page navigation
- Custom link handler: Active

**How to Test**:

1. Create PDF with hyperlinks
2. Test external links (should show confirmation)
3. Test internal page jumps

### 4. Interactive Forms 📝

**Status**: ✅ Configured

**Description**: Fillable PDF forms with validation and calculations

**Configuration**:

- XFA forms: Enabled
- Interactive rendering: Enabled

**How to Test**:

1. Create fillable PDF form in Adobe Acrobat
2. Add text fields, checkboxes, dropdowns
3. Test field interactions

### 5. Islamic Library Features 🕌

**Status**: ✅ Configured

**Description**: Arabic/RTL support and Quran audio integration

**Configuration**:

- RTL text direction: Auto-detect
- Arabic fonts: Enabled
- Quran audio: Enabled (default reciter: Mishary Alafasy)
- Tajweed highlights: Enabled

**How to Test**:

1. Upload Arabic PDF with RTL text
2. Verify proper text direction
3. Test Quran audio playback

## Testing Workflow

### Quick Test

```bash
# 1. Ensure containers are running
docker compose ps

# 2. Upload test PDF
cp test-interactive.pdf ./consume/

# 3. Access viewer
open http://localhost:8003

# 4. Watch logs for debugging
docker compose logs -f webserver | grep -i "pdf\|audio\|javascript"
```

### Browser Console Testing

Open http://localhost:8003 and press F12:

```javascript
// Check if configuration loaded
console.log(window.PAPERLESS_PDFJS_CONFIG);

// Verify features
console.log({
  audio: PAPERLESS_PDFJS_CONFIG.audioAnnotations.enabled,
  javascript: PAPERLESS_PDFJS_CONFIG.javascript.enabled,
  hyperlinks: PAPERLESS_PDFJS_CONFIG.hyperlinks.enabled,
  forms: PAPERLESS_PDFJS_CONFIG.renderInteractiveForms,
});
```

## Creating Test PDFs

### Audio Annotation PDF

**Using Adobe Acrobat Pro**:

1. File → Create → Blank Page
2. Tools → Rich Media → Add Sound
3. Select audio file (MP3/WAV)
4. Set trigger: Click or Page Open
5. Save as `test-audio.pdf`

### JavaScript Form PDF

**Using Adobe Acrobat Pro**:

1. Prepare → Add Text or Edit
2. Add form fields:
   - Text field: "price"
   - Text field: "tax"
   - Text field: "total"
3. Set calculation on "total":
   ```javascript
   var price = this.getField("price").value;
   var tax = this.getField("tax").value;
   event.value = price + tax;
   ```
4. Save as `test-form-calc.pdf`

### Hyperlink PDF

**Using any PDF editor**:

1. Add text: "Visit Example.com"
2. Create hyperlink: https://example.com
3. Add internal link to page 2
4. Save as `test-hyperlinks.pdf`

## Troubleshooting

### Audio Not Playing

**Check**:

- Browser console for errors
- File format (use MP3 for best compatibility)
- File size (< 10MB)
- Volume mounts: `./config/pdf-viewer-config.js` correctly mounted

**Fix**:

```bash
# Restart webserver
docker compose restart webserver

# Check configuration
docker compose exec webserver cat /usr/src/paperless/static-custom/pdf-config.js
```

### JavaScript Not Executing

**Check**:

- Sandbox is enabled (security requirement)
- Script timeout (default 5s)
- Allowed APIs list

**Debug**:

```javascript
// In browser console
PAPERLESS_PDFJS_CONFIG.onScriptExecution = function (script, context) {
  console.log("Executing:", script);
  console.log("Context:", context);
};
```

### Links Not Working

**Check**:

- External link confirmation enabled
- Browser popup blockers
- Link handler returning `true`

**Fix**:

```javascript
// Disable confirmation for testing
PAPERLESS_PDFJS_CONFIG.hyperlinks.confirmExternalLinks = false;
```

## Next Steps

### Planned Features

- [ ] Video annotations support
- [ ] Enhanced Quran audio player
- [ ] Translation overlay for Arabic text
- [ ] Annotation persistence
- [ ] Multi-user collaboration

### Performance Optimization

- [ ] Lazy loading for large PDFs
- [ ] Worker thread optimization
- [ ] Caching improvements
- [ ] Memory management for multimedia

## Resources

- [PDF.js Documentation](https://mozilla.github.io/pdf.js/)
- [Paperless-NGX API](https://docs.paperless-ngx.com/api/)
- [Adobe PDF Reference](https://www.adobe.com/devnet/pdf/pdf_reference.html)
