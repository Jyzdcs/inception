#!/bin/bash

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

mysqld_safe &

until mysqladmin ping --socket=/run/mysqld/mysqld.sock --silent 2>/dev/null; do
    sleep 0.3
done

mysql << EOF
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
SHOW DATABASES;
EOF

mysqladmin -u root -p${SQL_ROOT_PASSWORD} shutdown

exec mysqld