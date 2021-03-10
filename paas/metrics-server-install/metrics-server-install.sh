#! /bin/sh

# component yaml 다운로드하기
#     - https://www.eksworkshop.com/beginner/080_scaling/deploy_hpa/
wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.1/components.yaml

# component 설치하기
kubectl apply -f components.yaml

# 설치 점검하기
kubectl get apiservice v1beta1.metrics.k8s.io -o json | jq '.status'



