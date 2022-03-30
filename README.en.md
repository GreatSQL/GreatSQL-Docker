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
- [8.0.27](https://hub.docker.com/layers/158734159/greatsql/greatsql/8.0.27/images/sha256-d9e0f455e3412127ed59ecc5f69b36a717303ff868cac128fe4d8a0ad6545a4a?context=repo), [latest](https://hub.docker.com/layers/156877878/greatsql/greatsql/latest/images/sha256-d9e0f455e3412127ed59ecc5f69b36a717303ff868cac128fe4d8a0ad6545a4a?context=repo)
- [8.0.27-aarch64](https://hub.docker.com/layers/greatsql/greatsql/greatsql/8.0.27-aarch64/images/sha256-304b9d1bfc10898ffdab859399f02a6f929b51ca2d49e866d49f821cdfb59de9?context=explore), [latest-aarch64](https://hub.docker.com/layers/greatsql/greatsql/greatsql/latest-aarch64/images/sha256-304b9d1bfc10898ffdab859399f02a6f929b51ca2d49e866d49f821cdfb59de9?context=explore)

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
[root@mgr1 /]# mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 34
Server version: 8.0.27-18 GreatSQL (GPL), Release 18, Revision 202203211301
...
mysql  Ver 8.0.27-18 for Linux on x86_64 (GreatSQL (GPL), Release 18, Revision 202203211301)
...

[root@GreatSQL][(none)]>\s
...
Server version:        8.0.27-18 GreatSQL (GPL), Release 18, Revision 202203211301
...
[root@GreatSQL][(none)]>select version();
+-----------+
| version() |
+-----------+
| 8.0.27-18 |
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
  mgr2:
    image: greatsql/greatsql
    container_name: mgr2
    hostname: mgr2     
    networks:         
      mgr_net:
        ipv4_address: 172.18.0.2
    restart: unless-stopped         
    environment:                    
      TZ: Asia/Shanghai             
      MYSQL_ALLOW_EMPTY_PASSWORD: 1                 
      MYSQL_INIT_MGR: 1                             
      MYSQL_MGR_LOCAL: '172.18.0.2:33061'           
      MYSQL_MGR_SEEDS: '172.18.0.2:33061,172.18.0.3:33061,172.18.0.4:33061'     
      MYSQL_MGR_START_AS_PRIMARY: 1   #Specify the current node as the PRIMARY 
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
      MYSQL_MGR_ARBITRATOR: 0   #Neither primary nor arbitrator, then it is the SECONDARY
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
      MYSQL_MGR_ARBITRATOR: 1  #Specify the current node as ARBITRATOR. It cannot be specified as the PRIMARY/SECONDARY at the same time
networks:
  mgr_net:  
    ipam:
      config:
        - subnet: 172.18.0.0/24
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
[root@GreatSQL][(none)]> select * from performance_schema.replication_group_members;
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION | MEMBER_COMMUNICATION_STACK |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
| group_replication_applier | d17d165a-ab7a-11ec-a8c0-0242ac120002 | 172.18.0.2  |        3306 | ONLINE       | PRIMARY     | 8.0.27         | XCom                       |
| group_replication_applier | d28c3916-ab7a-11ec-ab60-0242ac120003 | 172.18.0.3  |        3306 | ONLINE       | SECONDARY   | 8.0.27         | XCom                       |
| group_replication_applier | d3dc6855-ab7a-11ec-98a0-0242ac120004 | 172.18.0.4  |        3306 | ONLINE       | ARBITRATOR  | 8.0.27         | XCom                       |
+---------------------------+--------------------------------------+-------------+-------------+--------------+-------------+----------------+----------------------------+
```
The mgr cluster has been built, it contains an arbitrator node.

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

- **MYSQL_INIT_MGR**

This is an optional variable. If it set to 1(default value is 0), it will create a new user for mgr, and create 'group_replication_recovery' mgr channel.
Optional.

- **MYSQL_MGR_NAME**

This is an optional variable. Set group_replication_group_name=X, default value: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1".
Optional.

- **MYSQL_MGR_LOCAL**

This is an optional variable. Set group_replication_local_address=X, default value: "172.17.0.2:33061".
Required, if MYSQL_INIT_MGR=1.

- **MYSQL_MGR_SEEDS**

This is an optional variable. Set group_replication_group_seeds=X, default value: "172.17.0.2:33061,172.17.0.3:33061".
Required, if MYSQL_INIT_MGR=1.

- **MYSQL_MGR_USER**

This is an optional variable. Set the mgr user name, default value: repl;
Optional.

- **MYSQL_MGR_USER_PWD**

This is an optional variable. Set the mgr user password, default value: repl4MGR;
Optional.

- **MYSQL_SID**
Set up server_id option, which requires the server_id is unique of each node when building an mgr. The default value is 3306 + random number.
Optional.

- **MYSQL_MGR_START_AS_PRIMARY**
Specify that the current node as PRIMARY. Default: 0.
If MYSQL_INIT_MGR = 1, at least one node must be designated as primary role.

- **MYSQL_MGR_ARBITRATOR**
Specifies that the current node as ARBITRATOR node. This option is exclusive with **MYSQL_MGR_START_AS_PRIMARY**, cannot be set to 1 at the same time. Default: 0.
Optional.

- **MYSQL_MGR_VIEWID**
As of MySQL 8.0.26, you can select an alternative UUID to form part of the GTIDs that are used when Group Replication’s internally generated transactions for view changes (View_change_log_event) are written to the binary log. Default: AUTOMATIC.
Optional.

## Contact Us
please scan the qr code


![输入图片说明](https://images.gitee.com/uploads/images/2021/0802/143402_f9d6cb61_8779455.jpeg "greatsql社区-wx-qrcode-0.5m.jpg")
