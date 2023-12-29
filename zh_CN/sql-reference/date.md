# TIMESTAMP Functions


## 函数列表
下表显示了`TIMESTAMP`类型的可用函数。
|  Function        |Input Type     |Return Type    |      Description                                           |
|  -----------------|-------------- |-------------- |------------------------------------------------------------|
| now()             | | TIMESTAMPTZ   |  返回配置时区或客户端设置时区的当前时间, 精度为微秒             |
| to_timestamp_sec()   |           | TIMESTAMP_S   |  仅在insert时可用，输入为Unix时间戳(INT64)，输出是精度为秒的时间戳             |
| to_timestamp_ms()    |          | TIMESTAMP_MS   |  仅在insert时可用，输入为Unix时间戳(INT64)，输出是精度为毫秒的时间戳             |
| to_timestamp_us()    |          | TIMESTAMP   |  仅在insert时可用，输入为Unix时间戳(INT64)，输出是精度为微秒的时间戳             |
| to_timestamp_ns()    |          | TIMESTAMP_NS   |  仅在insert时可用，输入为Unix时间戳(INT64)，输出是精度为纳秒的时间戳             |
| to_timestamp_tz()     |         | TIMESTAMPTZ   |  仅在insert时可用，输入为Unix时间戳(INT64)，输出是配置时区或客户端设置时区的精度为微秒的时间戳             |
| date_trunc('UNIT',expression)  |  (VARCHAR,TIMESTAMP*)     | TIMESTAMP*   |  根据输入的时间单位对TIMESTAMP*类型进行截断，例如: date_trunc('hour', TIMESTAMPTZ '1992-09-20 20:38:40')           |

::: tip
`date_trunc('UNIT',expression)`函数可用的精度单位：'microsecond', 'us', 'millisecond', 'ms', 'second', 's', 'minute', 'min', 'hour', 'h', 'day', 'd', 'week', 'w', 'month', 'mon', 'quarter', 'year', 'y'
:::    

## 示例
```SQL
-- 返回当前连接节点的版本信息
SELECT speed,temperature FROM sensor_info WHERE sn = '20230629' and ts > NOW() - interval '7 day';
```