#! /bin/bash



ip_address=( 172.16.100.34 172.16.100.33 172.16.100.32 172.16.100.31 172.16.100.30 172.16.100.22 172.16.100.23 172.16.100.24 172.16.100.26 172.16.100.27 172.16.100.28 172.16.100.29 );


for ip in ${ip_address[@]}



do



ssh -t root@$ip /bin/sh <<\EOF



yum -y update
yum -y install telnet glibc.x86_64 man wget openssh-clients lynx bc gcc sed rsync chkconfig perl perl-CPAN perl-DBI perl-DBD-Pg perl-Net-SSLeay openssl perl-IO-Tty tcpdump tcpreplay net-snmp-utils net-snmp dstat iotop sysstat quagga quagga-contrib iptraf samba nscd.x86_64 pam_krb5.x86_64 samba-winbind.x86_64 system-config-network-tui lsof parted nfs-utils


##### Update Webmin #####

if [ ! -f /opt/software/webmin-1.820-1.noarch.rpm ]; then

wget http://prdownloads.sourceforge.net/webadmin/webmin-1.820-1.noarch.rpm -P /opt/software
rpm -Uvh /opt/software/webmin-1.820-1.noarch.rpm
wget --no-cache http://builds.rebasoft.net/builder/rebasoft_webmin_new.tgz

##### Update JAVA #####

if [ ! -f /usr/java/jre1.8.0_111 ]; then

rm -rf /opt/java
wget http://builds.rebasoft.net/builder/jre/jre-8u111-linux-x64.rpm -P /opt/software
rpm ivf /opt/software/jre-8u111-linux-x64.rpm
ln -s /usr/java/jre1.8.0_111/ /opt/java

fi

EOF


done
