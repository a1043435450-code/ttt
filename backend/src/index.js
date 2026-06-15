import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import db from './db.js';
import { hashPassword, verifyPassword, generateToken, verifyToken } from './services/auth.js';
import { v4 as uuidv4 } from 'uuid';
import { ActivityLog, ChartOfAccounts, Customer, Invoice, JournalEntry } from './models.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

dotenv.config({ path: `${__dirname}/../.env` });

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Auth middleware
const authMiddleware = (req, res, next) => {
  const token = req.header('Authorization')?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: 'No token' });
  
  const user = verifyToken(token);
  if (!user) return res.status(401).json({ error: 'Invalid token' });
  
  req.user = user;
  next();
};

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'Saqr Al-Rahba Backend',
    version: '0.1.0',
    timestamp: new Date().toISOString()
  });
});

// ============================================
// AUTHENTICATION
// ============================================

app.post('/api/auth/login', (req, res) => {
  try {
    const { username, password } = req.body;
    const stmt = db.prepare('SELECT * FROM users WHERE username = ?');
    const user = stmt.get(username);
    
    if (!user || !verifyPassword(password, user.password_hash)) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    const token = generateToken(user.id);
    
    res.json({
      success: true,
      token,
      user: {
        id: user.id,
        username: user.username,
        full_name: user.full_name,
        role: user.role
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// CHART OF ACCOUNTS
// ============================================

app.get('/api/accounts', authMiddleware, (req, res) => {
  try {
    const stmt = db.prepare('SELECT * FROM chart_of_accounts ORDER BY code');
    const accounts = stmt.all();
    res.json({ success: true, data: accounts });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/accounts', authMiddleware, (req, res) => {
  try {
    const { code, name, type, parentId, level } = req.body;
    const id = uuidv4();
    
    const stmt = db.prepare(`
      INSERT INTO chart_of_accounts (id, code, name, type, parent_id, level)
      VALUES (?, ?, ?, ?, ?, ?)
    `);
    
    stmt.run(id, code, name, type, parentId || null, level || 1);
    ActivityLog.log(req.user.id, 'CREATE', 'account', id);
    
    res.json({ success: true, id });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// CUSTOMERS
// ============================================

app.get('/api/customers', authMiddleware, (req, res) => {
  try {
    const stmt = db.prepare('SELECT * FROM customers ORDER BY name');
    const customers = stmt.all();
    res.json({ success: true, data: customers });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/customers', authMiddleware, (req, res) => {
  try {
    const { name, phone, email, address, taxNumber } = req.body;
    const id = uuidv4();
    
    const stmt = db.prepare(`
      INSERT INTO customers (id, name, phone, email, address, tax_number)
      VALUES (?, ?, ?, ?, ?, ?)
    `);
    
    stmt.run(id, name, phone, email, address, taxNumber);
    ActivityLog.log(req.user.id, 'CREATE', 'customer', id);
    
    res.json({ success: true, id });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// INVOICES
// ============================================

app.get('/api/invoices', authMiddleware, (req, res) => {
  try {
    const stmt = db.prepare(`
      SELECT i.*, c.name as customer_name
      FROM invoices i
      LEFT JOIN customers c ON i.customer_id = c.id
      ORDER BY i.created_at DESC
      LIMIT 100
    `);
    const invoices = stmt.all();
    res.json({ success: true, data: invoices });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/invoices', authMiddleware, (req, res) => {
  try {
    const { invoiceNumber, invoiceType, invoiceDate, customerId, items, total, subtotal, tax } = req.body;
    const id = uuidv4();
    
    const stmt = db.prepare(`
      INSERT INTO invoices (id, invoice_number, invoice_type, customer_id, invoice_date, subtotal, tax_amount, total, created_by)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);
    
    stmt.run(id, invoiceNumber, invoiceType, customerId, invoiceDate, subtotal, tax, total, req.user.id);
    
    // Add items
    const itemStmt = db.prepare(`
      INSERT INTO invoice_lines (invoice_id, item_id, quantity, unit_price, line_total)
      VALUES (?, ?, ?, ?, ?)
    `);
    
    for (const item of items) {
      itemStmt.run(id, item.itemId, item.quantity, item.unitPrice, item.quantity * item.unitPrice);
    }
    
    ActivityLog.log(req.user.id, 'CREATE', 'invoice', id);
    
    res.json({ success: true, id });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// REPORTS
// ============================================

app.get('/api/reports/dashboard', authMiddleware, (req, res) => {
  try {
    const todayRevenue = db.prepare(`
      SELECT COALESCE(SUM(total), 0) as revenue
      FROM invoices
      WHERE invoice_type = 'sales' AND status = 'confirmed'
      AND DATE(created_at) = DATE('now')
    `).get();
    
    const totalCustomers = db.prepare('SELECT COUNT(*) as count FROM customers').get();
    const totalProducts = db.prepare('SELECT COUNT(*) as count FROM items').get();
    
    res.json({
      success: true,
      data: {
        today_revenue: todayRevenue.revenue,
        total_customers: totalCustomers.count,
        total_products: totalProducts.count
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/reports/trial-balance', authMiddleware, (req, res) => {
  try {
    const stmt = db.prepare(`
      SELECT a.code, a.name,
        COALESCE(SUM(jel.debit), 0) as debit,
        COALESCE(SUM(jel.credit), 0) as credit
      FROM chart_of_accounts a
      LEFT JOIN journal_entry_lines jel ON a.id = jel.account_id
      GROUP BY a.id
      ORDER BY a.code
    `);
    
    const accounts = stmt.all();
    const totalDebit = accounts.reduce((sum, acc) => sum + (acc.debit || 0), 0);
    const totalCredit = accounts.reduce((sum, acc) => sum + (acc.credit || 0), 0);
    
    res.json({
      success: true,
      data: {
        accounts,
        totals: { total_debit: totalDebit, total_credit: totalCredit }
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ============================================
// ERROR HANDLING
// ============================================

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════════════════════════════╗
║   صقر الرحبة - نظام المحاسبة والمبيعات والمخزون             ║
║   Saqr Al-Rahba Accounting System v0.1.0                       ║
╚════════════════════════════════════════════════════════════════╝

✓ Backend running on http://localhost:${PORT}
✓ API: http://localhost:${PORT}/api
✓ Health check: http://localhost:${PORT}/api/health

Database: SQLite
Environment: ${process.env.NODE_ENV || 'development'}

Press Ctrl+C to stop
`);
});
