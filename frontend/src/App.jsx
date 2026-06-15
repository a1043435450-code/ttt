import { useState, useEffect } from 'react';
import axios from 'axios';
import './index.css';

function App() {
  const [page, setPage] = useState('dashboard');
  const [accounts, setAccounts] = useState([]);
  const [customers, setCustomers] = useState([]);
  const [suppliers, setSuppliers] = useState([]);
  const [items, setItems] = useState([]);
  const [invoices, setInvoices] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      const [accRes, custRes, suppRes, itemRes, invRes] = await Promise.all([
        axios.get('/api/accounts'),
        axios.get('/api/customers'),
        axios.get('/api/suppliers'),
        axios.get('/api/items'),
        axios.get('/api/invoices')
      ]);
      setAccounts(accRes.data);
      setCustomers(custRes.data);
      setSuppliers(suppRes.data);
      setItems(itemRes.data);
      setInvoices(invRes.data);
    } catch (error) {
      console.error('Error loading data:', error);
    } finally {
      setLoading(false);
    }
  };

  const renderPage = () => {
    switch (page) {
      case 'accounts':
        return (
          <div className="card">
            <h2 className="text-2xl font-bold mb-4">شجرة الحسابات</h2>
            <table className="table">
              <thead>
                <tr>
                  <th>الرمز</th>
                  <th>الاسم</th>
                  <th>النوع</th>
                </tr>
              </thead>
              <tbody>
                {accounts.map(acc => (
                  <tr key={acc.id}>
                    <td>{acc.code}</td>
                    <td>{acc.name}</td>
                    <td>{acc.type}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        );
      case 'customers':
        return (
          <div className="card">
            <h2 className="text-2xl font-bold mb-4">العملاء</h2>
            <table className="table">
              <thead>
                <tr>
                  <th>الاسم</th>
                  <th>الهاتف</th>
                  <th>البريد الإلكتروني</th>
                </tr>
              </thead>
              <tbody>
                {customers.map(cust => (
                  <tr key={cust.id}>
                    <td>{cust.name}</td>
                    <td>{cust.phone}</td>
                    <td>{cust.email}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        );
      default:
        return (
          <div className="card">
            <h1 className="text-3xl font-bold">صقر الرحبة - لوحة التحكم</h1>
            <p className="mt-4">مرحباً بك في نظام صقر الرحبة للمحاسبة والمبيعات</p>
          </div>
        );
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow">
        <div className="container flex justify-between items-center py-4">
          <h1 className="text-xl font-bold">صقر الرحبة</h1>
          <nav className="flex gap-4">
            <button onClick={() => setPage('dashboard')} className="btn btn-secondary">
              الرئيسية
            </button>
            <button onClick={() => setPage('accounts')} className="btn btn-secondary">
              الحسابات
            </button>
            <button onClick={() => setPage('customers')} className="btn btn-secondary">
              العملاء
            </button>
          </nav>
        </div>
      </header>
      <main className="container">
        {loading ? <p>جاري التحميل...</p> : renderPage()}
      </main>
    </div>
  );
}

export default App;
