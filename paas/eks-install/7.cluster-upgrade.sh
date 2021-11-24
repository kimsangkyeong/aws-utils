### eks control plaine version upgrade 
참고 URL : https://eksctl.io/usage/cluster-upgrade/

1. 이용가능한 다음 버전으로 Control Plane upgrade 하기

eksctl upgrade cluster --name <clusterName> --approve

2. 특정 버전으로 Upgrade 하기

eksctl upgrade cluster --name <clusterName> --version=1.21 --approve

3. Addon Upgrade 하기

=> 4.addons-install.sh 의 명령어 참고하기

eksctl update addon --name vpc-cni --name <clusterName> --force

4. Nodegroup Upgrade 하기

## 가장최신버전으로 Upgrade 하기
eksctl upgrade nodegroup --name <nodegroupName> --cluster <clusterName> 

## 특정 kubernetes version의 최신버전으로 Upgrade 하기
eksctl upgrade nodegroup --name mngrp-fe --cluster ds0797-eks --kubernetes-version=1.20

** 참고 : nodegroup에 labels를 추가하여 kubernetes nodes에 적용할 수있다.

eksctl get labels --cluster ds07297-eks --nodegroup mngrp-fe 
eksctl set labels --cluster ds07297-eks --nodegroup mngrp-fe --labels tester=ds07297
eksctl unset labels --cluster ds07297-eks --nodegroup mngrp-fe --labels tester=ds07297

