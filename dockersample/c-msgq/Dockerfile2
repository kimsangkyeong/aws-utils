FROM docker.io/centos:7

MAINTAINER  1.0  kimsangkyeong@gmail.com

# timezone modify 
RUN  rm -rf /etc/localtime
RUN  ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# gcc compiler install
RUN  yum install -y gcc

# program binary copy
COPY msgqsnd /var/tmp
COPY msgqrcv /var/tmp
COPY msgtest.sh /var/tmp

ENTRYPOINT ["/var/tmp/msgtest.sh"]
