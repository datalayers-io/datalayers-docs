# COMPACT Statement

COMPACT 是一种用于优化数据库存储的操作。它通过重组表或数据存储结构来减少磁盘空间占用并提高性能。通常应用于在数据更新频繁或存储碎片较多的情况下，COMPACT 有助于恢复空间并提升读取和写入效率。

## COMPACT TABLE

```SQL
# 压缩非活跃窗口
COMPACT TABLE [db.]table_name
# 或者
COMPACT TABLE [db.]table_name FOR PAST

# 压缩当前窗口
COMPACT TABLE [db.]table_name FOR CURRENT
```

## COMPACT PARTITION

压缩指定的 partition，可以指定压缩的目标时间窗口。

```SQL
# 压缩非活跃窗口
COMPACT PARTITION partition_id
# 或者
COMPACT PARTITION partition_id FOR PAST

# 压缩当前窗口
COMPACT PARTITION partition_id FOR CURRENT
```
