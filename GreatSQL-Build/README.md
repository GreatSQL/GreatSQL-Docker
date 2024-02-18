# GreatSQL-Build
---

全自动编译GreatSQL源码，生成二进制包。

适用于CentOS 8 x86_64 环境，更多环境适配请自行修改Dockerfile及相关脚本中的参数。

使用方法：
```shell
# 创建新容器
$ docker run -itd --hostname greatsql --name greatsql greatsql/greatsql_build bash

# 查看自动编译进展
$ docker logs greatsql

1. compile patchelf
2. entering greatsql automake
3. greatsql automake completed
drwxrwxr-x 13 mysql mysql       293 Feb 18 08:29 GreatSQL-8.0.32-25-centos-glibc2.28-x86_64
/opt/GreatSQL-8.0.32-25-centos-glibc2.28-x86_64/bin/mysqld  Ver 8.0.32-25 for Linux on x86_64 (GreatSQL, Release 25, Revision 79f57097e3f)
4. entering /bin/bash
```

可以看到已经完成编译，如果需要的话，可以将Docker容器中的二进制包文件拷贝到宿主机上，例如：
```shell
$ docker cp greatsql:/opt/GreatSQL-8.0.32-25-centos-glibc2.28-x86_64 /usr/local/
```

如果宿主机环境也是CentOS 8 x86_64的话，这就可以在宿主机环境下直接使用该二进制文件包了。
