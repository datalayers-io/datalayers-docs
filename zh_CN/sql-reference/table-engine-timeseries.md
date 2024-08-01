# Time-series Table Engine
时序表引擎是为时序场景设计的存储与计算引擎，具有高效写入、高效查询、高效压缩等特性，同时提供基于时序场景的计算函数, 适用于车联网、工业、能源、监控、APM等场景。
本页面以及子页面所介绍功能均为 `时序引擎` 相关的的内容，不包括其他引擎。

## 创建表
**语法如下：**  
```SQL
CREATE TABLE [IF NOT EXISTS] [database.]table_name 
(
    name1 type1 [ DEFAULT default_expr ],
    name2 type2 [ DEFAULT default_expr ] ,
    ...
    TIMESTAMP KEY expr,
    ...
)
PARTITION BY HASH(column_name) PARTITIONS 2
[ENGINE=TimeSeries]
[ WITH ( [ key = value] [, ... ] ) ] 
```

**说明**  
* TIMESTAMP KEY: 用户必须指定 `TIMESTAMP KEY`，TIMESTAMP KEY 字段必须为 `TIMESTAMP` 类型。
* ENGINE: 用于指定表引擎，时序引擎为: TimeSeries。
* PARTITION: 在时序引擎中，一般将数据源唯一标识作为 partition key，并通过  PARTITIONS 设置分区数量(合理的设计分区数量有利于提升性能)。
* 创建表时可以通过`WITH`参数对表进行配置。  

|  Name                      | Description                                                                                                                |  
|  ------------------------  |-------------------------------------------------------------------------------------------------------------------------   |  
|  TTL                       | 数据文件的过期时间，超过该时间的文件将被自动删除，缺省值为 `0`，表示永不过期 。支持时间单位：m（分钟）、h（小时）、d（天）           |  
|  MEMTABLE_SIZE             | 每个 `partition` 内存中缓存的数据大小，缺省值为 `128MiB`。支持单位：MiB、GiB                                                       |  
|  FLUSH_INTERVAL            | 每间隔多长时间自动将内存数据持久化到文件中，缺省值为`1d`。如关闭则设置为`0`。支持单位：m（分钟）、h（小时）、d（天）                                    |  
|  MAX_ROW_GROUP_LENGTH      | 数据文件中单个 Row Group 存放的最大行数，缺省值为：`1000000`                                                                     |  
|  WAL_FSYNC_INTERVAL        | 用于配置 WAL 文件落盘的间隔，如果设置为0，则实时刷盘。缺省值：`3000`， 最大值：60000（60秒）。单位：ms（毫秒）                          |  
|  COMPRESSION               | 用于设置持久化文件的压缩方式。缺省值为：`ZSTD`, 目前支持以下选项：UNCOMPRESSED、SNAPPY、LZO、BROTLI、LZ4、ZSTD、LZ4_RAW                  |  
|  UPDATE_MODE               | 写入重复数据时的处理方式，目前仅支持：`Overwrite`                                                                                   |  
|  STORAGE_TYPE              | 持久化文件存储类型，standalone 模式下默认为：`local`。集群模式下支持：S3、FDB 两种类型 |  
|  META_CACHE_SIZE           | 数据元数据的缓存配置，缺省值为：`10000`, 表示缓存 10000 个元数据，如关闭则设置为 `0`                                                      |  
| COMPACT_WINDOW             | Compaction 的窗口大小，缺省值为：`1d`，支持单位：d（天），h（小时） |
| COMPACT_MAX_ACTIVE_FILES   | 活跃窗口的可合并 Parquet 文件个数，大于这个值时，会触发活跃窗口 Compaction，缺省值为：`10`，文件级别过大或文件大小过大的不累加到可合并个数 |
| COMPACT_MAX_FILE_SIZE      | 可合并文件的最大尺寸，缺省值为：`300MiB`，支持单位：MiB、GiB。 此设置表示当待合并文件大小超过时，不再合并这个文件，注意这个值不是对目标文件的强制大小限制，允许出现合并结果文件大小大于此设置。    |
| COMPACT_TIME               | 非活跃窗口合并的工作时间，缺省值为当前系统设置时区的 `02:00\~06:00`。支持 UTC 时区设置形式如： UTC,02:00\~06:00  支持多时间窗口设置形式如： UTC,02:00\~04:00,13:00\~15:00，不允许多个时间窗口重叠，允许时间跨凌晨如：23:00\~02:00 |
| COMPACT_MODE               | Compaction 支持的模式，缺省值为：`TTL`，支持选项：COMPACT, TTL, DELTA，选项可以并列，以英文逗号分隔。如需关闭 Compaction，则指定为 Disable  |

**示例**

```SQL
CREATE TABLE sensor_info (
     ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
     sn INT64 NOT NULL,
     speed DOUBLE,
     temperature REAL,
     TIMESTAMP KEY (ts)
) 
PARTITION BY HASH(sn) PARTITIONS 6
ENGINE=TimeSeries
WITH (ttl='7d', memtable_size='512MiB')
```

## 修改表

```SQL
-- add a new column with name "k" to the table "INT", it will be filled with the default value NULL
ALTER TABLE sensor_info ADD COLUMN k INT;
-- add a new column with name "l" to the table INT, it will be filled with the default value 10
ALTER TABLE sensor_info ADD COLUMN l INTEGER DEFAULT 10;

-- drop the column "k" from the table integers
ALTER TABLE integers DROP COLUMN k;

-- set value for table options 
ALTER TABLE integers MODIFY  OPTIONS ttl='10d', memtable_size='64M';
```


## 数据写入
```SQL
-- 指定列名写入数据
INSERT INTO table_name (column1,column2,column3,...) VALUES (value1,value2,value3,...);
```
**示例**
```SQL
INSERT INTO sensor_info (sn, speed, temperature) VALUES 
(1, 23, 360), 
(2, 23, 360)
```

## 数据查询  
查询sn = 202301 最近七天的 speed 数据。interval 支持 day, hour, minuter。
```SQL
SELECT speed,temperature FROM sensor_info 
WHERE 
sn = 1 and ts > NOW() - interval '7 day';
```
interval 函数允许在日期与时间之间进行数学计算。可用于添加或减去分钟（minute）、小时(hour)、天(day)、月(monty)、年(year)的时间间隔。

## 删除表
```SQL
DROP TABLE [IF EXISTS] [db_name.]tb_name
```
注意：删除表同时会删除表中所有数据，请谨慎操作。

## 限制
* TABLE ENGINE 设置后不可修改  
* PARTITION 设置后不可修改  
* PARTITION KEY 不能为 REAL、DOUBLE 类型
* TIMESTAMP KEY 设置后不可修改   
* 字段类型设置后不可修改
