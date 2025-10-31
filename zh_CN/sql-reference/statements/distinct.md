# DISTINCT 语句参考指南

## 概述
DISTINCT 关键字是 SQL 中用于消除重复记录的核心语句，它可以从查询结果中返回唯一不同的值。DISTINCT 既可以用于简单的列去重，也可以与聚合函数结合实现复杂的去重统计。

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
