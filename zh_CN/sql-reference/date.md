---
aside: false
---

# TIMESTAMP Functions


## 函数列表
下表显示了`TIMESTAMP`类型的可用函数。
|  <div style="width:45px"> Function </div>        |Input Type     |Return Type    |      Description                                           |
|  -----------------|-------------- |-------------- |------------------------------------------------------------|
| now()             | | TIMESTAMP_US   |  返回精度为微妙的UTC时间             |
| date_bin(interval, expression)  |  (INTEGER,TIMESTAMP*)     | TIMESTAMP*   |  根据输入的时间单位和数量对TIMESTAMP*类型进行截断，例如: date_bin('1 hour', ts), 每一小时进行一次截断 |


::: tip
函数可用的精度单位：'microsecond', 'millisecond', 'second', 'minute', 'hour', 'day', 'week', 'month', 'year'
:::    

## 示例
```SQL
-- 返回当前连接节点的版本信息
SELECT speed,temperature FROM sensor_info WHERE sn = '20230629' and ts > NOW() - interval '7 day';

-- 以 `1 day` 分割点进行聚合
SELECT date_bin('1 day', ts) as timepoint, count(*) as total from sx1  group by timepoint;
```
