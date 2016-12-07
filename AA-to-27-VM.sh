#!/bin/bash
sshhost=( 172.16.100.27 );
		echo Syncing To Server
		echo remote  Books
                rsync -avuc -C -e ssh ../../target/*.tar.gz root@$sshhost:/tmp/rebasoft-app.tar.gz

for ip in ${sshhost[@]}

do

ssh -t root@$ip /bin/sh <<\EOF
tar zxvf /tmp/rebasoft-app.tar.gz -C /
/etc/init.d/appauditord restart
EOF
done

