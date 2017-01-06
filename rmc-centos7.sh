#!/bin/bash

# Centos 7.3 Minimal Install

# Disable SELINUX
if grep -q SELINUX=enforcing /etc/sysconfig/selinux; then
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g; s/SELINUX=permissive/SELINUX=disabled/g' /etc/sysconfig/selinux
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
wget --no-cache -O /opt/scripts/disk_mon.sh "http://builds.rebasoft.net/builder/disk_mon.sh"
wget --no-cache -O /opt/scripts/postgres_mon.sh "http://builds.rebasoft.net/builder/postgres_mon.sh"
chmod -R 755 /opt/scripts
(crontab -u root -l; echo "0 */1 * * * /opt/scripts/disk_mon.sh" ) | crontab -u root -
(crontab -u root -l; echo "*/5 * * * * /opt/scripts/postgres_mon.sh" ) | crontab -u root -
wget --no-cache -O /opt/scripts/rmctouse.txt "http://builds.rebasoft.net/builder/rmctouse.txt"

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
read -r rmcname</opt/scripts/rmctouse.txt

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
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=81/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=444/tcp
firewall-cmd --permanent --add-port=9000/tcp
firewall-cmd --permanent --add-port=10000/tcp
firewall-cmd --reload
firewall-cmd --list-all

# security change for TCP timestamp
sysctl -w net.ipv4.tcp_timestamps=0
echo "Rebasoft RMC Appliance" > /etc/issue
echo "">> /etc/issue
echo "$(ifconfig em1 | grep inet)" >> /etc/issue
echo "" >> /etc/issue

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
wget --no-cache -O /opt/software/createRMCDB.txt "http://builds.rebasoft.net/builder/createRMCDB.txt"
su postgres < /opt/software/createRMCDB.txt

# Java Runtime Environment 1.8
wget --no-cache -O /opt/software/jre-8u101-linux-x64.rpm "http://builds.rebasoft.net/builder/jre/jre-8u101-linux-x64.rpm"
rpm -Uvh /opt/software/jre-8u101-linux-x64.rpm
ln -s /usr/java/jre1.8.0_101/ /opt/java

# RMC
wget "http://builds.rebasoft.net/linux/$rmcname" -P /opt/software && tar zvxf "/opt/software/$rmcname" -C /
mkdir /opt/Rebasoft/rmc/logs
chmod 755 /opt/Rebasoft/rmc/logs
cp -n /opt/Rebasoft/rmc/rmcd /etc/init.d/rmcd
chmod 755 /etc/init.d/rmcd
/sbin/chkconfig --add rmcd
/sbin/chkconfig --level 345 rmcd on
/etc/init.d/rmcd start

# Final Configurations
systemctl stop postfix.service

# Rabbit MQ
##### Adding repository entry #####
yum install epel-release
yum update
wget https://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm -P /opt/software/
rpm -Uvh /opt/software/erlang-solutions-1.0-1.noarch.rpm 

##### Installing Erlang #####
yum -y install erlang

##### Install RabbitMQ server #####
wget --no-cache http://www.convirture.com/repos/definitions/rhel/6.x/convirt.repo -P /etc/yum.repos.d/
yum -y install socat
wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.1/rabbitmq-server-3.6.1-1.noarch.rpm
rpm --import https://www.rabbitmq.com/rabbitmq-signing-key-public.asc
yum install rabbitmq-server-3.6.1-1.noarch.rpm
firewall-cmd --zone=public --permanent --add-port=4369/tcp --add-port=25672/tcp --add-port=5671-5672/tcp --add-port=15672/tcp  --add-port=61613-61614/tcp --add-port=1883/tcp --add-port=8883/tcp
firewall-cmd --reload

##### Start the Server #####
systemctl start rabbitmq-server.service
systemctl enable rabbitmq-server.service

##### Create RabbitMQ Configuration Files #####
cd /
echo "config files"
mkdir /etc/rabbitmq
chmod 755 /etc/rabbitmq
touch /etc/rabbitmq/rabbitmq-env.conf
touch /etc/rabbitmq/rabbitmq.config
echo "CONFIG_FILE=/etc/rabbitmq/rabbitmq" >> /etc/rabbitmq/rabbitmq-env.conf
echo "#NODE_IP_ADDRESS=127.0.0.1" >> /etc/rabbitmq/rabbitmq-env.conf
echo "NODENAME=rabbit@" >> /etc/rabbitmq/rabbitmq-env.conf
echo "[{rabbit, [{loopback_users, []}]}]." >> /etc/rabbitmq/rabbitmq.config

##### Enable RabbitMQ Management GUI #####
rabbitmq-plugins enable rabbitmq_management
chown -R rabbitmq:rabbitmq /var/lib/rabbitmq/

##### Add RabbitMQ user #####
rabbitmqctl add_user rebasoft R3b4s0ft
rabbitmqctl set_user_tags rebasoft administrator
rabbitmqctl set_permissions -p / rebasoft ".*" ".*" ".*"

##### Restart Server
systemctl restart rabbitmq-server.service

exit 0
