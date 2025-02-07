---
aside: false
---

# TIMESTAMP Functions

## 函数列表

下表显示了`TIMESTAMP`类型的可用函数。

| Function          | Input Type     | Return Type    |      Description                                           |
|  -----------------|-------------- |-------------- |------------------------------------------------------------|
| now()             |     | TIMESTAMP\_NS   | 返回精度为纳秒的配置时区的时间 |
| current\_date()   |     | Date | 返回当前日期 |
| current\_time()   |     | String | 返回精度为纳秒的UTC当前时间，不包含日期 |
| date\_bin(interval, expression[, origin-timestamp])  |  (INTERVAL<sup>1</sup>, exp[, TIMESTAMP]) | TIMESTAMP | 根据输入的 interval 时间单位对 expression 进行截断，可以指定 origin-timestamp 作为起始时间，不指定则默认为 UNIX epoch in UTC，例如: date\_bin('interval 1 hour', ts) 表示按照每一小时进行截断 |
| date\_bin\_gapfill(interval, expression[, origin-timestamp])  |  (INTERVAL<sup>1</sup>, exp[, TIMESTAMP]) | TIMESTAMP | 根据输入的 interval 时间单位对 expression 进行截断，并补全所有缺失的时间窗口。可以指定 origin-timestamp 作为起始时间，不指定则默认为 UNIX epoch in UTC |
| date\_trunc(precision, expression)  | (PRECISION<sup>2</sup>, exp)  | TIMESTAMP | 根据输入的 precision 精度单位对 expression 进行截断 |
| datetrunc(precision, expression)    | | | date\_trunc 的别名 |
| date\_part(part, expression)        | (PART<sup>3</sup>, exp)  | NUMERIC | 根据指定的 part 获取 expression 的指定部分，例如: date\_part('hour', now()) |
| datepart(part, expression)          | | | date\_part 的别名 |
| extract(field FROM expression)      | (FIELD<sup>4</sup>, exp) | NUMERIC | 获取 expression 的指定部分，等同于 datepart，例如: extract(hour from now()) |
| today()              |     | String | 返回当前日期  |
| make\_date(year, month, day)  | (YEAR, MONTH, DAY)<sup>5</sup> | String  | 构造一个日期 |
| to\_char(expression, format)  | (exp, FORMAT) | Date | 根据指定的 format 格式化日期 |
| to\_date(expression[, ..., format\_n])               | (exp[, ... FORMAT]) | Date | 根据指定的格式化转化成日期，指定多个格式化时依次解析直到符合格式 |
| to\_timestamp(expression[, ..., format\_n])          | (exp[, ... FORMAT]) | TIMESTAMP\_NS | 根据指定的格式化转化成纳秒精度的时间戳，指定多个格式化时依次解析直到符合格式 |
| to\_timestamp\_millis(expression[, ..., format\_n])  | (exp[, ... FORMAT]) | TIMESTAMP\_MS | 根据指定的格式化转化成毫秒精度的时间戳，指定多个格式化时依次解析直到符合格式 |
| to\_timestamp\_micros(expression[, ..., format\_n])  | (exp[, ... FORMAT]) | TIMESTAMP\_US | 根据指定的格式化转化成微秒精度的时间戳，指定多个格式化时依次解析直到符合格式 |
| to\_timestamp\_seconds(expression[, ..., format\_n]) | (exp[, ... FORMAT]) | TIMESTAMP\_S  | 根据指定的格式化转化成秒精度的时间戳，指定多个格式化时依次解析直到符合格式 |
| to\_timestamp\_nanos(expression[, ..., format\_n])   | (exp[, ... FORMAT]) | TIMESTAMP\_NS | 根据指定的格式化转化成纳秒精度的时间戳，指定多个格式化时依次解析直到符合格式 |
| from\_unixtime(expression)   | INTEGER | TIMESTAMP\_S | 从 unix 时间戳转换成时间戳 |
| to\_unixtime(expression[, ..., format\_n])           |(exp[, ... FORMAT]) | INTEGER | 根据指定的格式化转化成 unix 时间戳，指定多个格式化时依次解析直到符合格式 |

::: tip

1. INTERVAL 为形如'2 hour' 的字符串，可用精度单位：'nanosecond', 'microsecond', 'millisecond', 'second', 'minute, 'hour', 'day', 'week', 'month', 'year'
2. PRECISION 为形如 'hour' 的字符串，可用精度单位：'year', 'quarter', 'month', 'week', 'day', 'hour', 'minute', 'second'
3. PART 为形如 'minute' 字符串，可用部分：'year', 'quarter', 'month', 'week', 'day', 'hour', 'minute', 'second', 'millisecond', 'microsecond', 'nanosecond', 'dow', 'doy', 'epoch'
4. FIELD 为形如 minute 的标识符，不同于 PART 是不需要引号的
5. YEAR, MONTH, DAY 既可以是整数类型，也可以是整数类型的字符串形式
:::

## 示例

```SQL
-- 返回当前连接节点的版本信息
SELECT speed,temperature FROM sensor_info WHERE sn = '20230629' and ts > NOW() - interval 7 day;

-- 以 `1 day` 分割点进行聚合
SELECT date_bin('1 days', ts) as timepoint, count(*) as total from sx1  group by timepoint;
```
