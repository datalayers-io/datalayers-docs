# Time-series Table Engine
时序表引擎是为时序场景设计的存储与计算引擎，具有高效写入、高效查询、高效压缩等特性，同时提供基于时序场景的计算函数, 适用于车联网、工业、能源、监控、APM等场景。
本页面以及子页面所介绍功能均为 时序引擎 相关的的内容，不包括其他引擎。

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
PARTITION BY HASH(expr) PARTITIONS 2
[ENGINE=TimeSeries]
[ WITH ( [ key = value] [, ... ] ) ] 
```

**说明**  
* TIMESTAMP KEY: 用户必须指定 `TIMESTAMP KEY`，TIMESTAMP KEY 字段必须为 `TIMESTAMP` 类型。
* ENGINE: 用于指定表引擎，时序引擎为: TimeSeries。
* PARTITION: 在时序引擎中，一般将数据源唯一标识作为 partition key，并通过  PARTITIONS 设置分区数量(合理的设计分区数量有利于提升性能)。
* 创建表时可以通过`WITH`参数对表进行配置。  

|  Name                 | Description                                                                                                                |  
|  -------------------  |-------------------------------------------------------------------------------------------------------------------------   |  
|  TTL                  | 数据文件的过期时间，超过该时间的文件将被自动删除，缺省值为 `0`，表示永不过期 。支持时间单位：m（分钟）、h（小时）、d（天）                     |  
|  MAX_MEMTABLE_SIZE    | 每个 `partition` 内存中缓存的数据大小，缺省值为32MiB。支持单位：MiB、GiB                                                           |  
|  FLUSH_INTERVAL       | 每间隔多长时间将内存数据持久化到文件中，缺省值为86400s。支持单位：s（秒）、m（分钟）、h（小时）                                          |  
|  MAX_ROW_GROUP        | 数据文件中单个 Row Group 存放的最大行数，缺省值为：1000000                                                                        |  
|  WAL_FSYNC_INTERVAL   | 用于配置 WAL 文件落盘的间隔，如果设置为0，则实时刷盘。缺省值：3000， 最大值：60000（60秒）。单位：ms（毫秒）                              |  
|  COMPRESSION          | 用于设置持久化文件的压缩方式。缺省值为：ZSTD, 目前支持以下选项：UNCOMPRESSED、SNAPPY、LZO、BROTLI、LZ4、ZSTD、LZ4_RAW                  |  
|  UPDATE_MODE          | 写入重复数据时的处理方式，目前仅支持：Overwrite                                                                                   |  
|  STORAGE_TYPE         | 持久化文件存储类型，standalone 模式下默认为：local， 集群模式下默认为：fdb。 目前支持：S3、AZURE、GCS 等                                |  


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
WITH (ttl='7d', max_memtable_size='10MiB', max_row_group=8092, flush_interval='86400s')
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
ALTER TABLE integers MODIFY  OPTIONS ttl='10d', max_memtable_size='64M';
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
* TIMESTAMP KEY 设置后不可修改   
* 字段类型设置后不可修改
