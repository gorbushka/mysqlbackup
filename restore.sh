#!/bin/sh
PATH=/usr/mysql/test1/2016-10-05
HOST_DB=127.0.0.1
PORT=3306
#USER_DB=abackup
PASS_DB=a

for DB in `/bin/ls $PATH` ; do
    echo $DB
    DIR=$PATH/$DB
    /usr/bin/mysqladmin -u $USER_DB -p$PASS_DB create $DB
    echo $DIR/routines-nodata-$DB.sql.gz
    /bin/gunzip -c $DIR/routines-nodata-$DB.sql.gz | /usr/bin/mysql -h $HOST_DB -u $USER_DB -p$PASS_DB $DB
    /bin/rm -f $DIR/routines-nodata-$DB.sql.gz
    for TABLE_FILE in `/bin/ls $DIR` ; do
        echo $TABLE_FILE
        /bin/gunzip -c $DIR/$TABLE_FILE | /usr/bin/mysql -h $HOST_DB -u $USER_DB -p$PASS_DB $DB
    done
done
