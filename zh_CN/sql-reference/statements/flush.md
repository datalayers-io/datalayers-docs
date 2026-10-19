---
title: "FLUSH 语句详解"
description: "FLUSH 语句是 Datalayers 时序与日志引擎的数据管理命令，用于将内存中的 WAL 数据强制刷盘到存储引擎，以提升数据持久化安全性。"
---
# FLUSH 语句详解

## 功能概述

FLUSH 语句是 Datalayers 时序与日志引擎的数据管理命令，用于将内存中的 WAL 数据强制刷盘到存储引擎。

## 语法

```SQL
FLUSH 
    [TABLE [db.]table_name]
    | [DATABASE db_name]
    | [NODE node_name]
    | [ALL]
    [SYNC]
```

### 说明

- SYNC 表示同步等待 flush 完成才返回结果

示例：

### 将指定 `table` 内存的数据刷到磁盘

```SQL
FLUSH TABLE demo.sx1
```

### 将指定 db 中所有 table 的内存数据刷到磁盘上

```SQL
FLUSH DATABASE demo
```

### 将指定集群节点上所有 partition 的内存数据刷到磁盘上

```SQL
FLUSH NODE 'localhost:8366'
```

### 将所有 table 内存中的数据刷到磁盘

```SQL
FLUSH ALL
```

## 注意事项

* 未指定`SYNC`参数时，`FLUSH` 命令将立即返回，并在后台异步执行，如需查看进度/状态，请通过 `SHOW` Statement 语句进行查询。
