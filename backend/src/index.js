import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import api from './src/routes/api.js';
import { License, User } from './src/models.js';
import { hashPassword } from './src/services/auth.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// License check middleware
app.use((req, res, next) => {
  const isExpired = License.isExpired();
  if (isExpired && !req.path.includes('/license')) {
    return res.status(403).json({ error: 'License expired' });
  }
  next();
});

// Health check
app.get('/api/health', (req, res) => {
  const license = License.getActive();
  res.json({
    status: 'ok',
    service: 'Saqr Al-Rahba Backend',
    version: '0.1.0',
    license: license ? 'active' : 'expired',
    timestamp: new Date().toISOString()
  });
});

// API routes
app.use('/api', api);

// License management
app.post('/api/license/activate', (req, res) => {
  const { licenseKey, licenseType } = req.body;
  try {
    const activationDate = new Date().toISOString().split('T')[0];
    const expirationDate = new Date(Date.now() + 365*24*60*60*1000).toISOString().split('T')[0];
    
    License.create(licenseKey, licenseType, activationDate, expirationDate, 999);
    res.json({ success: true, message: 'License activated' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.get('/api/license/status', (req, res) => {
  const license = License.getActive();
  res.json({
    isActive: !!license,
    license: license ? { type: license.license_type, expiresAt: license.expiration_date } : null
  });
});

// Initialize default data
app.post('/api/initialize', (req, res) => {
  try {
    // Create default admin user if not exists
    const admin = User.getByUsername('admin');
    if (!admin) {
      User.create('admin', hashPassword('admin123'), 'Administrator', 'admin@saqr.local', 'admin');
    }
    
    // Create demo license
    const activeLicense = License.getActive();
    if (!activeLicense) {
      const activationDate = new Date().toISOString().split('T')[0];
      const expirationDate = new Date(Date.now() + 30*24*60*60*1000).toISOString().split('T')[0];
      License.create('SAQR-DEMO-2024', 'demo', activationDate, expirationDate, 5);
    }
    
    res.json({ success: true, message: 'System initialized' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════════════════════════╗
║   صقر الرحبة - نظام المحاسبة والمبيعات والمخزون            ║
║   Saqr Al-Rahba Accounting System                          ║
╚════════════════════════════════════════════════════════════╝

✓ Backend running on http://localhost:${PORT}
✓ API: http://localhost:${PORT}/api
✓ Health check: http://localhost:${PORT}/api/health

Database: SQLite
Environment: ${process.env.NODE_ENV || 'development'}

Press Ctrl+C to stop the server
`);
});
