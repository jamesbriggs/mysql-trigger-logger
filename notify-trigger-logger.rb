#!/usr/bin/ruby

# Program: notify-trigger-logger.rb
# Purpose: read debug_log table and send emails for rows with alerted="N"
# Env: ruby 1.8
# Author: James Briggs, USA
# Date: 2019 02 10
# Usage: ./notify-trigger-logger.rb

require "rubygems"

require 'mysql'
require 'net/smtp'

   DEBUG=true

   # database settings
   db_host='localhost'
   db_user='root'
   db_pass=''
   db='mydb'

   # email settings
   #email_to='example@example.com'
   email_to='example@example.com'

def send_email(to, opts={})
  email_host='localhost'
  email_from=to

  opts[:server] ||= email_host
  opts[:from]   ||= email_from

  msg = <<END_OF_MESSAGE
From: #{opts[:from]}
To: #{to}
Subject: #{opts[:subject]}

#{opts[:body]}
END_OF_MESSAGE

  Net::SMTP.start(opts[:server]) do |smtp|
    smtp.send_message msg, opts[:from], to
  end
end

   begin
      dbh = Mysql.new(db_host, db_user, db_pass, db)
   rescue Mysql::Error => e
     STDERR.puts "error: #{e.error}" + ", code: #{e.errno}"
     dbh.close if dbh
     exit(1)
   ensure
   end

   res = dbh.query("select id, ts, user, query, note from debug_log where alerted='N'")
   n = 0
   res.each_hash do |row|
      next if row['id'].to_i < 1

      n = n + 1

      body = <<EOD
      Time: #{ row['ts'] }
      User: #{ row['user'] }
      Query:
      #{ row['query'] }
EOD

      send_email email_to, :body => body, :subject => "mysql-trigger-debugger: #{ row['id'] }: #{ row['note'] }"

      STDERR.puts("notice: sending email for: #{ row['note'] }") if DEBUG

      if dbh
         res2 = dbh.query("update debug_log set alerted='Y' where id=#{ row['id'] }")
      end
   end

   dbh.close if dbh

   if DEBUG
      STDERR.puts("notice: no alertable rows found") if n == 0
   end

   exit(0)

