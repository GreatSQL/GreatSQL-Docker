# 更新日志

## 8.0.32-25(2024.1.19)

### 新功能

* 版本更新到GreatSQL 8.0.32-25。
* 支持表名大小写自定义选项。
* 新增greatsql-test.sql自测试脚本。
* 支持挂载外部my.cnf文件，[ISSUE#I8VFGR](https://gitee.com/GreatSQL/GreatSQL-Docker/issues/I8VFGR)。
* 新增group_replication_recovery_get_public_key = 1设置，避免在caching_sha2_password plugin模式下MGR通信异常。
* 初始化完毕后执行update更新；改用RPM包来构建；合并EVN及其他操作减少镜像层数；对应[ISSUE#I8WSOQ](https://gitee.com/GreatSQL/GreatSQL-Docker/issues/I8VFGR)。

### 其他更新

* 修复一个不太友好的报错提醒。
* 修改客户端prompt，最后加一个空格，更美观。

[8.0.32-25]: https://gitee.com/GreatSQL/GreatSQL-Docker/tree/greatsql-8.0.32-25/
