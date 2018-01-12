#! /bin/bash

REDIS_HOST=200.200.6.17
REDIS_PORT=6379
REDIS_DB=1


KEYNAME=*
KEYFILE=key.txt
echo "KEYS *" | redis-cli -h $REDIS_HOST  > $KEYFILE
VALUEFILE=value.txt

for key in `cat $KEYFILE`
do
echo "get $key" | redis-cli -h $REDIS_HOST >> $VALUEFILE
done
paste $KEYFILE $VALUEFILE >key_value.txt	
