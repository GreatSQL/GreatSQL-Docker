-- 
-- greatsql-test.sql
-- GreatSQL 主要功能特性自测脚本，适配版本：8.0.32-27
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
-- 8. 测试turbo引擎
--
-- 关于检查结果：
-- 当检查结果输出内容包含 OK 时，表示检查结果正确
-- 当检查结果输出内容包含 NG（NOT GOOD缩写） 时，表示检查结果异常，需要人为再确认
-- 
-- CHANGELOG
-- # 2025.03.31
-- 1. 升级到 GreatSQL 8.0.32-27
-- 2. 针对以下几个新特性做校验
--  * 新增高性能并行查询引擎Turbo
--  * 升级Rapid引擎内核版本
--  * InnoDB Page支持zstd压缩
--  * 新增Binlog限速状态查看
-- 

SET NAMES utf8mb4;

-- 1. 版本号
SELECT '--- 1. checking VERSION() ---' AS STAGE_1;
SELECT IF(@@version = '8.0.32-27', "OK: VERSION IS 8.0.32-27", "NG, VERSION IS NOT 8.0.32-27") AS '1.1 check: VERSION' FROM DUAL;
SELECT '                 ' FROM DUAL;
SELECT IF(@@version_comment LIKE '%GreatSQL%27%aa66a385910', "OK, Revision IS aa66a385910", "NG, Revision IS NOT aa66a385910") AS '1.2 check: VERSION_COMMENT' FROM DUAL;
SELECT '                 ' FROM DUAL;
SELECT '                 ' FROM DUAL;


-- 2. Oracle兼容性
SELECT '--- 2. checking CREATE NEW DB & TABLE, INSERT & SELECT ROWS & Oracle compatibility ---' AS STAGE_2;

-- CREATE DB & TABLE
CREATE DATABASE IF NOT EXISTS greatsql_803227 CHARACTER SET utf8mb4;
USE greatsql_803227;

DROP TABLE IF EXISTS t_803227;
CREATE TABLE t_803227(
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
c1 CLOB NOT NULL, 
c2 VARCHAR2(30) NOT NULL DEFAULT '',
c3 NUMBER UNSIGNED NOT NULL DEFAULT 0,
c4 PLS_INTEGER UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- INSERT ROWS
INSERT INTO t_803227 VALUES 
(1, rand(), rand(), ROUND(RAND()*1024000), ROUND(RAND()*1024000)),
(2, rand(), rand(), ROUND(RAND()*1024000), ROUND(RAND()*1024000)),
(4, rand(), rand(), ROUND(RAND()*1024000), ROUND(RAND()*1024000)),
(8, rand(), rand(), ROUND(RAND()*1024000), ROUND(RAND()*1024000)),
(16, rand(), rand(), ROUND(RAND()*1024000), ROUND(RAND()*1024000)),
(32, rand(), rand(), ROUND(RAND()*1024000), ROUND(RAND()*1024000));
SELECT IF(ROW_COUNT() = 6, 'OK, INSERT 6 ROWS', CONCAT('NG, INSERT ', ROW_COUNT(), ' ROWS')) AS 'check: INSERT ROWS WITH ORACLE DATA TYPE COLUMNS' FROM DUAL;
SELECT '                 ' FROM DUAL;
SELECT '                 ' FROM DUAL;


-- 3. Oracle语法
SELECT '--- 3. checking SELECT ANY/ALL FROM t_803227 ---' AS STAGE_3;
-- ALL Syntax
SELECT COUNT(*) INTO @ROWS FROM t_803227 WHERE id < ALL(4,8,16);
SELECT IF(@ROWS = 2, 'OK, FOUND 2 ROWS', CONCAT('NG, FOUND ', @ROWS, ' ROWS')) AS '3.1 check: FOUND_ROWS(ALL)' FROM DUAL;
SELECT '                 ' FROM DUAL;

-- ANY Syntax
SELECT COUNT(*) INTO @ROWS FROM t_803227 WHERE id < ANY(4,8,16);
SELECT IF(@ROWS = 4, 'OK, FOUND 4 ROWS', CONCAT('NG, FOUND ', @ROWS, ' ROWS')) AS '3.2 check: FOUND_ROWS(ANY)' FROM DUAL;
SELECT '                 ' FROM DUAL;

-- SET SQL_MODE = ORACLE
SET sql_mode = ORACLE;
SELECT IF(@@sql_mode = 'PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ORACLE,STRICT_TRANS_TABLES,STRICT_ALL_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION', 'OK, ORACLE MODE', 'NG, NOT ORACLE MODE') AS '3.3 check: SQL_MODE' FROM DUAL;
SELECT '                 ' FROM DUAL;
SELECT '3.4 check: SYSDATE IN ORACLE MODE' AS '3.4 check: SYSDATE IN ORACLE MODE' FROM DUAL;

-- SYSDATE
SELECT SYSDATE(), SYSDATE;
SELECT '                 ' FROM DUAL;

-- SET SQL_MODE = DEFAULT
SET sql_mode = DEFAULT;
SELECT IF(@@sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION', 'OK, DEFAULT MODE RESET SUCC', 'NG, DEFAULT MODE RESET FAIL') AS '3.5 check: SQL_MODE' FROM DUAL;
SELECT '                 ' FROM DUAL;
SELECT '                 ' FROM DUAL;

-- DECLARE...BEGIN Syntax
SELECT '                 ' FROM DUAL;
SELECT '3.6 check: DECLARE...BEGIN Syntax' AS '3.6 check: DECLARE...BEGIN Syntax' FROM DUAL;
SET sql_mode = ORACLE;
DELIMITER //
DECLARE
BEGIN
  SELECT 'Hi GreatSQL' INTO @ret;
END; //
DELIMITER ;
SET sql_mode = DEFAULT;
SELECT IF(@ret = 'Hi GreatSQL', "OK, SUPPORT DECLARE...BEGIN Syntax", "NG, NOT SUPPORT DECLARE...BEGIN Syntax") AS '3.6 check: DECLARE...BEGIN Syntax' FROM DUAL;


-- 4. Turbo引擎
SELECT '--- 4. checking Turbo ENGINE ---' AS STAGE_4;

-- INSTALL & CHECK Turbo ENGINE
INSTALL PLUGIN Turbo SONAME 'turbo.so';
SELECT IF(ENGINE = "turbo", "OK, SUPPORT Turbo ENGINE", "NG, NOT SUPPORT Turbo ENGINE") AS '4.1 check: Turbo ENGINE' FROM information_schema.ENGINES WHERE ENGINE = 'turbo' AND SUPPORT = 'YES';
SELECT '                 ' FROM DUAL;


SELECT '4. check: EXPLAIN SELECT USING Turbo' FROM DUAL;

EXPLAIN FORMAT=TREE SELECT /*+ SET_VAR(turbo_enable=ON) SET_VAR(turbo_cost_threshold=0) */ * FROM t_803227;
SELECT '                 ' FROM DUAL;

SELECT '4. UNINSTALL Turbo ENGINE' FROM DUAL;
UNINSTALL PLUGIN turbo;

-- DROP TABLE
DROP TABLE IF EXISTS t_803227;

-- 5. Rapid引擎
SELECT '--- 4. checking RAPID ENGINE ---' AS STAGE_4;

-- INSTALL & CHECK Rapid ENGINE
INSTALL PLUGIN Rapid SONAME 'ha_rapid.so';
SELECT IF(ENGINE = "Rapid", "OK, SUPPORT Rapid ENGINE", "NG, NOT SUPPORT Rapid ENGINE") AS '4.1 check: Rapid ENGINE' FROM information_schema.ENGINES WHERE ENGINE = 'Rapid' AND SUPPORT = 'YES';
SELECT '                 ' FROM DUAL;

CREATE TABLE `t_803227_rapid` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `c1` int unsigned NOT NULL DEFAULT '0',
  `c2` varchar(30) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- SECONDARY_ENGINE
ALTER TABLE t_803227_rapid SECONDARY_ENGINE = rapid;

-- INSERT ROWS
INSERT INTO t_803227_rapid VALUES 
(1,  RAND()*1024000, RAND()*1024000),
(2,  RAND()*1024000, RAND()*1024000),
(4,  RAND()*1024000, RAND()*1024000),
(8,  RAND()*1024000, RAND()*1024000),
(16, RAND()*1024000, RAND()*1024000),
(32, RAND()*1024000, RAND()*1024000);
SELECT IF(ROW_COUNT() = 6, 'OK, INSERT 6 ROWS', CONCAT('NG, INSERT ', ROW_COUNT(), ' ROWS')) AS '4.2 check: INSERT_ROWS' FROM DUAL;
SELECT '                 ' FROM DUAL;

-- SECONDARY_LOAD
ALTER TABLE t_803227_rapid SECONDARY_LOAD;

SELECT IF(CREATE_OPTIONS = 'SECONDARY_ENGINE="rapid" SECONDARY_LOAD="1"', "OK, t_803227_rapid IS A Rapid TABLE", "NG, t_803227_rapid IS NOT A Rapid TABLE") AS '4.3 check: t_803227_rapid' FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'greatsql_803227' AND TABLE_NAME = 't_803227_rapid';
SELECT '                 ' FROM DUAL;

-- EXPLAIN
SELECT '4.4 check: EXPLAIN SELECT FROM Rapid TABLE' FROM DUAL;
EXPLAIN SELECT /*+ SET_VAR(use_secondary_engine=2) SET_VAR(secondary_engine_cost_threshold=0) */ * FROM t_803227_rapid;
SELECT '                 ' FROM DUAL;

-- FORCE USING Rapid ENGINE
SELECT /*+ SET_VAR(use_secondary_engine=1) SET_VAR(secondary_engine_cost_threshold=0) */ COUNT(*) INTO @ROWS FROM t_803227_rapid;
SELECT IF(@ROWS = 6, 'OK, FOUND 6 ROWS', CONCAT('NG, FOUND ', @ROWS, ' ROWS')) AS '4.4 check: FOUND ROWS FROM Rapid TABLE' FROM DUAL;
SELECT '                 ' FROM DUAL;


-- 5. 并行LOAD DATA
SELECT '--- 5. checking PARALLEL LOAD DATA ---' AS STAGE_5;
SELECT IF(VARIABLE_NAME = "gdb_parallel_load_workers", "OK, PARALLEL LOAD DATA", "NG, PARALLEL LOAD DATA") AS '5.1 check: PARALLEL LOAD DATA' FROM performance_schema.global_variables where variable_name = 'gdb_parallel_load_workers';
SELECT '                 ' FROM DUAL;

-- 支持无主键并发LOAD DATA优化
SELECT IF(VARIABLE_NAME = "innodb_optimize_no_pk_parallel_load", "OK, PARALLEL LOAD DATA OPTIMIZE WHEN NON-PK", "NG, PARALLEL LOAD DATA OPTIMIZE WHEN NON-PK") AS '5.2 check: PARALLEL LOAD DATA OPTIMIZE WHEN NON-PK' FROM performance_schema.global_variables where variable_name = 'innodb_optimize_no_pk_parallel_load';
SELECT '                 ' FROM DUAL;
SELECT '                 ' FROM DUAL;


-- 6. Clone功能
SELECT '--- 6. checking clone encrypt ---' AS STAGE_6;
INSTALL PLUGIN CLONE SONAME 'mysql_clone.so';
SELECT IF(PLUGIN_NAME = 'clone', 'OK, PLUGIN clone ACTIVE', 'NG, PLUGIN Clone NOT ACTIVE') AS 'check: Clone PLUGIN' FROM information_schema.PLUGINS WHERE PLUGIN_NAME = 'clone' AND PLUGIN_STATUS = "ACTIVE";
SELECT '                 ' FROM DUAL;

SELECT IF(VARIABLE_NAME = "clone_encrypt_key_path", "OK, SUPPORT Clone encrypt", "NG, NOT SUPPORT Clone encrypt") AS 'check: Clone encrypt' FROM performance_schema.global_variables where variable_name = 'clone_encrypt_key_path';
SELECT '                 ' FROM DUAL;

INSTALL COMPONENT "file://component_mysqlbackup";
SELECT IF(component_urn = 'file://component_mysqlbackup', "OK, SUPPORT Clone increment backup", "NG, NOT SUPPORT Clone increment backup") AS "check: Clone increment backup" FROM mysql.component WHERE component_urn = 'file://component_mysqlbackup';
SELECT '                 ' FROM DUAL;

SELECT IF(VARIABLE_NAME = "clone_file_compress", "OK, SUPPORT Clone compressed", "NG, NOT SUPPORT Clone compressed") AS 'check: Clone compressed' FROM performance_schema.global_variables where variable_name = 'clone_file_compress';
SELECT '                 ' FROM DUAL;
SELECT '                 ' FROM DUAL;

-- 7. MGR特性
SELECT '--- 7. checking MGR ---' AS STAGE_7;
-- SELECT 'INSTALL PLUGIN group_replication SONAME "group_replication.so"';
INSTALL PLUGIN group_replication SONAME "group_replication.so";
SET GLOBAL super_read_only = OFF;

-- zone id
SELECT IF(VARIABLE_NAME = "group_replication_zone_id", "OK, SUPPORT MGR zone_id", "NG, NOT SUPPORT MGR zone_id") AS '7.1 check: MGR zone_id' FROM performance_schema.global_variables where variable_name = 'group_replication_zone_id';
SELECT '                 ' FROM DUAL;

SELECT IF(VARIABLE_NAME = "group_replication_arbitrator", "OK, SUPPORT MGR arbitrator", "NG, NOT SUPPORT MGR arbitrator") AS '7.2 check: MGR arbitrator' FROM performance_schema.global_variables where variable_name = 'group_replication_arbitrator';
SELECT '                 ' FROM DUAL;

SELECT IF(VARIABLE_NAME = "group_replication_primary_election_mode", "OK, SUPPORT MGR elect_mode", "NG, NOT SUPPORT MGR elect_mode") AS '7.3 check: MGR elect_mode' FROM performance_schema.global_variables where variable_name = 'group_replication_primary_election_mode';
SELECT '                 ' FROM DUAL;

SELECT IF(VARIABLE_NAME = "group_replication_donor_threshold", "OK, SUPPORT MGR Donor threshold", "NG, NOT SUPPORT MGR Donor threshold") AS '7.4 check: MGR Donor threshold' FROM performance_schema.global_variables where variable_name = 'group_replication_donor_threshold';
SELECT '                 ' FROM DUAL;

-- SELECT '--- checking greatdb_ha ---';
-- SELECT 'INSTALL PLUGIN greatdb_ha SONAME "greatdb_ha.so"';
INSTALL PLUGIN greatdb_ha SONAME "greatdb_ha.so";
SELECT IF(VARIABLE_NAME = "greatdb_ha_enable_mgr_vip", "OK, SUPPORT greatdb_ha", "NG, NOT SUPPORT greatdb_ha") AS '7.4 check: greatdb_ha' FROM performance_schema.global_variables where variable_name = 'greatdb_ha_enable_mgr_vip';
SELECT '                 ' FROM DUAL;

SELECT IF(VARIABLE_NAME = "greatdb_ha_mgr_read_vip_floating_type", "OK, SUPPORT greatdb_ha vip_floating", "NG, NOT SUPPORT greatdb_ha vip_floating") AS '7.5 check: greatdb_ha vip_floating' FROM performance_schema.global_variables where variable_name = 'greatdb_ha_mgr_read_vip_floating_type';
SELECT '                 ' FROM DUAL;
SELECT '                 ' FROM DUAL;


-- 8. 安全特性检查
-- 支持审计日志写表 & 用户的登录信息记录
-- basedir=/usr, REPLACE IF NEEDED
SOURCE /usr/share/mysql/install_audit_log.sql;
SELECT IF(VARIABLE_NAME = "audit_log_to_table", "OK, SUPPORT audit_log_to_table", "NG, NOT SUPPORT audit_log_to_table") AS '8.1 check: audit_log_to_table' FROM performance_schema.global_variables where variable_name = 'audit_log_to_table';
SELECT '                 ' FROM DUAL;

SELECT IF(name = 'audit_login_messages', "OK, SUPPORT last login msg", "NG, NOT SUPPORT last login msg") AS '8.2 check: last login msg' FROM mysql.func WHERE name = 'audit_login_messages';
SELECT '                 ' FROM DUAL;

-- 支持基于策略的数据脱敏
-- basedir=/usr, REPLACE IF NEEDED
SOURCE /usr/share/mysql/sys_masking.sql;
SELECT IF(COUNT(*)=4, "OK, SUPPORT data masking", "NG, NOT SUPPORT data masking") AS '8.3 check: data masking' FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='sys_masking';
SELECT '                 ' FROM DUAL;
SELECT '                 ' FROM DUAL;


-- 9. 优化功能检查
-- 支持非阻塞式DDL
SELECT IF(VARIABLE_NAME = "lock_ddl_polling_mode", "OK, nonblocking DDL", "NG, NOT SUPPORT nonblocking DDL") AS '9.1 check: nonblocking DDL' FROM performance_schema.global_variables where variable_name = 'lock_ddl_polling_mode';
SELECT '                 ' FROM DUAL;

-- 支持NUMA亲和性优化
SELECT IF(VARIABLE_NAME = "sched_affinity_numa_aware", "OK, affinity_numa_aware", "NG, NOT SUPPORT affinity_numa_aware") AS '9.2 check: affinity_numa_aware' FROM performance_schema.global_variables where variable_name = 'sched_affinity_numa_aware';
SELECT '                 ' FROM DUAL;

-- 支持Binlog读取限速
SELECT IF(VARIABLE_NAME = "rpl_read_binlog_speed_limit", "OK, Binlog speed limit", "NG, NOT SUPPORT Binlog speed limit") AS 'check: Binlog speed limit' FROM performance_schema.global_variables where variable_name = 'rpl_read_binlog_speed_limit';
SELECT '                 ' FROM DUAL;

SELECT IF(VARIABLE_NAME = "Rpl_data_speed", "OK, Binlog speed limit status", "NG, NOT SUPPORT Binlog speed limit status") AS 'check: Binlog speed limit status' FROM performance_schema.global_status where variable_name = 'Rpl_data_speed';
SELECT '                 ' FROM DUAL;
SELECT '                 ' FROM DUAL;

-- 10. InnoDB Page压缩支持zstd
SELECT '--- 11. checking InnoDB Page COMPRSSION USING Zstd ---' AS STAGE_11;
USE greatsql_803227;

DROP TABLE IF EXISTS t_803227;
CREATE TABLE t_803227(
id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
c1 CLOB NOT NULL, 
c2 VARCHAR2(30) NOT NULL DEFAULT '',
c3 NUMBER UNSIGNED NOT NULL DEFAULT 0,
c4 PLS_INTEGER UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMPRESSION="zstd";
SELECT IF(CREATE_OPTIONS = 'COMPRESSION="zstd"', "OK, InnoDB Page COMPONENT USING Zstd", "NG, NOT SUPPORT InnoDB Page COMPONENT USING Zstd") AS 'check: InnoDB Page COMPONENT USING Zstd' FROM information_schema.TABLES WHERE TABLE_SCHEMA='greatsql_803227' AND TABLE_NAME='t_803227';
SELECT '                 ' FROM DUAL;
SELECT '                 ' FROM DUAL;

-- 11. 清理
SELECT '--- 8. clean up ---' AS STAGE_8;
DROP DATABASE IF EXISTS greatsql_803227;
