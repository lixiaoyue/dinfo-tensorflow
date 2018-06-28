#!/bin/bash

# $0 is a script name, 
# $1, $2, $3 etc are passed arguments
# $1 is our command

#hadoop安装路径
if [ -z "$HA_NAMESERVICES" ]; then
#非高可用环境
echo "---without HA---"
else
#高可用HA环境
echo "---under HA---"

#高可用的参数配置
v_ha_nameservices=${HA_NAMESERVICES} #如：nameservice1
v_ha_namenodes_rpcaddress=${HA_NAMENODES_RPCADDRESS} #如：namenode52#hadoop2:8020,namenode74#hadoop3:8022

OLDIFS=$IFS
IFS=','

for v_item in ${v_ha_namenodes_rpcaddress}
do
  echo ${v_item}

  v_name=`echo ${v_item} | cut -d'#' -f1`
  v_value=`echo ${v_item} | cut -d'#' -f2`

  #拼接名称
  v_ha_namenodes="${v_ha_namenodes},${v_name}"

  #拼接配置代码块
  v_fragment="${v_fragment}
				<property>
						<name>dfs.namenode.rpc-address.${v_ha_nameservices}.${v_name}</name>
						<value>${v_value}</value>
				</property>
				"
done

IFS=$OLDIFS

#去掉最前面的逗号
v_ha_namenodes="${v_ha_namenodes:1}"

#生成配置文件
cat > ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
<property>
  <name>dfs.nameservices</name>
  <value>${v_ha_nameservices}</value>
</property>
<property>
  <name>dfs.client.failover.proxy.provider.${v_ha_nameservices}</name>
  <value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
</property>
<property>
  <name>dfs.ha.namenodes.${v_ha_nameservices}</name>
  <value>${v_ha_namenodes}</value>
</property>

${v_fragment}

</configuration>
EOF

fi

echo "==============================================================="

if [ -z "$KERBEROS_KDC" ]; then
#非认证环境
echo "---without kerberos---"
else
#认证环境
echo "---under kerberos---"

#====================================================================================================
#                                   处理hosts
#====================================================================================================
cat /etc/hosts /opt/kb/hosts | sort | uniq > /opt/temp_hosts
cat /opt/temp_hosts > /etc/hosts
rm -rf /opt/temp_hosts
#====================================================================================================
#                           完毕     处理hosts
#====================================================================================================

v_kdc=${KERBEROS_KDC}
v_admin_server=${KERBEROS_ADMIN_SERVER}
v_example_com=${KERBEROS_EXAMPLE_COM}
v_hdfs_example=${KERBEROS_HDFS_EXAMPLE}

#====================================================================================================
#               在节点的/etc/krb5.conf文件中进行服务器验证策略的配置
#====================================================================================================
#注意：在用命令<<EOF时，在最后结束的EOF前不能有空格、tab，否则打包时没问题，但是运行docker时会出错，启动不起来
cat > /etc/krb5.conf <<EOF
[logging]
default = FILE:/var/log/krb5libs.log
kdc = FILE:/var/log/krb5kdc.log
admin_server = FILE:/var/log/kadmind.log

[libdefaults]
dns_lookup_realm = false
ticket_lifetime = 24h  #认证凭证有效时间
renew_lifetime = 7d
forwardable = true
rdns = false
default_realm = ${v_example_com}
#default_ccache_name = KEYRING:persistent:%{uid}

[realms]
EXAMPLE.COM = {
kdc = ${v_kdc}
admin_server = ${v_admin_server}
}

[domain_realm]
.example.com = ${v_example_com}
example.com = ${v_example_com}
EOF
#====================================================================================================
#        完毕     在节点的/etc/krb5.conf文件中进行服务器验证策略的配置
#====================================================================================================

#将Kerberos KDC服务器端生成的hdfs.keytab认证文件复制到容器的如下目录
cp -f /opt/kb/hdfs.keytab ${HADOOP_HOME}/etc/hadoop/hdfs.keytab

#====================================================================================================
#                     在节点的${HADOOP_HOME}/sbin目录下新建kinit.sh文件
#====================================================================================================
cat > ${HADOOP_HOME}/sbin/kinit.sh <<EOF
while true
do
echo kinit -kt ${HADOOP_HOME}/etc/hadoop/hdfs.keytab  ${v_hdfs_example}
kinit -kt ${HADOOP_HOME}/etc/hadoop/hdfs.keytab  ${v_hdfs_example}
klist -e
echo sleep 18000s
sleep 18000
done
EOF
#====================================================================================================
#         完毕         在节点的${HADOOP_HOME}/sbin目录下新建kinit.sh文件
#====================================================================================================

#修改文件权限
chmod 777 ${HADOOP_HOME}/sbin/kinit.sh

#====================================================================================================
#              在节点中的${HADOOP_HOME}/etc/hadoop/core-site.xml文件中设置认证方式为kerberos
#====================================================================================================
#sed -i 's/^.*<configuration>//g' ${HADOOP_HOME}/etc/hadoop/core-site.xml
#sed -i 's/^.*<\/configuration>//g' ${HADOOP_HOME}/etc/hadoop/core-site.xml
cat > ${HADOOP_HOME}/etc/hadoop/core-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<property>
	<name>hadoop.security.authentication</name>
	<value>kerberos</value>
</property>
</configuration>
EOF
#====================================================================================================
#        完毕   在节点中的${HADOOP_HOME}/etc/hadoop/core-site.xml文件中设置认证方式为kerberos
#====================================================================================================

  #运行节点中的kinit.sh文件
  sh ${HADOOP_HOME}/sbin/kinit.sh > kinit.log &

fi

sh /run_jupyter.sh --allow-root
