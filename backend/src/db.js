import express from 'express';
import Database from 'better-sqlite3';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { readFileSync } from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const dbPath = join(__dirname, '../database.sqlite3');
const db = new Database(dbPath);

db.pragma('foreign_keys = ON');

// Read and execute schema
const schemaPath = join(__dirname, '../../database/schema.sql');
const schema = readFileSync(schemaPath, 'utf-8');

const statements = schema.split(';').filter(s => s.trim());
for (const stmt of statements) {
  if (stmt.trim()) {
    try {
      db.exec(stmt);
    } catch (error) {
      console.log(`Warning: ${error.message}`);
    }
  }
}

// Read and execute seed data
const seedPath = join(__dirname, '../../database/seed-data.sql');
const seedData = readFileSync(seedPath, 'utf-8');

const seedStatements = seedData.split(';').filter(s => s.trim());
for (const stmt of seedStatements) {
  if (stmt.trim()) {
    try {
      db.exec(stmt);
    } catch (error) {
      console.log(`Warning: ${error.message}`);
    }
  }
}

console.log('✓ Database initialized successfully');

export default db;
