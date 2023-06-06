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
- [latest](https://hub.docker.com/layers/greatsql/greatsql/latest/images/sha256-37a515999357c072e01fcbb4fcbb5b9e14a29d7438b2244a23ef801b97f23071?context=explore), [8.0.32-24](https://hub.docker.com/layers/greatsql/greatsql/8.0.32-24/images/sha256-37a515999357c072e01fcbb4fcbb5b9e14a29d7438b2244a23ef801b97f23071?context=repo), [8.0.25-16](https://hub.docker.com/layers/greatsql/greatsql/greatsql/8.0.25-16/images/sha256-03969daaaaaeb0f51dde0c9e92ef327302607cdde3afbe5c2b071098000c52c1?context=explore)
- [latest-arch64](https://hub.docker.com/layers/greatsql/greatsql/latest-aarch64/images/sha256-1afccea97b04ea0885dccf818ed1ff7d26f57c66041f31be7ee569c6cd74b4e0?context=repo), [8.0.32-24-arch64](https://hub.docker.com/layers/greatsql/greatsql/8.0.32-24-aarch64/images/sha256-1afccea97b04ea0885dccf818ed1ff7d26f57c66041f31be7ee569c6cd74b4e0?context=repo), [8.0.25-16-aarch64](https://hub.docker.com/layers/greatsql/greatsql/8.0.25-16-aarch64/images/sha256-c4664d2b84025ed2487d0aecb6090ab9bb0f7ee2033afd9a079ea4f1f9f82b52?context=repo)


## 如何使用GreatSQL镜像
例如:
```
$ docker run -d \
--name mgr1 --hostname=mgr1 \
-e MYSQL_ALLOW_EMPTY_PASSWORD=1 \
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

可以使用mysql 客户端工具（在docker镜像中，只保留了mysql这个客户端工具）
```
[root@mgr1 /]# mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 34
Server version: 8.0.32-24 GreatSQL (GPL), Release 24, Revision c2e83f27394
...
mysql  Ver 8.0.32-24 for Linux on x86_64 (GreatSQL (GPL), Release 24, Revision c2e83f27394)
...

[root@GreatSQL][(none)]>\s
...
Server version:        8.0.32-24 GreatSQL (GPL), Release 24, Revision c2e83f27394
...
[root@GreatSQL][(none)]>select version();
+-----------+
| version() |
+-----------+
| 8.0.32-24 |
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
networks:
  mgr_net:  #创建独立MGR专属网络
    ipam:
      config:
        - subnet: 172.18.0.0/24
```

启动所有容器:
```
$ docker-compse -f /data/docker/mgr.yml up -d
```

容器启动后，会自行进行MySQL实例的初始化并自动构建MGR集群。

进入第一个容器，确认实例启动并成为MGR的Primary节点：
```
$ docker exec -it mgr1 bash
$ mysql
...
[root@GreatSQL][(none)]>select * from performance_schema.replication_group_members;
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION | MEMBER_COMMUNICATION_STACK |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| group_replication_applier | d17d165a-ab7a-11ec-a8c0-0242ac120002 | 172.18.0.2  |        3306 | ONLINE       | PRIMARY     | 8.0.32         | XCom                       |
| group_replication_applier | d28c3916-ab7a-11ec-ab60-0242ac120003 | 172.18.0.3  |        3306 | ONLINE       | SECONDARY   | 8.0.32         | XCom                       |
| group_replication_applier | d3dc6855-ab7a-11ec-98a0-0242ac120004 | 172.18.0.4  |        3306 | ONLINE       | ARBITRATOR  | 8.0.32         | XCom                       |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
```
可以看到，一个三节点的MGR集群已自动构建完毕，并且其中还包含一个ARBITRATOR节点（仲裁节点/投票节点）。

## Docker-Compose环境变量/参数介绍
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

- **MYSQL_MGR_ARBITRATOR**
指定当前节点在MGR中以ARBITRATOR角色启动，该选项和**MYSQL_MGR_START_AS_PRIMARY**是互斥的，不能同时设置为1。默认值：0。
非必选项。

- **MYSQL_MGR_VIEWID**
MySQL 8.0.26开始，可以为view change单独指定一个GTID前缀，避免和正常的事务GTID混杂一起，产生问题。默认值：AUTOMATIC。
非必选项。

## 联系我们
扫码关注微信公众号

![输入图片说明](https://images.gitee.com/uploads/images/2021/0802/143402_f9d6cb61_8779455.jpeg "greatsql社区-wx-qrcode-0.5m.jpg")
