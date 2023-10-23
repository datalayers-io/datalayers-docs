# Time-series Table Engine
时序表引擎是为时序场景设计的存储与计算引擎，具有高效写入、高效查询、高效压缩等特性，同时提供基于时序场景的计算函数, 适用于车联网、工业、能源、监控、APM等场景。
本页面以及子页面所介绍功能均为 时序引擎 相关的的内容，不包括其他引擎。

## 创建表
通过  `CREATE TIMESERIES` 关键字创建时序模型的 Table, 创建后该属性不可修改。示例如下：
```SQL
CREATE TIMESERIES TABLE [IF NOT EXISTS] [database.]table_name 
(
    name1 type1 [DEFAULT expr1],
    name2 type2 [DEFAULT expr2],
    ...
    PRIMARY KEY expr,
    PARITITION KEY expr,
    INDEX expr1,
    INDEX expr2,
    ...
) 
[name=value]
```

### 选项说明
* PRIMARY KEY: 用户必须指定 `PRIMARY KEY`，且 `PRIMARY KEY` 第一项必须是 `timestamp` 类型。`PRIMARY KEY` 指定后不可修改。
* PARTITION KEY: 该设置用于数据分区。设置后数据将按该key进行分区组织数据。在时序场景合理设置分区多键有利于提升写入与查询效率，建议将 **数据源唯一标识** 作为数据分区 `KEY`。`PARTITION KEY` 指定后不可修改。
* TTL: 指定表中存储数据的保留时长， 如不配置默认则永久保存。value 为字符串，支持 m（分钟）、h（小时）和 d（天）三个单位，不加时间单位时默认单位为天。如: TTTL = 90, 则表示该 `database` 中的数据保留90天。
* PRECISION: 指定表中数据时间戳精度。ms 表示毫秒，us 表示微秒，ns 表示纳秒，默认 ms 毫秒。
* CACHE_POLICY: `Cache` 策略，用于配置缓存最新数据。 //todo 
* COMMENT：表注释说明。

### 主键的选择
在 TimeSeries 引擎中，数据按主键有序存放。因此在定义主键时第一个字段类型必须为 `TIMESTAMP`, 如 `PRIMARY KEY` 中定义了除主键外的其他字段，数据将根据这些字段进行分区存储，分区内的数据按时间顺序存储。一般建议将唯一数据标识设置为分区键，以实现该数据源的高效读取，如: `PRIMARY KEY (ts, device_id)`, ts 为时间戳，device_id 为数据源的唯一标识。

### 索引
索引支持的多种过滤条件，如：>, <, =, <> 。
fields value 的多种过滤条件：>, <, =, <>, like 等, 不支持索引。

### 示例

```SQL
CREATE TABLE vehicle_info (
  ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  sn char(20) NOT NULL,
  speed int,
  longitude float,
  latitude float,
  temp float,
  direction float,
  PRIMARY KEY (ts),
  PARTITION KEY (sn),
  [index xxxx]
)
TableEngine = TimeSeries
TTL=30d
```


## 修改表

### 添加列
```SQL
ALTER TABLE [database.]table_name
    ADD COLUMN `field` int8 NOT NULL;
```

### 删除列 
```SQL
ALTER TABLE [database.]table_name
    DROP COLUMN `field`;
```

### 修改索引
```SQL
ALTER TABLE [database.]table_name
ADD INDEX (field),
DROP INDEX (field);
```
注：不支持联合索引，同一列不能重复建立索引。

## 数据查询
查询sn = 202301 最近七天的 speed 数据。interval 支持 day, hour, minuter。
```SQL
SELECT speed FROM vehicle_info 
WHERE 
sn = '202301' and ts > interval '7 day';
```
## 删除表
```SQL
DROP TABLE [IF EXISTS] [db_name.]tb_name
```
注意：删除表同时会删除表中所有数据，请谨慎操作。

## 限制
* 分区键设置后，暂不支持修改。
* 表引擎指定后，暂不支持修改。
* 新增索引仅对新写入数据生效，对历史数据无效。
* 目前仅支持添加列，暂不支持 修改/删除 列。
