bak.sh 备份gps之外的所有表 放到一个文件夹中 批量恢复需要执行 restore.sh脚本
bak1.sh 备份指定的两个表 恢复需要手动执行
DIR_RES=/home/barron
    //中间文件目录
USER=root
               //数据库用户名
PW=123                  //数据库密码
file=`date +%Y%m%d`     //备份文件名 
DATABASE=td_busonline845   //数据库明名称