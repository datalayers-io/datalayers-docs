# PIVOT

`PIVOT` transforms row values into columns. It takes a table, CTE, or subquery as input, groups rows by all columns except the pivot column and the aggregated value column, and produces one output column for each value listed in the `IN (...)` clause.

This is useful when you want to reshape long-form data into a wide result that is easier to compare.

## Syntax

```sql
SELECT ...
FROM <input>
PIVOT (
  <aggregate_function>(<value_column>)
  FOR <pivot_column> IN (<pivot_value_1>, <pivot_value_2>, ...)
  [ DEFAULT ON NULL (<default_value>) ]
) [ AS <alias> (<output_column_1>, <output_column_2>, ...) ]
```

- `<input>`: A base table, CTE, or subquery.
- `<aggregate_function>`: An aggregate such as `SUM`, `MAX`, `MIN`, `AVG`, or `COUNT`.
- `<value_column>`: The column passed to the aggregate function.
- `<pivot_column>`: The column whose values are expanded into output columns.
- `<pivot_value_n>`: A constant pivot value. Each listed value becomes one output column.
- `DEFAULT ON NULL (<default_value>)`: Replaces `NULL` results after pivoting.
- `AS <alias> (...)`: Renames the pivoted relation and its output columns.

## Notes

- The current implementation supports a single pivot column.
- The `IN (...)` list must be static. Dynamic pivot values are not supported.
- The output keeps all input columns except the pivot column and the aggregated value column.
- If multiple rows fall into the same group and pivot value, the aggregate function is applied to those rows.

## Example Data

```sql
CREATE TABLE quarterly_sales (
  ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  empid INT32,
  amount INT32,
  quarter STRING,
  timestamp key(ts)
)
PARTITION BY HASH (amount) PARTITIONS 1;

INSERT INTO quarterly_sales (ts, empid, amount, quarter) VALUES
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

## Basic Pivot

```sql
SELECT *
FROM quarterly_sales
PIVOT (
  SUM(amount)
  FOR quarter IN ('2023_Q1', '2023_Q2', '2023_Q3')
)
ORDER BY empid;
```

```text
+---------------------------+-------+---------+---------+---------+
| ts                        | empid | 2023_Q1 | 2023_Q2 | 2023_Q3 |
+---------------------------+-------+---------+---------+---------+
| 2025-06-20T18:00:00+08:00 | 1     | 11400   | 8100    | 11000   |
| 2025-06-20T18:00:00+08:00 | 2     | 39600   | 90700   | 12000   |
| 2025-06-20T18:00:00+08:00 | 3     |         |         | 2800    |
+---------------------------+-------+---------+---------+---------+
```

## Replace `NULL` Results

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

```text
+---------------------------+-------+---------+---------+---------+
| ts                        | empid | 2023_Q1 | 2023_Q2 | 2023_Q3 |
+---------------------------+-------+---------+---------+---------+
| 2025-06-20T18:00:00+08:00 | 1     | 11400   | 8100    | 11000   |
| 2025-06-20T18:00:00+08:00 | 2     | 39600   | 90700   | 12000   |
| 2025-06-20T18:00:00+08:00 | 3     | 0       | 0       | 2800    |
+---------------------------+-------+---------+---------+---------+
```

## Rename Output Columns

```sql
SELECT *
FROM quarterly_sales
PIVOT (
  SUM(amount)
  FOR quarter IN ('2023_Q1', '2023_Q2', '2023_Q3', '2023_Q4')
) AS p (ts, employee, q1, q2, q3, q4)
ORDER BY employee;
```

```text
+---------------------------+----------+-------+-------+-------+-------+
| ts                        | employee | q1    | q2    | q3    | q4    |
+---------------------------+----------+-------+-------+-------+-------+
| 2025-06-20T18:00:00+08:00 | 1        | 11400 | 8100  | 11000 | 18000 |
| 2025-06-20T18:00:00+08:00 | 2        | 39600 | 90700 | 12000 | 5300  |
| 2025-06-20T18:00:00+08:00 | 3        |       |       | 2800  | 28900 |
+---------------------------+----------+-------+-------+-------+-------+
```

## Use a Subquery or CTE as Input

You can preprocess data before pivoting it.

```sql
WITH filtered_sales AS (
  SELECT empid, amount, quarter
  FROM quarterly_sales
  WHERE amount > 1000
)
SELECT *
FROM filtered_sales
PIVOT (
  SUM(amount)
  FOR quarter IN ('2023_Q1', '2023_Q2', '2023_Q3')
)
ORDER BY empid;
```

```text
+-------+---------+---------+---------+
| empid | 2023_Q1 | 2023_Q2 | 2023_Q3 |
+-------+---------+---------+---------+
| 1     | 11000   | 8100    | 11000   |
| 2     | 39600   | 90500   | 12000   |
| 3     |         |         | 2800    |
+-------+---------+---------+---------+
```
