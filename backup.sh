#!/bin/sh
# backup POWERNET DB 2017
# version 20.02.2017
# Semikin Sergey
#DB_TOARCH="sms"
DB_ROOT='backup'
DB_PASSWD=""
DB_HOST=""
PATH_TOARCH=/usr/mysql/backup


DATE=$(date +"%F")
DAYSLATEDATE=$(date --date="-2 day" +"%F")
DAYDATE=$(date +"%e")

# 2 - UNKNOWN ERROR; 1 - SUCCESS; 0 - backup not successfull
echo 2 > $PATH_TOARCH/backup_status
echo "!!!!!!!!!!START!!!!!!!!!!" > $PATH_TOARCH/logme

MYSQL_CMD="| mysql -u $DB_ROOT -p$DB_PASSWD -h $DB_HOST -BN $DB"

if [ ! -d "$PATH_TOARCH" ]; then
    echo "$PATH_TOARCH" not exist
    exit 1
fi
if [ ! -d "$PATH_TOARCH/$DATE" ]; then
    mkdir $PATH_TOARCH/$DATE
fi

for DB in `echo show databases| mysql -u $DB_ROOT -p$DB_PASSWD -h $DB_HOST -BN` ; do
 if [ ! -d "$PATH_TOARCH/$DATE/$DB" ]; then
  mkdir $PATH_TOARCH/$DATE/$DB
  SQL_CMD="echo \"SHOW TABLES from $DB where Tables_in_$DB not like 'old_%' and Tables_in_$DB not like '%_log'\""
  for table in `eval $SQL_CMD $MYSQL_CMD` ; do
   echo "!!!!!!!!!!dump the $DB $table" >> $PATH_TOARCH/$DATE/debug
   mysqldump --single-transaction -q -u $DB_ROOT -p$DB_PASSWD -h $DB_HOST $DB $table | gzip > $PATH_TOARCH/$DATE/$DB/$DB-$table.sql.gz
   echo $? >> $PATH_TOARCH/$DATE/debug
  done
 fi
 echo "!!!!!!!!!!create the $DB routines " >> $PATH_TOARCH/$DATE/debug
 mysqldump --single-transaction --routines --no-data --events --triggers -u $DB_ROOT -p$DB_PASSWD -h $DB_HOST $DB | gzip > $PATH_TOARCH/$DATE/$DB/routines-nodata-$DB.sql.gz
done
echo "!!!!!!!!!!create GRANTS"  >> $PATH_TOARCH/$DATE/debug
mysql -u $DB_ROOT -p$DB_PASSWD -h $DB_HOST --skip-column-names -A -e"SELECT CONCAT('SHOW GRANTS FOR ''',user,'''@''',host,''';') FROM mysql.user WHERE user<>''" | mysql -u $DB_ROOT -p$DB_PASSWD -h $DB_HOST --skip-column-names -A | sed 's

if [ -d $PATH_TOARCH/$DATE ]; then
    BKUP_SIZE=`du -s $PATH_TOARCH/$DATE | cut -f1`
    echo $BKUP_SIZE  >> $PATH_TOARCH/$DATE/debug
    if [ $BKUP_SIZE -gt 3000000 ]; then
       echo "!!!!!!!!!!DONE!!!!!!!!!!"  > $PATH_TOARCH/logme
       echo 1 > $PATH_TOARCH/backup_status
       if [ -d "$PATH_TOARCH/$DATE" ]; then
          if [ -d "$PATH_TOARCH/$DAYSLATEDATE" ]; then
             echo "remove $PATH_TOARCH/$DAYSLATEDATE" >> $PATH_TOARCH/$DATE/debug
             rm -rf $PATH_TOARCH/$DAYSLATEDATE
             if [ $(( $DAYDATE % 7 )) -eq 0 ]; then
                echo "week"  >> $PATH_TOARCH/$DATE/debug
                cp -r -f -- $PATH_TOARCH/$DATE/* $PATH_TOARCH/week-table-backup
             fi
             if [ $DAYDATE -eq 1 ]; then
                                echo "month"  >> $PATH_TOARCH/$DATE/debug
                cp -r -f -- $PATH_TOARCH/$DATE/* $PATH_TOARCH/month-table-backup
             fi
          fi
       fi
    else
         echo "!!!!!!!!!!TOO LOW SIZE!!!!!!!!!!" > $PATH_TOARCH/logme
         echo 0 > $PATH_TOARCH/backup_status
    fi
else
      echo "!!!!!!!!!!SOMETHING GOES WRONG!!!!!!!!!!" > $PATH_TOARCH/logme
      echo 0 > $PATH_TOARCH/backup_status
fi

