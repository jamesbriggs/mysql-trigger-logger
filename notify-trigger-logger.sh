#!/bin/bash

# Program: notify-trigger-logger.sh
# Purpose: read debug_log table and send emails for rows with alerted="N"
# Env: bash
# Author: James Briggs, USA
# Date: 2018 11 05
# Usage: ./notify-trigger-logger.sh

set -e

user=root
pw=password
db=test
host=localhost

email="me@apple"

out=`mysql -N -s -h $host -u $user -p$pw -e 'select id, ts, user, query, note from debug_log where alerted="N"' $db`

while IFS=$'\t' read -r -a row; do
    id="${row[0]}"
    if [[ "$id" == "" ]]; then
       break
    fi

    note="${row[4]}"
    # echo $id

    mailx -s "$0: $id: $note" "$email" << EOD
Time: ${row[1]}
User: ${row[2]}
Query:
${row[3]}
EOD

    `mysql -s -h $host -u $user -p$pw -e "update debug_log set alerted='Y' where id=$id" $db`
done <<< "$out"

set +e

exit

