## 클러스터에 대한 IAM OIDC 공급자 생성하기 
참고 URL : https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/enable-iam-roles-for-service-accounts.html

목적  : 서비스 계정에 IAM 역할을 사용하려면, 클러스터에 IAM OIDC 공급자가 있어야 한다.
        클러스터에는 OpenID Connector 발급자 URLdl 연결되어 있다.


1. 클러스터에 기존 IAM OIDC 공급자가 있는지? 확인하기

1) 클러스터의 OIDC 공급자 URL을 확인한다.
aws eks describe-cluster --name <cluster_name> --query "cluster.identity.oidc.issuer" --output text

출력 예시 : https://oidc.eks.us-west-2.amazonaws.com/id/EXAMPLED539D4633E53DE1B716D3041E

2) 계정의 IAM OIDC 공급자를 나열한다. - 이전 출력갑으로 조회
aws iam list-open-id-connect-providers | grep EXAMPLED539D4633E53DE1B716D3041E

출력 예시 : "Arn": "arn:aws-cn:iam::111122223333:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/EXAMPLED539D4633E53DE1B716D3041E"

### 출력이 반환되면, 클러스터에 대한 공급자가 이미 있는 것이다.
    그렇지 않다면, IAM OIDC 공급자를 생성해야 한다.

2. 클러스터에 IAM OIDC 자격 증명 공급자를 생성하기

eksctl utils associate-iam-oidc-provider --cluster <cluster_name> --approve


