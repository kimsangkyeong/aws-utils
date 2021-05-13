import json
import urllib.parse
import boto3
import os      # efs
import fcntl   # efs

print('Loading function')

# 전역 변수
LAMBDA_LOCAL_MOUNT_PATH='/mnt/data'
EFS_CDRPERSISTENCE_RESULT_PATH=LAMBDA_LOCAL_MOUNT_PATH + '/' + 'cdrpersistence/result' + '/'

def get_efs_list(basepath):
    print(' search path : ', basepath)
    with os.scandir(basepath) as entries:
        for entry in entries:
            #print(entry.name)
            statinfo = os.stat(basepath + '/' + entry.name)
            print("{} - size {}, createdtime {}, modifiedtime {}".format(entry.name, statinfo.st_size, statinfo.st_ctime, statinfo.st_mtime))

def lambda_handler(event, context):
    print("ksk-scenario-cdrpersistence : ", event)
    if event['cdrpersistenceBatchResult'] != 'SUCCEEDED' :
        print("batch error - skip process")
        return "error"
    else :
        # EFS list - check Result
        get_efs_list(LAMBDA_LOCAL_MOUNT_PATH)
        get_efs_list(EFS_CDRPERSISTENCE_RESULT_PATH)
        return "success"
        
