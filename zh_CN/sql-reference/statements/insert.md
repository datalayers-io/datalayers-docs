---
title: "INSERT 语句参考指南"
description: "Datalayers INSERT 语句参考指南 - INSERT 语句是 SQL 中用于向数据库表插入新记录的核心操作。"
---
# INSERT 语句参考指南

## 概述

INSERT 语句是 SQL 中用于向数据库表插入新记录的核心操作。

Datalayers 当前支持两类常见写法：

- `INSERT INTO ... VALUES ...`：直接写入一行或多行字面量数据。适合直接写入单条或多条记录。
- `INSERT INTO ... SELECT ...`：将查询结果写入另一张表。适合做表到表的数据搬运、过滤和派生写入。

## 语法

```SQL
-- 指定列名写入数据
INSERT INTO table_name (column1, column2, column3, ...)
VALUES (value1, value2, value3, ...), (value1, value2, value3, ...), ...

-- 将查询结果写入目标表
INSERT INTO target_table
SELECT select_expr [, ...]
FROM source_table
[WHERE condition]
```

## 语法示例

```SQL
-- 指定列名写入数据
INSERT INTO sensor_info(sn, speed, temperature)
VALUES ('100', 22.12, 30.8), ('101', 34.12, 40.6), ('102', 56.12, 52.3);

-- 将 source 表中过滤后的查询结果写入 sink 表
INSERT INTO sink
SELECT *
FROM source
WHERE sid >= 2;

-- SELECT 部分可使用 Datalayers 支持的任意查询语法，包括 SQL hints
INSERT INTO sink
SELECT /*+ set_var(parallel_degree=1) */
  ts, sid, value
FROM source
WHERE sid BETWEEN 2 AND 10;
```

## 使用用例

下面示例展示如何先向源表写入测试数据，再通过 `INSERT INTO ... SELECT ...` 将满足条件的数据写入目标表：

```SQL
CREATE TABLE `source` (
  ts TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  sid INT32 NOT NULL,
  value FLOAT,
  timestamp key(ts)
)
PARTITION BY HASH (sid) PARTITIONS 1
ENGINE=TimeSeries;

CREATE TABLE `sink` (
  ts TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  sid INT32 NOT NULL,
  value FLOAT,
  timestamp key(ts)
)
PARTITION BY HASH (sid) PARTITIONS 1
ENGINE=TimeSeries;

INSERT INTO source (ts, sid, value) VALUES
  (1732099812633, 1, 10.1),
  (1732099812634, 2, 20.2),
  (1732099812635, 3, 30.3);

INSERT INTO sink
SELECT *
FROM source
WHERE sid >= 2;

SELECT sid, value FROM sink;
```

执行结果会将 `source` 中 `sid >= 2` 的记录写入 `sink`。

## 从表函数写入

`INSERT INTO ... SELECT ...` 可以使用[表函数](../table-functions.md)生成数据行。表函数不是物理表，不需要预先创建；其输出的 `value` 列可以用于构造目标表的列值。

```sql
INSERT INTO sink
SELECT CAST(1000 + value AS TIMESTAMP(3)) AS ts,
       CAST(value AS INT) AS sid,
       CAST(value AS FLOAT) AS value
FROM generate_series(0, 9);
```

表函数也可以与时序表 Join 后再写入目标表：

```sql
INSERT INTO sink
SELECT CAST(g.value AS TIMESTAMP(3)) AS ts,
       CAST(s.sid AS INT) AS sid,
       s.value
FROM generate_series(0, 2) AS g
JOIN source AS s ON s.sid = g.value;
```

## 执行语义

`INSERT INTO ... SELECT ...` 是一次性的快照写入，不是持续同步任务。

这意味着：

- 系统只会将源表在请求发起时的当前数据快照写入目标表。
- 即使源表正在被持续写入，请求发起之后新增的数据也不会被自动同步到目标表。

## 当前版本限制

### 1. 目标表必须为时序表

实现层会校验：

- 目标表必须是 `TimeSeries` 表。
- `SELECT` 的源可以是 `TimeSeries` 表，也可以是表函数，或两者的 Join。
- 其他类型的表不能作为当前 `INSERT INTO ... SELECT ...` 的数据来源。

因此，`INSERT INTO ... SELECT ...` 当前适合用于时序表之间的数据搬运、过滤写入，以及从表函数生成并写入测试或派生数据。

### 2. 支持源表和目标表为同一张表

当前版本允许如下写法：

```sql
INSERT INTO sink
SELECT * FROM sink;
```

这会基于语句开始时的读取快照执行一次性复制，而不是持续订阅。
