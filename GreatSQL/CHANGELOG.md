# 8.0.32-25 更新日志

## 2024.4.16
* 利用Docker buildx支持多平台构建，不再需要用tag标识区分不同平台。

## 2024.3.20
### 新功能
* 增加参数MAXPERF，用于设置为最大性能模式（默认）；在最大性能模式下，会调大innodb_buffer_pool_size/rapid_memory_limit等多个选项，详见脚本`greatsql-init.sh`中对MAXPERF模式的处理逻辑。

## 2024.2.20
### 新功能
* 改造GreatSQL Docker镜像构造方法，全部从服务器上下载文件，无需从本地拷贝文件。
* 优化Dockerfile，合并x86_64和aarch64。
* 增加Rapid引擎功能测试。

### 其他更新
* 修复测试脚本中的转义字符。
* 将docker-compose挪到本目录下。

## 2024.1.19

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

[8.0.32-25]: https://gitee.com/GreatSQL/GreatSQL-Docker/tree/greatsql-8.0.32-25/GreatSQL
