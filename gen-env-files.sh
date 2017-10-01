#!/bin/bash
export OWNCLOUD_ADMIN_PASSWORD=$1
export OWNCLOUD_DB_PASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32;echo;)
export MYSQL_ROOT_PASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32;echo;)

test -f .env-owncloud-owncloud || cat << EOF > .env-owncloud-owncloud 
OWNCLOUD_DB_TYPE=mysql
OWNCLOUD_DB_NAME=owncloud
OWNCLOUD_DB_USERNAME=owncloud
OWNCLOUD_DB_PASSWORD=${OWNCLOUD_DB_PASSWORD}
OWNCLOUD_DB_HOST=db
OWNCLOUD_ADMIN_USERNAME=admin
OWNCLOUD_ADMIN_PASSWORD=${OWNCLOUD_ADMIN_PASSWORD}
OWNCLOUD_REDIS_ENABLED=true
OWNCLOUD_REDIS_HOST=redis
EOF

test -f .env-owncloud-mariadb || cat << EOF > .env-owncloud-mariadb 
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
MYSQL_USER=owncloud
MYSQL_PASSWORD=${OWNCLOUD_DB_PASSWORD}
MYSQL_DATABASE=owncloud
EOF
