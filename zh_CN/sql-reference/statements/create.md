---
title: "CREATE 语句参考指南"
description: "Datalayers CREATE 语句参考指南 - CREATE 语句是 SQL 中用于创建数据库对象（如数据库、表、索引等）的核心语句。通过 CREATE 语句，用户可以定义对象的结构、约束以及属性，是数据库设计和初始化的基础。"
---

# CREATE 语句参考指南

## 概述

CREATE 语句是 SQL 中用于创建数据库对象（如数据库、表、索引等）的核心语句。通过 CREATE 语句，用户可以定义对象的结构、约束以及属性，是数据库设计和初始化的基础。

::: tip
Datalayers 中数据库名、表名、字段名 **大小写敏感**
:::

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
    column_name data_type [column_constraint] [DEFAULT default_expr] [COMMENT 'text'],
    ...,
    [TIMESTAMP KEY(ts_column_name)],
    [PRIMARY KEY(col1 [, col2 ...])],
    [UNIQUE KEY [index_name] (col1 [, col2 ...])],
    [KEY [index_name] (col1 [, col2 ...])],
    [INVERTED INDEX [index_name] (string_column) [WITH (key=value, ...)]],
    [VECTOR INDEX [index_name] (vector_column) [WITH (key=value, ...)]]
)
[ENGINE = TimeSeries | Relational]
[PARTITION BY HASH(expr) [PARTITIONS partition_num]]
[WITH (key=value, ...)]
```

其中 `COMMENT 'text'` 用于为列添加注释。

当前版本主要支持两类表引擎：

- `ENGINE=TimeSeries`
- `ENGINE=Relational`

#### TimeSeries 表约束

对于时序（`TimeSeries`）引擎，当前实现要求：

- 至少有一个 `TIMESTAMP` 列，并通过 `TIMESTAMP KEY(...)` 指定时间列
- 必须指定 `PARTITION BY HASH(...)`
- 分区键必须是主键的一部分
- 时间列必须是主键的一部分
- 分区键和时间键都会被视为 `NOT NULL`
- 不支持 `AUTO_INCREMENT`

::: tip
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

#### Relational 表约束

对于关系表（`Relational`）引擎，当前实现支持：

- `PRIMARY KEY(...)`
- `UNIQUE KEY(...)` / `UNIQUE (...)`
- `KEY(...)`
- `AUTO_INCREMENT`

但不支持：

- `TIMESTAMP KEY(...)`
- `PARTITION BY HASH(...)`

示例：

```sql
CREATE TABLE rel_table_ok (
    id INT PRIMARY KEY,
    name STRING,
    value DOUBLE
) ENGINE=Relational;
```

### 创建 Source

`CREATE SOURCE` 用于定义一个流式输入对象。它描述外部数据源的字段、connector 和 format，但它本身不是一个表，无法接查询和写入。

```sql
CREATE SOURCE source_name (
    source_field,
    ...,
    [WATERMARK FOR event_time_column [AS expr]]
) WITH (
    connector='kafka|mqtt|http',
    format='json|csv|parquet',
    key='value',
    ...
)
```

其中 `source_field` 支持三种形式：

```sql
column_name data_type [NULL | NOT NULL] [COMMENT 'text']
column_name data_type METADATA FROM 'metadata_key'
column_name data_type AS expr
```

- 第一种是物理字段，直接从外部输入中读取。
- 第二种是元数据字段，从 connector 提供的元数据中提取。
- 第三种是计算列，基于前面定义的字段表达式计算得到。

当前版本对 source field 的列选项约束如下：

- 只有物理字段支持 `NULL` / `NOT NULL` / `COMMENT`
- 物理字段未显式声明可空性时，默认是 `NULL`
- 被 `WATERMARK FOR` 引用的物理字段会被隐式视为 `NOT NULL`，显式写成 `NULL` 会报错
- 元数据字段和计算列都不支持列选项
- 同一个 metadata key 不能被多个 source 字段重复引用

示例：

```sql
CREATE SOURCE src_kafka (
    ts TIMESTAMP(9) NOT NULL COMMENT 'event time',
    source_topic STRING METADATA FROM 'topic',
    value_label STRING AS source_topic,
    WATERMARK FOR ts AS ts - INTERVAL '5' SECOND
) WITH (
    connector='kafka',
    brokers='127.0.0.1:9092',
    topic='topic_stream_demo',
    offset='earliest',
    format='json'
);
```

说明：

- source 至少要定义一个字段
- `WITH (...)` 必填，且不能为空
- `CREATE SOURCE` 暂不支持 `IF NOT EXISTS`
- connector 相关选项依赖具体 connector，请参考 [Connector 配置说明](../../streaming/connectors.md)

#### Watermark

Watermark 用于声明 source 的事件时间语义。它由 `CREATE SOURCE` 中的 `WATERMARK FOR ...` 子句定义，系统会基于该表达式在运行时持续生成 watermark signal，并传递给下游算子。

如果只写 `WATERMARK FOR ts`，则默认等价于 `WATERMARK FOR ts AS ts`。如果写成 `AS ts - INTERVAL '5' SECOND`，则表示 watermark 相对事件时间延迟 5 秒推进。

约束如下：

- 一个 source 最多定义一个 watermark
- 事件时间列必须来自物理字段或元数据字段，不能是计算列
- 事件时间列会被视为非空列，显式声明为 `NULL` 会报错
- watermark 表达式只能基于前面定义的物理字段或元数据字段
- watermark 表达式结果类型必须是 `TIMESTAMP`

### 创建 Pipeline

`CREATE PIPELINE` 用于创建持续运行的流任务。pipeline 从一个 source 读取数据，执行实时计算，然后把结果写入一个已有的 sink table。

```sql
CREATE PIPELINE pipeline_name
SINK TO [database.]sink_table_name
AS
SELECT ...
```

示例：

```sql
CREATE PIPELINE p_kafka
SINK TO sink_t
AS
SELECT ts, sid, value
FROM src_kafka
WHERE value >= 2.0;
```

说明：

- `CREATE PIPELINE` 暂不支持 `IF NOT EXISTS`
- `AS` 后必须是 `SELECT` 语句
- 一个 pipeline 当前只能引用一个 source
- 当前支持的查询能力以投影、过滤为主
- 暂不支持 join、聚合、窗口、排序、limit、union、子查询等复杂语法
- sink table 必须已存在，且当前要求为 `TimeSeries` 表
- sink table 中没有默认值的非空列，必须由 pipeline 输出覆盖
- pipeline 输出列需要与 sink table 列按名称和类型兼容，必要时系统会尝试插入 cast
- 当前用户需要具备 source 的 `SELECT` 权限以及 sink table 的 `INSERT` 权限

### 建表时声明索引（INVERTED / VECTOR）

除了使用 `CREATE INDEX` 在建表后创建索引，Datalayers 也支持在 `CREATE TABLE` 的表约束中直接声明索引。

语法（片段）

```SQL
CREATE TABLE [IF NOT EXISTS] [database.]table_name (
    ...,
    timestamp key(ts_column),
    inverted index [index_name] (string_column) [with (key=value, ...)],
    vector index [index_name] (vector_column) [with (key=value, ...)]
)
PARTITION BY HASH(expr) PARTITIONS n
```

示例

```SQL
CREATE TABLE sx1(
    ts TIMESTAMP,
    sid INT32,
    message STRING,
    timestamp key(ts),
    inverted index idx_message (message) with (tokenizer=standard)
)
PARTITION BY HASH(sid) PARTITIONS 1;

CREATE TABLE sx2(
    ts TIMESTAMP,
    sid INT32,
    vec VECTOR(3),
    timestamp key(ts),
    vector index (vec)
)
PARTITION BY HASH(sid) PARTITIONS 1;
```

::: tip
索引创建语法见本文下方章节；索引刷新与删除请参考 [REFRESH 语句详解](./refresh.md) 与 [DROP 语句详解](./drop.md)。
:::

### CREATE INVERTED INDEX

作用

在字符串列上创建倒排索引，用于日志与文本场景的全文检索加速。

语法

```SQL
CREATE INVERTED INDEX [CONCURRENTLY] [IF NOT EXISTS] [index_name]
ON [database.]table_name (column_name)
[WITH (key=value, ...)]
```

选项

- `tokenizer`：分词器，`standard | chinese`，默认 `standard`
- `with_position`：是否保存词位置信息，`true | false`，默认 `false`
- `filters`：过滤器列表，使用 `,` 分隔，默认 `lowercase,english_stop`

`filters` 可选项说明：

| 过滤器 | 作用 | 适用场景 |
| --- | --- | --- |
| `lowercase` | 将英文 token 统一转为小写，减少大小写差异影响 | 英文日志或中英混合文本检索 |
| `english_stop` | 过滤英文停用词（如 `the`、`is`） | 需要降低英文高频虚词噪音 |
| `english_stemmer` | 对英文词做词干提取（如 `running` -> `run`） | 需要提升英文词形变化召回 |

`standard` 说明：`standard` 分词器基于空格和标点符号进行分词，适合英文文本。

示例

```SQL
CREATE INVERTED INDEX idx_message ON logs (message);

CREATE INVERTED INDEX IF NOT EXISTS idx_message ON logs (message);

CREATE INVERTED INDEX idx_message_cn ON logs (message)
WITH (tokenizer='chinese', filters='lowercase,english_stop', with_position='true');

CREATE INVERTED INDEX idx_message_std ON logs (message)
WITH (tokenizer='standard', filters='lowercase,english_stop,english_stemmer');
```

### CREATE VECTOR INDEX

作用

在向量列上创建向量索引，用于加速近似最近邻检索。

语法

```SQL
CREATE VECTOR INDEX [CONCURRENTLY] [IF NOT EXISTS] [index_name]
ON [database.]table_name (vector_column)
[WITH (key=value, ...)]
```

选项

- `type`：向量索引类型，如 `IVF_PQ`、`IVF_RQ`、`HNSW`、`HNSW_PQ` 等
- `distance`：距离函数，`l2 | cosine | dot`
- `num_cells`：IVF 类索引簇数量，默认 `32`
- `num_sub_vectors`：PQ 子向量个数，默认 `32`
- `num_bits`：PQ 编码位数，目前支持 `8`
- `max_level`：HNSW 最大层数，默认 `7`
- `m`：HNSW 每个节点最大邻居数，默认 `10`
- `ef_construction`：HNSW 构建候选邻居数，默认 `50`

示例

```SQL
CREATE VECTOR INDEX idx_embed ON logs (embed)
WITH (type=IVF_PQ, distance=L2);

CREATE VECTOR INDEX idx_embed_hnsw ON logs (embed)
WITH (type=HNSW, distance=cosine, max_level=7, m=10, ef_construction=50);
```
