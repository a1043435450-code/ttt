-- Insert default admin user
-- Password: admin123 (hashed)
INSERT INTO users (username, password_hash, full_name, email, role, is_active) VALUES
    ('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcg7b3XeKeQmGDeWvDrxj4b.B4m', 'مسؤول النظام', 'admin@saqr.local', 'admin', true)
ON CONFLICT (username) DO NOTHING;

-- Insert sample categories
INSERT INTO categories (name_ar, name_en, description) VALUES
    ('إلكترونيات', 'Electronics', 'المنتجات الإلكترونية'),
    ('مواد غذائية', 'Food', 'المواد الغذائية والمشروبات'),
    ('ملابس', 'Clothing', 'الملابس والأحذية'),
    ('أثاث', 'Furniture', 'الأثاث والتجهيزات')
ON CONFLICT DO NOTHING;

-- Insert sample products
INSERT INTO products (code, barcode, name_ar, name_en, category_id, unit, purchase_price, selling_price, cost_price, current_stock, min_stock, max_stock, vat_percent)
VALUES
    ('PRD001', '1234567890001', 'هاتف ذكي', 'Smartphone', 1, 'piece', 500, 800, 500, 50, 10, 100, 15),
    ('PRD002', '1234567890002', 'كمبيوتر محمول', 'Laptop', 1, 'piece', 1500, 2500, 1500, 20, 5, 30, 15),
    ('PRD003', '1234567890003', 'قميص رجالي', 'Male Shirt', 3, 'piece', 50, 100, 50, 100, 20, 200, 15),
    ('PRD004', '1234567890004', 'أرز أبيض', 'White Rice', 2, 'kg', 2, 3.5, 2, 500, 100, 1000, 15)
ON CONFLICT (code) DO NOTHING;

-- Insert sample customers
INSERT INTO customers (code, name_ar, name_en, phone, email, address, payment_terms, credit_limit)
VALUES
    ('CUST001', 'محمد أحمد', 'Mohammad Ahmed', '+966501234567', 'mohammad@example.com', 'الرياض - حي النخيل', '30 days', 10000),
    ('CUST002', 'فاطمة علي', 'Fatima Ali', '+966502234567', 'fatima@example.com', 'جدة - حي الروضة', '15 days', 5000)
ON CONFLICT (code) DO NOTHING;

-- Insert sample suppliers
INSERT INTO suppliers (code, name_ar, name_en, phone, email, address, payment_terms)
VALUES
    ('SUPP001', 'شركة الرابح', 'Al Rabi Company', '+966501111111', 'info@alrabi.com', 'الدمام - المنطقة التجارية', '30 days'),
    ('SUPP002', 'مصنع النجاح', 'Al Najah Factory', '+966502222222', 'sales@alnajah.com', 'القصيم - الرياض', '60 days')
ON CONFLICT (code) DO NOTHING;

-- Insert sample company settings
INSERT INTO company_settings (company_name_ar, company_name_en, address, phone, email, tax_number, commercial_registration) VALUES
    ('صقر الرحبة للتجارة', 'Saqr Al-Rahba Trading', 'الرياض - حي النخيل', '+966920000000', 'info@saqr.com', '123456789', '1010234567')
ON CONFLICT DO NOTHING;

-- Insert trial license
INSERT INTO licenses (license_key, package_type, start_date, end_date, max_users, is_active) VALUES
    ('SAQR-DEMO-2024-001', 'trial', CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days', 5, true)
ON CONFLICT (license_key) DO NOTHING;
