#!/bin/bash

# Centos 7.3 Minimal Install

# Disable SELINUX
#if grep -q SELINUX=enforcing /etc/selinux/config; then
if grep -q SELINUX=enforcing /etc/sysconfig/selinux; then
#sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
shutdown -r now
exit 0
else
echo "no need to restart for selinux"
fi

# Rebasoft User
useradd -m rebasoft
echo rebasoft:Rebas0ft | chpasswd
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g; s/PermitRootLogin yes/PermitRootLogin no/g; s/#PermitRootLogin no/PermitRootLogin no/g' /etc/ssh/sshd_config
systemctl restart sshd.service
mkdir -p /opt/pgsql /opt/Rebasoft /var /var/lib /etc/raddb
ln -s /opt/pgsql /var/lib/pgsql

# Installations
yum -y update
yum -y install net-tools telnet glibc.x86_64 man wget openssh-clients lynx bc gcc sed rsync chkconfig perl perl-CPAN perl-DBI perl-DBD-Pg perl-Net-SSLeay openssl perl-IO-Tty tcpdump tcpreplay net-snmp-utils net-snmp dstat iotop sysstat quagga quagga-contrib iptraf samba nscd.x86_64 pam_krb5.x86_64 samba-winbind.x86_64 system-config-network-tui lsof parted nfs-utils

# RSYSLOG Configuration File
wget --no-cache -O /etc/rsyslog.conf "http://builds.rebasoft.net/builder/rsyslog.conf"
systemctl stop rsyslog.service
mkdir -p /opt/scripts /opt/software /opt/software/samplicator

# Monitoring Scripts
wget --no-cache -O /opt/scripts/aa_mon.sh "http://builds.rebasoft.net/builder/aa_mon.sh"
wget --no-cache -O /opt/scripts/ac_mon.sh "http://builds.rebasoft.net/builder/ac_mon.sh"
wget --no-cache -O /opt/scripts/disk_mon.sh "http://builds.rebasoft.net/builder/disk_mon.sh"
wget --no-cache -O /opt/scripts/postgres_mon.sh "http://builds.rebasoft.net/builder/postgres_mon.sh"
chmod -R 755 /opt/scripts
(crontab -u root -l; echo "*/5 * * * * /opt/scripts/aa_mon.sh" ) | crontab -u root -
(crontab -u root -l; echo "*/5 * * * * /opt/scripts/ac_mon.sh" ) | crontab -u root -
(crontab -u root -l; echo "0 */1 * * * /opt/scripts/disk_mon.sh" ) | crontab -u root -
(crontab -u root -l; echo "*/5 * * * * /opt/scripts/postgres_mon.sh" ) | crontab -u root -
wget --no-cache -O /opt/scripts/aatouse.txt "http://builds.rebasoft.net/builder/aatouse.txt"
wget --no-cache -O /opt/scripts/actouse.txt "http://builds.rebasoft.net/builder/actouse.txt"

# Webmin V1.820
wget http://prdownloads.sourceforge.net/webadmin/webmin-1.820-1.noarch.rpm -P /opt/software
rpm -Uvh /opt/software/webmin-1.820-1.noarch.rpm
wget --no-cache -O /opt/software/rebasoft_webmin_new.tgz "http://builds.rebasoft.net/builder/rebasoft_webmin_new.tgz" && tar -vxzf /opt/software/rebasoft_webmin_new.tgz -C /
sed -i 's/ postgresql/ rebasoft postgresql/g' /etc/webmin/webmin.acl
rm -f /etc/webmin/module.infos.cache
/etc/init.d/webmin restart
wget --no-cache -O /etc/raddb/server "http://builds.rebasoft.net/builder/server"
wget --no-cache -O /lib64/security/pam_radius_auth.so "http://builds.rebasoft.net/builder/pam_radius_auth.so"
chmod 755 /lib64/security/pam_radius_auth.so
read -r aaname</opt/scripts/aatouse.txt
read -r acname</opt/scripts/actouse.txt

firewall-cmd --permanent --add-port=1935/tcp
firewall-cmd --permanent --add-port=123/udp
firewall-cmd --permanent --add-port=161/udp
firewall-cmd --permanent --add-port=162/udp
firewall-cmd --permanent --add-port=1812/udp
firewall-cmd --permanent --add-port=1813/udp
firewall-cmd --permanent --add-port=2055/udp
firewall-cmd --permanent --add-port=53/udp
firewall-cmd --permanent --add-port=514/udp
firewall-cmd --permanent --add-port=515/udp
firewall-cmd --permanent --add-port=67/udp
firewall-cmd --permanent --add-port=1645/udp
firewall-cmd --permanent --add-port=2050-2060/udp
firewall-cmd --permanent --add-port=510-520/udp
firewall-cmd --permanent --add-port=22/tcp
firewall-cmd --permanent --add-port=54321-54330/tcp
firewall-cmd --permanent --add-port=5432/tcp
firewall-cmd --permanent --add-port=8082/tcp
firewall-cmd --permanent --add-port=8087/tcp
firewall-cmd --permanent --add-port=8482/tcp
firewall-cmd --permanent --add-port=8487/tcp
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=81/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=444/tcp
firewall-cmd --permanent --add-port=10000/tcp
firewall-cmd --reload
firewall-cmd --list-all

# security change for TCP timestamp
sysctl -w net.ipv4.tcp_timestamps=0
echo "Rebasoft Appliance" > /etc/issue
echo "">> /etc/issue
echo "$(ifconfig ens160 | grep inet)" >> /etc/issue
echo "" >> /etc/issue

# IDRAC RACADM V7.0.0
wget http://builds.rebasoft.net/builder/OM-SrvAdmin-Dell-Web-LX-7.0.0-4614_A00.tar.gz -P /opt/software
yum -y install pciutils OpenIPMI
tar zvxf /opt/software/OM-SrvAdmin-Dell-Web-LX-7.0.0-4614_A00.tar.gz -C /
rpm -Uvh /linux/RPMS/supportRPMS/srvadmin/RHEL6/x86_64/libsmbios-2.2.27-4.3.2.el6.x86_64.rpm 
rpm -Uvh /linux/RPMS/supportRPMS/srvadmin/RHEL6/x86_64/smbios-utils-bin-2.2.27-4.3.2.el6.x86_64.rpm 
rpm -Uvh /linux/RPMS/supportRPMS/srvadmin/RHEL6/x86_64/srvadmin-omilcore-7.0.0-4.304.1.el6.x86_64.rpm
rpm -Uvh /linux/RPMS/supportRPMS/srvadmin/RHEL6/x86_64/srvadmin-hapi-7.0.0-4.19.1.el6.x86_64.rpm 
rpm -Uvh /linux/RPMS/supportRPMS/srvadmin/RHEL6/x86_64/srvadmin-argtable2-7.0.0-4.2.2.el6.x86_64.rpm 
rpm -Uvh /linux/RPMS/supportRPMS/srvadmin/RHEL6/x86_64/srvadmin-racadm5-7.0.0-4.162.1.el6.x86_64.rpm
/opt/dell/srvadmin/sbin/srvadmin-services.sh start

# PostgreSQL V9.2
yum -y install postgresql
yum -y install postgresql-contrib
yum -y install postgresql-server
yum -y install postgresql-libs
yum -y install postgresql-jdbc
postgresql-setup initdb
mv -f /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf.orig
mv -f /var/lib/pgsql/data/postgresql.conf /var/lib/pgsql/data/postgresql.conf.orig
wget --no-cache -O /var/lib/pgsql/data/pg_hba.conf "http://builds.rebasoft.net/builder/pg_hba.conf"
wget --no-cache -O /var/lib/pgsql/data/postgresql.conf "http://builds.rebasoft.net/builder/postgresqlAppliance.conf"
sudo systemctl start postgresql
sudo systemctl enable postgresql
wget --no-cache -O /opt/software/provisionDB.txt "http://builds.rebasoft.net/builder/provisionDB.txt"
wget --no-cache -O /opt/software/createAADB.txt "http://builds.rebasoft.net/builder/createAADB.txt"
wget --no-cache -O /opt/software/createACDB.txt "http://builds.rebasoft.net/builder/createACDB.txt"
su postgres < /opt/software/createAADB.txt
su postgres < /opt/software/createACDB.txt

# NTP
systemctl start snmpd.service
yum -y install ntp ntpdate
systemctl stop ntpd.service
ntpdate pool.ntp.org
systemctl start ntpd.service

# Java Runtime Environment 1.8
wget --no-cache -O /opt/software/jre-8u101-linux-x64.rpm "http://builds.rebasoft.net/builder/jre/jre-8u101-linux-x64.rpm"
rpm -Uvh /opt/software/jre-8u101-linux-x64.rpm
ln -s /usr/java/jre1.8.0_101/ /opt/java

# AC
wget "http://builds.rebasoft.net/linux/$acname" -P /opt/software && tar -zvxf "/opt/software/$acname" -C /
echo $acname > /opt/Rebasoft/MACAuditor/installed.txt
cp -n /opt/Rebasoft/MACAuditor/resources/unix/start.template /opt/Rebasoft/MACAuditor/resources/start
cp -n /opt/Rebasoft/MACAuditor/resources/unix/macauditord /etc/init.d/macauditord
chmod 755 /opt/Rebasoft/MACAuditor/resources/start /etc/init.d/macauditord
/sbin/chkconfig --add macauditord
/sbin/chkconfig --level 345 macauditord on
/etc/init.d/macauditord restart
sleep 2

# AA
wget "http://builds.rebasoft.net/linux/$aaname" -P /opt/software && tar -zvxf "/opt/software/$aaname" -C /
echo $aaname > /opt/Rebasoft/ApplicationAuditor/installed.txt
cp -n /opt/Rebasoft/ApplicationAuditor/scimitarResources/unix/start.template /opt/Rebasoft/ApplicationAuditor/scimitarResources/start
cp -n /opt/Rebasoft/ApplicationAuditor/scimitarResources/unix/appauditord /etc/init.d/appauditord
chmod 755 /opt/Rebasoft/ApplicationAuditor/scimitarResources/start /etc/init.d/appauditord
/sbin/chkconfig --add appauditord
/sbin/chkconfig --level 345 appauditord on
/etc/init.d/appauditord restart
sleep 2

# Samplicator
wget --no-cache -O /opt/software/samplicator/samplicate.conf.3055 "http://builds.rebasoft.net/builder/samplicator/samplicate.conf.3055"
wget --no-cache -O /opt/software/samplicator/samplicated "http://builds.rebasoft.net/builder/samplicator/samplicated"
wget --no-cache -O /opt/software/samplicator/samplicate_i586 "http://builds.rebasoft.net/builder/samplicator/samplicate_i586"
wget --no-cache -O /opt/software/samplicator/samplicate_x64 "http://builds.rebasoft.net/builder/samplicator/samplicate_x64"
wget --no-cache -O /opt/software/samplicator/samplicator-1.3.7-beta6.tar.gz "http://builds.rebasoft.net/builder/samplicator/samplicator-1.3.7-beta6.tar.gz"
rm -f /opt/software/samplicator/samplicate
ln /opt/software/samplicator/samplicate_x64 /opt/software/samplicator/samplicate
cp -n /opt/software/samplicator/samplicated /etc/init.d/samplicated
chmod 755 /opt/software/samplicator/samplicate /etc/init.d/samplicated
chkconfig --level 0123456 samplicated off

# TCP Fingerprinting
cp -n /opt/Rebasoft/MACAuditor/resources/unix/x64/* /usr/lib64/
ln libpcap.so.1 libpcap.so
ldconfig

# Final Configurations
chmod 744 -R /opt/Rebasoft/MACAuditor/resources/webapps/* /opt/Rebasoft/ApplicationAuditor/scimitarResources/webapps/*
chmod 755 /opt/Rebasoft/MACAuditor/resources/wmi/wmic_32 /opt/Rebasoft/MACAuditor/resources/unix/makeDiagnostics.sh /opt/Rebasoft/ApplicationAuditor/scimitarResources/unix/makeDiagnostics.sh
systemctl stop postfix.service
/etc/init.d/appauditord stop
/etc/init.d/macauditord stop
su postgres < /opt/software/provisionDB.txt

# Rabbit MQ
cd ~
touch rsmb.properties
chmod 755 rsmb.properties
echo "#host=" >> rsmb.properties
echo "#port=5672" >> rsmb.properties
echo "#username=test" >> rsmb.properties
echo "#password=test" >> rsmb.properties
exit 0

