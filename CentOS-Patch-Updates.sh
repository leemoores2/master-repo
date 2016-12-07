#! /bin/bash

ip_address=( 172.16.100.29 );

for ip in ${ip_address[@]}

do

ssh -t root@$ip /bin/sh <<\EOF

yum -y remove telnet
yum -y remove glibc glibc.i686
yum -y remove man
yum -y remove wget
yum -y remove openssh-clients
yum -y remove lynx
yum -y remove bc
yum -y remove gcc
yum -y remove sed
yum -y remove rsync
yum -y remove chkconfig
yum -y remove tcpdump
yum -y remove tcpreplay
yum -y remove net-snmp-utils net-snmp
yum -y remove dstat
yum -y remove iotop
yum -y remove sysstat
yum -y remove quagga quagga-contrib
yum -y remove iptraf
yum -y remove samba
yum -y remove nscd.x86_64
yum -y remove pam_krb5.x86_64
yum -y remove samba-winbind.x86_64
yum -y remove system-config-network-tui
yum -y remove nfs-utils nfs-utils-lib
yum -y remove lsof
yum -y remove parted
yum -y remove perl perl-CPAN perl-DBI perl-DBD-Pg perl-Net-SSLeay openssl perl-IO-Tty
yum -y remove unzip

yum -y update --downloadonly --downloaddir=/opt/updates
yum -y install telnet --downloadonly --downloaddir=/opt/updates
yum -y install glibc glibc.i686 --downloadonly --downloaddir=/opt/updates
yum -y install man --downloadonly --downloaddir=/opt/updates
yum -y install wget --downloadonly --downloaddir=/opt/updates
yum -y install openssh-clients --downloadonly --downloaddir=/opt/updates
yum -y install lynx --downloadonly --downloaddir=/opt/updates
yum -y install bc --downloadonly --downloaddir=/opt/updates
yum -y install gcc --downloadonly --downloaddir=/opt/updates
yum -y install sed --downloadonly --downloaddir=/opt/updates
yum -y install rsync --downloadonly --downloaddir=/opt/updates
yum -y install chkconfig --downloadonly --downloaddir=/opt/updates
yum -y install tcpdump --downloadonly --downloaddir=/opt/updates
yum -y install tcpreplay --downloadonly --downloaddir=/opt/updates
yum -y install net-snmp-utils net-snmp --downloadonly --downloaddir=/opt/updates
yum -y install dstat --downloadonly --downloaddir=/opt/updates
yum -y install iotop --downloadonly --downloaddir=/opt/updates
yum -y install sysstat --downloadonly --downloaddir=/opt/updates
yum -y install quagga quagga-contrib --downloadonly --downloaddir=/opt/updates
yum -y install iptraf --downloadonly --downloaddir=/opt/updates
yum -y install samba --downloadonly --downloaddir=/opt/updates
yum -y install nscd.x86_64 --downloadonly --downloaddir=/opt/updates
yum -y install pam_krb5.x86_64 --downloadonly --downloaddir=/opt/updates
yum -y install samba-winbind.x86_64 --downloadonly --downloaddir=/opt/updates
yum -y install system-config-network-tui --downloadonly --downloaddir=/opt/updates
yum -y install nfs-utils nfs-utils-lib --downloadonly --downloaddir=/opt/updates
yum -y install lsof --downloadonly --downloaddir=/opt/updates
yum -y install parted --downloadonly --downloaddir=/opt/updates
yum -y install perl perl-CPAN perl-DBI perl-DBD-Pg perl-Net-SSLeay openssl perl-IO-Tty --downloadonly --downloaddir=/opt/updates
yum -y install unzip --downloadonly --downloaddir=/opt/updates

yum -y install unzip
cd /opt/updates
zip $(date +%b)_updates.zip /opt/updates/*.rpm
rm -rf *.rpm

EOF

done
