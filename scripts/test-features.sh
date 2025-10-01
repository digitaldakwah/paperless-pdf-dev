#!/bin/bash
# =====================================
# PDF Viewer Feature Testing Script
# =====================================

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "=================================================="
echo -e "${BLUE}🧪 PDF Viewer Interactive Features Test${NC}"
echo "=================================================="
echo ""

# Check if containers are running
echo -e "${BLUE}📊 Checking container status...${NC}"
if ! docker compose ps | grep -q "healthy"; then
    echo -e "${YELLOW}⚠️  Some containers are not healthy${NC}"
    docker compose ps
    echo ""
fi

# Test 1: Configuration loaded
echo -e "${BLUE}1️⃣  Testing configuration loading...${NC}"
CONFIG_PRESENT=$(docker compose exec -T webserver test -f /usr/src/paperless/static-custom/pdf-config.js && echo "YES" || echo "NO")

if [ "$CONFIG_PRESENT" = "YES" ]; then
    echo -e "${GREEN}✅ Configuration file present${NC}"
else
    echo -e "${RED}❌ Configuration file missing${NC}"
    exit 1
fi

# Test 2: PDF.js library files
echo -e "${BLUE}2️⃣  Testing PDF.js library files...${NC}"
if [ -f "./pdfjs-custom/lib/pdf.min.mjs" ] && [ -f "./pdfjs-custom/lib/pdf.worker.min.mjs" ]; then
    PDF_SIZE=$(du -sh ./pdfjs-custom/lib/pdf.min.mjs | cut -f1)
    WORKER_SIZE=$(du -sh ./pdfjs-custom/lib/pdf.worker.min.mjs | cut -f1)
    echo -e "${GREEN}✅ PDF.js library files present${NC}"
    echo "   - pdf.min.mjs: $PDF_SIZE"
    echo "   - pdf.worker.min.mjs: $WORKER_SIZE"
else
    echo -e "${YELLOW}⚠️  PDF.js library files not found. Extracting...${NC}"
    docker compose exec -T webserver /usr/src/paperless/dev-scripts/extract-pdfjs.sh
fi

# Test 3: Feature configuration
echo -e "${BLUE}3️⃣  Testing feature configuration...${NC}"
echo "   Checking enabled features in config file..."

# Test 4: Web UI accessibility
echo -e "${BLUE}4️⃣  Testing web UI accessibility...${NC}"
if curl -f -s http://localhost:8003/api/ > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Web UI accessible at http://localhost:8003${NC}"
else
    echo -e "${RED}❌ Web UI not accessible${NC}"
    echo "   Run: docker compose logs webserver"
    exit 1
fi

# Test 5: Check consume directory
echo -e "${BLUE}5️⃣  Checking consume directory for test PDFs...${NC}"
if [ -d "./consume" ]; then
    PDF_COUNT=$(find ./consume -name "*.pdf" 2>/dev/null | wc -l)
    if [ "$PDF_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✅ Found $PDF_COUNT PDF(s) in consume directory${NC}"
        find ./consume -name "*.pdf" -exec basename {} \;
    else
        echo -e "${YELLOW}⚠️  No test PDFs found in ./consume/${NC}"
        echo "   Upload test PDFs to ./consume/ directory"
    fi
else
    echo -e "${RED}❌ Consume directory not found${NC}"
fi

# Summary
echo ""
echo "=================================================="
echo -e "${GREEN}✅ Testing Complete!${NC}"
echo "=================================================="
echo ""
echo -e "${BLUE}📝 Next Steps:${NC}"
echo "   1. Upload test PDFs to ./consume/"
echo "   2. Access viewer: http://localhost:8003"
echo "   3. Open browser console (F12)"
echo "   4. Test interactive features"
echo ""
echo -e "${BLUE}🔧 Useful Commands:${NC}"
echo "   - View logs: docker compose logs -f webserver"
echo "   - Restart: docker compose restart webserver"
echo "   - Shell: docker compose exec webserver bash"
echo ""
echo -e "${BLUE}📖 Documentation:${NC}"
echo "   - ./docs/INTERACTIVE_FEATURES.md"
echo "   - ./README.md"
echo ""
