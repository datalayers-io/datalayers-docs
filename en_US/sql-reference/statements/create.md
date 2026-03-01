
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

::: tip
针对非 **TIMESTAMP** 类型，默认值只支持常量设置。针对 **TIMESTAMP** 类型，默认值除了常量外还支持输出`CURRENT_TIMESTAMP`，在写入数据时如果没有给出时间戳值将会使用写入时间。
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

### Declare indexes in CREATE TABLE (INVERTED / VECTOR)

Besides creating indexes after table creation with `CREATE INDEX`, Datalayers also supports declaring indexes directly inside `CREATE TABLE` table constraints.

Syntax (fragment)

```SQL
CREATE TABLE [IF NOT EXISTS] [database.]table_name (
    ...,
    timestamp key(ts_column),
    inverted index [index_name] (string_column) [with (key=value, ...)],
    vector index [index_name] (vector_column) [with (key=value, ...)]
)
PARTITION BY HASH(expr) PARTITIONS n
```

Examples

```SQL
CREATE TABLE sx1(
    ts TIMESTAMP,
    sid INT32,
    message STRING,
    timestamp key(ts),
    inverted index idx_message (message) with (tokenizer=english)
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
Index creation syntax is documented below on this page; for index refresh and drop, see [REFRESH Statement](./refresh.md) and [DROP Statement](./drop.md).
:::

### CREATE INVERTED INDEX

Purpose

Creates an inverted index on a string column to accelerate full-text search for log and text workloads.

Syntax

```SQL
CREATE INVERTED INDEX [CONCURRENTLY] [IF NOT EXISTS] [index_name]
ON [database.]table_name (column_name)
[WITH (key=value, ...)]
```

Options

- `tokenizer`: tokenizer, `english | chinese`, default `english`
- `case_sensitive`: whether matching is case-sensitive, `true | false`, default `false`
- `with_position`: whether term positions are stored, `true | false`, default `false`

Examples

```SQL
CREATE INVERTED INDEX idx_message ON logs (message);

CREATE INVERTED INDEX IF NOT EXISTS idx_message ON logs (message);

CREATE INVERTED INDEX idx_message_cn ON logs (message)
WITH (tokenizer='chinese', case_sensitive='false', with_position='true');
```

### CREATE VECTOR INDEX

Purpose

Creates a vector index on a vector column to accelerate approximate nearest-neighbor search.

Syntax

```SQL
CREATE VECTOR INDEX [CONCURRENTLY] [IF NOT EXISTS] [index_name]
ON [database.]table_name (vector_column)
[WITH (key=value, ...)]
```

Options

- `type`: vector index type, such as `IVF_PQ`, `IVF_RQ`, `HNSW`, `HNSW_PQ`
- `distance`: distance function, `l2 | cosine | dot`
- `num_cells`: IVF cluster count, default `32`
- `num_sub_vectors`: PQ sub-vector count, default `32`
- `num_bits`: PQ code bits, currently supports `8`
- `max_level`: HNSW max level, default `7`
- `m`: HNSW max neighbors per node, default `10`
- `ef_construction`: HNSW construction candidate neighbors, default `50`

Examples

```SQL
CREATE VECTOR INDEX idx_embed ON logs (embed)
WITH (type=IVF_PQ, distance=L2);

CREATE VECTOR INDEX idx_embed_hnsw ON logs (embed)
WITH (type=HNSW, distance=cosine, max_level=7, m=10, ef_construction=50);
```
