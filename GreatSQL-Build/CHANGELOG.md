# 8.0.32-25 更新日志

## 2024.6.2
* 修复lscpu指令在部分OS下执行结果正则表达

## 2024.2.22
* 继续简化Dockerfile，使其构建更快。
* 把大部分实际工作放在自定义脚本里运行。
* 构建Docker镜像时只做基础工作。
* rpcgen安装改在 docker-entrypoint.sh 中，并判断x86/arm，不再在Dockerfile中处理

## 2024.2.20
* 版本更新到GreatSQL 8.0.32-25。
* 支持x86_64/aarch64。
* 支持从服务器上下载boost和rpcgen包。
* 支持从服务器上下载GreatSQL包。
* 支持全自动化编译GreatSQL源码。
* 编译完成后，清理不必要的文件目录。

[8.0.32-25]: https://gitee.com/GreatSQL/GreatSQL-Docker/tree/greatsql-8.0.32-25/GreatSQL-Build
