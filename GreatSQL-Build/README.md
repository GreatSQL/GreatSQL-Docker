# GreatSQL-Build Docker
---

## 简介

全自动编译GreatSQL源码，生成二进制包。

适用于 OracleLinux/CentOS x86_64/aarch64 环境，更多环境适配请自行修改Dockerfile及相关脚本中的参数。

**提示**：本项目将不再更新，如果有需要编译 GreatSQL 源码，请参考文档 [编译源码安装](https://greatsql.cn/docs/4-install-guide/6-install-with-source-code.html)。

## 基本信息
- 维护者: GreatSQL(greatsql@greatdb.com)
- 联系我们：greatsql@greatdb.com
- 最新版本：GreatSQL 8.4.4-4
- 最后更新时间：2025-10-16

## 支持哪些tag

- [latest](https://hub.docker.com/layers/greatsql/greatsql_build/latest/images/sha256-16c3b1f7336578e9ad96593d8e3b02de032ede456a5f4681f11cff538673bdd8)
- [8.0.32-27](https://hub.docker.com/layers/greatsql/greatsql_build/8.0.32-27/images/sha256-16c3b1f7336578e9ad96593d8e3b02de032ede456a5f4681f11cff538673bdd8)

拉取GreatSQL-Build镜像

```shell
docker pull greatsql/greatsql_build
```

还可以指定具体版本号

```shell
docker pull greatsql/greatsql_build:8.4.4-4
```

如果无法从hub.docker.com拉取，可以尝试从阿里云ACR或腾讯云TCR拉取，例如：

```shell
# 阿里云ACR
docker pull registry.cn-beijing.aliyuncs.com/greatsql/greatsql_build

# 腾讯云TCR
docker pull ccr.ccs.tencentyun.com/greatsql/greatsql_build
```

> 如果提示 timeout 连接超时错误，多重试几次应该就好了。

## GreatSQL Build Docker镜像构建

在开始前，需要先准备好一个Docker builx环境，这是为了支持多平台构建。

如果不需要支持多平台，则可以自行修改Dockerfile中的第10-11行，将原来的内容

```ini
 10 ARG TARGETARCH \
 11 OPT_DIR=/opt \
```

修改成下面这样

```ini
 10 ARG OPT_DIR=/opt \
```

也就是去掉`TARGETARCH`参数即可。

关于Docker buildx环境的配置，可以参考这篇文章：[使用 buildx 构建跨平台镜像](https://zhuanlan.zhihu.com/p/622399482) 或 [Multi-platform builds](https://docs.docker.com/build/building/multi-platform/)，这里不赘述。

```shell
docker buildx build --platform linux/arm64,linux/amd64 -t greatsql/greatsql_build . --push
```

上述命令会查找当前目录下的 `Dockerfile` 文件，并构建名为 `greatsql/greatsql_build` 的Docker镜像，并最终会push到`greatsql/greatsql_build`镜像仓库。这里需要修改成您自己的仓库名，例如改成我自己个人的：

```shell
docker buildx build --platform linux/arm64,linux/amd64 -t yejr/greatsql_build . --push
```

在构建镜像时，会自动从服务器上下载相应的源码包文件、初始化脚本等文件，并全自动化方式完成镜像构建工作。

如果无法从hub.docker.com拉取OracleLinux镜像，则修改`Dockerfile`文件的前几行，将镜像资源修改为阿里云或腾讯云：

```ini
  1 #FROM oraclelinux:8-slim as builder
  2 FROM registry.cn-beijing.aliyuncs.com/greatsql/oraclelinux:8-slim as builder
  3 #FROM ccr.ccs.tencentyun.com/greatsql/oraclelinux:8-slim as builder
```

## GreatSQL Build Docker镜像使用

```shell
# 创建新容器
docker run -itd --hostname greatsql_build --name greatsql_build greatsql/greatsql_build

# 进入容器，手动启动编译工作
docker exec -it greatsql_build sh
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
drwxrwxr-x 13 mysql mysql       293 Oct 11 11:54 GreatSQL-8.4.4-4-ol-glibc2.28-x86_64
/opt/GreatSQL-8.4.4-4-ol-glibc2.28-x86_64/bin/mysqld  Ver 8.4.4-4 for Linux on x86_64 (GreatSQL, Release 4, Revision d73de75905d)

5. remove files and clean up 
```

可以看到已经完成编译，可以将容器中编译好的二进制包文件拷贝到宿主机上，例如：

```shell
docker cp greatsql_build:/opt/GreatSQL-8.4.4-4-ol-glibc2.28-x86_64 /usr/local/
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
