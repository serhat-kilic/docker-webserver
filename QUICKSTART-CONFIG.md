# Quick Start: Customizing PHP Configuration

This is a quick guide to get you started with customizing PHP settings.

## 5-Minute Setup

### Step 1: Find Your PHP Version
```bash
cat .env | grep PHP_VERSION
# Or if .env doesn't exist yet:
cat default.env | grep PHP_VERSION
```

### Step 2: Edit Your PHP Configuration
```bash
# For PHP 8.2 (replace 82 with your version):
nano data/etc/php/82/php.ini
```

### Step 3: Apply Changes
```bash
bash xshok-admin.sh --restart
```

### Step 4: Verify (Optional)
```bash
./verify-config.sh
```

## Common Configuration Changes

### Increase Upload Limits
Edit `data/etc/php/[YOUR_VERSION]/php.ini`:
```ini
upload_max_filesize = 128M
post_max_size = 128M
```

### Increase Memory Limit
```ini
memory_limit = 512M
```

### Increase Execution Time
```ini
max_execution_time = 600
max_input_time = 600
```

### Enable Error Display (Development Only!)
```ini
display_errors = On
error_reporting = E_ALL
```

### Optimize OPcache
```ini
opcache.memory_consumption = 256
opcache.max_accelerated_files = 20000
```

## Example: WordPress with Large Media Files

For a WordPress site that needs to handle large video uploads:

1. Edit your PHP config:
```bash
nano data/etc/php/82/php.ini
```

2. Change these settings:
```ini
upload_max_filesize = 256M
post_max_size = 256M
memory_limit = 512M
max_execution_time = 600
max_input_time = 600
```

3. Restart:
```bash
bash xshok-admin.sh --restart
```

4. Verify in WordPress:
   - Go to Media > Add New
   - Check "Maximum upload file size" shown by WordPress

## Example: High-Traffic Site Optimization

For a high-traffic site needing maximum performance:

1. Edit your PHP config:
```bash
nano data/etc/php/82/php.ini
```

2. Optimize OPcache:
```ini
opcache.enable = 1
opcache.memory_consumption = 512
opcache.interned_strings_buffer = 16
opcache.max_accelerated_files = 20000
opcache.revalidate_freq = 60
opcache.jit = tracing
opcache.jit_buffer_size = 128M
```

3. Increase memory:
```ini
memory_limit = 512M
```

4. Restart:
```bash
bash xshok-admin.sh --restart
```

## Switching PHP Versions

If you need to change PHP versions:

1. Stop services:
```bash
bash xshok-admin.sh --down
```

2. Edit .env:
```bash
nano .env
```
Change `PHP_VERSION=74` to your desired version (74, 80, 81, 82, 83, or 84)

3. Customize the new version's config if needed:
```bash
nano data/etc/php/82/php.ini  # Match your new version
```

4. Start services:
```bash
bash xshok-admin.sh --start
```

## Troubleshooting

### Changes Not Taking Effect?

1. Make sure you edited the correct version's php.ini:
```bash
cat .env | grep PHP_VERSION
ls -la data/etc/php/
```

2. Restart the service:
```bash
bash xshok-admin.sh --restart
```

3. Check if settings are applied:
```bash
docker-compose exec openlitespeed php -i | grep memory_limit
```

### Can't Find php.ini?

Run the verification script:
```bash
./verify-config.sh
```

It will show you:
- Which PHP version is active
- If all config files exist
- Current PHP settings

### Need More Help?

See the detailed guides:
- **Full configuration guide:** [CONFIGURATION.md](CONFIGURATION.md)
- **PHP-specific guide:** [data/etc/php/README.md](data/etc/php/README.md)
- **Main documentation:** [README.md](README.md)

## Tips

- **Always backup** before making changes
- **Test changes** on a development server first
- **Document your changes** with comments in the ini file
- **Monitor logs** after changes: `tail -f volumes/www-conf/logs/error.log`
- **Use the verify script** to check your setup: `./verify-config.sh`
