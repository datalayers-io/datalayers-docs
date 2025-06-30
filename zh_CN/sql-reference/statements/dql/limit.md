# Limit Statement

LIMIT 子句在 SQL 中用于限制由查询返回的记录数，这在处理大量数据时特别有用，因为它可以减少数据的传输量，提高查询响应时间。例如，从一个大的记录集中获取前 10 条记录以返回。

`LIMIT` 子句在 SQL 中用于限制由查询返回的记录数，这在处理大量数据时特别有用，因为它可以减少数据的传输量，提高查询响应时间。例如，从一个大的记录集中获取前 10 条记录以返回。`LIMIT` 子句经常与 `OFFSET` 子句一起使用，以指定从哪一行开始获取数据。这在实现分页功能时非常有用。

## 语法

```sql
SELECT column1, column2, ...
FROM table_name
LIMIT number;

--`start` 是从查询结果中开始返回记录的偏移量。第一条记录的偏移量是 0（而不是 1）。
SELECT column1, column2, ...
FROM table_name
LIMIT number OFFSET start;
```

## 示例

```sql
--跳过前 5 条记录，从第 6 条记录开始获取 5 条记录
SELECT * FROM products
LIMIT 5 OFFSET 5;
```

::: tip

- 使用 `LIMIT`（和 `OFFSET`）时，最好明确指定排序顺序，使用 `ORDER BY` 子句，以确保结果的一致性和预期性。
- 过度使用 `OFFSET` 可能会导致性能问题，特别是当偏移量非常大时，因为数据库需要读取所有位于偏移量之前的记录然后才能返回所需的结果集。
:::
