#!/bin/bash
# user data file for standalone mysql server

# installing mysql-server and sysbench
apt-get update
apt-get install mysql-server sysbench -y

# loading sakila database in mysql
cd ~
wget https://downloads.mysql.com/docs/sakila-db.tar.gz
tar -xvf sakila-db.tar.gz
rm sakila-db.tar.gz

sudo mysql -u root -e "SOURCE ~/sakila-db/sakila-schema.sql;SOURCE ~/sakila-db/sakila-data.sql;"

rm ~/sakila-db.tar.gz