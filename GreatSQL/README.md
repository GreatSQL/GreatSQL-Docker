# GreatSQL Docker
---

## 简介

本项目用于构建GreatSQL Docker镜像。

适用于CentOS 8 x86_64/aarch64 环境，更多环境适配请自行修改Dockerfile及相关脚本中的参数。

## 基本信息
- 维护者: GreatSQL(greatsql@greatdb.com)
- 联系我们：greatsql@greatdb.com
- 最新版本：GreatSQL 8.0.32-25
- 最后更新时间：2024-03-20
- 支持CPU架构：x86_64、aarch64

## 支持哪些tag

- [latest](https://hub.docker.com/layers/greatsql/greatsql/latest/images/sha256-6a01d0b1b9107b286601249202803da5b08e9f729b8727f691ce423928994eef?context=repo), [8.0.32-25](https://hub.docker.com/layers/greatsql/greatsql/8.0.32-25/images/sha256-6a01d0b1b9107b286601249202803da5b08e9f729b8727f691ce423928994eef?context=repo), [8.0.32-24](https://hub.docker.com/layers/greatsql/greatsql/8.0.32-24/images/sha256-0d1ee8a01e4dec5d3698053319978c1817ca455eb6a11de9fa7e13b747fa9f3e?context=repo), [8.0.25-16](https://hub.docker.com/layers/greatsql/greatsql/greatsql/8.0.25-16/images/sha256-03969daaaaaeb0f51dde0c9e92ef327302607cdde3afbe5c2b071098000c52c1?context=explore)
- [latest](https://hub.docker.com/layers/greatsql/greatsql/latest/images/sha256-6a01d0b1b9107b286601249202803da5b08e9f729b8727f691ce423928994eef?context=repo), [8.0.32-25](https://hub.docker.com/layers/greatsql/greatsql/8.0.32-25/images/sha256-6a01d0b1b9107b286601249202803da5b08e9f729b8727f691ce423928994eef?context=repo), [8.0.32-24-arch64](https://hub.docker.com/layers/greatsql/greatsql/8.0.32-24-aarch64/images/sha256-97dfa7074a1c5b2e0355fcf5fc829e8074edca6db7c2e528059786fb0c48a523?context=repo), [8.0.25-16-aarch64](https://hub.docker.com/layers/greatsql/greatsql/8.0.25-16-aarch64/images/sha256-c4664d2b84025ed2487d0aecb6090ab9bb0f7ee2033afd9a079ea4f1f9f82b52?context=repo)

## GreatSQL Docker镜像使用

例如:

```shell
$ docker run -d \
--name greatsql --hostname=greatsql \
greatsql/greatsql
```

执行上述命令后，会创建一个GreatSQL运行环境容器，且采用空密码初始化。

几个参数简介：
*--name greatsql*，设定容器名称
*--hostname=greatsql*，设定容器主机名
*greatsql/greatsql*，指定容器使用的镜像名

如果想要映射外部 my.cnf 配置文件或自行指定 datadir，还可以类似下面这么用：

```shell
$ docker run -d \
-v /data/greatsql/my.cnf:/etc/my.cnf \
-v  /data/greatsql/data:/data \
--name greatsql --hostname=greatsql \
greatsql/greatsql
```

注意，需要先保证本地目录 `/data/greatsql/data` 是空的才行，否则 GreatSQL 在初始化检测时会报告失败，无法启动，日志中将有类似下面的内容：

```shell
[ERROR] [MY-010457] [Server] --initialize specified but the data directory has files in it. Aborting.
[ERROR] [MY-013236] [Server] The designated data directory /data/GreatSQL/ is unusable. You can remove all files that the server added to it.
[ERROR] [MY-010119] [Server] Aborting
```

## 连接（容器中的）MySQL
运行下面的命令进入容器

```shell
$ docker exec -it greatsql bash
```

可以使用mysql 客户端工具（在docker镜像中，只保留了mysql这个客户端工具）

```shell
[root@greatsql /]# mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 34
Server version: 8.0.32-25 GreatSQL, Release 25, Revision db07cc5cb73
...
mysql  Ver 8.0.32-24 for Linux on x86_64 (GreatSQL (GPL), Release 24, Revision c2e83f27394)
...

[root@GreatSQL][(none)]> \s
...
Server version:         8.0.32-25 GreatSQL, Release 25, Revision db07cc5cb73
...
[root@GreatSQL][(none)]> SELECT version();
+-----------+
| version() |
+-----------+
| 8.0.32-25 |
+-----------+
1 row in set (0.00 sec)

-- 初始化完后，执行测试脚本，验证是否支持新的特性和Oracle兼容语法等
[root@GreatSQL][(none)]> SOURCE /tmp/greatsql-test.sql;
```

## 如何通过 docker-compose 使用GreatSQL镜像

下面是一个docker-compose的配置文件参考 `/data/docker/mysql.yml`:

```shell
version: '2'

services:
  greatsql:
    image: greatsql/greatsql
    container_name: greatsql
    hostname: greatsql
    network_mode: bridge
    restart: unless-stopped
    environment:
      TZ: Asia/Shanghai
```

运行 `docker-compose -f /data/docker/mysql.yml up -d` 即可创建一个新容器。

运行下面的命令查看容器运行状态:

```shell
$ docker-compose -f /data/docker/mysql.yml ps
```

运行下面的命令进入容器:

```shell
$ docker exec -it greatsql bash
```

## 如何通过docker-compose构建MGR集群（单主模式）

下面是一个docker-compose的配置文件参考 `/data/docker/mgr.yml`:

```
version: '2'

services:
  mgr2:
    image: greatsql/greatsql #指定镜像
    container_name: mgr2    #设定容器名字
    hostname: mgr2          #设定容器中的主机名
    networks:               #指定容器使用哪个专用网络
      mgr_net:
        ipv4_address: 172.18.0.2    #设置容器使用固定IP地址，避免重启后IP变化
    restart: unless-stopped         #设定重启策略
    environment:                    #设置多个环境变量
      TZ: Asia/Shanghai             #时区
      MYSQL_ALLOW_EMPTY_PASSWORD: 1                 #允许root账户空密码
      MYSQL_INIT_MGR: 1                             #初始化MGR集群
      MYSQL_MGR_LOCAL: '172.18.0.2:33061'           #当前MGR节点的local_address
      MYSQL_MGR_SEEDS: '172.18.0.2:33061,172.18.0.3:33061,172.18.0.4:33061'     #MGR集群seeds
      MYSQL_MGR_START_AS_PRIMARY: 1                 #指定当前MGR节点为Primary角色
      MYSQL_MGR_ARBITRATOR: 0
      LOWER_CASE_TABLE_NAMES: 0                     #设定lower_case_table_names值，默认为0
  mgr3:
    image: greatsql/greatsql
    container_name: mgr3
    hostname: mgr3
    networks:
      mgr_net:
        ipv4_address: 172.18.0.3
    restart: unless-stopped
    depends_on:
      - "mgr2"
    environment:
      TZ: Asia/Shanghai
      MYSQL_ALLOW_EMPTY_PASSWORD: 1
      MYSQL_INIT_MGR: 1
      MYSQL_MGR_LOCAL: '172.18.0.3:33061'
      MYSQL_MGR_SEEDS: '172.18.0.2:33061,172.18.0.3:33061,172.18.0.4:33061'
      MYSQL_MGR_START_AS_PRIMARY: 0
      MYSQL_MGR_ARBITRATOR: 0                       #既非Primary，也非Arbitrator，那么就是Secondary角色了
      LOWER_CASE_TABLE_NAMES: 0
  mgr4:
    image: greatsql/greatsql
    container_name: mgr4
    hostname: mgr4
    networks:
      mgr_net:
        ipv4_address: 172.18.0.4
    restart: unless-stopped
    depends_on:
      - "mgr3"
    environment:
      TZ: Asia/Shanghai
      MYSQL_ALLOW_EMPTY_PASSWORD: 1
      MYSQL_INIT_MGR: 1
      MYSQL_MGR_LOCAL: '172.18.0.4:33061'
      MYSQL_MGR_SEEDS: '172.18.0.2:33061,172.18.0.3:33061,172.18.0.4:33061'
      MYSQL_MGR_START_AS_PRIMARY: 0
      MYSQL_MGR_ARBITRATOR: 1                   #指定当前MGR节点为Arbitrator角色，此时不能同时指定其为Primary/Secondary角色
      LOWER_CASE_TABLE_NAMES: 0
networks:
  mgr_net:  #创建独立MGR专属网络
    ipam:
      config:
        - subnet: 172.18.0.0/24
```

启动所有容器:

```shell
$ docker-compse -f /data/docker/mgr.yml up -d
```

容器启动后，会自行进行MySQL实例的初始化并自动构建MGR集群。

进入第一个容器，确认实例启动并成为MGR的Primary节点：

```shell
$ docker exec -it mgr2 bash
$ mysql
...
[root@GreatSQL][(none)]> SELECT * FROM performance_schema.replication_group_members;
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION | MEMBER_COMMUNICATION_STACK |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| group_replication_applier | d17d165a-ab7a-11ec-a8c0-0242ac120002 | 172.18.0.2  |        3306 | ONLINE       | PRIMARY     | 8.0.32         | XCom                       |
| group_replication_applier | d28c3916-ab7a-11ec-ab60-0242ac120003 | 172.18.0.3  |        3306 | ONLINE       | SECONDARY   | 8.0.32         | XCom                       |
| group_replication_applier | d3dc6855-ab7a-11ec-98a0-0242ac120004 | 172.18.0.4  |        3306 | ONLINE       | ARBITRATOR  | 8.0.32         | XCom                       |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
```
可以看到，一个三节点的MGR集群已自动构建完毕，并且其中还包含一个ARBITRATOR节点（仲裁节点/投票节点）。


## 如何通过docker-compose构建MGR集群（多主模式）

下面是一个docker-compose的配置文件参考 `/data/docker/mgr-multi-primary.yml`:

```
version: '2'

services:
  mgr2:
    image: greatsql/greatsql
    container_name: mgr2    #设定容器名字
    hostname: mgr2          #设定容器中的主机名
    networks:               #指定容器使用哪个专用网络
      mgr_net:
        ipv4_address: 172.18.0.2    #设置容器使用固定IP地址，避免重启后IP变化
    restart: unless-stopped         #设定重启策略
    environment:                    #设置多个环境变量
      TZ: Asia/Shanghai             #时区
      MYSQL_ALLOW_EMPTY_PASSWORD: 1                 #允许root账户空密码
      MYSQL_INIT_MGR: 1                             #初始化MGR集群
      MYSQL_MGR_LOCAL: '172.18.0.2:33061'           #当前MGR节点的local_address
      MYSQL_MGR_SEEDS: '172.18.0.2:33061,172.18.0.3:33061,172.18.0.4:33061'     #MGR集群seeds
      MYSQL_MGR_START_AS_PRIMARY: 1                 #指定当前MGR节点为Primary角色
      MYSQL_MGR_MULTI_PRIMARY: 1             #指定是否采用多主模式
      MYSQL_MGR_ARBITRATOR: 0                       
      LOWER_CASE_TABLE_NAMES: 0
      #MYSQL_MGR_VIEWID: "aaaaaaaa-bbbb-bbbb-aaaa-aaaaaaaaaaa1"
  mgr3:
    image: greatsql/greatsql
    container_name: mgr3
    hostname: mgr3
    networks: 
      mgr_net:
        ipv4_address: 172.18.0.3
    restart: unless-stopped
    depends_on:
      - "mgr2"
    environment:
      TZ: Asia/Shanghai
      MYSQL_ALLOW_EMPTY_PASSWORD: 1
      MYSQL_INIT_MGR: 1
      MYSQL_MGR_LOCAL: '172.18.0.3:33061'
      MYSQL_MGR_SEEDS: '172.18.0.2:33061,172.18.0.3:33061,172.18.0.4:33061'
      MYSQL_MGR_START_AS_PRIMARY: 0
      MYSQL_MGR_MULTI_PRIMARY: 1
      MYSQL_MGR_ARBITRATOR: 0                       #既非Primary，也非Arbitrator，那么就是Secondary角色了                 
      LOWER_CASE_TABLE_NAMES: 0
      #MYSQL_MGR_VIEWID: "aaaaaaaa-bbbb-bbbb-aaaa-aaaaaaaaaaa1"
  mgr4:
    image: greatsql/greatsql
    container_name: mgr4
    hostname: mgr4
    networks: 
      mgr_net:
        ipv4_address: 172.18.0.4
    restart: unless-stopped
    depends_on:
      - "mgr3"
    environment:
      TZ: Asia/Shanghai
      MYSQL_ALLOW_EMPTY_PASSWORD: 1
      MYSQL_INIT_MGR: 1
      MYSQL_MGR_LOCAL: '172.18.0.4:33061'
      MYSQL_MGR_SEEDS: '172.18.0.2:33061,172.18.0.3:33061,172.18.0.4:33061'
      MYSQL_MGR_START_AS_PRIMARY: 0
      MYSQL_MGR_MULTI_PRIMARY: 1
      MYSQL_MGR_ARBITRATOR: 0                   #指定当前MGR节点为Arbitrator角色，此时不能同时指定其为Primary/Secondary角色
      LOWER_CASE_TABLE_NAMES: 0
      #MYSQL_MGR_VIEWID: "aaaaaaaa-bbbb-bbbb-aaaa-aaaaaaaaaaa1"
networks:
  mgr_net:  #创建独立MGR专属网络
    ipam:
      config:
        - subnet: 172.18.0.0/24
```

启动所有容器:

```shell
$ docker-compse -f /data/docker/mgr-multi-primary.yml up -d
```

容器启动后，会自行进行MySQL实例的初始化并自动构建MGR集群。

进入第一个容器，确认实例启动并成为MGR的Primary节点：

```shell
$ docker exec -it mgr2 bash
$ mysql
...
[root@GreatSQL][(none)]> SELECT * FROM performance_schema.replication_group_members;
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION | MEMBER_COMMUNICATION_STACK |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| group_replication_applier | 9831bac0-30d4-11ee-8b65-0242ac120002 | 172.18.0.2  |        3306 | ONLINE       | PRIMARY     | 8.0.32         | XCom                       |
| group_replication_applier | 9907b1ae-30d4-11ee-8c66-0242ac120003 | 172.18.0.3  |        3306 | ONLINE       | PRIMARY     | 8.0.32         | XCom                       |
| group_replication_applier | 9a1ee7ca-30d4-11ee-8b93-0242ac120004 | 172.18.0.4  |        3306 | ONLINE       | PRIMARY     | 8.0.32         | XCom                       |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
```
可以看到，一个三节点的MGR集群已自动构建完毕，运行模式为多主模式。

## Docker-Compose环境变量/参数介绍
- **MYSQL_ROOT_PASSWORD**
设置MySQL root账号的密码。如果下面指定了MYSQL_ALLOW_EMPTY_PASSWORD=1，则本参数无效。

- **MYSQL_DATABASE**
是否初始化一个新的数据库。

- **MYSQL_ALLOW_EMPTY_PASSWORD**
是否设置MySQL root账号使用空密码，因为安全原因，不推荐这么做。

- **MYSQL_RANDOM_ROOT_PASSWORD**
设置MySQL root账号的密码采用随机生成方式。

- **MAXPERF**
设置是否采用最大性能模式运行容器，默认值：1，即默认启用该模式。如果您不需要运行该模式，请在创建容器时加上 `-e MAXPERF=0` 参数。在MAXPERF模式下，会进行如下几个调整：

	- 调整 innodb_buffer_pool_size 为物理内存的75%。 
	- 调整 rapid_memory_limit 为 innodb_buffer_pool_size 的50%。 
	- 调整 rapid_worker_threads 为逻辑CPU核数-2 。
	- 调整 max_connections = 4096。
	- 其他更多调整内容请参考 [脚本greatsql-init.sh](./greatsql-init.sh) 中的MAXPERF处理逻辑。

- **MYSQL_IBP**
设置innodb_buffer_pool_size，默认值：128M。

- **MYSQL_INIT_MGR**
是否初始化MGR相关设置，默认值：0（否）。如果设置为1（是），则会创建MGR服务所需账号，并设定运行 CHANGE MASTER TO 设置好MGR复制通道。
非必选项。

- **MYSQL_MGR_NAME**
设置group_replication_group_name，默认值："aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1"。
非必选项。

- **MYSQL_MGR_LOCAL**
设置 group_replication_local_address，默认值："172.17.0.2:33061"。
如果 MYSQL_INIT_MGR=1 则为必选项。

- **MYSQL_MGR_SEEDS**
设置 group_replication_group_seeds，默认值："172.17.0.2:33061,172.17.0.3:33061"。
如果 MYSQL_INIT_MGR=1 则为必选项。

- **MYSQL_MGR_USER**
设置MGR服务所需账号，默认值：repl。
非必选项。

- **MYSQL_MGR_USER_PWD**
设置MGR服务所需账号的密码，默认值：repl4MGR。
非必选项。

- **MYSQL_SID**
设置server_id选项，构建MGR集群时要求每个节点的server_id是唯一的，默认值：3306+随机数
非必选项。

- **MYSQL_MGR_START_AS_PRIMARY**
指定当前节点在MGR中以PRIMARY角色启动，每次都会进行MGR初始化引导操作。默认值：0。
如果 MYSQL_INIT_MGR=1 则至少要有一个节点指定为PRIMARY角色。

- **MYSQL_MGR_MULTI_PRIMARY**
设置是否采用多主模式运行。默认值：0。
如果 MYSQL_MGR_MULTI_PRIMARY=1，则【有且只能选择一个节点】设置 MYSQL_MGR_START_AS_PRIMARY=1，该节点会采用引导模式启动，其余节点不设置引导模式。

- **MYSQL_MGR_ARBITRATOR**
指定当前节点在MGR中以ARBITRATOR角色启动，该选项和**MYSQL_MGR_START_AS_PRIMARY**是互斥的，不能同时设置为1。默认值：0。
非必选项。

- **MYSQL_MGR_VIEWID**
MySQL 8.0.26开始，可以为view change单独指定一个GTID前缀，避免和正常的事务GTID混杂一起，产生问题。默认值：AUTOMATIC。
非必选项。

- **LOWER_CASE_TABLE_NAMES**
设置表名大小写选项 lower_case_table_names，设置为0表示区分大小写，设置为1表示不区分带下写。默认值：0。
非必选项。

## 文件介绍
- CHANGELOG.md，更新历史
- docker-compose，利用docker-compose拉起的示例文件
- Dockerfile，用于构建GreatSQL Shell Docker环境
- greatsql-init.sh，构建镜像初始化脚本
- greatsql-shrink.sh，在镜像中裁剪非必要文件脚本
- greatsql-test.sql，可执行GreatSQL自测试的脚本
- my.cnf，my.cnf模板文件

## 联系我们
扫码关注微信公众号

![GreatSQL社区微信公众号二维码](https://images.gitee.com/uploads/images/2021/0802/143402_f9d6cb61_8779455.jpeg "greatsql社区-wx-qrcode-0.5m.jpg")
