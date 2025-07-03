# REBALANCE Statement

对服务器节点上 table 的 partitions 进行重新分布，提高服务器集群的负载均衡性。  
```tip
注：该指令仅支持时序引擎。
```
## 语法

```SQL
REBALANCE [database db_name | table [database.]table_name]
```

### REBALANCE

```SQL
REBALANCE
```

对所有数据库的所有 table 的 partitions 进行重新分布。

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

```tips
注：仅支持在集群模式下使用。
```
