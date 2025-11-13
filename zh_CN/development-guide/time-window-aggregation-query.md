# 聚合查询

## 概述

在时序数据场景中，降采样与聚合计算是核心的数据处理技术。通过降低数据采样频率并将多个数据点合并为代表性数值，能够有效减少计算和传输开销，特别适用于长期趋势分析和可视化展示。

## 应用价值

- 性能优化：减少数据处理量，提升查询效率
- 趋势分析：保留关键数据特征，突出长期变化规律
- 资源节约：降低存储、传输和计算资源消耗
- 可视化友好：生成适合图表展示的数据密度

典型应用场景：工业物联网监控、系统性能指标分析、业务数据趋势展示等。

## 时间窗口聚合查询

### 场景说明

以传感器数据为例，采集频率为1秒级别。当需要展示最近一天或一个月的数据趋势时，原始数据点过于密集会导致：

- 数据传输量过大
- 客户端渲染性能下降
- 图表可读性差（点距过密）

时间窗口聚合通过数据分组和计算，有效解决上述问题。

### 数据表结构示例

Table schema 如下：

```sql
CREATE TABLE sensor_info (
  ts TIMESTAMP(9) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  sn INT32 NOT NULL,
  speed DOUBLE,
  temperature DOUBLE,
  timestamp KEY (ts))
  PARTITION BY HASH(sn) PARTITIONS 2
  ENGINE=TimeSeries
  with (ttl='10d');
```

### 查询示例

#### 分钟级聚合分析

查询设备`sn=1`的温度数据，按1分钟窗口计算平均值

```sql
SELECT 
  date_bin('1 minutes', ts) as timepoint, 
  avg(temperature) as avg_temp 
FROM sensor_info 
WHERE sn = 1
GROUP BY timepoint 
```

#### 天级聚合分析

查询设备sn=1的温度数据，按1天窗口计算最大值

```sql
SELECT 
  date_bin('1 day', ts) as timepoint, 
  max(temperature) as max_temp 
FROM sensor_info 
WHERE sn = 1
GROUP BY timepoint 
```

更多函数说明：
- [聚合函数](../sql-reference/aggregation.md)
- [时间与日期函数](../sql-reference/date.md)
- [数学函数](../sql-reference/math.md)
- [插值函数](../sql-reference/gap_fill.md)
- [Json 函数](../sql-reference/json.md)
