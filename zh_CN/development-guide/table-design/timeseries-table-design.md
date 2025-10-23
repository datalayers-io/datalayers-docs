# 时序模型
时序模型是针对时序、日志等场景优化的数据模型。时序引擎利用时序数据具有时间局部性以及数据查询场景等特点进行优化，以实现高吞吐写入、低存储成本以及高效的计算与分析。

## 建表语法

```sql
CREATE TABLE [IF NOT EXISTS] [database.]table_name 
(
    name1 TIMESTAMP [ DEFAULT default_expr ],
    name2 type [ DEFAULT default_expr ],
    name3 type [ DEFAULT default_expr ] ,
    ...
    TIMESTAMP KEY (name1),
    [ PRIMARY KEY (name1, ...) ],
    ...
)
PARTITION BY HASH(column_list) PARTITIONS 2
[ENGINE=TimeSeries]
[ WITH ( [ key = value] [, ... ] ) ]
```

## 建表实践

### 场景一

在某时序场景中，点表中包括以下几个字段，查询场景为点查。

| 字段          |  备注                                                   | 
| ------------- | ------------------------------------------------------ | 
| time          | 数据产生/记录的时间点（时序数据必须拥有一个时间）           |   
| point_number  | 点位信息                                                |   
| temperature   | 温度                                                   |   
| humidity      | 湿度                                                    |   


建表语句如下：

```sql
CREATE TABLE `point_table` (                          
   `time` TIMESTAMP(9) NOT NULL,
   `point_number` INT32 NOT NULL,                                               
   `temperature` DOUBLE,
   `humidity` DOUBLE,                                     
   TIMESTAMP KEY(`time`),                   
 )                                                     
 PARTITION BY HASH (`point_number`) PARTITIONS 2
```

- time 数据类型为 TIMESTAMP，精度为纳秒
- point_number 表示点位唯一标识
- 数据根据 `point_number` 的 hash 值来做分区，分区数量为：2
- PARTITIONS 数量设置见后面说明

### 场景二

在某时序场景中，点表中包括以下几个字段（相比场景一增加了 `region` 字段），查询场景为点查、区域查询（region）。

| 字段          |  备注                                                   | 
| ------------- | ------------------------------------------------------ | 
| time          | 数据产生/记录的时间点（时序数据必须拥有一个时间）           |   
| region        | 点位所属区域                                             |   
| point_number  | 点位信息                                                |   
| temperature   | 温度                                                   |   
| humidity      | 湿度                                                    |   

建表语句如下：

```sql
CREATE TABLE `point_table` (                          
   `time` TIMESTAMP(9) NOT NULL,
   `region` STRING NOT NULL,                       
   `pointNumber` INT32 NOT NULL,                                               
   `temperature` DOUBLE,                                     
   TIMESTAMP KEY(`time`),
   primary key(`region`, `pointNumber`, `time`)                               
 )                                                     
 PARTITION BY HASH (`region`) PARTITIONS 2
```

- time 数据类型为 TIMESTAMP，精度为纳秒
- 数据根据 `region` 的 hash 值来做分区，分区数量为：2
- 唯一点位标识：`region` + `pointNumber`
- PARTITIONS 数量设置见后面说明
- 相比场景一，场景二根据 region 查询的性能会更优（如有这类查询场景需求）

## PARTITION 数量
- 一般来说 1 个 partition 每秒可高达数十万点位的写入，因此根据实际场景需求来设置即可
- Partition 越多，会消耗越多的 CPU 与内存，建议 Partition 数量不超过集群内所有节点的 CPU CORE 之和 

