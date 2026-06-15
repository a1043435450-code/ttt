import { useState, useEffect } from 'react'
import axios from 'axios'

function App() {
  const [status, setStatus] = useState('تحميل...')

  useEffect(() => {
    axios.get('/api/health')
      .then(res => setStatus('متصل ✓'))
      .catch(() => setStatus('غير متصل ✗'))
  }, [])

  return (
    <div style={{ padding: '20px', textAlign: 'center', direction: 'rtl' }}>
      <h1>صقر الرحبة لأنظمة المحاسبة</h1>
      <p>الحالة: {status}</p>
    </div>
  )
}

export default App
