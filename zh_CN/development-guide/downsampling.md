# 聚合查询

在时序数据库中，降采样与聚合运算是较为常用的组合。通过降采样/抽稀减少数据点来降低数据点，以此减少计算、传输的负担，适用于长时间段的数据分析。而聚合计算则通过将多个数据点合并为一个值（如平均值、最大值或最小值）来提取趋势。两者结合可以有效提高查询性能，减少数据处理时间，同时保留重要的趋势信息，适用于工业IoT、监控和数据可视化等场景。

## 按时间窗口查询
Datalayers 支持按时间窗口进行聚合查询。
典型应用场景：传感器每秒上报数据，如我们展示该传感器数据最近一天或者一个月的变化趋势时，如果以秒为单位进行展示，则会带来以下一些问题：  
* 数据传输量大
* 客户端计算量大且复杂
* 不利于图形展示、观察（点位过于密集）

按时间窗口对数据进行切割、聚合运行特别适用于此类场景。

### 示例
Table schema 如下：
```sql
CREATE TABLE sensor_info (
  ts TIMESTAMP(9) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  sn STRING,
  speed DOUBLE,
  temperature DOUBLE,
  timestamp KEY (ts))
  PARTITION BY HASH(sn) PARTITIONS 2
  ENGINE=TimeSeries
  with (ttl='10d');
```

假设数据采集频率为 `1Hz`，在数据展示时我们希望查询 `sn = 1` 并且以 1分钟 的区间对数据进行聚合（获取一分钟以内 temperature 的平均值 ），则可使用时间函数对数据进行切割、云计算。SQL 语句如下：

```sql
SELECT date_bin('1 minutes', ts) as timepoint, avg(temperature) as temp from sensor_info where sn = 1 group by timepoint;
```

假设数据采集频率为 `1Hz`，在数据展示时我们希望查询 `sn = 1` 并且以 1天 的区间对数据进行聚合（获取一天以内 temperature 的最大值 ），则可使用时间函数对数据进行切割、云计算。SQL 语句如下：

```sql
SELECT date_bin('1 day', ts) as timepoint, max(temperature) as temp from sensor_info where sn = 1 group by timepoint;
```

更多函数说明：
* [聚合函数](../sql-reference/functions/aggregation.md)
* [时间与日期函数](../sql-reference/functions/date.md)
* [数据函数](../sql-reference/functions/math.md)
