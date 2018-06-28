FROM tensorflow/tensorflow:1.4.1-devel-py3

MAINTAINER zhangjianjun <zhangjianjun1@ultrapower.com.cn>

RUN pip --no-cache-dir install jieba gensim -i https://pypi.tuna.tsinghua.edu.cn/simple/

ENV DEBIAN_FRONTEND noninteractive

#预配置krb5-config
RUN echo 'krb5-config krb5-config/default_realm string EXAMPLE.COM' | debconf-set-selections && \
    echo 'krb5-config krb5-config/admin_server string 127.0.0.1' | debconf-set-selections && \
    echo 'krb5-config krb5-config/kerberos_servers string 127.0.0.1' | debconf-set-selections

RUN apt-get update && \
    apt-get install -y krb5-user \
    libpam-krb5 && \
    rm -rf /var/lib/apt/lists/*

ADD jdk-8u171-linux-x64.tar.gz /opt/
ADD hadoop-2.7.6.tar.gz /opt/
COPY entrypoint.sh /
#设置环境变量
ENV JAVA_HOME=/opt/jdk1.8.0_171
ENV HADOOP_HOME=/opt/hadoop-2.7.6
ENV HADOOP_HDFS_HOME=/opt/hadoop-2.7.6
ENV LD_LIBRARY_PATH=${JAVA_HOME}/jre/lib/amd64/server
ENV PATH=${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:$PATH

#拷贝算法包
ADD ultra.zip /usr/local/lib/python3.5/dist-packages/

#kerberos认证文件所在卷
VOLUME /opt/kb

ENTRYPOINT ["/entrypoint.sh"]

CMD ["start"]



	