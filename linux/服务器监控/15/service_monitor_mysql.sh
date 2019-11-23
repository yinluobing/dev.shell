#! /bin/bash

export TERM=linux
#服务器变量
#data_name="/dev/vda1"
#ping次数
count="3"
#日志路径

#邮箱地址
mail0="yuch@tongda.cc"
mail1="yuchao_cacti@163.com"
mail2="1281455504@qq.com"
mail3=""
#mysql账号密码
#本地数据库
LUSER="root"
LPASSWD="tongda666"
Lhost="127.0.0.1"
#监控端数据库
USER="root"
PASSWD="tongda666"
database="monitor"
tablename="message15"
host="200.200.6.19"
#日志文件路径
monitor=/var/monitor/service_monitor.log
#对应服务器路径
jboss_log=/usr/local/Server/jboss-eap-6.0/standalone/log/server.log  #真实日志路径
mysql_log=/var/lib/mysql/localhost.localdomain.err
nginx_log=
mysql_log_num=/var/monitor/mysql_log_num #文件标记
jboss_log_num=/var/monitor/jboss_log_num #文件标记
nginx_log_num=/var/monitor/nginx_log_num #文件标记
log_num=/var/monitor/log_num
logfile=/var/monitor/mail/logfile.log   #发邮件日志
send_monitor=/var/monitor/mail/send_monitor.log #邮件截取日志
redis_config=  #redis配置文件路径
#获取信息
#获取cpu使用率
cpuUsage=`top -bn 1 | awk -F '[ %]+' 'NR==3 {print $2}'`
#获取磁盘使用率
disktotal=`df -Th|awk -F '[ |%]+' 'NR>1 {print $7"="$6}'`
#获取内存情况
mem_total=`free -m | awk -F '[ :]+' 'NR==2{print $2}'`
mem_used=`free -m | awk -F '[ :]+' 'NR==3{print $3}'`
#统计内存使用率
mem_used_persent=`awk 'BEGIN{printf "%.0f\n",('$mem_used'/'$mem_total')*100}'`
#获取报警时间
now_time=`date '+%F %T'`
log_time=`date '+%Y-%m-%d %H-%M-%S'`
#统计丢包率
#ping_persent=`awk 'BEGIN{printf "%.0f\n",('$persent'/'$count')*100}'`
ping_persent=`ping -c 3 www.baidu.com | grep received | awk -F ',' '{print$3}'|awk -F ' ' '{print$1}' |sed 's/%//'`
#获取本机IP地址
IP=`/sbin/ifconfig eth1 | awk '/inet addr/ {print $2}' | cut -d: -f2`
#规则判断
#echo "============================${cpuUsage}=============================="
echo "$log_time IP地址:${IP} --> CPU使用率：${cpuUsage}% --> 内存使用率：${mem_used_persent}% --> 网络丢包率:  ${ping_persent}%" >> $monitor
#mysql 插入
# cpu mem disk net mysql nginx redis jboss mysql_log nginx_log jboss_log redis_log redis_mem
function insert_tables(){
#	insert_table="insert into message  (cpu,mem) values ('10','20')"
	mysql -u$USER -p$PASSWD -h$host -D$database -e "${insert_table}"

}
#发送邮件
function send_mail(){
        #mail -s "监控报警" $mail1 < /tmp/monitor.log
	#mail -s "监控报警" $mail2 < /tmp/monitor.log
	cat $logfile | wc -l > $log_num
	num_l=`cat $log_num`
	sed -n ''$num_l',$'p $logfile >> $send_monitor
	
	#tail -n  4  /tmp/monitor.log > $send_monitor
	mail -s "监控报警" $mail1 < /var/monitor/mail/send_monitor.log
	echo "$log_time !!!!!!!!发送告警邮件!!!!!!!"	
}
#insert_table="insert into message  (cpu,mem) values ('10','20')"
#mysql -uroot -p123 -Dmonitor -e "${insert_table}"
#循环获取磁盘信息
function check_disk(){
	for i in $disktotal
	do
			diskname=`echo $i | awk -F'=' '{print $1}'`
			diskusage=`echo $i | awk -F'=' '{print $2}'`
			echo "$log_time 磁盘-->$diskname使用率:  ${diskusage}% " >> $monitor
		if [ $diskusage -gt 80 ];then
		echo "$log_time 磁盘-->$diskname使用率:  ${diskusage}% " >> $logfile
		insert_table="insert into $tablename  (disk) values ('3')"
		insert_tables
		send_mail
		echo "发送邮件 磁盘触发"        
		fi
	done
}
####################
#检查中间件线程运行#
####################
function check_redis(){
	ps -fe | grep redis |grep -v grep >> /dev/null
	if [ $? -ne 0 ]
	then
	echo "$log_time -->redis 未运行" >> $logfile
	echo "$log_time -->redis 未运行触发邮件" >> $monitor
	insert_table="insert into $tablename  (redis) values ('1')"
	insert_tables
	send_mail
	else
	echo "$log_time -->redis 正常运行" >> $monitor
	fi
	
}

function check_jboss(){
	ps -fe | grep jboss |grep -v grep  >> /dev/null
	
	if [ $? -ne 0 ]
	then
	echo "$log_time -->jboss 未运行" >> $logfile
	echo "$log_time -->jboss 未运行触发邮件" >> $monitor
	insert_table="insert into $tablename  (jboss) values ('1')"
	insert_tables
	send_mail
	else
	echo "$log_time -->jboss 正常运行" >> $monitor
	fi
}

function check_mysql(){
	ps -fe | grep mysql |grep -v grep >> /dev/null
	
	if [ $? -ne 0 ]
	then
	echo "$log_time -->mysql 未运行" >> $logfile
	echo "$log_time -->mysql 未运行触发邮件" >> $monitor
	insert_table="insert into $tablename  (mysql) values ('1')"
	insert_tables
	send_mail
	else
	echo "$log_time -->mysql 正常运行" >> $monitor
	fi
}

function check_nginx(){
	ps -fe | grep nginx |grep -v grep >> /dev/null
	
	if [ $? -ne 0 ]
	then
	echo "$log_time -->nginx 未运行" >> $logfile
	echo "$log_time -->nginx 未运行触发邮件" >> $monitor
	insert_table="insert into $tablename  (nginx) values ('1')"
	insert_tables
	send_mail
	else
	echo "$log_time -->nginx 正常运行" >> $monitor
	fi
}
##
#获取进程PID
function GetPID(){ 
    PsUser=$1 
    PsName=$2 
    pid=`ps -u $PsUser |grep $PsName|grep -v grep|grep -v vi|grep -v dbx\n |grep -v tail|grep -v start|grep -v stop |sed -n 1p |awk '{print $1}'` 
    echo $pid 
 }
#获取进程的内存使用量
function GetMem() { 
        MEMUsage=`ps -o vsz -p $1|grep -v VSZ` 
        (( MEMUsage /= 1000)) 
        echo $MEMUsage 
}

##
#获取redis内存使用量
function check_redis_mem() {
	use_mem=$(redis-cli -h 127.0.0.1 info memory | grep used_memory_human: | awk -F ':' '{print $2}')
	max_mem=`cat $redis_config | grep  -E 'maxmemory [1-9]'|awk -F ' ' '{print $2}'`
	redis_mem_present=`awk 'BEGIN{printf "%.0f\n",('$use_mem'/'$max_mem')*100}'`
	if [ $redis_mem_present > 70 ]
	then
	echo "$log_time --> redis 运行内存不足 注意清理 使用:$use_mem 总共:$max_mem" >> $logfile
	echo "$log_time -->redis 内存不足 触发邮件" >> $monitor
	insert_table="insert into $tablename  (redis) values ('3')"
	insert_tables
	send_mail
	else
	echo "$log_time -->redis 内存使用正常 总共:$max_mem 使用:$use_mem "
fi
}

function auto_restore_redis(){
redis-cli -h 127.0.0.1 <<EOF
flushall
	
EOF


}		
##########
#检查日志#
##########

function check_mysql_log(){
	num_m=`cat $mysql_log_num`
	my_error_num=`sed -n ''$num_m',$'p $mysql_log | grep 'ERRO' | wc -l`
	cat $mysql_log | wc -l > $mysql_log_num
	if [ $my_error_num -ne 0 ] 
	then
	echo "mysql 日志文件触发邮件"
	sed -n ''$num_m',$'p $mysql_log | grep -i 'ERRO' >> $logfile
	insert_table="insert into $tablename  (mysql_log) values ('2')"
	insert_tables
	send_mail
	fi
}
function check_nginx_log(){
	num_n=`cat $nginx_log_num`
	ng_error_num=`sed -n ''$num_n',$'p $nginx_log | grep 'ERRO' | wc -l`
	cat $nginx_log | wc -l > $nginx_log_num
	if [ $ng_error_num -ne 0 ] 
	then
	echo "nginx 日志文件触发邮件"
	sed -n ''$num_n',$'p $nginx_log | grep -i 'ERRO' >> $logfile
	insert_table="insert into $tablename  (nginx_log) values ('2')"
	insert_tables
	send_mail	
	fi
	
}
function check_jboss_log(){
	num_j=`cat $jboss_log_num`
	jb_error_num=`sed -n ''$num_j',$'p $jboss_log | grep 'ERRO' | wc -l`
	cat $jboss_log | wc -l > $jboss_log_num
	if [ $jb_error_num -ne 0 ] 
	then
	echo "jboss 日志文件触发邮件"
	sed -n ''$num_j',$'p $jboss_log | grep  -i 'ERRO' >> $logfile
	insert_table="insert into $tablename  (jboss_log) values ('2')"
	insert_tables
	send_mail
	fi	

}
#MySQL临时表空间  最大连接数
#function check_mysql_table(){
#}
function check_mysql_connect(){
	CRONNECTEB=`mysql -u$LUSER -p$LPASSWD -h$Lhost -e "show status;"|grep Threads_connected|awk '{print $2}'`
	MAX_CRONNECTEB=`mysql -u$LUSER -p$LPASSWD -h$Lhost -e "show variables like '%max_connections%';" | grep -w  max_connections | awk '{print $2}'`
	echo "$log_time --> mysql 连接数:$CRONNECTEB  " >> $monitor
	if [ $CRONNECTEB -ge $MAX_CRONNECTEB ]
	then
	echo "$log_time --> mysql 连接数超出最大值:$MAX_CRONNECTEB "
	fi

}
#状态数据写入数据库中
function create_table(){
create_table_sql="create table $tablename ( id int not null auto_increment primary key, cpu varchar(100), mem varchar(100), disk varchar(100), net varchar(100), mysql varchar(100), nginx varchar(100), redis varchar(100), jboss varchar(100), mysql_log varchar(100), nginx_log varchar(100), jboss_log varchar(100), redis_log varchar(100), redis_mem varchar(100))"
}





function check(){
        
		if [[ "$cpuUsage" > 80 ]] || [[ "$mem_used_persent" > 80 ]] || [[ "$ping_persent" >  0 ]];then
                echo "报警时间：${now_time}" >> $logfile
                echo "${log_time} --> IP地址: ${IP} --> CPU使用率：${cpuUsage}% --> 内存使用率：${mem_used_persent}% --> 网络丢包率: ${ping_persent}" >> $logfile
		insert_table="insert into $tablename  (cpu,mem,net) values ('$cpuUsage','$mem_used_persent','$ping_persent')"
		insert_tables
                send_mail
        fi
		insert_table="insert into $tablename  (cpu,mem,net) values ('$cpuUsage','$mem_used_persent','$ping_persent')"
		insert_tables
}
function main(){
        check #检查基本状态 cpu 内存  网络
	check_disk #磁盘进程
	check_mysql #MySQL进程
	check_mysql_connect #MySQL连接数
#	check_nginx #nginx进程
#	check_redis #redis 进程
#	check_jboss_log #jboss日志
#	check_mysql_log #mysql 日志
#	check_nginx_log #nginx 日志
		
}
main
