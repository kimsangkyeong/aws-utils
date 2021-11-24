#! /usr/bin/sh

## 공통 함수 : 
# check for cloudformation processing
check_process_cf()
{
  ##  실행이 성공적으로 진행 중인 상황은 Output 문자열이 이렇게 나옴. =>   "ResourceStatus": "CREATE_IN_PROGRESS", "ResourceStatusReason": "User Initiated"
  while true; do
    results=$(aws cloudformation describe-stack-events \
            --stack-name $1 2> .err.txt | jq -r ".StackEvents[] | select(.LogicalResourceId==\"$1\" and .ResourceStatusReason < 0 ) | .ResourceStatus " ) ;
    if [ -e ".err.txt" ]
    then
      if [ -s ".err.txt" ]
      then
        cat .err.txt
        rm -f .err.txt
        break
      else
        rm -f .err.txt
      fi
    fi
    if [ "${results}" == "CREATE_COMPLETE" -o "${results}" == "ROLLBACK_COMPLETE" ]
    then
      echo "check status : ${results} ";
      break; 
    else
      echo "check status : in progress... - $(date)"
    fi
    sleep 5;
  done
}

## Step I. base vpc network 생성하기
CFSTACK_S3URL="s3://resource-infra-data-d-ds07297/cloudformation/sk-IaC-infra-vpc-base-EKS-CIDR.yaml"
CFSTACK_URL=$(aws s3 presign ${CFSTACK_S3URL})
CFSTACK_NAME0="ds07297-baseinfra-env"
CFSTACK_PROJECT="ds07297"
CFSTACK_PARAM=' ParameterKey="ProjectName",ParameterValue="'${CFSTACK_PROJECT}'" ParameterKey="Environment",ParameterValue="develop" ParameterKey="StackCreater",ParameterValue="ds07297" ParameterKey="OpsGroup",ParameterValue="admin" '
CFSTACK_TAGS=' Key="Env",Value="develop" Key="Info",Value="Network_Infrastructure" '

#   I-1. CloudFormation 명령 실행하기
echo "=== base cloudformation 생성하기 ==="
aws cloudformation create-stack \
--stack-name ${CFSTACK_NAME0}  \
--parameters  ${CFSTACK_PARAM} \
--template-url ${CFSTACK_URL} \
--tags ${CFSTACK_TAGS}

#  wait for processing 
check_process_cf ${CFSTACK_NAME0}

## Step II. eks service 용 subnet network 생성하기
CFSTACK_S3URL="s3://resource-infra-data-d-ds07297/cloudformation/sk-IaC-infra-vpc-svc-EKSCluster-CIDR.yaml"
CFSTACK_URL=$(aws s3 presign ${CFSTACK_S3URL})
CFSTACK_NAME="ds07297-eks-env"
CFSTACK_PARENT_NAME=${CFSTACK_NAME0}
CFSTACK_PROJECT="ds07297"
CFSTACK_PARAM=' ParameterKey="ParentVpcStack",ParameterValue="'${CFSTACK_PARENT_NAME}'" ParameterKey="StackCreater",ParameterValue="ds07297" ParameterKey="OpsGroup",ParameterValue="admin" '
CFSTACK_TAGS=' Key="Name",Value="ds07297" Key="Env",Value="develop" Key="Project",Value="'${CFSTACK_PROJECT}'" '

#   II-1. CloudFormation 명령 실행하기
echo "=== EKS service 용 cloudformation 생성하기 ==="
aws cloudformation create-stack \
--stack-name ${CFSTACK_NAME}  \
--parameters  ${CFSTACK_PARAM} \
--template-url ${CFSTACK_URL} \
--tags ${CFSTACK_TAGS}

#  wait for processing 
check_process_cf ${CFSTACK_NAME}

