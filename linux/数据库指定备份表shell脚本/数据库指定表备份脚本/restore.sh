#! /bin/bash
# auto_bak_table.sh
#
echo "请输入要恢复数据库名称----此操作只是恢复非gps的表"
read database
USER="root"
PWD="tongda666"
echo "数据恢复中...."
for sql in `cat nogps`
do
	mysql  -u$USER -p$PWD  $database <$sql.sql
done
echo "数据恢复完成!"
