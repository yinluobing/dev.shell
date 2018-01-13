#! /bin/bash
#description: 删除descritionlog表
#chkconfig:2345 80 90
# 删除description
USER=root
PASSWORD=123
DATABASE=td_busonlinedisp845
TABLE=dh_operationlog
echo "开始进入数据库删除表"
mysql -u$USER -p$PASSWORD <<EOF
use td_busonlinedisp845;
drop table dh_operationlog;
quit

EOF
echo "删除完成"
