# nginx를 설치하기 위한 참고 URL
# http://nginx.org/en/linux_packages.html

# 1. 사전 package update 
$ sudo yum install yum-utils

# 2. yum repository 설정을 위해 /etc/yum.repos.d/nginx.repo 에 다음 내용 추가
$ sudo vi /etc/yum.repos.d/nginx.repo

[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

## 주의사항 : amazon linux를 사용하는 경우에는 $releasever이 centos 버전이 아닌 amazon linux 버전값 이 셋팅되기 때문에
##            $releasever -> 7 or 8 값으로 치환한다.  ex) baseurl=http://nginx.org/packages/centos/7/$basearch/

# 3. By default, the repository for stable nginx packages is used. 
#    If you would like to use mainline nginx packages, run the following command:
#    tcp/udp proxy를 위한 stream 모듈은 nginx 1.19 버전에서 지원됨
$ sudo yum-config-manager --enable nginx-mainline

# 4. nginx install 하기
$ sudo yum install nginx -y

## --------- Configuration 
# default config :  /etc/nginx/nginx.conf 
# 5. http와 tcp proxy를 모두 처리하고 싶은 경우는 http와 stream을 모두 기술한다.
#    stream {
#        server {
#	      listem 9999;
#	      proxy_pass  ip:port;
#	      ..
#	}
#     }
#     http {
#        server {
#        }
#     }
#
## ---------- nginx 사용법 
# a. config 오류 점검  :  nginx -c  $PWD/nginx-ext.conf  -t
# b. terminal에서 실행 :  nginx                  => default config : /etc/nginx/nginx.conf 
#                         nginx -c $PWD/new.conf    => configure file을 입력으로 주기

# c. ex : sudo nginx -c $PWD/nginx-ext.conf
#         < proxy 서버를 설치한 EC2에서 실행 >
#         < stop -> start시 S3에서 nginx config 가져와서 systemctl 서비스 등록하는 방법 준비 필요 >
#         < 동일port는 먼저 만나는 server 혹은 default server로 등록된 것에서 처리가 되기 때문에,
#           다른 server_name으로 구분해서 proxy 처리하고자 하는 경우는 listen port를 달리 등록필요>
#
