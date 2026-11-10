---
title: "表函数"
description: "Datalayers 表函数 - 在 FROM 子句中即时生成数据行，支持 generate_series 和 range。"
---
# 表函数

## 功能概述

表函数（Table Function）在查询的 `FROM` 子句中即时生成一组数据行。它不依赖已创建的物理表，适合构造测试数据、补全序号或时间序列，以及在不写入临时表的情况下完成查询和派生写入。

Datalayers 当前提供以下两个表函数：

- `generate_series`：生成包含结束值的序列。
- `range`：生成不包含结束值的序列。

## generate_series

`generate_series` 生成从 `start` 到 `end` 的序列，并包含 `end`。输出列名为 `value`。

### generate_series 参数形式

| 调用形式 | 参数个数 | 默认值 | 结束边界 |
| --- | --- | --- | --- |
| `generate_series(end)` | 1 | `start = 0`，`step = 1` | 包含 `end` |
| `generate_series(start, end)` | 2 | `step = 1` | 包含 `end` |
| `generate_series(start, end, step)` | 3 | 无 | 包含 `end` |
| `generate_series(start_timestamp, end_timestamp, step_interval)` | 3 | 无 | 包含 `end_timestamp` |
| `generate_series(start_date, end_date, step_interval)` | 3 | 无 | 包含 `end_date` |

### generate_series 数据类型与输出

| 输入形态 | 参数要求 | 输出 `value` 类型 |
| --- | --- | --- |
| 整数 | `start`、`end`、`step` 均为 `INT64` | `INT64` |
| 时间戳 | 必须传入 3 个参数：`TIMESTAMP_NS` 起点、`TIMESTAMP_NS` 终点、`INTERVAL` 步长 | `TIMESTAMP_NS`，时区沿用起点 |
| 日期 | 必须传入 3 个参数：`DATE` 起点、`DATE` 终点、`INTERVAL` 步长 | `TIMESTAMP_NS`，无时区 |

### generate_series 限制

- 只支持整数、时间戳和日期三类输入，不支持浮点数、`DECIMAL`、字符串等其他类型。
- 整数形式支持 1 到 3 个参数；时间戳和日期形式必须严格传入 3 个参数。
- 同一序列的起止值必须属于同一种类型，不能混用整数、时间戳和日期。
- 时间戳参数按纳秒精度处理。时间戳和日期形式中，步长必须是合法的 `INTERVAL` 且不能为 `0`；整数形式中，`step` 不能为 `0`。
- 日期形式会先将 `DATE` 转换为纳秒时间戳。超出纳秒时间戳可表示范围（约 1677-09-21 至 2262-04-11）的日期会报错。
- 整数形式的 `step` 为负数时生成降序序列；时间戳和日期形式的 `INTERVAL` 为负值时可生成逆序序列。
- 当生成方向与步长方向不一致，或起止范围为空时，返回空结果。
- 整数形式中任一参数为 `NULL` 时返回空结果；时间戳和日期形式中，终点或步长为 `NULL` 时返回空结果。
- 参数必须是规划期可化简的常量表达式，不能引用表中的列。

### generate_series 示例

生成整数序列，包含结束值：

```sql
SELECT * FROM generate_series(1, 5);
```

结果：

```text
+-------+
| value |
+-------+
| 1     |
| 2     |
| 3     |
| 4     |
| 5     |
+-------+
```

只指定结束值时，`generate_series(6)` 返回 `0` 到 `6`，共 7 行：

```sql
SELECT * FROM generate_series(6);
```

使用负数步长生成降序序列：

```sql
SELECT * FROM generate_series(6, -1, -2);
```

结果为 `6`、`4`、`2`、`0`。

按分钟生成时间戳序列：

```sql
SELECT * FROM generate_series(
  TIMESTAMP '2024-01-01 00:00:00',
  TIMESTAMP '2024-01-01 00:03:00',
  INTERVAL '1 minute'
);
```

结果为 `00:00:00`、`00:01:00`、`00:02:00` 和 `00:03:00`。

按天生成日期序列，输出为纳秒时间戳：

```sql
SELECT * FROM generate_series(
  DATE '2024-01-01',
  DATE '2024-01-03',
  INTERVAL '1 day'
);
```

结果为 `2024-01-01 00:00:00`、`2024-01-02 00:00:00` 和 `2024-01-03 00:00:00`。

`generate_series` 可以与聚合、过滤、排序、CTE 和 Join 组合使用：

```sql
-- 聚合
SELECT sum(value) FROM generate_series(1, 5);

-- 过滤和排序
SELECT value
FROM generate_series(1, 100)
WHERE value % 10 = 0
ORDER BY value;

-- CTE
WITH s AS (SELECT value FROM generate_series(1, 5))
SELECT sum(value) FROM s;
```

将 `generate_series` 生成的数据写入时序表：

```sql
CREATE TABLE gen_sink (
  ts TIMESTAMP(3) NOT NULL,
  sid INT32,
  val INT64,
  timestamp KEY (ts)
)
PARTITION BY HASH(sid) PARTITIONS 1
ENGINE=TimeSeries;

INSERT INTO gen_sink
SELECT CAST(1000 + value AS TIMESTAMP(3)) AS ts,
       CAST(value AS INT) AS sid,
       value AS val
FROM generate_series(0, 9);

SELECT count(*) FROM gen_sink;
```

## range

`range` 生成从 `start` 开始、到 `end` 结束的序列，包含 `start`，但不包含 `end`。输出列名为 `value`。

### range 参数形式

| 调用形式 | 参数个数 | 默认值 | 结束边界 |
| --- | --- | --- | --- |
| `range(end)` | 1 | `start = 0`，`step = 1` | 不包含 `end` |
| `range(start, end)` | 2 | `step = 1` | 不包含 `end` |
| `range(start, end, step)` | 3 | 无 | 不包含 `end` |
| `range(start_timestamp, end_timestamp, step_interval)` | 3 | 无 | 不包含 `end_timestamp` |
| `range(start_date, end_date, step_interval)` | 3 | 无 | 不包含 `end_date` |

### range 数据类型与输出

| 输入形态 | 参数要求 | 输出 `value` 类型 |
| --- | --- | --- |
| 整数 | `start`、`end`、`step` 均为 `INT64` | `INT64` |
| 时间戳 | 必须传入 3 个参数：`TIMESTAMP_NS` 起点、`TIMESTAMP_NS` 终点、`INTERVAL` 步长 | `TIMESTAMP_NS`，时区沿用起点 |
| 日期 | 必须传入 3 个参数：`DATE` 起点、`DATE` 终点、`INTERVAL` 步长 | `TIMESTAMP_NS`，无时区 |

### range 限制

- 只支持整数、时间戳和日期三类输入，不支持浮点数、`DECIMAL`、字符串等其他类型。
- 整数形式支持 1 到 3 个参数；时间戳和日期形式必须严格传入 3 个参数。
- 同一序列的起止值必须属于同一种类型，不能混用整数、时间戳和日期。
- 时间戳参数按纳秒精度处理。时间戳和日期形式中，步长必须是合法的 `INTERVAL` 且不能为 `0`；整数形式中，`step` 不能为 `0`。
- 日期形式会先将 `DATE` 转换为纳秒时间戳。超出纳秒时间戳可表示范围（约 1677-09-21 至 2262-04-11）的日期会报错。
- 整数形式的 `step` 为负数时生成降序序列；时间戳和日期形式的 `INTERVAL` 为负值时可生成逆序序列。
- 当生成方向与步长方向不一致，或起止范围为空时，返回空结果。
- 整数形式中任一参数为 `NULL` 时返回空结果；时间戳和日期形式中，终点或步长为 `NULL` 时返回空结果。
- 参数必须是规划期可化简的常量表达式，不能引用表中的列。

### range 示例

生成整数序列，不包含结束值：

```sql
SELECT * FROM range(1, 5);
```

结果：

```text
+-------+
| value |
+-------+
| 1     |
| 2     |
| 3     |
| 4     |
+-------+
```

只指定结束值时，`range(5)` 返回 `0` 到 `4`，共 5 行：

```sql
SELECT * FROM range(5);
```

使用负数步长生成降序序列：

```sql
SELECT * FROM range(6, 0, -2);
```

结果为 `6`、`4`、`2`。

按分钟生成时间戳序列，不包含结束时间：

```sql
SELECT * FROM range(
  TIMESTAMP '2024-01-01 00:00:00',
  TIMESTAMP '2024-01-01 00:03:00',
  INTERVAL '1 minute'
);
```

结果为 `00:00:00`、`00:01:00` 和 `00:02:00`。

按天生成日期序列，不包含结束日期：

```sql
SELECT * FROM range(
  DATE '2024-01-01',
  DATE '2024-01-03',
  INTERVAL '1 day'
);
```

结果为 `2024-01-01 00:00:00` 和 `2024-01-02 00:00:00`。

`range` 可以与聚合、过滤、排序、CTE 和 Join 组合使用：

```sql
-- 聚合
SELECT sum(value) FROM range(1, 5);

-- 过滤和排序
SELECT value
FROM range(1, 100)
WHERE value % 10 = 0
ORDER BY value;

-- CTE
WITH s AS (SELECT value FROM range(1, 5))
SELECT sum(value) FROM s;
```

将 `range` 生成的数据写入时序表：

```sql
CREATE TABLE range_sink (
  ts TIMESTAMP(3) NOT NULL,
  sid INT32,
  val INT64,
  timestamp KEY (ts)
)
PARTITION BY HASH(sid) PARTITIONS 1
ENGINE=TimeSeries;

INSERT INTO range_sink
SELECT CAST(1000 + value AS TIMESTAMP(3)) AS ts,
       CAST(value AS INT) AS sid,
       value AS val
FROM range(0, 10);

SELECT count(*) FROM range_sink;
```
