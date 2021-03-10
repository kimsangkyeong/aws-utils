#! /bin/sh


# sample program 배포
#   - https://www.eksworkshop.com/beginner/080_scaling/test_hpa/
kubectl create deployment php-apache --image=us.gcr.io/k8s-artifacts-prod/hpa-example
kubectl set resources deploy php-apache --requests=cpu=200m
kubectl expose deploy php-apache --port 80

kubectl get pod -l app=php-apache

# hpa resource 생성
kubectl autoscale deployment php-apache `#The target average CPU utilization` \
    --cpu-percent=50 \
    --min=1 `#The lower limit for the number of pods that can be set by the autoscaler` \
    --max=10 `#The upper limit for the number of pods that can be set by the autoscaler`

# 점검하기
kubectl get hpa

# 다른 terminal에서  부하 추가하기
kubectl --generator=run-pod/v1 run -i --tty load-generator --image=busybox /bin/sh
while true; do wget -q -O - http://php-apache; done

# autoscaling 점검하기
kubectl get hpa -w


