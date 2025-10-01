# 🚀 VS Code Development Guide

## Quick Start

1. **Open Workspace**:
   - Open `paperless-pdf-dev.code-workspace` in VS Code
   - Install recommended extensions when prompted

2. **Install Extensions**:
   - VS Code will prompt to install recommended extensions
   - Or manually: `Ctrl+Shift+P` → "Extensions: Show Recommended Extensions"

3. **Start Development**:
   - Press `Ctrl+Shift+B` (default build task) to run setup
   - Or use Command Palette: `Tasks: Run Task` → "🚀 Start Development Environment"

## Essential Extensions

### Required
- **Docker** (`ms-azuretools.vscode-docker`) - Container management
- **ESLint** (`dbaeumer.vscode-eslint`) - JavaScript linting
- **Prettier** (`esbenp.prettier-vscode`) - Code formatting
- **Python** (`ms-python.python`) - Python support
- **YAML** (`redhat.vscode-yaml`) - Docker Compose validation

### Recommended
- **GitLens** (`eamodio.gitlens`) - Git supercharged
- **Todo Tree** (`gruntfuggly.todo-tree`) - Track TODO comments
- **REST Client** (`humao.rest-client`) - API testing
- **GitHub Copilot** (`github.copilot`) - AI pair programming

## Available Tasks

Press `Ctrl+Shift+P` → `Tasks: Run Task` to access:

### Development
- **🚀 Start Development Environment** - Full setup (default: `Ctrl+Shift+B`)
- **🔨 Build Containers** - Build Docker images
- **▶️ Start Containers** - Start services
- **⏹️ Stop Containers** - Stop all services

### Debugging
- **📋 View Logs - Webserver** - Follow webserver logs
- **📋 View All Logs** - All container logs
- **🐚 Shell: Webserver Container** - Bash shell in webserver
- **🐚 Shell: Database Container** - PostgreSQL shell

### PDF.js Development
- **📦 Extract PDF.js Files** - Extract PDF.js from container
- **📁 List PDF.js Files** - Show PDF.js library files
- **🔄 Restart Webserver** - Apply config changes

### Utilities
- **🌐 Open Web UI** - Open http://localhost:8003
- **📊 Docker Container Stats** - Resource usage
- **🔍 Check Container Health** - Service status
- **🧹 Clean Everything** - Remove all containers and volumes
- **🔐 Get Admin Token** - Get API authentication token

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+B` | Run default build task (setup) |
| `Ctrl+Shift+P` | Command palette |
| `Ctrl+`` | Toggle terminal |
| `Ctrl+Shift+D` | Debug view |
| `Ctrl+Shift+E` | Explorer view |
| `Ctrl+Shift+G` | Source control |
| `Ctrl+Shift+X` | Extensions |
| `Ctrl+K Ctrl+O` | Open folder |
| `F5` | Start debugging |

## API Testing with REST Client

1. Open `.vscode/api-tests.http`
2. Click "Send Request" above each request
3. View response in split panel

**Quick Tests**:
- Get token (request #1)
- List documents (request #4)
- Upload PDF (request #5)
- Download PDF (request #7)

## Debugging

### Python (Paperless Backend)
1. Set breakpoints in Python files
2. Run debug config: "🐍 Python: Attach to Webserver"
3. Container must be started with debug port exposed

### JavaScript (PDF.js)
1. Open browser DevTools (F12)
2. Sources tab → Filesystem → Add workspace folder
3. Set breakpoints in PDF.js files
4. Reload page

### Docker Container
1. Use task: "🐚 Shell: Webserver Container"
2. Navigate to `/usr/src/paperless/pdfjs-dev/`
3. Check files: `ls -la lib/`

## File Watching & Hot-Reload

### What Hot-Reloads (No Restart)
- `config/pdf-viewer-config.js` - PDF.js configuration
- Files in `consume/` - Auto-imported PDFs

### What Needs Restart
- `pdfjs-custom/lib/*.mjs` - PDF.js library files
- Environment variables in `docker-compose.yml`
- Task: "🔄 Restart Webserver"

### What Needs Rebuild
- `Dockerfile` changes
- New dependencies
- Task: "🔨 Build Containers"

## Common Workflows

### 1. Modify PDF.js Configuration
```bash
# Edit config
nano config/pdf-viewer-config.js

# Changes apply immediately (volume mounted)
# Refresh browser (Ctrl+F5)
```

### 2. Test Interactive PDF
```bash
# Copy PDF to consume directory
cp interactive-test.pdf consume/

# Watch logs
docker compose logs -f webserver | grep -i pdf

# View in UI
# http://localhost:8003
```

### 3. Customize PDF.js Library
```bash
# Extract PDF.js first (if not already done)
Task: "📦 Extract PDF.js Files"

# Edit library
nano pdfjs-custom/lib/pdf.min.mjs

# Restart webserver
Task: "🔄 Restart Webserver"

# Test changes
```

### 4. Debug API Issue
```bash
# Get auth token
Task: "🔐 Get Admin Token"

# Test API with REST Client
Open: .vscode/api-tests.http
Run requests

# Check logs
Task: "📋 View Logs - Webserver"
```

## Directory Structure Navigation

```
paperless-pdf-dev/
├── 📄 README.md                    # Main documentation
├── 📄 CHANGELOG.md                 # Version history
├── 🐳 Dockerfile                   # Container definition
├── 🐳 docker-compose.yml           # Service orchestration
│
├── ⚙️ config/
│   └── pdf-viewer-config.js       # PDF.js config (HOT-RELOAD)
│
├── 📦 pdfjs-custom/
│   ├── lib/                       # PDF.js libraries (EDIT HERE)
│   ├── backup/                    # Auto backups
│   └── config/                    # Additional configs
│
├── 🔧 scripts/
│   └── setup.sh                   # Quick start script
│
├── 📁 consume/                     # Upload PDFs here
├── 📁 export/                      # Exported documents
├── 📁 assets/                      # Custom assets
│
└── 💻 .vscode/
    ├── settings.json              # Editor settings
    ├── tasks.json                 # Build tasks
    ├── launch.json                # Debug configs
    ├── extensions.json            # Recommended extensions
    └── api-tests.http             # API testing
```

## Troubleshooting

### Container Won't Start
```bash
# Check logs
Task: "📋 View All Logs"

# Check disk space
df -h

# Clean and rebuild
Task: "🧹 Clean Everything (with volumes)"
Task: "🔨 Build Containers"
Task: "▶️ Start Containers"
```

### PDF.js Not Loading
```bash
# Extract PDF.js
Task: "📦 Extract PDF.js Files"

# Verify files
Task: "📁 List PDF.js Files"

# Check browser console
F12 → Console → Look for errors
```

### Changes Not Reflecting
```bash
# Clear browser cache
Ctrl+Shift+Del → Clear cache

# Hard refresh
Ctrl+F5

# Restart container
Task: "🔄 Restart Webserver"
```

### Port Already in Use
```bash
# Check what's using port 8003
sudo lsof -i :8003

# Change port in docker-compose.yml
ports:
  - "8004:8000"  # Changed from 8003
```

## Git Workflow

### Initial Setup
```bash
git config user.name "Your Name"
git config user.email "your@email.com"
```

### Commit Changes
```bash
# Stage changes
git add .

# Commit
git commit -m "feat: Add audio annotation support"

# Push
git push origin main
```

### Branch Strategy
```bash
# Create feature branch
git checkout -b feature/quran-audio

# Make changes, commit

# Merge to main
git checkout main
git merge feature/quran-audio
```

## Tips & Tricks

1. **Quick Container Shell**: `Ctrl+Shift+P` → "Tasks: Run Task" → "🐚 Shell: Webserver Container"

2. **Auto-format on Save**: Already enabled for JS, Python, YAML

3. **PDF.js Console Logs**: Browser console shows PDF.js initialization and errors

4. **Live Reload**: Edit `config/pdf-viewer-config.js` → Save → Refresh browser

5. **Docker Stats**: Monitor resource usage with "📊 Docker Container Stats" task

6. **API Testing**: Use `.vscode/api-tests.http` with REST Client extension

7. **TODO Tracking**: Write `// TODO: Description` in code → Shows in Todo Tree

8. **Path Autocomplete**: Type `./` to get file path suggestions

9. **Git Blame**: Click line number → GitLens shows commit info

10. **Multi-cursor**: `Alt+Click` to add cursors, edit multiple lines

## Resources

- **PDF.js Docs**: https://mozilla.github.io/pdf.js/
- **Paperless-NGX**: https://docs.paperless-ngx.com/
- **Docker Compose**: https://docs.docker.com/compose/
- **VS Code Shortcuts**: `Ctrl+K Ctrl+S`

---

**Need Help?**
- Check README.md for detailed documentation
- Open an issue on GitHub
- Check container logs: `docker compose logs -f`
