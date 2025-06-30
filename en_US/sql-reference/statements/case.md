# CASE Statement

CASE 语句类似于编程语言中的 IF-THEN-ELSE 结构，它使你能够根据条件返回特定值。

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
