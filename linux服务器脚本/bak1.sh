#! /bin/bash
# auto_bak_table.sh
#gps 为含有GPS的表
#nosps 没有包含GPS的表
#tables 指定数据库中的表
#恢复数据目录
DIR_RES=/home/barron
USER=root
PW=123
file=`date +%Y%m%d`"disp"
DATABASE=td_busonlinedisp845
TABLE1=dh_busoperatrecord
TABLE2=dh_busoperatrecordt
if [ ! -d "$DIR_RES/$file"  ];then
	mkdir $file
fi	
mysqldump  -u$USER -p$PW  $DATABASE  $TABLE1 $TABLE2  >$file/busoperatrecord.sql
tar -zcvf $file.tar.gz $file
rm -rf $file
echo "备份完成!"
