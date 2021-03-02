#! /usr/bin/sh

# Step1. helm chart 조회하기
#
#        - https://helm.sh > 상당메뉴 Charts 클릭 > https://artifacthub.io 검색창에정보입력
#        - "elasticsearch" > 검색결과 중 verified publisher & ORG 정보로 신뢰 chart 선택하기
#
# Step2. 가이드에 따라서 helm repo 등록 및 설치하기
#
#        - https://artifacthub.io/packages/helm/elastic/elasticsearch
#

# helm repository 추가하기
helm repo add elastic https://helm.elastic.co

# 설치할 namespace 생성하기
kubectl create namespace elastic

# helm 설치하기 
helm install -n elastic elasticsearch elastic/elasticsearch \
	     --version 7.11.1 \
	     --set clusterName="ds07297-mon-es" \
	     --set-string labels.Creator="ds07297" \
	     --set-string labels.approle="logmonitor" \
	     --set nodeSelector."node\\.role"=mon  \
             --set volumeClaimTemplate.storageClassName=gp2 # block Storage
                                     # storageClassName=gp2는eks 생성시 default 설정되어 있어서 파라미터 삭제가능
                                     # 다른 storage Class를 생성하는경우 사용하면 됨


# 점검하기
kubectl get pods --namespace=elastic -l app=ds07297-mon-es-master -w
kubectl port-forward -n elastic svc/ds07297-mon-es-master 9200
