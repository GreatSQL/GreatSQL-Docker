# GreatSQL-Shell-Build Docker
---
## 简介

本项目用于构建MySQL Shell for GreatSQL编译环境Docker镜像。

适用于CentOS 8 x86_64/aarch64 环境，更多环境适配请自行修改Dockerfile及相关脚本中的参数。

## 基本信息
- 维护者: GreatSQL(greatsql@greatdb.com)
- 联系我们: greatsql@greatdb.com
- 最新版本：GreatSQL 8.0.32-25
- 最后更新时间：2024-03-12
- 支持CPU架构：x86_64、aarch64

## 支持哪些tag
- [latest](https://hub.docker.com/layers/greatsql/greatsql_shell_build/latest/images/sha256-4a658457738231651010bdf9026164e38b4b455496f3d13a32dcac8f1b8e2b93?context=repo), [8.0.32-25](https://hub.docker.com/layers/greatsql/greatsql_shell_build/8.0.32-25/images/sha256-4a658457738231651010bdf9026164e38b4b455496f3d13a32dcac8f1b8e2b93?context=repo)
- [latest-arch64](https://hub.docker.com/layers/greatsql/greatsql_shell_build/latest-aarch64/images/sha256-46826329b1f0a6f201ddc30a47bfb9724afd724b116d7a4323d3db21d9ea46e0?context=repo), [8.0.32-25-aarch64](https://hub.docker.com/layers/greatsql/greatsql_shell_build/8.0.32-25-aarch64/images/sha256-46826329b1f0a6f201ddc30a47bfb9724afd724b116d7a4323d3db21d9ea46e0?context=repo)

## 如何使用GreatSQL-Shell-Build

例如：
```shell
$ docker run -itd --hostname greatsqlsh --name greatsqlsh greatsql/greatsql_shell_build:8.0.32-25 bash
```
执行上述命令后，会创建一个GreatSQL-Shell编译环境容器，并在容器中自动完成GreatSQL-Shell编译工作。

在编译过程中，可以执行下面命令查看进度：
```shell
$ docker logs greatsqlsh | tail
```

如果看到类似下面的结果，就表明二进制包已编译完成
```shell
$ docker logs greatsqlsh | tail
0. init GreatSQL-Shell-Build env
0.1 touch logfile /tmp/greatsqlsh-automake.log
0.2 install all DEPS(autoconf, gcc ...)
0.3 download yum-repos.tar.xz and v8-libs-aarch64.tar.xz
0.4 install yum-repos and v8-libs-aarch64

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
-rw-r--r-- 1 root root 20378992 Mar 12 10:33 /opt/greatsql-shell-8.0.32-25-centos-glibc2.28-x86_64.tar.xz
```

接下来回退到宿主机，将容器中的二进制包拷贝出来

```shell
$ docker cp greatsqlsh:/opt/greatsql-shell-8.0.32-25-centos-glibc2.28-x86_64.tar.xz /usr/local/
```

然后解压缩，就可以在宿主机环境下使用了，例如：
```shell
# 先安装几个必要的依赖包
$ dnf install -y libssh python38 python38-libs python38-pyyaml
$ pip3.8 install --user certifi pyclamd

# 测试使用
$ /usr/local/greatsql-shell-8.0.32-25-centos-glibc2.28-x86_64/bin/mysqlsh
MySQL Shell 8.0.32
...
Type '\help' or '\?' for help; '\quit' to exit.
 MySQL  JS > \q
Bye!
```

## 文件介绍
- CHANGELOG.md，更新历史
- docker-entrypoint.sh，GreatSQL-Shell Docker镜像初始化脚本，处理源码包下载等准备工作
- Dockerfile，用于构建Docker编译环境
- greatsqlsh-automake.sh，用于实现在Docker容器中自动化编译的脚本
- greatsqlsh-setenv.sh，通用环境变量设置脚本
- mysqlsh-for-greatsql-8.0.32.patch，需要对MySQL Shell打补丁，才能支持GreatSQL中特有的仲裁节点特性

## 其他分支
- 如果您想尝试支持Python 3.10版本的GreatSQL Shell，可参考 [earl86](https://gitee.com/earl86) 维护的[GreatSQL-Shell-Build分支](https://gitee.com/earl86/GreatSQL-Docker/tree/master/GreatSQL-Shell-Build)。
- 如果您想尝试在Rocky Linux中编译GreatSQL Shell，可参考 [xiongyu](https://gitee.com/xiongyu-net) 维护的[GreatSQL-Shell-Build分支](https://gitee.com/xiongyu-net/GreatSQL-Docker/tree/master/GreatSQL-Shell-Build)。

感谢以上二位commiter的贡献，由于无法适配ARM环境，因此主分支未合并，大家可根据个人喜好自行选择。

## 联系我们
扫码关注微信公众号

![GreatSQL社区微信公众号二维码](https://images.gitee.com/uploads/images/2021/0802/143402_f9d6cb61_8779455.jpeg "greatsql社区-wx-qrcode-0.5m.jpg")
