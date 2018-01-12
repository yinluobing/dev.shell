
#! /bin/bash

user=root
passwd=
host=
port=
#初始化MySQL表create_table_sql="create table message ( id int not null auto_increment primary key, cpu varchar(100), mem varchar(100), disk varchar(100), net varchar(100), mysql varchar(100), nginx varchar(100), redis varchar(100), jboss varchar(100), mysql_log varchar(100), nginx_log varchar(100), jboss_log varchar(100), redis_log varchar(100), redis_mem varchar(100))"
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD}  -D ${DBNAME} -e "${create_db_sql}"

#初始化计数
echo 1 > /var/monitor/mysql_log_num #文件标记
echo 1 > /var/monitor/jboss_log_num #文件标记
echo 1 > /var/monitor/nginx_log_num #文件标记
echo 1 > /var/monitor/log_num

