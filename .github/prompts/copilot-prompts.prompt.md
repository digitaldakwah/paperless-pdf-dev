---
mode: agent
---

Define the task to achieve, including specific requirements, constraints, and success criteria.

# GitHub Copilot Project Prompts

This file provides context-aware prompts for GitHub Copilot to assist with Paperless-NGX PDF viewer development.

---

## 🎯 Project Overview

You are working on **Paperless PDF Viewer Development** - a minimal, lightweight development environment for customizing PDF.js interactive features in Paperless-NGX.

**Mission**: Enable interactive PDF features (audio annotations, JavaScript execution, hyperlinks, multimedia) for Islamic educational materials.

**Key Constraints**:

- ✅ Keep it minimal & lightweight (~2GB total)
- ✅ Maintain 100% Paperless-NGX compatibility
- ✅ Use volume mounts for hot-reload (avoid rebuilds)
- ✅ Security-first for JavaScript execution (sandboxed)
- ✅ Support Arabic/RTL content
- ❌ No AI/RAG services (separate concern)
- ❌ No unnecessary dependencies

---

## 📚 Common Development Tasks

### 1. Adding New Interactive PDF Feature

**Prompt**:

```
I want to add [FEATURE_NAME] support to the PDF viewer.
This feature should:
- Be configurable via config/pdf-viewer-config.js
- Use PDF.js event handlers
- Be sandboxed/secure
- Support Arabic/RTL content
- Hot-reload without container rebuild

Generate the configuration object and event handler.
```

**Example Output Expected**:

```javascript
// config/pdf-viewer-config.js
PAPERLESS_PDFJS_CONFIG.featureName = {
  enabled: true,
  // ... configuration options
};

PAPERLESS_PDFJS_CONFIG.onFeatureEvent = function (data) {
  // ... handler implementation
  return result;
};
```

---

### 2. Customizing PDF.js Library

**Prompt**:

```
I need to modify PDF.js library to support [FUNCTIONALITY].
The change should:
- Be made in pdfjs-custom/lib/pdf.min.mjs
- Preserve existing functionality
- Be documented with comments
- Include error handling

Show me the code modification.
```

---

### 3. Adding Audio Annotation Support

**Prompt**:

```
Add audio annotation support for Quran recitation:
- Support MP3, WAV, OGG formats
- Show audio controls
- Max file size: 10MB
- Auto-create HTML5 audio element
- Insert at annotation position
- Include error handling

Generate the complete implementation.
```

---

### 4. JavaScript Execution (Sandboxed)

**Prompt**:

```
Implement sandboxed PDF JavaScript execution:
- Whitelist: app.alert, this.getField, AFSimple_Calculate
- Timeout: 5 seconds
- Error handling and logging
- Security sandbox enabled
- Support form calculations

Generate the configuration and handler.
```

---

### 5. Enhanced Hyperlink Handling

**Prompt**:

```
Create enhanced hyperlink handler:
- Confirm external links (dialog)
- Support internal navigation
- Track link clicks (console log)
- Support mailto: and file: protocols
- Open external in new tab

Generate the onLinkClick handler.
```

---

### 6. Docker Development Tasks

**Prompt**:

```
I need a [TASK_TYPE] Docker task:
- Should be minimal/lightweight
- Use Alpine images where possible
- Include health checks
- Proper error handling
- Resource limits

Generate the docker-compose.yml service definition.
```

---

### 7. REST API Integration

**Prompt**:

```
Create REST API request for [ENDPOINT]:
- Use authentication token
- Include error handling
- Format: .http file for REST Client extension
- Include example response
- Add comments for clarity

Generate the API request.
```

---

### 8. VS Code Task Creation

**Prompt**:

```
Create VS Code task for [TASK_NAME]:
- Shell command execution
- Proper presentation settings
- Problem matcher if applicable
- Descriptive label with emoji
- Add to .vscode/tasks.json

Generate the task configuration.
```

---

## 🔐 Security Patterns

### Sandboxed JavaScript Execution

**Prompt**:

```
Review this PDF JavaScript code for security:
[CODE]

Check for:
- Sandbox violations
- Unauthorized API calls
- Infinite loops
- Resource exhaustion
- XSS vulnerabilities

Provide security assessment and fixes.
```

---

### External Link Validation

**Prompt**:

```
Create link validation function:
- Validate URL format
- Check for dangerous protocols
- Confirm external navigation
- Block malicious patterns
- Log all link clicks

Generate the validator.
```

---

## 🕌 Islamic Library Features

### Quran Audio Integration

**Prompt**:

```
Implement Quran audio player:
- Reciter selection (Mishary Alafasy default)
- Ayah-by-ayah playback
- Synchronized highlighting
- Play/pause controls
- Volume control
- Support Arabic text (RTL)

Generate the audio player component.
```

---

### Arabic Text Rendering

**Prompt**:

```
Configure PDF.js for Arabic text:
- RTL text direction
- Arabic font support
- Tajweed highlighting
- Translation overlay
- Proper ligature rendering

Generate the configuration.
```

---

## 🧪 Testing Patterns

### Creating Test PDF with Interactive Features

**Prompt**:

```
Generate instructions for creating test PDF with:
- Audio annotations (Quran recitation)
- JavaScript (form calculation)
- External hyperlinks
- Internal navigation
- Fillable form fields
- Arabic text

Include Adobe Acrobat steps.
```

---

### API Testing

**Prompt**:

```
Create comprehensive API test suite for:
- Document upload
- PDF download
- Metadata retrieval
- Tag management
- Authentication

Use REST Client format (.http file).
```

---

## 🐛 Debugging Patterns

### Container Debugging

**Prompt**:

```
Debug [ISSUE] in Docker container:
- Check container logs
- Verify volume mounts
- Inspect file permissions
- Test network connectivity
- Validate environment variables

Generate debugging commands.
```

---

### PDF.js Debugging

**Prompt**:

```
Debug PDF.js [ISSUE]:
- Browser console logging
- PDF.js event tracking
- File verification
- Configuration validation
- Worker thread check

Generate debugging code.
```

---

## 📝 Documentation Patterns

### Feature Documentation

**Prompt**:

```
Document [FEATURE_NAME] feature:
- Purpose and use case
- Configuration options
- Code examples
- Testing steps
- Troubleshooting tips
- Islamic library integration

Generate markdown documentation.
```

---

### API Endpoint Documentation

**Prompt**:

```
Document API endpoint [ENDPOINT]:
- HTTP method and path
- Request parameters
- Response format
- Example request/response
- Error codes
- Authentication requirements

Generate API documentation.
```

---

## 🔧 Configuration Patterns

### Environment Variables

**Prompt**:

```
Add environment variable for [FEATURE]:
- Add to docker-compose.yml
- Document purpose and default value
- Update .env.example
- Add validation
- Include in README

Generate the configuration.
```

---

### Volume Mount Configuration

**Prompt**:

```
Configure volume mount for [PURPOSE]:
- Local path and container path
- Read/write permissions
- Directory creation
- Backup strategy
- Hot-reload support

Generate docker-compose.yml volume config.
```

---

## 🚀 Quick Start Prompts

### "I want to..."

**...add a new interactive PDF feature**

```
Add [FEATURE] to PDF viewer with config in config/pdf-viewer-config.js,
hot-reload support, and Arabic/RTL compatibility.
```

**...customize PDF.js library**

```
Modify pdfjs-custom/lib/pdf.min.mjs to support [FUNCTIONALITY]
with backward compatibility and error handling.
```

**...debug a container issue**

```
Debug [ISSUE] in [CONTAINER] - check logs, volumes, permissions,
and network. Provide diagnostic commands.
```

**...test API endpoint**

```
Create REST Client test for [ENDPOINT] with auth, error handling,
and example response in .vscode/api-tests.http.
```

**...optimize Docker image**

```
Reduce [SERVICE] container size using Alpine, multi-stage build,
and minimal dependencies. Maintain functionality.
```

**...add Quran feature**

```
Implement [QURAN_FEATURE] with Arabic support, RTL layout,
and audio integration. Use Islamic library config.
```

---

## 💡 Best Practices Reminders

When generating code, always:

1. **Maintain Compatibility**: Use Paperless-NGX official APIs
2. **Security First**: Sandbox JavaScript, validate inputs, confirm external links
3. **Hot-Reload**: Prefer config files over Dockerfile changes
4. **Minimal Size**: Use Alpine images, remove build tools after use
5. **Document Islamic Features**: Comment Quran, Arabic, RTL-specific code
6. **Error Handling**: Include try-catch, timeout, fallback
7. **Logging**: Console.log for development, proper logger for production
8. **Testing**: Include test instructions and example data
9. **Volume Mounts**: Use for development files (hot-reload)
10. **Comments**: Explain why, not just what

---

## 🎨 Code Style

### JavaScript (PDF.js Configuration)

```javascript
// Clear, descriptive names
PAPERLESS_PDFJS_CONFIG.featureName = {
  enabled: true,
  option1: "value",
  option2: 10,
};

// Event handlers with error handling
PAPERLESS_PDFJS_CONFIG.onEventName = function (data) {
  try {
    // Implementation
    console.log("Event:", data);
    return result;
  } catch (error) {
    console.error("Error in handler:", error);
    return null;
  }
};
```

### Docker Compose

```yaml
# Minimal service definition
service-name:
  image: alpine-based:latest # Prefer Alpine
  container_name: paperless-service
  restart: unless-stopped
  volumes:
    - ./local:/container:rw # Explicit permissions
  environment:
    - VAR_NAME=value
  healthcheck:
    test: ["CMD", "check-command"]
    interval: 30s
  deploy:
    resources:
      limits:
        memory: 512M # Resource limits
```

### Python (Paperless Backend)

```python
# Type hints and docstrings
def process_pdf(file_path: str) -> dict:
    """
    Process PDF with interactive features.

    Args:
        file_path: Path to PDF file

    Returns:
        Processing results dictionary
    """
    try:
        # Implementation
        return {"status": "success"}
    except Exception as e:
        logger.error(f"PDF processing error: {e}")
        return {"status": "error", "message": str(e)}
```

---

## 📊 Project Statistics

- **Total Size**: ~2GB (vs 7GB+ production)
- **Containers**: 5 (vs 11 production)
- **Boot Time**: <60 seconds
- **Hot-Reload**: Yes (config files)
- **Framework**: Paperless-NGX (100% compatible)
- **PDF Library**: PDF.js (Mozilla)

---

## 🔗 Quick References

- PDF.js API: https://mozilla.github.io/pdf.js/api/
- Paperless API: http://localhost:8003/api/
- Container Shell: `docker compose exec webserver bash`
- Logs: `docker compose logs -f webserver`
- Web UI: http://localhost:8003

---

**When in doubt, ask**: "How can I implement [FEATURE] while maintaining compatibility, security, and minimal size?"
