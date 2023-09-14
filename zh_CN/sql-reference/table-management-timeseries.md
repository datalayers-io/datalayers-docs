# Time-series Table Engine

Time-series Table Engine 专为时序数据处理设计的存储引擎，具有高效写入、超高压缩比、丰富的计算函数等特性。....... //todo

## 创建表
```SQL
CREATE TABLE [IF NOT EXISTS] [database.]table_name 
(
    name1 [type1] [DEFAULT expr1],
    name2 [type2] [DEFAULT expr2],
    ...
    INDEX index_name1 expr1,
    INDEX index_name2 expr2,
    ...
    [PARTITION KEY expr]
) ENGINE = TimeSeries()
[SETTINGS name=value, ...]
```

### 参数说明
* PARTITION: 该设置用于数据分区。设置后数据将按该key进行分区组织数据。在时序场景合理设置分区多键有利于提升写入与查询效率，建议将**设备唯一标识**作为 PARTITION KEY。
* PRECISION: 表中时间戳的精度。s 表示秒，ms 表示毫秒，us 表示微秒，ns 表示纳秒，默认 ms 毫秒。
* TTL: 指定数据库中存储数据的保留时间， 如不配置默认则永久保存。value 为字符串，支持 m（分钟）、h（小时）和 d（天）三个单位，不加时间单位时默认单位为天。如: TTTL = 90, 则表示该 database 中的数据保留90天, 默认为0， 表示永久有效。
* CACH_POLICY: Cache 策略设置

## 修改表

## 删除表

## 限制

