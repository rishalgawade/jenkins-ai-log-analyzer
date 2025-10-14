#!/bin/bash
set -e
mkdir -p logs
echo "Compiling..."
javac src/Main.java -d .
echo "Running program..."
java Main | tee logs/build_log.txt
