# পরিচয়

## সম্পূর্ণ পরীক্ষা এবং স্থাপনা নির্দেশিকা

### 1. ইউনিট পরীক্ষা

```bash
cd backend
npm test
```

### 2. একীকরণ পরীক্ষা

```bash
# শুরু ব্যাকএন্ড
cd backend && npm start

# নতুন টার্মিনাল এ - পরীক্ষা চালান
cd tests && npm test
```

### 3. উৎপাদনে স্থাপনা

```bash
# বিল্ড ফ্রন্টএন্ড
cd frontend && npm run build

# সার্ভার এ আপলোড করুন
scp -r dist/ user@server:/var/www/saqr-rahba/

# ব্যাকএন্ড স্থাপন করুন
ssh user@server
cd /var/www/saqr-rahba/backend
npm install --production
npm start
```

### 4. Docker স্থাপনা

```bash
docker build -t saqr-rahba .
docker run -p 3001:3001 -e DATABASE_URL=sqlite:./database.sqlite3 saqr-rahba
```

### 5. পর্যবেক্ষণ এবং রক্ষণাবেক্ষণ

- PM2 ব্যবহার করে দীর্ঘস্থায়ী চালান
- নিয়মিত ব্যাকআপ সেটআপ করুন
- লগ পর্যালোচনা করুন

### 6. নিরাপত্তা চেকলিস্ট

☐ SSL সার্টিফিকেট ইনস্টল করুন  
☐ ফায়ারওয়াল কনফিগার করুন  
☐ ডাটাবেস পাসওয়ার্ড পরিবর্তন করুন  
☐ API রেট সীমিতকরণ সেটআপ করুন  
☐ ব্যবহারকারী ইনপুট যাচাই করুন  
☐ ZATCA সার্টিফিকেট ইনস্টল করুন  

### সাপোর্ট

https://github.com/a1043435450-code/ttt
