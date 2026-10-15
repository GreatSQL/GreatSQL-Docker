# 8.4.4-4 更新日志

## 2026.10.15
* 根据代码审查报告修复P3问题：greatsqlsh-automake.sh 运行时动态库收集改用 readlink -f 解析真实文件名后按稳定目标名拷贝，不再硬编码 libssl.so.1.1.1k 等精确版本号，系统升级后不会因文件名变化而失效（#17）

## 2025.10.21
* 更新到8.4.4-4版本
* 支持仲裁节点
* 修改gcc依赖

[8.4.4-4]: https://gitee.com/GreatSQL/GreatSQL-Docker/tree/greatsql-8.4.4-4/GreatSQL-Shell-Build
