FROM docker.io/centos:7

MAINTAINER  1.0  kimsangkyeong@gmail.com

# timezone modify 
RUN  rm -rf /etc/localtime
RUN  ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# gcc compiler install
RUN  yum update -y 
RUN  yum install unzip -y 

# program binary copy
COPY awscliv2.zip /
RUN  unzip /awscliv2.zip
RUN  /aws/install

ENTRYPOINT ["/usr/bin/sleep","3600"]
