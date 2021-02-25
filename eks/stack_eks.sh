#! /usr/bin/sh

CFSTACK_S3URL="S3://myoperation/iac_for_eks.yaml"
CFSTACK_URL=$(aws s3 presign ${CFSTACK_S3URL})
CFSTACK_NAME="eks-sample"
CFSTACK_PROJECT="eks_sample"
CFSTACK_PARAM=' ParameterKey="ProjectName",ParameterValue="'${CFSTACK_PROJECT}'" ParameterKey="Environment",ParameterValue="develop" '
CFSTACK_TAGS=' Key="Env",Value="develop" Key="Info",Value="Network Infrastructure" '﻿

aws cloudformation create-stack \
--stack-name ${CFSTACK_NAME}  \
--parameters  ${CFSTACK_PARAM} \
--template-url ${CFSTACK_URL} \
--tags ${CFSTACK_TAGS}

##   진행 중인 상황은 Output 문자열이 이렇게 나옴. =>   "ResourceStatus": "CREATE_IN_PROGRESS", "ResourceStatusReason": "User Initiated"
while true; do 
  results=$(aws cloudformation describe-stack-events \
          --stack-name ${CFSTACK_NAME} 2> .err.txt | jq -r ".StackEvents[] | select(.LogicalResourceId==\"${CFSTACK_NAME}\" and .ResourceStatusReason < 0 ) | .ResourceStatus " ) ; 
  if [ -e ".err.txt" ]
  then
    cat .err.txt
    rm -f .err.txt
    break
  fi
  echo "check status : ${results} "; 
  if [ "${results}" == "CREATE_COMPLETE" -o "${results}" == "ROLLBACK_COMPLETE" ]; then break; fi;
  sleep 5; 
done
