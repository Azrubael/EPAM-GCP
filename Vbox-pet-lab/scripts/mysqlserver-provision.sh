#!/bin/bash

set -e  # Stop the script if an error happened

sudo apt-get update

echo
echo "### [1] -- Installind dependencies"
sudo apt-get install -y wget lsb-release gnupg

echo
echo "### [2] -- Downloading MySQL APT config..."
wget https://dev.mysql.com/get/mysql-apt-config_0.8.22-1_all.deb

echo
echo "### [3] -- Installing MySQL APT config..."
sudo dpkg -i mysql-apt-config_0.8.22-1_all.deb
sudo apt-get update

echo
echo "### [4] -- Installing MySQL Server..."
# sudo apt-get install -y mysql-server
sudo apt-get install -y mysql-server=8.0.39-0ubuntu0.20.04.1

echo
echo
echo "### [5] -- Checking the MySQL version"
mysql --version

echo
echo "### [6] -- Starting MySQL as a service..."
sudo systemctl start mysql
sudo systemctl enable mysql


echo
echo "### [7] -- Run SQL commands to create a user and a database"
MYSQL_ROOT_PASSWORD="newpassword"
MYSQL_USER="petclinic"
MYSQL_PASSWORD="petclinic"
MYSQL_DATABASE="information_schema"

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