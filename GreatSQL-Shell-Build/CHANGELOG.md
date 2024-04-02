# 8.0.32-25 更新日志

## 2024.4.2
* 将更多依赖动态库文件CP到发行包中，方便在其他平台直接运行。
* 发行包中去掉OS标识。

## 2024.3.12
* 增加V8(JS语法)支持。
* 优化Dockerfile，只进行基础镜像构建，依赖包安装、yum update等工作放在外部脚本中完成。

## 2024.2.20
* 优化GreatSQL-Shell-Build，改用从服务器上下载，无需准备本地二进制文件包。

## 2024.1.22

* 版本更新到GreatSQL 8.0.32-25。
* 支持从hub.docker.com中拉取镜像并自动完成编译工作。
* 也支持调用本地脚本完成自动创建GreatSQL Shell编译环境Docker镜像，并自动创建GreatSQL Shell自动编译Docker容器，一条命令即可完成全部编译工作。
* 编译后的二进制包用xz压缩，压缩比更高，在xz压缩时采用并行方式，降低压缩耗时。

[8.0.32-25]: https://gitee.com/GreatSQL/GreatSQL-Docker/tree/greatsql-8.0.32-25/GreatSQL-Shell-Build
