# صيانة ومراقبة نظام صقر الرحبة

## مراقبة الأداء

### 1. مراقبة استخدام الموارد

```bash
# است��دام top
top

# استخدام htop (أكثر سهولة)
htop

# استخدام PM2
pm2 monit
```

### 2. فحص السجلات

```bash
# عرض سجلات التطبيق
pm2 logs

# عرض سجلات محددة
pm2 logs saqr-backend

# عرض آخر 100 سطر
pm2 logs saqr-backend --lines 100
```

### 3. فحص قاعدة البيانات

```bash
# الاتصال بقاعدة البيانات
psql -U saqr -d saqr_rahba

# حجم قاعدة البيانات
SELECT pg_size_pretty(pg_database_size('saqr_rahba'));

# عدد الصفوف في الجداول
SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) 
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

# الخروج
\q
```

## العمليات الصيانية

### تنظيف قاعدة البيانات

```bash
# حذف السجلات القديمة (أكثر من سنة)
DELETE FROM activity_logs WHERE created_at < NOW() - INTERVAL '1 year';

# تحسين الجداول
VACUUM ANALYZE;

# إعادة بناء الفهارس
REINDEX DATABASE saqr_rahba;
```

### تحديث النظام

```bash
# الحصول على آخر الكود
cd /var/www/saqr-rahba
git pull origin main

# تحديث الحزم
npm install
cd backend && npm install && cd ..
cd frontend && npm install && npm run build && cd ..

# إعادة تشغيل التطبيق
pm2 restart all
```

### النسخ الاحتياطية

#### النسخ اليدوية

```bash
# نسخ قاعدة البيانات
DUMP_DATE=$(date +%Y%m%d_%H%M%S)
pg_dump -U saqr saqr_rahba | gzip > /backups/db_$DUMP_DATE.sql.gz

# نسخ الملفات
tar -czf /backups/files_$DUMP_DATE.tar.gz /var/www/saqr-rahba/
```

#### استعادة من نسخة احتياطية

```bash
# استعادة قاعدة البيانات
zcat /backups/db_20240101_120000.sql.gz | psql -U saqr saqr_rahba

# استعادة الملفات
tar -xzf /backups/files_20240101_120000.tar.gz -C /
```

## استكشاف وإصلاح الأخطاء

### المشكلة: البطء الشديد

```bash
# 1. تحقق من استخدام الموارد
pm2 monit

# 2. فحص استعلامات قاعدة البيانات البطيئة
psql -U saqr -d saqr_rahba
SELECT query, calls, mean_exec_time 
FROM pg_stat_statements 
ORDER BY mean_exec_time DESC LIMIT 10;

# 3. قم بتحسين الفهارس
REINDEX DATABASE saqr_rahba;

# 4. اعادة تشغيل قاعدة البيانات
sudo systemctl restart postgresql
```

### المشكلة: ارتفاع حجم قاعدة البيانات

```bash
# 1. تحقق من حجم الجداول
SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size 
FROM pg_tables WHERE schemaname='public' ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

# 2. حذف السجلات القديمة
DELETE FROM activity_logs WHERE created_at < NOW() - INTERVAL '6 months';
DELETE FROM pos_transactions WHERE created_at < NOW() - INTERVAL '1 year';

# 3. نظف المساحة المهدرة
VACUUM ANALYZE;
```

### المشكلة: فشل الاتصال بقاعدة البيانات

```bash
# 1. تحقق من حالة PostgreSQL
sudo systemctl status postgresql

# 2. اعد تشغيل PostgreSQL
sudo systemctl restart postgresql

# 3. تحقق من ملف الإعدادات
sudo nano /etc/postgresql/14/main/postgresql.conf

# 4. تحقق من حقوق الوصول
sudo nano /etc/postgresql/14/main/pg_hba.conf
```

### المشكلة: خطأ في الترخيص

```bash
# تحديث الترخيص
UPDATE licenses SET end_date = NOW() + INTERVAL '1 year' 
WHERE license_key = 'SAQR-DEMO-2024-001';
```

## جدول الصيانة الموصى به

| المهمة | التكرار | الوصف |
|------|--------|-------|
| عمل نسخة احتياطية | يومي | نسخ قاعدة البيانات والملفات |
| فحص الأداء | يومي | مراقبة استخدام الموارد |
| تنظيف السجلات | أسبوعي | حذف السجلات القديمة |
| تحديث الأمان | أسبوعي | تثبيت التحديثات الأمنية |
| تحسين قاعدة البيانات | شهري | إعادة بناء الفهارس، تنظيف المساحة |
| مراجعة النسخ الاحتياطية | شهري | اختبار استعادة من نسخة احتياطية |
| تحديث النظام | ربع سنوي | تحديث الحزم والمكتبات |
| مراجعة الأمان | سنوي | فحص شامل للأمان والأداء |

## المراقبة المتقدمة

### استخدام Prometheus

```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
  - job_name: 'postgresql'
    static_configs:
      - targets: ['localhost:9187']
```

### استخدام Alerting

```yaml
# alerts.yml
groups:
  - name: saqr_alerts
    rules:
      - alert: HighCPUUsage
        expr: node_cpu > 0.8
        for: 5m
        annotations:
          summary: "High CPU usage detected"
      
      - alert: LowDiskSpace
        expr: node_filesystem_avail_bytes < 10737418240
        for: 5m
        annotations:
          summary: "Low disk space"
      
      - alert: DatabaseDown
        expr: pg_up == 0
        for: 1m
        annotations:
          summary: "PostgreSQL is down"
```

## التقارير الدورية

### تقرير الأداء الأسبوعي

```bash
#!/bin/bash
echo "=== Weekly Performance Report ==="
echo "Date: $(date)"
echo ""
echo "System Load:"
uptime
echo ""
echo "Disk Usage:"
df -h
echo ""
echo "Database Size:"
psql -U saqr -d saqr_rahba -c "SELECT pg_size_pretty(pg_database_size('saqr_rahba'));"
echo ""
echo "Application Status:"
pm2 status
```

## الدعم

للمساعدة في الصيانة: support@saqr.com
