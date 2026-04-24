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

## SHOW SOURCES

查看当前数据库下的所有 source。

```SQL
SHOW SOURCES
```

当前版本返回以下列：

| 列名 | 含义 |
| --- | --- |
| `source` | source 名称 |
| `version` | source 元信息的 version |
| `created_time` | source 创建时间，ISO 8601 字符串 |
| `updated_time` | source 最近一次更新时间，ISO 8601 字符串 |

说明：

- 当前用户需要具备当前数据库的 `SELECT` 权限

## SHOW PIPELINES

查看当前数据库下的所有 pipeline。

```SQL
SHOW PIPELINES
```

当前版本返回以下列：

| 列名 | 含义 |
| --- | --- |
| `pipeline_name` | pipeline 名称 |
| `source_name` | pipeline 读取的 source 名称；如果有多个 source，会用逗号拼接 |
| `sink_name` | pipeline 写入的 sink 名称 |
| `state` | pipeline 当前状态 |
| `up_time` | 从启动到当前的运行时长；未启动时为 `-` |
| `stopped_time` | pipeline 停止时间；未停止时为 `-` |
| `created_time` | pipeline 创建时间，ISO 8601 字符串 |
| `assigned_node` | 仅在集群模式下显示，pipeline 相关任务将被调度到该节点运行 |

说明：

- 当前用户需要具备当前数据库的 `SELECT` 权限

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

## SHOW CREATE SOURCE

回显指定 source 的定义 SQL。

```sql
SHOW CREATE SOURCE source_name
```

说明：

- 输出的是规范化后的 `CREATE SOURCE` 语句，而不是用户的原始输入
- 敏感参数在输出时会被脱敏处理，例如密码类字段会以 * 号代替

## SHOW CREATE PIPELINE

回显指定 pipeline 的定义 SQL。

```sql
SHOW CREATE PIPELINE pipeline_name
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
