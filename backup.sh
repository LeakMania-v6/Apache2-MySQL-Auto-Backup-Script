#!/bin/bash

date=`date '+[%Y_%m_%d]<->[%H-%M-%S]'`
mysql_backup_name=mysql_backup_$date.zip
site_backup_name=site_backup_$date.zip

#Timeout between every backups (in seconds).
timeout=86400

#Database login informations.
db_user='username'
db_password='password'

#Backup password.
#It's recommended to use an very strong password here.
backup_pw='very_strong_password'

#Here you need to put your anonfile token.
#Get your anonfile token here: https://anonfile.com/docs/api
#Only available for registered peoples.
anonfile_token='token'

#List all websites you want to backup here.
#Exemple: sites=("site1" "site2")
sites=("public_html")

#List all databases you want to backup here.
#Exemple: databases=("database1" "database2")
databases=("main_database")

#Folder where you store your website(s)
sites_path='/var/www/'
sites_paths=''
for str in "${sites_paths[@]}"
do
	sites_paths+=' '$sites_path$str
done
zip --password $backup_pw $site_backup_name -r$sites_paths

files=''
for str in "${databases[@]}"
do
	mysqldump --user=$db_user --password=$db_password --databases $str > $str.sql
	files+=$str'.sql '
done

mkdir backups
mv *.sql backups
zip --password $backup_pw $mysql_backup_name -r backups
rm -rf backups

curl -F "file=@$mysql_backup_name" https://anonfile.com/api/upload?token=$anonfile_token
curl -F "file=@$site_backup_name" https://anonfile.com/api/upload?token=$anonfile_token

rm $site_backup_name
rm $mysql_backup_name

sleep $timeout

./backup.sh

echo $files