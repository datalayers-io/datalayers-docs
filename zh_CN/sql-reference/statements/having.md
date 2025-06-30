# HAVING Statement

`HAVING` 子句在 SQL 中用于在 `GROUP BY` 子句聚合后对结果集进行条件过滤。它与 `WHERE` 子句不同，`WHERE` 子句在数据分组前对个别记录进行过滤，而 `HAVING` 子句则是在数据已经被 `GROUP BY` 子句聚合之后，对这些分组的结果进行过滤。

`HAVING` 子句通常与聚合函数（如 `SUM`、`AVG`、`MAX`、`MIN`、`COUNT` 等）一起使用，用于指定筛选条件。

## 语法

```sql
SELECT column1, column2, AGGREGATE_FUNCTION(column3)
FROM table_name
WHERE condition1
GROUP BY column1, column2
HAVING condition2;
```

这里的 `AGGREGATE_FUNCTION` 可以是任何聚合函数，`condition1` 是 `WHERE` 子句中使用的筛选条件，而 `condition2` 是应用于聚合结果的筛选条件。

## 示例

```sql
SELECT customer_id, SUM(order_amount) AS total_amount
FROM orders
GROUP BY customer_id
HAVING SUM(order_amount) > 500;
```

这个查询会返回订单总额超过 500 的所有客户及其订单总额。

::: tip

- 如果 `GROUP BY` 子句存在的话, `HAVING` 子句必须跟在 `GROUP BY` 子句之后。
- 可以没有 `GROUP BY` 子句而使用 `HAVING` 子句，但这种情况下 `HAVING` 会作用于整个结果集，就像是对所有行的一个总体聚合条件。
- 如果同时使用了 `WHERE` 和 `HAVING` 子句，`WHERE` 子句会先过滤个别记录，然后 `GROUP BY` 会进行数据聚合，最后 `HAVING` 子句会对聚合后的数据进行过滤。
:::
