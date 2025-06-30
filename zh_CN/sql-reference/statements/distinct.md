# DISTINCT Statement

`DISTINCT` 关键字在 SQL 中用于返回唯一不同的值。当你从一个数据库表中选择列时，可能会有重复的值。如果你只想列出不同（唯一的）值，可以使用 `DISTINCT` 关键字。

另一方面，`DISTINCT` 也可以结合聚合函数使用，在聚合时忽略重复的值。

## 语法

对查询结果进行去重：

```sql
SELECT DISTINCT column1, column2, ...
FROM table_name;
```

`column1`, `column2`, ... 表示想从 `table_name` 表中选择的列，且结果集将不包含重复的行。

对聚合的数据进行去重：

```sql
SELECT aggregate_function(DISTINCT column) FROM table_name;
```

## 示例

```sql
-- 对查询结果进行去重
SELECT DISTINCT department FROM employees;

-- 对聚合的数据进行去重
SELECT count(distinct department) FROM employees;
```
