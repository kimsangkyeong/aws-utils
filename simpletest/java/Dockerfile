FROM docker.io/centos:7

MAINTAINER  1.0  kimsangkyeong@gmail.com

# timezone modify
RUN  rm -rf /etc/localtime
RUN  ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# gcc compiler install
RUN  yum update -y
RUN  yum install unzip wget java-1.8.0-openjdk java-1.8.0-openjdk-devel -y

# program binary copy
RUN  JAVALOCATE=`readlink -f /usr/bin/java`;echo "JAVA_HOME=${JAVALOCATE%/*/*/*}" >> /etc/profile
RUN  echo 'PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile
RUN  echo 'CLASSPATH=$JAVA_HOME/jre/lib:$JAVA_HOME/lib/tools.jar' >> /etc/profile
RUN  echo "export  JAVA_HOME PATH CLASSPATH" >> /etc/profile
RUN  wget https://mirror.navercorp.com/apache//ant/binaries/apache-ant-1.10.10-bin.zip
RUN  unzip apache-ant-1.10.10-bin.zip

COPY aws-java-sdk-1.12.9 /aws-java-sdk-1.12.9

ENTRYPOINT ["/usr/bin/sleep","3600"]

