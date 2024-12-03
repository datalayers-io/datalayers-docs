## COMPACT TABLE
压缩指定的 table，可以指定压缩的目标时间窗口。
**语法**
```SQL
# 压缩非活跃窗口
COMPACT TABLE [db.]table_name
# 或者
COMPACT TABLE [db.]table_name FOR PAST

# 压缩当前窗口
COMPACT TABLE [db.]table_name FOR CURRENT
```


## COMPACT PARTITION
压缩指定的 partition，可以指定压缩的目标时间窗口。
**语法**
```SQL
# 压缩非活跃窗口
COMPACT PARTITION partition_id
# 或者
COMPACT PARTITION partition_id FOR PAST

# 压缩当前窗口
COMPACT PARTITION partition_id FOR CURRENT
```
