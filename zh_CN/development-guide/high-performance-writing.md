# 高性能写入
本章节介绍如何将数据高效的写入到 Datalayers 中。


## 协议相关
todo

### Prepared Statement
预处理语句是数据库系统中用于预编译 SQL 语句的一种机制，它在提升查询性能和安全性方面发挥着重要作用。

当使用预处理语句时，Datalayers会预先编译 SQL 语句并将其存储在一个准备好的状态中。在后续执行该语句时，Datalayers可以直接使用已编译的版本，从而避免重复编译。这种机制不仅绕过了 SQL 解析器，加速了单条 SQL 的执行，更重要的是，它显著降低了 CPU 负载，释放了系统资源，这是Datalayers其他优化点能够生效的前提与保证。

同时，数据库系统可以在执行 SQL 语句之前进行语法检查、语义分析和优化，进一步提高查询的执行效率。

#### 语法
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

## 配置相关
todo