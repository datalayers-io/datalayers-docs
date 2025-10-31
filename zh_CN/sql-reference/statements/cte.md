# CTE（公共表表达式）参考指南 

## 概述
CTE（Common Table Expression，公共表表达式）是 SQL 中用于创建临时命名结果集的高级功能。它提高了查询的可读性、可维护性，并支持递归查询等复杂场景。

## 示例

```sql
WITH tmp AS
(
    SELECT * FROM t
)
SELECT * FROM tmp
```
