# 高性能写入

本章节详细介绍在时序数据场景下实现数据高效写入 Datalayers 的最佳实践，涵盖影响写入性能的关键因素及优化策略。

## 批量写入

原则：单次请求数据量越大，写入效率越高。建议每批次数据量控制在8000条以内以获得最佳性能。

**通过 SQL 批量写入**：

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

**通过行协议批量写入**：

```shell
curl -i -XPOST "http://127.0.0.1:8361/write?db=db_name&u=admin&p=public&precision=ns" -d 'weather,location=us-midwest temperature=82 1699429527\nweather,location=us-midwest temperature=82 1699429528
```

:::tip
无论是使用 SQL 写入还 行协议 写入，在每一次请求中携带更多的数据，将获得更好的写入性能。
:::

## 并发写入

在服务器资源充足的情况下，适当增加并发连接数可显著提升整体写入吞吐量。建议根据实际硬件资源配置合理的并发度。

## 传输协议

- **gRPC协议**：性能更优，推荐在高吞吐量生产环境使用
- **HTTP协议**：适用于开发、测试或者受限环境

## Prepared Statement

预处理语句是数据库系统中用于预编译 SQL 语句的一种机制，它在提升查询性能和安全性方面发挥着重要作用。

当使用预处理语句时，Datalayers 会预先编译 SQL 语句并将其存储在一个准备好的状态中。在后续执行该语句时，Datalayers 可以直接使用已编译的版本，从而避免重复编译。这种机制不仅绕过了 SQL 解析器，加速了单条 SQL 的执行，更重要的是，它显著降低了 CPU 负载，释放了系统资源。

同时，数据库系统可以在执行 SQL 语句之前进行语法检查、语义分析和优化，进一步提高查询的执行效率。

在 Datalayers 中，Prepared Statement 目前支持Insert 与 Query，核心是通过`?`作为占位符，随后对占位符进行参数绑定，以达到绕过 SQL 解析的效果。

在 Insert 中，首先通过带有占位符的语句开启 Prepared Statement，随后通过 RecordBatch 的形式来绑定参数，完成执行，需要注意：

- 为保证高效执行，Insert 中在 values 部分只支持单行的形式，而最终生成的 Insert batch 大小取决于 参数绑定时 RecordBatch 中的行数
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

- 一般来说 1 个 partition 每秒可高达数十万点位的写入，因此根据实际场景需求来设置即可
- Partition 越多，会消耗越多的 CPU 与内存，建议 partition 数量不超过集群内所有节点的 CPU CORE 之和

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
