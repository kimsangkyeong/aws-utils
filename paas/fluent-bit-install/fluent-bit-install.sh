#! /usr/bin/sh

# 1. Manual install ( fluentbit에서-> fluentd 전달)
# 1-1. namespace 생성하기
kubectl create namespace logging

# 1-2. service account 생성하기
kubectl create sa fluent-bit -n logging

# 1-3. fluent-bit sa role 설정하기
# 참고파일을 받아서 role & rolebinding 관련 yaml 작성하기
wget -O fluentbit-reference.yaml https://www.eksworkshop.com/intermediate/230_logging/deploy.files/fluentbit.yaml
kubectl apply -f fluent-bit-role.yaml

# 1-4. fluet-bit를 daemonset으로 배포하기
# 참고파일을 받아서 serviceAccountName: fluent-bit 추가
#            ( https://github.com/fluent/fluentd-kubernetes-daemonset )
# ## fluent-bit config 참조
#   (https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/configuration-file,
# ## output은 fluentd로 forward 하도록 설정한다.
kuebctl apply -f fluent-bit-forward.yaml

#
