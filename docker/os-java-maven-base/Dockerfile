FROM openshift/base-centos7:latest
COPY jdk-8u131-linux-x64.rpm .
RUN yum localinstall jdk-8u131-linux-x64.rpm -y
COPY apache-maven-3.5.0-bin.tar.gz .
RUN tar -xvzf apache-maven-3.5.0-bin.tar.gz
RUN mv apache-maven-3.5.0 /opt
ENV M2_HOME=/opt/apache-maven-3.5.0
ENV JAVA_HOME=/usr/java/jdk1.8.0_131
ENV PATH=$M2_HOME/bin:$PATH
RUN echo "`mvn -v`"


