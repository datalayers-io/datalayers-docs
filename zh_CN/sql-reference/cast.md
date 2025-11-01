# CAST 函数详解

## 功能概述
CAST 函数是 SQL 中用于数据类型转换的核心函数，可以将一个表达式的值转换为指定的目标数据类型。如果转换不可行，函数会抛出错误，确保数据转换的类型安全。

## 语法

```sql
CAST(expression AS data_type)
```

## 示例

```sql
SELECT CAST(1 AS BOOLEAN);
```
