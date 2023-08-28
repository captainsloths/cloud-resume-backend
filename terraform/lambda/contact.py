import boto3

ses = boto3.client('ses', region_name='us-east-1')

def lambda_handler(event, context):
    print('EVENT: ', event)
    
    params = {
        'Destination': {
            'ToAddresses': ['alex.eiselstein@gmail.com'],
        },
        'Message': {
            'Body': {
                'Text': {
                    'Data': 'Hello from Lambda!',
                },
            },
            'Subject': {
                'Data': 'Message from AWS Lambda',
            },
        },
        'Source': 'alex.eiselstein@gmail.com',
    }

    response = ses.send_email(**params)
    return response
