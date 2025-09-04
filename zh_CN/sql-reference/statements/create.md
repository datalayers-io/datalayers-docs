
# CREATE Statement

CREATE 语句是一种用于创建数据库对象（如数据库、表等）的 SQL 语句。通过 CREATE 语句，用户可以定义对象的结构、约束以及属性，是数据库设计和初始化的基础。

## 语法

### 创建数据库

```SQL
CREATE DATABASE [IF NOT EXISTS] database_name
```

示例

```SQL
CREATE DATABASE hello_datalayers
```

表示创建一个名为 `hello_datalayers` 的数据库。

### 创建表

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

::: tips
**TIMESTAMP** 类型字段，默认值支持数值常量、RFC3339 / ISO8601 格式时间字符串以及时间戳函数`CURRENT_TIMESTAMP`，在写入数据时对于缺失的 **TIMESTAMP** 类型字段会自动设置为当前时间。
其他类型字段的默认值仅支持常量。
:::  

示例

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
