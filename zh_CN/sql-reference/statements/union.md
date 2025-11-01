# Union 语句详解

## 功能概述
UNION 语句用来合并两个 SELECT 语句的结果，将两个结果集拼接称一个结果集。使用 UNION 时，每个 SELECT 语句必须具有相同数量的列，且对应列的数据类型必须互相兼容。

## 示例

```sql
-- 使用单个 Union
SELECT ts, value, flag FROM t1
UNION 
SELECT ts, value, flag FROM t2

-- 使用多个 Union
SELECT ts, value, flag FROM t1
UNION 
SELECT ts, value, flag FROM t2
UNION
SELECT ts, value, flag FROM t3
```
