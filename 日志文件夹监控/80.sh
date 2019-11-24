#! /bin/bash

#Dir 表示需要监控的文件夹绝对路径
#Scale 表示指定的占比
#DiskUse 表示磁盘的使用率
#FileTime 当前时间
#/opt/disk.log 为脚本的日志文件
Dir=/boot
#Scale=40
FileTime=`date '+%Y-%m-%d %H':'%M':'%S'`
function diskuse()
{
	DiskUse=`df -Th|awk -F '[ |%]+' 'NR>1 {print $7"="$6}' | grep "$Dir" | awk -F "=" '{print $2}'`
	echo $DiskUse
}
function sort(){
cd $Dir
Dirlist=`ls -lrt |awk 'NR>1 {print $9}'`
for i in $Dirlist
do
echo "for"
DiskUse=`diskuse`
if [ "server.log" = "$i" ] || [ "upload-info.log" = "$i" ] || [[ "$DiskUse" < 40 ]];then
echo "循环退出"
continue
else
echo "del"
rm -rf $i
echo "$FileTime 删除文件名为:$i" >> /opt/disk.log
fi
done
}

function judge(){
DiskUse=`diskuse`
if [[ "$DiskUse" > 40 ]]; then
sort
echo "$DiskUse"
fi
}
function main(){
echo "$FileTime 检查磁盘" >> /opt/disk.log
judge
a=`diskuse`
echo "$a"
}
main
