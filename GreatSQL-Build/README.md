# GreatSQL-Build Docker
---

## 简介

全自动编译GreatSQL源码，生成二进制包。

适用于 OracleLinux/CentOS x86_64/aarch64 环境，更多环境适配请自行修改Dockerfile及相关脚本中的参数。

## 基本信息
- 维护者: GreatSQL(greatsql@greatdb.com)
- 联系我们：greatsql@greatdb.com
- 最新版本：GreatSQL 8.0.32-26
- 最后更新时间：2024-08-19

## 支持哪些tag

- [latest](https://hub.docker.com/layers/greatsql/greatsql_build/latest/images/sha256-a8bea01ea86b77866f8e4739859537b6f4b5060178ae06552e6fad4607c4e0cf)
- [8.0.32-26](https://hub.docker.com/layers/greatsql/greatsql_build/8.0.32-26/images/sha256-a8bea01ea86b77866f8e4739859537b6f4b5060178ae06552e6fad4607c4e0cf)
- [8.0.32-25](https://hub.docker.com/layers/greatsql/greatsql/8.0.32-25/images/sha256-6a01d0b1b9107b286601249202803da5b08e9f729b8727f691ce423928994eef)

如果无法从 hub.docker.com 拉取，可以尝试从阿里云 ACR 或腾讯云 TCR 拉取，例如：

```shell
$ docker pull registry.cn-beijing.aliyuncs.com/greatsql/greatsql_build
$ docker pull registry.cn-beijing.aliyuncs.com/greatsql/greatsql_build:8.0.32-26

$ docker pull ccr.ccs.tencentyun.com/greatsql/greatsql_build
$ docker pull ccr.ccs.tencentyun.com/greatsql/greatsql_build:8.0.32-26
```

> 如果提示 timeout 连接超时错误，多重试几次应该就好了。

## GreatSQL Build Docker镜像构建

```shell
$ docker build -t greatsql/greatsql_build .
```
上述命令会查找当前目录下的 `Dockerfile` 文件，并构建名为 `greatsql/greatsql_build` 的Docker镜像。

在构建镜像时，会自动从服务器上下载相应的源码包文件、初始化脚本等文件，并全自动化方式完成镜像构建工作。

如果无法从 hub.docker.com 拉取 oraclelinux 镜像，则修改 `Dockerfile` 文件的前几行，将镜像资源修改为阿里云或腾讯云：

```ini
  1 #FROM oraclelinux:8-slim as builder
  2 FROM registry.cn-beijing.aliyuncs.com/greatsql/oraclelinux:8-slim as builder
  3 #FROM ccr.ccs.tencentyun.com/greatsql/oraclelinux:8-slim as builder
```

## GreatSQL Build Docker镜像使用

```shell
# 创建新容器
$ docker run -itd --hostname greatsql_build --name greatsql_build greatsql/greatsql_build

# 进入容器，手动启动编译工作
$ docker exec -it greatsql_build sh
sh-4.4# pwd
/
sh-4.4#
sh-4.4# ls
bin  boot  dev  etc  greatsql_build_init.sh  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var

sh-4.4# sh ./greatsql_build_init.sh

0. GreatSQL-Build INIT

1. downloading sourcecode tarballs and extract
 1.1 downloading sourcecode tarballs ...
...
3. compile GreatSQL
 3.1 compiling GreatSQL
 3.2 remove mysql-test from GreatSQL
 3.3 make dynamic link for GreatSQL

4. greatsql build completed!
drwxrwxr-x 13 mysql mysql       293 Aug 16 08:27 GreatSQL-8.0.32-26-ol-glibc2.28-x86_64
/opt/GreatSQL-8.0.32-26-ol-glibc2.28-x86_64/bin/mysqld  Ver 8.0.32-26 for Linux on x86_64 (GreatSQL, Release 26, Revision a68b3034c3d)

5. remove files and clean up 
```

可以看到已经完成编译，可以将容器中编译好的二进制包文件拷贝到宿主机上，例如：
```shell
$ docker cp greatsql_build:/opt/GreatSQL-8.0.32-26-ol-glibc2.28-x86_64 /usr/local/
```

如果宿主机环境也是 OracleLinux/CentOS x86_64 的话，这就可以在宿主机环境下直接使用该二进制文件包了。

> 编译过程中，可能会遇到网络问题（DNS解析失败、网络连接超时等）导致失败的话，多重试几次即可。

## 文件介绍
- CHANGELOG.md，更新历史
- Dockerfile，用于构建初始化 GreatSQL 编译环境。
- greatsql-automake.sh，GreatSQL自动编译脚本，编译过程中产生的日志默认输出到 /tmp/greatsql-automake.log 中。
- greatsql-setenv.sh，通用环境变量设置脚本
- greatsql_build_init.sh，GreatSQL 编译调度入口脚本，该脚本中完成编译环境所需的软件包安装，并调用 greatsql-automake.sh 实现自动编译。

## 联系我们
扫码关注微信公众号

![GreatSQL社区微信公众号二维码](https://images.gitee.com/uploads/images/2021/0802/143402_f9d6cb61_8779455.jpeg "greatsql社区-wx-qrcode-0.5m.jpg")
