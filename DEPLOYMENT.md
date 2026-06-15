# نظام صقر الرحبة المحاسبي - دليل النشر

## متطلبات النشر

### البيئة الإنتاجية
- Ubuntu 20.04 LTS أو أحدث
- Node.js 18+
- npm 9+
- PostgreSQL 14+ أو SQLite
- nginx
- SSL Certificate

### معدات الخادم
- CPU: 4 cores (minimum)
- RAM: 8GB (minimum)
- Storage: 100GB SSD
- Bandwidth: 100Mbps

## خطوات النشر

### 1. تحضير الخادم

```bash
# تحديث النظام
sudo apt update && sudo apt upgrade -y

# تثبيت المتطلبات
sudo apt install -y nodejs npm postgresql nginx git

# إنشاء مستخدم التطبيق
sudo useradd -m -s /bin/bash saqr
sudo usermod -aG sudo saqr

# إنشاء مجلد التطبيق
sudo mkdir -p /var/www/saqr-rahba
sudo chown -R saqr:saqr /var/www/saqr-rahba
```

### 2. نشر التطبيق

```bash
# الذهاب إلى مجلد التطبيق
cd /var/www/saqr-rahba

# استنساخ المستودع
git clone https://github.com/a1043435450-code/ttt.git .

# تثبيت الحزم
npm install --production

# تثبيت الحزم الخاصة بـ Backend
cd backend
npm install --production
cd ..

# تثبيت الحزم الخاصة بـ Frontend
cd frontend
npm install --production
npm run build
cd ..

# إنشاء ملف .env
cp backend/.env.example backend/.env

# تحرير إعدادات الإنتاج
nano backend/.env
```

### 3. إعداد قاعدة البيانات

```bash
# إنشاء قاعدة البيانات
sudo -u postgres psql -c "CREATE DATABASE saqr_rahba;"
sudo -u postgres psql -c "CREATE USER saqr WITH PASSWORD 'password';"
sudo -u postgres psql -c "ALTER ROLE saqr SET client_encoding TO 'utf8';"
sudo -u postgres psql -c "ALTER ROLE saqr SET default_transaction_isolation TO 'read committed';"
sudo -u postgres psql -c "ALTER ROLE saqr SET default_transaction_deferrable TO on;"
sudo -u postgres psql -c "ALTER DATABASE saqr_rahba OWNER TO saqr;"

# استيراد مخطط قاعدة البيانات
sudo -u postgres psql -d saqr_rahba -f database/schema.sql
sudo -u postgres psql -d saqr_rahba -f database/seed-data.sql
```

### 4. إعداد nginx

```bash
# إنشاء ملف التكوين
sudo nano /etc/nginx/sites-available/saqr-rahba
```

```nginx
upstream backend {
    server localhost:3001;
}

server {
    listen 80;
    server_name saqr.example.com;
    
    # إعادة التوجيه إلى HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name saqr.example.com;
    
    # SSL Certificates
    ssl_certificate /etc/letsencrypt/live/saqr.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/saqr.example.com/privkey.pem;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Gzip Compression
    gzip on;
    gzip_types text/plain text/css text/javascript application/json application/javascript;
    gzip_min_length 1024;
    
    # Frontend
    location / {
        root /var/www/saqr-rahba/frontend/dist;
        try_files $uri $uri/ /index.html;
    }
    
    # Backend API
    location /api/ {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# تفعيل الموقع
sudo ln -s /etc/nginx/sites-available/saqr-rahba /etc/nginx/sites-enabled/

# اختبار التكوين
sudo nginx -t

# إعادة تشغيل nginx
sudo systemctl restart nginx
```

### 5. إعداد SSL

```bash
# تثبيت Certbot
sudo apt install -y certbot python3-certbot-nginx

# الحصول على شهادة SSL
sudo certbot certonly --nginx -d saqr.example.com
```

### 6. إعداد PM2 للعمليات الخلفية

```bash
# تثبيت PM2
sudo npm install -g pm2

# إنشاء ملف ecosystem.config.js
cat > /var/www/saqr-rahba/ecosystem.config.js << EOF
module.exports = {
  apps: [
    {
      name: 'saqr-backend',
      script: './backend/src/index.js',
      instances: 4,
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production'
      },
      error_file: './logs/err.log',
      out_file: './logs/out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    }
  ]
};
EOF

# بدء التطبيق
cd /var/www/saqr-rahba
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

### 7. إعداد المراقبة والنسخ الاحتياطي

```bash
# إنشاء مجلد السجلات
mkdir -p /var/www/saqr-rahba/logs

# إعداد النسخة الاحتياطية اليومية
cat > /var/www/saqr-rahba/backup.sh << EOF
#!/bin/bash
BACKUP_DIR="/backups/saqr-rahba"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p \$BACKUP_DIR

# نسخ قاعدة البيانات
sudo -u postgres pg_dump saqr_rahba | gzip > \$BACKUP_DIR/db_\$DATE.sql.gz

# نسخ الملفات
tar -czf \$BACKUP_DIR/files_\$DATE.tar.gz /var/www/saqr-rahba/

# حذف النسخ القديمة (أكثر من 30 يوم)
find \$BACKUP_DIR -type f -mtime +30 -delete
EOF

chmod +x /var/www/saqr-rahba/backup.sh

# إضافة النسخة الاحتياطية إلى cron (كل يوم الساعة 2 صباحاً)
sudo crontab -e
# أضف: 0 2 * * * /var/www/saqr-rahba/backup.sh
```

### 8. اختبار النشر

```bash
# الوصول إلى الموقع
http://saqr.example.com

# اختبار API
curl https://saqr.example.com/api/health

# التحقق من السجلات
pm2 logs
```

## المراقبة المستمرة

### استخدام PM2 Monitoring

```bash
pm2 install pm2-logrotate
pm2 install pm2-auto-pull
pm2 link your_secret_key your_public_key
```

### استخدام Prometheus + Grafana

```bash
# تثبيت Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.40.0/prometheus-2.40.0.linux-amd64.tar.gz
tar -xzf prometheus-2.40.0.linux-amd64.tar.gz

# تثبيت Grafana
sudo apt install -y grafana-server
```

## استكشاف الأخطاء

### المشاكل الشائعة

**1. فشل الاتصال بقاعدة البيانات**
```bash
# تحقق من حالة PostgreSQL
sudo systemctl status postgresql

# إعادة تشغيل PostgreSQL
sudo systemctl restart postgresql
```

**2. الموارد العالية للـ CPU/Memory**
```bash
# مراقبة العمليات
pm2 monit

# اعادة تشغيل العمليات
pm2 restart all
```

**3. أخطاء SSL**
```bash
# تجديد الشهادة
sudo certbot renew

# التحقق من تاريخ انتهاء الشهادة
sudo openssl x509 -enddate -noout -in /etc/letsencrypt/live/saqr.example.com/cert.pem
```

## الصيانة الدورية

- **أسبوعياً**: مراجعة السجلات والنسخ الاحتياطية
- **شهرياً**: تحديث الحزم والمكتبات
- **ربع سنوي**: اختبار استعادة النسخ الاحتياطية
- **سنوياً**: مراجعة الأمان والأداء

## الدعم

للحصول على الدعم: https://github.com/a1043435450-code/ttt/issues
