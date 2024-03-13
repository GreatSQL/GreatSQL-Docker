# GreatSQL-Shell Docker

## 简介

在Docker环境中运行MySQL Shell for GreatSQL 8.0.32-25，无需额外安装，更方便省事。

## 基本信息
- 维护者: GreatSQL(greatsql@greatdb.com)
- 联系我们：greatsql@greatdb.com
- 最新版本：GreatSQL 8.0.32-25
- 最后更新时间：2024-03-13
- 支持CPU架构：x86_64、aarch64

## 支持哪些tag
- [latest](https://hub.docker.com/layers/greatsql/greatsql_shell/latest/images/sha256-4264884f14341e3b34077c52c2ee7d0d53ce00fb5e45915c3b57e950ef52d80f?context=explore), [8.0.32-25](https://hub.docker.com/layers/greatsql/greatsql_shell/8.0.32-25/images/sha256-4264884f14341e3b34077c52c2ee7d0d53ce00fb5e45915c3b57e950ef52d80f?context=explore)
- [latest-arch64](https://hub.docker.com/layers/greatsql/greatsql_shell/latest-aarch64/images/sha256-46d3d92632256d24078948a81a6750ae808e3c2292c10eb88107633f5bde85ec?context=explore), [8.0.32-25-aarch64](https://hub.docker.com/layers/greatsql/greatsql_shell/8.0.32-25-aarch64/images/sha256-46d3d92632256d24078948a81a6750ae808e3c2292c10eb88107633f5bde85ec?context=explore)

## 怎么使用这个Docker镜像

### 通过tcp/ip方式连接GreatSQL

创建一个MySQL Shell for GreatSQL新容器：
```shell
$ docker run -itd --hostname greatsqlsh --name greatsqlsh greatsql/greatsql_shell bash
```

通过tcp/ip方式连接GreatSQL

```shell
$ docker exec -it greatsqlsh bash -c "mysqlsh --uri GreatSQL@172.17.140.123"
Please provide the password for 'GreatSQL@172.17.140.123': *************
MySQL Shell 8.0.32
...
Your MySQL connection id is 14891 (X protocol)
Server version: 8.0.32-25 GreatSQL, Release 25, Revision db07cc5cb73
No default schema selected; type \use <schema> to set one.

# 获取当前MGR状态信息
 MySQL  172.17.140.123:33060+ ssl  JS > c=dba.getCluster()
 MySQL  172.17.140.123:33060+ ssl  JS > c.status()
{
    "clusterName": "mgr803225",
    "defaultReplicaSet": {
        "name": "default",
        "primary": "172.17.136.59:3306",
        "ssl": "REQUIRED",
        "status": "OK_NO_TOLERANCE",
        "statusText": "Cluster is NOT tolerant to any failures.",
        "topology": {
            "172.17.136.59:3306": {
                "address": "172.17.136.59:3306",
                "memberRole": "PRIMARY",
                "mode": "R/W",
                "readReplicas": {},
                "replicationLag": "applier_queue_applied",
                "role": "HA",
                "status": "ONLINE",
                "version": "8.0.32"
            },
            "172.17.140.123:3306": {
                "address": "172.17.140.123:3306",
                "memberRole": "SECONDARY",
                "mode": "R/O",
                "readReplicas": {},
                "replicationLag": "applier_queue_applied",
                "role": "HA",
                "status": "ONLINE",
                "version": "8.0.32"
            }
        },
        "topologyMode": "Single-Primary"
    },
    "groupInformationSourceMember": "172.17.136.59:3306"
}
 MySQL  172.17.140.123:33060+ ssl  JS >

# 切换到SQL命令行模式下，并查看连接列表
 MySQL  172.17.140.123:33060+ ssl  JS > \sql
Switching to SQL mode... Commands end with ;
Fetching global names for auto-completion... Press ^C to stop.
 MySQL  172.17.140.123:33060+ ssl  SQL > show processlist;
+-------+-------------+----------------------+------+---------+---------+----------------------------------------------------------+----------------------------------+------------+-----------+---------------+
| Id    | User        | Host                 | db   | Command | Time    | State                                                    | Info                             | Time_ms    | Rows_sent | Rows_examined |
+-------+-------------+----------------------+------+---------+---------+----------------------------------------------------------+----------------------------------+------------+-----------+---------------+
|    12 | system user |                      | NULL | Connect | 1200070 | waiting for handler commit                               | Group replication applier module | 1200070613 |         0 |             0 |
...
| 14883 | GreatSQL    | 172.17.134.224:35392 | NULL | Query   |       0 | init                                                     | PLUGIN: show processlist         |          0 |         0 |             0 |
+-------+-------------+----------------------+------+---------+---------+----------------------------------------------------------+----------------------------------+------------+-----------+---------------+
7 rows in set (0.0028 sec)
```

### 通过unix socket方式连接GreatSQL

或者创建一个像这样的新容器，并挂载mysql.sock文件
```shell
$ docker run -itd --hostname greatsqlsh --name greatsqlsh -v /data/GreatSQL/mysql.sock:/tmp/mysql.sock greatsql/greatsql_shell bash
```

通过socket方式连接GreatSQL
```shell
$ docker exec -it greatsqlsh bash -c "mysqlsh -S/tmp/mysql.sock"
Please provide the password for 'root@/tmp%2Fmysql.sock':
MySQL Shell 8.0.32
...
Fetching schema names for auto-completion... Press ^C to stop.
Your MySQL connection id is 178
Server version: 8.0.32-25 GreatSQL, Release 25, Revision db07cc5cb73
No default schema selected; type \use <schema> to set one.
 MySQL  localhost  Py > \sql
Switching to SQL mode... Commands end with ;
Fetching global names for auto-completion... Press ^C to stop.
 MySQL  localhost  SQL > show processlist;
+-----+-------------+-----------------+----------+---------+------+----------------------------------------------------------+----------------------------------+---------+-----------+---------------+
| Id  | User        | Host            | db       | Command | Time | State                                                    | Info                             | Time_ms | Rows_sent | Rows_examined |
+-----+-------------+-----------------+----------+---------+------+----------------------------------------------------------+----------------------------------+---------+-----------+---------------+
|  42 | GreatSQL    | 127.0.0.1:41682 | NULL     | Sleep   | 2469 |                                                          | NULL                             | 2468667 |         0 |             0 |
|  57 | root        | localhost       | greatsql | Sleep   | 2000 |                                                          | NULL                             | 2000318 |         8 |            33 |
...
| 178 | root        | localhost       | NULL     | Query   |    0 | init                                                     | show processlist                 |       0 |         0 |             0 |
+-----+-------------+-----------------+----------+---------+------+----------------------------------------------------------+----------------------------------+---------+-----------+---------------+
9 rows in set (0.0002 sec)
```

如上所示，这就可以在Docker环境中运行MySQL Shell for GreatSQL 8.0.32-25，用它来管理GreatSQL MGR更方便省事。

## 文件介绍
- CHANGELOG.md，更新历史
- Dockerfile，用于构建GreatSQL Shell Docker环境

## 联系我们
扫码关注微信公众号

![GreatSQL社区微信公众号二维码](https://images.gitee.com/uploads/images/2021/0802/143402_f9d6cb61_8779455.jpeg "greatsql社区-wx-qrcode-0.5m.jpg")
