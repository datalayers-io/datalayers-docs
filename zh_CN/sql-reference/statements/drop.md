
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


### DROP NODE

```SQL
DROP NODE node_name [force]
```

将指定的节点从集群中移除。

注：当指定 Node 上还存在 partition 时，drop node 指令会被拒绝。
