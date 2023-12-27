import boto3
from awsutil import *
# get user data for standalone instance

user_data_manager = ""
with open("manager.sh", "r") as file:
    user_data_manager = file.read()

user_data_worker = ""
with open("worker.sh", "r") as file:
    user_data_worker = file.read()


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
    #standalone = create_instances(ec2, 4, 't2.micro', "ami-053b0d53c279acc90", security_group, user_data_cluster, key_pair_name, "standalone")
    #print("standalone", standalone)


    # create cluster
    subnet = 'subnet-04c4760bb0437e465'
    master = create_instance(client, 't2.micro', "ami-053b0d53c279acc90", security_group, user_data_manager, key_pair_name,
                              "manager", subnet, "172.31.1.1")
    worker1  = create_instance(client,  't2.micro', "ami-053b0d53c279acc90", security_group, user_data_worker, key_pair_name,
                               "worker1", subnet, "172.31.1.2")
    worker2 = create_instance(client, 't2.micro', "ami-053b0d53c279acc90", security_group, user_data_worker, key_pair_name,
                              "worker2", subnet, "172.31.1.3")
    worker3 = create_instance(client, 't2.micro', "ami-053b0d53c279acc90", security_group, user_data_worker, key_pair_name,
                              "worker3", subnet, "172.31.1.4")