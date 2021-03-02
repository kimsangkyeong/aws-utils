#! /usr/bin/sh

# Step1. Amazon EKS Cluster에IAM Role을 가지고 Kubernetetes service account에 IAM Role을 연결가능 
#        이 service account 는 service account를 사용하는 pod의 contianer에 AWS permission을 제공
#        이렇게 하면 더이상 node의 IAM role에 permission을 확장하지 않아도 된다.
#        https://www.eksworkshop.com/intermediate/230_logging/prereqs/
#
# 1-1 Enabling IAM roles for service accounts on your cluster
#
#eksctl utils associate-iam-oidc-provider \
#    --cluster ds07297-eks \
#    --approve

# 1-2 AWS의Elasticsearch 서비스를 사용한다면, ESHttp* 호출할 수 있는 Policy 생성
#
#mkdir ~/environment/logging/
#export AWS_REGION="region"
#export ACCOUNT_ID="accountid"
#export ES_DOMAIN_NAME="eksworkshop-logging"
#
#cat <<EoF > ~/environment/logging/fluent-bit-policy.json
#{
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Action": [
#                "es:ESHttp*"
#            ],
#            "Resource": "arn:aws:es:${AWS_REGION}:${ACCOUNT_ID}:domain/${ES_DOMAIN_NAME}",
#            "Effect": "Allow"
#        }
#    ]
#}
#EoF
#
#aws iam create-policy   \
#  --policy-name fluent-bit-policy \
#  --policy-document file://~/environment/logging/fluent-bit-policy.json
#
# 1-3 Create an IAM role
#
#kubectl create namespace logging
#
#eksctl create iamserviceaccount \
#    --name fluent-bit \
#    --namespace logging \
#    --cluster eksworkshop-eksctl \
#    --attach-policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/fluent-bit-policy" \
#    --approve \
#    --override-existing-serviceaccounts
#
# 1-4 생성된 service account 확인하기
#
#kubectl -n logging describe sa fluent-bit


# 2. Manual install ( fluentbit -> fluentd )
# 2-1. namespace 생성하기
kubectl create namespace logging

# 2-2. service account 생성하기
kubectl create sa fluent-bit -n logging

# 2-3. fluentd-bit sa role 설정하기
# 참고파일 받아서 role & rolebinding 관련 yaml 작성하기
wget -O fluent-bit-role.yaml https://www.eksworkshop.com/intermediate/230_logging/deploy.files/fluentbit.yaml
kubectl apply -f fluent-bit-role.yaml

# 2-3. fluent-bit 배포하기 
# 참고파일을 받아서 elasticsearch -> forward로
#      ref yaml ( https://www.eksworkshop.com/intermediate/230_logging/deploy/ )
#      and modify to forward of Output Plugin ( https://docs.fluentd.org/output/forward )
#               ( https://github.com/fluent/fluent-bit-kubernetes-logging/pull/22/files )
# 1) wget https://www.eksworkshop.com/intermediate/230_logging/deploy.files/fluentbit.yaml
# 2) site 정보 참고해서 output을es -> forward로 수정함
fluentbit-forward.yaml


#
