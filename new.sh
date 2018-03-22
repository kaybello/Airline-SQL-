#!/bin/bash
_db="$1"
_db_user="root"

#create database
createDatabaseIfDoesNotExist(){

  /usr/local/mysql/bin/mysql -uroot <<new.sh
    DROP DATABASE IF EXISTS \`$1\`;
    CREATE DATABASE IF NOT EXISTS \`$1\`;
    GRANT ALL PRIVILEGES ON $1.* TO '$1'@'localhost';
    GRANT FILE ON *.* to '$1'@'localhost';
    FLUSH PRIVILEGES;
new.sh
    echo "$1 created"
}

 createDatabaseIfDoesNotExist $1

# define directory containing CSV documents
documentDirectoryPath="/Users/kayode.bello/Desktop/KAYODE_SQL/"

# get a list of CSV documents in directory
csvDocuments=` ls -1 $documentDirectoryPath | grep .csv`



# loop through csv documents
for csvDocument in ${csvDocuments[@]}
do

  # remove file extension
  csvDocumentExtensionless=`echo $csvDocument | sed 's/\(.*\)\..*/\1/'`

  # define table name
  tableName="${csvDocumentExtensionless}"

  # echo "Table Name Is: $tableName"
  # echo ""

  # get header columns from CSV file
  headerColumns=`head -1 $documentDirectoryPath$csvDocument | tr ',' '\n' | sed 's/ /_/g'`

  # echo "about to get header columns for $documentDirectoryPath$csvDocuments "
  # echo ""
  # echo ""
  # echo "$headerColumns"

  #create table if it exist or not
  /usr/local/mysql/bin/mysql -u $_db_user $_db << eof
  DROP TABLE IF EXISTS \`$tableName\`;
  CREATE TABLE IF NOT EXISTS \`$tableName\` (id int(11) NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)
  )
  ;
eof
      echo "\`$tableName\` created"


  headerColumnsArray=($headerColumns)
  cnt=0
   #loop through header columns
  for item in "${headerColumnsArray[@]}"
  do
    item=${item//[$'\t\r\n']}
    if [ $cnt -eq 0 ];
    then
      #change column
      /usr/local/mysql/bin/mysql -u $_db_user $_db --execute="alter table \`$tableName\` CHANGE \`id\` \`$item\` int(11) NOT NULL "
     else
       #add column
      /usr/local/mysql/bin/mysql -u $_db_user $_db --execute="alter table \`$tableName\` add column \`$item\` text"
    fi
      #increment of variable
      ((cnt=cnt+1))
  done
       #import csvDocument into mysql
      /usr/local/mysql/bin/mysql -u $_db_user $_db << eof
      LOAD DATA LOCAL INFILE '$documentDirectoryPath/$csvDocument'
      REPLACE INTO TABLE $tableName
      FIELDS TERMINATED BY ","
      LINES TERMINATED BY "\r\n"
      IGNORE 1 LINES
      ;
eof
      echo "$csvDocument imported"

done

      echo "update Ticket_purchases_Data set date_of_purchases= STR_to_DATE(date_of_purchases, '%m/%d/%Y')" | /usr/local/mysql/bin/mysql -u $_db_user $_db
  exit
