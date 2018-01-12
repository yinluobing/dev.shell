#!/bin/bash  
MYSQL=/usr/bin/mysql  
MYSQL_HOST=localhost 
MYSQL_USER=root 
MYSQL_PASSWORD=123 
CHECK_TIME=3  
#mysql  is working MYSQL_OK is 1 , mysql down MYSQL_OK is 0  
MYSQL_OK=1 
function check_mysql_health (){  
$MYSQL -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD -e "show status;" >/dev/null 2>&1  
if [ $? = 0 ] ;then  
     MYSQL_OK=1 
else  
     MYSQL_OK=0 
fi  
     return $MYSQL_OK  
}  
while [ $CHECK_TIME -ne 0 ]  
do  
     let "CHECK_TIME-=1"  ##（小提示这里我们采用的是let进行整数的运算当然您可以用expr，感觉let省去了$比较方便）
     check_mysql_health  
     if [ $MYSQL_OK = 1 ] ; then  
          CHECK_TIME=0 
          exit 0  
     fi  
 
     if [ $MYSQL_OK -eq 0 ] &&  [ $CHECK_TIME -eq 0 ]  
     then  
          /etc/init.d/keepalived stop  
     exit 1   
     fi  
     sleep 1  
done  
