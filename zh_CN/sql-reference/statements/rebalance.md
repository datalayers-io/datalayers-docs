# REBALANCE 语句详解

## 功能概述
REBALANCE 语句用于重新分布集群中的数据分区，优化数据在节点间的分布均衡性。该操作通过调整分区布局，消除数据倾斜，提升集群整体性能和资源利用率。

## 语法

```SQL
REBALANCE [database db_name | table [database.]table_name]
```

### REBALANCE

```SQL
REBALANCE
```

对数据库的所有 table 的 partitions 进行重新分布。

### REBALANCE DATABASE

```SQL
REBALANCE DATABASE db_name
```

对指定数据库为 db_name 中的所有 table 的 partitions 进行重新分布。

### REBALANCE TABLE

```SQL
REBALANCE TABLE table_name
```

对指定 table 的所有 partitions 进行重新分布。

## 注意事项
- 仅支持在集群模式下使用。
