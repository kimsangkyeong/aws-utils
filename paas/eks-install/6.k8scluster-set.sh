### EKS 생성 Cluster 정보 kubeconfig에 자동 생성하기
참고 URL : https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/create-kubeconfig.html

1. AWS 임시 자격증명 확인하기
aws sts get-caller-identity

2. kubeconfig 자동 생성하기

2-1) aws cli의 버전이 1.16.156 이상일것 
aws --version

2-2) AWS CLI update-kubeconfig 명령으로 자동 생성하기

aws eks --region <region-code> update-kubeconfig --name <cluster_name>

2-3) 구성 확인하기

kubectl get svc
