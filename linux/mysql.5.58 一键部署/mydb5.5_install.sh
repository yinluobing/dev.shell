#! /bin/bash
#mysql5.5 二进制版本安装脚本
#
function check_md5(){

if [ "$1" = "2df3a1fc8db6c99f8398ea544fc6328d" ] 
then
echo "-----------------------------------packag ok ----------------------------------------"
else
echo "-----------------------------------packag error pleas reinstall ----------------------------------------"
exit

fi
}
function install(){	

if [ -f /etc/my.cnf ] || [ -s /etc/my.cnf];then
rm -rf /etc/my.cnf
fi
echo "----------------------------------start install mysql -----------------------------"
if [ 'grep "mysql" /etc/passwd | wc -l' ]; then
echo "adding user mysql"
groupadd mysql
useradd -s /sbin/nologin -M -g mysql mysql
else
echo "mysql user exists"
fi

echo "------------------------------- mysql install directory----------------------------------"
if [ ! -d $install_directory ]
then
mkdir -p $install_directory
fi
cd $install_directory
#判断安装包是否存在
if [ ! -f $install_directory/mysql-5.5.58-linux-glibc2.12-x86_64.tar.gz ]
then
echo "---------------------------packag error or packag not exits-----------------------------"
echo "---------------------------network download  input <y>no<n>-----------------------------"
read download
case $download in
	y)
	wget https://cdn.mysql.com//Downloads/MySQL-5.5/mysql-5.5.58-linux-glibc2.12-x86_64.tar.gz -P $install_directory
	;;
	n)
	echo "---------------------------quit install-----------------------------"
	exit
	;;
	*)
	echo "-------------------------The input does not conform to the format-------------------------"
	;;
esac
sleep 1
else
echo "-----------------------------------packag exist----------------------------------------"
fi
#检查安装包MD5值
MD5=`md5sum  "$install_directory/mysql-5.5.58-linux-glibc2.12-x86_64.tar.gz" | awk '{print $1}'`	
check_md5 $MD5
#断点测试
#sleep 100 
echo "------------------------------unpackaging mysql -----------------------------------"
tar -xvf $install_directory/mysql-5.5.58-linux-glibc2.12-x86_64.tar.gz 
mv mysql-5.5.58-linux-glibc2.12-x86_64  mysql-5.5.58
#cd mysql-5.5.58


echo "-------------------------install mysql,please wait-----------------"
sh $install_directory/mysql-5.5.58/scripts/mysql_install_db --basedir=$install_directory/mysql-5.5.58/ --datadir=$install_directory/mysql-5.5.58/data/ --user=mysql
echo "-------------------------Check the system configuration-----------------"
free_size=`free -g | awk -F '[ :]+' 'NR==2{print $2}'`

if [[ "$free_size" > 1 ]] && [[ "$free_size" < 4 ]]
then
cp $install_directory/mysql5.5.58/support-files/my-huge.cnf /etc/my.cnf
echo "-------------------------my-huge.cnf --> /etc/my.cnf-----------------"
elif [[ "$free_size" >  4 ]] 
then
cp $install_directory/mysql-5.5.58/support-files/my-innodb-heavy-4G.cnf /etc/my.cnf
echo "-------------------------my-innodb-heavy-4G.cnf --> /etc/my.cnf-----------------"
else
cp $install_directory/mysql-5.5.58/support-files/my-large.cnf /etc/my.cnf
echo "-------------------------my-large.cnf --> /etc/my.cnf-----------------"
fi


echo "-------------------------start configuring my.cnf-----------------"
sed -i '/\[mysqld\]/a\datadir = '"$install_directory"'/mysql-5.5.58/data' /etc/my.cnf
sed -i '/\[mysqld\]/a\basedir = '"$install_directory"'/mysql-5.5.58' /etc/my.cnf

echo "-------------------------<Default --> 1>or<Custom --> 2>-----------------"

#read portnomber
case $portnomber in
         1)
           	echo "default port"
		PORTSIZE=3306
         ;;
         2)
		echo "please inport"
		#read PORTSIZE
		portsize=`sed -n '/^port/=' /etc/my.cnf | sed -n "2"p`
		sed -i ''"$portsize"'d' /etc/my.cnf
		sed -i '/\[mysqld\]/a\port = '"$PORTSIZE"'' /etc/my.cnf
         ;;
         *)
           echo "The input does not conform to the format"
         ;;
esac 

chown -R mysql.mysql $install_directory/mysql-5.5.58

#chown -R mysql /usr/local/mysql/var
cp $install_directory/mysql-5.5.58/support-files/mysql.server /etc/rc.d/init.d/mysqld
cp $install_directory/mysql-5.5.58/bin/mysql /usr/sbin/mysql
cp $install_directory/mysql-5.5.58/bin/mysqldump /usr/sbin/mysqldump
chown -R root:root /etc/rc.d/init.d/mysqld
chmod 755 /etc/rc.d/init.d/mysqld
chkconfig --add mysqld

echo "mysql starting"
service mysqld start
if [ $? -ne 0 ];then
echo "mysql start filed ,please check /etc/my.cnf !"

else
echo "mysql start successful,congratulations!"
sleep 1
echo "-------------------------config user passwd ---------------------"
mysql -uroot  >tables.txt  <<EOF
grant all privileges on *.* to 'root'@'%' identified by '123456';
flush privileges;
quit
EOF

#关闭防火墙
echo "-------------------iptables off-------------------"
service iptables status
service iptables stop
#关闭SElinux
echo "-------------------selinux off-------------------"
setenforce 0

DATE=`date +"%H:%M:%S"`
IP=`/sbin/ifconfig eth0 | awk '/inet addr/ {print $2}' | cut -d: -f2`
echo "$DATE IP:$IP" >>$install_directory/install_`date +"%Y%m%d"`.log
echo "$DATE datadir:$install_directory/data" >>$install_directory/install_`date +"%Y%m%d"`.log
echo "$DATE basedir:$install_directory" >>$install_directory/install_`date +"%Y%m%d"`.log
echo "$DATE port:$PORTSIZE" >>$install_directory/install_`date +"%Y%m%d"`.log
echo "$DATE user:root" >>$install_directory/install_`date +"%Y%m%d"`.log
echo "$DATE passwd:123456" >>$install_directory/install_`date +"%Y%m%d"`.log
echo "-------------------install completed----------------------"
cat "$install_directory/install_`date +"%Y%m%d"`.log"

fi
}

function uninstall(){
#卸载数据库 会删除所有数据
echo "-------------------This is dangerous operation------------------------"
echo "------------------------Start back  data  please wait... ------------------------"
mysqldump -uroot -p --all-database  > all.sql
echo "-------------------backup completed----------------------"
echo "Check whether the file is complete uninstall confirmed"
read delect
case  $delect in
	y)
	process=`ps -ef | grep mysql | awk '{print $2}'`
	for a in $process
	do
	kill -9 $a
	done
	rm -rf $install_directory/mysql-5.5.58
	dir=`find / -name "mysql"`
	for b in $dir
	do 
	rm -rf $b
	done
	dird=`find / -name "mysqld"`
	for c in  $dird
	do
	rm -rf $c
	done
	rm -rf /etc/init.d/mysqld
	rm -rf `cat /etc/my.cnf | grep basedir | awk -F "=" '{print $2}'`
	echo "-------------------Uninstall completed----------------------"
	;;
	n)
	etho "quit uninstall"
	exit
	;;
	*)
	;;
esac


}
function main(){
echo "-------------1 for installation 2 for uninstallation--------------"
echo "------------------------- <1>or<2> ---------------------"
read cmd
source install.cnf
case $cmd in
	1 | begin)
	echo "Please enter the installation path   示例:/opt "
	#read install_directory
	install
	;;
	2 | end)
	uninstall
	;;
	*)
	echo "The input does not conform to the format  install"
esac
	
}
main

