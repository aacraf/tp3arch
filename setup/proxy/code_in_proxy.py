from flask import Flask, request, jsonify
import mysql.connector

app = Flask(__name__)

# MySQL connection configuration

cluster = {
    "manager": "ip-172.31.1.1.ec2.internal",
    "node1": "ip-172.31.1.2.ec2.internal",
    "node2": "ip-172.31.1.3.ec2.internal",
    "node3": "ip-172.31.1.4.ec2.internal"
}

mysql_config = dict(
    user= 'tp3',
    password= 'tp3',
    database= 'sakila',
)

def create_ssh_tunnel(node):
  print('Creating tunnel...')
  ssh_config = cluster[node]
  tunnel = SSHTunnelForwarder(
      ('172.31.1.1', 22),
      ssh_username='ubuntu',
      ssh_pkey='key_pair_tp3.pem',
      remote_bind_address=('172.31.1.1', 3306)
  )
  tunnel.start()

  print('Tunnel creation successful!')

  return tunnel


def send_query(query, node):
    connection = mysql.connector.connect(**mysql_config, host=cluster[node])
    cursor = connection.cursor(dictionary=True)
    cursor.execute(query)
    result = cursor.fetchall()
    cursor.close()
    connection.close()
    return result


@app.route('/direct', methods=['POST'])
def direct():
    query = request.json.get('query')
    result = send_query(query,"manager")
    return result


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
