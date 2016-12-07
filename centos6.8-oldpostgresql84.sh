#!/bin/bash

echo ### using centos 6.5, basic/minimal install
echo ### basic storage
echo ### replace exiting fs
echo ### /home has most space and this is where will will host postgresql, change script if required for another location
echo ###vi /etc/sysconfig/network-scripts/ifcfg-eth0
echo ###set "ONBOOT=yes"
echo ###set "BOOTPROTO=dhcp"
echo ###sdisbale selinux /etc/selinux
#echo "Rebasoft Auditor Appliance" > /etc/issue
#echo "">> /etc/issue
#echo "$( ifconfig -a | grep 'inet\|Link')" >> /etc/issue
#echo "" >> /etc/issue

if grep -q SELINUX=enforcing /etc/selinux/config;
then
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
echo "Need to restart for selinux"
shutdown -r now
exit 0
else
    echo "no need to restart for selinux"
fi

useradd -m rebasoft
echo rebasoft:Rebas0ft | chpasswd
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin no/PermitRootLogin no/g' /etc/ssh/sshd_config
/etc/init.d/sshd restart

mkdir /opt/pgsql
mkdir /opt/Rebasoft
mkdir /var
mkdir /var/lib
ln -s /opt/pgsql /var/lib/pgsql
server="http://builds.rebasoft.net"
restartaa=false;
restartac=false;
value=0;
#===Basics
if [ ! -f /usr/sbin/tcpdump ]; then
#yum --releasever=6.6 upgrade
yum -y update
yum install nfs-utils
yum -y install telnet
yum -y install glibc glibc.i686
yum -y install man
yum -y install wget
yum -y install openssh-clients
yum -y install lynx
yum -y install bc
yum -y install gcc
yum -y install sed
yum -y install rsync
yum -y install chkconfig
yum -y install perl perl-CPAN perl-DBI perl-DBD-Pg perl-Net-SSLeay openssl perl-IO-Tty
yum -y install tcpdump
yum -y install tcpreplay
yum -y install net-snmp-utils net-snmp
yum -y install dstat
yum -y install iotop
yum -y install sysstat
yum -y install quagga quagga-contrib
yum -y install iptraf
yum -y install samba
yum -y install nscd.x86_64 
yum -y install pam_krb5.x86_64 
yum -y install samba-winbind.x86_64
yum -y install system-config-network-tui
yum -y install lsof
yum -y install parted
#yum -y install mrtg

#http://www.openlogic.com/wazi/bid/339238/Add-AD-authentication-to-CentOS-in-four-easy-steps
fi
#===
cd /
mkdir /opt/scripts
mkdir /opt/software
mkdir /opt/software/samplicator
cd /opt/scripts

# Add in the appliance monitoring scripts
wget --no-cache -O aa_mon.sh "$server/builder/aa_mon.sh"
wget --no-cache -O ac_mon.sh "$server/builder/ac_mon.sh"
wget --no-cache -O disk_mon.sh "$server/builder/disk_mon.sh"
wget --no-cache -O postgres_mon.sh "$server/builder/postgres_mon.sh"

chmod 755 aa_mon.sh
chmod 755 ac_mon.sh
chmod 755 disk_mon.sh
chmod 755 postgres_mon.sh

rm -rf /etc/rsyslog.conf
wget --no-cache -O /etc/rsyslog.conf "$server/builder/rsyslog.conf"
service rsyslog stop

# Creating Cron Jobs for Monitoring Scripts

mon1="/opt/scripts/aa_mon.sh"
job1="*/5 * * * * $mon1"
cat <(fgrep -i -v "$mon1" <(crontab -l)) <(echo "$job1") | crontab -
mon2="/opt/scripts/ac_mon.sh"
job2="*/5 * * * * $mon2"
cat <(fgrep -i -v "$mon2" <(crontab -l)) <(echo "$job2") | crontab -
mon3="/opt/scripts/disk_mon.sh"
job3="0 */1 * * * $mon3"
cat <(fgrep -i -v "$mon3" <(crontab -l)) <(echo "$job3") | crontab -
mon4="/opt/scripts/postgres_mon.sh"
job4="*/5 * * * * $mon4"
cat <(fgrep -i -v "$mon4" <(crontab -l)) <(echo "$job4") | crontab -

echo "Rebasoft Auditor Appliance" > /etc/issue
echo "">> /etc/issue
echo "$(ifconfig eth0 | grep inet)" >> /etc/issue
echo "" >> /etc/issue

wget --no-cache -O aatouse.txt "$server/builder/aatouse.txt"
wget --no-cache -O actouse.txt "$server/builder/actouse.txt"

cd /opt/software
if [ ! -f /opt/software/webmin-1.791-1.noarch.rpm ]; then
wget --no-cache -O webmin-1.791-1.noarch.rpm "$server/builder/webmin-1.791-1.noarch.rpm"
rpm -Uvh webmin-1.791-1.noarch.rpm
wget --no-cache http://builds.rebasoft.net/builder/rebasoft_webmin_new.tgz
tar -vxzf rebasoft_webmin_new.tgz -C /
if grep -q rebasoft /etc/webmin/webmin.acl;
then
echo " rebasoft webmin already enabled"
else
sed -i 's/ postgresql/ rebasoft postgresql/g' /etc/webmin/webmin.acl
rm -f /etc/webmin/module.infos.cache
/etc/init.d/webmin restart
fi
fi
mkdir /etc/raddb
wget --no-cache -O /etc/raddb/server "$server/builder/server"
wget --no-cache -O /lib64/security/pam_radius_auth.so "$server/builder/pam_radius_auth.so"
chmod 755 /lib64/security/pam_radius_auth.so

read -r aaname</opt/scripts/aatouse.txt
read -r acname</opt/scripts/actouse.txt

iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p udp --dport 123 -j ACCEPT
iptables -A INPUT -p udp --dport 161 -j ACCEPT
iptables -A INPUT -p udp --dport 162 -j ACCEPT
iptables -A INPUT -p udp --dport 1812 -j ACCEPT
iptables -A INPUT -p udp --dport 1813 -j ACCEPT
iptables -A INPUT -p udp --dport 2055 -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --dport 514 -j ACCEPT
iptables -A INPUT -p udp --dport 515 -j ACCEPT
iptables -A INPUT -p udp --dport 67 -j ACCEPT
iptables -A INPUT -p udp --dport 1645 -j ACCEPT
iptables -A INPUT -p udp --dport 2050:2060 -j ACCEPT
iptables -A INPUT -p udp --dport 510:520 -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 54321:54330 -j ACCEPT
iptables -A INPUT -p tcp --dport 5432 -j ACCEPT
iptables -A INPUT -p tcp --dport 8082 -j ACCEPT
iptables -A INPUT -p tcp --dport 8087 -j ACCEPT
iptables -A INPUT -p tcp --dport 8482 -j ACCEPT
iptables -A INPUT -p tcp --dport 8487 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 81 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 444 -j ACCEPT
iptables -A INPUT -p tcp --dport 10000 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type timestamp-request -j DROP
iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited
iptables -A FORWARD -j REJECT --reject-with icmp-host-prohibited

/etc/init.d/iptables save

# security change for TCP timestamp
sysctl -w net.ipv4.tcp_timestamps=0

echo "Rebasoft Auditor Appliance" > /etc/issue
echo "">> /etc/issue
echo "$(ifconfig eth0 | grep inet)" >> /etc/issue
echo "" >> /etc/issue

echo "==Postgres"
if [ ! -f /var/lib/pgsql/pgstartup.log ]; then
yum -y install postgresql-server
yum -y install postgresql
yum -y install postgresql-jdbc

/etc/init.d/postgresql initdb
mv -f /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf.orig
mv -f /var/lib/pgsql/data/postgresql.conf /var/lib/pgsql/data/postgresql.conf.orig
cd /var/lib/pgsql/data/
wget "$server/builder/pg_hba.conf"
wget --no-cache -O /var/lib/pgsql/data/postgresql.conf "$server/builder/postgresqlAppliance.conf"

chkconfig --level 345  postgresql on
/etc/init.d/postgresql restart
cat /var/lib/pgsql/pgstartup.log
cd /var/lib
ls -lrt
cd /opt/software
wget --no-cache -O /opt/software/provisionDB.txt "$server/builder/provisionDB.txt"
wget --no-cache -O /opt/software/createAADB.txt "$server/builder/createAADB.txt"
wget --no-cache -O /opt/software/createACDB.txt "$server/builder/createACDB.txt"
su - postgres < /opt/software/createAADB.txt
su - postgres < /opt/software/createACDB.txt

fi

echo "=====NTP"
if [ ! -f "/etc/init.d/snmpd" ]; then
chkconfig --level 345 snmpd on
/etc/init.d/snmpd start

yum -y install ntp

/etc/init.d/ntpd stop
chkconfig --levels 345 ntpd on
ntpdate 0.us.pool.ntp.org
/etc/init.d/ntpd start
fi
echo "=========Software"

cd /opt/software/
if [ ! -f "/opt/software/jre-8u73-linux-x64.rpm" ]; then
wget "$server/builder/jre/jre-8u73-linux-x64.rpm"
rpm -Uvh jre-8u73-linux-x64.rpm
ln -s /usr/java/jre1.8.0_73/ /opt/java
/opt/java/bin/java -version
echo "install java done"

fi
echo "=======JAVA Done"
if [ ! -f "/opt/software/$acname" ]; then
restartac=true;
echo "=========$acname $restartac"
wget "$server/linux/$acname" && tar -vxf "/opt/software/$acname" -C /
echo $acname > /opt/Rebasoft/MACAuditor/installed.txt
fi

if [ ! -f "/opt/Rebasoft/MACAuditor/resources/start" ]; then
restartac=true;
cp -n /opt/Rebasoft/MACAuditor/resources/unix/start.template /opt/Rebasoft/MACAuditor/resources/start
chmod 755 /opt/Rebasoft/MACAuditor/resources/start
cp -n /opt/Rebasoft/MACAuditor/resources/unix/macauditord /etc/init.d/macauditord
chmod 755 /etc/init.d/macauditord
/sbin/chkconfig --add macauditord
/sbin/chkconfig --level 345 macauditord on

fi

if [ "$restartac" = true ]; then
/etc/init.d/macauditord restart
fi

echo "Sleeping to allow core service to start";
sleep 8

if [ ! -f "/opt/software/$aaname" ]; then
restartaa=true;
echo "=========$aaname $restartaa"
wget "$server/linux/$aaname" && tar -vxf "/opt/software/$aaname" -C /
echo $aaname > /opt/Rebasoft/ApplicationAuditor/installed.txt
fi

if [ ! -f "/opt/Rebasoft/ApplicationAuditor/scimitarResources/start" ] ; then
restartaa=true;
cp -n /opt/Rebasoft/ApplicationAuditor/scimitarResources/unix/start.template /opt/Rebasoft/ApplicationAuditor/scimitarResources/start
chmod 755 /opt/Rebasoft/ApplicationAuditor/scimitarResources/start
cp -n /opt/Rebasoft/ApplicationAuditor/scimitarResources/unix/appauditord /etc/init.d/appauditord
chmod 755 /etc/init.d/appauditord
/sbin/chkconfig --add appauditord
/sbin/chkconfig --level 345 appauditord on

fi
if [ "$restartaa" = true ]; then
/etc/init.d/appauditord restart
fi
echo "Sleeping to allow app service to start";
sleep 8

if [ ! -f "/opt/software/samplicator/samplicate" ]; then
cd /opt/software/samplicator

wget "$server/builder/samplicator/samplicate.conf.3055"
wget "$server/builder/samplicator/samplicated"
wget "$server/builder/samplicator/samplicate_i586"
wget "$server/builder/samplicator/samplicate_x64"
wget "$server/builder/samplicator/samplicator-1.3.7-beta6.tar.gz"

rm -f /opt/software/samplicator/samplicate
ln /opt/software/samplicator/samplicate_x64 /opt/software/samplicator/samplicate
chmod 755 /opt/software/samplicator/samplicate
cp /opt/software/samplicator/samplicated /etc/init.d/samplicated
chmod 755 /etc/init.d/samplicated

fi
#=======
echo Check max memory for java 
echo check postgresql db settings for memory etc
#========

cd /opt/software
chmod 744 -R /opt/Rebasoft/MACAuditor/resources/webapps/*
chmod 744 -R /opt/Rebasoft/ApplicationAuditor/scimitarResources/webapps/*
chmod 755 /opt/Rebasoft/MACAuditor/resources/wmi/wmic_32
chmod 755 /opt/Rebasoft/MACAuditor/resources/unix/makeDiagnostics.sh
chmod 755 /opt/Rebasoft/ApplicationAuditor/scimitarResources/unix/makeDiagnostics.sh
cat /opt/Rebasoft/ApplicationAuditor/scimitarResources/start
cat /opt/Rebasoft/MACAuditor/resources/start

chkconfig --level 0123456 postfix off
chkconfig --level 0123456 samplicated off
/etc/init.d/postfix stop
/etc/init.d/appauditord stop
/etc/init.d/macauditord stop
su - postgres < /opt/software/provisionDB.txt

#pcap for tcp fingerprinting
cd /usr/lib64
cp -n /opt/Rebasoft/MACAuditor/resources/unix/x64/* /usr/lib64/
ln libpcap.so.1 libpcap.so
ldconfig

exit 0