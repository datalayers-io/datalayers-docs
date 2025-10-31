# CASE 语句参考指南

## 概述
CASE 语句是 SQL 中用于实现条件逻辑的核心功能，类似于编程语言中的 IF-THEN-ELSE 结构。它允许根据条件表达式返回不同的值，广泛应用于数据转换、分类计算和条件聚合等场景。


## 语法

```sql
CASE
  WHEN condition1 THEN result1
  WHEN condition2 THEN result2
  ...
  ELSE result
END
```

通过 `WHEN condition THEN result` 可以将满足给定条件的行转换为给定的值。使用 `ELSE` 可以指定默认值。

## 示例

CASE 语句可以在 SELECT、WHERE、GROUP BY、ORDER BY 等多个语句中使用。

### SELECT 语句中的 CASE

```sql
-- 根据 value 列的取值返回不同的值
SELECT
  CASE 
    WHEN value < 100 THEN 1
    WHEN value > 100 and value <= 200 THEN 2
    ELSE 3
  END
FROM t

-- 对 CASE 语句返回的值进行聚合
SELECT
  SUM(CASE WHEN value < 100 THEN 1 ELSE 0 END)
FROM t
```

### WHERE/HAVING 语句中的 CASE

```sql
-- WHERE 语句中使用 CASE
SELECT * FROM t
WHERE flag = (CASE WHEN value < 100 THEN 1 ELSE 0 END)

-- HAVING 语句中使用 CASE
SELECT sum(flag) FROM t
GROUP BY flag HAVING flag = (CASE WHEN value < 100 THEN 1 ELSE 0 END)
```

### GROUP BY 语句中的 CASE

```sql
SELECT
  sum(flag),
  CASE WHEN value < 100 THEN 1 ELSE 0 AS v
FROM t
GROUP BY v;
```

### ORDER BY 语句中的 CASE

```sql
SELECT * FROM t 
ORDER BY CASE WHEN value < 100 THEN 1 ELSE 0 END
```
