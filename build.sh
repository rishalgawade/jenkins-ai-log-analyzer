#!/bin/bash
set -e
echo "=========================================="
echo "🚀 Java Build & Test Pipeline"
echo "=========================================="
echo ""
echo "📋 Step 1: Environment Check"
java -version 2>&1 | head -n 1
javac -version 2>&1
echo ""
echo "🔨 Step 2: Compiling Java Source"
mkdir -p build
javac -d build src/Main.java
echo "  ✅ Compilation successful"
echo ""
echo "▶️  Step 3: Running Application"
echo "  Executing: java -cp build Main"
echo ""
java -cp build Main
echo ""
echo "✅ Application completed successfully"
