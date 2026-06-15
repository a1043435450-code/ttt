@echo off
chcp 65001 >nul
color 0A

echo.
echo ============================================================
echo   صقر الرحبة - نظام المحاسبة والمبيعات والمخزون
echo   Saqr Al-Rahba Accounting System v0.1.0
echo ============================================================
echo.

REM Check Node.js
echo [1/5] Checking Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo X Node.js not found. Please install Node.js 18+
    exit /b 1
)
for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
echo OK Node.js %NODE_VERSION%

REM Install root dependencies
echo.
echo [2/5] Installing dependencies...
call npm install

REM Install backend
echo.
echo [3/5] Setting up backend...
cd backend
call npm install
if not exist .env (
    copy .env.example .env >nul 2>&1
)
cd ..

REM Install frontend
echo.
echo [4/5] Setting up frontend...
cd frontend
call npm install
cd ..

REM Build frontend
echo.
echo [5/5] Building frontend...
cd frontend
call npm run build
cd ..

echo.
echo ============================================================
echo OK Installation completed!
echo ============================================================
echo.
echo To start the system:
echo   npm run dev
echo.
echo Backend: http://localhost:3001
echo Frontend: http://localhost:3000
echo.
pause
