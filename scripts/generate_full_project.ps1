<#
PowerShell generator script: create the entire Saqr Al-Rahba project on Desktop
Usage: Run PowerShell as Administrator. This script will create files and folders and run npm installs.
#>

Set-StrictMode -Version Latest
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = 'Stop'

$desktop = [Environment]::GetFolderPath('Desktop')
$root = Join-Path $desktop 'Saqr-Al-Rahba'

function Write-Dir([string]$path){
    if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path | Out-Null }
}

function Write-File([string]$path, [string]$content){
    $dir = Split-Path $path -Parent
    Write-Dir $dir
    $content | Out-File -FilePath $path -Encoding UTF8 -Force
}

Write-Host "Creating project at: $root"

# Directories
$dirs = @(
    $root,
    Join-Path $root 'backend',
    Join-Path $root 'backend\src',
    Join-Path $root 'backend\src\services',
    Join-Path $root 'backend\migrations',
    Join-Path $root 'backend\tests',
    Join-Path $root 'frontend',
    Join-Path $root 'frontend\src',
    Join-Path $root 'electron',
    Join-Path $root 'database',
    Join-Path $root 'scripts',
    Join-Path $root 'assets'
)

foreach ($d in $dirs) { Write-Dir $d }

# 1) Database schema (SQLite) - minimal but comprehensive structure
$schema = @'
PRAGMA foreign_keys = ON;

-- Users & roles
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  full_name TEXT,
  email TEXT,
  role TEXT DEFAULT 'user',
  is_active INTEGER DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS licenses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  license_key TEXT UNIQUE,
  package_type TEXT,
  start_date TEXT,
  end_date TEXT,
  max_users INTEGER,
  is_active INTEGER DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Chart of accounts (recursive parent)
CREATE TABLE IF NOT EXISTS accounts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  type TEXT,
  level INTEGER DEFAULT 1,
  parent_id INTEGER,
  is_active INTEGER DEFAULT 1,
  FOREIGN KEY(parent_id) REFERENCES accounts(id)
);

-- Journal entries (double-entry)
CREATE TABLE IF NOT EXISTS journal_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  entry_number TEXT UNIQUE,
  entry_date TEXT,
  description TEXT,
  posted INTEGER DEFAULT 0,
  created_by INTEGER,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS journal_lines (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  entry_id INTEGER NOT NULL,
  account_id INTEGER NOT NULL,
  debit REAL DEFAULT 0,
  credit REAL DEFAULT 0,
  description TEXT,
  FOREIGN KEY(entry_id) REFERENCES journal_entries(id),
  FOREIGN KEY(account_id) REFERENCES accounts(id)
);

-- Customers and suppliers
CREATE TABLE IF NOT EXISTS customers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT UNIQUE,
  name TEXT,
  phone TEXT,
  email TEXT,
  address TEXT,
  tax_number TEXT,
  balance REAL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS suppliers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT UNIQUE,
  name TEXT,
  phone TEXT,
  email TEXT,
  address TEXT,
  tax_number TEXT,
  balance REAL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Products, warehouses and inventory
CREATE TABLE IF NOT EXISTS categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT UNIQUE,
  barcode TEXT,
  name TEXT,
  category_id INTEGER,
  unit TEXT,
  purchase_price REAL,
  selling_price REAL,
  vat_percent REAL DEFAULT 15,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(category_id) REFERENCES categories(id)
);

CREATE TABLE IF NOT EXISTS warehouses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  location TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS inventory (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id INTEGER,
  warehouse_id INTEGER,
  quantity INTEGER DEFAULT 0,
  FOREIGN KEY(product_id) REFERENCES products(id),
  FOREIGN KEY(warehouse_id) REFERENCES warehouses(id)
);

CREATE TABLE IF NOT EXISTS inventory_movements (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id INTEGER,
  warehouse_id INTEGER,
  movement_type TEXT,
  quantity INTEGER,
  reference TEXT,
  created_by INTEGER,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Invoices and invoice lines
CREATE TABLE IF NOT EXISTS invoices (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  invoice_number TEXT UNIQUE,
  invoice_type TEXT,
  invoice_date TEXT,
  customer_id INTEGER,
  supplier_id INTEGER,
  subtotal REAL,
  vat_amount REAL,
  total_amount REAL,
  status TEXT DEFAULT 'draft',
  zatca_status TEXT,
  created_by INTEGER,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS invoice_lines (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  invoice_id INTEGER,
  product_id INTEGER,
  description TEXT,
  quantity INTEGER,
  unit_price REAL,
  discount REAL DEFAULT 0,
  vat_percent REAL DEFAULT 15,
  line_total REAL,
  FOREIGN KEY(invoice_id) REFERENCES invoices(id),
  FOREIGN KEY(product_id) REFERENCES products(id)
);

-- POS transactions
CREATE TABLE IF NOT EXISTS cash_registers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  opening_balance REAL DEFAULT 0,
  current_balance REAL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS cashier_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  cash_register_id INTEGER,
  user_id INTEGER,
  opened_at DATETIME,
  closed_at DATETIME,
  opening_balance REAL,
  closing_balance REAL,
  status TEXT,
  FOREIGN KEY(cash_register_id) REFERENCES cash_registers(id)
);

CREATE TABLE IF NOT EXISTS pos_transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  transaction_number TEXT UNIQUE,
  cashier_session_id INTEGER,
  customer_id INTEGER,
  transaction_date DATETIME,
  subtotal REAL,
  vat_amount REAL,
  total_amount REAL,
  payment_method TEXT,
  created_by INTEGER,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pos_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  pos_transaction_id INTEGER,
  product_id INTEGER,
  quantity INTEGER,
  unit_price REAL,
  total_price REAL,
  FOREIGN KEY(pos_transaction_id) REFERENCES pos_transactions(id)
);

-- ZATCA meta
CREATE TABLE IF NOT EXISTS zatca_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  invoice_id INTEGER,
  uuid TEXT,
  xml TEXT,
  qr TEXT,
  status TEXT,
  response TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(invoice_id) REFERENCES invoices(id)
);

-- Activity log
CREATE TABLE IF NOT EXISTS activity_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  action TEXT,
  entity_type TEXT,
  entity_id INTEGER,
  details TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
'@

Write-File (Join-Path $root 'database\schema.sql') $schema

# 2) Seed data (admin user and basic accounts)
$seed = @'
-- seed: admin user and defaults
INSERT INTO users (username, password_hash, full_name, email, role) VALUES ('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcg7b3XeKeQmGDeWvDrxj4b.B4m', 'مسؤول النظام', 'admin@saqr.local', 'admin');

INSERT INTO accounts (code, name, type, level) VALUES
('1000','الأصول','asset',1),
('1100','الأصول المتداولة','asset',2),
('2000','الالتزامات','liability',1),
('3000','حقوق المالكين','equity',1),
('4000','الإيرادات','income',1),
('5000','المصروفات','expense',1);

INSERT INTO warehouses (name, location) VALUES ('المستودع الرئيسي', 'الفرع الرئيسي');
INSERT INTO cash_registers (name, opening_balance, current_balance) VALUES ('الصندوق الرئيسي',0,0);
'@

Write-File (Join-Path $root 'database\seed-data.sql') $seed

# 3) Backend files
$backendPkg = @'
{
  "name": "saqr-backend",
  "version": "0.1.0",
  "type": "module",
  "main": "src/index.js",
  "scripts": {
    "dev": "node --watch src/index.js",
    "start": "node src/index.js",
    "migrate": "node src/migrate.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "better-sqlite3": "^9.2.2",
    "bcryptjs": "^2.4.3",
    "jsonwebtoken": "^9.1.2",
    "uuid": "^9.0.1",
    "xmlbuilder2": "^3.0.2",
    "qrcode": "^1.5.3",
    "multer": "^1.4.5-lts.1",
    "body-parser": "^1.20.2",
    "cors": "^2.8.5",
    "dayjs": "^1.11.9"
  }
}
'@

Write-File (Join-Path $root 'backend\package.json') $backendPkg

$envExample = @'
PORT=3001
NODE_ENV=development
DB_PATH=../database.sqlite3
JWT_SECRET=saqr-secret-please-change
ZATCA_API_URL=https://zatca.example
ZATCA_CERT_PATH=
ZATCA_CERT_PASSWORD=
'@
Write-File (Join-Path $root 'backend\.env.example') $envExample

$backendIndex = @'
import express from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import dotenv from 'dotenv';
import dbInit from './db.js';
import authRoutes from './routes/auth.js';
import invoiceRoutes from './routes/invoices.js';

dotenv.config();
const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ extended: true }));

// initialize DB
await dbInit();

app.use('/api/auth', authRoutes);
app.use('/api/invoices', invoiceRoutes);

app.get('/api/health', (req, res) => res.json({ status: 'ok', name: 'Saqr Backend' }));

app.listen(PORT, () => console.log(`Backend listening on http://localhost:${PORT}`));
'@
Write-File (Join-Path $root 'backend\src\index.js') $backendIndex

$backendDb = @'
import fs from 'fs';
import Database from 'better-sqlite3';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

export default async function init() {
  const dbPath = process.env.DB_PATH ? (process.env.DB_PATH.startsWith('../') ? join(__dirname, '..', process.env.DB_PATH) : process.env.DB_PATH) : join(__dirname, '../../database.sqlite3');
  const exists = fs.existsSync(dbPath);
  const db = new Database(dbPath);
  db.pragma('foreign_keys = ON');

  if (!exists) {
    const schema = fs.readFileSync(join(__dirname, '../../database/schema.sql'), 'utf-8');
    db.exec(schema);
    const seed = fs.readFileSync(join(__dirname, '../../database/seed-data.sql'), 'utf-8');
    db.exec(seed);
    console.log('Database created and seeded at', dbPath);
  } else {
    console.log('Database exists at', dbPath);
  }

  // expose DB globally for simple modules
  global.saqrDb = db;
  return db;
}
'@
Write-File (Join-Path $root 'backend\src\db.js') $backendDb

$authRoute = @'
import express from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || 'saqr-secret-please-change';

router.post('/login', (req, res) => {
  const { username, password } = req.body;
  const db = global.saqrDb;
  const stmt = db.prepare('SELECT * FROM users WHERE username = ?');
  const user = stmt.get(username);
  if (!user) return res.status(401).json({ error: 'Invalid credentials' });
  const ok = bcrypt.compareSync(password, user.password_hash);
  if (!ok) return res.status(401).json({ error: 'Invalid credentials' });
  const token = jwt.sign({ id: user.id, username: user.username, role: user.role }, JWT_SECRET, { expiresIn: '24h' });
  res.json({ token, user: { id: user.id, username: user.username, full_name: user.full_name, role: user.role } });
});

export default router;
'@
Write-File (Join-Path $root 'backend\src\routes\auth.js') $authRoute

$invoiceRoute = @'
import express from 'express';
import { v4 as uuidv4 } from 'uuid';

const router = express.Router();

function authMiddleware(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: 'Unauthorized' });
  try {
    const jwt = (await import('jsonwebtoken'));
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'saqr-secret-please-change');
    req.user = decoded;
    return next();
  } catch (e) { return res.status(401).json({ error: 'Unauthorized' }); }
}

router.get('/', authMiddleware, (req, res) => {
  const db = global.saqrDb;
  const rows = db.prepare('SELECT i.*, c.name as customer_name FROM invoices i LEFT JOIN customers c ON i.customer_id = c.id ORDER BY i.created_at DESC LIMIT 200').all();
  res.json({ data: rows });
});

router.post('/', authMiddleware, (req, res) => {
  const db = global.saqrDb;
  const { invoice_type, invoice_date, customer_id, items } = req.body;
  const invoice_number = 'INV-' + Date.now();
  const subtotal = items?.reduce((s, it) => s + (it.unit_price * it.quantity), 0) || 0;
  const vat = +(subtotal * 0.15).toFixed(2);
  const total = +(subtotal + vat).toFixed(2);

  const insert = db.prepare('INSERT INTO invoices (invoice_number, invoice_type, invoice_date, customer_id, subtotal, vat_amount, total_amount, status, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)');
  const info = insert.run(invoice_number, invoice_type || 'sales', invoice_date || new Date().toISOString(), customer_id || null, subtotal, vat, total, 'confirmed', req.user.id);
  const invoiceId = db.prepare('SELECT last_insert_rowid() as id').get().id;

  const insertLine = db.prepare('INSERT INTO invoice_lines (invoice_id, product_id, description, quantity, unit_price, vat_percent, line_total) VALUES (?, ?, ?, ?, ?, ?, ?)');
  if (items && items.length) {
    for (const it of items) {
      insertLine.run(invoiceId, it.product_id || null, it.description || it.name || '', it.quantity || 1, it.unit_price || 0, it.vat_percent || 15, (it.unit_price || 0)*(it.quantity || 1));
    }
  }

  // create journal entry (simple double-entry)
  const je = db.prepare('INSERT INTO journal_entries (entry_number, entry_date, description, posted, created_by) VALUES (?, ?, ?, ?, ?)');
  je.run('JE-' + Date.now(), new Date().toISOString(), 'Auto entry for invoice ' + invoice_number, 1, req.user.id);
  const jeId = db.prepare('SELECT last_insert_rowid() as id').get().id;

  // Debit Accounts Receivable (1120) and Credit Sales Revenue (4100) and VAT payable (2120)
  const accStmt = db.prepare('SELECT id FROM accounts WHERE code = ? LIMIT 1');
  const ar = accStmt.get('1120')?.id || null;
  const sales = accStmt.get('4100')?.id || null;
  const vatAcc = accStmt.get('2120')?.id || null;

  const jl = db.prepare('INSERT INTO journal_lines (entry_id, account_id, debit, credit, description) VALUES (?, ?, ?, ?, ?)');
  if (ar) { jl.run(jeId, ar, total, 0, 'AR for ' + invoice_number); }
  if (sales) { jl.run(jeId, sales, 0, subtotal, 'Sales for ' + invoice_number); }
  if (vatAcc) { jl.run(jeId, vatAcc, 0, vat, 'VAT for ' + invoice_number); }

  res.json({ success: true, invoice_id: invoiceId, invoice_number, total });
});

export default router;
'@
Write-File (Join-Path $root 'backend\src\routes\invoices.js') $invoiceRoute

# 4) ZATCA helper (basic UBL generation and QR)
$zatca = @'
import { create } from 'xmlbuilder2';
import QRCode from 'qrcode';

export function buildUBL(invoice, company) {
  const doc = create({ version: '1.0', encoding: 'utf-8' })
    .ele('Invoice', { 'xmlns': 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2' })
      .ele('cbc:ID').txt(invoice.invoice_number).up()
      .ele('cbc:IssueDate').txt(invoice.invoice_date.split('T')[0]).up()
      .ele('cac:AccountingSupplierParty')
        .ele('cac:Party')
          .ele('cbc:Name').txt(company.name).up()
        .up()
      .up()
      .ele('cac:AccountingCustomerParty')
        .ele('cac:Party')
          .ele('cbc:Name').txt(invoice.customer_name || '').up()
        .up()
      .up();
  // minimal UBL body, extend as needed
  return doc.end({ prettyPrint: true });
}

export async function buildQR(payload) {
  return await QRCode.toDataURL(payload);
}
'@
Write-File (Join-Path $root 'backend\src\services\zatca.js') $zatca

# 5) License module
$license = @'
import Database from 'better-sqlite3';
const db = global.saqrDb || new Database('./database.sqlite3');

export function verifyLicense(key, hwid) {
  const stmt = db.prepare('SELECT * FROM licenses WHERE license_key = ? LIMIT 1');
  const lic = stmt.get(key);
  if (!lic) return { valid: false, reason: 'not_found' };
  const now = new Date();
  if (lic.end_date && new Date(lic.end_date) < now) return { valid: false, reason: 'expired' };
  return { valid: true, license: lic };
}
'@
Write-File (Join-Path $root 'backend\src\services\license.js') $license

# 6) Frontend minimal React app (RTL ready)
$frontendPkg = @'
{
  "name": "saqr-frontend",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "start": "vite preview --port 3000"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "axios": "^1.6.5",
    "bootstrap": "^5.3.2",
    "react-bootstrap": "^2.10.0",
    "i18next": "^23.1.2"
  },
  "devDependencies": {
    "vite": "^5.0.8",
    "@vitejs/plugin-react": "^4.2.1"
  }
}
'@
Write-File (Join-Path $root 'frontend\package.json') $frontendPkg

$frontendIndex = @'
import React from "react";
import { createRoot } from "react-dom/client";

function App(){
  return (
    <div dir="rtl" style={{padding:20,fontFamily:'Segoe UI'}}>
      <h1>صقر الرحبة لأنظمة المحاسبة</h1>
      <p>نسخة سطح مكتب محلية</p>
    </div>
  );
}

createRoot(document.getElementById('root')).render(<App />);
'@
Write-File (Join-Path $root 'frontend\src\main.jsx') $frontendIndex

$frontendHtml = @'
<!doctype html>
<html lang="ar" dir="rtl">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>صقر الرحبة</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
'@
Write-File (Join-Path $root 'frontend\index.html') $frontendHtml

# 7) Electron wrapper
$electronMain = @'
const { app, BrowserWindow } = require('electron');
const path = require('path');
const { spawn } = require('child_process');

let mainWindow;
let backendProcess;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true
    }
  });

  const url = process.env.ELECTRON_START_URL || `file://${path.join(__dirname, '../frontend/dist/index.html')}`;
  mainWindow.loadURL(url);
}

app.whenReady().then(() => {
  // spawn backend
  const backendPath = path.join(__dirname, '../backend');
  backendProcess = spawn('node', ['src/index.js'], { cwd: backendPath, detached: true, stdio: 'ignore' });
  backendProcess.unref();

  createWindow();

  app.on('activate', function () {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
'@
Write-File (Join-Path $root 'electron\main.js') $electronMain

# 8) Root package.json to orchestrate
$rootPkg = @'
{
  "name": "saqr-desktop",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "postinstall": "cd frontend && npm install && npm run build && cd ../backend && npm install",
    "start": "electron .",
    "dev": "concurrently \"cd backend && npm run dev\" \"cd frontend && npm run dev\""
  },
  "devDependencies": {
    "electron": "^26.0.0",
    "concurrently": "^8.2.0",
    "electron-builder": "^24.0.0"
  },
  "build": {
    "appId": "com.saqr.alrahba",
    "win": {
      "target": "nsis",
      "icon": "assets/icon.ico"
    },
    "files": [
      "backend/**",
      "frontend/dist/**",
      "electron/**",
      "database/**"
    ],
    "nsis": {
      "oneClick": false,
      "perMachine": false,
      "allowElevation": true,
      "allowToChangeInstallationDirectory": true
    }
  }
}
'@
Write-File (Join-Path $root 'package.json') $rootPkg

# 9) Installer icon placeholder
$icoContent = @"
"@
Write-File (Join-Path $root 'assets\icon.ico') $icoContent

# 10) Scripts: install.bat (call root install)
$installBat = @'
@echo off
chcp 65001 >nul
cd /d "%~dp0\.."
npm install
cd backend
npm install
cd ..
cd frontend
npm install
npm run build
cd ..
echo Build complete. Run npm start at project root to launch.
pause
'@
Write-File (Join-Path $root 'scripts\install.bat') $installBat

# 11) PowerShell runner and finish
$runner = @'
# Run this to install dependencies and build
Write-Host "Running npm install at root..."
cd "{0}"
npm install
cd frontend
npm install
npm run build
cd ..\backend
npm install
cd ..
Write-Host "All modules installed. To run the desktop app: npm start"
'@ -f $root.Replace('\','\\')
Write-File (Join-Path $root 'scripts\run-and-build.ps1') $runner

Write-Host "Files created. Installing dependencies (this may take some minutes)..."

# Attempt to run npm install at root
Push-Location $root
if (Test-Path 'package.json') {
    try { npm install } catch { Write-Warning "npm install failed at root. Please run scripts\\install.bat or scripts\\run-and-build.ps1 manually." }
}
Pop-Location

Write-Host "Generation complete. Project located at: $root"
Write-Host "Run scripts\\install.bat or open the folder and run npm start to launch the desktop application."
