# GreatSQL-Docker

---

## 介绍
GreatSQL软件相关Docker镜像集。

Dockerfiles可用于自定义和构建docker映像。[戳此阅读更多关于Dockerfiles的文档](https://docs.docker.com/engine/reference/builder/)。

如何构建和运行GreatSQL软件，请参阅各个目录。

我们非常欢迎和鼓励社区用户提出改进建议或贡献代码、想法，以及其他任何可以帮助改进项目的做法。

如果您发现任何GreatSQL-Docker项目相关的问题、bug，都可以[戳此提交issue](https://gitee.com/GreatSQL/GreatSQL-Docker/issues)，我们将尽快处理。


## 快速使用
- 维护者: GreatSQL(greatsql@greatdb.com)
- 联系人: greatsql@greatdb.com

## 支持哪些tag
- [8.0.25](https://hub.docker.com/layers/158734159/greatsql/greatsql/8.0.25/images/sha256-d9e0f455e3412127ed59ecc5f69b36a717303ff868cac128fe4d8a0ad6545a4a?context=repo), [latest](https://hub.docker.com/layers/156877878/greatsql/greatsql/latest/images/sha256-d9e0f455e3412127ed59ecc5f69b36a717303ff868cac128fe4d8a0ad6545a4a?context=repo)

## 如何使用GreatSQL镜像
例如:
```
$ docker run -d \
--name mgr1 --hostname=mgr1 \
-e MYSQL_ALLOW_EMPTY_PASSWORD=1 \
-e MYSQL_INIT_MGR=1 \
greatsql/greatsql
```
*--name mgr1*，设定容器名称
*--hostname=mgr1*，设定容器主机名
*MYSQL_ALLOW_EMPTY_PASSWORD=1* 设定容器中的MySQL root用户是否采用空密码
*greatsql/greatsql*，指定容器使用的镜像名

## 连接（容器中的）MySQL
运行下面的命令进入容器
```
$ docker exec -it mgr1 bash
```

可以使用mysql 或 mysqladmin等客户端工具
```
[root@mgr1 /]# mysqladmin ping
mysqld is alive
[root@mgr1 /]# mysqladmin ver
mysqladmin  Ver 8.0.25 for Linux on x86_64 (MySQL Community Server - GPL)
Copyright (c) 2018-2021 GreatOpenSource and/or its affiliates
Copyright (c) 2009-2021 Percona LLC and/or its affiliates
Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Server version          8.0.25-15
Protocol version    10
Connection        Localhost via UNIX socket
UNIX socket        /data/GreatSQL/mysql.sock
Uptime:            2 hours 56 min 47 sec

Threads: 70  Questions: 68  Slow queries: 0  Opens: 155  Flush tables: 3  Open tables: 72  Queries per second avg: 0.006

[root@mgr1 /]# mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
...
[root@GreatSQL][(none)]>select version();
+-----------+
| version() |
+-----------+
| 8.0.25-15 |
+-----------+
1 row in set (0.00 sec)
```

## 如何通过 docker-compose 使用GreatSQL镜像

下面是一个docker-compose的配置文件参考 `/data/docker/mysql.yml`:
```
version: '2'

services:
  mgr1:
    image: greatsql/greatsql
    container_name: mgr1
    hostname: mgr1
    network_mode: bridge
    restart: unless-stopped
    environment:
      TZ: Asia/Shanghai
      MYSQL_ALLOW_EMPTY_PASSWORD: 1
      MYSQL_INIT_MGR: 1
```

运行 `docker-compose -f /data/docker/mysql.yml up -d` 即可创建一个新容器。
运行下面的命令查看容器运行状态:
```
$ docker-compose -f /data/docker/mysql.yml ps
```

运行下面的命令进入容器:
```
$ docker exec -it mgr1 bash
```

## 如何通过docker-compose构建MGR集群

下面是一个docker-compose的配置文件参考 `/data/docker/mgr.yml`:
```
version: '2'

services:
  mgr1:
    image: greatsql/greatsql
    container_name: mgr1
    hostname: mgr1
    network_mode: bridge
    restart: unless-stopped
    environment:
      TZ: Asia/Shanghai
      MYSQL_ALLOW_EMPTY_PASSWORD: 1
      MYSQL_INIT_MGR: 1
      MYSQL_MGR_LOCAL: '172.17.0.2:33061'
      MYSQL_MGR_SEEDS: '172.17.0.2:33061,172.17.0.3:33061'
    extra_hosts:
      - "mgr1:172.17.0.2"
      - "mgr2:172.17.0.3"
  mgr2:
    image: greatsql/greatsql
    container_name: mgr2
    hostname: mgr2
    network_mode: bridge
    restart: unless-stopped
    depends_on:
      - "mgr1"
    environment:
      TZ: Asia/Shanghai
      MYSQL_ALLOW_EMPTY_PASSWORD: 1
      MYSQL_INIT_MGR: 1
      MYSQL_MGR_LOCAL: '172.17.0.3:33061'
      MYSQL_MGR_SEEDS: '172.17.0.2:33061,172.17.0.3:33061'
    extra_hosts:
      - "mgr1:172.17.0.2"
      - "mgr2:172.17.0.3"
```

启动所有容器:
```
$ docker-compse -f /data/docker/mgr.yml up -d
```

进入第一个容器，将其设置为MGR的PRIMARY节点
```
$ docker exec -it mgr1 bash
[root@mgr1 /]# mysql
...
[root@GreatSQL][(none)]> SET GLOBAL group_replication_bootstrap_group=ON;

[root@GreatSQL][(none)]> start group_replication;

[root@GreatSQL][(none)]> select * from performance_schema.replication_group_members;
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+
| CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+
| group_replication_applier | 202eb70c-e13a-11eb-b390-0242ac110002 | mgr1        |        3306 | ONLINE       | PRIMARY     | 8.0.25         |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+
1 rows in set (0.00 sec)
```

进入第二个容器，将其设置为SECONDARY节点
```
$ docker exec -it mgr2 bash
[root@mgr2 /]# mysql
...
[root@GreatSQL][(none)]> start group_replication;

[root@GreatSQL][(none)]>select * from performance_schema.replication_group_members;
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+
| CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+
| group_replication_applier | 202eb70c-e13a-11eb-b390-0242ac110002 | mgr1        |        3306 | ONLINE       | PRIMARY     | 8.0.25         |
| group_replication_applier | 20851760-e13a-11eb-91e1-0242ac110003 | mgr2        |        3306 | ONLINE       | SECONDARY   | 8.0.25         |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+
2 rows in set (0.00 sec)
```
看起来这就好了。

## 环境变量/参数介绍
- **MYSQL_ROOT_PASSWORD**
设置MySQL root账号的密码。如果下面指定了MYSQL_ALLOW_EMPTY_PASSWORD=1，则本参数无效。

- **MYSQL_DATABASE**
是否初始化一个新的数据库。

- **MYSQL_ALLOW_EMPTY_PASSWORD**
是否设置MySQL root账号使用空密码，因为安全原因，不推荐这么做。

- **MYSQL_RANDOM_ROOT_PASSWORD**
设置MySQL root账号的密码采用随机生成方式。

- **MYSQL_IBP**
设置innodb_buffer_pool_size，默认值：128M。

- **MYSQL_MGR_NAME**
设置group_replication_group_name，默认值："aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1"。

- **MYSQL_MGR_LOCAL**
设置 group_replication_local_address，默认值："172.17.0.2:33061"。

- **MYSQL_MGR_SEEDS**
设置 group_replication_group_seeds，默认值："172.17.0.2:33061,172.17.0.3:33061"。

- **MYSQL_INIT_MGR**
是否初始化MGR相关设置，默认值：0（否）。如果设置为1（是），则会创建MGR服务所需账号，并设定运行 CHANGE MASTER TO 设置好MGR复制通道。

- **MYSQL_MGR_USER**
设置MGR服务所需账号，默认值：repl。

- **MYSQL_MGR_USER_PWD**
设置MGR服务所需账号的密码，默认值：repl4MGR。

## 联系我们
扫码关注微信公众号

![输入图片说明](https://images.gitee.com/uploads/images/2021/0802/143402_f9d6cb61_8779455.jpeg "greatsql社区-wx-qrcode-0.5m.jpg")