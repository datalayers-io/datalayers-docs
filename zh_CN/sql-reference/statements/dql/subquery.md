# Subquery Statement

Subquery（子查询，或称嵌套查询），用于将查询结果用在一个查询中。目前支持在 SELECT、FROM、WHERE 等语句中使用子查询。

## 示例

```sql
-- SELECT 语句中的子查询
SELECT (SELECT flag FROM t) FROM t

-- FROM 语句中的子查询
SELECT * FROM (SELECT * FROM t where flag = 0)

-- WHERE 语句中的子查询
SELECT * FROM t WHERE flag > (SELECT avg(flag) FROM t)
```
