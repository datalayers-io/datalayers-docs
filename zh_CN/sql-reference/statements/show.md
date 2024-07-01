
## SHOW DATABASES
查看数据库中所有数据库。
```SQL
SHOW DATABASES
```

## SHOW TABLES
查看某个 `database` 下所有的table。
```SQL
SHOW TABLES
```

## SHOW CREATE TABLE
获取指定 table 的 SCHEMA
```SQL
SHOW CREATE TABLE table_name
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

# 查看指定 table 的 partitions
SHOW PARTITIONS ON TABLE [db].table_name

# 查看指定 Node 的 partitions
SHOW PARTITIONS ON NODE node_name
```

## SHOW TASKS [TYPE]
查看任务队列
```SQL
# 查看按类型合并的所有任务
SHOW TASKS

# 查看指定类型的任务列表
# 仅支持 SHOW TASKS 结果中 type 列的值，例如:
SHOW TASKS flush
```


