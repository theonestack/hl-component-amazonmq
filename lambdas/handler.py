import sys
import os

sys.path.append(f"{os.environ['LAMBDA_TASK_ROOT']}/lib")
sys.path.append(os.path.dirname(os.path.realpath(__file__)))

import cr_response
import json
import boto3
import string
import random

from botocore.exceptions import ClientError

def lambda_handler(event, context):
    print(f"Received event:{json.dumps(event)}")

    lambda_response = cr_response.CustomResourceResponse(event)
    params = event['ResourceProperties']
    print(f"Resource Properties {params}")

    try:
        if event['RequestType'] == 'Create':
            event['PhysicalResourceId'] = params['Path']
            password, version = put_parameter(params=params,override=False)
            lambda_response.respond(data={
                "Password": password,
                "Version": version
            })
        elif event['RequestType'] == 'Update':
            event['PhysicalResourceId'] = params['Path']
            password, version = put_parameter(params=params,override=True)
            lambda_response.respond(data={
                "Password": password,
                "Version": version
            })

        elif event['RequestType'] == 'Delete':
            delete_parameter(params['Path'])
            lambda_response.respond()
    except Exception as e:
        message = str(e)
        lambda_response.respond_error(message)
    return 'OK'


def put_parameter(params,override):

    if 'Path' not in params:
      raise Exception('Path parameter is required')

    if 'Description' not in params:
      raise Exception('Description parameter is required')

    length = int(params['Length']) if 'Length' in params else 32
    password = params['Value'] if 'Value' in params else generate_password(length)

    client = boto3.client('ssm')
    response = client.put_parameter(
        Name=params['Path'],
        Description=params['Description'],
        Value=password,
        Overwrite=override,
        Type='SecureString'
    )

    if 'Tags' in params:

        if not isinstance(params['Tags'],list):
            raise Exception('Tags must be of type list')

        client.add_tags_to_resource(
            ResourceType='Parameter',
            ResourceId=params['Path'],
            Tags=params['Tags']
        )

    return password, response['Version']

def delete_parameter(path):
    client = boto3.client('ssm')
    try:
        client.delete_parameter(
            Name=path
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'ParameterNotFound':
            print("Parameter doesn't exist")
        else:
            raise Exception("Unexpected error on delete: %s" % e)


def generate_password(length):
    print(f"Generating a new password {length} chars long")
    return ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(length))
