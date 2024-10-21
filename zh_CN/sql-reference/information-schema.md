# INFORMATION_SCHEMA
INFORMATION_SCHEMA 是 Datalayers 中用于提供数据库的元数据访问的一个虚拟数据库。INFORMATION_SCHEMA 中的表并不存储实际的数据，而是存储数据库对象（如表、列、sst_files等信息）的元数据信息，因此 INFORMATION_SCHEMA 下所有表均为只读表（视图）。以下是一些常用的 `information_schema` 表。 

## schemata
|  类型名称             | 类型                       |  备注                                        |
|  -------------       |-------------------------- |------------------------------------------   |
| database             | STRING                    |  数据库的名称                                 |
| created_time         | STRING                    |  数据库的创建时间                              |


## tables
|  类型名称             | 类型                       |  备注                                        |
|  -------------       |-------------------------- |------------------------------------------   |
| database             | STRING                    |  数据库的名称                                 |
| table                | STRING                    |  table 的名称                                |
| engine               | STRING                    |  表引擎                                      |
| version              | UINT32                    |  表的 version， 每修改一次 version 加 1        |
| created_time         | STRING                    |  创建时间                                    |
| updated_time         | STRING                    |  最新的修改时间                                |

## table_partitions
|  类型名称             | 类型                       |  备注                                        |
|  -------------       |-------------------------- |------------------------------------------   |
| database             | STRING                    |  数据库的名称                                 |
| table                | STRING                    |  table 的名称                                |
| node                 | STRING                    |  partition 被分配到的 node                    |
| partition_id         | UINT64                    |  partition_id，全局唯一                       |
| status               | STRING                    |  partition 的状态                            |


## partition_manifests

|  类型名称                    | 类型                       |  备注                                        |
|  -------------              |-------------------------- |------------------------------------------   |
| database                    | STRING                    |  数据库的名称                                 |
| table                       | STRING                    |  table 的名称                                |
| partition_id                | UINT64                    |  partition_id，全局唯一                       |
| manifest_version            | UINT32                    |  manifest_version                           |
| read_version                | UINT32                    |  当前 read version                          |
| flushed_wal_seq_id          | UINT64                    |  partiflushed_wal_seq_id                    |
| flushed_wal_seq_id_offset   | UINT64                    |  flushed_wal_seq_id_offset                   |
| max_ts_in_ssts              | INT64                     |  已落盘中，最大的 时间                          | 
| schema_version              | UINT32                    |  当前 partition 中， table schema 的 version   | 

## sst_files

|  类型名称                    | 类型                       |  备注                                        |
|  -------------              |-------------------------- |------------------------------------------   |
| database                    | STRING                    |  数据库的名称                                 |
| table                       | STRING                    |  table 的名称                                |
| partition_id                | UINT64                    |  partition_id，全局唯一                       |
| file_name                   | STRING                    |  数据存储的文件名                              |
| file_id                     | UINT64                    |  当前文件的id，全局唯一                         |
| file_size                   | UINT64                    |  当前文件存储实际占用的磁盘空间大小（压缩后），单位：Byte     |
| unzip_size                  | UINT64                    |  当前文件数据内容所占空间大小（压缩前）                  |
| min_ts                      | INT64                     |  当前文件中数据最小的时间                         | 
| max_ts                      | INT64                     |  当前文件中数据最大的时间                         | 
| storage_type                | STRING                    |  当前数据存储的目标类型，如：S3                    |
| is_delta                    | BOOLEAN                   |  当前数据文件是否是 delta 数据                    |

该虚拟表用于存储 数据库/表 对应的数据文件信息。可通过该表查询 数据库/表 的空间占用信息、压缩率等。
```sql
// 查询表名为 `sx1` 存储数据的原始大小、压缩后的空间大小
select sum(file_size),sum(unzip_size) from sst_files where table = 'sx1'
```
