
# SHOW 语句详解

## 功能概述
SHOW 语句是 Datalayers 提供的元数据查询命令，用于快速获取数据库系统的各类信息。它提供了比直接查询 INFORMATION_SCHEMA 更简洁的语法，适合日常管理和监控使用。

## SHOW DATABASES

查看数据库中所有数据库。

```SQL
SHOW DATABASES
```

## SHOW TABLES

查看某个 `database` 下所有的table。

```SQL
SHOW TABLES
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

## SHOW CURRENT node

在集群模式gh，通过该命令可查看当前连接对应的节点。  
注：在单机模式下该命令会返回空。

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
