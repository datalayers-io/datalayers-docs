# COMPACT Statement

COMPACT 是一种用于优化数据库存储的操作。它通过重组表或数据存储结构来减少磁盘空间占用并提高性能。通常应用于在数据更新频繁或存储碎片较多的情况下，COMPACT 有助于恢复空间并提升读取效率。

## 语法

```sql
COMPACT [TABLE <table_name> | PARTITION <partition_id>]
    [FROM <start_time>] 
    [TO <end_time>]
```

## COMPACT TABLE

对 table 进行 compaction。

```SQL
# 对全表数据进行 compact
COMPACT TABLE [db.]table_name

# 指定时间范围进行 compact
COMPACT TABLE [db.]table_name FROM "2025-01-01"

# 指定时间范围进行 compact
COMPACT TABLE [db.]table_name FROM "2025-01-01" TO "2025-01-27"
```

## COMPACT PARTITION

对指定 partition 进行 compact。

```SQL
# 指定 partition compact
COMPACT PARTITION partition_id

# 指定时间范围
COMPACT PARTITION partition_id FROM "2025-01-01"

# 指定时间范围
COMPACT PARTITION partition_id FROM "2025-01-01" TO "2025-01-27"
```
