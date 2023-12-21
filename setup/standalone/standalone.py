import boto3
from awsutil import *
# get user data for standalone instance

user_data_standalone = ""
with open("standalone.sh", "r") as file:
    user_data_standalone = file.read()

if __name__ == "__main__":
    ## The 'client' variable creates a link to the EC2 service. ##
    client = boto3.client('ec2', region_name='us-east-1')
    ## EC2 client. ##
    ec2 = boto3.resource('ec2', region_name='us-east-1')

    ## Create keypair if it doesn't exist yet. ##
    key_pair_name = create_keypair(client, 'key_pair_tp3')

    ## Create security group if it doesn't exist yet. ##
    security_group = create_security_group(client, 'tp3', [22, 80])

    # create standalone instance.
    standalone = create_instances(ec2, 1, 't2.micro', "ami-053b0d53c279acc90", security_group, user_data_standalone, key_pair_name, "standalone")
    # log standalone instance id.
    print("standalone", standalone)