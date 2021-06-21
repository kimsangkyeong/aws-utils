#####
#  java 설치: # yum install java-1.8.0-openjdk
#             # yum install java-1.8.0-openjdk-devel
#             # readlink -f /usr/bin/java
#                /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.242.b08-0.el7_7.x86_64/jre/bin/java
#             # vi /etc/profile
#                 JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.242.b08-0.el7_7.x86_64
#                 PATH=$PATH:$JAVA_HOME/bin
#                 CLASSPATH=$JAVA_HOME/jre/lib:$JAVA_HOME/lib/tools.jar
#                 export JAVA_HOME PATH CLASSPATH
#
#  ant 설치 : apache-ant-1.10.10-bin.zip
#  aws-sdk 설치 :  - 설치하위디렉토리의 sample로 이동하여 ant를 실행하여 테스트 가능
#                  aws-java-sdk.zip
#####
0. docker hub에계정 등록하기
0. 서버의 docker 기동상태 점검 :
   system status docker
   => inactive 이면 systemctl start docker
1. docker login
2. hello.c 소스 컴파일 및 테스트 : gcc hello.c -o hello.out; hello.out
3. Dockerfile 점검
   ( program compile 환경과 동일하게 필요한 package 설치가 필요하면,
     Docker file에 설치하도록 명령어를 수행한다.
     - hello.c 샘플 프로그램의 Local 컴파일 환경
       OS  : cat /etc/system-release
             => CentOS Linux release 7.6.1810 (Core)
       gcc : gcc --version
             => gcc version 4.8.5 20150623 (Red Hat 4.8.5-39) (GCC)
     => gcc library가 필요하다고 가정했을 경우 예시의 Dockerfile 처럼 yum 으로 설치가능
   )
4. sudo docker build --tag purecap/awsjavasdk:1.0 .
5. sudo docker images
6. sudo docker run --name awsjavasdk purecap/awsjavasdk:1.0
      # 실행이정상이면, output 출력 확인
   # 백그라운드 수행은 sudo docker run -d --name awsjavasdk purecap/awsjavasdk:1.0

## operation
 sudo docker ps
 sudo docker container logs -f <CONTAINER ID>  # log 추적기능
 sudo docker container stop <CONTAINER ID> # container 중지하기
 sudo docker container start <CONTAINER ID> # container 재시작하기
 sudo docker container rm <CONTAINER ID> # container 삭제하기
 sudo docker container rm <CONTAINER NAME> # container 삭제하기
 sudo docker rmi -f <CONTAINER ID>  # image 강제 삭제할 경우


