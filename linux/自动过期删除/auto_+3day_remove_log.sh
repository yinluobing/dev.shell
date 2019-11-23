#! /bin/bash
#chkconfig: 2345 80 90
#description:  auto_remove  
find /usr/local/Server/jboss-eap-6.0/standalone/log   -mtime +3 -name "*.log.*" -exec rm  {} \;
