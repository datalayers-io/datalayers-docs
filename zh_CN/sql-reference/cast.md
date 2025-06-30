# CAST Function

转换函数用来将表达式的值转换为给定的类型。如果转换不可行，则抛出错误。

## 语法

```sql
CAST(expression AS data_type)
```

## 示例

```sql
SELECT CAST(value AS FLOAT) FROM t
```
