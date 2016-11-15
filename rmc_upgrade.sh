#! /bin/bash

ip_address=( 172.16.100.31 );

for ip in ${ip_address[@]}
do

ssh -t root@$ip /bin/sh <<\EOF

yum -y install ntp ntpdate
chkconfig ntpd on
service ntpd start
killall java
cd /
echo "Remove RMC";
rm -rf /opt/Rebasoft/rmc
rm -rf /etc/init.d/rmcd

echo "Install RMC";
wget -q http://reba.io/RMC29LATEST -O /tmp/rmc2.9.tar.gz
tar -zxvf /tmp/rmc2.9.tar.gz -C /

echo "configure macauditord process";
cp -n /opt/Rebasoft/rmc/rmcd /etc/init.d/rmcd
chmod 755 /etc/init.d/rmcd
/sbin/chkconfig --add rmcd
/sbin/chkconfig --level 345 rmcd on

echo "start rmcd service";
/etc/init.d/rmcd start

EOF
done
