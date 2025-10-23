# LAST CACHE
在时序场景中，经常需要查询 点/设备 最新一行的数据记录，用于追踪设备最新状态。Datalayers 在 v2.3.12 版本中，引入 LAST CACHE，用于缓存设备、点位最新一行数据，以加速查询。

如需启用 LAST CACHE，需通过以下两个步骤：

## 配置 LAST CACHE 

```toml
# 配置 LAST CACHE 在当前节点上，最多使用多少内存。
# 默认: 2GB
last_cache_size = "2GB"
```
该配置表示当前节点，LAST CACHE 最多使用 2GB 内存。

## 启用 LAST CACHE 

Datalayers 中，可根据 TABLE OPTIONS 中的配置决定当前表是否启用 LAST CACHE 优化。如下 table schema：

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

在 table options 中，将ENABLE_LAST_CACHE设置为 true，即为该 table 启用了 LAST CACHE 优化。

通过上述配置，即可对下面 SQL 加速查询。
- select * from t where sid = 1 order by ts desc limit 1
- select last_value(value order by ts) from t where sid = 1
- select first_value(value order by ts desc) from t where sid = 1
