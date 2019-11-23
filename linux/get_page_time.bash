#!/bin/bash
begin_time=`date +%s%N`
curl  -s  -H ‘Host: bbs.iammecn.com’ $1 >/tmp/tmp
end_time=`date +%s%N`
let time1="$end_time"-"$begin_time"
let time1="time1/1000000"
begin_time=`date +%s%N`
curl  -s  -H ‘Host: www.iammecn.com’ $1 >/tmp/tmp
end_time=`date +%s%N`
let time2="$end_time"-"$begin_time"
let time2="time2/1000000"
printf misstime:$time1 
printf " "hittime:$time2