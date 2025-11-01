# FLUSH  语句详解

## 功能概述
FLUSH 语句是 Datalayers 时序、日志引擎专用的数据管理命令，用于将内存（wal）中的数据进行强制落盘，将 wal 数据落到存储引擎中。

## 语法

### FLUSH TABLE

```SQL
FLUSH TABLE [db.]table_name
```

将指定 `table_name` 内存的数据刷到磁盘。

### FLUSH DATABASE

```SQL
FLUSH DATABASE db_name
```

将指定 db_name 中所有 table 的内存数据刷到磁盘上。

### FLUSH NODE

将指定集群节点上所有 partition 的内存数据刷到磁盘上。

```SQL
FLUSH NODE name
```

## 注意事项

* 所有 `FLUSH` 指定均为异步执行，如需查看进度/状态，请通过 `SHOW` Statement 语句进行查询。
