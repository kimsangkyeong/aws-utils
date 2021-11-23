### eksctl addons 설치하기 : https://eksctl.io/usage/addons/

1.  VPC-CNI addon 설치하기

1) Cluster 설치 버전 확인하기

kubernetes get ds -A -o wide
  .출력 정보 중 aws-node의 Image 버전 정보를 확인한다.
  .출력 예시 : 

  NAMESPACE     NAME         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE   CONTAINERS   IMAGES                                                                           SELECTOR
kube-system   aws-node     2         2         2       2            2           <none>          90m   aws-node     602401143452.dkr.ecr.us-west-1.amazonaws.com/amazon-k8s-cni:v1.7.5-eksbuild.1    k8s-app=aws-node
kube-system   kube-proxy   2         2         2       2            2           <none>          90m   kube-proxy   602401143452.dkr.ecr.us-west-1.amazonaws.com/eks/kube-proxy:v1.19.8-eksbuild.1   k8s-app=kube-proxy

2) VPC-CNI addon 설치하기
config 파일 작성 : attachPolicy, attachPolicyARNs and serviceAccountRoleARN 중에서 최대 1개 설정
vi vpc-cni-conf.yaml
-----
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: exmaple-cluster
  region: us-west-1
  version: "1.19"

iam:
  withOIDC: true

addons:
- name: vpc-cni
  version: 1.7.5 # optional
  attachPolicyARNs: #optional
  - arn:aws:iam::aws:policy/AmazonEKS_CNI_ds07297_Policy
  serviceAccountRoleARN: arn:aws:iam::aws:policy/AmazonEKSCNIAccess # optional
  tags: # optional
    team: eks
    creater: ds0797
  attachPolicy: # optional
    Statement:
    - Effect: Allow
      Action:
      - ec2:AssignPrivateIpAddresses
      - ec2:AttachNetworkInterface
      - ec2:CreateNetworkInterface
      - ec2:DeleteNetworkInterface
      - ec2:DescribeInstances
      - ec2:DescribeTags
      - ec2:DescribeNetworkInterfaces
      - ec2:DescribeInstanceTypes
      - ec2:DetachNetworkInterface
      - ec2:ModifyNetworkInterfaceAttribute
      - ec2:UnassignPrivateIpAddresses
      Resource: '*'
----

eksctl create addon -f vpc-cni-conf.yaml


