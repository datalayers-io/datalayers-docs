# LAST CACHE 优化指南

## 概述
在时序数据场景中，经常需要查询特定设备或点位的最新数据记录，用于实时监控和设备状态追踪。Datalayers v2.3.12 版本引入了 LAST CACHE 功能，专门用于缓存设备最新数据，显著提升相关查询性能。

## 功能特性
- **高效内存缓存**：专为最新数据查询优化
- **按需开启**：支持按表级别灵活控制启用与禁用

如需启用 LAST CACHE，需通过以下两个步骤：

## 配置步骤
### 配置全局缓存大小

在 Datalayers 配置文件（默认路径：/etc/datalayers/datalayers.toml）中设置：
```toml
# 配置 LAST CACHE 在当前节点上，最多使用多少内存。
# 默认: 2GB
last_cache_size = "2GB"
```
此配置表示单个节点上 LAST CACHE 功能可使用的最大内存容量。

### 启用表级 LAST CACHE

在创建表时，通过 TABLE OPTIONS 启用该表的 LAST CACHE 优化：
```sql
CREATE TABLE `t` (
  `ts` TIMESTAMP(9) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `sid` INT32 NOT NULL,
  `value` REAL,
  `flag` INT8,
  TIMESTAMP KEY(`ts`)
)
PARTITION BY HASH (`sid`) PARTITIONS 2
ENGINE=TimeSeries
WITH (
  ENABLE_LAST_CACHE=TRUE
)
```

将 ENABLE_LAST_CACHE设置为 TRUE即为该表启用 LAST CACHE 优化。

## 优化的查询场景
通过上述配置，即可对下面 SQL 加速查询：
- select * from t where sid = 1 order by ts desc limit 1
- select last_value(value order by ts) from t where sid = 1
- select first_value(value order by ts desc) from t where sid = 1
