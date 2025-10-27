# EXPLAIN Statement

用于分析查询语句的执行计划。

## 语法

```sql
EXPLAIN [ANALYZE] [verbose] SELECT
```

```tips
ANALYZE: 执行语句并测量每个计划节点花费的时间与获取数据的记录数等。
```

## 示例

```sql
EXPLAIN ANALYZE SELECT * FROM products LIMIT 5 OFFSET 5;
```
