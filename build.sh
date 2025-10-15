#!/bin/bash
set -e
mkdir -p logs
echo "Compiling..."
javac src/Main.java -d .
echo "Running program..."
java Main 2>&1 | tee logs/build_log.txt
