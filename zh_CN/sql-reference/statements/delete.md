# DELETE STATEMENT
DELETE 语句从 table-name 中删除符合条件的数据记录。


## DELETE FROM
```SQL
-- 从数据库中删除符合条件“id > 2”的行 
DELETE FROM talbe_name WHERE id > 2;
-- 删除表中所有的数据
DELETE FROM talbe_name;
```

如果 WHERE 子句不存在，则删除表中的所有记录。如果提供了 WHERE 子句，则只删除WHERE子句结果为`true`的记录。