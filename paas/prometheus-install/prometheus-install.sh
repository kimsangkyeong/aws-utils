#! /usr/bin/sh

# Step1. helm chart 조회하기
#
#        - https://helm.sh > 상당메뉴 Charts 클릭 > https://artifacthub.io 검색창에정보입력
#        - "prometheus" > 검색결과 중 verified publisher & ORG 정보로 신뢰 chart 선택하기
#
# Step2. 가이드에 따라서 helm repo 등록 및 설치하기
#
#        - https://artifacthub.io/packages/helm/prometheus-community/prometheus
#

# helm repository 추가하기
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add kube-state-metrics https://kubernetes.github.io/kube-state-metrics
helm repo update

# 설치할 namespace 생성하기
kubectl create namespace prometheus

# chart value 확인하기
helm show values prometheus-community/prometheus > values.yaml

# helm 설치하기 
helm install -n prometheus prometheus prometheus-community/prometheus \
	--set alertmanager.persistentVolume.storageClass="gp2" \
	--set server.persistentVolume.storageClass="gp2" \
	--set server.nodeSelector."node\\.role"=mon \
	--set server.podLabels.creator=ds07297 \
	--set pushgateway.nodeSelector."node\\.role"=mon \
	--set pushgateway.podLabels.creator=ds07297

# 점검하기
kubectl get pods --namespace=prometheus -l app=prometheus -w

kubectl port-forward -n prometheus deploy/prometheus-server 8080:9090
http://localhost:8080/targets
