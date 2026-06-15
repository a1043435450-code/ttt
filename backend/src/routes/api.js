import express from 'express';
import { ChartOfAccounts, Customer, Supplier, Item, Invoice } from '../models.js';
import { ActivityLog } from '../models.js';

const router = express.Router();

// Middleware للتحقق من المصادقة (يمكن تحسينها لاحقاً)
const authMiddleware = (req, res, next) => {
  req.user = { id: 'user-1', username: 'admin' }; // مؤقت
  next();
};

router.use(authMiddleware);

// شجرة الحسابات
router.get('/accounts', (req, res) => {
  const accounts = ChartOfAccounts.getAll();
  res.json(accounts);
});

router.post('/accounts', (req, res) => {
  try {
    const { code, name, type, parentId, level } = req.body;
    const id = ChartOfAccounts.create(code, name, type, parentId || null, level || 1);
    ActivityLog.log(req.user.id, 'CREATE', 'account', id);
    res.json({ id, code, name, type });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

router.get('/accounts/:id', (req, res) => {
  const account = ChartOfAccounts.getById(req.params.id);
  if (!account) return res.status(404).json({ error: 'Not found' });
  res.json(account);
});

router.put('/accounts/:id', (req, res) => {
  try {
    const updated = ChartOfAccounts.update(req.params.id, req.body);
    if (!updated) return res.status(400).json({ error: 'No changes' });
    ActivityLog.log(req.user.id, 'UPDATE', 'account', req.params.id);
    res.json({ success: true });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// العملاء
router.get('/customers', (req, res) => {
  const customers = Customer.getAll();
  res.json(customers);
});

router.post('/customers', (req, res) => {
  try {
    const { name, phone, email, address, taxNumber } = req.body;
    const id = Customer.create(name, phone, email, address, taxNumber);
    ActivityLog.log(req.user.id, 'CREATE', 'customer', id);
    res.json({ id, name, phone, email });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

router.get('/customers/:id', (req, res) => {
  const customer = Customer.getById(req.params.id);
  if (!customer) return res.status(404).json({ error: 'Not found' });
  res.json(customer);
});

router.put('/customers/:id', (req, res) => {
  try {
    const updated = Customer.update(req.params.id, req.body);
    if (!updated) return res.status(400).json({ error: 'No changes' });
    ActivityLog.log(req.user.id, 'UPDATE', 'customer', req.params.id);
    res.json({ success: true });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// الموردين
router.get('/suppliers', (req, res) => {
  const suppliers = Supplier.getAll();
  res.json(suppliers);
});

router.post('/suppliers', (req, res) => {
  try {
    const { name, phone, email, address, taxNumber } = req.body;
    const id = Supplier.create(name, phone, email, address, taxNumber);
    ActivityLog.log(req.user.id, 'CREATE', 'supplier', id);
    res.json({ id, name, phone, email });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

router.get('/suppliers/:id', (req, res) => {
  const supplier = Supplier.getById(req.params.id);
  if (!supplier) return res.status(404).json({ error: 'Not found' });
  res.json(supplier);
});

router.put('/suppliers/:id', (req, res) => {
  try {
    const updated = Supplier.update(req.params.id, req.body);
    if (!updated) return res.status(400).json({ error: 'No changes' });
    ActivityLog.log(req.user.id, 'UPDATE', 'supplier', req.params.id);
    res.json({ success: true });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// الأصناف
router.get('/items', (req, res) => {
  const items = Item.getAll();
  res.json(items);
});

router.post('/items', (req, res) => {
  try {
    const { code, name, description, unit, purchasePrice, sellingPrice, reorderLevel } = req.body;
    const id = Item.create(code, name, description, unit, purchasePrice, sellingPrice, reorderLevel);
    ActivityLog.log(req.user.id, 'CREATE', 'item', id);
    res.json({ id, code, name, unit });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

router.get('/items/:id', (req, res) => {
  const item = Item.getById(req.params.id);
  if (!item) return res.status(404).json({ error: 'Not found' });
  res.json(item);
});

router.put('/items/:id', (req, res) => {
  try {
    const updated = Item.update(req.params.id, req.body);
    if (!updated) return res.status(400).json({ error: 'No changes' });
    ActivityLog.log(req.user.id, 'UPDATE', 'item', req.params.id);
    res.json({ success: true });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// الفواتير
router.get('/invoices', (req, res) => {
  const invoices = Invoice.getAll();
  res.json(invoices);
});

router.post('/invoices', (req, res) => {
  try {
    const { invoiceNumber, invoiceType, invoiceDate, customerId, supplierId, subtotal, taxAmount, total } = req.body;
    const id = Invoice.create(invoiceNumber, invoiceType, invoiceDate, subtotal, taxAmount, total, customerId, supplierId);
    ActivityLog.log(req.user.id, 'CREATE', 'invoice', id);
    res.json({ id, invoiceNumber, invoiceType });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

router.get('/invoices/:id', (req, res) => {
  const invoice = Invoice.getById(req.params.id);
  if (!invoice) return res.status(404).json({ error: 'Not found' });
  const lines = Invoice.getLines(req.params.id);
  res.json({ ...invoice, lines });
});

router.post('/invoices/:id/lines', (req, res) => {
  try {
    const { itemId, quantity, unitPrice, lineTotal } = req.body;
    const lineId = Invoice.addLine(req.params.id, itemId, quantity, unitPrice, lineTotal);
    res.json({ lineId });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

export default router;
