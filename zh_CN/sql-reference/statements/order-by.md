# ORDER BY 语句参考指南

## 概述
ORDER BY 子句是 SQL 中用于对查询结果进行排序的关键语句，它允许根据一个或多个列或表达式对结果集进行升序或降序排列。ORDER BY 在数据分析、报表生成和分页查询中具有重要作用。

## 语法

```sql
SELECT column1, column2, ...
FROM table_name
ORDER BY column1 [ASC|DESC], column2 [ASC|DESC], ...;
```

## 示例

```sql
-- 按照 `last_name` 升序排序
SELECT * FROM employees
ORDER BY last_name ASC;

-- 首先按照 `country` 升序排序，然后在每个国家内部按照 `salary` 降序排序
SELECT * FROM employees
ORDER BY country ASC, salary DESC;
```
