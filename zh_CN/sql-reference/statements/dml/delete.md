# DELETE Statement

DELETE 语句用于从表中删除数据。

## 语法

```SQL
-- 删除满足条件的数据
DELETE FROM table_name WHERE expression
```

## 示例

```SQL
-- 删除表 t 中满足 `value > 100` 的数据
DELETE FROM t WHERE value > 100
```
