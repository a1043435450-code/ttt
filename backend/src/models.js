import Database from 'better-sqlite3';
import { v4 as uuidv4 } from 'uuid';

const db = new Database('./database.sqlite3');

export class ActivityLog {
  static log(userId, action, entityType, entityId) {
    const id = uuidv4();
    const stmt = db.prepare(`
      INSERT INTO activity_log (id, user_id, action, entity_type, entity_id)
      VALUES (?, ?, ?, ?, ?)
    `);
    stmt.run(id, userId, action, entityType, entityId);
  }
}

export class ChartOfAccounts {
  static create(code, name, type) {
    const id = uuidv4();
    const stmt = db.prepare(`
      INSERT INTO chart_of_accounts (id, code, name, type)
      VALUES (?, ?, ?, ?)
    `);
    stmt.run(id, code, name, type);
    return id;
  }
}

export class Customer {
  static create(name, phone, email) {
    const id = uuidv4();
    const stmt = db.prepare(`
      INSERT INTO customers (id, name, phone, email)
      VALUES (?, ?, ?, ?)
    `);
    stmt.run(id, name, phone, email);
    return id;
  }
}

export class Invoice {
  static create(invoiceNumber, type, total) {
    const id = uuidv4();
    const stmt = db.prepare(`
      INSERT INTO invoices (id, invoice_number, invoice_type, total)
      VALUES (?, ?, ?, ?)
    `);
    stmt.run(id, invoiceNumber, type, total);
    return id;
  }
}

export class JournalEntry {
  static create(description, lines) {
    const id = uuidv4();
    const stmt = db.prepare(`
      INSERT INTO journal_entries (id, description)
      VALUES (?, ?)
    `);
    stmt.run(id, description);
    return id;
  }
}
