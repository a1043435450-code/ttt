-- شجرة الحسابات
CREATE TABLE IF NOT EXISTS chart_of_accounts (
  id TEXT PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  parent_id TEXT REFERENCES chart_of_accounts(id),
  level INTEGER,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- المستخدمين
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  full_name TEXT,
  email TEXT,
  role TEXT DEFAULT 'user',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- القيود المحاسبية
CREATE TABLE IF NOT EXISTS journal_entries (
  id TEXT PRIMARY KEY,
  entry_date DATE NOT NULL,
  description TEXT,
  reference_type TEXT,
  reference_id TEXT,
  user_id TEXT REFERENCES users(id),
  is_balanced BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- بنود القيود
CREATE TABLE IF NOT EXISTS journal_entry_lines (
  id TEXT PRIMARY KEY,
  entry_id TEXT NOT NULL REFERENCES journal_entries(id),
  account_id TEXT NOT NULL REFERENCES chart_of_accounts(id),
  debit DECIMAL(12,2),
  credit DECIMAL(12,2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- العملاء
CREATE TABLE IF NOT EXISTS customers (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  address TEXT,
  tax_number TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- الموردين
CREATE TABLE IF NOT EXISTS suppliers (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  address TEXT,
  tax_number TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- الأصناف
CREATE TABLE IF NOT EXISTS items (
  id TEXT PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  unit TEXT,
  purchase_price DECIMAL(10,2),
  selling_price DECIMAL(10,2),
  reorder_level INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- المخزون
CREATE TABLE IF NOT EXISTS inventory (
  id TEXT PRIMARY KEY,
  item_id TEXT NOT NULL REFERENCES items(id),
  warehouse_id TEXT,
  quantity INTEGER,
  last_counted TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- الفواتير
CREATE TABLE IF NOT EXISTS invoices (
  id TEXT PRIMARY KEY,
  invoice_number TEXT UNIQUE NOT NULL,
  invoice_type TEXT,
  customer_id TEXT REFERENCES customers(id),
  supplier_id TEXT REFERENCES suppliers(id),
  invoice_date DATE NOT NULL,
  due_date DATE,
  subtotal DECIMAL(12,2),
  tax_amount DECIMAL(12,2),
  total DECIMAL(12,2),
  status TEXT DEFAULT 'draft',
  zatca_status TEXT,
  zatca_uuid TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- بنود الفاتورة
CREATE TABLE IF NOT EXISTS invoice_lines (
  id TEXT PRIMARY KEY,
  invoice_id TEXT NOT NULL REFERENCES invoices(id),
  item_id TEXT REFERENCES items(id),
  quantity INTEGER NOT NULL,
  unit_price DECIMAL(10,2),
  line_total DECIMAL(12,2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جلسات الكاشير
CREATE TABLE IF NOT EXISTS cashier_sessions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id),
  session_date DATE NOT NULL,
  opening_balance DECIMAL(12,2),
  closing_balance DECIMAL(12,2),
  status TEXT DEFAULT 'open',
  opened_at TIMESTAMP,
  closed_at TIMESTAMP
);

-- حركات POS
CREATE TABLE IF NOT EXISTS pos_transactions (
  id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL REFERENCES cashier_sessions(id),
  transaction_date TIMESTAMP,
  customer_id TEXT REFERENCES customers(id),
  total DECIMAL(12,2),
  payment_method TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إعدادات المنشأة
CREATE TABLE IF NOT EXISTS company_settings (
  id TEXT PRIMARY KEY,
  company_name TEXT,
  logo_path TEXT,
  address TEXT,
  commercial_registration TEXT,
  tax_number TEXT,
  phone TEXT,
  email TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- نظام الترخيص
CREATE TABLE IF NOT EXISTS licenses (
  id TEXT PRIMARY KEY,
  license_key TEXT UNIQUE NOT NULL,
  license_type TEXT,
  activation_date DATE,
  expiration_date DATE,
  max_users INTEGER,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- سجل النشاط
CREATE TABLE IF NOT EXISTS activity_log (
  id TEXT PRIMARY KEY,
  user_id TEXT REFERENCES users(id),
  action TEXT,
  entity_type TEXT,
  entity_id TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
