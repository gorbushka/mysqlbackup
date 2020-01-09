#! /bin/bash

#
# MySQL Backup scripts from SLAVE

database=""
host=""
port="3306"
user="wbackup"
password=""
backup_dir="/usr/mysql/backup/full"

MYSQLDUMP="$(which mysqldump)"
MYSQL="$(which mysql)"
NOWDATE=$(date +"%F")
DAYSLATEDATE=$(date --date="-2 day" +"%F")
MYSQL_CMD="$MYSQL -u $user -h $host -p$password "


[ ! -d $backup_dir ] && `mkdir -p $backup_dir` || :

filedb="$backup_dir/full-alldb-$NOWDATE.sql.gz"
filepos="$backup_dir/full-pos-$NOWDATE"

$MYSQL_CMD -A -e"STOP SLAVE SQL_THREAD;"
$MYSQL_CMD -A -E -e"SHOW SLAVE STATUS;"  > $filepos

$MYSQLDUMP --master-data=2 --all-databases -u $user -h $host -p$password | gzip > $filedb

$MYSQL_CMD -A -e"START SLAVE;"

cp -f $filedb $backup_dir/full-alldb-state.sql.gz
cp -f $filepos $backup_dir/full-pos-state

if [ $? -eq 0 ];then
   echo "The back up of the database $database has been completed successfully"
   if [ -e $backup_dir/full-alldb-$DAYSLATEDATE.sql.gz ]
   then
    rm -f $backup_dir/full-alldb-$DAYSLATEDATE.sql.gz
   fi
   if [ -e $backup_dir/full-pos-$DAYSLATEDATE ]
   then
    rm -f $backup_dir/full-pos-$DAYSLATEDATE
   fi
else
   echo "Error occured while backing up the $database database"
fi
