import json
import urllib.parse
import boto3
import os      # efs
import fcntl   # efs

print('Loading function')

# 전역 변수
s3 = boto3.client('s3')

LAMBDA_LOCAL_MOUNT_PATH='/mnt/data'
EFS_ACCOUNTINFO_INPUT_PATH=LAMBDA_LOCAL_MOUNT_PATH + '/' + 'accountinfo/input' + '/'
S3_DELIVERED_OBJECT_PATH='delivered' + '/'   # 정상 처리 완료
S3_HOLE_OBJECT_PATH='hold' + '/'             # 대기 상태로 전환
## SSM Parameter Store
SSM_PARAMETER_JOB_HOLDING_FLAG='ksk-scenario-job-process-holding-flag'
##  stepfunction
#stm_accountinfo_arn='arn:aws:states:ap-northeast-2:091262214952:stateMachine:ksk-scenario-stm-accountinfo'
stm_accountinfo_arn='arn:aws:states:ap-northeast-2:091262214952:stateMachine:ksk-scenario-stm-accountinfo-choice'
awsbatchtype='ec2'  # RunEnvironment : "ec2", "fargate"

def download_s3_object(bucket, key):
    try:
        targetfilename = EFS_ACCOUNTINFO_INPUT_PATH + key[len('input/'):]
        print("bucket : {}, key : {}, fname : {}".format(bucket, key, targetfilename))
        os.makedirs(EFS_ACCOUNTINFO_INPUT_PATH + 'input', exist_ok=True)
        s3.download_file(bucket, key, targetfilename)
    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
        raise e

def delivered_s3_object(bucket, key):
    try:
        copy_source = {
              'Bucket': bucket,
              'Key': key
            }
        filename = key[len('input/'):]
        destkey = S3_DELIVERED_OBJECT_PATH + filename
        print("source : {}/{} => dest : {}".format(bucket, key, destkey))
        s3.copy(copy_source, bucket, destkey)
        s3.delete_object(Bucket=bucket, Key=key)
    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
        raise e

def hold_s3_object(bucket, key):
    try:
        copy_source = {
              'Bucket': bucket,
              'Key': key
            }
        filename = key[len('input/'):]
        destkey = S3_HOLE_OBJECT_PATH + filename
        print("source : {}/{} => dest : {}".format(bucket, key, destkey))
        s3.copy(copy_source, bucket, destkey)
        s3.delete_object(Bucket=bucket, Key=key)
    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
        raise e
        
def get_parameter():
    try:
        # get SSM client
        ssm = boto3.client('ssm')

        print('ssm.get_parameter() : ', ssm)
        #confirm  parameter exists before updating it
        resp = ssm.get_parameter(
              Name=SSM_PARAMETER_JOB_HOLDING_FLAG
            )

        print('response : ', resp)
        if not resp['Parameter']:
            print('No such parameter')
            return ''
        else :
            print('job flag :  {} = {}'.format(SSM_PARAMETER_JOB_HOLDING_FLAG, resp['Parameter']['Value']))
            return resp['Parameter']['Value']
            
    except Exception as e:
        print(e)
        print('Error get_parameter {} from ssm.'.format(SSM_PARAMETER_JOB_HOLDING_FLAG))
        raise e       
        
def get_efs_list(basepath):
    print(' search path : ', basepath)
    with os.scandir(basepath) as entries:
        for entry in entries:
            #print(entry.name)
            statinfo = os.stat(basepath + '/' + entry.name)
            print("{} - size {}, createdtime {}, modifiedtime {}".format(entry.name, statinfo.st_size, statinfo.st_ctime, statinfo.st_mtime))

def execute_statemachine(key):
    try:
        stepfunc = boto3.client('stepfunctions');
        response = stepfunc.start_execution(
            stateMachineArn=stm_accountinfo_arn,
            input=json.dumps({"InputFileName": key[len('input/'):], "Caller": "ksk-scenario-s3-efs", "RunEnvironment": awsbatchtype})
        )   
    except Exception as e:
        print(e)
        print('Error execute_statemachine - {} .'.format(stm_accountinfo_arn))
        raise e       

def lambda_handler(event, context):
    print('event => ' , event)
    # Get the object from the event and show its content type
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    
    print('bucket : {}, key : {}'.format(bucket, key))
    # Get Job Process Info 
    holding_yn = get_parameter()
    if holding_yn == 'N' :  # 정상 상태
      # 다운로드
      download_s3_object(bucket, key)
      # delivered로 이동
      delivered_s3_object(bucket, key)
      # EFS list
      get_efs_list(LAMBDA_LOCAL_MOUNT_PATH)
      get_efs_list(EFS_ACCOUNTINFO_INPUT_PATH)
      # execute accountinfo Stepfunction
      execute_statemachine(key)
    else:  # Hoding 상태
      # hold로 이동
      hold_s3_object(bucket, key)
      
    return event
