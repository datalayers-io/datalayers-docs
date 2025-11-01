# WHERE 子句参考指南

## 概述
WHERE 子句是 SQL 查询中用于过滤记录的核心组件，它通过指定条件表达式来限制查询结果集中包含的行。正确使用 WHERE 子句可以显著提高查询效率和结果准确性。

`WHERE` 子句可以与比较运算符（如 `=`, `<>`, `>`, `<`, `>=`, `<=`）、逻辑运算符（如 `AND`, `OR`, `NOT`）以及其他函数（如 `BETWEEN`, `IN`, `LIKE`, `IS NULL`）一起使用，以构建复杂的条件表达式。

## 语法
```sql
SELECT column1, column2, ...
FROM table_name
WHERE condition;
```

**示例**

```sql
-- 选择 `employees` 表中 `last_name` 为 'doe' 的所有记录
SELECT * FROM employees
WHERE last_name = 'doe';

-- 选择 `employees` 表中 `salary` 大于 50000 且 `department` 为 'IT' 的所有记录
SELECT * FROM employees
WHERE salary > 50000 AND department = 'IT';

-- 选择 `employees` 表中 `ts` 在 2020-01-01 至 2020-12-31 之间的所有记录
SELECT * FROM employees
WHERE ts BETWEEN '2020-01-01' AND '2020-12-31';

```
