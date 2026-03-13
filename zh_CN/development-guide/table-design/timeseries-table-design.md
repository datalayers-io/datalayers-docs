---
title: "时序存储使用指南"
description: "介绍 Datalayers 时序表设计的关键原则，包括时间列、主键、分区键、表属性和典型建表模式，帮助你构建高性能时序表。"
---
# 时序存储使用指南

## 概述

时序模型面向监控指标、设备遥测、工业采集、能源数据等按时间持续写入的数据场景。合理的时序表设计应同时兼顾以下目标：

- 写入吞吐：持续承载高频数据写入
- 查询效率：支持按时间范围、点位、区域等条件快速过滤
- 存储成本：在保证可分析性的前提下控制文件数量与资源消耗

在设计时序表时，建议优先确定以下问题：时间列是谁、记录唯一性如何定义、查询最常用的过滤条件是什么、数据保留周期有多长。

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

## 设计要点

### 时间列

- 每张时序表都必须定义一个 `TIMESTAMP KEY`
- 时间列应使用真实业务时间，而不是任意递增序号代替
- 如需接收迟到数据，应结合 `BACKFILL_TIME_WINDOW` 统一规划补录策略

### PRIMARY KEY

- `PRIMARY KEY` 用于定义记录唯一性，且必须包含 `TIMESTAMP KEY`
- 当业务天然存在“设备 + 时间”“区域 + 点位 + 时间”这类唯一键时，建议显式建模
- 如果场景以追加写入为主且不依赖唯一性约束，可根据实际模型决定是否声明 `PRIMARY KEY`

### 分区键

- 分区键应优先选择高频过滤字段，例如 `point_number`、`device_id`、`region`
- 分区键需要兼顾写入均衡与查询局部性，避免过低基数导致热点
- 若声明了 `PRIMARY KEY`，`PARTITION BY HASH(column_list)` 中的列必须来自 `PRIMARY KEY` 中除 `TIMESTAMP KEY` 外的列

## 建表实践

### 场景一：按点位查询的时序表

该场景适用于以单点位查询、单点位写入为主的设备监控或传感器采集业务。

| 字段 | 备注 |
| --- | --- |
| time | 数据产生/记录的时间点（时序数据必须拥有一个时间） |
| point_number | 点位信息 |
| temperature | 温度 |
| humidity | 湿度 |

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

**说明**：

- `time` 使用 `TIMESTAMP(9)`，适合纳秒级时间精度场景
- `point_number` 是主要过滤键，也是分区键，可提升单点位查询效率
- 当查询主要围绕单个点位展开时，按 `point_number` 分区通常比随机分区更稳定
- `PARTITIONS` 的具体设置需结合写入规模与集群资源评估

### 场景二：同时支持点位和区域过滤的时序表

该场景适用于既需要按点位查询，也需要按区域聚合或筛选的业务。

| 字段 | 备注 |
| --- | --- |
| time | 数据产生/记录的时间点（时序数据必须拥有一个时间） |
| region | 点位所属区域 |
| point_number | 点位信息 |
| temperature | 温度 |
| humidity | 湿度 |

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

**说明**：

- `PRIMARY KEY(region, pointNumber, time)` 显式表达了记录唯一性
- 选择 `region` 作为分区键，有利于按区域筛选和区域级聚合
- 如果跨区域查询远多于区域内查询，应重新评估分区键是否仍应使用 `region`
- 相比场景一，该设计更适合带业务维度过滤的分析查询

## 表属性建议

- `TTL`：用于控制历史数据保留周期，适合按月、按季度清理历史数据
- `BACKFILL_TIME_WINDOW`：用于定义允许迟到写入的时间范围
- `MEMTABLE_SIZE`：影响落盘频率与后台合并压力，过小会放大写入抖动
- `ENABLE_LAST_CACHE`：适合“查最新值”明显多于“查历史明细”的场景

## PARTITIONS 数量建议

- 一般情况下，单个 partition 可以承载较高写入吞吐，是否增加 partition 应基于实际压测结果决定
- partition 越多，通常越有利于并行写入和并行查询，但也会增加 CPU、内存和后台合并开销
- 建议 `PARTITIONS` 数量不要明显超过集群总 CPU Core 数
- `PARTITIONS` 在建表后当前不支持动态修改，因此需要在建表阶段一次性规划

更具体的写入侧建议可参考 [高性能写入](../high-performance-ingestion.md)。

合理的时序表设计是保证系统性能的关键，建议根据实际业务场景和数据特征进行针对性优化。
