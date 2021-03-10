#! /bin/sh


# Configure Cluster Autoscaler(CA) 구성 정보
#   - https://www.eksworkshop.com/beginner/080_scaling/deploy_ca/

# cluster Autoscaler
wget https://www.eksworkshop.com/beginner/080_scaling/deploy_ca.files/cluster-autoscaler-autodiscover.yaml

# CA를 사용하려면, 상기 yaml 파일을 참조하여 AWS Auto Scaling Group 을 parameter에 셋팅 등 구성 정보 수정 필요.

