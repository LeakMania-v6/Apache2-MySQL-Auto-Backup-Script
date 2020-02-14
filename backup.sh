#!/bin/bash

date=`date '+[%Y_%m_%d]-[%H-%M-%S]'`
mysql_backup_name=mysql_backup_$date.zip
site_backup_name=site_backup_$date.zip

#If you don't want to use anonfile, you can change this URL
#You must know what you doing.
url="https://api.anonfile.com/upload"

#Timeout between every backups (in seconds).
timeout=43200

#Database login informations.
db_user='username'
db_password='password'

#Backup password.
#It's recommended to use an very strong password here.
backup_pw=''

#Here you need to put your anonfile token.
#Get your anonfile token here: https://anonfile.com/docs/api
#Only available for registered peoples.
token=''

#List all databases you want to backup here.
#Exemple: databases=("database1" "database2")
databases=("")

#Folder where you store your website(s)
sites_path='/var/www/'

install_depends() {
	curl -s 'http://localhost' > /dev/null || apt -y install curl
	zip_path=`which zip` || apt -y install zip
	screen -dmS zip zip || apt -y install screen
}
backup() {
	zip -9 --password $backup_pw $site_backup_name -r $sites_path
	files=''
	for str in "${databases[@]}"
	do
		mysqldump --user=$db_user --password=$db_password --databases $str > $str.sql
		files+=$str'.sql '
	done
	mkdir backups; mv *.sql backups; zip -9 --password $backup_pw $mysql_backup_name -r backups; rm -rf backups
}
upload() {
	curl -F "file=@$mysql_backup_name$url?token=$token"
	sleep 40
	curl -F "file=@$site_backup_name$url?token=$token"
}
clean() {
	rm $site_backup_name $mysql_backup_name
	clear
}

install_depends
backup
upload
clean

sleep $timeout

./backup.sh

#SOURCE: https://github.com/LeakMania-v6/Apache2-MySQL-Auto-Backup-Script