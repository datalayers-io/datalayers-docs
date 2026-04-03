---
title: "UNPIVOT 语句详解"
description: "Datalayers UNPIVOT 语句详解，介绍 UNPIVOT 的语法、NULL 处理和典型示例。"
---
# UNPIVOT 语句详解

## 功能概述

`UNPIVOT` 用于将列数据转成行数据。它适合把宽表结果恢复成长表结果，保留未参与展开的列，并把多个来源列收敛成两列：

- 一列保存来源列的名称或别名
- 一列保存来源列的值

这常用于后续过滤、聚合、绘图或统一处理不同指标列。

## 基本语法

```sql
SELECT ...
FROM <input>
UNPIVOT [ INCLUDE NULLS | EXCLUDE NULLS ] (
  <value_column>
  FOR <name_column> IN (
    <source_column_1> [ AS <label_1> ],
    <source_column_2> [ AS <label_2> ],
    ...
  )
) [ AS <alias> ]
```

- `<input>`：输入数据，可以是基础表、CTE 或子查询。
- `<value_column>`：输出值列，用于保存原始列值。
- `<name_column>`：输出名称列，用于保存来源列标签。
- `<source_column_n>`：需要展开为行的来源列。
- `AS <label_n>`：给来源列指定写入 `<name_column>` 的标签。
- `EXCLUDE NULLS`：过滤掉值为 `NULL` 的行，默认行为。
- `INCLUDE NULLS`：保留值为 `NULL` 的行。

## 注意事项

- `IN (...)` 中未列出的列会原样保留在输出中。
- 如果需要完整保留所有来源列对应的行，请使用 `INCLUDE NULLS`。
- `UNPIVOT` 可以和过滤、JOIN、CTE、子查询一起使用。

## 示例数据

```sql
CREATE TABLE wide_sales (
  ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  region STRING,
  q1 INT32,
  q2 INT32,
  q3 INT32,
  timestamp key(ts)
)
PARTITION BY HASH (region) PARTITIONS 1;

INSERT INTO wide_sales (ts, region, q1, q2, q3) VALUES
  ('2024-09-01 10:00:00Z', 'North', 1000, 1500, NULL),
  ('2024-09-01 10:00:00Z', 'South', 1200, 1300, 1400);
```

## 基础用法

```sql
SELECT *
FROM wide_sales
UNPIVOT (
  sales FOR quarter IN (q1 AS 'Q1', q2 AS 'Q2', q3 AS 'Q3')
) AS u
ORDER BY quarter, region;
```

```plaintext
+----------------------+--------+---------+-------+
| ts                   | region | quarter | sales |
+----------------------+--------+---------+-------+
| 2024-09-01T10:00:00Z | North  | Q1      | 1000  |
| 2024-09-01T10:00:00Z | South  | Q1      | 1200  |
| 2024-09-01T10:00:00Z | North  | Q2      | 1500  |
| 2024-09-01T10:00:00Z | South  | Q2      | 1300  |
| 2024-09-01T10:00:00Z | South  | Q3      | 1400  |
+----------------------+--------+---------+-------+
```

## 保留 `NULL` 值

```sql
SELECT *
FROM wide_sales
UNPIVOT INCLUDE NULLS (
  sales FOR quarter IN (q1 AS 'Q1', q2 AS 'Q2', q3 AS 'Q3')
) AS u
ORDER BY quarter, region;
```

```plaintext
+----------------------+--------+---------+-------+
| ts                   | region | quarter | sales |
+----------------------+--------+---------+-------+
| 2024-09-01T10:00:00Z | North  | Q1      | 1000  |
| 2024-09-01T10:00:00Z | South  | Q1      | 1200  |
| 2024-09-01T10:00:00Z | North  | Q2      | 1500  |
| 2024-09-01T10:00:00Z | South  | Q2      | 1300  |
| 2024-09-01T10:00:00Z | North  | Q3      |       |
| 2024-09-01T10:00:00Z | South  | Q3      | 1400  |
+----------------------+--------+---------+-------+
```

## 对展开后的结果继续过滤

```sql
SELECT region, quarter, sales
FROM wide_sales
UNPIVOT (
  sales FOR quarter IN (q1 AS 'Q1', q2 AS 'Q2', q3 AS 'Q3')
) AS u
WHERE quarter = 'Q2'
ORDER BY region;
```

```plaintext
+--------+---------+-------+
| region | quarter | sales |
+--------+---------+-------+
| North  | Q2      | 1500  |
| South  | Q2      | 1300  |
+--------+---------+-------+
```
