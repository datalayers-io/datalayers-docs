
# DROP Statement

DROP 是一种用于删除数据库对象的 SQL 语句。通过 DROP 语句，可以永久删除表、数据库等对象。**DROP 操作是不可撤销的**，一旦执行，对象及其所有数据都会被永久移除。

## 语法

### DROP TABLE

删除指定的table，执行该指令将删除指定table下的所有数据，请谨慎操作。  

```SQL
DROP TABLE [IF EXISTS] [db.]table_name 
```

### DROP DATABASE

```SQL
DROP DATABASE [IF EXISTS] database_name
```

删除指定的 `database`, 如果 `database` 不为空（database下有 table），则不可删除。  

### DROP INDEX

Drops a specified index (including inverted and vector indexes).

```SQL
DROP INDEX [IF EXISTS] index_name ON [database.]table_name
```

Examples

```SQL
DROP INDEX idx_message ON logs;

DROP INDEX IF EXISTS idx_message ON logs;
```
