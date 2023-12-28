#!/bin/bash
# user data file for standalone mysql server

# Installing required packages
sudo apt-get update
sudo apt-get install python3 python3-pip -y
sudo pip3 install flask



# Python Script Setup
cd ~

# KEy


touch /home/ubuntu/trusted.py
echo """
from flask import Flask, request, jsonify
import os
import time
import random
import re
import requests

app = Flask(__name__)

@app.route('/trusted', methods=['POST'])
def request_validation():
    response = requests.post('http://ip-172-31-1-11.ec2.internal/direct', json=request.json)
    return jsonify(response.json())

@app.route('/', methods=['GET'])
def home():
    return jsonify(result='hello')

if __name__ == '__main__':
    app.run(host='0.0.0.0',debug=True, port=80)
""" | tee /home/ubuntu/trusted.py

sudo chmod +x /home/ubuntu/trusted.py
sudo python3 /home/ubuntu/trusted.py