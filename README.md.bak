# dinfo-tensorflow

基于TensorFlow1.4.1， 且包含kerberos认证以及hadoop相关客户端的docker容器
当前目录包含 Dockerfile文件，通过docker命令构建TensorFlow docker镜像

## 构建docker image

    $ docker build -t dinfo.cn/tensorflow:1.4.1 .


## 运行dinfo TensorFlow容器

    $ ./tensorflowrun.sh
	
其中tensorflowrun.sh脚本内容如下：
``` bash
docker run -d \
--name=dinfo-tensorflow \
--net=host \
-e KERBEROS_KDC=hadoop2 \
-e KERBEROS_ADMIN_SERVER=hadoop2 \
-e KERBEROS_EXAMPLE_COM=EXAMPLE.COM \
-e KERBEROS_HDFS_EXAMPLE=hdfs@EXAMPLE.COM \
-e HA_NAMESERVICES=nameservice1 \
-e HA_NAMENODES_RPCADDRESS=namenode52#hadoop2:8020,namenode74#hadoop3:8020 \
-v /opt/tensorflow_docker/kb:/opt/kb \
dinfo.cn/tensorflow:1.4.1
```

## 环境变量说明
| 参数名称   | 说明   |  备注  |
| --------   | ------  | ------  |
| KERBEROS_KDC     | kerberos认证相关配置。取自krb5.conf中的realms节点的kdc值 |   如果没有开启kerberos认证，那么此参数中不设置     |
| KERBEROS_ADMIN_SERVER        |   kerberos认证相关配置。取自krb5.conf中的realms节点的admin_server值   |   如果没有开启kerberos认证，那么此参数中不设置   |
| KERBEROS_EXAMPLE_COM        |    kerberos认证相关配置。取自krb5.conf中的libdefaults节点中的default_realm值    |  如果没有开启kerberos认证，那么此参数中不设置  |
| KERBEROS_HDFS_EXAMPLE        |    kerberos认证相关配置，hdfs认证用户名，kinit命令使用，一般为hdfs@EXAMPLE.COM   |  如果没有开启kerberos认证，那么此参数中不设置  |
| HA_NAMESERVICES        |    hadoop HA高可用相关配置。取自hdfs-site.xml中的dfs.nameservices属性    |  如果没有开启HA高可用，那么此参数不设置  |
| HA_NAMENODES_RPCADDRESS        |    hadoop HA高可用相关配置。取自hdfs-site.xml中的dfs.ha.namenodes.XXX和rpc-address属性    |  如果没有开启HA高可用，那么此参数不设置  |
| -v /opt/tensorflow_docker/kb:/opt/kb        |    存放kerberos认证相关和HA高可用相关的配置信息。主要有2个文件：hdfs.keytab和hosts    |    |
