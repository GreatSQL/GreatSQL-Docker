-- 
-- greatsql-test.sql
-- GreatSQL 主要功能特性自测脚本，适配版本：8.0.32-25
-- 
-- 
-- 主要测试项
-- 1. 版本号以及Revision
-- 2. 采用Oracle数据类型建表
-- 3. Oracle语法用法
-- 4. 测试rapid引擎
-- 5. 测试Clone加密
-- 6. 测试MGR特性
-- 7. 测试greatdb_ha特性
--
-- 关于检查结果：
-- 当检查结果输出内容包含 OK 时，表示检查结果正确
-- 当检查结果输出内容包含 NG（NOT GOOD缩写） 时，表示检查结果异常，需要人为再确认
-- 
--
-- CHANGELOG
-- # 2024.6.5
-- 1. 增加对 GreatSQL 新增的几个主要特性检查
-- 2. 对每项检查，对其结果都增加 OK/NG 标识
-- 3. 不再详细输出每个测试命令，但仍在脚本中保留（仅注释掉）
-- 



-- 1. VERSION
SELECT '--- 1. checking VERSION() ---' AS STAGE_1;
-- SELECT 'SELECT @@version FROM DUAL;' AS EXEC_TEST_SQL;
SELECT IF(@@version = '8.0.32-25', "OK: VERSION IS 8.0.32-25", "NG, VERSION IS NOT 8.0.32-25") AS '1.1 check: VERSION' FROM DUAL;
SELECT '                 ' FROM DUAL;
-- SELECT 'SELECT @@version_comment FROM DUAL;' AS EXEC_TEST_SQL;
SELECT IF(@@version_comment LIKE 'GreatSQL%25%79f57097e3f', "OK, Revision IS 79f57097e3f", "NG, Revision IS NOT 79f57097e3f") AS '1.2 check: VERSION_COMMENT' FROM DUAL;
SELECT '                 ' FROM DUAL;
SELECT '                 ' FROM DUAL;

-- 2. DDL & DML for Oracle compatibility
SELECT '--- 2. checking CREATE NEW DB & TABLE, INSERT & SELECT ROWS & Oracle compatibility ---' AS STAGE_2;

-- SELECT 'CREATE DATABASE IF NOT EXISTS greatsql_803225 CHARACTER SET utf8mb4;' AS EXEC_TEST_SQL;
CREATE DATABASE IF NOT EXISTS greatsql_803225 CHARACTER SET utf8mb4;

-- SELECT 'USE greatsql_803225;' AS EXEC_TEST_SQL;
USE greatsql_803225;

-- SELECT '
-- CREATE TABLE t_803225(
-- id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
-- c1 CLOB NOT NULL, 
-- c2 VARCHAR2(30) NOT NULL DEFAULT \'\',
-- c3 NUMBER UNSIGNED NOT NULL DEFAULT 0,
-- c4 PLS_INTEGER UNSIGNED NOT NULL DEFAULT 0
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;' AS EXEC_TEST_SQL;
CREATE TABLE t_803225(
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
c1 CLOB NOT NULL, 
c2 VARCHAR2(30) NOT NULL DEFAULT '',
c3 NUMBER UNSIGNED NOT NULL DEFAULT 0,
c4 PLS_INTEGER UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- SELECT 'SHOW CREATE TABLE t_803225\\G' AS EXEC_TEST_SQL;
-- SHOW CREATE TABLE t_803225\G

-- SELECT 'INSERT INTO t_803225 VALUES 
-- (?, rand(), rand(), ROUND(RAND()*1024000), ROUND(RAND()*1024000)) ... ' AS EXEC_TEST_SQL;
INSERT INTO t_803225 VALUES 
(1, rand(), rand(), ROUND(RAND()*1024000), ROUND(RAND()*1024000)),
(2, rand(), rand(), ROUND(RAND()*1024000), ROUND(RAND()*1024000)),
(4, rand(), rand(), ROUND(RAND()*1024000), ROUND(RAND()*1024000)),
(8, rand(), rand(), ROUND(RAND()*1024000), ROUND(RAND()*1024000)),
(16, rand(), rand(), ROUND(RAND()*1024000), ROUND(RAND()*1024000)),
(32, rand(), rand(), ROUND(RAND()*1024000), ROUND(RAND()*1024000));
SELECT IF(ROW_COUNT() = 6, 'OK, INSERT 6 ROWS', CONCAT('NG, INSERT ', ROW_COUNT(), ' ROWS')) AS 'check: INSERT ROWS WITH ORACLE DATA TYPE COLUMNS' FROM DUAL;
SELECT '                 ' FROM DUAL;
SELECT '                 ' FROM DUAL;


-- 3. Oracle syntax
SELECT '--- 3. checking SELECT ANY/ALL FROM t_803225 ---' AS STAGE_3;
-- SELECT 'SELECT * FROM t_803225 WHERE id < ALL(4,8,16);' AS EXEC_TEST_SQL;
SELECT COUNT(*) INTO @ROWS FROM t_803225 WHERE id < ALL(4,8,16);
SELECT IF(@ROWS = 2, 'OK, FOUND 2 ROWS', CONCAT('NG, FOUND ', @ROWS, ' ROWS')) AS '3.1 check: FOUND_ROWS(ALL)' FROM DUAL;
SELECT '                 ' FROM DUAL;

-- SELECT 'SELECT * FROM t_803225 WHERE id < ANY(4,8,16);' AS EXEC_TEST_SQL;
SELECT COUNT(*) INTO @ROWS FROM t_803225 WHERE id < ANY(4,8,16);
SELECT IF(@ROWS = 4, 'OK, FOUND 4 ROWS', CONCAT('NG, FOUND ', @ROWS, ' ROWS')) AS '3.2 check: FOUND_ROWS(ANY)' FROM DUAL;
SELECT '                 ' FROM DUAL;

-- SELECT 'DROP TABLE IF EXISTS t_803225;';
DROP TABLE IF EXISTS t_803225;

-- SELECT '--- SELECT SYSDATE IN DEFAULT MODE ---';
-- SELECT 'SELECT SYSDATE(), SYSDATE;' AS EXEC_TEST_SQL;
-- SET sql_mode = DEFAULT;
-- SELECT SYSDATE(), SYSDATE;

-- SELECT '--- SELECT SYSDATE IN ORACLE MODE ---';
-- SELECT 'SET sql_mode = ORACLE;' AS EXEC_TEST_SQL;
SET sql_mode = ORACLE;
SELECT IF(@@sql_mode = 'PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ORACLE,STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION', 'OK, ORACLE MODE', 'NG, NOT ORACLE MODE') AS '3.3 check: SQL_MODE' FROM DUAL;
SELECT '                 ' FROM DUAL;
SELECT '3.4 check: SYSDATE IN ORACLE MODE' AS '3.4 check: SYSDATE IN ORACLE MODE' FROM DUAL;
-- SELECT 'SELECT SYSDATE(), SYSDATE;' AS EXEC_TEST_SQL;
SELECT SYSDATE(), SYSDATE;
SELECT '                 ' FROM DUAL;

-- SELECT 'SET sql_mode = DEFAULT;' AS EXEC_TEST_SQL;
SET sql_mode = DEFAULT;
SELECT IF(@@sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION', 'OK, DEFAULT MODE RESET SUCC', 'NG, DEFAULT MODE RESET FAIL') AS '3.5 check: SQL_MODE' FROM DUAL;
SELECT '                 ' FROM DUAL;
SELECT '                 ' FROM DUAL;


-- 4. Rapid ENGINE
SELECT '--- 4. checking RAPID ENGINE ---' AS STAGE_4;
-- SELECT 'INSTALL PLUGIN Rapid SONAME "ha_rapid.so"';
INSTALL PLUGIN Rapid SONAME 'ha_rapid.so';

-- SELECT 'SELECT ENGINE FROM ENGINES WHERE ENGINE = 'Rapid' AND SUPPORT = 'YES';';
SELECT IF(ENGINE = "Rapid", "OK, SUPPORT Rapid ENGINE", "NG, NOT SUPPORT Rapid ENGINE") AS '4.1 check: Rapid ENGINE' FROM information_schema.ENGINES WHERE ENGINE = 'Rapid' AND SUPPORT = 'YES';
SELECT '                 ' FROM DUAL;

-- SELECT '
-- CREATE TABLE `t_803225_rapid` (
--   `id` int unsigned NOT NULL AUTO_INCREMENT,
--   `c1` int unsigned NOT NULL DEFAULT \'0\',
--   `c2` varchar(30) NOT NULL DEFAULT \'\',
--   PRIMARY KEY (`id`)
-- ) ENGINE=InnoDB;';

CREATE TABLE `t_803225_rapid` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `c1` int unsigned NOT NULL DEFAULT '0',
  `c2` varchar(30) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;


-- SELECT 'ALTER TABLE t_803225_rapid SECONDARY_ENGINE = rapid;';
ALTER TABLE t_803225_rapid SECONDARY_ENGINE = rapid;

-- SELECT 'INSERT INTO t_803225_rapid VALUES(?, RAND()*1024000, RAND()*1024000) ... ' AS EXEC_TEST_SQL;
INSERT INTO t_803225_rapid VALUES 
(1,  RAND()*1024000, RAND()*1024000),
(2,  RAND()*1024000, RAND()*1024000),
(4,  RAND()*1024000, RAND()*1024000),
(8,  RAND()*1024000, RAND()*1024000),
(16, RAND()*1024000, RAND()*1024000),
(32, RAND()*1024000, RAND()*1024000);
SELECT IF(ROW_COUNT() = 6, 'OK, INSERT 6 ROWS', CONCAT('NG, INSERT ', ROW_COUNT(), ' ROWS')) AS '4.2 check: INSERT_ROWS' FROM DUAL;
SELECT '                 ' FROM DUAL;

-- SELECT 'ALTER TABLE t_803225_rapid SECONDARY_LOAD;';
ALTER TABLE t_803225_rapid SECONDARY_LOAD;

-- SELECT 'SHOW CREATE TABLE t_803225_rapid\\G';
-- SHOW CREATE TABLE t_803225_rapid\G

-- SELECT 'SHOW TABLE STATUS like \'t_803225_rapid\'\\G';
-- SHOW TABLE STATUS like 't_803225_rapid'\G
SELECT IF(CREATE_OPTIONS = 'SECONDARY_ENGINE="rapid" SECONDARY_LOAD="1"', "OK, t_803225_rapid IS A Rapid TABLE", "NG, t_803225_rapid IS NOT A Rapid TABLE") AS '4.3 check: t_803225_rapid' FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'greatsql_803225' AND TABLE_NAME = 't_803225_rapid';
SELECT '                 ' FROM DUAL;

-- SELECT 'SET use_secondary_engine = ON; SET secondary_engine_cost_threshold = 0;'; 
-- SET use_secondary_engine = ON; SET secondary_engine_cost_threshold = 0; 

-- SELECT 'EXPLAIN SELECT * FROM t_803225_rapid;';
SELECT '4.4 check: EXPLAIN SELECT FROM Rapid TABLE' FROM DUAL;
EXPLAIN SELECT /*+ SET_VAR(use_secondary_engine=2) SET_VAR(secondary_engine_cost_threshold=0) */ * FROM t_803225_rapid;
SELECT '                 ' FROM DUAL;

-- SELECT 'SELECT COUNT(*) FROM t_803225_rapid;';
SELECT /*+ SET_VAR(use_secondary_engine=1) SET_VAR(secondary_engine_cost_threshold=0) */ COUNT(*) INTO @ROWS FROM t_803225_rapid;
SELECT IF(@ROWS = 6, 'OK, FOUND 6 ROWS', CONCAT('NG, FOUND ', @ROWS, ' ROWS')) AS '4.4 check: FOUND ROWS FROM Rapid TABLE' FROM DUAL;
SELECT '                 ' FROM DUAL;


-- 5. parallel load data
SELECT '--- 5. checking PARALLEL LOAD DATA ---' AS STAGE_5;
-- SELECT VARIABLE_NAME FROM performance_schema.global_variables WHERE VARIABLE_NAME = 'gdb_parallel_load_workers';
SELECT IF(VARIABLE_NAME = "gdb_parallel_load_workers", "OK, PARALLEL LOAD DATA", "NG, PARALLEL LOAD DATA") AS 'check: PARALLEL LOAD DATA' FROM performance_schema.global_variables where variable_name = 'gdb_parallel_load_workers';
SELECT '                 ' FROM DUAL;
SELECT '                 ' FROM DUAL;


-- 6. clone encrypt
SELECT '--- 6. checking clone encrypt ---' AS STAGE_6;
-- SELECT 'INSTALL PLUGIN CLONE SONAME "mysql_clone.so"';
INSTALL PLUGIN CLONE SONAME 'mysql_clone.so';
SELECT IF(PLUGIN_NAME = 'clone', 'OK, PLUGIN clone ACTIVE', 'NG, PLUGIN clone NOT ACTIVE') AS 'check: clone PLUGIN' FROM information_schema.PLUGINS WHERE PLUGIN_NAME = 'clone' AND PLUGIN_STATUS = "ACTIVE";
SELECT '                 ' FROM DUAL;

SELECT IF(VARIABLE_NAME = "clone_encrypt_key_path", "OK, SUPPORT clone encrypt", "NG, NOT SUPPORT clone encrypt") AS 'check: PARALLEL LOAD DATA' FROM performance_schema.global_variables where variable_name = 'clone_encrypt_key_path';
SELECT '                 ' FROM DUAL;
SELECT '                 ' FROM DUAL;


-- 7. MGR
SELECT '--- 7. checking MGR ---' AS STAGE_7;
-- SELECT 'INSTALL PLUGIN group_replication SONAME "group_replication.so"';
INSTALL PLUGIN group_replication SONAME "group_replication.so";

-- zone id
SELECT IF(VARIABLE_NAME = "group_replication_zone_id", "OK, SUPPORT MGR zone_id", "NG, NOT SUPPORT MGR zone_id") AS '7.1 check: MGR zone_id' FROM performance_schema.global_variables where variable_name = 'group_replication_zone_id';
SELECT '                 ' FROM DUAL;

SELECT IF(VARIABLE_NAME = "group_replication_arbitrator", "OK, SUPPORT MGR arbitrator", "NG, NOT SUPPORT MGR arbitrator") AS '7.2 check: MGR arbitrator' FROM performance_schema.global_variables where variable_name = 'group_replication_arbitrator';
SELECT '                 ' FROM DUAL;

SELECT IF(VARIABLE_NAME = "group_replication_primary_election_mode", "OK, SUPPORT MGR elect_mode", "NG, NOT SUPPORT MGR elect_mode") AS '7.3 check: MGR elect_mode' FROM performance_schema.global_variables where variable_name = 'group_replication_primary_election_mode';
SELECT '                 ' FROM DUAL;

-- SELECT '--- checking greatdb_ha ---';
-- SELECT 'INSTALL PLUGIN greatdb_ha SONAME "greatdb_ha.so"';
INSTALL PLUGIN greatdb_ha SONAME "greatdb_ha.so";
SELECT IF(VARIABLE_NAME = "greatdb_ha_enable_mgr_vip", "OK, SUPPORT greatdb_ha", "NG, NOT SUPPORT greatdb_ha") AS '7.4 check: greatdb_ha' FROM performance_schema.global_variables where variable_name = 'greatdb_ha_enable_mgr_vip';
SELECT '                 ' FROM DUAL;

SELECT IF(VARIABLE_NAME = "greatdb_ha_mgr_read_vip_floating_type", "OK, SUPPORT greatdb_ha vip_floating", "NG, NOT SUPPORT greatdb_ha vip_floating") AS '7.5 check: greatdb_ha vip_floating' FROM performance_schema.global_variables where variable_name = 'greatdb_ha_mgr_read_vip_floating_type';
SELECT '                 ' FROM DUAL;

-- 8. cleanup
SELECT '--- 8. clean up ---' AS STAGE_8;
DROP DATABASE IF EXISTS greatsql_803225;

