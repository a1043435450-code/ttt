import Database from 'better-sqlite3';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { readFileSync } from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const dbPath = join(__dirname, '../database.sqlite3');
const db = new Database(dbPath);

// تفعيل المفاتيح الأجنبية
db.pragma('foreign_keys = ON');

// قراءة وتنفيذ مخطط قاعدة البيانات
const schemaPath = join(__dirname, '../../database/schema.sql');
const schema = readFileSync(schemaPath, 'utf-8');

const statements = schema.split(';').filter(s => s.trim());
for (const stmt of statements) {
  if (stmt.trim()) {
    db.exec(stmt);
  }
}

console.log('✓ Database initialized');

export default db;
