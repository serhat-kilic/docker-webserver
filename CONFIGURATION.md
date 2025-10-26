# Configuration Management Guide

## Quick Reference

This guide explains how to manage and customize configuration files for PHP, OpenLiteSpeed, MySQL, and Redis in this Docker setup.

## Directory Structure

```
docker-webserver/
├── data/
│   └── etc/
│       ├── mysql/
│       │   └── conf.d/         # MySQL configuration files
│       │       ├── my-2gb.cnf
│       │       ├── my-4gb.cnf
│       │       ├── my-16gb.cnf
│       │       └── my-32gb.cnf
│       ├── php/
│       │   ├── 74/
│       │   │   └── php.ini     # PHP 7.4 configuration
│       │   ├── 80/
│       │   │   └── php.ini     # PHP 8.0 configuration
│       │   ├── 81/
│       │   │   └── php.ini     # PHP 8.1 configuration
│       │   ├── 82/
│       │   │   └── php.ini     # PHP 8.2 configuration
│       │   ├── 83/
│       │   │   └── php.ini     # PHP 8.3 configuration
│       │   ├── 84/
│       │   │   └── php.ini     # PHP 8.4 configuration
│       │   └── README.md
│       ├── redis/
│       │   └── redis.conf      # Redis configuration
│       └── openlitespeed/
│           └── README.md
├── volumes/
│   ├── www-conf/               # OpenLiteSpeed config (auto-generated)
│   ├── www-vhosts/             # Website files
│   ├── mysql/                  # MySQL data
│   ├── mysql-backup/           # MySQL backups
│   └── redis/                  # Redis data
└── docker-compose.yml
```

## Configuration Files Overview

### PHP Configuration (php.ini)

**Location:** `data/etc/php/[VERSION]/php.ini`

**When to edit:** 
- Need to change memory limits
- Adjust upload file sizes
- Modify execution timeouts
- Configure error reporting
- Customize OPcache settings

**How to apply changes:**
```bash
# 1. Edit the appropriate php.ini file for your PHP version
nano data/etc/php/82/php.ini  # For PHP 8.2

# 2. Restart OpenLiteSpeed
bash xshok-admin.sh --restart
```

**Common customizations:**
```ini
# Performance
memory_limit = 512M
max_execution_time = 600

# File Uploads
upload_max_filesize = 128M
post_max_size = 128M

# Development (disable for production!)
display_errors = On
error_reporting = E_ALL

# OPcache
opcache.memory_consumption = 256
```

---

### OpenLiteSpeed Configuration

**Location:** `volumes/www-conf/` (auto-generated after first run)

**When to edit:**
- Adjust server performance settings
- Configure SSL/TLS settings
- Modify worker process limits
- Add custom MIME types
- Configure access control

**How to apply changes:**

**Method 1: Web Admin (Recommended)**
```bash
# 1. Set admin password
bash xshok-admin.sh --password

# 2. Access web admin
# Open browser: https://your-server:7080

# 3. Make changes through GUI

# 4. Apply changes (graceful restart)
bash xshok-admin.sh --restart
```

**Method 2: Direct File Edit**
```bash
# 1. Edit configuration files
nano volumes/www-conf/httpd_config.conf

# 2. Graceful restart
bash xshok-admin.sh --restart
```

---

### MySQL Configuration

**Location:** `data/etc/mysql/conf.d/`

**Available presets:**
- `my-2gb.cnf` - For 2GB RAM servers
- `my-4gb.cnf` - For 4GB RAM servers (default)
- `my-16gb.cnf` - For 16GB RAM servers
- `my-32gb.cnf` - For 32GB+ RAM servers

**How to switch configuration:**
```bash
# 1. Edit docker-compose.yml
nano docker-compose.yml

# 2. Uncomment the desired config line under mysql service:
#        - ./data/etc/mysql/conf.d/my-2gb.cnf:/etc/mysql/conf.d/my.cnf:ro
        - ./data/etc/mysql/conf.d/my-4gb.cnf:/etc/mysql/conf.d/my.cnf:ro
#        - ./data/etc/mysql/conf.d/my-16gb.cnf:/etc/mysql/conf.d/my.cnf:ro

# 3. Restart services
bash xshok-admin.sh --down
bash xshok-admin.sh --start
```

---

### Redis Configuration

**Location:** `data/etc/redis/redis.conf`

**When to edit:**
- Change memory limits
- Configure persistence options
- Adjust connection settings
- Set maxmemory policy

**How to apply changes:**
```bash
# 1. Edit redis.conf
nano data/etc/redis/redis.conf

# 2. Restart services
bash xshok-admin.sh --restart
```

---

## Configuration Workflow

### First Time Setup

1. **Install the system:**
   ```bash
   cd /datastore
   bash xshok-admin.sh --start
   ```

2. **Check PHP version:**
   ```bash
   cat .env | grep PHP_VERSION
   ```

3. **Customize PHP settings:**
   ```bash
   nano data/etc/php/[YOUR_VERSION]/php.ini
   ```

4. **Set admin password:**
   ```bash
   bash xshok-admin.sh --password
   ```

5. **Restart to apply:**
   ```bash
   bash xshok-admin.sh --restart
   ```

---

### Switching PHP Versions

```bash
# 1. Stop services
bash xshok-admin.sh --down

# 2. Edit .env
nano .env
# Change: PHP_VERSION=82  (for PHP 8.2)

# 3. Customize new PHP version config if needed
nano data/etc/php/82/php.ini

# 4. Start services
bash xshok-admin.sh --start
```

---

### Adding a Website with Custom PHP Settings

```bash
# 1. Customize PHP settings first
nano data/etc/php/82/php.ini  # Edit as needed

# 2. Add website, database, and SSL
bash xshok-admin.sh --qa example.com

# 3. Restart to apply PHP settings
bash xshok-admin.sh --restart
```

---

## Best Practices

### 1. Always Backup Before Changes
```bash
# Backup configurations
cp -r data/etc data/etc.backup
cp -r volumes/www-conf volumes/www-conf.backup

# Backup databases
bash xshok-admin.sh --backup-all /tmp/backup
```

### 2. Test in Development First
- Never test configuration changes directly in production
- Use a staging/development server
- Monitor logs after changes

### 3. Document Your Changes
```bash
# Add comments to configuration files
# Example in php.ini:
# Increased for large video uploads - 2024-10-26
upload_max_filesize = 256M
```

### 4. Monitor After Changes
```bash
# Check logs
tail -f volumes/www-conf/logs/error.log

# Check PHP errors
docker-compose exec openlitespeed tail -f /var/log/php_errors.log
```

### 5. Use Version Control for Config Files
```bash
# Track your custom configurations
git add data/etc/php/82/php.ini
git commit -m "Increased upload limits for client needs"
```

---

## Troubleshooting

### PHP Settings Not Applied
```bash
# 1. Verify PHP version matches
cat .env | grep PHP_VERSION

# 2. Check if correct php.ini is mounted
docker-compose exec openlitespeed ls -la /usr/local/lsws/lsphp*/etc/php/*/litespeed/

# 3. Restart services
bash xshok-admin.sh --restart

# 4. Verify settings inside container
docker-compose exec openlitespeed php -i | grep memory_limit
```

### OpenLiteSpeed Config Not Applied
```bash
# 1. Check configuration syntax
docker-compose exec openlitespeed /usr/local/lsws/bin/lswsctrl configtest

# 2. Check for errors
tail -f volumes/www-conf/logs/error.log

# 3. Graceful restart
bash xshok-admin.sh --restart
```

### Container Won't Start After Config Change
```bash
# 1. Check docker logs
docker-compose logs openlitespeed

# 2. Restore backup
cp data/etc.backup/php/82/php.ini data/etc/php/82/php.ini

# 3. Restart
bash xshok-admin.sh --restart
```

---

## Additional Resources

- **PHP Configuration:** `data/etc/php/README.md`
- **OpenLiteSpeed:** `data/etc/openlitespeed/README.md`
- **Main Documentation:** `README.md`
- **OpenLiteSpeed Docs:** https://openlitespeed.org/kb/
- **PHP Manual:** https://www.php.net/manual/en/ini.core.php

---

## Support

If you encounter issues:
1. Check the logs in `volumes/www-conf/logs/`
2. Review the documentation files in `data/etc/`
3. Restore from backup if needed
4. Open an issue on GitHub with detailed information
