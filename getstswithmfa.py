##############################################################################
# 목적 : MFA 설정 IAM User의 STS Session 정보를 Config 파일에 자동 설정하기     #
# 조건 : python, boto3 package, aws cli 설치되어 있어야 함                     #
# 기능 : 1. AWS Account 계정, IAM User 정보, serial_number_mfa, MFA OTP Token 값을 입력           #
#        2.자동으로 Session 정보를 credential 파일에 mfa profile로 셋팅        #
#        3. aws s3 ls --profile mfa   처럼 사용하면 됨.                       #
# 기타 : STS Session 유지시간은 12시간으로 설정                                #
# -------------------------------------------------------------------------- #
#  ver       date       author       description                             #
# -------------------------------------------------------------------------- #
#  1.0    2021.2.17      ksk         최초 개발                                #
#  1.1    2023.5.15      ksk         환경변수 설정 정보 stdout 출력 추가       #
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
        newlines = [];  envlines_linux = []; envlines_win = [];
        envlines_linux.append('[Linux Envirionment]')
        envlines_win.append('[Windows Envirionment]')
        for idx, line in enumerate(lines) :
            if '[mfa]' in line :
                finded_mfa = True
            if finded_mfa :
                if 'aws_access_key_id' in line :
                    line = 'aws_access_key_id = ' + stsinfo['aws_access_key_id'] + '\n'
                    envlines_linux.append('export AWS_ACCESS_KEY_ID=' + stsinfo['aws_access_key_id'])
                    envlines_win.append('SET AWS_ACCESS_KEY_ID=' + stsinfo['aws_access_key_id'])
                if 'aws_secret_access_key' in line :
                    line = 'aws_secret_access_key = ' + stsinfo['aws_secret_access_key'] + '\n'
                    envlines_linux.append('export AWS_SECRET_ACCESS_KEY=' + stsinfo['aws_secret_access_key'])
                    envlines_win.append('SET AWS_SECRET_ACCESS_KEY=' + stsinfo['aws_secret_access_key'])
                if 'aws_session_token' in line :
                    line = 'aws_session_token = ' + stsinfo['aws_session_token'] + '\n'
                    envlines_linux.append('export AWS_SESSION_TOKEN=' + stsinfo['aws_session_token'])
                    envlines_win.append('SET AWS_SESSION_TOKEN=' + stsinfo['aws_session_token'])
            newlines.append(line)

        if not finded_mfa :
            newlines.append('[mfa]\n')
            newlines.append('aws_access_key_id = ' + stsinfo['aws_access_key_id'] + '\n')
            newlines.append('aws_secret_access_key = ' + stsinfo['aws_secret_access_key'] + '\n')
            newlines.append('aws_session_token = ' + stsinfo['aws_session_token'] + '\n')
            envlines_linux.append('export AWS_ACCESS_KEY_ID=' + stsinfo['aws_access_key_id'])
            envlines_linux.append('export AWS_SECRET_ACCESS_KEY=' + stsinfo['aws_secret_access_key'])
            envlines_linux.append('export AWS_SESSION_TOKEN=' + stsinfo['aws_session_token'])
            envlines_win.append('SET AWS_ACCESS_KEY_ID=' + stsinfo['aws_access_key_id'])
            envlines_win.append('SET AWS_SECRET_ACCESS_KEY=' + stsinfo['aws_secret_access_key'])
            envlines_win.append('SET AWS_SESSION_TOKEN=' + stsinfo['aws_session_token'])

        with open(CONFIG_FILE, 'w') as fwrite:
            fwrite.writelines(newlines)

        print(envlines_linux)
        print(envlines_win)

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

###### < 최종 이미지 > ####
# 1. 파일 구성 : .aws/credentials
#                $aws sts get-session-token --serial-number MFA_NUM --token-code CODE_FROM_MFA
#                실행결과 값을 mfa로 셋팅
#                [mfa]
#                aws_access_key_id = ID_FROM_ABOVE
#                aws_secret_access_key = KEY_FROM_ABOVE
#                aws_session_token = TOKEN_FROM_ABOVE
# 2. 파일 구성 : .aws/config
#                [mfa]
#                output = json
#                region = us-east-1
#
#                [profile secondaccount]
#                role_arn = arn:aws:iam::<SECOND_ACCOUNT_ID>:role/admin
#                source_profile = mfa
# 3. 실행 예시 : $aws s3 ls --profile mfa
#######
