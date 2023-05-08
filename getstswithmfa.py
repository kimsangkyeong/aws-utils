##############################################################################
# 목적 : MFA 설정 IAM User의 STS Session 정보를 Config 파일에 자동 설정하기     #
# 조건 : python, boto3 package, aws cli 설치되어 있어야 함                     #
# 기능 : 1. AWS Account 계정, IAM User 정보, MFA OTP Token 값을 입력           #
#        2.자동으로 Session 정보를 credential 파일에 mfa profile로 셋팅        #
#        3. aws s3 ls --profile mfa   처럼 사용하면 됨.                       #
# 기타 : STS Session 유지시간은 12시간으로 설정                                #
# -------------------------------------------------------------------------- #
#  ver       date       author       description                             #
# -------------------------------------------------------------------------- #
#  1.0    2021.2.17      ksk         최초 개발                                #
##############################################################################
import boto3
import sys
import io

# coding= utf-8 
def setEnvironment():
    sys.stdin  = io.TextIOWrapper(sys.stdin.detach(), encoding = 'utf-8')
    sys.stdout = io.TextIOWrapper(sys.stdout.detach(), encoding = 'utf-8')
    sys.stderr = io.TextIOWrapper(sys.stderr.detach(), encoding = 'utf-8')
    #print("stdin - {}, stdout - {}, stderr - {}".format(sys.stdin.encoding, sys.stdout.encoding, sys.stderr.encoding))

awsinfo = {'account_num':'','iamuser_id':'','tokencode_mfa':'','serial_number_mfa':'' }
stsinfo = {'aws_access_key_id':'','aws_secret_access_key':'','aws_session_token':''}
def getAWSInfo(argv):
    LEN_ACCOUNT_NUM = 12 # account 자릿수
    while True:
        awsinfo['account_num']   = input("account_num : ")
        if LEN_ACCOUNT_NUM == len(awsinfo['account_num']) :
            break
        print(".. error : account_num 12자리 정보를 다시 입력해 주세요~") 
    awsinfo['iamuser_id']    = input("iamuser_id : ")

    awsinfo['serial_number_mfa']   = input("serial_number_mfa : ")
    # awsinfo['serial_number_mfa'] = 'arn:aws:iam::' + awsinfo['account_num'] + ':mfa/' + awsinfo['iamuser_id']
    
    LEN_TOKENCODE_MFA = 6 # OTP mfa token code 자릿수
    while True:
        awsinfo['tokencode_mfa'] = input("tokencode_mfa : ")
        if LEN_TOKENCODE_MFA == len(awsinfo['tokencode_mfa']):
            break
        print(".. error : tokencode_mfa 6자리 정보를 다시 입력해 주세요~") 
    print(awsinfo)
    return True

def getStsSession(argv):
    getAWSInfo(argv) # AWS 계정/유저/OTP Code 정보 얻기
    try:
        sts = boto3.client('sts')
        SESSION_DURATION_SECONDS=42300 # 12시간 default
        response = sts.get_session_token(
            DurationSeconds=SESSION_DURATION_SECONDS,
            SerialNumber=awsinfo['serial_number_mfa'],
            TokenCode=awsinfo['tokencode_mfa']
        )
        if 200 == response["ResponseMetadata"]["HTTPStatusCode"]:
            credentials = response["Credentials"]
            #print(credentials)
            stsinfo['aws_access_key_id']     = credentials['AccessKeyId']
            stsinfo['aws_secret_access_key'] = credentials['SecretAccessKey']
            stsinfo['aws_session_token']     = credentials['SessionToken']
            #print(stsinfo)
        else:
            print("call error : {}".format(response["ResponseMetadata"]["HTTPStatusCode"]))
            return False
        return True
    except Exception as othererr:
      print("sts.get_session_token() error : {}".format(othererr))
      return False
    
def setCredentialsConfig():
    try:
        CONFIG_FILE  = 'credentials' # .aws/credentials file
        with open(CONFIG_FILE, 'r') as fread:
            lines = fread.readlines();

        finded_mfa = False
        newlines = []
        for idx, line in enumerate(lines) :
            if '[mfa]' in line :
                finded_mfa = True
            if finded_mfa :
                if 'aws_access_key_id' in line :
                    line = 'aws_access_key_id = ' + stsinfo['aws_access_key_id'] + '\n'
                if 'aws_secret_access_key' in line :
                    line = 'aws_secret_access_key = ' + stsinfo['aws_secret_access_key'] + '\n'
                if 'aws_session_token' in line :
                    line = 'aws_session_token = ' + stsinfo['aws_session_token'] + '\n'
            newlines.append(line)

        if not finded_mfa :
            newlines.append('[mfa]\n')
            newlines.append('aws_access_key_id = ' + stsinfo['aws_access_key_id'] + '\n')
            newlines.append('aws_secret_access_key = ' + stsinfo['aws_secret_access_key'] + '\n')
            newlines.append('aws_session_token = ' + stsinfo['aws_session_token'] + '\n')

        with open(CONFIG_FILE, 'w') as fwrite:
            fwrite.writelines(newlines)

        return True
    except Exception as errinfo:
        print("setCredentialsConfig() open error : {}".format(errinfo))
        return False

def main(argv):
    setEnvironment()
    if not getStsSession(argv):
        sys.exit(1)
    if not setCredentialsConfig():
        sys.exit(1)
    sys.exit(0)

if __name__ == "__main__":
    main(sys.argv[1:])
