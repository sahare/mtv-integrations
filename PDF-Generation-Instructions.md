# PDF Report Generation Instructions

## Overview
This guide provides multiple methods to generate PDF reports from your MTV Integrations threat model documentation.

## Method 1: Convert Markdown to PDF (Recommended)

### Option A: Using Pandoc (Best Quality)
```bash
# Install pandoc (if not already installed)
# macOS: brew install pandoc
# Ubuntu: sudo apt install pandoc
# Windows: Download from https://pandoc.org/installing.html

# Generate PDF with professional styling
pandoc MTV-Integrations-ThreatDragon-Report.md \
  -o MTV-Integrations-ThreatDragon-Report.pdf \
  --pdf-engine=xelatex \
  --toc \
  --toc-depth=3 \
  --number-sections \
  -V geometry:margin=1in \
  -V fontsize=11pt \
  -V documentclass=report
```

### Option B: Using VS Code Extension
1. **Install Extension**: "Markdown PDF" by yzane
2. **Open File**: `MTV-Integrations-ThreatDragon-Report.md`
3. **Generate PDF**: 
   - `Ctrl/Cmd + Shift + P`
   - Type "Markdown PDF: Export (pdf)"
   - Select and execute

### Option C: Using Online Converters
1. **Recommended Sites**:
   - https://www.markdowntopdf.com/
   - https://md2pdf.netlify.app/
   - https://dillinger.io/ (with export option)

2. **Process**:
   - Upload or paste the markdown content
   - Configure styling options
   - Download generated PDF

## Method 2: Generate from Threat Dragon (Interactive)

### Option A: Threat Dragon Desktop Application
```bash
# 1. Download and install Threat Dragon
# Visit: https://owasp.org/www-project-threat-dragon/

# 2. Open your threat model
# File → Open → Select: mtv-integrations-threat-model.json

# 3. Generate PDF Report
# Reports → Generate Report → Select PDF format
# Choose report sections and styling options
```

### Option B: Threat Dragon Web Application
```bash
# 1. Visit https://www.threatdragon.org/

# 2. Import your model
# Click "Import Model" → Upload: mtv-integrations-threat-model.json

# 3. Generate Report
# Use the "Reports" menu to generate and download PDF
```

## Method 3: Create Custom PDF Report

### Using LaTeX Template (Advanced)
```bash
# 1. Install LaTeX distribution
# macOS: brew install --cask mactex
# Ubuntu: sudo apt install texlive-full
# Windows: Download MiKTeX from https://miktex.org/

# 2. Create custom template (optional)
# Use the provided LaTeX styling for professional output

# 3. Generate with pandoc and custom template
pandoc MTV-Integrations-ThreatDragon-Report.md \
  -o MTV-Integrations-ThreatDragon-Report.pdf \
  --pdf-engine=xelatex \
  --template=custom-template.tex \
  --toc \
  --number-sections
```

## Method 4: Browser Print to PDF

### Chrome/Edge/Safari
1. **Open File**: Open `MTV-Integrations-ThreatDragon-Report.md` in VS Code with markdown preview
2. **Print Preview**: 
   - `Ctrl/Cmd + P`
   - Destination: "Save as PDF"
   - Layout: "Portrait"
   - Margins: "Default"
   - Options: Include headers and footers
3. **Save**: Choose filename and location

## Styling and Formatting Options

### Professional Report Styling
```yaml
# Add to markdown frontmatter for enhanced PDF generation
---
title: "MTV Integrations - Threat Dragon Security Report"
subtitle: "Comprehensive Security Assessment"
author: "Security Team"
date: "$(date)"
documentclass: report
geometry: 
  - margin=1in
fontsize: 11pt
mainfont: "Times New Roman"
sansfont: "Arial"
monofont: "Courier New"
colorlinks: true
linkcolor: blue
urlcolor: blue
toccolor: black
---
```

### Custom CSS for Web-based Conversion
```css
/* Add to custom.css for web-based PDF generation */
body {
    font-family: "Times New Roman", serif;
    line-height: 1.6;
    color: #333;
}

h1, h2, h3, h4, h5, h6 {
    color: #2c3e50;
    font-family: "Arial", sans-serif;
}

.critical {
    color: #e74c3c;
    font-weight: bold;
}

.high {
    color: #e67e22;
    font-weight: bold;
}

.medium {
    color: #f39c12;
    font-weight: bold;
}

table {
    border-collapse: collapse;
    margin: 20px 0;
}

th, td {
    border: 1px solid #ddd;
    padding: 8px 12px;
    text-align: left;
}

th {
    background-color: #f8f9fa;
    font-weight: bold;
}
```

## Batch Generation Script

### Generate All Report Formats
```bash
#!/bin/bash
# generate-reports.sh

# Set variables
REPORT_NAME="MTV-Integrations-ThreatDragon-Report"
SOURCE_FILE="$REPORT_NAME.md"

echo "Generating threat model reports..."

# Generate PDF with pandoc (high quality)
if command -v pandoc &> /dev/null; then
    echo "Generating PDF with pandoc..."
    pandoc "$SOURCE_FILE" \
        -o "$REPORT_NAME.pdf" \
        --pdf-engine=xelatex \
        --toc \
        --toc-depth=3 \
        --number-sections \
        -V geometry:margin=1in \
        -V fontsize=11pt \
        -V documentclass=report
    echo "✅ PDF generated: $REPORT_NAME.pdf"
else
    echo "⚠️  Pandoc not found, skipping PDF generation"
fi

# Generate HTML version
if command -v pandoc &> /dev/null; then
    echo "Generating HTML..."
    pandoc "$SOURCE_FILE" \
        -o "$REPORT_NAME.html" \
        --toc \
        --toc-depth=3 \
        --number-sections \
        --css=custom.css \
        --standalone
    echo "✅ HTML generated: $REPORT_NAME.html"
fi

# Generate Word document
if command -v pandoc &> /dev/null; then
    echo "Generating Word document..."
    pandoc "$SOURCE_FILE" \
        -o "$REPORT_NAME.docx" \
        --toc \
        --toc-depth=3 \
        --number-sections
    echo "✅ Word document generated: $REPORT_NAME.docx"
fi

echo "Report generation complete!"
```

## Quality Assurance Checklist

### Before PDF Generation
- [ ] Review markdown formatting and syntax
- [ ] Verify all tables render correctly
- [ ] Check all links are functional
- [ ] Ensure proper heading hierarchy
- [ ] Validate threat IDs and references

### After PDF Generation
- [ ] Check PDF page breaks are logical
- [ ] Verify table of contents is accurate
- [ ] Ensure all tables fit properly
- [ ] Validate page numbers and headers
- [ ] Review overall formatting and readability

## Troubleshooting Common Issues

### Pandoc Installation Issues
```bash
# macOS troubleshooting
brew install pandoc
brew install --cask basictex  # Lightweight LaTeX

# Ubuntu troubleshooting
sudo apt update
sudo apt install pandoc texlive-xetex texlive-fonts-recommended

# Check installation
pandoc --version
```

### LaTeX Font Issues
```bash
# Install additional fonts for XeTeX
# macOS
brew install font-times-new-roman
brew install font-arial

# Ubuntu
sudo apt install fonts-liberation
sudo apt install fonts-dejavu
```

### Large File Handling
```bash
# For very large reports, increase memory limits
pandoc --pdf-engine-opt=-interaction=nonstopmode \
       --pdf-engine-opt=-max-print-line=120 \
       --pdf-engine-opt=-halt-on-error \
       input.md -o output.pdf
```

## Distribution and Security

### Document Classification
- **CONFIDENTIAL**: Contains security-sensitive information
- **Internal Use Only**: Restrict distribution according to organizational policy
- **Version Control**: Include version numbers and generation dates

### Secure Distribution
```bash
# Generate password-protected PDF (if supported)
pandoc MTV-Integrations-ThreatDragon-Report.md \
  -o MTV-Integrations-ThreatDragon-Report.pdf \
  --pdf-engine=xelatex \
  --variable=password:"secure_password_here"

# Or use external tools for password protection
qpdf --encrypt user_pass owner_pass 256 -- \
  input.pdf output-encrypted.pdf
```

---

**Note**: Choose the method that best fits your environment and requirements. For official reports, pandoc with LaTeX provides the highest quality output.
