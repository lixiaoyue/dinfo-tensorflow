FROM tensorflow/tensorflow:1.4.1-devel-py3

MAINTAINER zhangjianjun <zhangjianjun1@ultrapower.com.cn>

# upgrade pip
RUN pip --no-cache-dir install --upgrade pip

RUN pip --no-cache-dir install jieba gensim -i https://pypi.tuna.tsinghua.edu.cn/simple/

ENV DEBIAN_FRONTEND noninteractive

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

#预配置krb5-config
RUN echo 'krb5-config krb5-config/default_realm string EXAMPLE.COM' | debconf-set-selections && \
    echo 'krb5-config krb5-config/admin_server string 127.0.0.1' | debconf-set-selections && \
    echo 'krb5-config krb5-config/kerberos_servers string 127.0.0.1' | debconf-set-selections

RUN apt-get update && \
    apt-get install -y vim openssh-server \
    krb5-user \
    libpam-krb5 --no-install-recommends

# 修改root密码
RUN echo 'root:root' |chpasswd 

# edit /etc/ssh/sshd_config
RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -ri 's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config && \
    echo "service ssh start" > /run_jupyter.sh && \
    echo 'jupyter notebook "$@"' >> /run_jupyter.sh && \
    mkdir -p /var/run/sshd && \
    chmod 755 /var/run/sshd

# remove apt related cache
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*
	
ADD jdk-8u171-linux-x64.tar.gz /opt/
ADD hadoop-2.7.6.tar.gz /opt/
COPY entrypoint.sh /
#设置环境变量
RUN echo 'export JAVA_HOME=/opt/jdk1.8.0_171' >> /etc/profile && \
    echo 'export HADOOP_HOME=/opt/hadoop-2.7.6' >> /etc/profile && \
    echo 'export HADOOP_HDFS_HOME=/opt/hadoop-2.7.6' >> /etc/profile && \
    echo 'export LD_LIBRARY_PATH=${JAVA_HOME}/jre/lib/amd64/server' >> /etc/profile && \
    echo 'export PATH=${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:$PATH' >> /etc/profile && \
    echo 'export JAVA_HOME=/opt/jdk1.8.0_171' >> /etc/bash.bashrc && \
    echo 'export HADOOP_HOME=/opt/hadoop-2.7.6' >> /etc/bash.bashrc && \
    echo 'export HADOOP_HDFS_HOME=/opt/hadoop-2.7.6' >> /etc/bash.bashrc && \
    echo 'export LD_LIBRARY_PATH=${JAVA_HOME}/jre/lib/amd64/server' >> /etc/bash.bashrc && \
    echo 'export PATH=${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:$PATH' >> /etc/bash.bashrc 

ENV JAVA_HOME=/opt/jdk1.8.0_171
ENV HADOOP_HOME=/opt/hadoop-2.7.6
ENV HADOOP_HDFS_HOME=/opt/hadoop-2.7.6
ENV LD_LIBRARY_PATH=${JAVA_HOME}/jre/lib/amd64/server
ENV PATH=${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:$PATH

#拷贝算法包
ADD ultra.zip /usr/local/lib/python3.5/dist-packages/

#kerberos认证文件所在卷
VOLUME /opt/kb

#开放端口
EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
