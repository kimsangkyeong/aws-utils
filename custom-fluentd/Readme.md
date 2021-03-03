># 목적 : elasticsearch plugin을 포함하는 custom-fluentd 만들기
>## 참고 : https://github.com/garystafford/custom-fluentd
>##        https://hub.docker.com/r/fluent/fluentd/

## Docker Image 만들기
|순서|내용|참고|
|-|-|-|
|1|docker 기동하기|sudo systemctl docker start|
|2|docker login 하기|sudo docker login|
|3|Dockerfile 보완하기|vi Dockerfile|
|4|docker build 하기|sudo docker build -t <repository>/custom-fluentd:v1.0 .|
|5|docker repository upload 하기|sudo docker push|
|-|-|-|
