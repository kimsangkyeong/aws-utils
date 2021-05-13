import json
import urllib.parse
import boto3
import os      # efs
import fcntl   # efs

print('Loading function')

# 전역 변수
s3 = boto3.client('s3')
LAMBDA_LOCAL_MOUNT_PATH='/mnt/data'
EFS_ACCOUNTINFO_RESULT_PATH=LAMBDA_LOCAL_MOUNT_PATH + '/' + 'accountinfo/result' + '/'

# SQS - rating
ratingQURL='https://sqs.ap-northeast-2.amazonaws.com/091262214952/ksk-scenario-rating-job-queue'

def get_efs_list(basepath):
    print(' search path : ', basepath)
    with os.scandir(basepath) as entries:
        for entry in entries:
            print(entry.name)

def push_request_to_sqs(inputfilename):
    try:
        sqs = boto3.client('sqs')
        _params = {'InputFileName': inputfilename}
        msg_body = json.dumps(_params)
        print('send message : {}', msg_body )
        msg = sqs.send_message(QueueUrl=ratingQURL,
                               MessageBody=msg_body)
    except Exception as e:
        print(e)

def lambda_handler(event, context):
    print("ksk-scenario-accountinfo : ", event)
    if event['accountinfoBatchResult'] != 'SUCCEEDED' :
        print("batch error - skip process")
        return 
    else :
        # EFS list - check Result
        get_efs_list(LAMBDA_LOCAL_MOUNT_PATH)
        get_efs_list(EFS_ACCOUNTINFO_RESULT_PATH)
        # request job process
        push_request_to_sqs(event['InputFileName'])
