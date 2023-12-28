#!/bin/bash
# user data file for standalone mysql server

# Installing required packages
sudo apt-get update
sudo apt-get install python3 -y
wget https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py
sudo pip3 install --ignore-installed blinker
sudo pip3 install flask
sudo pip3 install sshtunnel
sudo pip3 install mysql-connector-python
sudo pip3 install pandas
sudo pip3 install pymysql
sudo pip3 install pythonping




# Python Script Setup
cd ~

# KEy


touch /home/ubuntu/proxy.py
echo """
from flask import Flask, request, jsonify
import mysql.connector
from sshtunnel import SSHTunnelForwarder
import os
import pandas as pd
import pymysql
import time
import pythonping
import random
import json

app = Flask(__name__)

# SSH tunnel configuration
cluster = {
    'manager': '172.31.1.1',
    'node1': '172.31.1.2',
    'node2': '172.31.1.3',
    'node3': '172.31.1.4',

}

mysql_config = {
    'user': 'root',
    'password': 'root',
    'database': 'sakila',
}

def create_ssh_tunnel(node):
  print('Creating tunnel...')
  tunnel = SSHTunnelForwarder((cluster[node], 22),ssh_username='ubuntu',ssh_pkey='/home/ubuntu/key_pair_tp3.pem',local_bind_address=('127.0.0.1', 3306),  remote_bind_address=('127.0.0.1', 3306))
  tunnel.start()

  print('Tunnel creation successful!')

  return tunnel

def create_connection_to_db(hostip):
    print('Querying at ' + hostip + '...')

    connection = pymysql.connect(host='localhost',user='achraf',password='achraf',db='sakila',port=3306)
    print('Connection sucessful!')
    return connection


def get_best_server():
    best_server = list(cluster.keys())[0]
    best_time = 1000

    print('Pinging all servers...')
    for host in list(cluster.keys()):
        result = pythonping.ping(cluster[host], count=1, timeout=5)

        if not(result.packet_loss) and result.rtt_avg_ms < best_time:
            print(host + ' - time: ' + str(result.rtt_avg_ms) + ' ms')
            best_server = host
            best_time = result.rtt_avg_ms

    print(best_server + ' is the best server.')
    return best_server

@app.route('/direct', methods=['POST'])
def direct():
    tunnel = create_ssh_tunnel('manager')
    time.sleep(20)
    connection = create_connection_to_db('manager')
    query = request.json.get('query')
    data = pd.read_sql_query(query, connection)
    connection.close()
    tunnel.close()
    print(data)
    return jsonify(json.loads(data.to_json(orient='records')))


@app.route('/random', methods=['POST'])
def random_hit():
    query = request.json.get('query')
    if 'SELECT' not in query:
      host = 'manager'
    else:
      nodes = list(cluster.keys())[1:]
      # Select a random node
      host = random.choice(nodes)

    tunnel = create_ssh_tunnel(host)
    time.sleep(20)
    connection = create_connection_to_db(host)

    data = pd.read_sql_query(query, connection)
    connection.close()
    tunnel.close()
    print(data)
    return jsonify(json.loads(data.to_json(orient='records')))

@app.route('/custom', methods=['POST'])
def custom():
    query = request.json.get('query')
    if 'SELECT' not in query:
      host = 'manager'
    else:
      host = get_best_server()
    print('best host is', host)
    tunnel = create_ssh_tunnel(host)
    time.sleep(20)
    connection = create_connection_to_db(host)
    data = pd.read_sql_query(query, connection)
    connection.close()
    tunnel.close()
    print(data)
    return jsonify(json.loads(data.to_json(orient='records')))


@app.route('/', methods=['GET'])
def home():
    return jsonify(result='hello')

if __name__ == '__main__':
    app.run(host='0.0.0.0',debug=True, port=80)
""" | tee /home/ubuntu/proxy.py


cat <<EOL > /home/ubuntu/key_pair_tp3.pem
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAscyaaX1YZdfkQNNhnjEEgQaVRVOaAI5Sj9sgB02kqs+Z6z16
xI9rlHYzRvhvAsqXUStmXsJvrSq3NwlPcqfS7N6XSZdlRXzS91m0tzgJP/eX5lEe
q6QiCfyS3bnpDpCOrfy1e3cCTPo1pmMIvTVTWNhzbocaK06JyjFWZIGjpTX11T4o
DVVg8jyRJH5QlrNBo2+fBe2X6HmoOevRjgWFGdzTY7RTw96yyn/LxAu1cjejJquQ
X+vZnzHelBZyWiTu3ZCJqISwPuEQVFj/X1RFrxjVWkZdPDdyPtNBkWRN0qOUbLoJ
0BojIbck1F7ZmXPCeIBpiYOl6emVngBKKwH0UQIDAQABAoIBAEwhjeSplVZWcRgI
6v2vg3wz82qx93lRd6y9aSN3bZDuP7vooU7VEn2Jdz9mVTJeyRgqezUMEIGXjsf0
Jp6zma9vSFxshSKR5kufj6/8QImxXMtz5KweJa0dB04FsvNXlqCNWrA5LzUC1kIe
mblawguC8zpagywT/xAivBlhIU816udoHYzepmXhXrp154KINfdT1lPlurTIK9cS
1GEmy5s8FeegwqqUgg8EjMI0iSSNk8QeBhDlijsDs9LYv66L9UZlfMmuQkxuJtY9
rK51Gm2eK8hgOj66uh1UDckBwMfw5rko35+TI0KQ53LVV9S9vhcJWTKgwrzlDlBO
tQ+hiYECgYEA3kgY3A5KkKZvttfhbHqIwhWWkELMoe2DpUdiFmFu8CwzWOGexmbZ
lkCymrNmdII/dpsxtGynflyKsYbT7DnQT//V6v2uMDhVhoAYgS0afjfbbEjA76oc
NJ1A5ONlgaRmHUJsny/NfX3AT45L5ECXN91vvmuxFPof6ckwDK3eOLkCgYEAzMUc
7ojm6d8GFS2uaCW6pmJjq6NKR+8Alo8TolxX/lAige/E2bncEmqdX2tiyrv7YdxE
p3flUxmCrX5pfbi8qC+uEw/Q73ra1tbIijNN2/LdWrRS9K/RtFWrcG3+tVJxE07e
pF5V7SDaFA7pR6/8m+6BjM+toAwD4Yh3OiDsHFkCgYBuac2/cXHkjGgtoOqe4fcQ
wXx6yFOxk7Oy49R7XYan0qzm15vw3aHzmsudQMQB17kCh3CXOOmyQPG74UdfrhAl
zOVLxxtBZJpHJ1YExIzGaaSbE0CTTCKamApmJ/aCAVGf8yDVqf8e+NoQKpTUGqmC
3IHnSsM5sk0r6f3uLmeWMQKBgQCZoNUo/VtJYYL9xq0QBCZ6CF1A+5ySRXUKgEO5
z1BRQ6vwEoR82V2MD6MMYNPYyJo8fHahsmlCJGSPZ8Ubhss737HZKUeXNHQVNUV1
sjIa76Y1FA8c9v/9LT0Xd97eCQE+/DA7327WHoye+eT5XMbH8nQNwg5AgmMzBSB2
Yxbh2QKBgCc/MRIz+puwlJOT3dVpn00/NgO5y6OfgPWkpWWdxsDFDP+RKNBFcywv
PSpd48lBhdR97zfopI5PQil20AoK7+w1Krx67ZxMiq1g8xJigj5/bB4ME7bcQWpk
XHKJSscj8y01Xmb4pwpy2bxYTwRqq5E14yDWEIeK219/7tmZHB7s
-----END RSA PRIVATE KEY-----
EOL
sudo chmod 400 /home/ubuntu/key_pair_tp3.pem

# Add a delay
sleep 15

sudo chmod +x /home/ubuntu/proxy.py
sudo python3 /home/ubuntu/proxy.py