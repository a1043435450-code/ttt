# صقر الرحبة - نظام المحاسبة والمبيعات والمخزون
# Saqr Al-Rahba Accounting System

## البدء السريع / Quick Start

### Windows
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
powershell -ExecutionPolicy Bypass -File scripts/setup.ps1
```

### Linux/Mac
```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### بعد الإعداد / After Setup
```bash
cd ~/Desktop/Saqr-Accounting
npm run dev
```

## المتطلبات / Requirements

- Node.js 18+
- npm 9+
- Windows 10+, Linux, or macOS
- 2GB RAM (minimum)
- 500MB Disk Space

## الميزات / Features

✓ إدارة محاسبية متكاملة (Integrated Accounting)
✓ نظام مبيعات وفواتير (Sales & Invoicing)
✓ إدارة مخزون (Inventory Management)
✓ نظام كاشير POS (POS System)
✓ دعم الفوترة الإلكترونية ZATCA (E-Invoice Support)
✓ تقارير شاملة (Comprehensive Reports)
✓ نظام ترخيص (Licensing System)
✓ إدارة المستخدمين والصلاحيات (User Management)
✓ سجل النشاط (Activity Log)
✓ عمل بدون إنترنت (Offline Mode)

## المعمارية / Architecture

```
Desktop (Electron)
├── Frontend (React + RTL)
│   └── Vite Server (Port 3000)
├── Backend (Express.js)
│   └── API Server (Port 3001)
└── Database (SQLite)
    └── database.sqlite3
```

## المسارات / Paths

- **Backend API**: http://localhost:3001/api
- **Frontend**: http://localhost:3000
- **Health Check**: http://localhost:3001/api/health

## المستخدمون الافتراضيون / Default Users

| Username | Password | Role |
|----------|----------|------|
| admin | admin123 | Administrator |
| cashier | cashier123 | Cashier |
| accountant | accountant123 | Accountant |

## الهيكل / Project Structure

```
saqr-accounting/
├── backend/                 # Node.js + Express API
│   ├── src/
│   │   ├── index.js        # Server entry point
│   │   ├── db.js           # Database initialization
│   │   ├── models.js       # Database models
│   │   ├── routes/
│   │   │   └── api.js      # API routes
│   │   └── services/
│   │       ├── auth.js     # Authentication
│   │       └── zatca.js    # ZATCA integration
│   ├── package.json
│   └── database.sqlite3
├── frontend/                # React + Vite
│   ├── src/
│   │   ├── main.jsx
│   │   ├── App.jsx
│   │   └── index.css
│   ├── index.html
│   ├── package.json
│   └── vite.config.js
├── desktop/                 # Electron App
│   ├── main.js
│   ├── preload.js
│   ├── package.json
│   └─�� electron-builder.json
├── database/
│   ├── schema.sql          # Database schema
│   └── seedData.js         # Initial data
├── scripts/
│   ├── setup.ps1           # Windows setup
│   └── setup.sh            # Linux/Mac setup
└── docs/
    ├── ARCHITECTURE.md
    └── API.md
```

## قاعدة البيانات / Database

### الجداول / Tables
- chart_of_accounts (شجرة الحسابات)
- journal_entries (القيود المحاسبية)
- journal_entry_lines (بنود القيود)
- customers (العملاء)
- suppliers (الموردين)
- items (الأصناف)
- invoices (الفواتير)
- cashier_sessions (جلسات الكاشير)
- pos_transactions (حركات POS)
- users (المستخدمين)
- licenses (نظام الترخيص)
- activity_log (سجل النشاط)
- company_settings (إعدادات المنشأة)

## الترخيص / Licensing

### أنواع الرخص / License Types
- **Demo**: رخصة تجريبية لمدة 30 يوم
- **Basic**: الخطة الأساسية
- **Professional**: الخطة المهنية
- **Enterprise**: الخطة المؤسسية

## الدعم والمساعدة / Support

https://github.com/a1043435450-code/ttt

## الترخيص / License

جميع الحقوق محفوظة © 2024
All Rights Reserved © 2024
