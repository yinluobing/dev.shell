#! /bin/bash

#服务器变量
#data_name="/dev/vda1"
#ping次数
count="3"
#日志路径

#邮箱地址
mail1="yuch@tongda.cc"
mail2="1281455504@qq.com"
mail3=""
#mysql账号密码
USER="root"
PASSWD="123"
database="monitor"
tablename="message"
#日志文件路径
monitor=/var/monitor/service_monitor.log
#对应服务器路径
jboss_log=  #真实日志路径
mysql_log=/var/lib/mysql/Test0.err
nginx_log=
mysql_log_num=/var/monitor/mysql_log_num #文件标记
jboss_log_num=/var/monitor/jboss_log_num #文件标记
nginx_log_num=/var/monitor/nginx_log_num #文件标记
log_num=/var/monitor/log_num
logfile=/tmp/logfile.log   #发邮件日志
send_monitor=/tmp/send_monitor.log #邮件截取日志
redis_config=  #redis配置文件路径
#获取信息
#获取cpu使用率
cpuUsage=`top -n 1 | awk -F '[ %]+' 'NR==3 {print $2}'`
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
#获取网络情况
ping_status=`ping -c $count www.baidu.com|awk 'NR==7 {print $4}'`
#统计丢包率
persent=$[count-ping_status]
ping_persent=`awk 'BEGIN{printf "%.0f\n",('$persent'/'$count')*100}'`

#获取本机IP地址
IP=`ifconfig eth0 | awk '/inet addr/ {print $2}' | cut -d: -f2`
#规则判断
echo "$log_time IP地址:${IP} --> CPU使用率：${cpuUsage}% --> 内存使用率：${mem_used_persent}% --> 网络丢包率:  ${ping_persent}%" >> $monitor
#mysql 插入
# cpu mem disk net mysql nginx redis jboss mysql_log nginx_log jboss_log redis_log redis_mem
function insert_tables(){
	insert_table="insert into message  (cpu,mem) values ('10','20')"
	mysql -u$USER -p$PASSWD -D$database -e "${insert_table}"

}
#发送邮件
function send_mail(){
        #mail -s "监控报警" $mail1 < /tmp/monitor.log
	#mail -s "监控报警" $mail2 < /tmp/monitor.log
	cat $logfile | wc -l > $log_num
	num_l=`cat $log_num`
	sed -n ''$num_l',$'p $logfile >> $send_monitor

	#tail -n  4  /tmp/monitor.log > $send_monitor
	mail -s "监控报警" $mail1 < /tmp/send_monitor.log
	echo "$log_time !!!!!!!!发送告警邮件!!!!!!!"
}

function check_mysql(){
	ps -fe | grep mysql |grep -v grep >> /dev/null

	if [ $? -ne 0 ]
	then
	echo "$log_time -->mysql 未运行" >> $logfile
	echo "$log_time -->mysql 未运行触发邮件" >> $monitor
	insert_table="insert into message  (mysql) values ('未运行')"
	insert_tables
	send_mail
	else
	echo "$log_time -->mysql 正常运行" >> $monitor
	fi
}

##########
#检查日志#
##########

function check_mysql_log(){
	cat $mysql_log | wc -l > $mysql_log_num
	num_m=`cat $mysql_log_num`
	my_error_num=`sed -n '$num_m,$'p $mysql_log | grep 'ERRO' | wc -l`
	if [ $my_error_num -ne 0 ]
	then
	echo "mysql 日志文件触发邮件"
	sed -n ''$num_m',$'p $mysql_log | grep -i 'ERRO' >> $logfile
	insert_table="insert into message  (mysql_log) values ('日志报警')"
	insert_tables
	send_mail
	fi
}

#MySQL临时表空间  最大连接数
#function check_mysql_table(){
#}
function check_mysql_connect(){
	CRONNECTEB=`mysql -u$USER -p$PASSWD -e "show status;"|grep Threads_connected|awk '{print $2}'`
	echo "$log_time --> mysql 连接数:$CRONNECTEB  " >> $monitor

}
#状态数据写入数据库中
function create_table(){
create_table_sql="create table message ( id int not null auto_increment primary key, cpu varchar(100), mem varchar(100), disk varchar(100), net varchar(100), mysql varchar(100), nginx varchar(100), redis varchar(100), jboss varchar(100), mysql_log varchar(100), nginx_log varchar(100), jboss_log varchar(100), redis_log varchar(100), redis_mem varchar(100))"
}

function check(){

		if [[ "$cpuUsage" > 80 ]] || [[ "$mem_used_persent" > 80 ]] || [[ "$ping_persent" >  0 ]];then
        #if [[ "$cpuUsage" > 80 ]] || [[ "$mem_used_persent" > 80 ]];then
                echo "报警时间：${now_time}" >> $logfile
                echo "IP地址: ${IP} --> CPU使用率：${cpuUsage}% --> 内存使用率：${mem_used_persent}% --> 网络丢包率: ${ping_persen}" >> $logfile
				insert_table="insert into message  (cpu,mem,net) values ($cpuUsage,$mem_used_persent,$ping_persent)"
				insert_tables
                send_mail
        fi
}
function main(){
    check #检查基本状态 cpu 内存  网络
	check_disk #磁盘进程
	check_mysql #MySQL进程
	check_mysql_connect #MySQL连接数
}
main
