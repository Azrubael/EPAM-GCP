#!/bin/bash

set -e  # Stop the script if an error happened

sudo apt-get update

echo
echo "### [1] -- Installing MySQL 8.0 dependencies"
sudo apt-get install -y wget lsb-release gnupg

echo
echo "### [2] -- Installing MySQL Server..."
sudo apt-get install -y mysql-server

echo
echo "### [3] -- Checking the MySQL version..."
mysql --version

echo
echo "### [4] -- Loading the environment..."
source /home/vagrant/mysqlserver.env


echo
echo "### [5] -- Starting MySQL as a service..."
sudo systemctl start mysql
sudo systemctl enable mysql


echo
echo "### [6] -- Run SQL commands to create a user and a database"
# MYSQL_ROOT_PASSWORD=""
# MYSQL_ALLOW_EMPTY_PASSWORD=true
# MYSQL_USER="petclinic"
# MYSQL_PASSWORD="petclinic"
# MYSQL_DATABASE="information_schema"

sudo mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'localhost';
FLUSH PRIVILEGES;
EOF


echo
echo "### [7] -- MySQL service status"
sudo systemctl status mysql
