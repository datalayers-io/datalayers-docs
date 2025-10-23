# 高性能写入
本章节介绍在时序数据模型场景下如何将数据高效的写入到 Datalayers 中。在数据写入过程中，以下相关因素将影响数据写入的性能：


## 批量写入
在数据写入时，每次请求携带的数据量越大写入效率越高（注：每次请求batch数量建议控制在8000以下，以获取最佳性能）。
### SQL 示例
```SQL
-- CREATE TABLE sx1 (
-- ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
-- sid INT32,
-- temp REAL,
-- timestamp KEY (ts))
-- PARTITION BY HASH(sid) PARTITIONS 8
-- ENGINE=TimeSeries;

insert into sx1 (sid, value) values (1, 26.3),(2,23.4),(3, 26.6)......
```

### 行协议写入示例
```shell
curl -i -XPOST "http://127.0.0.1:8361/write?db=db_name&u=admin&p=public&precision=ns" -d 'weather,location=us-midwest temperature=82 1699429527\nweather,location=us-midwest temperature=82 1699429528
```

:::tip
无论是使用 SQL 写入还 行协议 写入，在每一次请求中携带更多的数据，将获得更好的写入性能。
:::

## 并发写入
在服务器资源足够的情况下，更高的并发（连接）会带来更好的写入性能。

## 传输协议
Datalayers 支持`HTTP`、`gRPC` 两种协议来进行交互，gRPC 的性能优于 HTTP。

## Prepared Statement
预处理语句是数据库系统中用于预编译 SQL 语句的一种机制，它在提升查询性能和安全性方面发挥着重要作用。

当使用预处理语句时，Datalayers会预先编译 SQL 语句并将其存储在一个准备好的状态中。在后续执行该语句时，Datalayers可以直接使用已编译的版本，从而避免重复编译。这种机制不仅绕过了 SQL 解析器，加速了单条 SQL 的执行，更重要的是，它显著降低了 CPU 负载，释放了系统资源，这是Datalayers其他优化点能够生效的前提与保证。

同时，数据库系统可以在执行 SQL 语句之前进行语法检查、语义分析和优化，进一步提高查询的执行效率。

在 Datalayers 中，Prepared Statement 目前支持Insert 与 Query，核心是通过`?`作为占位符，随后对占位符进行参数绑定，以达到绕过 SQL 解析的效果。

在Insert中，首先通过带有占位符的语句开启Prepared Statement，随后通过RecordBatch的形式来绑定参数，完成执行，需要注意：
- 为保证高效执行，Insert 中在values部分只支持单行的形式，而最终生成的Insert batch大小取决于 参数绑定时RecordBatch 中的行数
- 进行参数绑定时，每一行的列数必须严格相等，同时需和占位符数量相等且类型匹配

具体语法如下：

```SQL
-- CREATE TABLE sx1 (
-- ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
-- sid INT32 ,
-- value INT32 DEFAULT 10,
-- timestamp KEY (ts))
-- PARTITION BY HASH(sid) PARTITIONS 8
-- ENGINE=TimeSeries;

insert into sx1 (sid) values (?)

```
```Rust
// Use RecordBatch to bind parameters: 

let schema = Arc::new(Schema::new(vec![Field::new("sid", DataType::Int32, false)]));
// int32 array
let array = Int32Array::from(vec![1]);
let columns = vec![Arc::new(array) as Arc<dyn Array>];
let batch = RecordBatch::try_new(schema, columns).unwrap();

```

## Table Options
在时序数据模型场景，合理设置 table options 有利于提升写的性能。

### Partition 数量
在创建 table 时，可设置更多 partition 的数量，以提升系统写的性能。

示例： 
```SQL
CREATE TABLE sx1 (
ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
sid INT32 ,
value INT32 DEFAULT 10,
timestamp KEY (ts))
PARTITION BY HASH(sid) PARTITIONS 8
ENGINE=TimeSeries;
```
### Memtable size
在时序模型中，数据首先被写入到内存中（即：memtable），当内存中数据达到设置的阈值的一半时（即：memtable_size），将会触发落盘的行为，将内存中的数据转存到持久中。后台线程再根据策略，对落盘的文件进行合并、整理，如果 memtable size 设置较小，会导致频繁落盘、compact，从而影响读写性能。

示例： 
```SQL
CREATE TABLE sx1 (
ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
sid INT32 ,
value INT32 DEFAULT 10,
timestamp KEY (ts))
PARTITION BY HASH(sid) PARTITIONS 8
ENGINE=TimeSeries
WITH(memtable_size=512MB)
```
