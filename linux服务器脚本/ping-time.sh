#! /bin/bash

ping 192.168.13.111 | awk '{ print $0"\t" strftime("%Y-%m-%d %H:%M:%S",systime())}' >>/mnt/106-111.log
ping 192.168.13.108 | awk '{ print $0"\t" strftime("%Y-%m-%d %H:%M:%S",systime())}' >>/mnt/106-108.log
ping 192.168.13.109 | awk '{ print $0"\t" strftime("%Y-%m-%d %H:%M:%S",systime())}' >>/mnt/106-109.log
ping 192.168.13.1 | awk '{ print $0"\t" strftime("%Y-%m-%d %H:%M:%S",systime())}' >>/mnt/106-1.log
ping 192.168.13.254 | awk '{ print $0"\t" strftime("%Y-%m-%d %H:%M:%S",systime())}' >>/mnt/106-254.log