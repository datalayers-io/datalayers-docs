
## DROP DATABASE
删除数据库中指定 `database_name` 中所有的表，然后删除该 `database_name`。  
**语法**
```SQL
DROP DATABASE [IF EXISTS] database_name
```
## DROP TABLE
删除指定的 `table_name`。  
**语法**
```SQL
DROP TABLE [IF EXISTS] [db.]table_name 
```

## DROP INDEX
```SQL
-- Remove the index title_idx.
DROP INDEX title_idx;
```