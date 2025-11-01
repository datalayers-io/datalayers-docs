# LIMIT 语句参考指南

## 概述
LIMIT 子句是 SQL 中用于控制查询结果集大小的关键语句，它通过限制返回的记录数量来优化查询性能和资源使用。结合 OFFSET 子句可以实现分页功能，是处理大数据集的重要工具。

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
