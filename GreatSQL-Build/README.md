# GreatSQL-Build Docker
---

全自动编译GreatSQL源码，生成二进制包。

适用于CentOS 8 x86_64/aarch64 环境，更多环境适配请自行修改Dockerfile及相关脚本中的参数。

## 1. GreatSQL Build Docker镜像构建

```shell
$ docker build -t greatsql/greatsql_build .
```
上述命令会查找当前目录下的 `Dockerfile` 文件，并构建名为 `greatsql/greatsql_build` 的Docker镜像。

在构建镜像时，会自动从服务器上下载相应的源码包文件、初始化脚本等文件，并全自动化方式完成镜像构建工作。

## 2. GreatSQL Build Docker镜像使用

```shell
# 创建新容器
$ docker run -itd --hostname greatsql_build --name greatsql_build greatsql/greatsql_build bash

# 查看自动编译进展
$ docker logs greatsql_build

0. touch logfile /tmp/greatsqlsh-automake.log

1. downloading sourcecode tarballs and extract
 1.1 downloading sourcecode tarballs ...
 1.2 extract tarballs ...

2. compiling antlr4

3. compiling patchelf

4. compiling protobuf

5. compiling MySQL Shell for GreatSQL
 5.1 compiling mysqlclient and mysqlxclient
 5.2 compiling MySQL Shell for GreatSQL

6. MySQL Shell for GreatSQL 8.0.32-25 build completed!
 6.1 MySQL Shell for GreatSQL 8.0.32-25 version:
/opt/greatsql-shell-8.0.32-25-centos-glibc2.28-x86_64/bin/mysqlsh   Ver 8.0.32 for Linux on x86_64 - for MySQL 8.0.32 (Source distribution)
 6.2 TARBALL file:
-rw-r--r-- 1 root root 19956168 Feb 21 02:56 /opt/greatsql-shell-8.0.32-25-centos-glibc2.28-x86_64.tar.xz
```

可以看到已经完成编译，如果需要的话，可以将Docker容器中的二进制包文件拷贝到宿主机上，例如：
```shell
$ docker cp greatsql_build:/opt/GreatSQL-8.0.32-25-centos-glibc2.28-x86_64 /usr/local/
```

如果宿主机环境也是CentOS 8 x86_64的话，这就可以在宿主机环境下直接使用该二进制文件包了。

## 文件介绍
- CHANGELOG.md，更新历史
- docker-entrypoint.sh，镜像初始化脚本，该脚本中再调用greatsql-automake.sh实现自动编译。
- Dockerfile，用于构建GreatSQL编译环境
- greatsql-automake.sh，GreatSQL自动编译脚本
- greatsql-setenv.sh，通用环境变量设置脚本

## 联系我们
扫码关注微信公众号

![GreatSQL社区微信公众号二维码](https://images.gitee.com/uploads/images/2021/0802/143402_f9d6cb61_8779455.jpeg "greatsql社区-wx-qrcode-0.5m.jpg")
