
## DROP DATABASE
删除指定的 `database`, 如果 `database` 不为空（database下有 table），则不可删除。  
**语法**
```SQL
DROP DATABASE [IF EXISTS] database_name
```
## DROP TABLE
删除指定的table，执行该指令将删除指定table下的所有数据，请谨慎操作。  
**语法**
```SQL
DROP TABLE [IF EXISTS] [db.]table_name 
```

