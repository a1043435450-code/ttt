import { useState, useEffect } from 'react';
import axios from 'axios';

function App() {
  const [page, setPage] = useState('dashboard');
  const [data, setData] = useState({
    accounts: [],
    customers: [],
    suppliers: [],
    items: [],
    invoices: []
  });
  const [loading, setLoading] = useState(false);
  const [stats, setStats] = useState({
    totalSales: 0,
    totalPurchases: 0,
    totalInventory: 0,
    totalCustomers: 0
  });

  useEffect(() => {
    loadAllData();
  }, []);

  const loadAllData = async () => {
    try {
      setLoading(true);
      const endpoints = [
        '/api/accounts',
        '/api/customers',
        '/api/suppliers',
        '/api/items',
        '/api/invoices'
      ];

      const responses = await Promise.all(
        endpoints.map(endpoint =>
          axios.get(endpoint).catch(err => [])
        )
      );

      setData({
        accounts: responses[0].data || [],
        customers: responses[1].data || [],
        suppliers: responses[2].data || [],
        items: responses[3].data || [],
        invoices: responses[4].data || []
      });

      // Calculate stats
      const totalSales = (responses[4].data || []).reduce((sum, inv) => sum + (inv.total || 0), 0);
      setStats({
        totalSales: totalSales.toFixed(2),
        totalPurchases: 0,
        totalInventory: (responses[3].data || []).length,
        totalCustomers: (responses[1].data || []).length
      });
    } catch (error) {
      console.error('Error loading data:', error);
    } finally {
      setLoading(false);
    }
  };

  const Dashboard = () => (
    <div>
      <h1 className="text-4xl font-bold mb-8 text-blue-900">صقر الرحبة - لوحة التحكم</h1>
      <div className="dashboard-grid">
        <div className="stat-card blue">
          <div className="text-gray-600 text-sm">إجمالي المبيعات</div>
          <div className="text-3xl font-bold text-blue-600">{stats.totalSales} ر.س</div>
        </div>
        <div className="stat-card green">
          <div className="text-gray-600 text-sm">عدد العملاء</div>
          <div className="text-3xl font-bold text-green-600">{stats.totalCustomers}</div>
        </div>
        <div className="stat-card yellow">
          <div className="text-gray-600 text-sm">الأصناف</div>
          <div className="text-3xl font-bold text-yellow-600">{stats.totalInventory}</div>
        </div>
        <div className="stat-card red">
          <div className="text-gray-600 text-sm">الحسابات</div>
          <div className="text-3xl font-bold text-red-600">{data.accounts.length}</div>
        </div>
      </div>
    </div>
  );

  const AccountsPage = () => (
    <div className="card">
      <h2 className="text-2xl font-bold mb-6">شجرة الحسابات</h2>
      {loading ? (
        <p>جاري التحميل...</p>
      ) : (
        <table className="table">
          <thead>
            <tr>
              <th>الرمز</th>
              <th>الاسم</th>
              <th>النوع</th>
              <th>المستوى</th>
            </tr>
          </thead>
          <tbody>
            {data.accounts.map(acc => (
              <tr key={acc.id}>
                <td>{acc.code}</td>
                <td>{acc.name}</td>
                <td>
                  <span className="badge badge-info">{acc.type}</span>
                </td>
                <td>{acc.level}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );

  const CustomersPage = () => (
    <div className="card">
      <h2 className="text-2xl font-bold mb-6">إدارة العملاء</h2>
      {loading ? (
        <p>جاري التحميل...</p>
      ) : (
        <table className="table">
          <thead>
            <tr>
              <th>الاسم</th>
              <th>الهاتف</th>
              <th>البريد الإلكتروني</th>
              <th>الرقم الضريبي</th>
            </tr>
          </thead>
          <tbody>
            {data.customers.map(cust => (
              <tr key={cust.id}>
                <td>{cust.name}</td>
                <td>{cust.phone}</td>
                <td>{cust.email}</td>
                <td>{cust.tax_number}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );

  const SuppliersPage = () => (
    <div className="card">
      <h2 className="text-2xl font-bold mb-6">إدارة الموردين</h2>
      {loading ? (
        <p>جاري التحميل...</p>
      ) : (
        <table className="table">
          <thead>
            <tr>
              <th>الاسم</th>
              <th>الهاتف</th>
              <th>البريد الإلكتروني</th>
              <th>العنوان</th>
            </tr>
          </thead>
          <tbody>
            {data.suppliers.map(supp => (
              <tr key={supp.id}>
                <td>{supp.name}</td>
                <td>{supp.phone}</td>
                <td>{supp.email}</td>
                <td>{supp.address}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );

  const InvoicesPage = () => (
    <div className="card">
      <h2 className="text-2xl font-bold mb-6">الفواتير</h2>
      {loading ? (
        <p>جاري التحميل...</p>
      ) : (
        <table className="table">
          <thead>
            <tr>
              <th>رقم الفاتورة</th>
              <th>التاريخ</th>
              <th>الإجمالي</th>
              <th>الحالة</th>
            </tr>
          </thead>
          <tbody>
            {data.invoices.map(inv => (
              <tr key={inv.id}>
                <td>{inv.invoice_number}</td>
                <td>{inv.invoice_date}</td>
                <td>{inv.total} ر.س</td>
                <td>
                  <span className={`badge badge-${inv.status === 'paid' ? 'success' : 'warning'}`}>
                    {inv.status === 'paid' ? 'مدفوعة' : 'معلقة'}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );

  return (
    <div className="flex min-h-screen bg-gray-50">
      {/* Sidebar */}
      <aside className="sidebar">
        <div className="px-6 py-4">
          <h1 className="text-2xl font-bold">صقر الرحبة</h1>
          <p className="text-sm text-blue-200">نظام المحاسبة</p>
        </div>
        <nav className="space-y-2 px-4 mt-8">
          <button
            onClick={() => setPage('dashboard')}
            className={`w-full text-right px-4 py-2 rounded-lg transition ${
              page === 'dashboard' ? 'bg-blue-500 font-bold' : 'hover:bg-blue-700'
            }`}
          >
            لوحة التحكم
          </button>
          <button
            onClick={() => setPage('accounts')}
            className={`w-full text-right px-4 py-2 rounded-lg transition ${
              page === 'accounts' ? 'bg-blue-500 font-bold' : 'hover:bg-blue-700'
            }`}
          >
            الحسابات
          </button>
          <button
            onClick={() => setPage('customers')}
            className={`w-full text-right px-4 py-2 rounded-lg transition ${
              page === 'customers' ? 'bg-blue-500 font-bold' : 'hover:bg-blue-700'
            }`}
          >
            العملاء
          </button>
          <button
            onClick={() => setPage('suppliers')}
            className={`w-full text-right px-4 py-2 rounded-lg transition ${
              page === 'suppliers' ? 'bg-blue-500 font-bold' : 'hover:bg-blue-700'
            }`}
          >
            الموردين
          </button>
          <button
            onClick={() => setPage('invoices')}
            className={`w-full text-right px-4 py-2 rounded-lg transition ${
              page === 'invoices' ? 'bg-blue-500 font-bold' : 'hover:bg-blue-700'
            }`}
          >
            الفواتير
          </button>
        </nav>
      </aside>

      {/* Main Content */}
      <main className="main-content flex-1">
        {page === 'dashboard' && <Dashboard />}
        {page === 'accounts' && <AccountsPage />}
        {page === 'customers' && <CustomersPage />}
        {page === 'suppliers' && <SuppliersPage />}
        {page === 'invoices' && <InvoicesPage />}
      </main>
    </div>
  );
}

export default App;
