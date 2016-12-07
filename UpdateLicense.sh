#! /bin/bash

ip_address=( 172.16.100.22 );

for ip in ${ip_address[@]}

do

ssh -t root@$ip /bin/sh <<\EOF

su rebasoft
psql
\c rebasoft
delete from licenses;
INSERT into licenses (keytype,licensekey) VALUES ("saber", $1);
\q
exit
service macauditord restart


EOF

done