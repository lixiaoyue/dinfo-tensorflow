docker run -itd -p 8888:8888 -p 50022:22 \
--name=dinfo-tensorflow \
-e KERBEROS_KDC=hadoop2 \
-e KERBEROS_ADMIN_SERVER=hadoop2 \
-e KERBEROS_EXAMPLE_COM=EXAMPLE.COM \
-e KERBEROS_HDFS_EXAMPLE=hdfs@EXAMPLE.COM \
-e HA_NAMESERVICES=nameservice1 \
-e HA_NAMENODES_RPCADDRESS=namenode52#hadoop2:8020,namenode74#hadoop3:8020 \
-v /opt/tensorflow_docker/kb:/opt/kb \
dinfo.cn/tensorflow:1.4.1           
