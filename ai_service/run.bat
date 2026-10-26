@echo off
echo ==================================================
echo   Khoi dong MuaNgay AI Visual Search Service
echo   Model: clip-ViT-B-32 (OpenAI)
echo   Port: 8000
echo ==================================================
cd /d "%~dp0"
venv\Scripts\python app.py
pause
