#!/bin/bash

ip='172.16.100.29'

if [ ! -f "/opt/Rebasoft/MACAuditor/saber.pid" ]; then
echo "$ip Auditor Core Process is down!" | mail lee.moores@rebasoft.net
fi

if [ ! -f "/opt/Rebasoft/ApplicationAuditor/scimitar.pid" ]; then
echo "$ip Application Auditor Process is down!" | mail lee.moores@rebasoft.net
fi

