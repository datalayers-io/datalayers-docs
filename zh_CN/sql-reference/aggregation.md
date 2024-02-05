# Aggregate Functions

聚合函数用于从一组输入值计算单个结果。

## 函数列表

|  Function            | Argument Type(s)                        |           Description                               |
|  -----------------   |------------------------------------     |------------------------------------------------------------------------------           |
|mean(expression)|mean(BIGINT) -> DOUBLE <br> mean(DOUBLE) -> DOUBLE <br> mean(DECIMAL) -> DOUBLE <br> mean(INTEGER) -> DOUBLE <br> mean(SMALLINT) -> DOUBLE <br> mean(TINYINT) -> DOUBLE <br> mean(UBIGINT) -> DOUBLE <br> mean(UINTEGER) -> DOUBLE <br> mean(USMALLINT) -> DOUBLE <br> mean(UTINYINT) -> DOUBLE <br> |计算表达式结果集的平均值。|
|median(expression)|median(BIGINT) -> DOUBLE <br> median(BIT) -> VARCHAR <br> median(BOOLEAN) -> VARCHAR <br> median(DOUBLE) -> DOUBLE <br> median(DECIMAL) -> DECIMAL <br> median(INTEGER) -> DOUBLE <br> median(SMALLINT) -> DOUBLE <br> median(TIMESTAMP) -> TIMESTAMP <br> median(TIMESTAMP_NS) -> TIMESTAMP <br> median(TIMESTAMP_MS) -> TIMESTAMP <br> median(TIMESTAMP_S) -> TIMESTAMP <br> median(TINYINT) -> DOUBLE <br> median(UBIGINT) -> DOUBLE <br> median(UINTEGER) -> DOUBLE <br> median(USMALLINT) -> DOUBLE <br> median(UTINYINT) -> DOUBLE <br> median(VARCHAR) -> VARCHAR <br> median(TIMESTAMPTZ) -> TIMESTAMPTZ <br> |找到表达式结果集中的中位数值。|
|stddev(expression)|stddev(BIGINT) -> DOUBLE <br> stddev(DOUBLE) -> DOUBLE <br> stddev(DECIMAL) -> DOUBLE <br> stddev(INTEGER) -> DOUBLE <br> stddev(SMALLINT) -> DOUBLE <br> stddev(TINYINT) -> DOUBLE <br> stddev(UBIGINT) -> DOUBLE <br> stddev(UINTEGER) -> DOUBLE <br> stddev(USMALLINT) -> DOUBLE <br> stddev(UTINYINT) -> DOUBLE <br> |计算表达式结果集的标准差，以衡量数据的分散程度。|
|sum(expression)|sum(TYPE) -> TYPE_PRECISE * 2 <br> |对表达式结果集中的所有值求和。|
|avg(expression)|avg(BIGINT) -> DOUBLE <br> avg(DOUBLE) -> DOUBLE <br> avg(DECIMAL) -> DOUBLE <br> avg(INTEGER) -> DOUBLE <br> avg(SMALLINT) -> DOUBLE <br> avg(TINYINT) -> DOUBLE <br> avg(UBIGINT) -> DOUBLE <br> avg(UINTEGER) -> DOUBLE <br> avg(USMALLINT) -> DOUBLE <br> avg(UTINYINT) -> DOUBLE <br> |计算表达式结果集的平均值，与mean函数相同。|
|max(expression)|max(TYPE) -> TYPE <br>  |找到表达式结果集中的最大值。|
|min(expression)|min(TYPE) -> TYPE <br>  |找到表达式结果集中的最小值。|
|count(expression)|count(TYPE) -> BIGINT <br> |计算表达式结果集中的项数。|

::: tip
当某种数据类型可以隐式转换到聚合函数支持的类型时，会转换并执行。
:::

## 示例
```SQL
-- 查询 sensor_info 记录的总行数
SELECT count(*) FROM sensor_info;
-- 计算 sn = 20230629 最近7天的平均速度
SELECT avg(speed) FROM sensor_info WHERE sn = '20230629' and ts > NOW() - interval '7 day';
-- 获取最大温度值
SELECT max(temperature) FROM weather_data;
-- 计算特定设备的总运行时间
SELECT sum(duration) FROM device_logs WHERE device_id = 'device123';
-- 找出特定分组中年龄的中位数
SELECT median(age) FROM user_profiles GROUP BY user_group;
```

---