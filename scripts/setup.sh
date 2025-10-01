#!/bin/bash
# =====================================
# 🚀 QUICK START SCRIPT
# Paperless PDF Viewer Development
# =====================================

set -e

echo "=================================================="
echo "📚 PAPERLESS PDF VIEWER - DEVELOPMENT SETUP"
echo "=================================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found. Please install Docker first.${NC}"
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose not found. Please install Docker Compose first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker found${NC}"
echo ""

# Create required directories
echo -e "${BLUE}📁 Creating directories...${NC}"
mkdir -p consume export assets pdfjs-custom/{lib,backup,config}

# Extract PDF.js from production (if available)
if docker ps | grep -q "paperless-webserver-1"; then
    echo -e "${BLUE}📦 Extracting PDF.js from production container...${NC}"
    
    docker cp paperless-webserver-1:/usr/src/paperless/src/documents/static/frontend/en-US/assets/js/pdf.min.mjs \
        ./pdfjs-custom/lib/pdf.min.mjs 2>/dev/null || echo -e "${YELLOW}⚠️  Could not extract pdf.min.mjs${NC}"
    
    docker cp paperless-webserver-1:/usr/src/paperless/src/documents/static/frontend/en-US/assets/js/pdf.worker.min.mjs \
        ./pdfjs-custom/lib/pdf.worker.min.mjs 2>/dev/null || echo -e "${YELLOW}⚠️  Could not extract pdf.worker.min.mjs${NC}"
    
    if [ -f ./pdfjs-custom/lib/pdf.min.mjs ]; then
        echo -e "${GREEN}✅ PDF.js library extracted${NC}"
        cp -r ./pdfjs-custom/lib/* ./pdfjs-custom/backup/ 2>/dev/null || true
        echo -e "${GREEN}✅ Backup created${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Production container not running. PDF.js will be extracted on first container start.${NC}"
fi

echo ""
echo -e "${BLUE}🔨 Building Docker containers...${NC}"
docker compose build --no-cache

echo ""
echo -e "${BLUE}🚀 Starting services...${NC}"
docker compose up -d

echo ""
echo -e "${BLUE}⏳ Waiting for services to be ready...${NC}"
sleep 15

# Check health
if docker compose ps | grep -q "healthy\|running"; then
    echo -e "${GREEN}✅ Services started successfully!${NC}"
else
    echo -e "${YELLOW}⚠️  Some services may still be starting...${NC}"
fi

echo ""
echo "=================================================="
echo -e "${GREEN}🎉 SETUP COMPLETE!${NC}"
echo "=================================================="
echo ""
echo -e "📊 Service Status:"
docker compose ps
echo ""
echo -e "🌐 Access Points:"
echo -e "   ${BLUE}Web UI:${NC}     http://localhost:8003"
echo -e "   ${BLUE}API:${NC}        http://localhost:8003/api/"
echo -e "   ${BLUE}Admin:${NC}      admin / admin"
echo ""
echo -e "📁 Development Directories:"
echo -e "   ${BLUE}PDF.js Files:${NC}      ./pdfjs-custom/"
echo -e "   ${BLUE}Configuration:${NC}     ./config/pdf-viewer-config.js"
echo -e "   ${BLUE}Upload:${NC}            ./consume/"
echo -e "   ${BLUE}Export:${NC}            ./export/"
echo ""
echo -e "🔧 Quick Commands:"
echo -e "   View logs:        ${BLUE}docker compose logs -f webserver${NC}"
echo -e "   Shell access:     ${BLUE}docker compose exec webserver bash${NC}"
echo -e "   Restart:          ${BLUE}docker compose restart webserver${NC}"
echo -e "   Stop:             ${BLUE}docker compose down${NC}"
echo ""
echo -e "📚 Next Steps:"
echo -e "   1. Open http://localhost:8003"
echo -e "   2. Login with admin/admin"
echo -e "   3. Upload a PDF with interactive features"
echo -e "   4. Edit ./config/pdf-viewer-config.js for customization"
echo -e "   5. Check ./pdfjs-custom/lib/ for PDF.js library files"
echo ""
echo -e "📖 Documentation: ${BLUE}./README.md${NC}"
echo "=================================================="
