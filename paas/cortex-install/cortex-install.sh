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
	--set alertmanager.podLabels.approle=alert-metrics \
	--set compactor.persistentVolume.storageClass="gp2" \
	--set compactor.podLabels.approle=compactor-metrics \
	--set configs.podLabels.approle=configs-cortex \
	--set distributor.podLabels.approle=distributor-cortex \
	--set ingester.podLabels.approle=ingester-cortex \
	--set nginx.podLabels.approle=nginx-cortex \
	--set querier.podLabels.approle=querier-cortex \
	--set ruler.podLabels.approle=ruler-cortex \
	--set serviceAccount.name=cortex \
	--set store_gateway.podLabels.approle=store_gateway-cortex \
	--set table_manager.podLabels.approle=store_gateway-cortex 

# 점검하기
kubectl get pods --namespace=cortex -w

# UI로 점검하기
kubectl --namespace cortex port-forward service/cortex
curl http://127.0.0.1:/api/prom/label

