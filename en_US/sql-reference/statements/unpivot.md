# UNPIVOT

`UNPIVOT` transforms columns into rows. It takes a wide table as input, keeps the non-unpivoted columns, and converts a list of source columns into a pair of output columns: one column stores the source-column label and the other stores the source-column value.

This is useful when you want to normalize wide data for filtering, aggregation, or downstream processing.

## Syntax

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

- `<input>`: A base table, CTE, or subquery.
- `<value_column>`: The output column that stores values read from the source columns.
- `<name_column>`: The output column that stores the source-column label.
- `<source_column_n>`: A source column to be turned into rows.
- `AS <label_n>`: An optional label written into `<name_column>`.
- `EXCLUDE NULLS`: Drops rows whose unpivoted value is `NULL`. This is the default behavior.
- `INCLUDE NULLS`: Keeps rows whose unpivoted value is `NULL`.

## Notes

- All columns not listed in the `IN (...)` clause are preserved in the output.
- `UNPIVOT` is implemented as a relational rewrite, so it can be used with filters, joins, CTEs, and subqueries.
- Use `INCLUDE NULLS` when you need a complete row set even if some source columns are empty.

## Example Data

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

## Basic Unpivot

```sql
SELECT *
FROM wide_sales
UNPIVOT (
  sales FOR quarter IN (q1 AS 'Q1', q2 AS 'Q2', q3 AS 'Q3')
) AS u
ORDER BY quarter, region;
```

```text
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

## Keep `NULL` Values

```sql
SELECT *
FROM wide_sales
UNPIVOT INCLUDE NULLS (
  sales FOR quarter IN (q1 AS 'Q1', q2 AS 'Q2', q3 AS 'Q3')
) AS u
ORDER BY quarter, region;
```

```text
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

## Filter the Unpivoted Result

```sql
SELECT region, quarter, sales
FROM wide_sales
UNPIVOT (
  sales FOR quarter IN (q1 AS 'Q1', q2 AS 'Q2', q3 AS 'Q3')
) AS u
WHERE quarter = 'Q2'
ORDER BY region;
```

```text
+--------+---------+-------+
| region | quarter | sales |
+--------+---------+-------+
| North  | Q2      | 1500  |
| South  | Q2      | 1300  |
+--------+---------+-------+
```
