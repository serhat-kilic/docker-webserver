#!/usr/bin/env bash
################################################################################
# Configuration Verification Script
# This is property of eXtremeSHOK.com
# Copyright (c) Adrian Jon Kriel :: admin@extremeshok.com
################################################################################
#
# Verifies that configuration files are properly set up and mounted
#
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==================================${NC}"
echo -e "${BLUE}Configuration Verification Script${NC}"
echo -e "${BLUE}==================================${NC}"
echo ""

# Check if .env exists
if [ ! -f ".env" ]; then
    echo -e "${RED}✗${NC} .env file not found"
    echo -e "  Run: ${YELLOW}bash xshok-admin.sh --start${NC} to initialize"
    exit 1
else
    echo -e "${GREEN}✓${NC} .env file exists"
fi

# Get PHP version from .env
if [ -f ".env" ]; then
    source .env
    PHP_VER="${PHP_VERSION:-74}"
    echo -e "${GREEN}✓${NC} Current PHP version: ${YELLOW}${PHP_VER}${NC} (PHP ${PHP_VER:0:1}.${PHP_VER:1})"
else
    PHP_VER="74"
    echo -e "${YELLOW}!${NC} Using default PHP version: 7.4"
fi

echo ""
echo -e "${BLUE}Checking PHP Configuration Files:${NC}"

# Check PHP config files
for version in 74 80 81 82 83 84; do
    php_ini="data/etc/php/${version}/php.ini"
    if [ -f "$php_ini" ]; then
        size=$(stat -f%z "$php_ini" 2>/dev/null || stat -c%s "$php_ini" 2>/dev/null)
        if [ "$version" = "$PHP_VER" ]; then
            echo -e "${GREEN}✓${NC} $php_ini ${GREEN}(ACTIVE)${NC} - ${size} bytes"
        else
            echo -e "${GREEN}✓${NC} $php_ini - ${size} bytes"
        fi
    else
        echo -e "${RED}✗${NC} $php_ini ${RED}NOT FOUND${NC}"
    fi
done

echo ""
echo -e "${BLUE}Checking Other Configuration Files:${NC}"

# Check MySQL config
mysql_configs=("my-2gb.cnf" "my-4gb.cnf" "my-16gb.cnf" "my-32gb.cnf")
for config in "${mysql_configs[@]}"; do
    mysql_conf="data/etc/mysql/conf.d/${config}"
    if [ -f "$mysql_conf" ]; then
        echo -e "${GREEN}✓${NC} $mysql_conf exists"
    else
        echo -e "${RED}✗${NC} $mysql_conf ${RED}NOT FOUND${NC}"
    fi
done

# Check Redis config
redis_conf="data/etc/redis/redis.conf"
if [ -f "$redis_conf" ]; then
    echo -e "${GREEN}✓${NC} $redis_conf exists"
else
    echo -e "${RED}✗${NC} $redis_conf ${RED}NOT FOUND${NC}"
fi

echo ""
echo -e "${BLUE}Checking Documentation Files:${NC}"

# Check documentation
docs=("data/etc/php/README.md" "data/etc/openlitespeed/README.md" "CONFIGURATION.md")
for doc in "${docs[@]}"; do
    if [ -f "$doc" ]; then
        echo -e "${GREEN}✓${NC} $doc exists"
    else
        echo -e "${YELLOW}!${NC} $doc not found"
    fi
done

echo ""
echo -e "${BLUE}Checking Docker Compose Configuration:${NC}"

# Check if docker-compose.yml has the PHP mount
if grep -q "data/etc/php" docker-compose.yml; then
    echo -e "${GREEN}✓${NC} PHP config mount found in docker-compose.yml"
else
    echo -e "${RED}✗${NC} PHP config mount ${RED}NOT FOUND${NC} in docker-compose.yml"
fi

echo ""
echo -e "${BLUE}Checking Volume Directories:${NC}"

# Check volumes directory
volumes_dirs=("www-vhosts" "www-conf" "mysql" "mysql-backup" "redis" "acme" "unbound-keys")
for vol_dir in "${volumes_dirs[@]}"; do
    if [ -d "volumes/${vol_dir}" ]; then
        echo -e "${GREEN}✓${NC} volumes/${vol_dir} exists"
    else
        echo -e "${YELLOW}!${NC} volumes/${vol_dir} not found (will be created on first run)"
    fi
done

echo ""
echo -e "${BLUE}Container Status:${NC}"

# Check if containers are running
if command -v docker-compose &> /dev/null; then
    if docker-compose ps | grep -q "Up"; then
        echo -e "${GREEN}✓${NC} Docker containers are running"
        
        # Check if PHP config is mounted inside container
        echo ""
        echo -e "${BLUE}Verifying PHP Config Inside Container:${NC}"
        if docker-compose exec -T openlitespeed test -f "/usr/local/lsws/lsphp${PHP_VER}/etc/php.ini" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} PHP config successfully mounted at /usr/local/lsws/lsphp${PHP_VER}/etc/php.ini"
        elif docker-compose exec -T openlitespeed test -f "/usr/local/lsws/lsphp${PHP_VER}/etc/php/${PHP_VER}/litespeed/php.ini" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} PHP config successfully mounted at /usr/local/lsws/lsphp${PHP_VER}/etc/php/${PHP_VER}/litespeed/php.ini"
        else
            echo -e "${YELLOW}!${NC} Could not verify PHP config mount (container might need restart)"
        fi
            
        # Show which php.ini is being loaded
        echo ""
        echo -e "${BLUE}Loaded PHP Configuration File:${NC}"
        docker-compose exec -T openlitespeed php --ini 2>/dev/null | grep -E "Loaded Configuration File" || echo -e "${YELLOW}Could not retrieve loaded php.ini${NC}"
            
        # Show some key PHP settings
        echo ""
        echo -e "${BLUE}Current PHP Settings (from container):${NC}"
        docker-compose exec -T openlitespeed php -i 2>/dev/null | grep -E "^(memory_limit|upload_max_filesize|post_max_size|max_execution_time)" | head -4 || echo -e "${YELLOW}Could not retrieve PHP settings${NC}"
    else
        echo -e "${YELLOW}!${NC} Docker containers are not running"
        echo -e "  Run: ${YELLOW}bash xshok-admin.sh --start${NC}"
    fi
else
    echo -e "${YELLOW}!${NC} docker-compose not found or not in PATH"
fi

echo ""
echo -e "${BLUE}==================================${NC}"
echo -e "${GREEN}Verification Complete!${NC}"
echo -e "${BLUE}==================================${NC}"
echo ""
echo -e "To customize your PHP settings:"
echo -e "  1. Edit: ${YELLOW}data/etc/php/${PHP_VER}/php.ini${NC}"
echo -e "  2. Restart: ${YELLOW}bash xshok-admin.sh --restart${NC}"
echo ""
echo -e "For more information, see: ${YELLOW}CONFIGURATION.md${NC}"
echo ""
