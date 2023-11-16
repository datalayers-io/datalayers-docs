# ALTER
ALTER TABLE语句修改相关 SCHEMA 的定义。





## ADD COLUMN
ADD COLUMN子句可用于向表中添加指定类型的新列。
```SQL
-- 在表 `table_name` 中添加一个新列 `k``, 类型为 INTEGER 
ALTER TABLE table_name ADD COLUMN k INTEGER;
-- 在表 `table_name` 中添加 一个新列 `l`, 类型为 INTEGER， 默认值为 10
ALTER TABLE table_name ADD COLUMN l INTEGER DEFAULT 10;
```

## DROP COLUMN
DROP COLUMN子句可用于从表中删除列。
```SQL
-- 从 `table_name` 中删除列 k 
ALTER TABLE table_name DROP k;
```
::: tip
列只有在没有任何索引依赖时才能被删除。如：PRIMARY KEY、UNIQUE等。
:::

## RENAME COLUMN
对表中的列重命名。
```SQL
-- rename a column of a table
ALTER TABLE table_name RENAME i TO j;
ALTER TABLE table_name RENAME COLUMN j TO k;
```

## RENAME TABLE
对表进行重命名
```SQL
-- rename a table
ALTER TABLE table_name RENAME TO new_table_name;
```

## ALTER TYPE
暂不支持

## SET/DROP DEFAULT
暂不支持