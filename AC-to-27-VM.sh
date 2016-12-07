#!/bin/bash
sshhost=( 172.16.100.27 );
		echo Syncing To Server
		echo remote  Books
                rsync -avuc -C -e ssh ../../target/*.tar.gz root@$sshhost:/tmp/rebasoft-core.tar.gz

for ip in ${sshhost[@]}

do

ssh -t root@$ip /bin/sh <<\EOF
tar zxvf /tmp/rebasoft-core.tar.gz -C /
/etc/init.d/macauditord restart
EOF
done
