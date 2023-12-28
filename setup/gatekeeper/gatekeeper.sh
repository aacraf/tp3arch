#!/bin/bash
# user data file for standalone mysql server

# Installing required packages
sudo apt-get update
sudo apt-get install python3 -y
wget https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py
sudo pip3 install --ignore-installed blinker
sudo pip3 install flask


# Python Script Setup
cd ~

# KEy


touch /home/ubuntu/gatekeeper.py
echo """
from flask import Flask, request, jsonify
import random
import re
import requests

app = Flask(__name__)


def validate_request(data):
    return True


@app.route('/request', methods=['POST'])
def request_validation():
    data = request.json
    if validate_request(data):
        # Forward the request to the proxy
        response = requests.post('http://ip-172-31-1-13.ec2.internal/trusted', json=data)
        return jsonify(response.json()), response.status_code
    else:
        return jsonify({'error': 'Invalid request'}), 400


@app.route('/', methods=['GET'])
def home():
    return jsonify(result='hello')

if __name__ == '__main__':
    app.run(host='0.0.0.0',debug=True, port=80)
""" | tee /home/ubuntu/gatekeeper.py


sudo chmod +x /home/ubuntu/gatekeeper.py
sudo python3 /home/ubuntu/gatekeeper.py