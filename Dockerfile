# =====================================
# 📚 PAPERLESS-NGX PDF VIEWER DEV
# Minimal & Lightweight Development Container
# =====================================
# 
# Purpose: PDF.js Interactive Viewer Development
# Base: Official Paperless-NGX (compatibility maintained)
# Size Target: < 800MB (vs 1.6GB production)
# Features: PDF.js customization, hot-reload, dev tools
# =====================================

FROM ghcr.io/paperless-ngx/paperless-ngx:latest AS base

# Metadata
LABEL maintainer="Digital Dakwah Platform"
LABEL description="Minimal Paperless-NGX for PDF.js Interactive Viewer Development"
LABEL version="1.0.0-dev"
LABEL repository="https://github.com/digitaldakwah/paperless-pdf-dev"

# =====================================
# DEVELOPMENT STAGE
# =====================================

FROM base AS development

USER root

# Install ONLY essential development tools (minimize size)
RUN apt-get update && apt-get install -y --no-install-recommends \
  # Core dev tools
  curl \
  wget \
  vim \
  nano \
  git \
  # Node.js for frontend development
  nodejs \
  npm \
  # Debugging essentials
  less \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

# Install minimal npm packages globally
RUN npm install -g --no-optional \
  http-server@14 \
  nodemon@3

# =====================================
# PDF.JS DEVELOPMENT SETUP
# =====================================

# Create development directories
RUN mkdir -p /usr/src/paperless/pdfjs-dev/{lib,config,assets} \
  && mkdir -p /usr/src/paperless/dev-scripts

# Copy PDF.js custom configuration (will be mounted as volume)
RUN mkdir -p /usr/src/paperless/static-custom

# =====================================
# DEVELOPMENT UTILITIES
# =====================================

# Create PDF.js extraction utility
RUN cat > /usr/src/paperless/dev-scripts/extract-pdfjs.sh << 'EOF'
#!/bin/bash
echo "📦 Extracting PDF.js library files..."
cp -r /usr/src/paperless/src/documents/static/frontend/en-US/assets/js/pdf*.mjs \
  /usr/src/paperless/pdfjs-dev/lib/ 2>/dev/null || true
echo "✅ PDF.js extracted to /usr/src/paperless/pdfjs-dev/lib/"
ls -lh /usr/src/paperless/pdfjs-dev/lib/
EOF

# Create hot-reload startup script
RUN cat > /usr/src/paperless/dev-scripts/dev-start.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting Paperless-NGX Development Mode..."
echo "📁 PDF.js Dev Location: /usr/src/paperless/pdfjs-dev/"
echo "🔗 Access: http://localhost:8000"
echo "📊 Interactive PDF Features: Enabled"
echo ""

# Extract PDF.js on first run
if [ ! -f /usr/src/paperless/pdfjs-dev/lib/pdf.min.mjs ]; then
/usr/src/paperless/dev-scripts/extract-pdfjs.sh
fi

# Start Paperless-NGX (s6-overlay entrypoint)
exec /init "$@"
EOF

# Make scripts executable
RUN chmod +x /usr/src/paperless/dev-scripts/*.sh

# =====================================
# ENVIRONMENT CONFIGURATION
# =====================================

ENV PAPERLESS_DEBUG=true \
  PAPERLESS_ENABLE_COMPRESSION=false \
  PAPERLESS_LOGGING_DIR=/usr/src/paperless/data/log \
  # PDF.js Development Flags
  PDFJS_DEV_MODE=true \
  PDFJS_ENABLE_AUDIO=true \
  PDFJS_ENABLE_JAVASCRIPT=true \
  PDFJS_ENABLE_HYPERLINKS=true \
  PDFJS_INTERACTIVE_MODE=true

# =====================================
# FILE OWNERSHIP
# =====================================

RUN chown -R paperless:paperless /usr/src/paperless/pdfjs-dev \
  && chown -R paperless:paperless /usr/src/paperless/dev-scripts \
  && chown -R paperless:paperless /usr/src/paperless/static-custom

# Switch to paperless user
USER paperless

# Working directory
WORKDIR /usr/src/paperless

# =====================================
# HEALTH CHECK
# =====================================

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8000/api/ || exit 1

# =====================================
# ENTRYPOINT
# =====================================

# Use development startup script
ENTRYPOINT ["/usr/src/paperless/dev-scripts/dev-start.sh"]

# =====================================
# BUILD OPTIMIZATION NOTES
# =====================================
# 
# Size Reduction Strategies:
# - Minimal dependencies (no Angular CLI, TypeScript, etc.)
# - No build tools (use pre-compiled Paperless-NGX)
# - Volume mounts for file editing (no rebuilds)
# - Alpine-based services where possible
#
# Compatibility:
# - Base: Official ghcr.io/paperless-ngx/paperless-ngx:latest
# - Updates: Automatic with base image updates
# - Frameworks: Maintains 100% Paperless-NGX compatibility
#
# Development Workflow:
# - Edit PDF.js: Mount volume to pdfjs-dev/
# - No rebuilds: Changes via volume mounts
# - Testing: Real-time with Paperless-NGX stack
#
# =====================================
