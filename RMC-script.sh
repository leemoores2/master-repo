#!/bin/bash

# Centos 6.8 Minimal Install
# Disable SELINUX
if grep -q SELINUX=enforcing /etc/selinux/config; then
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
shutdown -r now
exit 0
else
    echo "no need to restart for selinux"
fi

# Rebasoft User
useradd -m rebasoft
echo rebasoft:Rebas0ft | chpasswd
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g; s/PermitRootLogin yes/PermitRootLogin no/g; s/#PermitRootLogin no/PermitRootLogin no/g' /etc/ssh/sshd_config
/etc/init.d/sshd restart
mkdir -p /opt/pgsql /opt/Rebasoft /var /var/lib /etc/raddb
ln -s /opt/pgsql /var/lib/pgsql

# Installations
yum -y update
yum -y install telnet glibc.x86_64 man wget openssh-clients lynx bc gcc sed rsync chkconfig perl perl-CPAN perl-DBI perl-DBD-Pg perl-Net-SSLeay openssl perl-IO-Tty tcpdump tcpreplay net-snmp-utils net-snmp dstat iotop sysstat quagga quagga-contrib iptraf samba nscd.x86_64 pam_krb5.x86_64 samba-winbind.x86_64 system-config-network-tui lsof parted nfs-utils

# RSYSLOG Configuration File
wget --no-cache -O /etc/rsyslog.conf "http://builds.rebasoft.net/builder/rsyslog.conf"
/etc/init.d/rsyslog stop
chkconfig --level 0123456 rsyslog off
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
iptables -A INPUT -p tcp -m tcp --dport 15672 -j ACCEPT
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
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 81 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 444 -j ACCEPT
iptables -A INPUT -p tcp --dport 10000 -j ACCEPT
iptables -A INPUT -p tcp --dport 9000 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type timestamp-request -j DROP
iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited
iptables -A FORWARD -j REJECT --reject-with icmp-host-prohibited
/etc/init.d/iptables save

# security change for TCP timestamp
sysctl -w net.ipv4.tcp_timestamps=0
echo "Rebasoft RMC Appliance" > /etc/issue
echo "">> /etc/issue
echo "$(ifconfig eth0 | grep inet)" >> /etc/issue
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

# PostgreSQL V8.4
yum -y install postgresql-server postgresql postgresql-jdbc
/etc/init.d/postgresql initdb
mv -f /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf.orig
mv -f /var/lib/pgsql/data/postgresql.conf /var/lib/pgsql/data/postgresql.conf.orig
wget --no-cache -O /var/lib/pgsql/data/pg_hba.conf "http://builds.rebasoft.net/builder/pg_hba.conf"
wget --no-cache -O /var/lib/pgsql/data/postgresql.conf "http://builds.rebasoft.net/builder/postgresqlAppliance.conf"
chkconfig --level 345 postgresql on
/etc/init.d/postgresql restart
wget --no-cache -O /opt/software/createRMCDB.txt "http://builds.rebasoft.net/builder/createRMCDB.txt"
su postgres < /opt/software/createRMCDB.txt

# NTP
chkconfig --level 345 snmpd on
/etc/init.d/snmpd start
yum -y install ntp ntpdate
/etc/init.d/ntpd stop
chkconfig --levels 345 ntpd on
ntpdate pool.ntp.org
/etc/init.d/ntpd start

# Java Runtime Environment 1.8
wget --no-cache -O /opt/software/jre-8u101-linux-x64.rpm "http://builds.rebasoft.net/builder/jre/jre-8u101-linux-x64.rpm"
rpm -Uvh /opt/software/jre-8u101-linux-x64.rpm
ln -s /usr/java/jre1.8.0_101/ /opt/java

# RMC
wget "http://builds.rebasoft.net/linux/$rmcname" -P /opt/software && tar -zvxf "/opt/software/$rmcname" -C /
cp -n /opt/Rebasoft/rmc/rmcd /etc/init.d/rmcd
chmod 755 /etc/init.d/rmcd
/sbin/chkconfig --add rmcd
/sbin/chkconfig --level 345 rmcd on
/etc/init.d/rmcd start

# Final Configurations
chkconfig --level 0123456 postfix off
/etc/init.d/postfix stop

# Rabbit MQ

##### Adding repository entry #####
wget https://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm -P /opt/software/
rpm -Uvh /opt/software/erlang-solutions-1.0-1.noarch.rpm 

##### Installing Erlang #####
yum -y install erlang

##### Install RabbitMQ server #####
wget --no-cache http://www.convirture.com/repos/definitions/rhel/6.x/convirt.repo -P /etc/yum.repos.d/
yum -y install socat
wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.5/rabbitmq-server-3.6.5-1.noarch.rpm -P /opt/software/
rpm --import https://www.rabbitmq.com/rabbitmq-release-signing-key.asc
yum -y install /opt/software/rabbitmq-server-3.6.5-1.noarch.rpm

##### Configure Process #####
chkconfig rabbitmq-server on

##### Start the Server #####
/etc/init.d/rabbitmq-server start

##### Create RabbitMQ Configuration Files #####
cd /
echo "config files"
mkdir /etc/rabbitmq
chmod 755 /etc/rabbitmq
touch /etc/rabbitmq/rabbitmq-env.conf
touch /etc/rabbitmq/rabbitmq.config
echo "CONFIG_FILE=/etc/rabbitmq/rabbitmq" >> /etc/rabbitmq/rabbitmq-env.conf
echo "#NODE_IP_ADDRESS=127.0.0.1" >> /etc/rabbitmq/rabbitmq-env.conf
echo "NODENAME=rabbit@rebasvr29" >> /etc/rabbitmq/rabbitmq-env.conf
echo "[{rabbit, [{loopback_users, []}]}]." >> /etc/rabbitmq/rabbitmq.config

##### Enable RabbitMQ Management GUI #####
rabbitmq-plugins enable rabbitmq_management   

##### Add RabbitMQ user #####
rabbitmqctl add_user rebasoft R3b4s0ft
rabbitmqctl set_user_tags rebasoft administrator
rabbitmqctl set_permissions -p / rebasoft ".*" ".*" ".*"

##### Restart Server
/etc/init.d/rabbitmq-server restart

