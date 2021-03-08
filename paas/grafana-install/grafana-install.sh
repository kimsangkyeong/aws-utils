#! /usr/bin/sh

# Step1. helm chart 조회하기
#
#        - https://helm.sh > 상당메뉴 Charts 클릭 > https://artifacthub.io 검색창에정보입력
#        - "grafana" > 검색결과 중 verified publisher & ORG 정보로 신뢰 chart 선택하기
#
# Step2. 가이드에 따라서 helm repo 등록 및 설치하기
#
#        - https://artifacthub.io/packages/helm/grafana/grafana
#

# helm repository 추가하기
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# 설치할 namespace 생성하기
kubectl create namespace grafana

# chart value 확인하기
helm show values grafana/grafana > values.yaml

# helm 설치하기 

# grafana datasource 설정 yaml 파일 생성하기
cat << EoF > ./grafana.yaml
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus-server.prometheus.svc.cluster.local
      access: proxy
      isDefault: true
EoF

helm install -n grafana grafana grafana/grafana \
        --set persistence.storageClassName="gp2" \
        --set persistence.enabled=true \
        --set adminPassword='EKS!sAWSome' \
	--set nodeSelector."node\\.role"=mon \
        --values ./grafana.yaml \
        --set service.type=ClusterIP \
        --set service.labels.creator=ds07297 \ 
        --set podLabels.creator=ds07297

# 점검하기
kubectl get pods --namespace=grafana -l app.kubernetes.io/name=grafana -w

## service.Type=LoadBalancer 일 경우
export ELB=$(kubectl get svc --namespace grafana grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "http://$ELB:80"
## service.Type=ClusterIP 일 경우
kubectl port-forward -n grafana deployment/grafana 8081:3000
http://localhost:8081/

# password 획득하기
kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# chart 
1. Cluster Monitoring Dashboard : + Import > 3119 > Load > Prometheus > Import
2. Pods Monitoring Dashboard : + Import > 6417 > Load > Kubernetes Pods Monitoring > change(uid) > Prometheus > Import

