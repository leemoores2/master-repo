#!/bin/bash/

# Open 5432 port for postgresql #

if ! grep -q "-A INPUT -p tcp -m tcp --dport 5432 -j ACCEPT" /etc/sysconfig/iptables ; then

echo "Open 5432 in IPTABLES";
iptables -A INPUT -p tcp --dport 5432 -j ACCEPT

service iptables restart

fi

# Change listen_address to * in postgresql.conf file #

if ! grep -q "listen_address = localhost" /var/lib/pgsql/9.4/data/postgresql.conf ; then

echo "Listening Address";
sed -i "s/listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/pgsql/9.4/data/postgresql.conf

fi

tcpconnection=$(cat /var/lib/pgsql/9.4/data/pg_hba.conf | grep 10.100.1.0/24)
if [ -z "$tcpconnection" ] ; then
echo "TCP Connection";                                                                                                                  
echo "host all all 10.100.1.0/24 trust" >> /var/lib/pgsql/9.4/data/pg_hba.conf
service postgresql-9.4 restart
fi
