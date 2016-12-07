#!/bin/bash



ip_address=( 172.16.100.22 172.16.100.23 172.16.100.24 172.16.100.26 172.16.100.27 172.16.100.28 172.16.100.29 172.16.100.32 172.16.100.33 );


for ip in ${ip_address[@]}



do



ssh -t root@$ip /bin/sh <<\EOF


su rebasoft
psql
\c rebasoft
delete from params where key = 'uuid';
\q
exit
service macauditord restart
su rebasoft
psql
\c rebasoft_appauditor
delete from params where key = 'uuid';
\q
exit
service appauditord restart

EOF


done
