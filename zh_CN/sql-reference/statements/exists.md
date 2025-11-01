# Exists 语句详解

## 功能概述
EXISTS 语句是 SQL 中用于检查子查询是否返回结果的逻辑运算符。它不关心返回的具体数据，只关心是否存在至少一行记录。EXISTS 通常与 WHERE 子句结合使用，用于基于相关数据的存在性进行条件过滤。

## 示例

```sql
SELECT * FROM t WHERE EXISTS (SELECT * FROM t WHERE flag = 0);
```
