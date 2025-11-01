# COMPACT 语句详解

## 功能概述
COMPACT 是一种用于优化数据库存储的操作。它通过重组表或数据存储结构来减少磁盘空间占用并提高性能。通常应用于在数据更新频繁或存储碎片较多的情况下，COMPACT 有助于恢复空间并提升读取效率。  

## 语法

```SQL
COMPACT TABLE <table_name> [PARTITION partition_id] 
[FROM <from_time>] 
[TO <to_time>]
```

* 必须指定 table_name 参数；
* 可以指定 PARTITION 仅压缩特定的 partition；
* 可以指定 FROM 和 TO 限定压缩时间范围；
* 不指定 FROM 和 TO 表示压缩指定 Table 或 Partition 的所有时间段的数据；
* 只指定 FROM，不指定 TO 表示压缩从 FROM 时间开始到当前的所有数据；
* 只指定 TO，不指定 FROM 表示压缩从有数据依赖到 TO 时间之间的所有数据；
* FROM 和 TO 支持 ISO 8601 时间格式，支持仅指定日期；

## 示例

```sql
COMPACT TABLE demo.sx1

COMPACT TABLE demo.sx1 PARTITION 1234567 FROM '2020-01-01' TO '2025-01-01T10:00:00.123456789+08:00'

COMPACT TABLE demo.sx1 FROM '2025-01-01T10:00:00.123456789Z'

COMPACT TABLE sx1 TO '2025-01-01'
```
