@echo off
chcp 65001 >nul
echo ==================================================
echo   Khoi dong MuaNgay AI Visual Search Service
echo   Model: clip-ViT-B-32 (OpenAI)
echo   Port: 8000
echo ==================================================
cd /d "%~dp0"

if not exist "venv\Scripts\python.exe" (
    echo [Thong bao] Chua tim thay virtualenv. Dang tu dong tao venv...
    python -m venv venv
    if errorlevel 1 (
        echo [Loi] Khong the tao virtualenv. Vui long kiem tra Python tren may.
        pause
        exit /b 1
    )
)

if not exist "venv\Lib\site-packages\sentence_transformers" (
    echo [Thong bao] Dang cai dat cac thu vien AI can thiet tu requirements.txt...
    venv\Scripts\python.exe -m pip install --upgrade pip
    venv\Scripts\pip.exe install -r requirements.txt
    if errorlevel 1 (
        echo [Loi] Khong the cai dat cac thu vien.
        pause
        exit /b 1
    )
)

echo [Thong bao] Dang khoi dong AI Service tren cong 8000...
venv\Scripts\python.exe app.py
pause

