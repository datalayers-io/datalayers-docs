---
title: "DROP 语句详解"
description: "Datalayers DROP 语句详解 - DROP 语句是用于永久删除数据库对象的 SQL 命令。该操作不可撤销，一旦执行，目标对象及其所有关联数据将被永久删除，需要谨慎使用。"
---

# DROP 语句详解

## 功能概述

DROP 语句是用于永久删除数据库对象的 SQL 命令。该操作不可撤销，一旦执行，目标对象及其所有关联数据将被**永久删除**，需要谨慎使用。

## 语法

### DROP TABLE

删除指定的 table。执行该指令将删除该 table 下的所有数据，请谨慎操作。  

```SQL
DROP TABLE [IF EXISTS] [db.]table_name 
```

### DROP DATABASE

```SQL
DROP DATABASE [IF EXISTS] database_name
```

删除指定的 `database`。如果 `database` 不为空（database 下存在 table），则不可删除。  

### DROP INDEX

删除指定索引（包括倒排索引和向量索引）。

```SQL
DROP INDEX [IF EXISTS] index_name ON [database.]table_name
```

示例

```SQL
DROP INDEX idx_message ON logs;

DROP INDEX IF EXISTS idx_message ON logs;
```

### DROP SOURCE

删除指定 source。

```SQL
DROP SOURCE [IF EXISTS] [db.]source_name
```

说明

- 如果 source 仍被某个 pipeline 引用，删除会失败。
- `IF EXISTS` 可用于忽略不存在对象的报错。

### DROP PIPELINE

删除指定 pipeline。

```SQL
DROP PIPELINE [IF EXISTS] [db.]pipeline_name
```

说明

- 只有处于 `Stopped` 或 `Failed` 状态的 pipeline 才允许删除。
- 如果 pipeline 仍在运行，请先执行 `ALTER PIPELINE ... STOP`，再执行 `DROP PIPELINE`。
- `IF EXISTS` 可用于忽略不存在对象的报错。

### DROP NODE

```SQL
DROP NODE node_name [force]
```

将指定的节点从集群中移除。

注：当指定 Node 上还存在 partition 时，drop node 指令会被拒绝。
