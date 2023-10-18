# Time-series Table Engine
时序表引擎是为时序场景设计的存储与计算引擎，具有高效写入、高效查询、高效压缩等特性，同时提供基于时序场景的计算函数, 适用于车联网、工业、能源、监控、APM等场景。

## 创建表
```SQL
CREATE TABLE [IF NOT EXISTS] [database.]table_name 
(
    name1 [type1] [DEFAULT expr1],
    name2 [type2] [DEFAULT expr2],
    ...
    PRIMARY KEY expr,
    INDEX index_name1 expr1,
    INDEX index_name2 expr2,
    ...
) 
TableEngine = TimeSeries,
[SETTINGS name=value, ...]
```

### 参数说明
* PRIMARY KEY: 用户必须指定 PRIMARY KEY，且 PRIMARY KEY 第一项必须是 timestamp 类型。PRIMARY KEY 指定后不可修改.
* PARTITION KEY: 该设置用于数据分区。设置后数据将按该key进行分区组织数据。在时序场景合理设置分区多键有利于提升写入与查询效率，建议将 **数据源唯一标识** 作为数据分区KEY。PARTITION KEY 指定后不可修改。
* TTL: 指定表中存储数据的保留时长， 如不配置默认则永久保存。value 为字符串，支持 m（分钟）、h（小时）和 d（天）三个单位，不加时间单位时默认单位为天。如: TTTL = 90, 则表示该 database 中的数据保留90天。
* PRECISION: 指定表中数据时间戳精度。ms 表示毫秒，us 表示微秒，ns 表示纳秒，默认 ms 毫秒

### 示例

```
CREATE TABLE Car (
  ts timestamp NOT NULL,
  sn char(20) NOT NULL,
  model char(10) NOT NULL,
  color char(10),
  speed int,
  price float,
  PRIMARY KEY (ts),
  PARTITION KEY (sn),
  [index xxx xxxx]
)
TableEngine = TimeSeries
TTL=30d
```


## 修改表

## 添加索引

## 删除表
```
DROP TABLE [IF EXISTS] [db_name.]tb_name
```
注意：删除表同时会删除表中所有数据，请谨慎操作。

## 限制

