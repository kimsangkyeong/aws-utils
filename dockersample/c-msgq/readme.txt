0. docker hub에계정 등록하기
0. 서버의 docker 기동상태 점검 : 
   system status docker
   => inactive 이면 systemctl start docker
1. docker login
   #docker 프로세스가 push/pull을 docker hub repository에 접근 권한 부여하기

2. msq 프로그램 컴파일 테스트: gcc msgqrcv.c -o /var/tmp/msgqrcv, gcc msgqsnd.c -o /var/tmp/msgqsnd
                           msgtest.sh 내의 경로는 Docker 내의 복사경로 고려해서 작성
3. Dockerfile 점검 
   ( program compile 환경과 동일하게 필요한 package 설치가 필요하면, 
     Docker file에 설치하도록 명령어를 수행한다. 
       OS  : cat /etc/system-release
             => CentOS Linux release 7.6.1810 (Core)
       gcc : gcc --version
             => gcc version 4.8.5 20150623 (Red Hat 4.8.5-39) (GCC)
     => gcc library가 필요하다고 가정했을 경우 예시의 Dockerfile 처럼 yum 으로 설치가능
   )
4. sudo docker build -f Dockerfile --tag cpgm-msgqueue:1.0 .
5. sudo docker images
6. sudo docker run -d --name msgqueue cpgm-msgqueue:1.0  

## operation
 sudo docker ps
 sudo docker container logs -f <CONTAINER ID>  # log 추적기능
 sudo docker container logs -f <CONTAINER NAME>  # log 추적기능
 sudo docker container logs -f msgqueue  # log 추적기능
 sudo docker container stop <CONTAINER ID> # container 중지하기
 sudo docker container start <CONTAINER ID> # container 재시작하기
 sudo docker container rm <CONTAINER ID> # container 삭제하기
 sudo docker container rm <CONTAINER NAME> # container 삭제하기
 sudo docker rmi -f <CONTAINER ID>  # image 강제 삭제할 경우
 sudo docker exec -it <CONTAINER NAME> /bin/sh #container 에 접속

++++++++++
0. 참고 : https://docs.aws.amazon.com/AmazonECR/latest/userguide/getting-started-cli.html

1. docker 프로세스가 push/pull을 ECR repository에 접근 권한 부여하기
   # ecr repository login 권한 획득
   # aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.region.amazonaws.com
   # aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin 592806604814.dkr.ecr.us-west-1.amazonaws.com

2. docker image를 ecr 저장소로 보내기위한 tag 설정
 sudo docker tag cpgm-msgqueue:1.0 592806604814.dkr.ecr.us-west-1.amazonaws.com/ds07297-cpgm-msgqueue:1.0

3. docker image를 ecr 저장소로 push 하기
 sudo docker push 592806604814.dkr.ecr.us-west-1.amazonaws.com/ds07297-cpgm-msgqueue:1.0

