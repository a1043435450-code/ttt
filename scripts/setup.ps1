# Saqr Al-Rahba Accounting System - Setup Script
# PowerShell setup for Windows

$ErrorActionPreference = "Stop"
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$ProjectPath = Join-Path $DesktopPath "saqr-accounting"

Write-Host "صقر الرحبة - نظام المحاسبة" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "جاري إعداد المشروع..." -ForegroundColor Yellow

# التحقق من Node.js
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Node.js غير مثبت. يرجى تثبيت Node.js 18+" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Node.js مثبت" -ForegroundColor Green

# إنشاء مجلد المشروع
if (Test-Path $ProjectPath) {
    Remove-Item -Path $ProjectPath -Recurse -Force
}

New-Item -ItemType Directory -Path $ProjectPath | Out-Null
Set-Location $ProjectPath

Write-Host "✓ تم إنشاء مجلد المشروع" -ForegroundColor Green

# استنساخ المستودع
Write-Host "جاري استنساخ المستودع..." -ForegroundColor Yellow
git clone https://github.com/a1043435450-code/ttt.git .

# تثبيت الحزم
Write-Host "جاري تثبيت الحزم..." -ForegroundColor Yellow
npm install

# إنشاء ملفات .env
Write-Host "جاري إنشاء ملفات الإعدادات..." -ForegroundColor Yellow

@"
PORT=3001
NODE_ENV=development
DATABASE_URL=sqlite:./database.sqlite3
JWT_SECRET=saqr-secret-key-change-in-production
DATABASE_TYPE=sqlite
"@ | Out-File -FilePath "backend/.env" -Encoding UTF8

Write-Host "✓ تم إنشاء الإعدادات" -ForegroundColor Green

# بناء المشروع
Write-Host "جاري بناء المشروع..." -ForegroundColor Yellow
npm run build

Write-Host "" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "✓ تم الإعداد بنجاح!" -ForegroundColor Green
Write-Host "مسار المشروع: $ProjectPath" -ForegroundColor Green
Write-Host "" -ForegroundColor Green
Write-Host "للبدء:" -ForegroundColor Yellow
Write-Host "  npm run dev" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Green
