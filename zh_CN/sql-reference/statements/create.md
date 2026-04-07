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
