import boto3
from awsutil import *

import os

# get user data for standalone instance


user_data_proxy = ""
with open("gatekeeper.sh", "r") as file:
    user_data_gatekeeper = file.read()

with open("trusted_host.sh", "r") as file:
    used_data_trusted = file.read()





if __name__ == "__main__":
    ## The 'client' variable creates a link to the EC2 service. ##
    client = boto3.client('ec2', region_name='us-east-1')
    ## EC2 client. ##
    ec2 = boto3.resource('ec2', region_name='us-east-1')

    ## Create keypair if it doesn't exist yet. ##
    key_pair_name = create_keypair(client, 'key_pair_tp3')

    ## Create security group if it doesn't exist yet. ##
    security_group_th = create_security_group(client, 'tp3-trustedhost', [22, 80], '172.31.1.12/16')

    security_group_gk = create_security_group(client, 'tp3-gatekeeper', [22, 80], '0.0.0.0/0')

    # create standalone instance.
    subnet = 'subnet-04c4760bb0437e465'
    gatekeeper = create_instance(client, 't2.micro', "ami-053b0d53c279acc90", security_group_gk, user_data_gatekeeper, key_pair_name,
                                  "gatekeeper", subnet, "172.31.1.12")

    trusted_host = create_instance(client, 't2.micro', "ami-053b0d53c279acc90", security_group_th, used_data_trusted,
                                key_pair_name,
                                 "trusted_host", subnet, "172.31.1.13")


    print("gatekeeper", gatekeeper)