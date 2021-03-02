#! /usr/bin/sh

# Step1. helm chart 조회하기
#
#        - https://helm.sh > 상당메뉴 Charts 클릭 > https://artifacthub.io 검색창에정보입력
#        - "coretex" > 검색결과 중 verified publisher & ORG 정보로 신뢰 chart 선택하기
#
# Step2. 가이드에 따라서 helm repo 등록 및 설치하기
#
#        - https://artifacthub.io/packages/helm/cortex/cortex
#

# helm repository 추가하기
helm repo add cortex-helm https://cortexproject.github.io/cortex-helm-chart
helm repo update

# 설치할 namespace 생성하기
kubectl create namespace cortex

# chart value 확인하기
helm show values cortex-helm/cortex > values.yaml

# helm version 검색하기
helm search repo cortex-helm

# helm 설치하기 
helm install -n cortex cortex cortex-helm/cortex \
	--set alertmanager.persistentVolume.storageClass="gp2" \
	--set server.persistentVolume.storageClass="gp2" \
	--set server.nodeSelector."node\\.role"=mon \
	--set server.podLabels.approle=merge-metrics \
	--set pushgateway.nodeSelector."node\\.role"=mon \
	--set pushgateway.podLabels.approle=merge-metrics

# 점검하기
kubectl get pods --namespace=cortex -l approle=cortex -w

