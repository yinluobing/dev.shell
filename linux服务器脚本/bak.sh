#! /bin/bash
# auto_bak_table.sh
#gps 为含有GPS的表
#nosps 没有包含GPS的表
#tables 指定数据库中的表
#恢复数据目录
DIR_RES=/home/barron
USER=root
PW=123
file=`date +%Y%m%d`
DATABASE=td_busonline845
if [ ! -d "$DIR_RES/$file/log"  ];then
	mkdir -p $file
fi
rm -rf $DIR_RES/gps $DIR_RES/nogps
mysql -u$USER -p$PW >tables.txt  <<EOF
use td_busonline845;
show tables;
quit
EOF
sed -i '1d' tables.txt
echo "数据备份中..."
for sql in `cat tables.txt`
do
	if [[ $sql =~ "gps" ]];then
	echo  "$sql" >> gps
	else
	echo  "$sql" >> nogps
	mysqldump  -u$USER -p$PW  $DATABASE  "$sql" >$file/$sql.sql
	fi	
done
mv gps $DIR_RES/$file
mv nogps $DIR_RES/$file
cp  restore.sh  $DIR_RES/$file
rm -rf tables.txt
tar -zcvf $file.tar.gz $file
rm -rf $file
echo "备份完成!"
