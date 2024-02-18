# GreatSQL Docker镜像
---

本项目用于构建GreatSQL Docker镜像。

适用于CentOS 8 x86_64/aarch64 环境，更多环境适配请自行修改Dockerfile及相关脚本中的参数。

## 1. GreatSQL Docker镜像构建

```shell
$ docker build -t greatsql/greatsql .
```
上述命令会查找当前目录下的 `Dockerfile` 文件，并构建名为 `greatsql/greatsql` 的Docker镜像。

如果想要自定义Dockerfile文件路径，例如想要在aarch64平台下构建Docker镜像，可以采用类似下面的方法：
```shell
$ docker build -t greatsql/greatsql:aarch -f ./Dockerfile-aarch64 .
```
在构建镜像时，会自动从服务器上下载相应的GreatSQL RPM包文件、初始化脚本完成初始化工作，并全自动化方式完成镜像构建工作。

## 2. GreatSQL Docker镜像使用

```shell
# 创建新容器
$ docker run -itd --hostname greatsql --name greatsql greatsql/greatsql

# 查看容器中GreatSQL初始化进展
$ docker logs greatsql
[Note] You specify none of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD
GreatSQL create root@localhost with **EMPTY PASSWORD**
Initializing database
Database initialized
MySQL init process in progress...
MySQL init process in progress...
MySQL init process in progress...
mysql: [Warning] Using a password on the command line interface can be insecure.
Warning: Unable to load '/usr/share/zoneinfo/iso3166.tab' as time zone. Skipping it.
Warning: Unable to load '/usr/share/zoneinfo/leapseconds' as time zone. Skipping it.
Warning: Unable to load '/usr/share/zoneinfo/tzdata.zi' as time zone. Skipping it.
Warning: Unable to load '/usr/share/zoneinfo/zone.tab' as time zone. Skipping it.
Warning: Unable to load '/usr/share/zoneinfo/zone1970.tab' as time zone. Skipping it.
mysql: [Warning] Using a password on the command line interface can be insecure.

/docker-entrypoint.sh: ignoring /docker-entrypoint-initdb.d/*


MySQL init process done. Ready for start up.
```

这就可以正常使用GreatSQL Docker镜像了。
