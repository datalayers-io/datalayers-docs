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
`date_trunc`和`time_split`函数可用的精度单位：'microsecond', 'us', 'millisecond', 'ms', 'second', 's', 'minute', 'min', 'hour', 'h', 'day', 'd', 'week', 'w', 'month', 'mon', 'quarter', 'year', 'y'
:::    

## 示例
```SQL
-- 返回当前连接节点的版本信息
SELECT speed,temperature FROM sensor_info WHERE sn = '20230629' and ts > NOW() - interval '7 day';

-- 以3小时分分割点进行聚合
SELECT avg(price),time_split('3hour',ts) AS timepoint FROM sensor_info GROUP BY timepoint;
```