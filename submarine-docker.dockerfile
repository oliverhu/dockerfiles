FROM ubuntu:18.04
ENV HADOOP_VERSION 2.9.2
ENV HADOOP_URL https://www.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
RUN apt-get update
RUN apt-get -y install apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     git \
     software-properties-common \
     openjdk-8-jdk vim \
     wget python3-distutils
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

RUN set -x \
    && curl -fSL "$HADOOP_URL" -o /tmp/hadoop.tar.gz \
    && tar -xvf /tmp/hadoop.tar.gz -C /opt/ \
    && rm /tmp/hadoop.tar.gz*
COPY hadoop /opt/hadoop-$HADOOP_VERSION/etc/hadoop
RUN cd ~
RUN git clone https://github.com/apache/submarine.git
RUN cd submarine

RUN submarine/dev-support/mini-submarine/submarine/build_python_virtual_env.sh
RUN mv venv/ /opt/
RUN chmod +r -R /opt/venv 
ENV HADOOP_HOME=/opt/hadoop-$HADOOP_VERSION/
ENV HADOOP_YARN_HOME=/opt/hadoop-$HADOOP_VERSION/
ENV HADOOP_HDFS_HOME=/opt/hadoop-$HADOOP_VERSION/
ENV HADOOP_CONF_DIR=/opt/hadoop-$HADOOP_VERSION/etc/hadoop
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# Crate user
RUN groupadd -g 5000 hadoop
RUN useradd -u 1000 -g hadoop pi
RUN mkdir /home/pi
RUN chown pi:hadoop /home/pi
