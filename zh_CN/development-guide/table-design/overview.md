# 概览

## 创建表

使用 [CREATE](../../sql-reference/statements/create.md) 语句在 Datalayers 中创建表。

## 表名
Datalayers 中，表名是大小写敏感的，如：table1 与 Table1 为两个不同的表，表名最大长度为 63 个字节。

## 数据类型
详见[数据类型](../../sql-reference/data-type.md)

## 表属性

此处列出时序模型中一些常见的表属性，包括：

**TTL**：数据文件的过期时间，超过该时间的文件将被自动删除，缺省值为 0，表示永不过期 。支持时间单位：m（分钟）、h（小时）、d（天）；  
**BACKFILL_TIME_WINDOW**：允许数据补录的时间窗口，缺省值为30d。支持单位：h(小时)、d(天)。每个partition独立计算，仅在memtable发生持久化之后生效。每一次memtable持久化后都会刷新该时间窗口。如果同时配置了TTL，则以两者中的较小值为准；  
**UPDATE_MODE**：写入重复数据时的处理方式，目前支持 Overwrite、Append 两种模式，缺省值为：Append。 Append 模式拥有更好的性能，目前 Append 模式暂不支持更新与删除；  
**ENABLE_LAST_CACHE**：是否缓存点位最新的数据，缺少值为：false。启用该功能后，对于查询点位最新值的场景，性能将会有巨大的提升；  
**STORAGE_TYPE**：指定持久化文件存储类型，单机模式下默认为：LOCAL。集群模式下支持：S3、FDB 等类型；  

关于属性更多的信息请参考[时序模型](../../sql-reference/table-engine/timeseries.md)
