#!/bin/bash
set -e

echo "=========================================="
echo "🚀 Jenkins AI Log Analyzer - Build"
echo "=========================================="
echo ""

echo "📋 Step 1: Environment check..."
python3 --version
echo ""

echo "🧪 Step 2: Running tests..."
echo "  Test 1: PASSED ✅"
sleep 1
echo "  Test 2: PASSED ✅"
sleep 1
echo "  Test 3: FAILED ❌"
echo ""
echo "ERROR: Test suite failed"
echo "  File: tests/test_integration.py"
echo "  Line: 45"
echo "  Error: AssertionError: Expected 200, got 404"
echo ""

# Uncomment to simulate failure
exit 1

echo "✅ Build completed successfully!"
