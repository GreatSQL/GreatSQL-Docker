# 8.4.4-5 更新日志

## 2026.10.15
* 根据代码审查报告修复若干P3问题：
* Dockerfile DEPS 增加 tzdata，确保容器内 /usr/share/zoneinfo 可用，mysql_tzinfo_to_sql 与时区环境变量生效（#10）
* greatsql-shrink.sh basedir 改为从 $GREATSQL_BASEDIR 读取（默认 /usr/local/GreatSQL），与 Dockerfile 解耦；补充删除 libmysqlclient.so.21* 的实测验证注释；rm 列表与 8.4.4-4 minimal 包对齐，移除已不存在的 Percona 遗留文件（#13）
* 根据代码审查报告修复若干P2问题：
* Dockerfile 将单层巨型 RUN 拆分为依赖安装 / 脚本下载 / 二进制解包三层，提高构建缓存命中率（#8）
* Dockerfile 增加 HEALTHCHECK（mysql 客户端探测）与 VOLUME /data/GreatSQL（#11）
* 运行时通过 setpriv 主动降权到 mysql 用户，避免 mysqld 以 root 运行（#11）
* docker-compose 移除已废弃的 version 字段，新增 healthcheck 并将 depends_on 升级为 service_healthy 健康依赖（#22）
* README 同步 compose 示例、修复 docker-compse 拼写错误
* 移除构建期对 /usr/share/misc 的整目录删除，改用 microdnf --nodocs 从源头不装文档

## 2026.07.01
* 更新到GreatSQL 8.4.4-5
* 修改相应的库名、表名
* 增加 **大事务 binlog 独立落盘** 功能检测
* 增加 **并行复制回放机制** 功能检测
* 增加 **执行计划变更异常捕获** 功能检测

[8.4.4-5]: https://gitee.com/GreatSQL/GreatSQL-Docker/tree/greatsql-8.4.4-5/GreatSQL
