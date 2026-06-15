import { v4 as uuidv4 } from 'uuid';
import db from '../db.js';

export class ChartOfAccounts {
  static create(code, name, type, parentId = null, level = 1) {
    const id = uuidv4();
    const stmt = db.prepare(`
      INSERT INTO chart_of_accounts (id, code, name, type, parent_id, level)
      VALUES (?, ?, ?, ?, ?, ?)
    `);
    stmt.run(id, code, name, type, parentId, level);
    return id;
  }

  static getAll() {
    return db.prepare('SELECT * FROM chart_of_accounts ORDER BY code').all();
  }

  static getById(id) {
    return db.prepare('SELECT * FROM chart_of_accounts WHERE id = ?').get(id);
  }

  static getByCode(code) {
    return db.prepare('SELECT * FROM chart_of_accounts WHERE code = ?').get(code);
  }

  static update(id, data) {
    const allowed = ['name', 'type', 'is_active'];
    const fields = Object.keys(data).filter(k => allowed.includes(k));
    if (fields.length === 0) return false;
    
    const setClause = fields.map(f => `${f} = ?`).join(', ');
    const values = fields.map(f => data[f]);
    values.push(id);
    
    const stmt = db.prepare(`UPDATE chart_of_accounts SET ${setClause} WHERE id = ?`);
    stmt.run(...values);
    return true;
  }
}

export class JournalEntry {
  static create(entryDate, description, referenceType = null, referenceId = null, userId) {
    const id = uuidv4();
    const stmt = db.prepare(`
      INSERT INTO journal_entries (id, entry_date, description, reference_type, reference_id, user_id)
      VALUES (?, ?, ?, ?, ?, ?)
    `);
    stmt.run(id, entryDate, description, referenceType, referenceId, userId);
    return id;
  }

  static addLine(entryId, accountId, debit = 0, credit = 0) {
    const id = uuidv4();
    const stmt = db.prepare(`
      INSERT INTO journal_entry_lines (id, entry_id, account_id, debit, credit)
      VALUES (?, ?, ?, ?, ?)
    `);
    stmt.run(id, entryId, accountId, debit || 0, credit || 0);
    return id;
  }

  static validateBalance(entryId) {
    const result = db.prepare(`
      SELECT SUM(COALESCE(debit, 0)) as total_debit, SUM(COALESCE(credit, 0)) as total_credit
      FROM journal_entry_lines
      WHERE entry_id = ?
    `).get(entryId);
    
    const balanced = Math.abs(result.total_debit - result.total_credit) < 0.01;
    
    if (balanced) {
      db.prepare('UPDATE journal_entries SET is_balanced = true WHERE id = ?').run(entryId);
    }
    
    return balanced;
  }

  static getAll() {
    return db.prepare(`
      SELECT je.*, u.username, u.full_name
      FROM journal_entries je
      LEFT JOIN users u ON je.user_id = u.id
      ORDER BY je.entry_date DESC
    `).all();
  }

  static getById(id) {
    return db.prepare('SELECT * FROM journal_entries WHERE id = ?').get(id);
  }

  static getLines(entryId) {
    return db.prepare(`
      SELECT jel.*, coa.code, coa.name
      FROM journal_entry_lines jel
      JOIN chart_of_accounts coa ON jel.account_id = coa.id
      WHERE jel.entry_id = ?
    `).all(entryId);
  }
}

export class Customer {
  static create(name, phone = '', email = '', address = '', taxNumber = '') {
    const id = uuidv4();
    const stmt = db.prepare(`
      INSERT INTO customers (id, name, phone, email, address, tax_number)
      VALUES (?, ?, ?, ?, ?, ?)
    `);
    stmt.run(id, name, phone, email, address, taxNumber);
    return id;
  }

  static getAll() {
    return db.prepare('SELECT * FROM customers ORDER BY name').all();
  }

  static getById(id) {
    return db.prepare('SELECT * FROM customers WHERE id = ?').get(id);
  }

  static update(id, data) {
    const allowed = ['name', 'phone', 'email', 'address', 'tax_number'];
    const fields = Object.keys(data).filter(k => allowed.includes(k));
    if (fields.length === 0) return false;
    
    const setClause = fields.map(f => `${f} = ?`).join(', ');
    const values = fields.map(f => data[f]);
    values.push(id);
    
    const stmt = db.prepare(`UPDATE customers SET ${setClause} WHERE id = ?`);
    stmt.run(...values);
    return true;
  }
}

export class Supplier {
  static create(name, phone = '', email = '', address = '', taxNumber = '') {
    const id = uuidv4();
    const stmt = db.prepare(`
      INSERT INTO suppliers (id, name, phone, email, address, tax_number)
      VALUES (?, ?, ?, ?, ?, ?)
    `);
    stmt.run(id, name, phone, email, address, taxNumber);
    return id;
  }

  static getAll() {
    return db.prepare('SELECT * FROM suppliers ORDER BY name').all();
  }

  static getById(id) {
    return db.prepare('SELECT * FROM suppliers WHERE id = ?').get(id);
  }

  static update(id, data) {
    const allowed = ['name', 'phone', 'email', 'address', 'tax_number'];
    const fields = Object.keys(data).filter(k => allowed.includes(k));
    if (fields.length === 0) return false;
    
    const setClause = fields.map(f => `${f} = ?`).join(', ');
    const values = fields.map(f => data[f]);
    values.push(id);
    
    const stmt = db.prepare(`UPDATE suppliers SET ${setClause} WHERE id = ?`);
    stmt.run(...values);
    return true;
  }
}

export class Item {
  static create(code, name, description = '', unit = 'piece', purchasePrice = 0, sellingPrice = 0, reorderLevel = 0) {
    const id = uuidv4();
    const stmt = db.prepare(`
      INSERT INTO items (id, code, name, description, unit, purchase_price, selling_price, reorder_level)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `);
    stmt.run(id, code, name, description, unit, purchasePrice, sellingPrice, reorderLevel);
    return id;
  }

  static getAll() {
    return db.prepare('SELECT * FROM items ORDER BY code').all();
  }

  static getById(id) {
    return db.prepare('SELECT * FROM items WHERE id = ?').get(id);
  }

  static getByCode(code) {
    return db.prepare('SELECT * FROM items WHERE code = ?').get(code);
  }

  static update(id, data) {
    const allowed = ['name', 'description', 'unit', 'purchase_price', 'selling_price', 'reorder_level'];
    const fields = Object.keys(data).filter(k => allowed.includes(k));
    if (fields.length === 0) return false;
    
    const setClause = fields.map(f => `${f} = ?`).join(', ');
    const values = fields.map(f => data[f]);
    values.push(id);
    
    const stmt = db.prepare(`UPDATE items SET ${setClause} WHERE id = ?`);
    stmt.run(...values);
    return true;
  }
}

export class Invoice {
  static create(invoiceNumber, invoiceType, invoiceDate, subtotal = 0, taxAmount = 0, total = 0, customerId = null, supplierId = null) {
    const id = uuidv4();
    const stmt = db.prepare(`
      INSERT INTO invoices (id, invoice_number, invoice_type, customer_id, supplier_id, invoice_date, subtotal, tax_amount, total)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);
    stmt.run(id, invoiceNumber, invoiceType, customerId, supplierId, invoiceDate, subtotal, taxAmount, total);
    return id;
  }

  static addLine(invoiceId, itemId, quantity, unitPrice, lineTotal) {
    const id = uuidv4();
    const stmt = db.prepare(`
      INSERT INTO invoice_lines (id, invoice_id, item_id, quantity, unit_price, line_total)
      VALUES (?, ?, ?, ?, ?, ?)
    `);
    stmt.run(id, invoiceId, itemId, quantity, unitPrice, lineTotal);
    return id;
  }

  static getAll() {
    return db.prepare(`
      SELECT i.*, c.name as customer_name, s.name as supplier_name
      FROM invoices i
      LEFT JOIN customers c ON i.customer_id = c.id
      LEFT JOIN suppliers s ON i.supplier_id = s.id
      ORDER BY i.invoice_date DESC
    `).all();
  }

  static getById(id) {
    return db.prepare('SELECT * FROM invoices WHERE id = ?').get(id);
  }

  static getLines(invoiceId) {
    return db.prepare(`
      SELECT il.*, i.code, i.name
      FROM invoice_lines il
      JOIN items i ON il.item_id = i.id
      WHERE il.invoice_id = ?
    `).all(invoiceId);
  }

  static updateStatus(invoiceId, status) {
    db.prepare('UPDATE invoices SET status = ? WHERE id = ?').run(status, invoiceId);
  }

  static updateZATCAStatus(invoiceId, zatcaStatus, zatcaUUID = null) {
    db.prepare('UPDATE invoices SET zatca_status = ?, zatca_uuid = ? WHERE id = ?')
      .run(zatcaStatus, zatcaUUID, invoiceId);
  }
}

export class CashierSession {
  static create(userId, sessionDate, openingBalance) {
    const id = uuidv4();
    const stmt = db.prepare(`
      INSERT INTO cashier_sessions (id, user_id, session_date, opening_balance, opened_at)
      VALUES (?, ?, ?, ?, datetime('now'))
    `);
    stmt.run(id, userId, sessionDate, openingBalance);
    return id;
  }

  static closeSession(sessionId, closingBalance) {
    db.prepare(`
      UPDATE cashier_sessions 
      SET status = 'closed', closing_balance = ?, closed_at = datetime('now')
      WHERE id = ?
    `).run(closingBalance, sessionId);
  }

  static getCurrentSession(userId) {
    return db.prepare(`
      SELECT * FROM cashier_sessions
      WHERE user_id = ? AND status = 'open'
      ORDER BY opened_at DESC LIMIT 1
    `).get(userId);
  }

  static getAll() {
    return db.prepare(`
      SELECT cs.*, u.username, u.full_name
      FROM cashier_sessions cs
      JOIN users u ON cs.user_id = u.id
      ORDER BY cs.opened_at DESC
    `).all();
  }
}

export class POSTransaction {
  static create(sessionId, customerId = null, total, paymentMethod) {
    const id = uuidv4();
    const stmt = db.prepare(`
      INSERT INTO pos_transactions (id, session_id, customer_id, total, payment_method, transaction_date)
      VALUES (?, ?, ?, ?, ?, datetime('now'))
    `);
    stmt.run(id, sessionId, customerId, total, paymentMethod);
    return id;
  }

  static getBySession(sessionId) {
    return db.prepare(`
      SELECT pt.*, c.name as customer_name
      FROM pos_transactions pt
      LEFT JOIN customers c ON pt.customer_id = c.id
      WHERE pt.session_id = ?
      ORDER BY pt.transaction_date DESC
    `).all(sessionId);
  }

  static getSessionTotal(sessionId) {
    const result = db.prepare(`
      SELECT SUM(total) as total_sales
      FROM pos_transactions
      WHERE session_id = ?
    `).get(sessionId);
    return result.total_sales || 0;
  }
}

export class CompanySettings {
  static get() {
    return db.prepare('SELECT * FROM company_settings LIMIT 1').get();
  }

  static update(data) {
    const allowed = ['company_name', 'logo_path', 'address', 'commercial_registration', 'tax_number', 'phone', 'email'];
    const fields = Object.keys(data).filter(k => allowed.includes(k));
    
    if (fields.length === 0) return false;
    
    const existing = this.get();
    
    if (!existing) {
      const id = uuidv4();
      const insertFields = ['id', ...fields];
      const values = [id, ...fields.map(f => data[f])];
      const placeholders = insertFields.map(() => '?').join(', ');
      
      db.prepare(`
        INSERT INTO company_settings (${insertFields.join(', ')})
        VALUES (${placeholders})
      `).run(...values);
    } else {
      const setClause = fields.map(f => `${f} = ?`).join(', ');
      const values = fields.map(f => data[f]);
      values.push(existing.id);
      
      db.prepare(`UPDATE company_settings SET ${setClause} WHERE id = ?`).run(...values);
    }
    
    return true;
  }
}

export class License {
  static create(licenseKey, licenseType, activationDate, expirationDate, maxUsers) {
    const id = uuidv4();
    const stmt = db.prepare(`
      INSERT INTO licenses (id, license_key, license_type, activation_date, expiration_date, max_users)
      VALUES (?, ?, ?, ?, ?, ?)
    `);
    stmt.run(id, licenseKey, licenseType, activationDate, expirationDate, maxUsers);
    return id;
  }

  static getActive() {
    return db.prepare(`
      SELECT * FROM licenses
      WHERE is_active = true
      AND expiration_date > date('now')
      ORDER BY expiration_date DESC
      LIMIT 1
    `).get();
  }

  static verifyLicense(licenseKey) {
    const license = db.prepare(`
      SELECT * FROM licenses
      WHERE license_key = ?
      AND is_active = true
      AND expiration_date > date('now')
    `).get(licenseKey);
    
    return license ? true : false;
  }

  static isExpired() {
    const license = this.getActive();
    return !license;
  }
}

export class User {
  static create(username, passwordHash, fullName = '', email = '', role = 'user') {
    const id = uuidv4();
    const stmt = db.prepare(`
      INSERT INTO users (id, username, password_hash, full_name, email, role)
      VALUES (?, ?, ?, ?, ?, ?)
    `);
    stmt.run(id, username, passwordHash, fullName, email, role);
    return id;
  }

  static getByUsername(username) {
    return db.prepare('SELECT * FROM users WHERE username = ?').get(username);
  }

  static getById(id) {
    return db.prepare('SELECT * FROM users WHERE id = ?').get(id);
  }

  static getAll() {
    return db.prepare('SELECT id, username, full_name, email, role, is_active, created_at FROM users ORDER BY created_at DESC').all();
  }

  static update(id, data) {
    const allowed = ['full_name', 'email', 'role', 'is_active'];
    const fields = Object.keys(data).filter(k => allowed.includes(k));
    if (fields.length === 0) return false;
    
    const setClause = fields.map(f => `${f} = ?`).join(', ');
    const values = fields.map(f => data[f]);
    values.push(id);
    
    const stmt = db.prepare(`UPDATE users SET ${setClause} WHERE id = ?`);
    stmt.run(...values);
    return true;
  }
}

export class ActivityLog {
  static log(userId, action, entityType, entityId) {
    const id = uuidv4();
    const stmt = db.prepare(`
      INSERT INTO activity_log (id, user_id, action, entity_type, entity_id)
      VALUES (?, ?, ?, ?, ?)
    `);
    stmt.run(id, userId, action, entityType, entityId);
  }

  static getAll(limit = 100) {
    return db.prepare(`
      SELECT al.*, u.username, u.full_name
      FROM activity_log al
      LEFT JOIN users u ON al.user_id = u.id
      ORDER BY al.created_at DESC
      LIMIT ?
    `).all(limit);
  }

  static getByUser(userId, limit = 50) {
    return db.prepare(`
      SELECT * FROM activity_log
      WHERE user_id = ?
      ORDER BY created_at DESC
      LIMIT ?
    `).all(userId, limit);
  }
}
