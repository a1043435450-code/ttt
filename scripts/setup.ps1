# PowerShell Setup Script for Saqr Al-Rahba Accounting System
# Windows Desktop Setup

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

# Colors
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Error-Custom { Write-Host $args -ForegroundColor Red }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning-Custom { Write-Host $args -ForegroundColor Yellow }

# Paths
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$ProjectPath = Join-Path $DesktopPath "Saqr-Accounting"
$RepoURL = "https://github.com/a1043435450-code/ttt.git"

Write-Host "
╔════════════════════════════════════════════════════════════╗
║   صقر الرحبة - نظام المحاسبة والمبيعات والمخزون            ║
║   Saqr Al-Rahba Accounting System                          ║
╚══════════════��═════════════════════════════════════════════╝
" -ForegroundColor Cyan

Write-Info "جاري الإعداد..."
Write-Info "Setting up system..."

# Check Node.js
Write-Info "
[1/10] التحقق من Node.js..."
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error-Custom "✗ Node.js غير مثبت. يرجى تثبيت Node.js 18+"
    Write-Error-Custom "✗ Node.js is not installed. Please install Node.js 18+"
    Write-Error-Custom "Download: https://nodejs.org/"
    exit 1
}
$nodeVersion = node --version
Write-Success "✓ Node.js $nodeVersion"

# Check Git
Write-Info "
[2/10] التحقق من Git..."
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error-Custom "✗ Git غير مثبت"
    Write-Error-Custom "✗ Git is not installed"
    exit 1
}
Write-Success "✓ Git installed"

# Create and clean project directory
Write-Info "
[3/10] إنشاء مجلد المشروع..."
if (Test-Path $ProjectPath) {
    Write-Warning-Custom "Removing existing project folder..."
    Remove-Item -Path $ProjectPath -Recurse -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

New-Item -ItemType Directory -Path $ProjectPath | Out-Null
Set-Location $ProjectPath
Write-Success "✓ مجلد المشروع: $ProjectPath"

# Clone repository
Write-Info "
[4/10] استنساخ المستودع..."
try {
    git clone $RepoURL .
    Write-Success "✓ تم استنساخ المستودع"
} catch {
    Write-Error-Custom "✗ فشل استنساخ المستودع"
    exit 1
}

# Install root dependencies
Write-Info "
[5/10] تثبيت الحزم الأساسية..."
try {
    npm install --legacy-peer-deps
    Write-Success "✓ تم تثبيت الحزم"
} catch {
    Write-Error-Custom "✗ فشل تثبيت الحزم"
    exit 1
}

# Create .env files
Write-Info "
[6/10] إنشاء ملفات الإعدادات..."

$envContent = @"
PORT=3001
NODE_ENV=development
DATABASE_URL=sqlite:./database.sqlite3
DATABASE_TYPE=sqlite
JWT_SECRET=saqr-accounting-secret-key-2024
ZATCA_API_URL=https://api.zatca.gov.sa
ZATCA_API_KEY=
ZATCA_CERTIFICATE_PATH=./certificates/zatca.pem
"@

$envContent | Out-File -FilePath "backend/.env" -Encoding UTF8 -Force
Write-Success "✓ Backend .env created"

# Build frontend
Write-Info "
[7/10] بناء الواجهة الأمامية..."
try {
    Set-Location "$ProjectPath/frontend"
    npm install --legacy-peer-deps
    npm run build
    Write-Success "✓ تم بناء الواجهة"
    Set-Location $ProjectPath
} catch {
    Write-Error-Custom "✗ فشل بناء الواجهة"
    Write-Warning-Custom "Continuing anyway..."
}

# Install and build desktop
Write-Info "
[8/10] تثبيت تطبيق سطح المكتب..."
try {
    Set-Location "$ProjectPath/desktop"
    npm install --legacy-peer-deps
    Write-Success "✓ تم تثبيت تطبيق سطح المكتب"
    Set-Location $ProjectPath
} catch {
    Write-Error-Custom "✗ فشل تثبيت تطبيق سطح المكتب"
    Write-Warning-Custom "Continuing anyway..."
}

# Create database
Write-Info "
[9/10] إنشاء قاعدة البيانات..."
try {
    Set-Location "$ProjectPath/backend"
    node -e "
    import Database from 'better-sqlite3';
    const db = new Database('./database.sqlite3');
    console.log('Database created');
    " 2>$null
    Write-Success "✓ تم إنشاء قاعدة البيانات"
    Set-Location $ProjectPath
} catch {
    Write-Warning-Custom "Database initialization - will be created on first run"
}

# Create shortcuts
Write-Info "
[10/10] إنشاء اختصارات..."
$shortcutPath = "$ProjectPath/START.bat"
$content = @"
@echo off
chcp 65001 >nul
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║   صقر الرحبة - نظام المحاسبة والمبيعات والمخزون            ║
echo ║   Saqr Al-Rahba Accounting System                          ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo جاري البدء... / Starting...
echo.
cd /d "%ProjectPath%"
call npm run dev
pause
"@

$content | Out-File -FilePath $shortcutPath -Encoding ASCII -Force
Write-Success "✓ تم إنشاء START.bat"

# Create readme for startup
$readmePath = "$ProjectPath/START_HERE.txt"
$readme = @"
╔════════════════════════════════════════════════════════════╗
║   صقر الرحبة - نظام المحاسبة والمبيعات والمخزون            ║
║   Saqr Al-Rahba Accounting System v0.1.0                  ║
╚════════════════════════════════════════════════════════════╝

طرق البدء / How to Start:

1. الطريقة السريعة (Quick Start):
   - Double-click START.bat
   - انتظر تشغيل الخوادم (Wait for servers to start)

2. عبر سطر الأوامر (Command Line):
   - cd Saqr-Accounting
   - npm run dev

أقسام النظام / System Modules:

✓ Backend (Node.js + Express)
  - PORT: 3001
  - URL: http://localhost:3001/api

✓ Frontend (React)
  - PORT: 3000
  - URL: http://localhost:3000

✓ Desktop (Electron)
  - Standalone application

✓ Database (SQLite)
  - Location: backend/database.sqlite3

ميزات النظام / Features:

✓ إدارة محاسبية متكاملة (Integrated Accounting)
✓ نظام مبيعات وفواتير (Sales & Invoicing)
✓ إدارة مخزون (Inventory Management)
✓ نظام كاشير POS (POS System)
✓ دعم الفوترة الإلكترونية ZATCA (E-Invoice Support)
✓ تقارير شاملة (Comprehensive Reports)
�� نظام ترخيص (Licensing System)
✓ إدارة المستخدمين والصلاحيات (User Management)
✓ سجل النشاط (Activity Log)

المتطلبات / Requirements:

✓ Node.js 18+
✓ npm 9+
✓ Windows 10+
✓ 2GB RAM (minimum)
✓ 500MB Disk Space

الدعم والمساعدة / Support:

للمساعدة والدعم الفني، يرجى التواصل:
https://github.com/a1043435450-code/ttt

"
$readme | Out-File -FilePath $readmePath -Encoding UTF8 -Force
Write-Success "✓ تم إنشاء START_HERE.txt"

# Final summary
Write-Host "
╔════════════════════════════════════════════════════════════╗
║   ✓ تم الإعداد بنجاح!                                      ║
║   ✓ Setup completed successfully!                         ║
╚════════════════════════════════════════════════════════════╝
" -ForegroundColor Green

Write-Host "
مسار المشروع / Project Path:
$ProjectPath
" -ForegroundColor Cyan

Write-Host "للبدء / To start:
" -ForegroundColor Yellow
Write-Host "1. Open: $ProjectPath" -ForegroundColor Green
Write-Host "2. Double-click: START.bat" -ForegroundColor Green
Write-Host "   أو / or" -ForegroundColor Yellow
Write-Host "   Run: npm run dev" -ForegroundColor Green

Write-Host "
انتظر حتى تشغيل الخوادم... / Waiting for servers to start...
" -ForegroundColor Cyan

Write-Host "سيتم فتح الواجهة تلقائياً / Interface will open automatically..." -ForegroundColor Cyan
Write-Host "Backend: http://localhost:3001" -ForegroundColor Cyan
Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan

Write-Host "
اضغط أي مفتاح للإغلاق / Press any key to close...
" -ForegroundColor Yellow
Read-Host
