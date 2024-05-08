
## SHOW DATABASES
查看数据库中所有数据库。
```SQL
show databases
```

## SHOW TABLES
查看某个 `database` 下所有的table。
```SQL
show tables
```

## SHOW CREATE TABLE
获取指定 table 的 SCHEMA
```SQL
show create table table_name
```

## SHOW LICENCE
获取系统的 Licence 信息
```SQL
SHOW LICENCE  
```
## SHOW CLUSTER
获取集群节点信息。注：该指令仅在集群模式下生效。  
```SQL
SHOW CLUSTER
```

## SHOW PARTITIONS [ON TABLE/NODE name]
查看 partitions 分布
```SQL
# 查看所有 partitions 
SHOW PARTITIONS

# 查看指定 table 的 partitons
SHOW PARTITIONS ON TABLE [db].table_name

# 查看指定 Node 的 partitons
SHOW PARTITIONS ON NODE node_name
```
