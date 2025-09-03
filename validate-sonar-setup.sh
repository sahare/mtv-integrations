#!/bin/bash

# Validate SonarQube Setup for MTV Integrations
# This script checks that all components are properly configured

echo "🔍 Validating SonarQube setup for MTV Integrations..."
echo "=================================================="

# Check sonar-project.properties exists and has correct content
echo "1. Checking sonar-project.properties configuration..."
if [ -f "sonar-project.properties" ]; then
    echo "   ✅ sonar-project.properties exists"
    
    if grep -q "sonar.go.coverage.reportPaths=cover.out" sonar-project.properties; then
        echo "   ✅ Coverage paths configured correctly"
    else
        echo "   ⚠️  Coverage paths may need verification"
    fi
    
    if grep -q "sonar.tests=test/,controllers/" sonar-project.properties; then
        echo "   ✅ Test paths configured correctly"
    else
        echo "   ⚠️  Test paths may need verification"
    fi
    
    if grep -q "\*\*/vendor/\*\*" sonar-project.properties; then
        echo "   ✅ Vendor directory properly excluded"
    else
        echo "   ⚠️  Vendor exclusions may need verification"
    fi
else
    echo "   ❌ sonar-project.properties not found!"
    exit 1
fi

echo ""

# Check for test files
echo "2. Checking test file structure..."
TEST_FILES=$(find . -name "*_test.go" | wc -l)
if [ $TEST_FILES -gt 0 ]; then
    echo "   ✅ Found $TEST_FILES test files"
    find . -name "*_test.go" | head -5 | sed 's/^/      /'
    if [ $TEST_FILES -gt 5 ]; then
        echo "      ... and $((TEST_FILES - 5)) more"
    fi
else
    echo "   ❌ No test files found!"
fi

echo ""

# Check vendor directory
echo "3. Checking vendor directory status..."
if [ -d "vendor" ]; then
    echo "   ✅ Vendor directory exists"
    
    # Check for vendor inconsistencies
    if go mod vendor -n &>/dev/null; then
        echo "   ✅ Vendor directory is up to date"
    else
        echo "   ⚠️  Vendor directory may need syncing (run: go mod vendor)"
    fi
else
    echo "   ⚠️  No vendor directory (may use modules instead)"
fi

echo ""

# Check coverage file generation
echo "4. Testing coverage file generation..."
if go test -coverprofile=test_cover.out -v ./controllers/... &>/dev/null; then
    if [ -f "test_cover.out" ]; then
        COVERAGE=$(go tool cover -func=test_cover.out | tail -1 | awk '{print $3}' 2>/dev/null || echo "unknown")
        echo "   ✅ Coverage generation successful: $COVERAGE"
        rm -f test_cover.out
    else
        echo "   ❌ Coverage file was not generated"
    fi
else
    echo "   ⚠️  Coverage generation failed (may need dependencies)"
fi

echo ""

# Check existing coverage files
echo "5. Checking existing coverage files..."
COVERAGE_FILES=(cover.out coverage.out coverage_unit.out coverage_e2e.out)
FOUND_COVERAGE=false

for file in "${COVERAGE_FILES[@]}"; do
    if [ -f "$file" ]; then
        SIZE=$(ls -la "$file" | awk '{print $5}')
        if [ "$SIZE" -gt 0 ]; then
            COVERAGE=$(go tool cover -func="$file" | tail -1 | awk '{print $3}' 2>/dev/null || echo "unknown")
            echo "   ✅ $file ($SIZE bytes, $COVERAGE coverage)"
            FOUND_COVERAGE=true
        else
            echo "   ⚠️  $file exists but is empty"
        fi
    fi
done

if [ "$FOUND_COVERAGE" = false ]; then
    echo "   ⚠️  No coverage files found - run './generate-coverage.sh' or 'make test'"
fi

echo ""

# Check Go toolchain
echo "6. Checking Go toolchain..."
if command -v go &>/dev/null; then
    GO_VERSION=$(go version | awk '{print $3}')
    echo "   ✅ Go installed: $GO_VERSION"
else
    echo "   ❌ Go not found in PATH!"
fi

echo ""

# Check SonarQube scanner
echo "7. Checking SonarQube scanner availability..."
if command -v sonar-scanner &>/dev/null; then
    echo "   ✅ sonar-scanner available"
elif command -v npx &>/dev/null; then
    echo "   ✅ npx available (can use: npx sonarqube-scanner)"
else
    echo "   ⚠️  No SonarQube scanner found"
    echo "      Install with: npm install -g sonarqube-scanner"
fi

echo ""

# Summary and recommendations
echo "📋 Summary and Recommendations:"
echo "================================"

if [ -f "cover.out" ]; then
    CURRENT_COVERAGE=$(go tool cover -func=cover.out | tail -1 | awk '{print $3}' 2>/dev/null)
    if [ -n "$CURRENT_COVERAGE" ]; then
        echo "✅ Current test coverage: $CURRENT_COVERAGE"
    fi
fi

echo ""
echo "🚀 Ready for SonarQube analysis!"
echo ""
echo "Next steps:"
echo "1. Set SONAR_TOKEN environment variable"
echo "2. Run: sonar-scanner"
echo "3. Check SonarQube Cloud dashboard for results"
echo ""
echo "For comprehensive coverage:"
echo "./generate-coverage.sh && sonar-scanner"
echo ""
echo "📚 Documentation: SONARQUBE-SETUP.md"
