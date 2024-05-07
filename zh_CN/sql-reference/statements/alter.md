# ALTER
ALTER TABLE语句修改相关 SCHEMA 的定义。

## ADD COLUMN
ADD COLUMN子句可用于向表中添加指定类型的新列。
```SQL
-- 在表 `table_name` 中添加一个新列 `k``, 类型为 INT 
ALTER TABLE table_name ADD COLUMN k INT;
-- 在表 `table_name` 中添加 一个新列 `l`, 类型为 INT， 默认值为 10
ALTER TABLE table_name ADD COLUMN l INT DEFAULT 10;
```

## DROP COLUMN
DROP COLUMN子句可用于从表中删除列。
```SQL
-- 从 `table_name` 中删除列 k 
ALTER TABLE table_name DROP column k;
```
::: tip
列只有在没有任何索引依赖时才能被删除。如：PRIMARY KEY、UNIQUE等。
:::

## MODIFY OPTIONS
修改 Table Options。
```SQL
-- Modify options of a table
ALTER TABLE table_name MODIFY OPTIONS ttl='10d',max_memtable_size=64M;
```

