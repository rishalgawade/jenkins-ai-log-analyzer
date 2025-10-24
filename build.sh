#!/bin/bash
set -e

echo "=========================================="
echo "🚀 Jenkins AI Log Analyzer - Build"
echo "=========================================="
echo ""

echo "📋 Step 1: Environment check..."
echo "  Python: $(python3 --version 2>&1 || echo 'Not found')"
echo "  pip: $(pip3 --version 2>&1 || echo 'Not found')"
echo "  Git: $(git --version 2>&1 || echo 'Not found')"
echo ""

echo "📦 Step 2: Installing dependencies..."
if [ -f requirements.txt ]; then
    echo "  Found requirements.txt"
    pip3 install -r requirements.txt --quiet
    echo "  ✅ Dependencies installed"
else
    echo "  ⚠️  No requirements.txt found"
fi
echo ""

echo "🧪 Step 3: Running tests..."
echo "  Test 1: Configuration validation... PASSED ✅"
sleep 1
echo "  Test 2: API connectivity check... PASSED ✅"
sleep 1
echo "  Test 3: Integration test... FAILED ❌"
echo ""
echo "ERROR: Test suite failed at test_api_endpoint"
echo "  File: tests/test_integration.py"
echo "  Line: 45"
echo "  Error: AssertionError: Expected status code 200, got 404"
echo "  URL: http://api.example.com/v1/users"
echo ""
echo "Stack trace:"
echo "  Traceback (most recent call last):"
echo "    File 'tests/test_integration.py', line 45, in test_api_endpoint"
echo "      assert response.status_code == 200"
echo "  AssertionError: Expected 200, got 404"
echo ""

# Comment out this line to test successful builds
exit 1

echo "✅ Step 4: Build artifacts created"
echo ""
echo "=========================================="
echo "🎉 Build completed successfully!"
echo "=========================================="