#! /usr/bin/sh

## eksctl을 이용하여 미리 Cluster에서 생성해 놓은 subnet 정보를 이용하여 EKS를 생성한다.
# I. EKS Cluster 단독 생성하기
CLUSTER_NAME="ds07297-eks"
CLUSTER_VPC_NAME="ds07297-d-vpc"               # 존재하는 VPC의 ID를 얻기 위해 Tag Name을 기준으로 조회함. < 정보 확인 할 것 >
CLUSTER_NODESNET_KEYWORD="-dataplane-"      # 1. Dual Cidr EKS용 VPC의 CF로 만들어 지면 사전 예약어로 사용하고 있어서 Tag Name에 포함된 문자열을 기준으로 조회함.
CLUSTER_REGION="us-west-1"
CLUSTER_TAGS="{ Env: develop, Operator: admin, Project: ds07297 }"
CLUSTER_KUBERNETES_VERSION='"1.18"'

# 1. subnet id 얻어오기
# 1-1. vpc id 얻어오기
CLUSTER_VPC_ID=$(aws ec2 describe-vpcs | jq -r  " .Vpcs[] | if has(\"Tags\") then  select(.Tags[].Value==\"${CLUSTER_VPC_NAME}\") | .VpcId else \"\"end " | tr '\n' ',' | sed 's/,//g')
# 1-2. available zone의 public, private subnet id 얻어오기
AZ1="us-west-1b"
AZ2="us-west-1c"
# 1-2. available zone 1 의 public subnet id 얻어오기
CLUSTER_NODESNET_PUBLIC1=$(aws ec2 describe-subnets | jq -r " .Subnets[] | select(.VpcId==\"${CLUSTER_VPC_ID}\") | select(.Tags[].Value | contains(\"${CLUSTER_NODESNET_KEYWORD}\")) | { az : .AvailabilityZone, sid : .SubnetId, sname : .Tags[].Value} | select(.sname | contains(\"${CLUSTER_NODESNET_KEYWORD}\")) | select(.az | contains(\"${AZ1}\")) | select(.sname | contains(\"public\")) | .sid ")
# 1-3. available zone 2 의 public subnet id 얻어오기
CLUSTER_NODESNET_PUBLIC2=$(aws ec2 describe-subnets | jq -r " .Subnets[] | select(.VpcId==\"${CLUSTER_VPC_ID}\") | select(.Tags[].Value | contains(\"${CLUSTER_NODESNET_KEYWORD}\")) | { az : .AvailabilityZone, sid : .SubnetId, sname : .Tags[].Value} | select(.sname | contains(\"${CLUSTER_NODESNET_KEYWORD}\")) | select(.az | contains(\"${AZ2}\")) | select(.sname | contains(\"public\")) | .sid ")
# 1-4. available zone 1 의 private subnet id 얻어오기
CLUSTER_NODESNET_PRIVATE1=$(aws ec2 describe-subnets | jq -r " .Subnets[] | select(.VpcId==\"${CLUSTER_VPC_ID}\") | select(.Tags[].Value | contains(\"${CLUSTER_NODESNET_KEYWORD}\")) | { az : .AvailabilityZone, sid : .SubnetId, sname : .Tags[].Value} | select(.sname | contains(\"${CLUSTER_NODESNET_KEYWORD}\")) | select(.az | contains(\"${AZ1}\")) | select(.sname | contains(\"private\")) | .sid ")
# 1-5. available zone 2 의 private subnet id 얻어오기
CLUSTER_NODESNET_PRIVATE2=$(aws ec2 describe-subnets | jq -r " .Subnets[] | select(.VpcId==\"${CLUSTER_VPC_ID}\") | select(.Tags[].Value | contains(\"${CLUSTER_NODESNET_KEYWORD}\")) | { az : .AvailabilityZone, sid : .SubnetId, sname : .Tags[].Value} | select(.sname | contains(\"${CLUSTER_NODESNET_KEYWORD}\")) | select(.az | contains(\"${AZ2}\")) | select(.sname | contains(\"private\")) | .sid ")

echo "eks cluster vpc : $CLUSTER_VPC_ID "
echo "eks cluster $AZ1 public subnet : $CLUSTER_NODESNET_PUBLIC1"
echo "eks cluster $AZ2 public subnet : $CLUSTER_NODESNET_PUBLIC2"
echo "eks cluster $AZ1 private subnet : $CLUSTER_NODESNET_PRIVATE1"
echo "eks cluster $AZ2 private subnet : $CLUSTER_NODESNET_PRIVATE2"

# RFC1918 https://aws.amazon.com/ko/about-aws/whats-new/2020/10/amazon-eks-supports-configurable-kubernetes-service-ip-address-range/ 
CLUSTER_SERVICEIPV4CIDR="10.2.128.0/17"  

EKSCTL_CLUSTER_DEBUG_LOG_LEVEL=3

# 2. cluster.yaml 파일만들기 

CLUSTER_NAME="ds07297-eks"
cat << EOF > $CLUSTER_NAME"-cluster.yaml"
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: ${CLUSTER_NAME}
  region: ${CLUSTER_REGION}
  version: ${CLUSTER_KUBERNETES_VERSION}
  tags: ${CLUSTER_TAGS}
kubernetesNetworkConfig:
  serviceIPv4CIDR: ${CLUSTER_SERVICEIPV4CIDR}
vpc:
  id: ${CLUSTER_VPC_ID}
  subnets:
    public:
      us-west-1b:
          id: ${CLUSTER_NODESNET_PUBLIC1}
      us-west-1c:
          id: ${CLUSTER_NODESNET_PUBLIC2}
    private:
      us-west-1b:
          id: ${CLUSTER_NODESNET_PRIVATE1}
      us-west-1c:
          id: ${CLUSTER_NODESNET_PRIVATE2}
  clusterEndpoints:
      privateAccess: true
      publicAccess: true
EOF

# 3. EKS Cluster 생성하기
#eksctl create cluster -f $CLUSTER_NAME"-cluster.yaml"

#--------------------------------------------------------------------------------------------------------------

# II. EKS Cluster 의 managed node groups 생성하기
# 1. managed-nodes.yaml 파일만들기

CLUSTER_NAME="ds07297-eks"
CLUSTER_REGION="us-west-1"
CLUSTER_NODE_SSH_PUBLIC_KEY=ds07297-kpair

# cluster managed node 생성하기 
cat << EOF > managed-nodegroups.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
    name: ${CLUSTER_NAME}
    region: ${CLUSTER_REGION}
managedNodeGroups:
  - name: mngrp-fe
    ami: "ami-0ee5bb0be5fd09f21"
    desiredCapacity: 2
    minSize: 1
    maxSize: 5
    volumeSize: 20
    labels: { node.role: fe, env: develop }
    tags: { Creater: ds07297, Env: develop, Operator: admin }
    instanceType: "t3.large"
#    maxPodsPerNode: 50
    privateNetworking: true
    ssh:
      allow: true
      publicKeyName: ${CLUSTER_NODE_SSH_PUBLIC_KEY}
    overrideBootstrapCommand: |
      #!/bin/bash
      /etc/eks/bootstrap.sh ${CLUSTER_NAME} --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup-image=ami-0ee5bb0be5fd09f21'
  - name: mngrp-be
    ami: "ami-0ee5bb0be5fd09f21"
    desiredCapacity: 2
    minSize: 1
    maxSize: 5
    volumeSize: 30
    labels: { node.role: be, env: develop }
    tags: { Creater: ds07297, Env: develop, Operator: admin }
    instanceType: "t3.xlarge"
#    maxPodsPerNode: 100
    privateNetworking: true
    ssh:
      allow: true
      publicKeyName: ${CLUSTER_NODE_SSH_PUBLIC_KEY}
    overrideBootstrapCommand: |
      #!/bin/bash
      /etc/eks/bootstrap.sh ${CLUSTER_NAME} --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup-image=ami-0ee5bb0be5fd09f21'
EOF

eksctl create nodegroup --config-file=managed-nodegroups.yaml


