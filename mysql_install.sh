#!/bin/bash

# Adjust Firewall
sudo ufw all 3306

# Install MySQL Server in a Non-Interactive mode. Default root password will be "root"
echo "mysql-server-5.7 mysql-server/root_password password root" | sudo debconf-set-selections
echo "mysql-server-5.7 mysql-server/root_password_again password root" | sudo debconf-set-selections
sudo apt-get -y install mysql-server-5.7


# Update config, create password for root, and new user

sudo sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /etc/mysql/my.cnf
sudo sed -i '/skip-external-locking/a disabled_storage_engines="MyISAM,FEDERATED"' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo mysql -e "SET PASSWORD FOR root@localhost = PASSWORD('root');FLUSH PRIVILEGES;"
sudo mysql -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
sudo mysql -e "DROP DATABASE test;DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';"
sudo mysql -u root -proot -e "CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password';GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost';FLUSH PRIVILEGES;"
sudo mysql -u admin -ppassword -e "CREATE DATABASE migrateddb;"
sudo mysql -u root -proot -e "ALTER USER admin PASSWORD EXPIRE;"
sudo service mysql restart

wget -O ~/localdb.sql https://github.com/azureossd/mysql-1/raw/master/localdb.sql
