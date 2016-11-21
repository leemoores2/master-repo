#! /bin/bash

ip_address=( 172.16.100.31 172.16.100.29 172.16.100.28 172.16.100.27 172.16.100.26 172.16.100.25 172.16.100.24 172.16.100.23 172.16.100.22 10.100.1.222 10.100.1.246);
param1=$1
param2=$2
param3=$3
param4=$4

for ip in ${ip_address[@]}

do

ssh -t root@$ip "$param1 $param2 $param3 $param4" <<\EOF

EOF
done
