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
    PRIMARY KEY expr,
    ...
)
[ WITH ( [ key = value] [, ... ] ) ] 
```

**说明**  
* PRIMARY KEY: 用户必须指定 `PRIMARY KEY`，PRIMARY KEY 可设置一个或多个列，其中第一个字段必须为 `TIMESTAMP` 类型。
* 在 时序引擎 中，主键用于表示唯一一条数据记录。一般建议将 `唯一数据源 + 时间` 设置主键。如: `PRIMARY KEY (ts, sn)`, `ts` 为时间戳，`sn` 为数据源的唯一标识, 如下示例。
* 创建表时可以通过`WITH`参数对表进行配置。
  * TTL: 数据文件的过期时间，超过该时间的文件将被自动删除，缺省值为3650d。支持时间单位：m（分钟）、h（小时）、d（天）。
  * MAX_MEMTABLE_SIZE: 每个 `vnode` 内存中缓存的数据大小，缺省值为32MiB。支持单位：MiB、GiB。
  * FLUSH_INTERVAL: 每间隔多长时间将内存数据持久化到文件中，缺省值为86400s。支持单位：s（秒）、m（分钟）、h（小时）。
  * MAX_ROW_GROUP_LENGTH: 数据文件中单个 Row Group 存放的最大行数，缺省值为1000000。
  * WAL_FSYNC_INTERVAL: 用于配置 WAL 文件落盘的间隔，如果设置为0，则实时刷盘。缺省值：3000， 最大值：60000（60秒）。单位：ms（毫秒）。
  * VNODE：该表在集群中 vnode 的数量。一个 vnode 代表一个处理线程。缺省值为：2, 最大不能超过 65535。实际大小受系统资源限制，当前单个 CPU核心 最多可以设置4个vnode。

**示例**

```SQL
CREATE TABLE sensor_info (
     ts TIMESTAMP NOT NULL,
     sn BIGINT NOT NULL,
     region VARCHAR(10) NOT NULL,
     speed DOUBLE,
     temperature REAL,
     direction REAL,
     PRIMARY KEY (ts,sn)
) WITH (vnode=2, ttl='7d', max_memtable_size='10MiB', max_row_group_length=1000000, flush_interval='86400s')
```

## 修改表

```SQL
-- add a new column with name "k" to the table "integers", it will be filled with the default value NULL
ALTER TABLE integers ADD COLUMN k INTEGER;
-- add a new column with name "l" to the table integers, it will be filled with the default value 10
ALTER TABLE integers ADD COLUMN l INTEGER DEFAULT 10;

-- drop the column "k" from the table integers
ALTER TABLE integers DROP k;

-- set the default value of a column
ALTER TABLE integers ALTER COLUMN i SET DEFAULT 10;
-- drop the default value of a column
ALTER TABLE integers ALTER COLUMN i DROP DEFAULT;

-- make a column not nullable
ALTER TABLE t ALTER COLUMN x SET NOT NULL;
-- drop the not null constraint
ALTER TABLE t ALTER COLUMN x DROP NOT NULL;

-- rename a table
ALTER TABLE integers RENAME TO integers_old;

-- rename a column of a table
ALTER TABLE integers RENAME i TO j;
```

## 添加索引

|Name       | Description                                                          |
|------     | ------------------------------                                       |
|name       | The name of the index to be created.                                 |
|table      | The name of the table to be indexed.                                 |
|column     | The name of the column to be indexed.                                |
|expression | An expression based on one or more columns of the table. The expression usually must be written with surrounding parentheses, as shown in the syntax. However, the parentheses can be omitted if the expression has the form of a function call.|


```SQL
-- Create index 's_idx' that allows for duplicate values on column revenue of table films.
CREATE INDEX s_idx ON films (revenue);
-- Create compound index 'gy_idx' on genre and year columns.
CREATE INDEX gy_idx ON films (genre, year);
```
注：
* 不支持联合索引，同一列不能重复建立索引。
* 在时序引擎中，新添加索引仅针对新写入数据生效，对历史数据不生效。

## 删除索引
```SQL
-- Remove the index title_idx.
DROP INDEX title_idx;
```
**注**：在时序引擎中索引删除时，并不会立即对已建立的索引进行处理，仅针对新数据生效，历史索引信息后台会择机进行处理。


## 数据写入
```SQL
-- 向表中写入数据 
INSERT INTO table_name VALUES (1), (2), (3);
-- 指定列名写入数据
INSERT INTO table_name (column1,column2,column3,...) VALUES (value1,value2,value3,...);
```
**示例**
```SQL
INSERT INTO sensor_info (ts, sn, region, speed, temperature, direction) VALUES 
('2023-11-09 09:08:10.017', 20230629, 'CHENGDU', 100, 23, 360), 
('2023-11-09 09:08:15.018', 20230629, 'CHENGDU', 100, 23, 360);
```

## 数据查询  
查询sn = 202301 最近七天的 speed 数据。interval 支持 day, hour, minuter。
```SQL
SELECT sn, region, speed FROM sensor_info 
WHERE 
sn = '20230629' and ts > NOW() - interval '7 day';
```
interval 函数允许在日期与时间之间进行数学计算。可用于添加或减去分钟（minute）、小时(hour)、天(day)、月(monty)、年(year)的时间间隔。
## 删除表
```SQL
DROP TABLE [IF EXISTS] [db_name.]tb_name
```
注意：删除表同时会删除表中所有数据，请谨慎操作。

## 限制
* 主键设置后，不可修改
* 新增索引仅对新写入数据生效，对历史数据无效
* 目前仅支持添加列，暂不支持 修改/删除 列
