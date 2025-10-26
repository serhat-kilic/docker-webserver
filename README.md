# docker-webserver
Our optimized production web-server setup based on docker
* openlitespeed + **Multi-PHP Support (PHP 7.4, 8.0, 8.1, 8.2, 8.3, 8.4)** + letsencrypt ssl + mariadb(mysql) + redis + memcached

## This setup is used for most of our web servers and has been used for more than 6 years.
* We have near or perfect scores for all the major webpage and performance tests
* There are literally thousands of sites using this setup, everything from online shops with more than 35 000 active customers to a simple blogs and forums.
* In 2020 nginx + php-fpm was replaced with openlitespeed due to the massive performance advantage wordpress has with lscache.
* Everything is optimized and the config values used are derived by years of testing, tweaking and observing real world data.

![Full Docker Visualization](docker-vis-full.png)

### used dockers:
* [extremeshok/unbound](https://hub.docker.com/repository/docker/extremeshok/unbound) **caching dns**
* [extremeshok/openlitespeed-php](https://hub.docker.com/repository/docker/extremeshok/openlitespeed-php) **optimised openlitespeed with php webserver**
* [extremeshok/acme-http2https](https://hub.docker.com/repository/docker/extremeshok/acme-http2https) **generates letsencrypt certificates and forwards all http to httpS**
* containrrr/watchtower **autoupdates docker containers**
* mariadb:10.5 **mysql, but better**
* tiredofit/db-backup **backup mysql databases every 1 hour**
* bitnami/phpmyadmin **webbased database admin**
* redis **caching store**
* memcached **caching store**
* robbertkl/ipv6nat **ipv6nat**

### Benefits
* optimized
* vhosts (host multiple independent domains)
* hourly mysql database backups
* simple management
* automatic updates for wordpress
* fully integrated
* stable
* quickly backup and restore databases
* webserver file permissions and owenership are corrected on startup (non blocking)

### Why ?
* administration via a single shell command
* webinterfaces are so 2000;s
* optimized out of the box
* a user can host multiple websites
* low resource usage
* quick to bootstrap
* ubuntu + docker

### Recommended setup:
* VM / VPS (as a rule, always run a vm instead of baremetal, makes it easy to upgrade and do maintenance)
* Fresh/clean UBUNTU LTS configured with the xshok-ubuntu-docker-host.sh script https://github.com/extremeshok/xshok-docker
* Project run from the /datastore dir.

### Notes:
* .env is generated on first install, as the passwords are always randomised.
* there is no need to configure or edit the docker-compose.yml
* all administration is done via xshok-admin.sh
* files are saved into the volumes dir
* restoring sql files, a temporary filtered sql file is created with the create database, alter database, drop database and use statements removed

### Multi-PHP Support:
This setup supports multiple PHP versions (7.4, 8.0, 8.1, 8.2, 8.3, 8.4) via the official LiteSpeed Docker images. You can select your desired PHP version by:

1. **Before first installation**, edit the `default.env` file:
   ```bash
   # Set your desired PHP version
   PHP_VERSION=82  # for PHP 8.2
   ```
   Available versions: `74` (7.4), `80` (8.0), `81` (8.1), `82` (8.2), `83` (8.3), `84` (8.4)

2. **After installation**, edit the `.env` file and modify the `PHP_VERSION` variable, then restart:
   ```bash
   # Stop the services
   bash xshok-admin.sh --down
   
   # Edit .env and change PHP_VERSION
   nano .env  # Change PHP_VERSION=74 to your desired version
   
   # Start the services
   bash xshok-admin.sh --start
   ```

3. **Advanced**: You can also manually specify the image and tag in `.env`:
   ```bash
   OPENLITESPEED_IMAGE=litespeedtech/openlitespeed
   OPENLITESPEED_TAG=1.8.4-lsphp82
   ```

**Important Notes:**
* The setup now uses `litespeedtech/openlitespeed` (official) instead of `extremeshok/openlitespeed-php` for multi-PHP support
* Changing PHP versions will affect all websites on the server
* Make sure your applications are compatible with the selected PHP version before switching
* When upgrading PHP versions, test thoroughly in a development environment first

**For existing users upgrading from extremeshok/openlitespeed-php:**
* The new setup uses the official LiteSpeed image which has slightly different paths/configuration
* To continue using the old image, add these lines to your `.env` file (or `default.env` before first installation):
  ```bash
  OPENLITESPEED_IMAGE=extremeshok/openlitespeed-php
  OPENLITESPEED_TAG=latest
  ```
* It's recommended to backup your data before switching between images

### Configuration Management:
This setup allows you to customize PHP, LiteSpeed, MySQL, and Redis configurations locally. All configuration files persist across container restarts.

#### PHP Configuration
Each PHP version has its own customizable `php.ini` file located in `data/etc/php/[VERSION]/php.ini`:
* `data/etc/php/74/php.ini` - PHP 7.4 configuration
* `data/etc/php/80/php.ini` - PHP 8.0 configuration
* `data/etc/php/81/php.ini` - PHP 8.1 configuration
* `data/etc/php/82/php.ini` - PHP 8.2 configuration
* `data/etc/php/83/php.ini` - PHP 8.3 configuration
* `data/etc/php/84/php.ini` - PHP 8.4 configuration

**To customize PHP settings:**
1. Edit the appropriate `php.ini` file for your PHP version (check `PHP_VERSION` in `.env`)
2. Modify settings like `memory_limit`, `upload_max_filesize`, `max_execution_time`, etc.
3. Restart OpenLiteSpeed to apply changes: `bash xshok-admin.sh --restart`

Common settings you might want to customize:
```ini
memory_limit = 256M                # Maximum memory per script
upload_max_filesize = 64M          # Maximum upload file size
max_execution_time = 300           # Maximum script execution time
post_max_size = 64M                # Maximum POST data size
```

See `data/etc/php/README.md` for more details and examples.

#### OpenLiteSpeed Configuration
OpenLiteSpeed configuration files are stored in `volumes/www-conf/` (mounted from `/etc/openlitespeed/` in the container).

**To customize LiteSpeed settings:**
1. **Recommended**: Use the web admin interface at `https://your-server:7080`
   - Set password first: `bash xshok-admin.sh --password`
2. **Alternative**: Edit files directly in `volumes/www-conf/`
3. Apply changes: `bash xshok-admin.sh --restart`

See `data/etc/openlitespeed/README.md` for more details.

#### MySQL Configuration
MySQL configuration files are in `data/etc/mysql/conf.d/`:
* Uncomment/comment different configurations in `docker-compose.yml` based on your RAM
* Available configs: `my-2gb.cnf`, `my-4gb.cnf`, `my-16gb.cnf`, `my-32gb.cnf`

#### Redis Configuration
Redis configuration is located at `data/etc/redis/redis.conf`
* Edit this file to customize Redis settings
* Restart to apply: `bash xshok-admin.sh --restart`

**Important:** All configuration changes persist across container restarts and updates.

**For detailed configuration management guide, troubleshooting, and best practices, see [CONFIGURATION.md](CONFIGURATION.md)**

### Recommended VM:
2 vcpu, 4GB ram (2GB can be used), NVME storage (webservers need nvme, sata ssd is too slow and hdd is pointless)

### Usage / Installation
* Download and place the files into /datastore
* start servers
``` bash xshok-admin.sh --start ```
* start servers at boot
``` bash xshok-admin.sh --boot ```
* set a password for the litespeed weadmin https://hostname:7080
``` bash xshok-admin.sh --password ```
* add a FQDN domain, create a database and generate a letsencrypt ssl
``` bash xshok-admin.sh --qa fqdn.com ```
* restart litespeed to apply the changes
``` bash xshok-admin.sh --restart ```

# xshok-admin.sh
used to control and manage the webserver, add domains, databases, ssl etc.
```
eXtremeSHOK.com Webserver
WEBSITE OPTIONS
   -wl | --website-list
       list all websites
   -wa | --website-add [domain_name]
       add a website
   -wd | --website-delete [domain_name]
       delete a website
   -wp | --website-permissions [domain_name]
       fix permissions and ownership of a website
DATABASE OPTIONS
   -dl | --database-list [domain_name]
       list all databases for domain
   -da | --database-add [domain_name]
       add a database to domain, database name, user and pass autogenerated
   -dd | --database-delete [database_name]
       delete a database
   -dp | --database-password [database_name]
       reset the password for a database
   -dr | --database-restore [database_name] [/your/path/file_name]
       restore a database backup file to database_name, supports .gz and .sql
BACKUP OPTIONS
   -ba | --backup-all [/your/path]*optional*
       backup all databases, optional backup path, file will use the default sql/databasename.sql.gz
   -bd | --backup-database [database_name] [/your/path/file_name]*optional*
       backup a database, optional backup filename, will use the default sql/databasename.sql.gz if not specified
SSL OPTIONS
   -sl | --ssl-list
       list all ssl
   -sa | --ssl-add [domain_name]
       add ssl to a website
   -sd | --ssl-delete [domain_name]
       delete ssl from a website
QUICK OPTIONS
   -qa | --quick-add [domain_name]
       add website, database, ssl, restart server
ADVANCED OPTIONS
   -wc | --warm-cache [domain_name]
       loads a website sitemap and visits each page, used to warm the cache
GENERAL OPTIONS
   --up | --start | --init
       start xshok-webserver (will launch docker-compose.yml)
   --down | --stop
       stop all dockers and docker-compose
   -r | --restart
       gracefully restart openlitespeed with zero down time
   -b | --boot | --service | --systemd
       creates a systemd service to start docker and run docker-compose.yml on boot
   -p | --password
       generate and set a new web-admin password
   -e | --env
       generate a new .env from the default.env
   -H, --help
      Display help and exit.

```

![No volumes Docker Visualization](docker-vis-novols.png)
