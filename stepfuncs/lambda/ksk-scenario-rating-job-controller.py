import os
import json
import boto3
from time import sleep
from ast import literal_eval

print('Loading function')

# 전역 변수
sqs = boto3.client('sqs')
stepfunc = boto3.client('stepfunctions')
ssm = boto3.client('ssm')

# SQS - rating
ratingQURL='https://sqs.ap-northeast-2.amazonaws.com/091262214952/ksk-scenario-rating-job-queue'
Wait_Time=0
MAX_RECIEVE_CNT_AT_ONE_TIME=10
## SSM Parameter Store
SSM_PARAMETER_JOB_HOLDING_FLAG='ksk-scenario-job-process-holding-flag'
SSM_PARAMETER_JOB_RATING_DESIRED_PROCESS_COUNT='ksk-scenario-job-rating-desired-process-count'

##  stepfunction
#stm_rating_arn='arn:aws:states:ap-northeast-2:091262214952:stateMachine:ksk-scenario-stm-rating'
stm_rating_arn='arn:aws:states:ap-northeast-2:091262214952:stateMachine:ksk-scenario-stm-rating-choice'

def get_parameter(parametername):
    try:
        #get parameter value
        response = ssm.get_parameter(
           Name=parametername
        )
        #print(response)
        if not response['Parameter']:
            print('No such parameter')
            return ''
        else :
            print('job flag :  {} = {}'.format(parametername, response['Parameter']['Value']))
            return response['Parameter']['Value']
            
    except Exception as e:
        print(e)
        print('Error get_parameter {} from ssm.'.format(parametername))
        raise e            

def get_running_stepfunction_count(desired_count):
    try:
        print("call stepfunc.list_executions ")
        response = stepfunc.list_executions(
                stateMachineArn=stm_rating_arn,
                statusFilter='RUNNING',
                maxResults=desired_count
            )
        print('list_executions function - entry :',response)
        print('count - entry: ', len(response['executions']))
        return len(response['executions'])
    except Exception as e:
        print(e)
        print('Error get_parameter {} from ssm.'.format(parametername))
        raise e  

def receive_sqs_message(sqs_queue_url, max_number, wait_time):
    try:
        print("call sqs.receive_sqs_message ")
        response = sqs.receive_message(QueueUrl=sqs_queue_url,
                                        AttributeNames=['ALL'],
                                        MaxNumberOfMessages=max_number,
                                        VisibilityTimeout=5,
                                        WaitTimeSeconds=wait_time)
        return response
    except Exception as e:
        print(e)
        print('Error receive_sqs_message : queue {} - max_number - {}'.format(sqs_queue_url, max_number))
        return None

def delete_sqs_message(sqs_queue_url, receipthandle):
    try:
        sqs.delete_message(QueueUrl=sqs_queue_url,
                           ReceiptHandle= receipthandle)
        return None
    except Exception as e:
        print(e)
        print('Error delete_sqs_message : queue {} - receipthandle - {}'.format(sqs_queue_url, receipthandle))
        return None

def execute_rating_stepfunction(more_runnable_count, awsbatchtype):
    while more_runnable_count > 0 :
        response = receive_sqs_message(ratingQURL, more_runnable_count, Wait_Time)
        print("response : ", response)
        #print(".. {} .. {} ".format(type(response['ResponseMetadata']), response['ResponseMetadata']))
        if response['ResponseMetadata']['HTTPStatusCode'] == 200 :
            if 'Messages' not in response :
                print(" No Queue Data ")
                break
            else :
                for msg in response['Messages']:
                    print("Received message: {} - {}".format(msg['ReceiptHandle'], msg['Body']))    
                    data = literal_eval(msg['Body']) # str to dict
                    print(" queue data -> {}, {}".format(type(data),data['InputFileName']))
                    start_rating_stepfunction(data['InputFileName'], awsbatchtype)
                    delete_sqs_message(ratingQURL, msg['ReceiptHandle'])
                    more_runnable_count = more_runnable_count - 1
                    print("more_runnable_count : ", more_runnable_count)
        else :
            print(" receive_message Error : ", response)    

def start_rating_stepfunction(inputfilename, awsbatchtype):
    try:
        response = stepfunc.start_execution(
                              stateMachineArn=stm_rating_arn,
                              input=json.dumps({"InputFileName": inputfilename, "Caller": "ksk-scenario-rating-job-controller", "RunEnvironment": awsbatchtype})
                   )
    except Exception as e:
        print(e)
        print('Error start_rating_stepfunction : inputfilename {} '.format(inputfilename))
        return None
    
def lambda_handler(event, context):
    if event.get('awsbatchtype') in ['ec2', 'fargate'] :  # RunEnvironment : "ec2", "fargate"
        awsbatchtype = event.get('awsbatchtype')
    else:
        awsbatchtype = 'fargate' # default
    print("event : {}  => awsbatchtype : {}".format(event, awsbatchtype))  
    
    loopcnt = 0
    
    while loopcnt <= 280 : 
        print("loopcnt : ", loopcnt)
        # get job process holding flag 
        holding_yn = get_parameter(SSM_PARAMETER_JOB_HOLDING_FLAG)
        if holding_yn == 'N' :  # 정상 상태

            # get rating process desired count info
            desired_count = get_parameter(SSM_PARAMETER_JOB_RATING_DESIRED_PROCESS_COUNT)
            int_desired_count = int(desired_count)
       
            # check running process count 
            running_count = get_running_stepfunction_count(int_desired_count)

            # check execute stepfunction    
            execute_maxcount = min(int_desired_count - running_count, MAX_RECIEVE_CNT_AT_ONE_TIME- running_count)
            print("min(int_desired_count {} - running_count {}, MAX_RECIEVE_CNT_AT_ONE_TIME {} - running_count {}) => execute_maxcount : {}".format(int_desired_count,running_count, 
                                                                                                                                             MAX_RECIEVE_CNT_AT_ONE_TIME, running_count, execute_maxcount))
            if execute_maxcount > 0 :
                execute_rating_stepfunction(execute_maxcount, awsbatchtype)
            sleep(10)
        else:  # Hoding 상태
            # 10초 sleep
            sleep(10)
        loopcnt = loopcnt + 1
        print("loopcnt : ", loopcnt)
        
    print("end...")
    

