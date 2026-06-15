-- ============================================
-- SAQR AL-RAHBA ACCOUNTING SYSTEM
-- COMPLETE DATABASE SCHEMA
-- ============================================

-- ============================================
-- USERS AND AUTHENTICATION
-- ============================================

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    email VARCHAR(100),
    role VARCHAR(20) DEFAULT 'user',
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    permissions TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_roles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    role_id INTEGER REFERENCES roles(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- COMPANY AND SETTINGS
-- ============================================

CREATE TABLE IF NOT EXISTS company_settings (
    id SERIAL PRIMARY KEY,
    company_name_ar VARCHAR(255) NOT NULL,
    company_name_en VARCHAR(255),
    logo_path VARCHAR(255),
    address VARCHAR(500),
    phone VARCHAR(20),
    email VARCHAR(100),
    tax_number VARCHAR(50),
    commercial_registration VARCHAR(50),
    website VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS licenses (
    id SERIAL PRIMARY KEY,
    license_key VARCHAR(100) UNIQUE NOT NULL,
    package_type VARCHAR(50),
    start_date DATE,
    end_date DATE,
    max_users INTEGER,
    is_active BOOLEAN DEFAULT true,
    hardware_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- CHART OF ACCOUNTS
-- ============================================

CREATE TABLE IF NOT EXISTS accounts (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name_ar VARCHAR(255) NOT NULL,
    name_en VARCHAR(255),
    type VARCHAR(50),
    level INTEGER,
    parent_id INTEGER REFERENCES accounts(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS journal_entries (
    id SERIAL PRIMARY KEY,
    entry_number VARCHAR(50) UNIQUE NOT NULL,
    entry_date DATE NOT NULL,
    description TEXT,
    reference_type VARCHAR(50),
    reference_id INTEGER,
    is_posted BOOLEAN DEFAULT false,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS journal_entry_lines (
    id SERIAL PRIMARY KEY,
    entry_id INTEGER REFERENCES journal_entries(id),
    account_id INTEGER REFERENCES accounts(id),
    debit DECIMAL(15,2) DEFAULT 0,
    credit DECIMAL(15,2) DEFAULT 0,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS general_ledger (
    id SERIAL PRIMARY KEY,
    account_id INTEGER REFERENCES accounts(id),
    entry_date DATE,
    entry_id INTEGER REFERENCES journal_entries(id),
    description TEXT,
    debit DECIMAL(15,2) DEFAULT 0,
    credit DECIMAL(15,2) DEFAULT 0,
    balance DECIMAL(15,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- CUSTOMERS AND SUPPLIERS
-- ============================================

CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE,
    name_ar VARCHAR(255) NOT NULL,
    name_en VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100),
    address VARCHAR(500),
    tax_number VARCHAR(50),
    commercial_registration VARCHAR(50),
    payment_terms VARCHAR(50),
    credit_limit DECIMAL(15,2),
    balance DECIMAL(15,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS suppliers (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE,
    name_ar VARCHAR(255) NOT NULL,
    name_en VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100),
    address VARCHAR(500),
    tax_number VARCHAR(50),
    commercial_registration VARCHAR(50),
    payment_terms VARCHAR(50),
    balance DECIMAL(15,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS customer_ledger (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id),
    transaction_date DATE,
    description TEXT,
    debit DECIMAL(15,2),
    credit DECIMAL(15,2),
    balance DECIMAL(15,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- INVENTORY AND PRODUCTS
-- ============================================

CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name_ar VARCHAR(255) NOT NULL,
    name_en VARCHAR(255),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    barcode VARCHAR(50),
    name_ar VARCHAR(255) NOT NULL,
    name_en VARCHAR(255),
    category_id INTEGER REFERENCES categories(id),
    unit VARCHAR(20),
    description TEXT,
    purchase_price DECIMAL(15,2),
    selling_price DECIMAL(15,2),
    cost_price DECIMAL(15,2),
    current_stock INTEGER DEFAULT 0,
    min_stock INTEGER,
    max_stock INTEGER,
    vat_percent DECIMAL(5,2) DEFAULT 15,
    is_active BOOLEAN DEFAULT true,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS warehouses (
    id SERIAL PRIMARY KEY,
    name_ar VARCHAR(255) NOT NULL,
    name_en VARCHAR(255),
    location VARCHAR(500),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS inventory (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    warehouse_id INTEGER REFERENCES warehouses(id),
    quantity INTEGER DEFAULT 0,
    cost_price DECIMAL(15,2),
    last_counted TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS inventory_movements (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    warehouse_id INTEGER REFERENCES warehouses(id),
    movement_type VARCHAR(50),
    quantity INTEGER,
    reference_type VARCHAR(50),
    reference_id INTEGER,
    notes TEXT,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- INVOICES AND SALES
-- ============================================

CREATE TABLE IF NOT EXISTS invoices (
    id SERIAL PRIMARY KEY,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    invoice_type VARCHAR(50),
    invoice_date DATE NOT NULL,
    due_date DATE,
    customer_id INTEGER REFERENCES customers(id),
    supplier_id INTEGER REFERENCES suppliers(id),
    warehouse_id INTEGER REFERENCES warehouses(id),
    subtotal DECIMAL(15,2),
    discount_percent DECIMAL(5,2),
    discount_amount DECIMAL(15,2),
    vat_amount DECIMAL(15,2),
    total_amount DECIMAL(15,2),
    paid_amount DECIMAL(15,2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'draft',
    zatca_status VARCHAR(50),
    zatca_uuid VARCHAR(255),
    notes TEXT,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS invoice_items (
    id SERIAL PRIMARY KEY,
    invoice_id INTEGER REFERENCES invoices(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER,
    unit_price DECIMAL(15,2),
    discount_percent DECIMAL(5,2),
    discount_amount DECIMAL(15,2),
    vat_percent DECIMAL(5,2),
    vat_amount DECIMAL(15,2),
    total_price DECIMAL(15,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- CASH AND PAYMENTS
-- ============================================

CREATE TABLE IF NOT EXISTS cash_registers (
    id SERIAL PRIMARY KEY,
    name_ar VARCHAR(255) NOT NULL,
    name_en VARCHAR(255),
    location VARCHAR(500),
    opening_balance DECIMAL(15,2),
    current_balance DECIMAL(15,2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS cashier_sessions (
    id SERIAL PRIMARY KEY,
    cash_register_id INTEGER REFERENCES cash_registers(id),
    user_id INTEGER REFERENCES users(id),
    session_date DATE NOT NULL,
    opening_balance DECIMAL(15,2),
    closing_balance DECIMAL(15,2),
    expected_balance DECIMAL(15,2),
    variance DECIMAL(15,2),
    status VARCHAR(50),
    opened_at TIMESTAMP,
    closed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bank_accounts (
    id SERIAL PRIMARY KEY,
    bank_name_ar VARCHAR(255) NOT NULL,
    bank_name_en VARCHAR(255),
    account_number VARCHAR(50) UNIQUE NOT NULL,
    account_holder VARCHAR(255),
    currency VARCHAR(10) DEFAULT 'SAR',
    current_balance DECIMAL(15,2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    payment_number VARCHAR(50) UNIQUE NOT NULL,
    payment_type VARCHAR(50),
    payment_date DATE NOT NULL,
    customer_id INTEGER REFERENCES customers(id),
    supplier_id INTEGER REFERENCES suppliers(id),
    invoice_id INTEGER REFERENCES invoices(id),
    cash_register_id INTEGER REFERENCES cash_registers(id),
    bank_account_id INTEGER REFERENCES bank_accounts(id),
    amount DECIMAL(15,2),
    payment_method VARCHAR(50),
    reference_number VARCHAR(100),
    notes TEXT,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS checks (
    id SERIAL PRIMARY KEY,
    check_number VARCHAR(50) UNIQUE NOT NULL,
    check_type VARCHAR(50),
    check_date DATE,
    maturity_date DATE,
    bank_account_id INTEGER REFERENCES bank_accounts(id),
    payee_name VARCHAR(255),
    amount DECIMAL(15,2),
    status VARCHAR(50) DEFAULT 'issued',
    notes TEXT,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- POS TRANSACTIONS
-- ============================================

CREATE TABLE IF NOT EXISTS pos_transactions (
    id SERIAL PRIMARY KEY,
    transaction_number VARCHAR(50) UNIQUE NOT NULL,
    cashier_session_id INTEGER REFERENCES cashier_sessions(id),
    customer_id INTEGER REFERENCES customers(id),
    transaction_date TIMESTAMP,
    subtotal DECIMAL(15,2),
    discount_percent DECIMAL(5,2),
    discount_amount DECIMAL(15,2),
    vat_amount DECIMAL(15,2),
    total_amount DECIMAL(15,2),
    payment_method VARCHAR(50),
    cash_received DECIMAL(15,2),
    change_amount DECIMAL(15,2),
    is_voided BOOLEAN DEFAULT false,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pos_transaction_items (
    id SERIAL PRIMARY KEY,
    pos_transaction_id INTEGER REFERENCES pos_transactions(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER,
    unit_price DECIMAL(15,2),
    total_price DECIMAL(15,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- ZATCA INTEGRATION
-- ============================================

CREATE TABLE IF NOT EXISTS zatca_invoices (
    id SERIAL PRIMARY KEY,
    invoice_id INTEGER REFERENCES invoices(id),
    uuid VARCHAR(255) UNIQUE,
    xml_content TEXT,
    qr_code TEXT,
    submission_status VARCHAR(50),
    submission_timestamp TIMESTAMP,
    compliance_status VARCHAR(50),
    certificate_path VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- REPORTS AND ANALYTICS
-- ============================================

CREATE TABLE IF NOT EXISTS financial_periods (
    id SERIAL PRIMARY KEY,
    period_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    status VARCHAR(50) DEFAULT 'open',
    is_closed BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS cost_centers (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) UNIQUE NOT NULL,
    name_ar VARCHAR(255) NOT NULL,
    name_en VARCHAR(255),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- ACTIVITY LOG
-- ============================================

CREATE TABLE IF NOT EXISTS activity_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    action VARCHAR(100),
    entity_type VARCHAR(50),
    entity_id INTEGER,
    old_values TEXT,
    new_values TEXT,
    ip_address VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_invoices_date ON invoices(invoice_date);
CREATE INDEX idx_invoices_customer ON invoices(customer_id);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_journal_entries_date ON journal_entries(entry_date);
CREATE INDEX idx_general_ledger_account ON general_ledger(account_id);
CREATE INDEX idx_inventory_product ON inventory(product_id);
CREATE INDEX idx_payments_date ON payments(payment_date);
CREATE INDEX idx_pos_transactions_date ON pos_transactions(transaction_date);
CREATE INDEX idx_activity_logs_user ON activity_logs(user_id);
CREATE INDEX idx_activity_logs_date ON activity_logs(created_at);

-- ============================================
-- INITIAL DATA
-- ============================================

-- Insert default roles
INSERT INTO roles (name, description, permissions) VALUES
    ('admin', 'مسؤول النظام', ARRAY['read', 'write', 'delete', 'report', 'settings', 'user_management']),
    ('accountant', 'محاسب', ARRAY['read', 'write', 'journal_entries', 'reports']),
    ('cashier', 'أمين صندوق', ARRAY['read', 'write', 'pos', 'payments']),
    ('manager', 'مدير', ARRAY['read', 'report'])
ON CONFLICT (name) DO NOTHING;

-- Insert default chart of accounts
INSERT INTO accounts (code, name_ar, name_en, type, level) VALUES
    ('1000', 'الأصول', 'Assets', 'asset', 1),
    ('1100', 'الأصول المتداولة', 'Current Assets', 'asset', 2),
    ('1110', 'الصندوق والبنك', 'Cash', 'asset', 3),
    ('1120', 'الذمم المدينة', 'Accounts Receivable', 'asset', 3),
    ('1130', 'المخزون', 'Inventory', 'asset', 3),
    ('2000', 'الالتزامات', 'Liabilities', 'liability', 1),
    ('2100', 'الالتزامات المتداولة', 'Current Liabilities', 'liability', 2),
    ('2110', 'الذمم الدائنة', 'Accounts Payable', 'liability', 3),
    ('2120', 'الضريبة المستحقة', 'Tax Payable', 'liability', 3),
    ('3000', 'حقوق الملاك', 'Equity', 'equity', 1),
    ('4000', 'الإيرادات', 'Revenue', 'income', 1),
    ('4100', 'إيرادات المبيعات', 'Sales Revenue', 'income', 2),
    ('5000', 'المصروفات', 'Expenses', 'expense', 1),
    ('5100', 'تكلفة البضاعة المباعة', 'Cost of Goods Sold', 'expense', 2),
    ('5200', 'مصروفات التشغيل', 'Operating Expenses', 'expense', 2)
ON CONFLICT (code) DO NOTHING;

-- Insert default warehouse
INSERT INTO warehouses (name_ar, name_en, location) VALUES
    ('المستودع الرئيسي', 'Main Warehouse', 'الرياض')
ON CONFLICT DO NOTHING;

-- Insert default cash register
INSERT INTO cash_registers (name_ar, name_en, location, opening_balance, current_balance) VALUES
    ('الصندوق الرئيسي', 'Main Register', 'الرياض', 0, 0)
ON CONFLICT DO NOTHING;

-- Insert default bank account
INSERT INTO bank_accounts (bank_name_ar, bank_name_en, account_number, account_holder, currency, current_balance) VALUES
    ('البنك الأهلي', 'National Bank', '1234567890', 'صقر الرحبة', 'SAR', 0)
ON CONFLICT DO NOTHING;
