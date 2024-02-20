# GreatSQL-Shell-Build Docker
---
## 简介

本项目用于构建MySQL Shell for GreatSQL编译环境Docker镜像。

适用于CentOS 8 x86_64/aarch64 环境，更多环境适配请自行修改Dockerfile及相关脚本中的参数。

## 基本信息
- 维护者: GreatSQL(greatsql@greatdb.com)
- 联系我们: greatsql@greatdb.com
- 最新版本：GreatSQL 8.0.32-25
- 最后更新时间：2024-02-20
- 支持CPU架构：x86_64、aarch64

## 支持哪些tag
- [latest](https://hub.docker.com/layers/greatsql/greatsql_shell_build/latest/images/sha256-4a658457738231651010bdf9026164e38b4b455496f3d13a32dcac8f1b8e2b93?context=repo), [8.0.32-25](https://hub.docker.com/layers/greatsql/greatsql_shell_build/8.0.32-25/images/sha256-4a658457738231651010bdf9026164e38b4b455496f3d13a32dcac8f1b8e2b93?context=repo)
- [latest-arch64](https://hub.docker.com/layers/greatsql/greatsql_shell_build/latest-aarch64/images/sha256-46826329b1f0a6f201ddc30a47bfb9724afd724b116d7a4323d3db21d9ea46e0?context=repo), [8.0.32-25-aarch64](https://hub.docker.com/layers/greatsql/greatsql_shell_build/8.0.32-25-aarch64/images/sha256-46826329b1f0a6f201ddc30a47bfb9724afd724b116d7a4323d3db21d9ea46e0?context=repo)

## 如何使用GreatSQL-Shell-Build

例如：
```shell
$ docker run -itd --hostname greatsqlsh --name greatsqlsh greatsql/greatsql_shell_build:8.0.32-25 bash
```
执行上述命令后，会创建一个GreatSQL-Shell编译环境容器，在容器中会自动进行GreatSQL-Shell编译工作。

在编译过程中，可以执行下面命令查看进度：
```shell
$ docker logs greatsqlsh | tail
```

如果看到类似下面的结果，就表明二进制包已编译完成
```shell
$ docker logs greatsqlsh | tail
1. extracting tarballs
2. compiling antlr4
3. compiling patchelf
4. compiling rpcsvc-proto
5. compiling protobuf
6. compiling greatsql shell
/opt/greatsql-shell-8.0.32-25-centos-glibc2.28-x86_64/bin/mysqlsh   Ver 8.0.32 for Linux on x86_64 - for MySQL 8.0.32 (Source distribution)
7. MySQL Shell 8.0.32-25 for GreatSQL build completed! TARBALL is:
-rw-r--r-- 1 root root 20343832 Jan 20 21:41 greatsql-shell-8.0.32-25-centos-glibc2.28-x86_64.tar.xz
```

接下来回退到宿主机，将容器中的二进制包拷贝出来

```shell
$ docker cp greatsqlsh:/opt/greatsql-shell-8.0.32-25-centos-glibc2.28-x86_64.tar.xz /usr/local/
```

然后解压缩，就可以在宿主机环境下使用了，例如：
```shell
$ /usr/local/greatsql-shell-8.0.32-25-centos-glibc2.28-x86_64/bin/mysqlsh
MySQL Shell 8.0.32
...
Type '\help' or '\?' for help; '\quit' to exit.
 MySQL  Py > \q
Bye!
```

**提醒**：如果是在aarch64环境中，则修改Dockerfile的前几行，改成适用于aarch64的镜像，例如

```shell
#for x86_64
#FROM centos:8

#for aarch64
FROM docker.io/arm64v8/centos
```

然后执行上面创建容器的命令即可。

## 编译GreatSQL Shell

如果您想自行手动编译GreatSQL Shell，详情可参考文档：[MySQL Shell 8.0.32 for GreatSQL编译二进制包](https://mp.weixin.qq.com/s/_nDIcNeTOGY4mdiUPUgj1A)。或者参考下面的简易过程说明：

1. 在Dockerfile中有个`COPY greatsql_shell_docker_build.tar /opt`的动作，需要自行打包 **greatsql_shell_docker_build.tar** 文件包，主要由一下几个文件组成：

- [antlr4-4.10.0.tar.gz](https://github.com/antlr/antlr4/archive/refs/tags/4.10.tar.gz)
- [boost_1_77_0.tar.gz](https://boostorg.jfrog.io/artifactory/main/release/1.77.0/source/boost_1_77_0.tar.gz)
- [mysql-8.0.32.tar.gz](https://downloads.mysql.com/archives/get/p/23/file/mysql-8.0.32.tar.gz)
- [mysql-shell-8.0.32-src.tar.gz](https://downloads.mysql.com/archives/get/p/43/file/mysql-shell-8.0.32-src.tar.gz)
- mysqlsh-for-greatsql-8.0.32.patch, 见本目录
- [patchelf-0.14.5.tar.gz](https://github.com/NixOS/patchelf/releases/download/0.14.5/patchelf-0.14.5.tar.gz)
- [protobuf-all-3.19.4.tar.gz](https://github.com/protocolbuffers/protobuf/releases/download/v3.19.4/protobuf-all-3.19.4.tar.gz)
- [rpcsvc-proto-1.4.tar.gz](https://github.com/thkukuk/rpcsvc-proto/releases/download/v1.4/rpcsvc-proto-1.4.tar.gz)

其中，几个在github上的文件需要科学上网才能下载。此外，在文档 **[MySQL Shell 8.0.32 for GreatSQL编译二进制包](https://mp.weixin.qq.com/s/_nDIcNeTOGY4mdiUPUgj1A)** 中有提到，antlr4源码包中的`runtime/Cpp/runtime/CMakeLists.txt`文件第一行要注释掉并重新打包，否则编译时要去github上下载文件，会导致编译失败。

2. 上述 **greatsql_shell_docker_build.tar** 文件包准备好后，按照下面步骤开始编译工作。


- 1. 略过Docker的安装过程，直接调用 `greatsql-shell-docker-build.sh` 脚本开始自动编译工作。

- 2. 调用脚本时的第一个参数用于自定义CPU架构，目前支持 **x86_64**、**aarch64** 两种，若参数值为 **aarch64** 之外的任何值，都会被当做 **x86_64** 处理。

- 3. 脚本 `greatsql-shell-docker-build.sh` 会开始自动构建 **greatsql_shell_build** 镜像。

- 4. 在构建完 **greatsql_shell_docker_build** 镜像后，还会自动创建新容器完成编译。

- 5. 编译结束后会输出编译结果，并将编译得到的二进制包拷贝到当前目录下。

```shell
$ sh ./greatsql-shell-docker-build.sh ./greatsql_shell_docker_build.tar

1. Docker images **greatsql_shell_build** build start
Sending build context to Docker daemon  2.469GB
...
Docker build success!
...

2. Creating docker container to buile GreatSQL Shell
...
GreatSQL Shell on builing ...
...

3. Copy GreatSQL-Shell TARBALL to the current directory
...
-rw-r--r-- 1 root root 20346808 Jan 22 13:28 greatsql-shell-8.0.32-25-centos-glibc2.28-x86_64.tar.xz
```
然后解压缩，就可以在宿主机环境下使用GreatSQL Shell了。

**注意**：采用本方法构建的GreatSQL Shell是适用于CentOS 8(glibc 2.28)环境下运行的，宿主环境如果是其他操作系统（或glibc版本不一致）可能无法正常运行。

## 文件介绍
- CHANGELOG.md，更新历史
- Dockerfile，用于构建Docker编译环境
- greatsql-shell-build.sh，用于实现在Docker容器中自动化编译的脚本
- greatsql-shell-docker-build.sh，用于自动构建Docker编译环境并自动编译GreatSQL-Shell的脚本
- mysqlsh-for-greatsql-8.0.32.patch，需要对MySQL Shell打补丁，才能支持GreatSQL中特有的仲裁节点特性

## 联系我们
扫码关注微信公众号

![GreatSQL社区微信公众号二维码](https://images.gitee.com/uploads/images/2021/0802/143402_f9d6cb61_8779455.jpeg "greatsql社区-wx-qrcode-0.5m.jpg")
