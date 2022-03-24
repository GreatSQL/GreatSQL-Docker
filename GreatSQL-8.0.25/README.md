
## 关于裁剪说明
为了让Docker镜像尽可能精简，GreatSQL在制作过程中将mysql router裁剪掉了，以及一些用不上的so文件。

下面是被裁剪文件的详细列表，如果不想要精简版本，可根据本项目提供的Dockerfile自行制作镜像文件。
```
#裁剪bin目录
$ cd bin
$ rm -fr comp_err ibd2sdi innochecksum ldb lz4_decompress myisamchk myisam_ftdump myisamlog myisampack \
 mysqlcheck mysql_client_test mysqld_multi mysqld_safe mysqldumpslow mysqlimport mysql_keyring_encryption_test \
 mysql_ldb mysql_migrate_keyring mysqlrouter mysqlrouter_keyring mysqlrouter_passwd mysqlrouter_plugin_info \
 mysql_secure_installation mysqlslap mysqltest mysqltest_safe_process mysql_upgrade mysqlxtest ps-admin \
 ps_mysqld_helper sst_dump zlib_decompress

#裁剪lib目录
$ cd lib
$ rm -f libHotBackup.so libmysqlservices.a libperconaserverclient.* libcoredumper.a libnspr4.so \
 private/libnspr4.so libnss3.so private/libnss3.so libnssutil3.so private/libnssutil3.so libplc4.so \
 private/libplc4.so libplds4.so private/libplds4.so libsmime3.so private/libsmime3.so libssl3.so private/libssl3.so

$ rm -fr mysqlrouter/ mecab/
$ cd cd plugin
$ rm -fr debug/
$ rm -fr auth_pam_compat.so auth_pam.so component_keyring_file.so component_mysqlx_global_reset.so \
 component_pfs_example_component_population.so component_pfs_example.so component_test_backup_lock_service.so \
 component_test_mysql_current_thread_reader.so component_test_mysql_runtime_error.so \
 component_test_pfs_notification.so component_test_pfs_resource_group.so \
 component_test_status_var_service_int.so component_test_status_var_service_reg_only.so \
 component_test_status_var_service.so component_test_status_var_service_str.so \
 component_test_status_var_service_unreg_only.so component_test_string_service_charset.so \
 component_test_string_service_long.so component_test_string_service.so \
 component_test_system_variable_source.so component_test_sys_var_service_int.so \
 component_test_sys_var_service_same.so component_test_sys_var_service.so \
 component_test_sys_var_service_str.so component_test_udf_registration.so \
 component_udf_reg_3_func.so component_udf_reg_avg_func.so component_udf_reg_int_func.so \
 component_udf_reg_int_same_func.so component_udf_reg_only_3_func.so component_udf_reg_real_func.so \
 component_udf_unreg_3_func.so component_udf_unreg_int_func.so component_udf_unreg_real_func.so \
 daemon_example.ini dialog.so ha_rocksdb.so innodb_engine.so libdaemon_example.so libmemcached.so \
 libpluginmecab.so libtest_framework.so libtest_services.so libtest_services_threaded.so \
 libtest_session_attach.so libtest_session_detach.so libtest_session_info.so libtest_session_in_thd.so \
 libtest_sql_2_sessions.so libtest_sql_all_col_types.so libtest_sql_cmds_1.so libtest_sql_commit.so \
 libtest_sql_complex.so libtest_sql_errors.so libtest_sql_lock.so libtest_sql_processlist.so \
 libtest_sql_replication.so libtest_sql_reset_connection.so libtest_sql_shutdown.so \
 libtest_sql_sleep_is_connected.so libtest_sql_sqlmode.so libtest_sql_stmt.so \
 libtest_sql_stored_procedures_functions.so libtest_sql_views_triggers.so \
 libtest_x_sessions_deinit.so libtest_x_sessions_init.so pfs_example_plugin_employee.so \
 procfs.so qa_auth_client.so qa_auth_interface.so qa_auth_server.so \
 replication_observers_example_plugin.so test_security_context.so test_services_plugin_registry.so \
 test_udf_services.so tokudb_backup.so udf_example.so
```
