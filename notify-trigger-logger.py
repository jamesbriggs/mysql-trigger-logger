#!/usr/bin/python

# Program: notify-trigger-logger.py
# Purpose: read debug_log table and send emails for rows with alerted="N"
# Env: python
# Author: James Briggs, USA
# Date: 2018 11 05
# Usage: ./notify-trigger-logger.py

import MySQLdb
import os

mailer = "/usr/sbin/sendmail" # mailer location
to = "me@apple.com"

db = MySQLdb.connect("localhost", "root", "password", "db")
 
cursor = db.cursor() 
sql = "select id, ts, user, query, note from debug_log where alerted='N'"
cursor.execute(sql)
results = cursor.fetchall() 

for row in results:
    id = row[0]
    # print id

    subject = "notify-trigger-logger.py: %s: %s" % (id, row[4])

    message = """\
To: %s
Subject: %s

Time: %s
User: %s
Query:
%s
""" % (to, subject, row[1], row[2], row[3])

    p = os.popen("%s -t -i" % mailer, "w")
    p.write(message)
    status = p.close()

    cursor2 = db.cursor() 
    sql2 = "update debug_log set alerted='Y' where id = %s" % id
    cursor2.execute(sql2)
    db.commit()
 
db.close()

