#!/bin/sh  
#JBOSS_HOME  
JBOSS_HOME=/usr/local/server/jboss-eap-6.0
case "$1" in  
start)  
echo "Starting JBoss 6..."  
sh ${JBOSS_HOME}/bin/standalone.sh &  
;;  
stop)  
echo "Stopping JBoss 6..."  
sh ${JBOSS_HOME}/bin/jboss-cli.sh  --connect --command=:shutdown  
;;  
log)  
echo "Showing server.log..."  
tail -1000f ${JBOSS_HOME}/standalone/log/server.log  
;;  
*)  
echo "Usage: /etc/init.d/jboss {start|stop|log}"  
exit 1  
;; esac  
exit 0 
