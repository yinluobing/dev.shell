#!/bin/bash
#chkconfig:2345 80 80
#description:funtion auto jboss

nohup /usr/local/server/jboss-eap-6.0/bin/standalone.sh&
slepp 2
tail -f nobup.out
