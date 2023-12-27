import boto3
from awsutil import *

import os

# get user data for standalone instance


user_data_proxy = ""
with open("proxy.sh", "r") as file:
    user_data_proxy = file.read()


def get_instance_public_ip(ec2_resource, instance_id):
    instance = ec2_resource.Instance(instance_id)
    instance.wait_until_running()  # Wait for the instance to start
    instance.load()  # Reload the instance attributes to get updated information
    return instance.public_ip_address


if __name__ == "__main__":
    ## The 'client' variable creates a link to the EC2 service. ##
    client = boto3.client('ec2', region_name='us-east-1')
    ## EC2 client. ##
    ec2 = boto3.resource('ec2', region_name='us-east-1')

    ## Create keypair if it doesn't exist yet. ##
    key_pair_name = create_keypair(client, 'key_pair_tp3')

    ## Create security group if it doesn't exist yet. ##
    security_group = create_security_group(client, 'tp3', [22, 80, 3306])

    # create standalone instance.
    subnet = 'subnet-04c4760bb0437e465'
    proxy = create_instance(client, 't2.micro', "ami-053b0d53c279acc90", security_group, user_data_proxy, key_pair_name,
                              "proxy", subnet, "172.31.1.11")

    instance_id = proxy['Instances'][0]['InstanceId']

    print("standalone", proxy)