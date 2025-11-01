# EXPLAIN 语句详解

## 功能概述
EXPLAIN 语句是 Datalayers 提供的强大查询分析工具，用于展示查询语句的执行计划。通过分析执行计划，用户可以深入了解查询的底层执行逻辑，识别性能瓶颈，并进行针对性的优化。

## 语法

```sql
EXPLAIN [ANALYZE] [verbose] SELECT
```

::: tip
ANALYZE: 执行语句并测量每个计划节点花费的时间与获取数据的记录数等。
:::

## 示例

```sql
EXPLAIN ANALYZE SELECT * FROM products LIMIT 5 OFFSET 5;
```
