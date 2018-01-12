#! /bin/bash

export TERM=linux   #防止脚本定时任务出错

count=3
ipaddr="200.200.6.17"
cpuUsage=`/usr/bin/top -bn 1 | awk -F '[ %]+' 'NR==3 {print $2}'`
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
ping_status=`ping -c $count $ipaddr | awk 'NR==7 {print $4}'`
#统计丢包率
persent=$[count-ping_status]
ping_persent=`awk 'BEGIN{printf "%.0f\n",('$persent'/'$count')*100}'`
#获取本机IP地址
IP=`/sbin/ifconfig eth1 | awk '/inet addr/ {print $2}' | cut -d: -f2`
#规则判断
echo "$log_time IP地址:${IP} --> CPU使用率：${cpuUsage}% --> 内存使用率：${mem_used_persent}% --> 网络丢包率:  ${ping_persent}%" >> /home/sh/check.log
