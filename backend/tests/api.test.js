import { describe, it, expect, beforeAll, afterAll } from '@jest/globals';
import axios from 'axios';

const API_URL = 'http://localhost:3001/api';
let token = '';

describe('Authentication Tests', () => {
  it('should login with correct credentials', async () => {
    const response = await axios.post(`${API_URL}/auth/login`, {
      username: 'admin',
      password: 'admin123'
    });
    
    expect(response.status).toBe(200);
    expect(response.data.token).toBeDefined();
    token = response.data.token;
  });

  it('should fail with incorrect credentials', async () => {
    try {
      await axios.post(`${API_URL}/auth/login`, {
        username: 'admin',
        password: 'wrong'
      });
      expect(false).toBe(true);
    } catch (error) {
      expect(error.response.status).toBe(401);
    }
  });
});

describe('Chart of Accounts Tests', () => {
  it('should get all accounts', async () => {
    const response = await axios.get(`${API_URL}/accounts`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    expect(response.status).toBe(200);
    expect(Array.isArray(response.data.data)).toBe(true);
  });

  it('should create a new account', async () => {
    const response = await axios.post(`${API_URL}/accounts`, {
      code: 'TEST001',
      name: 'Test Account',
      type: 'asset'
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    expect(response.status).toBe(200);
    expect(response.data.success).toBe(true);
  });
});

describe('Invoice Tests', () => {
  it('should get all invoices', async () => {
    const response = await axios.get(`${API_URL}/invoices`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    expect(response.status).toBe(200);
    expect(Array.isArray(response.data.data)).toBe(true);
  });

  it('should create a new invoice', async () => {
    const response = await axios.post(`${API_URL}/invoices`, {
      invoiceNumber: `INV-${Date.now()}`,
      invoiceType: 'sales',
      invoiceDate: new Date().toISOString().split('T')[0],
      customerId: null,
      items: [],
      total: 0,
      subtotal: 0,
      tax: 0
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    expect(response.status).toBe(200);
    expect(response.data.success).toBe(true);
  });
});

describe('Reports Tests', () => {
  it('should get dashboard data', async () => {
    const response = await axios.get(`${API_URL}/reports/dashboard`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    expect(response.status).toBe(200);
    expect(response.data.data).toBeDefined();
  });

  it('should get trial balance', async () => {
    const response = await axios.get(`${API_URL}/reports/trial-balance`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    expect(response.status).toBe(200);
    expect(response.data.data.accounts).toBeDefined();
  });
});
