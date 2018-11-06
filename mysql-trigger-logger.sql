-- Program: mysql-trigger-logger.sql
-- Author: James Briggs, USA
-- Date: 2018 11 05
-- Env: MySQL
-- License: MIT
-- Usage: edit after line 22, then: mysql> source mysql-trigger-logger.sql

DROP TABLE IF EXISTS debug_log;

CREATE TABLE IF NOT EXISTS debug_log (
   `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
   `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
   `query` varchar(1024) NOT NULL DEFAULT '',
   `user` varchar(32) NOT NULL DEFAULT '',
   `note` varchar(1024) NOT NULL DEFAULT '',
   `alerted` char(1) NOT NULL DEFAULT 'N',
   PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP PROCEDURE IF EXISTS p_log_query;

DELIMITER |
CREATE PROCEDURE p_log_query (IN in_query varchar(1024), IN in_note varchar(1024))
BEGIN
   INSERT INTO debug_log (query, user, note) VALUES (in_query, USER(), in_note);
END
|
DELIMITER ;

DROP TRIGGER IF EXISTS t_check_query_update_monitor;

DELIMITER |
CREATE TRIGGER t_check_query_update_monitor AFTER UPDATE ON monitor
FOR EACH ROW
BEGIN
   DECLARE q VARCHAR(1024);
   IF (OLD.id = 1000001 AND OLD.intervals < 5 AND NEW.intervals > 5) THEN
      SET q = (SELECT info FROM INFORMATION_SCHEMA.PROCESSLIST WHERE id = CONNECTION_ID());
      CALL p_log_query(q, 'unexpected value for intervals column');
   END IF;
END
|
DELIMITER ;

DROP TRIGGER IF EXISTS t_check_query_update_client;

DELIMITER |
CREATE TRIGGER t_check_query_update_client AFTER UPDATE ON client
FOR EACH ROW
BEGIN
   DECLARE q VARCHAR(1024);
   IF (OLD.id = 1 AND OLD.sp_enabled = 'Y' AND NEW.sp_enabled = 'N') THEN
      SET q = (SELECT info FROM INFORMATION_SCHEMA.PROCESSLIST WHERE id = CONNECTION_ID());
      CALL p_log_query(q, 'sp_enabled column disabled unexpectedly');
   END IF;
END
|
DELIMITER ;

-- Sample DBA management commands:

-- See if the procedure is installed
SHOW PROCEDURE STATUS;

-- See if the triggers are installed
SHOW TRIGGERS;

-- See if any rows logged by triggers
SELECT * FROM debug_log;

-- Prune the log table
TRUNCATE TABLE debug_log;

