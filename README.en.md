# GreatSQL-Docker

---

## Introduction

Docker image set related to GreatSQL software.

Dockerfiles can be used to customize and build docker images, [Click here to read more about dockerfiles]https://docs.docker.com/engine/reference/builder/).

How to build and run the great SQL software, please refer to the various directories.

We welcome and encourage community users to suggest improvements or contribute code, ideas, and anything else that can help improve the project.

If you find any problems or bugs related to the GreatSQL-Docker, you can [submit issue](https://gitee.com/GreatSQL/GreatSQL-Docker/issues).


## Quick reference
- Maintained by: GreatSQL(greatsql@greatdb.com)
- Where to get help: send mail to greatsql@greatdb.com

## Supported tags
- [8.0.25](https://hub.docker.com/layers/158734159/greatsql/greatsql/8.0.25/images/sha256-d9e0f455e3412127ed59ecc5f69b36a717303ff868cac128fe4d8a0ad6545a4a?context=repo), [latest](https://hub.docker.com/layers/156877878/greatsql/greatsql/latest/images/sha256-d9e0f455e3412127ed59ecc5f69b36a717303ff868cac128fe4d8a0ad6545a4a?context=repo)

## How to use this image
Starting a GreatSQL instance is simple:
```
$ docker run -d \
--name mgr1 --hostname=mgr1 \
-e MYSQL_ALLOW_EMPTY_PASSWORD=1 \
-e MYSQL_INIT_MGR=1 \
greatsql/greatsql
```
*--name mgr1* is the name you want to assign to your container,
*--hostname=mgr1* set the container's hostname,
*MYSQL_ALLOW_EMPTY_PASSWORD=1* set MySQL root user password as empty(by default),
tag is the tag specifying the GreatSQL version you want. See the list above for relevant tags.

## Connect to MySQL
Execute the following command to enter the container
```
$ docker exec -it mgr1 bash
```

You can execute client programs such as mysql or mysqladmin
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

## How to use this image via docker-compose

Example for docker-compose `/data/docker/mysql.yml`:
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

Run `docker-compose -f /data/docker/mysql.yml up -d`to create a new container, run the command to check the container status:
```
$ docker-compose -f /data/docker/mysql.yml ps
```

Run the command to enter container:
```
$ docker exec -it mgr1 bash
```

## How to create a new MGR cluster via docker-compse
Example for docker-compose `/data/docker/mgr.yml`:
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

Start all the containers:
```
$ docker-compse -f /data/docker/mgr.yml up -d
```

Enter the first contaniner, and setup it as MGR PRIMARY node:
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

Enter the second contaniner, and setup it as MGR SECONDARY node:
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
It looks ok.

## Environment Variables
- **MYSQL_ROOT_PASSWORD**

This variable is mandatory and specifies the password that will be set for the MySQL root superuser account.

- **MYSQL_DATABASE**

This variable is optional and allows you to specify the name of a database to be created on image startup.

- **MYSQL_ALLOW_EMPTY_PASSWORD**

This is an optional variable. Set to a non-empty value, like yes, to allow the container to be started with a blank password for the root user. NOTE: Setting this variable to yes is not recommended unless you really know what you are doing, since this will leave your MySQL instance completely unprotected, allowing anyone to gain complete superuser access.

- **MYSQL_RANDOM_ROOT_PASSWORD**

This is an optional variable. Set to a non-empty value, like yes, to generate a random initial password for the root user (using pwmake). The generated root password will be printed to stdout (GENERATED ROOT PASSWORD: .....).

- **MYSQL_IBP**

This is an optional variable. Set innodb_buffer_pool_size=1G, default value: 128M.

- **MYSQL_MGR_NAME**

This is an optional variable. Set group_replication_group_name=X, default value: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1".

- **MYSQL_MGR_LOCAL**

This is an optional variable. Set group_replication_local_address=X, default value: "172.17.0.2:33061".

- **MYSQL_MGR_SEEDS**

This is an optional variable. Set group_replication_group_seeds=X, default value: "172.17.0.2:33061,172.17.0.3:33061".

- **MYSQL_INIT_MGR**

This is an optional variable. If it set to 1(default value is 0), it will create a new user for mgr, and create 'group_replication_recovery' mgr channel.

- **MYSQL_MGR_USER**

This is an optional variable. Set the mgr user name, default value: repl;

- **MYSQL_MGR_USER_PWD**

This is an optional variable. Set the mgr user password, default value: repl4MGR;
