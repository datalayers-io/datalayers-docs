# CTE（公共表表达式）参考指南

## 概述

CTE（Common Table Expression，公共表表达式）是 SQL 中用于创建临时命名结果集的高级功能。在特定的场景下使用 CTE 可提高了查询性能，提升查询语句的可读性、可维护性。

## 使用方法

### 普通查询

```sql
WITH tmp AS
(
    SELECT * FROM t
)
SELECT * FROM tmp
```

### 递归查询

```sql
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 5
)
SELECT * FROM seq;
```
