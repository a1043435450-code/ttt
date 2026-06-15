#!/bin/bash
# Linux/Mac setup script

DESKTOP=$(cd ~; pwd)/Desktop
PROJECT_PATH="$DESKTOP/Saqr-Accounting"
REPO_URL="https://github.com/a1043435450-code/ttt.git"

echo "
╔════════════════════════════════════════════════════════════╗
║   صقر الرحبة - نظام المحاسبة والمبيعات والمخزون            ║
║   Saqr Al-Rahba Accounting System                          ║
╚════════════════════════════════════════════════════════════╝
"

echo "[1/10] التحقق من Node.js..."
if ! command -v node &> /dev/null; then
    echo "✗ Node.js غير مثبت"
    exit 1
fi
echo "✓ Node.js $(node --version)"

echo "[2/10] التحقق من Git..."
if ! command -v git &> /dev/null; then
    echo "✗ Git غير مثبت"
    exit 1
fi
echo "✓ Git installed"

echo "[3/10] إنشاء مجلد المشروع..."
rm -rf "$PROJECT_PATH"
mkdir -p "$PROJECT_PATH"
cd "$PROJECT_PATH"
echo "✓ مجلد المشروع: $PROJECT_PATH"

echo "[4/10] استنساخ المستودع..."
git clone $REPO_URL .
echo "✓ تم استنساخ المستودع"

echo "[5/10] تثبيت الحزم الأساسية..."
npm install
echo "✓ تم تثبيت الحزم"

echo "[6/10] إنشاء ملفات الإعدادات..."
cat > backend/.env << EOF
PORT=3001
NODE_ENV=development
DATABASE_URL=sqlite:./database.sqlite3
DATABASE_TYPE=sqlite
JWT_SECRET=saqr-accounting-secret-key-2024
EOF
echo "✓ Backend .env created"

echo "[7/10] بناء الواجهة الأمامية..."
cd frontend && npm install && npm run build && cd ..
echo "✓ تم بناء الواجهة"

echo "[8/10] تثبيت تطبيق سطح المكتب..."
cd desktop && npm install && cd ..
echo "✓ تم تثبيت تطبيق سطح المكتب"

echo "[9/10] إنشاء قاعدة البيانات..."
echo "✓ سيتم إنشاء قاعدة البيانات عند البدء الأول"

echo "[10/10] الإنشاء كامل..."
echo "
╔════════════════════════════════════════════════════════════╗
║   ✓ تم الإعداد بنجاح!                                      ║
║   ✓ Setup completed successfully!                         ║
╚════════════════════════════════════════════════════════════╝

مسار المشروع: $PROJECT_PATH

للبدء:
cd $PROJECT_PATH
npm run dev

Backend: http://localhost:3001
Frontend: http://localhost:3000
"
