#!/bin/bash

set -e

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

INIT_FILE=""

if [ ! -d  /var/lib/mysql/mysql ] ; then
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql
	cat > tmp/init.sql <<EOF
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$(cat /run/secrets/db_password)';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '$(cat /run/secrets/db_root_password)';
FLUSH PRIVILEGES;
EOF
fi

INIT_FILE="--init-file=/tmp/init.sql"

exec mariadbd --user=mysql $INIT_FILE
