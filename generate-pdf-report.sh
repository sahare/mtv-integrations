#!/bin/bash

# MTV Integrations Threat Dragon Report PDF Generator
# This script generates PDF reports from the threat model documentation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT_NAME="MTV-Integrations-ThreatDragon-Report"
SOURCE_FILE="$SCRIPT_DIR/$REPORT_NAME.md"
OUTPUT_FILE="$SCRIPT_DIR/$REPORT_NAME.pdf"

echo "🔒 MTV Integrations Threat Dragon Report Generator"
echo "=================================================="

# Check if source file exists
if [[ ! -f "$SOURCE_FILE" ]]; then
    echo "❌ Error: Source file not found: $SOURCE_FILE"
    exit 1
fi

echo "📄 Source file: $SOURCE_FILE"
echo "📁 Output file: $OUTPUT_FILE"
echo ""

# Check for pandoc
if command -v pandoc >/dev/null 2>&1; then
    echo "✅ Pandoc found: $(pandoc --version | head -n1)"
    
    # Check for LaTeX
    if command -v xelatex >/dev/null 2>&1; then
        echo "✅ XeLaTeX found: $(xelatex --version | head -n1)"
        PDF_ENGINE="--pdf-engine=xelatex"
    elif command -v pdflatex >/dev/null 2>&1; then
        echo "✅ PDFLaTeX found: $(pdflatex --version | head -n1)" 
        PDF_ENGINE="--pdf-engine=pdflatex"
    else
        echo "⚠️  No LaTeX engine found, using default"
        PDF_ENGINE=""
    fi
    
    echo ""
    echo "🔄 Generating PDF report..."
    
    # Generate PDF with professional formatting
    pandoc "$SOURCE_FILE" \
        -o "$OUTPUT_FILE" \
        $PDF_ENGINE \
        --toc \
        --toc-depth=3 \
        --number-sections \
        -V geometry:margin=1in \
        -V fontsize=11pt \
        -V documentclass=report \
        -V title="MTV Integrations - Threat Dragon Security Report" \
        -V subtitle="Comprehensive Security Assessment" \
        -V author="Security Team" \
        -V date="$(date '+%Y-%m-%d')" \
        -V colorlinks=true \
        -V linkcolor=blue \
        -V urlcolor=blue \
        -V toccolor=black \
        --highlight-style=tango \
        2>/dev/null || {
            echo "⚠️  PDF generation with advanced options failed, trying basic conversion..."
            pandoc "$SOURCE_FILE" -o "$OUTPUT_FILE" --toc
        }
    
    if [[ -f "$OUTPUT_FILE" ]]; then
        FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
        echo ""
        echo "✅ PDF report generated successfully!"
        echo "📄 File: $OUTPUT_FILE"
        echo "📊 Size: $FILE_SIZE"
        echo ""
        echo "🔍 Report contents:"
        echo "   • 16 security threats identified"
        echo "   • 2 critical, 8 high, 6 medium risk threats"
        echo "   • Complete STRIDE analysis"
        echo "   • Security recommendations and roadmap"
        echo ""
        echo "🚨 WARNING: This report contains CONFIDENTIAL security information"
        echo "           Handle according to organizational security policies"
        
        # Try to open the PDF (optional)
        if command -v open >/dev/null 2>&1; then
            echo ""
            read -p "📖 Open PDF now? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                open "$OUTPUT_FILE"
            fi
        fi
    else
        echo "❌ Error: PDF generation failed"
        exit 1
    fi
    
else
    echo "❌ Pandoc not found!"
    echo ""
    echo "📥 Installation options:"
    echo ""
    echo "🍎 macOS:"
    echo "   brew install pandoc"
    echo "   brew install --cask basictex  # For LaTeX support"
    echo ""
    echo "🐧 Ubuntu/Debian:"
    echo "   sudo apt update"
    echo "   sudo apt install pandoc texlive-xetex texlive-fonts-recommended"
    echo ""
    echo "🪟 Windows:"
    echo "   Download from: https://pandoc.org/installing.html"
    echo ""
    echo "🌐 Alternative: Use online converters or VS Code extensions"
    echo "   See PDF-Generation-Instructions.md for details"
    echo ""
    exit 1
fi

echo ""
echo "📚 Additional formats available:"
echo "   • HTML: pandoc $SOURCE_FILE -o $REPORT_NAME.html --toc --standalone"
echo "   • Word: pandoc $SOURCE_FILE -o $REPORT_NAME.docx --toc"
echo ""
echo "📖 For more options, see: PDF-Generation-Instructions.md"
echo ""
echo "🎉 Report generation complete!"
