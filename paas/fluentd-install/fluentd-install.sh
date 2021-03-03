#! /usr/bin/sh

# Step1. AWS eksworkshop 을 참고하여 배포하기 정보 
#        Amazon EKS Cluster에IAM Role을 가지고 Kubernetetes service account에 IAM Role을 연결가능 
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
#cat <<EoF > ~/environment/logging/fluentd-policy.json
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
#  --policy-name fluentd-policy \
#  --policy-document file://~/environment/logging/fluentd-policy.json
#
# 1-3 Create an IAM role
#
#kubectl create namespace logging
#
#eksctl create iamserviceaccount \
#    --name fluentd \
#    --namespace logging \
#    --cluster eksworkshop-eksctl \
#    --attach-policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/fluentd-policy" \
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
kubectl create sa fluentd -n logging

# 2-3. fluentd sa role 설정하기
# 참고파일을 받아서 role & rolebinding 관련 yaml 작성하기
wget -O fluentd-role.yaml https://www.eksworkshop.com/intermediate/230_logging/deploy.files/fluentbit.yaml
kubectl apply -f fluentd-role.yaml

# 2-4. fluetd를 deployment로 배포하기
# 참고파일을 받아서 daemonset -> deployment 수정, serviceAccountName: fluentd 추가
#            ( https://github.com/fluent/fluentd-kubernetes-daemonset )
# ## fluent-bit와 fluentd는 config 파일 구성이 다름 유의할 것 
#   (https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/configuration-file,
#    https://docs.fluentd.org/configuration/config-file)
# ## custom flentd를 만들어서 사용하기 : https://github.com/garystafford/custom-fluentd
# ## input은 fluent-bit에서 전달한 데이타로 설정하도록 구성한다.
kuebctl apply -f fluentd-es-configmap.yaml

#
