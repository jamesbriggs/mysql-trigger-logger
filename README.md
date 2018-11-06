# mysql-trigger-logger
mysql-trigger-logger.sql demonstrates how to use MySQL triggers to log the timestamp, user, SQL and a note for unexpected changes ("heisenbugs") from UPDATE or INSERT statements to a logging table according to custom logic.

## Getting Started

1. Download mysql-trigger-logger.sql
2. Edit the trigger definitions logic for your use case (you should not need to update the stored procedure)
3. Test in your development environment first
4. Ask your DBA to install it in other environments. Note that adding triggers will interfere with trigger-based schema change tools like pt-osc.
5. Matching SQL queries will be inserted into the debug_log table. Either check that table peridically manually, or use a cron job like notify-trigger-logger.pl to send alert emails automatically.

## Notes

1. Adding triggers to busy tables will impact performance since triggers are executed for all rows, even if your logic refers to a subset of rows.
2. Trying other debugging methods first, like grepping SQL statements in source code, is recommended before installing triggers in your production database. This is a last resort to narrow down the source of a problem.
3. MySQL has a limit of one trigger type per table.

## License

MIT License
