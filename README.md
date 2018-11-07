# mysql-trigger-logger
`mysql-trigger-logger.sql` demonstrates how to use MySQL triggers to log the timestamp, user, SQL and a custom note for unexpected changes ("heisenbugs") from `UPDATE` or `INSERT` statements to a logging table according to custom conditional statements.

## Getting Started

1. Download `mysql-trigger-logger.sql`
2. Edit the trigger definitions logic after line 22 for your use case (you should not need to update the stored procedure)
3. Test in your development environment first
4. Ask your DBA to install it in other environments. Note that adding triggers will interfere with trigger-based schema change tools like `pt-online-schema-change`
5. Matching SQL queries will be inserted into the `debug_log` table. Either check that table periodically manually, or use one of the provided cron jobs like `notify-trigger-logger.pl` to send alert emails automatically.

## Cron Jobs

The following cron scripts (tested on Linux) are provided to read the logging table, `debug_log`, for new alerts (`alerted='N'`), send the alert email, then toggle that row to `alerted='Y'`:

1. `notify-trigger-logger.pl` (written in Perl)
2. `notify-trigger-logger.py` (written in Python)
3. `notify-trigger-logger.sh` (written in bash. avoid embedded tabs in the query and note columns for best results.)

There are minimal dependencies:

* the mysql client package for your OS, on Redhat/CentOS typically installed by `sudo yum -y install mysql-client`
* for Perl, a mailer compatible with the `sendmail` program name from either the sendmail or postfix packages and `sudo cpan install DBI DBD::mysql`
* for Python, a mailer compatible with the `sendmail` program name from either the sendmail or postfix packages and `sudo pip install MySQLdb`
* for bash, the `mailx` command

## Security

1. No temporary files are created, and no files are read or written.
2. The scripts can be run as a non-privileged OS user and made read-only to that user to make the database password private or ...
3. You can move the login details to `/etc/notify-trigger-logger.ini` to centralize credentials.
4. A limited-privilege MySQL database user can be created with `GRANT SELECT, UPDATE on debug_log to 'debug_log'@'127.0.0.1';`
5. The default email alerts contain raw SQL statements, which could contain PII or PHI. You may want to omit or mask the queries for compliance reasons.
6. If HTML can be injected from an end-user, then you should use the Perl or Python scripts and escape the query text. bash scripts are impractical to harden against unknown input strings.

## Notes

1. Adding triggers to busy tables will impact performance since triggers are executed for all rows, even if your logic refers to a subset of rows.
2. It's recommended to try simpler debugging methods first, like grepping SQL statements in source code or reading application logs, before installing triggers in your production database. This use of triggers is a last resort to narrow down the source of an intermittent  problem.
3. MySQL has a limit of one trigger type, `INSERT` or `UPDATE`, per table. Additional `CREATE TRIGGER` statements will be skipped.
4. The provided cron scripts send one alert per log entry, all at once. If your triggers log many rows, then you will get many alert emails. There are several ways to customize the alerting behavior:
  * add a counter in the inner loop of the script and exit after say 10 alerts per run, or use `LIMIT 10` in the `SELECT` statement
  * change the `SET alerted='Y' WHERE id=` to `note=` or `alerted='N'` to mark multiple items as already alerted
  * do `SELECT id, ts, user, query, note, COUNT(*) cnt FROM debug_log WHERE alerted='N' GROUP BY note` to send one alert email per note string with a count per note string.

## Alert Email Sample

```text
From: root@localhost
To: me@apple.com
Subject: notify-trigger-logger.pl: 1: unexpected value in client.intervals

Time: 2018-11-05 17:58:53
User: debug_log@127.0.0.1
Query:
INSERT INTO client SET intervals = 15 WHERE id = 1;
```

## License

MIT License
