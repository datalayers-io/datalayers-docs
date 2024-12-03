## FLUSH TABLE
将指定 table 的内存数据刷到磁盘上。
**语法**
```SQL
FLUSH TABLE [db.]table_name
```

## FLUSH DATABASE
将指定 database 所有 table 的内存数据刷到磁盘上。
**语法**
```SQL
FLUSH DATABASE db
```

## FLUSH NODE
将指定集群节点上的 partition 的内存数据刷到磁盘上。
**语法**
```SQL
FLUSH NODE name
```
