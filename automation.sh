#!/bin/sh

s3_bucket=upgrad-yogesh
myname=Yogesh
timestamp=$(date '+%d%m%Y-%H%M%S')

sudo apt update -y

if [[ -z $(apache2 -v 2>/dev/null) ]] && [[ -z $(httpd -v 2>/dev/null) ]]; then
   echo "Apache not found" 
   echo "Installing Apache server"
   apt-get install apache2 -y        	
fi

if [ $(/etc/init.d/apache2 status | grep -v grep | grep 'Apache2 is running' | wc -l) > 0 ]; then
 echo "Apache server is running."
else
  echo "Apache server is not running."
  echo "Starting the apache server"
  systemctl start apache2
  chkconfig httpd on
fi

tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log

aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar




