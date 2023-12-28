#!/bin/bash

# Update and install required packages
sudo apt-get update
sudo apt-get -y install mysql-server mysql-client mysql-common

# Installing MySQL Cluster Data Node
wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-7.6/mysql-cluster-community-data-node_7.6.6-1ubuntu18.04_amd64.deb
dpkg -i mysql-cluster-community-data-node_7.6.6-1ubuntu18.04_amd64.deb
rm mysql-cluster-community-data-node_7.6.6-1ubuntu18.04_amd64.deb

# Create MySQL data directory
sudo mkdir -p /usr/local/mysql/data

# Start the MySQL Cluster Data Node
sudo /usr/local/mysql-cluster/bin/ndbd

# Configure MySQL Cluster connection string in /etc/my.cnf
echo "[mysql_cluster]" | sudo tee -a /etc/my.cnf
echo "ndb-connectstring=ip-172-31-1-1.ec2.internal" | sudo tee -a /etc/my.cnf

# Start MySQL Server
sudo service mysql start


# ADD SAKILA DATABASE
# loading sakila database in mysql
cd ~
wget https://downloads.mysql.com/docs/sakila-db.tar.gz
tar -xvf sakila-db.tar.gz
rm sakila-db.tar.gz

sudo mysql -u root -e "SOURCE ~/sakila-db/sakila-schema.sql;SOURCE ~/sakila-db/sakila-data.sql;"

rm ~/sakila-db.tar.gz



# You can add any additional configuration or setup steps here if needed
#sudo su
#mysql
#CREATE USER 'achraf'@'localhost' IDENTIFIED BY 'achraf';
#GRANT ALL PRIVILEGES ON *.* TO 'achraf'@'localhost' WITH GRANT OPTION;
#FLUSH PRIVILEGES;
#exit
sudo mysql -e "CREATE USER 'achraf'@'localhost' IDENTIFIED BY 'achraf';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'achraf'@'localhost' WITH GRANT OPTION;"
sudo mysql -e "FLUSH PRIVILEGES;"