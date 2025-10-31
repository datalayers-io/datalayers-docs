# HAVING 语句参考指南

## 概述
HAVING 子句是 SQL 中用于对 GROUP BY 分组后的结果进行过滤的关键语句。它与 WHERE 子句的主要区别在于执行时机：WHERE 在分组前过滤单个记录，而 HAVING 在分组后过滤整个分组。

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
