
## CREATE DATABASE

在 Datalayers 中数据库可看为一个集合，该集合中包含了一种或者多种数据模型的table  
**语法**
```SQL
CREATE DATABASE [IF NOT EXISTS] database_name
```

**示例**
```SQL
CREATE DATABASE hello_datalayers
```
表示创建一个名为 `hello_datalayers` 的数据库。
## CREATE TABLE

**语法**
```SQL
CREATE TABLE [IF NOT EXISTS] [database.]table_name 
(
    column_name data_type [column_constraint] [ DEFAULT default_expr ]，
    ...
    ...
    timestamp key (ts_column_name)
)
PARTITION BY HASH(expr) PARTITIONS PARTITOIN_NUM
ENGINE=TimeSeries
with(k=v,k1=v1)
```
对于时序（TimeSeries）引擎，至少有一个列需要为 **TIMESTAMP** 类型，且必须使用 `timestamp key` 语句来指定唯一的 timestamp key 列，这个列的类型必须为 **TIMESTAMP**。

::: tip
针对非 **TIMESTAMP** 类型，默认值只支持常量设置。针对 **TIMESTAMP** 类型，默认值除了常量外还支持输出`CURRENT_TIMESTAMP`，在写入数据时如果没有给出时间戳值将会使用写入时间。
:::  

**示例**
```SQL
CREATE TABLE sx1(
    ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sid INT32,
    value REAL,
    flag INT8,
    timestamp key (ts),
    )
PARTITION BY HASH(sid) PARTITIONS 1
ENGINE=TimeSeries
with (ttl='10d')
```

