#!/usr/bin/ruby

# Program: notify-trigger-logger.rb
# Purpose: read debug_log table and send emails for rows with alerted="N"
# Env: ruby
# Author: James Briggs, USA
# Date: 2019 02 10
# Usage: ./notify-trigger-logger.rb

require "rubygems"

require 'mysql'
require 'net/smtp'

   host='localhost'
   user='root'
   pass=''
   db='mydb'

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

   dbh = Mysql.new(host, user, pass, db)
   res = dbh.query("select id, ts, user, query, note from debug_log where alerted='N'")
   res.each_hash do |row|
      body = <<EOD
      Time: #{ row['ts'] }
      User: #{ row['user'] }
      Query:
      #{ row['query'] }
EOD

      send_email email_to, :body => body, :subjecft => "mysql-trigger-debugger: #{ row['id'] }: #{ row['note'] }"

      if dbh
         res2 = dbh.query("update debug_log set alerted='Y' where id=#{ row['id'] }");
      end
   end

   dbh.close if dbh
