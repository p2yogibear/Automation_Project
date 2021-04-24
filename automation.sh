#!/bin/sh

s3_bucket=upgrad-yogesh
myname=Yogesh
timestamp=$(date '+%d%m%Y-%H%M%S')

FILE=/var/www/html/inventory.html

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
size="$(wc -c <"${myname}-httpd-logs-${timestamp}.tar")"

if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist."
    echo "create the file."
    echo "Log Type               Date Created               Type      Size " >> $FILE
fi    
    echo "httpd-logs		 $timestamp	            tar	      $size" >> $FILE    


aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

cronjob=/etc/cron.d/automation

if [ ! -f "$cronjob" ]; then
    echo "$cronjob does not exist."
    touch /etc/cron.d/automation
    echo "* * * * * root /root/Automation_Project/automation.sh" >> $cronjob
fi    


