# 8.0.32-26 更新日志

## 2024.12
* 基础镜像改为Oracle Linux 9-sim，以适配更多硬件平台（如海光3000型号）
* GreatSQL安装包调整为minimal二进制包，不再采用RPM包以适配Oracle Linux 9-sim系统
* 保留mysqldump、mysqlbinlog、mysqldecompress等客户端工具
* 修复MAXPERF逻辑判断问题，修复CPU核数判断逻辑

## 2024.8
* 当MAXPERF值不为1时不额外输出，避免造成误解/困惑
* 增加时区参数（`TZ`）说明建议。
* 修改MAXPERF默认值（不再默认为1）
* 裁剪更多文件
* 将基础镜像修改为Oracle Linux 8-sim，缩减镜像尺寸
* 增加腾讯云TCR容器资源
* 客户端prompt微调，增加空格
* 修复初始化不当导致某些连接无法获取账户名的问题, issue: https://greatsql.cn/thread-840-1-1.html
* 默认关闭NUMA

## 2024.7.30
* 更新到GreatSQL 8.0.32-26
* 独立出 group_replication_single_primary_fast_mode 变量名
* 独立出 group_replication_enforce_update_everywhere_checks 变量名
* 增加从阿里云ACR拉取说明
* 对照GreatSQL 8.0.32-26的my.cnf模板，更新my.cnf配置，增加相应参数变量
* 规范化my.cnf配置中的参数值

[8.0.32-26]: https://gitee.com/GreatSQL/GreatSQL-Docker/tree/greatsql-8.0.32-26/GreatSQL
