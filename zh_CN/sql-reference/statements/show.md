---
title: "SHOW 语句详解"
description: "SHOW 语句是 Datalayers 提供的元数据查询命令，用于快速获取数据库系统的各类信息。它提供了比直接查询 INFORMATION_SCHEMA 更简洁的语法，适合日常管理和监控使用。"
---

# SHOW 语句详解

## 功能概述

SHOW 语句是 Datalayers 提供的元数据查询命令，用于快速获取数据库系统的各类信息。它提供了比直接查询 INFORMATION_SCHEMA 更简洁的语法，适合日常管理和监控使用。

## SHOW DATABASES

查看数据库中所有数据库。

```SQL
SHOW DATABASES
```

## SHOW TABLES

查看当前数据库下所有的表，支持可选的 `LIKE` 模式过滤。

```SQL
SHOW TABLES
SHOW TABLES LIKE 'sx%'
```

## SHOW INDEX

查看某个 `table` 下所有的索引。

```SQL
SHOW INDEX FROM [db].table_name
```

## SHOW CREATE DATABASE

回显指定数据库的创建 SQL。

```sql
SHOW CREATE DATABASE db_name
```

## SHOW CREATE TABLE

获取指定 table 的 SCHEMA

```SQL
SHOW CREATE TABLE table_name
```

## SHOW LICENSE

获取系统的 License 信息

```SQL
SHOW LICENSE
```

## SHOW CLUSTER

获取集群节点信息。注：该指令仅在集群模式下生效。

```SQL
SHOW CLUSTER
```

## SHOW PARTITIONS [ON TABLE/NODE name]

查看 partitions 分布

```SQL
# 查看所有 partitions 
SHOW PARTITIONS

# 查看指定 table 的 partitions
SHOW PARTITIONS ON TABLE [db].table_name

# 查看指定 Node 的 partitions
SHOW PARTITIONS ON NODE node_name
```

## SHOW TASKS [TYPE]

查看任务队列

```SQL
# 查看按类型合并的所有任务
SHOW TASKS

# 查看指定类型的任务列表
# 仅支持 SHOW TASKS 结果中 type 列的值，例如:
SHOW TASKS flush
```

## SHOW CURRENT NODE

在集群模式下，通过该命令可查看当前连接对应的节点。  
注：在单机模式下该命令会返回空。

```sql
SHOW CURRENT NODE
```

## SHOW GRANTS

查看当前用户或指定用户/角色的授权信息。

```sql
SHOW GRANTS
SHOW GRANTS FOR 'user1'@'127.0.0.1'
```

## SHOW PRIVILEGES

查看系统当前支持的权限类型。

```sql
SHOW PRIVILEGES
```

## SHOW VERSION

获取 Datalayers 的版本号

```shell
> show version
+---------+
| version |
+---------+
| 1.0.3   |
+---------+
1 row in set (0.003 sec)
```
