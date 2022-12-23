#!/bin/bash

HOSTADDR=134.209.71.56                #print your remote host here
SSHUSER=root                          #print here your ssh username
privatekey=/home/linux/.ssh/id_oops   #path to your privatekey
LOCALDIR=/home/linux                  #path to local directory

ssh $SSHUSER@$HOSTADDR -i $privatekey 'mkdir /usr/local/out_files'
#extracting uniq IP's for last two hours from containerized NGINX access.log on remote host and write it to a file, then awk extracts unique IP's and write them to another file
ssh $SSHUSER@$HOSTADDR -i $privatekey 'docker logs --since 2h $(docker ps | grep nginx | awk '\''{print $1}'\'') > /usr/local/out_files/logs-nginx.txt'
ssh $SSHUSER@$HOSTADDR -i $privatekey 'awk '\''{print $1}'\'' /usr/local/out_files/logs-nginx.txt | sort | uniq -c > /usr/local/out_files/nginx-awk_log_$(date +%d_%b_%H_%M_%S).txt'

#adding filename variable that we will need further
filename=$(ssh $SSHUSER@$HOSTADDR -i $privatekey 'cd /usr/local/out_files/; ls -t | head -1')

#copy file from remote host using scp utility
scp -i $privatekey $SSHUSER@$HOSTADDR:/usr/local/out_files/$filename $LOCALDIR/$filename

#removing file from remote host (optional)
#ssh $SSHUSER@$HOSTADDR -i $privatekey 'rm -rf /usr/local/out_files/$filename'
ssh $SSHUSER@$HOSTADDR -i $privatekey 'rm /usr/local/out_files/logs-nginx.txt'

#rm $LOCALDIR$filename


cat /home/linux/$filename