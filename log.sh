#! /bin/bash

echo "本脚本放到日志目录下"
echo "日志的日期 两位数"
read LOG_TIME
echo "生成日志名称 随便去一个名称"
read LOG_NAME
echo "输入需要拉取日志时间 eg:0911-0944"
read TIME
echo "$TIME" > source
HOUR= cut -c 1,2 source
MIN= cut -c 3,4 source
TOHOUR= cut -c 6,7 source
TOMIN= cut -c 8,9 source

M=`date "+%m"`
echo $MONTH
D=`date "+%d"`
STIME=$HOUR:$MIN:00
DTIME=$TOHOUR:$TOMIN:00
if [ "$LOG_TIME" == "$D" ];then
	echo "当天"
	cat server.log | awk '$1 >= ${STIME} && $1 <= ${DTIME}' > "$LOG_NAME"_"$LOG_TIME"_"$TIME".log
echo "	cat server.log | awk '$1 >= "$HOUR':'$MIN':'00" && $1 <="$TOHOUR':'$TOMIN':'00"' > {"$TIME}".log"
else
	echo "不是当天"
	cat server.log.2017-$M-$LOG_TIME | awk '$1 >= "$HOUR':'$MIN':'00" && $1 <="$TOHOUR':'$TOMIN':'00"' > "$LOG_NAME"_"$LOG_TIME"_"$TIME".log
fi

zip "$LOG_NAME"_"$LOG_TIME"_"$TIME".zip  "$LOG_NAME"_"$LOG_TIME"_"$TIME".log
