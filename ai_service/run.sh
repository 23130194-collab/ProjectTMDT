#!/bin/bash
# Script khởi động AI Service cho chức năng Visual Search
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

echo "=================================================="
echo "  Khoi dong MuaNgay AI Visual Search Service"
echo "  Model: clip-ViT-B-32 (OpenAI)"
echo "  Port: 8000"
echo "=================================================="

./venv/bin/python app.py
