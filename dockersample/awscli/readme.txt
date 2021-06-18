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
4. sudo docker build --tag cpgm-hello:1.0 .
5. sudo docker images
6. sudo docker run --name hello cpgm-hello:1.0  
      # 실행이정상이면, output 출력 확인
   => Hello World! - 4/7 15:48:13
      Hello World! - 4/7 15:48:15
   # 백그라운드 수행은 sudo docker run -d --name hello cpgm-hello:1.0

## operation
 sudo docker ps
 sudo docker container logs -f <CONTAINER ID>  # log 추적기능
 sudo docker container stop <CONTAINER ID> # container 중지하기
 sudo docker container start <CONTAINER ID> # container 재시작하기
 sudo docker container rm <CONTAINER ID> # container 삭제하기
 sudo docker container rm <CONTAINER NAME> # container 삭제하기
 sudo docker rmi -f <CONTAINER ID>  # image 강제 삭제할 경우

