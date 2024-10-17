#!/bin/bash

sudo apt-get update
sudo apt-get install -y wget lsb-release gnupg
wget https://dev.mysql.com/get/mysql-apt-config_0.8.22-1_all.deb
sudo dpkg -i mysql-apt-config_0.8.22-1_all.deb
sudo apt-get update
# sudo apt-get install -y mysql-server
sudo apt-get install -y mysql-server=8.0.39-0ubuntu0.20.04.1

### Check the installed MySQL
mysql --version

sudo systemctl start mysql
sudo systemctl enable mysql

MYSQL_ROOT_PASSWORD="newpassword"
MYSQL_USER="petclinic"
MYSQL_PASSWORD="petclinic"
MYSQL_DATABASE="information_schema"

### Run SQL commands to create a user and a database
sudo mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'localhost';
FLUSH PRIVILEGES;
EOF


: << '#AlternativeSettngUpMySQL'
### Команда 'mysql_secure_installation' предназначена для настройки безопасности MySQL, включая установку пароля для пользователя root, удаление анонимных пользователей и другие параметры безопасности. В данном случае устанавливается пароль для пользователя root как PetClinic, вместо уже установленной MYSQL_ROOT_PASSWORD.

sudo mysql_secure_installation <<EOF

y
PetClinic
PetClinic
y
y
y
y
EOF
#AlternativeSettngUpMySQL