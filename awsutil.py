"""
    This module contains the most important functions made by us to create
    AWS objects and allow for the necessary operations on TP2.
"""

def create_keypair(client, name, save_to_file=True):
    """
    Creates a new key pair with the specified name if it doesn't already exist.

    Args:
        client: An instance of the Boto3 EC2 client.
        name: The name of the key pair to create.
        save_to_file: A boolean indicating whether to save the PEM key to a local file.

    Returns:
        The name of the key pair that was created or already existed.
        The PEM key content as a string (if save_to_file is False).
    """

    print("Checking if the specified key pair name already exists...")

    # Gets all key pairs (if any).
    response = client.describe_key_pairs()

    # Verifies if the key pair already exists.
    # 1st case: there is a key pair with that name already.
    for i in range(0, len(response['KeyPairs'])):
        if response['KeyPairs'][i]["KeyName"] == name:
            print(f"Key pair '{name}' already exists.\n")
            key_pair = response['KeyPairs'][i]

            if not save_to_file:
                return key_pair['KeyName'], key_pair['KeyMaterial']

            return key_pair['KeyName']

    # 2nd case: there is no key pair with that name OR there isn't a key pair yet.
    key_pair = client.create_key_pair(KeyName=name)
    print("Key pair doesn't exist, so it was just created.\n")

    if not save_to_file:
        return key_pair['KeyName'], key_pair['KeyMaterial']

    # Save the PEM key to a local file
    pem_key = key_pair['KeyMaterial']
    pem_file_path = f"{name}.pem"

    with open(pem_file_path, 'w') as pem_file:
        pem_file.write(pem_key)

    print(f"PEM key saved to {pem_file_path}\n")

    return key_pair['KeyName']


def create_security_group(client, name, ports):
    """
    Creates a new security group with the given name and authorizes ingress rules
    for the specified ports.
    If a security group with the given name already exists, it authorizes ingress
    rules for the specified ports that are not already enabled.

    Args:
        client (boto3.client): The Boto3 client to use.
        name (str): The name of the security group to create or update.
        ports (list): A list of integers representing the ports to authorize ingress rules for.

    Returns:
        str: The ID of the created or updated security group.
    """

    print(f"Checking if '{name}' security group already exists...")

    # Gets all security groups (if any).
    response = client.describe_security_groups()
    security_group = None
    existing_rules = []

    # Verifies if the security group already exists.
    for group in response['SecurityGroups']:
        if group["GroupName"] == name:
            print(f"Security group '{name}' already exists.")
            security_group = group
            existing_rules = [rule['FromPort'] for rule in group['IpPermissions']]
            break

    if security_group is None:
        security_group = client.create_security_group(
            GroupName=name,
            Description='TP3 ' + name + ' Security Group'
        )
        print(f"Security group '{name}' didn't exist, so it was just created!")

    # Authorize ingress rules for new or existing security group
    for port in ports:
        if port not in existing_rules:
            client.authorize_security_group_ingress(
                GroupId=security_group['GroupId'],
                IpPermissions=[
                    {'IpProtocol': 'tcp',
                     'FromPort': port,
                     'ToPort': port,
                     'IpRanges': [{'CidrIp': '0.0.0.0/0'}]}
                ]
            )

    return security_group['GroupId']



def create_instances(ec2, n, instance_type, image_id, security_group_id, user_data_script, key_pair_name, tagname):
    """
    Creates EC2 instances with the specified parameters.

    Args:
        ec2 (boto3.client): The EC2 client object.
        n (int): The number of instances to create.
        instance_type (str): The instance type to create.
        image_id (str): The ID of the AMI to use for the instances.
        security_group_id (str): The ID of the security group to assign to the instances.
        user_data_script (str): The user data script to run on the instances.
        key_pair_name (str): The name of the key pair to use for the instances.
        availability_zone (str): The availability zone in which to launch the instances.

    Returns:
        list: A list of the created EC2 instances.
    """

    instances = ec2.create_instances(
        #BlockDeviceMappings=[
        #    {
        #        'DeviceName': '/dev/sda1',
        #        'Ebs': {
        #            'VolumeSize': volume_size,
        #            'VolumeType': 'gp2'
        #        }
        #    },
        #],
        MinCount=1,
        MaxCount=n,
        KeyName=key_pair_name,
        InstanceType=instance_type,
        ImageId=image_id,
        UserData=user_data_script,

        #Placement={
        #    'AvailabilityZone': availability_zone
        #},
        NetworkInterfaces=[
            {
                'DeviceIndex': 0,
                'Groups': [security_group_id],
                'AssociatePublicIpAddress': True
            }
        ],
        TagSpecifications=[
            {
                'ResourceType': 'instance',
                'Tags': [
                    {
                        'Key': 'Name',
                        'Value': tagname
                    },
                ]
            },
        ]
    )

    # register instances in target groups
    instance_ids = [instance.instance_id for instance in instances]
    print("Instance IDs:", instance_ids)

    for instance in instances:
        # Wait for each instance to be running
        instance.wait_until_running()

    return instances



def create_instance(ec2, instance_type, image_id, security_group_id, user_data_script, key_pair_name, tagname, subnet,private_ip):
    """
    Create an instance from the params passed

    :param: name of the instance to create
    :param: privateIp of the instance to create
    :param: SecurityGroupId of the instance to create
    :param: userData of the instance to create
    :param: InstanceType of the instance to create
    :return the instance created
    """
    return ec2.run_instances(
        ImageId="ami-0a6b2839d44d781b2",
        MinCount=1,
        MaxCount=1,
        InstanceType=instance_type,
        KeyName=key_pair_name,
        UserData=user_data_script,
        SecurityGroupIds=[security_group_id],
        SubnetId=subnet,
        PrivateIpAddress=private_ip,
        TagSpecifications=[
            {
                'ResourceType': 'instance',
                'Tags': [
                    {
                        'Key': 'Name',
                        'Value': tagname
                    },
                ]
            },
        ]
    )


if __name__ == '__main__':
    pass
