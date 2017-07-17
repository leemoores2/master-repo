#!/bin/bash

vers=$1 # example: 29, 30
version=$2 # example: 2.9, 3.1
branch=$3 # example: M, RC
sub_version=$4 # example: 18
build_no=$5 # example: 43
prod=$6

if [[ $prod == "CORE" ]]; then
wget http://172.16.100.16:8085/browse/SAB-AC$1$4$-$5/artifact/shared/tar.gz/rebasoft-auditor-core-$2$3$4-BUILD$5.tar.gz  -P /opt/software/
pid=`cat /opt/Rebasoft/MACAuditor/saber.pid`
kill -9 ${pid}
rm -rf /opt/Rebasoft/MACAuditor
tar zxvf /opt/software/rebasoft-auditor-core-$2$3$4-BUILD$5.tar.gz -C /
cp -n /opt/Rebasoft/MACAuditor/resources/unix/start.template /opt/Rebasoft/MACAuditor/resources/start
chmod 755 /opt/Rebasoft/MACAuditor/resources/start
service macauditord start
fi

if [[ $prod == "APP" ]]; then
wget http://172.16.100.16:8085/browse/SCIM-AA$10$4-$5/artifact/shared/tar.gz/rebasoft-application-auditor-$2$3$4-$5.tar.gz  -P /opt/software/
pid=`cat /opt/Rebasoft/ApplicationAuditor/scimitar.pid`
kill -9 ${pid}
rm -rf /opt/Rebasoft/ApplicationAuditor
tar zxvf /opt/software/rebasoft-application-auditor-$2$3$4-$5.tar.gz -C /
cp -n /opt/Rebasoft/ApplicationAuditor/scimitarResources/unix/start.template /opt/Rebasoft/ApplicationAuditor/scimitarResources/start
chmod 755 /opt/Rebasoft/ApplicationAuditor/scimitarResources/start
service appauditord start
fi

# Delete files older than 5 days
find /opt/software/rebasoft*.* -mtime +5 -exec rm {} \;
