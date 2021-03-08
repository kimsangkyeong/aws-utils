#! /usr/bin/sh

# Step1. Istioctl로 설치하기
#
#        -https://istio.io/latest/docs/setup/install/istioctl/ 
#          

# Istio release 다운로드 하기
#        -https://istio.io/latest/docs/setup/getting-started/#download
curl -L https://istio.io/downloadIstio | sh -
cd istio-1.9.0
export PATH=$PWD/bin:$PATH

# profile 정보 조회하기
istioctl profile dump default -o yaml > default-values.yaml
istioctl profile dump demo -o yaml > demo-values.yaml

# istio 설치하기 
#   IstioOperator Options : https://istio.io/latest/docs/reference/config/istio.operator.v1alpha1/

istioctl install -f default-values.yaml

# 점검하기
kubectl get all -n istio-system 

# istio-injection 설정하기
kubectl label namespace default istio-injection=enabled

# 샘플 앱 배포하기
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl get pod,svc

# 앱 점검하기
kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -sS productpage:9080/productpage | grep -o "<title>.*</title>"

# istio gateway와 application 연결하기
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml

# configuration 점검하기
istioctl analyze

# 점검하기
ELB=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
http://${ELB}/productpage

# addon dashboard
#-- prometheus, grafana가 따로 설치된 경우addon을 targetting 한다.
#-- 별도 설치 후 연결하기가 잘 안되어서 addon으로 같이 설치함
kubectl apply -f samples/addon/jaeger.yaml
kubectl apply -f samples/addon/kiali.yaml
#-- kiali 설치 시 오류 발생(unable to recognize "samples/addons/kiali.yaml": no matches for kind "MonitoringDashboard" in version "monitoring.kiali.io/v1alpha1") => kiali.yaml의 crd에 --- 2개 연속으로 해서 발생하는 오류로 판단됨. --- ... 짝을 이루도록 수정 후 설치할 것
#-- kiali에서 외부 prometheus 설정확대하기참조 
#   https://kiali.io/documentation/latest/runtimes-monitoring/#_prometheus_configuration
kubectl apply -f samples/addon/extras/zipkin.yaml
kubectl apply -f samples/addon/prometheus.yaml
kubectl apply -f samples/addon/grafana.yaml

# kiali Dashboard
kubectl port-forward -n istio-system  deployment/kiali 20001
http://localhost:20001/kiali

#####
# Step2. Helm으로 설치하기 
#
#        -https://istio.io/latest/docs/setup/install/helm/
#

# helm repository 추가하기

# 설치할 namespace 생성하기

# helm 설치하기

# 점검하기
#kubectl get pod -n istio-system -l app=kibana -w
#kubectl port-forward -n istio-system  deployment/kibana-kibana 5601
