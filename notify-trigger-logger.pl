#!/usr/bin/perl

# Program: notify-trigger-logger.pl
# Purpose: read debug_log table and send emails for rows with alerted="N"
# Env: perl5
# Author: James Briggs, USA
# Date: 2018 11 05
# Usage: ./notify-trigger-logger.pl

use strict;
use diagnostics;

use DBI;

   my $DEBUG = 0;

   my $user = 'root';
   my $pw   = 'password';
   my $host = '127.0.0.1';
   my $db   = 'test';

   my $email = 'me@apple.com';
   my $mailer = '/usr/sbin/sendmail -t -oi';

   my $dbh = DBI->connect("dbi:mysql:database=$db;hostname=$host", $user, $pw) or die $DBI::errstr;

   my $sql = 'select id, ts, user, query, note from debug_log where alerted="N"';
   my $sth = $dbh->prepare($sql);
   my $rv = $sth->execute();

   my $sql2 = 'update debug_log set alerted = "Y" where id = ?';
   my $sth2 = $dbh->prepare($sql2);

   while (my ($id, $ts, $user, $query, $note) = $sth->fetchrow_array()) {
      print "$id, $ts, $user, $query, $note\n" if $DEBUG;

      open X, "|$mailer" or die $!;

      print X <<EOD;
To: $email
Subject: mysql-trigger-debugger: $id: $note

Time: $ts
User: $user
Query:
$query
EOD

      close X or die $!;

      my $rv2 = $sth2->execute($id);

      sleep 1;
   }

   $dbh->disconnect();

   exit;

