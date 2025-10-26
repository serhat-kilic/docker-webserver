# OpenLiteSpeed Configuration

This directory can be used to store custom OpenLiteSpeed configuration files.

## Overview

The OpenLiteSpeed configuration is primarily managed through:
1. The web admin interface at `https://your-server:7080`
2. Configuration files mounted in `/etc/openlitespeed` inside the container
3. The main configuration directory is already mounted via docker-compose volumes

## Configuration Location

The main OpenLiteSpeed configuration directory is mounted at:
- **Host**: `volumes/www-conf/`
- **Container**: `/etc/openlitespeed/`

## Important Configuration Files

After the first run, you'll find these files in `volumes/www-conf/`:

- `httpd_config.conf` - Main server configuration
- `admin/` - Admin interface configuration
- `conf/` - Virtual host configurations
- `logs/` - Log files

## How to Customize

### Method 1: Web Admin Interface (Recommended)
1. Access the web admin at `https://your-server:7080`
2. Login with credentials (set via `bash xshok-admin.sh --password`)
3. Make changes through the GUI
4. Graceful restart: `bash xshok-admin.sh --restart`

### Method 2: Direct Configuration File Editing
1. Edit files in `volumes/www-conf/`
2. Test configuration syntax
3. Graceful restart: `bash xshok-admin.sh --restart`

## Common Customizations

### Increase Worker Processes
Edit `volumes/www-conf/httpd_config.conf` and modify:
```
maxConnections              10000
maxSSLConnections           5000
```

### Add Custom MIME Types
Edit `volumes/www-conf/conf/mime.properties`

### Custom Error Pages
Place custom error pages in `volumes/www-vhosts/your-domain/html/`

### Enable/Disable Modules
Edit `volumes/www-conf/conf/httpd_config.conf`

## Best Practices

1. **Always backup** configuration files before making changes
2. **Test in development** before applying to production
3. **Use graceful restart** to apply changes without downtime
4. **Monitor logs** in `volumes/www-conf/logs/` after changes
5. **Document your changes** for future reference

## Tips

- Changes made through the web admin interface are automatically persisted
- Manual configuration file changes require a restart to take effect
- Virtual host configurations are managed by the `xshok-admin.sh` script
- The web admin password can be reset with: `bash xshok-admin.sh --password`

## Additional Resources

- [OpenLiteSpeed Documentation](https://openlitespeed.org/kb/)
- [LiteSpeed Web Server Wiki](https://www.litespeedtech.com/support/wiki)
