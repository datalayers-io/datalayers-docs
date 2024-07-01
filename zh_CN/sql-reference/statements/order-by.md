# ORDER BY

`ORDER BY` 子句在 SQL 中用于根据一个或多个列对查询结果进行排序。默认情况下，`ORDER BY` 会按照升序（ASC）对记录进行排序，但也可以指定为降序（DESC）来对记录进行排序。这在需要根据某些字段来组织输出结果时非常有用。

`ORDER BY` 子句不仅可以用于基本的字段排序，还可以结合函数使用，例如对记录的计算结果进行排序。此外，可以指定多个列进行排序，SQL 会按照列在 `ORDER BY` 子句中出现的顺序来对结果集进行排序。

**语法**
```sql
SELECT column1, column2, ...
FROM table_name
ORDER BY column1 [ASC|DESC], column2 [ASC|DESC], ...;
```

**示例**

```sql
-- 按照 `last_name` 升序排序
SELECT * FROM employees
ORDER BY last_name ASC;

-- 首先按照 `country` 升序排序，然后在每个国家内部按照 `salary` 降序排序
SELECT * FROM employees
ORDER BY country ASC, salary DESC;
```

::: tip
- 当使用 `ORDER BY` 对结果进行排序时，如果未明确指定排序方向（ASC 或 DESC），则默认为升序排序。
- 在使用 `LIMIT` 子句限制返回的记录数量时，`ORDER BY` 对于确定哪些记录应该包含在结果集中非常关键。
- 对于大型数据集，排序操作可能会消耗较多的资源，因此应谨慎使用，尤其是在性能敏感的应用中。
:::
