# GreatSQL Build Docker镜像
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

1. compile patchelf
2. entering greatsql automake
3. greatsql automake completed
drwxrwxr-x 13 mysql mysql       293 Feb 18 08:29 GreatSQL-8.0.32-25-centos-glibc2.28-x86_64
/opt/GreatSQL-8.0.32-25-centos-glibc2.28-x86_64/bin/mysqld  Ver 8.0.32-25 for Linux on x86_64 (GreatSQL, Release 25, Revision 79f57097e3f)
4. entering /bin/bash
```

可以看到已经完成编译，如果需要的话，可以将Docker容器中的二进制包文件拷贝到宿主机上，例如：
```shell
$ docker cp greatsql_build:/opt/GreatSQL-8.0.32-25-centos-glibc2.28-x86_64 /usr/local/
```

如果宿主机环境也是CentOS 8 x86_64的话，这就可以在宿主机环境下直接使用该二进制文件包了。
