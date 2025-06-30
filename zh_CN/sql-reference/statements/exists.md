# Exists Statement

EXISTS 语句用于判断查询语句是否有记录，如果有一条或多条记录存在返回 True，否则返回 False。

## 示例

```sql
SELECT * FROM t WHERE EXISTS (SELECT * FROM t WHERE flag = 0);
```
