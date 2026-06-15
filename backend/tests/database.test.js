import Database from 'better-sqlite3';
import { describe, it, expect, beforeAll } from '@jest/globals';

let db;

beforeAll(() => {
  db = new Database(':memory:');
  
  db.exec(`
    CREATE TABLE accounts (
      id INTEGER PRIMARY KEY,
      code VARCHAR(20),
      name VARCHAR(255),
      type VARCHAR(50)
    )
  `);
});

describe('Database Tests', () => {
  it('should insert data', () => {
    const stmt = db.prepare('INSERT INTO accounts (code, name, type) VALUES (?, ?, ?)');
    const info = stmt.run('1000', 'Assets', 'asset');
    expect(info.changes).toBe(1);
  });

  it('should query data', () => {
    const stmt = db.prepare('SELECT * FROM accounts WHERE code = ?');
    const row = stmt.get('1000');
    expect(row.name).toBe('Assets');
  });

  it('should update data', () => {
    const stmt = db.prepare('UPDATE accounts SET name = ? WHERE code = ?');
    const info = stmt.run('Total Assets', '1000');
    expect(info.changes).toBe(1);
  });
});
