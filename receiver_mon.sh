#!/bin/bash


logfile=/opt/Rebasoft/monitor.log
port=2055

#for port in "${portlist[@]}"
#do

#portcheck=$(/usr/sbin/lsof -i:2055 | /bin/grep root | /bin/awk '{print $3}')

portcheck=$(/usr/sbin/lsof -i:"$port" | /bin/awk '/root/{print $3}')

echo "$(date) Returned Port Value = "$port"" >> $logfile
echo "$(date) Returned Port Check Value = "$portcheck"" >> $logfile

echo "Returned Port Value = "$port""
echo "Returned Port Check Value = "$portcheck""

if [[ $portcheck != "root" ]]
 then
  echo "$(date) WARNING Application Auditor Receiver Port "$port" is down" >> $logfile
  echo "Port Check Response = "$portcheck"" >> $logfile
  /etc/init.d/appauditord restart 
fi
#done

