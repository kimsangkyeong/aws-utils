#! /bin/sh

# helm repository 추가하기
helm repo add stable https://charts.helm.sh/stable

# helm install
helm install kube-ops-view \
stable/kube-ops-view \
--set service.type=LoadBalancer \
--set rbac.create=True

# 점검 하기
helm list
kubectl get svc kube-ops-view | tail -n 1 | awk '{ print "Kube-ops-view URL = http://"$4 }'
