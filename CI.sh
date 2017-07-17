#!/bin/bash

vers=$1
version=$2 # example: 2.9
sub_version=$3 # example: 18
build_no=$4 # example: 43
prod=$5

if [[ $prod == "CORE" ]]; then
wget http://172.16.100.16:8085/browse/SAB-AC$1M0$3-$4/artifact/shared/tar.gz/rebasoft-auditor-core-$2M0$3-BUILD$4.tar.gz  -P /opt/software/
#pid=`cat /opt/Rebasoft/MACAuditor/saber.pid`
#kill -9 ${pid}
#rm -rf /opt/Rebasoft/MACAuditor
#tar zxvf /opt/software/rebasoft-auditor-core-$2M0$3-BUILD$4.tar.gz -C /
#cp -n /opt/Rebasoft/MACAuditor/resources/unix/start.template /opt/Rebasoft/MACAuditor/resources/start
#chmod 755 /opt/Rebasoft/MACAuditor/resources/start
#service macauditord start
fi

if [[ $prod == "APP" ]]; then
wget http://172.16.100.16:8085/browse/SCIM-AA29M018-7/artifact/shared/tar.gz/rebasoft-application-auditor-2.9M018-7.tar.gz  -P /opt/software/
#pid=`cat /opt/Rebasoft/ApplicationAuditor/scimitar.pid`
#kill -9 ${pid}
#rm -rf /opt/Rebasoft/ApplicationAuditor
#tar zxvf /opt/software/rebasoft-application-auditor-2.9M018-7.tar.gz -C /
#cp -n /opt/Rebasoft/ApplicationAuditor/scimitarResources/unix/start.template /opt/Rebasoft/ApplicationAuditor/scimitarResources/start
#chmod 755 /opt/Rebasoft/ApplicationAuditor/scimitarResources/start
#service appauditord start
fi

# Delete files older than 5 days
find /opt/software/rebasoft*.* -mtime +5 -exec rm {} \;
