# mysql-trigger-logger
mysql-trigger-logger.sql demonstrates how to use MySQL triggers to log the timestamp, user, SQL and a note for unexpected changes ("heisenbugs") from UPDATE or INSERT statements to a logging table according to custom logic.

## Getting Started

1. Download mysql-trigger-logger.sql
2. Edit the trigger definitions logic after line 22 for your use case (you should not need to update the stored procedure)
3. Test in your development environment first
4. Ask your DBA to install it in other environments. Note that adding triggers will interfere with trigger-based schema change tools like pt-osc.
5. Matching SQL queries will be inserted into the debug_log table. Either check that table periodically manually, or use one of the provided cron jobs like notify-trigger-logger.pl to send alert emails automatically.

## Cron Jobs

The following cron scripts (tested on Linux) are provided to read the logging table, debug_log, for new alerts (alerted='N'), send the alert email, then toggle that row to alerted='Y':

1. notify-trigger-logger.pl (written in Perl)
2. notify-trigger-logger.py (written in Python)
3. notify-trigger-logger.sh (written in bash. avoid embedded tabs in the query and note columns for best results.)

## Notes

1. Adding triggers to busy tables will impact performance since triggers are executed for all rows, even if your logic refers to a subset of rows.
2. It's recommended to try simpler debugging methods first, like grepping SQL statements in source code or reading application logs, before installing triggers in your production database. This use of triggers is a last resort to narrow down the source of an intermittent  problem.
3. MySQL has a limit of one trigger type, INSERT or UPDATE, per table. Additional CREATE TRIGGER statements will be skipped.
4. The provided cron scripts send one alert per log entry. If your triggers log many rows, then you will get many alerts with the default scripts. There are several ways to customize the alerting behavior:
 i. add a counter in the inner loop
 ii. add a LIMIT 10 statement
 iii. change the SET alerted='Y' WHERE clause from id= to note= or alerted='N'

## License

MIT License
