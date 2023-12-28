#!/bin/bash

# allow execution of scripts
#chmod +x -r setup
# cluster
python3 setup/cluster/cluster.py
#standalone
python3 setup/standalone/standalone.py
#proxy
python3 setup/proxy/proxy.py
# gatekeeper
python3 setup/gatekeeper/gatekeeper.py

