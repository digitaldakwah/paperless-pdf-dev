#!/bin/bash
# =====================================
# Create Sample Test PDFs
# =====================================
# This script creates simple test PDFs to verify viewer functionality

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}📄 Creating test PDF samples...${NC}"
echo ""

# Check if ghostscript is available
if ! command -v gs &> /dev/null; then
    echo -e "${YELLOW}⚠️  ghostscript not found. Installing...${NC}"
    sudo apt-get update && sudo apt-get install -y ghostscript
fi

# Test PDF 1: Simple text document
echo -e "${BLUE}1️⃣  Creating simple text PDF...${NC}"
cat > /tmp/test-simple.ps << 'EOF'
%!PS-Adobe-3.0
%%BoundingBox: 0 0 612 792
%%Title: Simple Test PDF
%%Creator: Paperless PDF Viewer Dev
%%Pages: 1
%%EndComments

%%Page: 1 1
/Times-Roman findfont 24 scalefont setfont
100 700 moveto
(Paperless PDF Viewer - Test Document) show

/Times-Roman findfont 16 scalefont setfont
100 650 moveto
(This is a simple test PDF to verify basic rendering.) show

100 600 moveto
(Interactive features:) show

/Times-Roman findfont 14 scalefont setfont
120 570 moveto
(- Audio annotations) show
120 550 moveto
(- JavaScript execution) show
120 530 moveto
(- Hyperlinks) show
120 510 moveto
(- Interactive forms) show

showpage
%%EOF
EOF

gs -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile=./consume/test-simple.pdf /tmp/test-simple.ps 2>/dev/null
echo -e "${GREEN}✅ Created: ./consume/test-simple.pdf${NC}"

# Test PDF 2: Document with hyperlinks
echo -e "${BLUE}2️⃣  Creating PDF with hyperlinks...${NC}"
cat > /tmp/test-links.ps << 'EOF'
%!PS-Adobe-3.0
%%BoundingBox: 0 0 612 792
%%Title: Hyperlink Test PDF
%%Pages: 2
%%EndComments

%%Page: 1 1
/Times-Roman findfont 20 scalefont setfont
100 700 moveto
(Hyperlink Test Document - Page 1) show

/Times-Roman findfont 14 scalefont setfont
100 650 moveto
(This PDF contains test hyperlinks:) show

100 600 moveto
(External link: https://mozilla.github.io/pdf.js/) show

100 550 moveto
(Internal link: Go to Page 2) show

showpage

%%Page: 2 2
/Times-Roman findfont 20 scalefont setfont
100 700 moveto
(Page 2 - Destination Page) show

/Times-Roman findfont 14 scalefont setfont
100 650 moveto
(You successfully navigated to page 2!) show

showpage
%%EOF
EOF

gs -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile=./consume/test-links.pdf /tmp/test-links.ps 2>/dev/null
echo -e "${GREEN}✅ Created: ./consume/test-links.pdf${NC}"

# Test PDF 3: Arabic/RTL text
echo -e "${BLUE}3️⃣  Creating Arabic/RTL test PDF...${NC}"
cat > /tmp/test-arabic.ps << 'EOF'
%!PS-Adobe-3.0
%%BoundingBox: 0 0 612 792
%%Title: Arabic RTL Test
%%Pages: 1
%%EndComments

%%Page: 1 1
/Times-Roman findfont 20 scalefont setfont
100 700 moveto
(Arabic/RTL Test Document) show

/Times-Roman findfont 14 scalefont setfont
100 650 moveto
(This document tests Right-to-Left text support) show

100 600 moveto
(Islamic Library Features:) show

120 570 moveto
(- RTL text direction) show
120 550 moveto
(- Arabic font support) show
120 530 moveto
(- Quran audio integration) show

showpage
%%EOF
EOF

gs -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile=./consume/test-arabic.pdf /tmp/test-arabic.ps 2>/dev/null
echo -e "${GREEN}✅ Created: ./consume/test-arabic.pdf${NC}"

# Cleanup
rm -f /tmp/test-*.ps

echo ""
echo -e "${GREEN}✅ Test PDFs created successfully!${NC}"
echo ""
echo -e "${BLUE}📊 Summary:${NC}"
ls -lh ./consume/*.pdf 2>/dev/null || echo "No PDFs found"
echo ""
echo -e "${BLUE}📝 Next Steps:${NC}"
echo "   1. PDFs are now in ./consume/ directory"
echo "   2. Access viewer: http://localhost:8003"
echo "   3. Documents will be auto-imported"
echo "   4. Open browser console (F12) to test features"
echo ""
