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

### 创建 Source

`CREATE SOURCE` 用于定义一个流式输入对象。它描述外部数据源的字段、connector 和 format，但它本身不是一个表，无法接查询和写入。

语法

```SQL
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

其中 `source_field` 支持三种写法：

```SQL
column_name data_type [NULL | NOT NULL] [COMMENT 'text']
column_name data_type METADATA FROM 'metadata_key'
column_name data_type AS expr
```

- 第一种是普通的 physical field，直接从消息 payload 中解码得到。
- 第二种是 metadata field，从 connector 读取的消息元信息中提取，常见的 metadata 包括 Kafka 的 topic、partition、offset，HTTP 的 header 等。`METADATA FROM` 的 key 取决于具体 connector，且 metadata 列类型必须与该 key 的类型完全一致。
- 第三种是 computed field，基于 physical field 和 metadata field 定义的计算。Computed field 只能基于 physical field 和 metadata field 定义，不能基于其他 computed field 定义。

当前版本对 source field 的列选项约束如下：

- 只有 physical field 允许指定列选项，且仅支持 `NULL`、`NOT NULL` 和 `COMMENT`
- 如果一个 physical field 没有显式指定 `NULL` 或 `NOT NULL`，则默认为 `NULL`
- 如果一个 physical field 被 watermark 声明为事件时间列，则该列会隐式被视为 `NOT NULL`。如果用户显式指定了 `NULL` 会报错
- metadata field 和 computed field 不支持列选项
- 同一个 metadata key 不能被多个 source 列重复引用

示例

```SQL
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

说明

- source 至少需要定义一个列。
- `WITH (...)` 为必填，且不能为空。
- `CREATE SOURCE` 暂不支持 `IF NOT EXISTS`。
- connector 配置项取决于具体 connector，详见 [Connectors 概述](../../streaming/connectors.md)。

#### Watermark

Watermark 用于声明 source 的事件时间语义。它由 `CREATE SOURCE` 中的 `WATERMARK FOR ...` 子句定义，系统会基于该表达式在运行时持续生成 watermark signal，并传递给下游算子。

最简单的写法是直接把某个时间列声明为事件时间列：`WATERMARK FOR ts`。也可以显式给出 watermark 表达式，例如 `WATERMARK FOR ts AS ts - INTERVAL '5' SECOND`，表示 watermark 信号比事件时间落后 5 秒。

当前版本的约束如下：

- 一个 source 至多定义一个 watermark
- `WATERMARK FOR <column>` 中的事件时间列必须来自 physical field 或 metadata field，不能是 computed field
- `WATERMARK FOR <column>` 中的事件时间列会被视为 non-nullable；显式指定 `NULL` 会报错
- Watermark 表达式也只能基于 physical field 或 metadata field 构建
- Watermark 表达式的结果类型必须是 `TIMESTAMP`

### 创建 Pipeline

`CREATE PIPELINE` 用于创建持续运行的流任务。pipeline 从一个 source
读取数据，执行实时计算，然后把结果写入一个已有的 sink table。

语法

```SQL
CREATE PIPELINE pipeline_name
SINK TO [database.]sink_table_name
AS
SELECT ...
```

示例

```SQL
CREATE PIPELINE p_kafka
SINK TO sink_t
AS
SELECT ts, sid, value
FROM src_kafka
WHERE value >= 2.0;
```

说明

- `CREATE PIPELINE` 暂不支持 `IF NOT EXISTS`。
- `AS` 后必须是 `SELECT` 查询。
- 当前一个 pipeline 只能引用一个 source。
- 当前仅支持投影与过滤，不支持 join、聚合、窗口、排序、limit、union、子查询等更复杂算子。
- sink table 必须已经存在，且必须是 TimeSeries 表。
- sink table 中无默认值的非空列必须出现在查询输出中。
- 查询输出列必须与 sink table 的列名和类型兼容；当类型可转换时，系统会自动补充必要的 cast。如果不兼容，则会报错。
- 执行 `CREATE PIPELINE` 时，当前用户需要对 source 具备 `SELECT` 权限，并对 sink table 具备 `INSERT` 权限。

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
