### eksctl addons 설치하기 : https://eksctl.io/usage/addons/

1.  VPC-CNI addon 설치하기

1) Cluster 설치 버전 확인하기

kubectl get ds -A -o wide

  .출력 정보 중 aws-node의 Image 버전 정보를 확인한다.
  .출력 예시 : 

  NAMESPACE     NAME         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE   CONTAINERS   IMAGES                                                                           SELECTOR
kube-system   aws-node     2         2         2       2            2           <none>          90m   aws-node     602401143452.dkr.ecr.us-west-1.amazonaws.com/amazon-k8s-cni:v1.7.5-eksbuild.1    k8s-app=aws-node
kube-system   kube-proxy   2         2         2       2            2           <none>          90m   kube-proxy   602401143452.dkr.ecr.us-west-1.amazonaws.com/eks/kube-proxy:v1.19.8-eksbuild.1   k8s-app=kube-proxy

2) VPC-CNI addon 설치하기

eksctl create addon --cluster <Cluster-Name> --name vpc-cni 
eksctl create addon --cluster <Cluster-Name> --name vpc-cni --force  
## --force는 기존에 존재를 하고 있으면, 강제로 replace 처리하는 option

or  =============

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

    ================

3) 설치한 addon 정보 확인하기 : update에 사용할 수 있는 버전이 있는지?를 확인할 수 있음

eksctl get addon --cluster <Cluster-Name> --name vpc-cni 
eksctl get addons --cluster <Cluster-Name>
## <Cluster-Name>에추가된 addon 정보를 모두 조회할 수 있음.

4) 버전 Upgrade 하기
eksctl update addon --name vpc-cni --cluster <Cluster-Name> --force
eksctl update addon --name vpc-cni --version <new target version> --cluster <Cluster-Name> --force
## 특정버전으로 update하고자 하는 경우 --version <new target version> 추가

2.  kube-proxy addon 설치하기

1) Cluster 설치 버전 확인하기

kubectl get ds -A -o wide

  .출력 정보 중 kube-proxy의 Image 버전 정보를 확인한다.

2) kube-proxy addon 설치하기

eksctl create addon --name kube-proxy --cluster <Cluster-Name>
eksctl create addon --name kube-proxy --cluster <Cluster-Name> --force

3) 설치한 addon 정보 확인하기 : update에 사용할 수 있는 버전이 있는지?를 확인할 수 있음

eksctl get addon --cluster <Cluster-Name> --name kube-proxy
eksctl get addons --cluster <Cluster-Name>
## <Cluster-Name>에추가된 addon 정보를 모두 조회할 수 있음.

4) 버전 Upgrade 하기
eksctl update addon --name kube-proxy --cluster <Cluster-Name> --force
eksctl update addon --name kube-proxy --version <new target version> --cluster <Cluster-Name> --force
## 특정버전으로 update하고자 하는 경우 --version <new target version> 추가

3.  core-dns addon 설치하기

1) Cluster 설치 버전 확인하기

kubectl get pod -A -o wide

  .출력 정보 중 coredns의 Image 버전 정보를 확인한다.
kubectl get pod <coredns pod> -n kube-system -o=jsonpath="{.spec.containers[].image}"

2) coredns addon 설치하기

eksctl create addon --name coredns --cluster <Cluster-Name>
eksctl create addon --name coredns --cluster <Cluster-Name> --force

3) 설치한 addon 정보 확인하기 : update에 사용할 수 있는 버전이 있는지?를 확인할 수 있음

eksctl get addon --cluster <Cluster-Name> --name coredns
eksctl get addons --cluster <Cluster-Name>
## <Cluster-Name>에추가된 addon 정보를 모두 조회할 수 있음.

4) 버전 Upgrade 하기
eksctl update addon --name coredns --cluster <Cluster-Name> --force
eksctl update addon --name coredns --version <new target version> --cluster <Cluster-Name> --force
## 특정버전으로 update하고자 하는 경우 --version <new target version> 추가

