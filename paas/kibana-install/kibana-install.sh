#! /usr/bin/sh

# Step1. helm chart 조회하기
#
#        - https://helm.sh > 상당메뉴 Charts 클릭 > https://artifacthub.io 검색창에정보입력
#        - "kibana" > 검색결과 중 verified publisher & ORG 정보로 신뢰 chart 선택하기
#
# Step2. 가이드에 따라서 helm repo 등록 및 설치하기
#
#        - https://artifacthub.io/packages/helm/elastic/kibana
#

# helm repository 추가하기
helm repo add elastic https://helm.elastic.co

# 설치할 namespace 생성하기
kubectl create namespace kibana

# helm 설치하기
helm install -n kibana kibana elastic/kibana \
	     --version 7.11.1 \
	     --set nodeSelector."node\\.role"=mon  \
             --set-string labels.Creator="ds07297" \
	     --set elasticsearchHosts="http://ds07297-mon-es-master.elastic.svc.cluster.local:9200"  
                   # service name & namespace 포함할 것.

# 참고사항 : workgroup을 3개 node로 elasticsearch 배포상태에에서는 배포 시 pending
#            eksctl scale nodegroup .. 으로 4개 증대시 배포완료. 
#            배포환경의 영향도 분석 필요. (affinity 등 )

# 점검하기
kubectl get pod -n kibana -l app=kibana -w
kubectl port-forward -n kibana  deployment/kibana-kibana 5601
