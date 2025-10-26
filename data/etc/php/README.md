# PHP Configuration Files

This directory contains PHP configuration files for different PHP versions.

## Structure

```
data/etc/php/
├── 74/php.ini  - PHP 7.4 configuration
├── 80/php.ini  - PHP 8.0 configuration
├── 81/php.ini  - PHP 8.1 configuration
├── 82/php.ini  - PHP 8.2 configuration
├── 83/php.ini  - PHP 8.3 configuration
└── 84/php.ini  - PHP 8.4 configuration
```

## How to Use

1. **Select your PHP version** in the `.env` file:
   ```bash
   PHP_VERSION=82  # for PHP 8.2
   ```

2. **Edit the corresponding PHP configuration file**:
   - For PHP 7.4: `data/etc/php/74/php.ini`
   - For PHP 8.0: `data/etc/php/80/php.ini`
   - For PHP 8.1: `data/etc/php/81/php.ini`
   - For PHP 8.2: `data/etc/php/82/php.ini`
   - For PHP 8.3: `data/etc/php/83/php.ini`
   - For PHP 8.4: `data/etc/php/84/php.ini`

3. **Restart OpenLiteSpeed** to apply changes:
   ```bash
   bash xshok-admin.sh --restart
   ```

## Common Settings to Customize

### Memory and Execution Time
```ini
max_execution_time = 300        # Maximum script execution time in seconds
max_input_time = 300            # Maximum input parsing time in seconds
memory_limit = 256M             # Maximum memory a script can use
```

### File Uploads
```ini
upload_max_filesize = 64M       # Maximum size of uploaded files
post_max_size = 64M             # Maximum size of POST data
max_file_uploads = 20           # Maximum number of files per upload
```

### Error Reporting (for development)
```ini
display_errors = On             # Show errors on screen (Off for production)
error_reporting = E_ALL         # Report all errors
```

### OPcache Settings
```ini
opcache.enable = 1              # Enable OPcache
opcache.memory_consumption = 128 # OPcache memory in MB
opcache.max_accelerated_files = 10000  # Maximum cached files
```

### Session Settings
```ini
session.save_handler = redis    # Use Redis for session storage
session.save_path = "tcp://redis:6379"  # Redis connection
```

## Notes

- Changes to `php.ini` files are persistent and will survive container restarts
- Each PHP version has its own configuration file
- The configuration files override the default PHP settings
- For PHP 8.0+, JIT compilation is enabled by default
- Sessions are configured to use Redis for better performance and scalability
