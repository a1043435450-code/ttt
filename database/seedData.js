export default async function initializeDatabase() {
  console.log('Initializing Saqr Al-Rahba Database...');
  
  const initialData = {
    accounts: [
      { code: '1000', name: 'الأصول', type: 'asset', level: 1 },
      { code: '1100', name: 'الأصول المتداولة', type: 'asset', level: 2 },
      { code: '1110', name: 'النقد', type: 'asset', level: 3 },
      { code: '1120', name: 'البنوك', type: 'asset', level: 3 },
      { code: '1200', name: 'الأصول الثابتة', type: 'asset', level: 2 },
      { code: '2000', name: 'الالتزامات', type: 'liability', level: 1 },
      { code: '2100', name: 'الالتزامات المتداولة', type: 'liability', level: 2 },
      { code: '3000', name: 'حقوق الملاك', type: 'equity', level: 1 },
      { code: '4000', name: 'الإيرادات', type: 'revenue', level: 1 },
      { code: '4100', name: 'إيرادات المبيعات', type: 'revenue', level: 2 },
      { code: '5000', name: 'المصروفات', type: 'expense', level: 1 },
      { code: '5100', name: 'تكلفة البضاعة المباعة', type: 'expense', level: 2 }
    ],
    users: [
      { username: 'admin', password: 'admin123', fullName: 'مسؤول النظام', role: 'admin' },
      { username: 'cashier', password: 'cashier123', fullName: 'أمين الصندوق', role: 'cashier' },
      { username: 'accountant', password: 'accountant123', fullName: 'المحاسب', role: 'accountant' }
    ],
    licenses: [
      {
        licenseKey: 'SAQR-DEMO-2024',
        licenseType: 'demo',
        activationDate: new Date().toISOString().split('T')[0],
        expirationDate: new Date(Date.now() + 30*24*60*60*1000).toISOString().split('T')[0],
        maxUsers: 5
      }
    ]
  };
  
  return initialData;
}
