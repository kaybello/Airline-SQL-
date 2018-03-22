#!/bin/bash


tableName=$1
_db_user=root
/usr/local/mysql/bin/mysql -e 'show tables' Airline_project -u $_db_user  | while read table;
do /usr/local/mysql/bin/mysql -e "SET FOREIGN_KEY_CHECKS=0;
truncate table $tableName;
SET FOREIGN_KEY_CHECKS=1;" Airline_project -u $_db_user ;
echo "$tableName trucated"
done

# /Users/kayode.bello/Desktop/truncate.sh



# tableName=$1
# _db_user=root
# IP_ADDR=localhost
# somevar=`echo "TRUNCATE TABLE $tableName" | /usr/local/mysql/bin/mysql  -h $IP_ADDR  -u $_db_user  $tableName `
# echo $somevar
