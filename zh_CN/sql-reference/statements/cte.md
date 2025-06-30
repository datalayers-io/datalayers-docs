# CTE Statement

CTE（Common Table Expression，公共表表达式），用来将某个 SELECT 语句的查询结果存入到一个临时表中，在同一个查询的其他 SELECT 语句中重复使用。

## 示例

```sql
WITH tmp AS
(
    SELECT * FROM t
)
SELECT * FROM tmp
```
