# TIMESTAMP Functions


## 函数列表
下表显示了`TIMESTAMP`类型的可用函数。
|  Function        |Input Type     |Return Type    |      Description                                           |
|  -----------------|-------------- |-------------- |------------------------------------------------------------|
| now()             | | TIMESTAMPTZ   |  返回配置时区或客户端设置时区的当前时间, 精度为微秒             |
| date_trunc('UNIT',expression)  |  (VARCHAR,TIMESTAMP*)     | TIMESTAMP*   |  根据输入的时间单位对TIMESTAMP*类型进行截断，例如: date_trunc('hour', TIMESTAMPTZ '1992-09-20 20:38:40') ，数值将会被截断舍入至最近的整点小时          |
| date_trunc(INTEGER,'UNIT',expression)  |  (INTEGER,VARCHAR,TIMESTAMP*)     | TIMESTAMP*   |  根据输入的时间单位和数量对TIMESTAMP*类型进行截断，例如: date_trunc(3,'hour', TIMESTAMPTZ '1992-09-20 20:38:40'), 每三小时进行一次截断 |
| time_split('[COUNT]UNIT',expression)  |  (VARCHAR,TIMESTAMP*)     | TIMESTAMP*   |  作用和date_trunc相似, 根据输入的时间单位和数量对TIMESTAMP*类型进行截断，但直接支持数值+单位的字符串输入。例如: time_split('3 hour', ts), 以3小时为分割点，数值将会被分割舍入。'[COUNT]UNIT' 可以匹配'hour','3 hour','3hour'。 |

::: tip
针对于`date_trunc`和`time_split`函数分割算法可以用一个例子详细说明：如果设置 count 为3，unit 为'hour'，则时间戳将被舍入到最接近的3小时的倍数，分割的基准点将是从'1970-01-01 00:00:00'开始计算。以'2024-01-15 12:34:56'为例，首先计算从1970-01-01T00:00:00到2024-01-15T12:34:56的总小时数。接下来，这个小时数将被舍入到最接近的3小时的倍数。这意味着如果这个小时数除以3的结果有小数部分，它将被向下舍入到最接近的分割点。在这个特定例子中，2024-01-15T12:34:56 将被舍入为 2024-01-15T12:00:00，因为12是最接近12:34的分割点。如果时间是 2024-01-15T15:34:56，它将被舍入为 2024-01-15T15:00:00，因为15是最接近15:34的分割点。

`date_trunc`和`time_split`函数可用的精度单位：'microsecond', 'us', 'millisecond', 'ms', 'second', 's', 'minute', 'min', 'm', 'hour', 'h', 'day', 'd', 'week', 'w', 'month', 'mon', 'quarter', 'year', 'y'
:::    

## 示例
```SQL
-- 返回当前连接节点的版本信息
SELECT speed,temperature FROM sensor_info WHERE sn = '20230629' and ts > NOW() - interval '7 day';

-- 以3小时分分割点进行聚合
SELECT avg(price),time_split('3hour',ts) AS timepoint FROM sensor_info GROUP BY timepoint;
```