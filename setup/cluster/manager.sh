#!/bin/bash

# Update and install required packages
apt update
apt install git dos2unix libaio1 libmecab2 sysbench expect libncurses5 libtinfo5 wget -y

# Install MySQL Cluster Management Server
wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-8.0/mysql-cluster-community-management-server_8.0.31-1ubuntu20.04_amd64.deb
dpkg -i mysql-cluster-community-management-server_8.0.31-1ubuntu20.04_amd64.deb


#create MySQL Cluster config directory
mkdir /var/lib/mysql-cluster
touch /var/lib/mysql-cluster/config.ini

# Create a MySQL Cluster config file (config.ini)
cat <<EOF | dos2unix > /var/lib/mysql-cluster/config.ini
[ndbd default]
# Options affecting ndbd processes on all data nodes:
NoOfReplicas=3    # Number of replicas

[ndb_mgmd]
# Management process options:
hostname=ip-172-31-1-1.ec2.internal # Hostname of the manager
datadir=/var/lib/mysql-cluster    # Directory for the log files
NodeId=1

[ndbd]
hostname=ip-172-31-1-2.ec2.internal # Hostname/IP of the first data node
NodeId=2            # Node ID for this data node
datadir=/var/lib/mysql-cluster/data    # Remote directory for the data files

[ndbd]
hostname=ip-172-31-1-3.ec2.internal # Hostname/IP of the second data node
NodeId=3            # Node ID for this data node
datadir=/var/lib/mysql-cluster/data    # Remote directory for the data files

[ndbd]
hostname=ip-172-31-1-4.ec2.internal # Hostname/IP of the third data node
NodeId=4            # Node ID for this data node
datadir=/var/lib/mysql-cluster/data    # Remote directory for the data files

[mysqld]
# SQL node options:
hostname=ip-172-31-1-1.ec2.internal # MySQL server/client on the same instance as the cluster manager
NodeId=11
EOF

touch /etc/systemd/system/ndb_mgmd.service
# Create a MySQL Cluster config file (config.ini)
cat <<EOF | dos2unix > //etc/systemd/system/ndb_mgmd.service
[Unit]
Description=MySQL NDB Cluster Management Server
After=network.target auditd.service

[Service]
Type=forking
ExecStart=/usr/sbin/ndb_mgmd -f /var/lib/mysql-cluster/config.ini
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

# Start MySQL Cluster Manager
systemctl enable ndb_mgmd
systemctl start ndb_mgmd

# Install MySQL Server
# installing mysql-server and sysbench
apt-get update
apt-get install mysql-server sysbench -y

# C

# Securing MySQL installation
mysql_secure_installation <<EOF
tp3
tp3
y
y
y
y
EOF

# Start MySQL Server
systemctl enable mysql
systemctl start mysql

# Setup for MySQL Cluster Management Server complete

# ADD SAKILA DATABASE
# loading sakila database in mysql
cd ~
wget https://downloads.mysql.com/docs/sakila-db.tar.gz
tar -xvf sakila-db.tar.gz
rm sakila-db.tar.gz

sudo mysql -u root -e "SOURCE ~/sakila-db/sakila-schema.sql;SOURCE ~/sakila-db/sakila-data.sql;"

rm ~/sakila-db.tar.gz

# You can add any additional configuration or setup steps here if needed
sudo su
mysql
CREATE USER 'achraf'@'localhost' IDENTIFIED BY 'achraf';
GRANT ALL PRIVILEGES ON *.* TO 'achraf'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
exit
