#!/bin/bash

# Adjust Firewall
sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 3306 proto tcp

# Install MySQL Server in a Non-Interactive mode. Default root password will be "root"

sudo apt-get update
sleep 30
sudo apt-get -y install mysql-server-5.7
sleep 90


# Update config, create password for root, and new user

sudo sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /etc/mysql/my.cnf
sudo sed -i '/skip-external-locking/a disabled_storage_engines="MyISAM,FEDERATED"' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo mysql -e "SET PASSWORD FOR root@localhost = PASSWORD('root');FLUSH PRIVILEGES;"
sudo mysql -uroot -proot -e "CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password';GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost';FLUSH PRIVILEGES;"
sudo mysql -uadmin -ppassword -e "CREATE DATABASE migrateddb;"
sudo mysql -uroot -proot -e "ALTER USER admin@localhost PASSWORD EXPIRE;"
sudo service mysql restart

echo "MySQL restarted"
sudo mkdir /backup

wget -O /backup/localdb.sql https://github.com/azureossd/mysql-1/raw/master/localdb.sql
