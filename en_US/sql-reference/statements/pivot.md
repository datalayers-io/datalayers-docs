# PIVOT

PIVOT 是 SQL 中用于 “行转列” 的工具。它接受一个表或子查询作为输入，基于某个字段的不同取值，将这些取值 “转置” 为结果表中的多个列，同时对数据进行聚合填充。

通过这种方式，可以将原本多行展示的数据，转变为一行多列的形式，使数据结构更加清晰，便于对比和分析。

## 基本语法

```sql
SELECT ...
FROM <input>
   PIVOT (
     <aggregate_function>(<value_column>)
     FOR <pivot_column> IN (<pivot_value_1>, <pivot_value_2>, ...)
     [ DEFAULT ON NULL (<default_value>) ]
   )
```

* `<input>`：PIVOT 操作的数据来源，可以是一个表或子查询。
* `<aggregate_function>`：聚合函数，如 `SUM`、`MAX`、`AVG` 等，用于对行转列过程中重复值进行聚合处理。
* `<value_column>`：需要聚合的值所在的列。
* `<pivot_column>`：用于行转列的“参考列”，其不同值将成为输出结果中的列名。
* `<pivot_value_n>`：用于行转列的列值，每个值对应生成一个新列。必须是常量，不支持表达式。
* `DEFAULT ON NULL (<default_value>)`（可选）：用于将结果中的 `NULL` 值替换为指定默认值。

最终的结果表包含除了 `pivot_column` 和 `value_column` 外的所有列，以及根据 `pivot_value_n` 新增的列。

## 示例

下面通过一个示例表 `quarterly_sales` 来说明 PIVOT 的实际用法。

```sql
CREATE TABLE `quarterly_sales` (
  ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  empid INT32,
  amount INT32,
  quarter STRING,
  timestamp key(ts)
)
PARTITION BY HASH (amount) PARTITIONS 1;

INSERT INTO `quarterly_sales` (ts, empid, amount, quarter) VALUES
  ('2025-06-20 10:00:00Z', 1, 11000, '2023_Q1'),
  ('2025-06-20 10:00:00Z', 1, 400, '2023_Q1'),
  ('2025-06-20 10:00:00Z', 2, 4600, '2023_Q1'),
  ('2025-06-20 10:00:00Z', 2, 35000, '2023_Q1'),
  ('2025-06-20 10:00:00Z', 1, 5100, '2023_Q2'),
  ('2025-06-20 10:00:00Z', 1, 3000, '2023_Q2'),
  ('2025-06-20 10:00:00Z', 2, 200, '2023_Q2'),
  ('2025-06-20 10:00:00Z', 2, 90500, '2023_Q2'),
  ('2025-06-20 10:00:00Z', 1, 6000, '2023_Q3'),
  ('2025-06-20 10:00:00Z', 1, 5000, '2023_Q3'),
  ('2025-06-20 10:00:00Z', 2, 2500, '2023_Q3'),
  ('2025-06-20 10:00:00Z', 2, 9500, '2023_Q3'),
  ('2025-06-20 10:00:00Z', 3, 2800, '2023_Q3'),
  ('2025-06-20 10:00:00Z', 1, 8000, '2023_Q4'),
  ('2025-06-20 10:00:00Z', 1, 10000, '2023_Q4'),
  ('2025-06-20 10:00:00Z', 2, 800, '2023_Q4'),
  ('2025-06-20 10:00:00Z', 2, 4500, '2023_Q4'),
  ('2025-06-20 10:00:00Z', 3, 2700, '2023_Q4'),
  ('2025-06-20 10:00:00Z', 3, 16000, '2023_Q4'),
  ('2025-06-20 10:00:00Z', 3, 10200, '2023_Q4');
```

### 按照指定列值执行 PIVOT

将每位员工在各个季度的销售额进行汇总，并按季度展开为多列显示：

```sql
SELECT *
FROM quarterly_sales
  PIVOT (
    SUM(amount)
    FOR quarter IN ('2023_Q1', '2023_Q2', '2023_Q3')
  )
ORDER BY empid;
```

```
+---------------------------+-------+---------+---------+---------+
| ts                        | empid | 2023_Q1 | 2023_Q2 | 2023_Q3 |
+---------------------------+-------+---------+---------+---------+
| 2025-06-20T18:00:00+08:00 | 1     | 11400   | 8100    | 11000   |
| 2025-06-20T18:00:00+08:00 | 2     | 39600   | 90700   | 12000   |
| 2025-06-20T18:00:00+08:00 | 3     |         |         | 2800    |
+---------------------------+-------+---------+---------+---------+
```

在此例中，PIVOT 的执行流程如下：
  1. 根据 `'2023_Q1', '2023_Q2', '2023_Q3'` 在结果表新增对应的列。
  2. 除了 `quarter` 和 `amount` 以外，保留输入表中的其余列作为分组键，对数据进行分组。
  3. 对每个分组内的数据，根据 `quarter` 的不同取值，在 `amount` 上应用指定的聚合函数，将聚合结果填入对应的列中。

### 设置默认值

通过 `DEFAULT ON NULL`，可将结果中的 `NULL` 替换为默认值（例如 0）：

```sql
SELECT *
FROM quarterly_sales
  PIVOT (
    SUM(amount)
    FOR quarter IN ('2023_Q1', '2023_Q2', '2023_Q3')
    DEFAULT ON NULL (0)
  )
ORDER BY empid;
```

```
+---------------------------+-------+---------+---------+---------+
| ts                        | empid | 2023_Q1 | 2023_Q2 | 2023_Q3 |
+---------------------------+-------+---------+---------+---------+
| 2025-06-20T18:00:00+08:00 | 1     | 11400   | 8100    | 11000   |
| 2025-06-20T18:00:00+08:00 | 2     | 39600   | 90700   | 12000   |
| 2025-06-20T18:00:00+08:00 | 3     | 0       | 0       | 2800    |
+---------------------------+-------+---------+---------+---------+
```

### 重命名结果表

可以重命名结果表，使其更具可读性：

```sql
SELECT *
FROM quarterly_sales
  PIVOT (
    SUM(amount)
    FOR quarter IN ('2023_Q1', '2023_Q2', '2023_Q3', '2023_Q4')
  ) AS p (ts, employee, q1, q2, q3, q4)
ORDER BY employee;
```

```
+---------------------------+----------+-------+-------+-------+-------+
| ts                        | employee | q1    | q2    | q3    | q4    |
+---------------------------+----------+-------+-------+-------+-------+
| 2025-06-20T18:00:00+08:00 | 1        | 11400 | 8100  | 11000 | 18000 |
| 2025-06-20T18:00:00+08:00 | 2        | 39600 | 90700 | 12000 | 5300  |
| 2025-06-20T18:00:00+08:00 | 3        |       |       | 2800  | 28900 |
+---------------------------+----------+-------+-------+-------+-------+
```

---

### 使用子查询作为 PIVOT 的输入

您还可以通过子查询对数据进行预处理，再输入 PIVOT。

```sql
SELECT *
FROM (
  SELECT empid, amount, quarter
  FROM quarterly_sales
  WHERE amount > 1000
) AS filtered_sales
  PIVOT (
    SUM(amount)
    FOR quarter IN ('2023_Q1', '2023_Q2', '2023_Q3')
  )
ORDER BY empid;
```

```
+-------+---------+---------+---------+
| empid | 2023_Q1 | 2023_Q2 | 2023_Q3 |
+-------+---------+---------+---------+
| 1     | 11000   | 8100    | 11000   |
| 2     | 39600   | 90500   | 12000   |
| 3     |         |         | 2800    |
+-------+---------+---------+---------+
```