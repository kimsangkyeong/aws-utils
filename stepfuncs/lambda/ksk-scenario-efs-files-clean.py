import json
import urllib.parse
import boto3
import os      # efs
import fcntl   # efs
import shutil

print('Loading function')

# 전역 변수
LAMBDA_LOCAL_MOUNT_PATH='/mnt/data'

def delete_efs_list(basepath):
    print(' search path : ', basepath)
    with os.scandir(basepath) as entries:
        for entry in entries:
            if entry.is_file():
                print('file : ', entry.name)
                os.remove( basepath + '/' + entry.name )
            else:
                print('directory : ', entry.name)
                shutil.rmtree( basepath + '/' + entry.name )
    print(' delete_efs_list end ')                
            
def lambda_handler(event, context):
    # EFS list
    delete_efs_list(LAMBDA_LOCAL_MOUNT_PATH)

    return event
