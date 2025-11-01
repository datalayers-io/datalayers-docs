# Subquery 语句详解

## 功能概述
子查询（Subquery）是 SQL 中嵌套在其他查询内部的查询，允许将一个查询的结果作为另一个查询的条件、列或数据源。子查询提供了强大的数据关联和分析能力，是复杂查询的核心工具。

## 示例

```sql
-- SELECT 语句中的子查询
SELECT (SELECT flag FROM t) FROM t

-- FROM 语句中的子查询
SELECT * FROM (SELECT * FROM t where flag = 0)

-- WHERE 语句中的子查询
SELECT * FROM t WHERE flag > (SELECT avg(flag) FROM t)
```
