# Aggregate Functions

聚合函数用于从一组输入值计算单个结果。


## 函数列表

|  Function            | Argument Type(s)                        |  Return Type                                                                            |      Description                                           |
|  -----------------   |------------------------------------     |------------------------------------------------------------------------------           |------------------------------------------------------------|
| avg(expression)      | 值类型                                   |   对于任何整型参数为数值，对于浮点型参数为双精度，否则与参数数据类型相同                            |  所有非空输入值的平均值(算术平均值)                             |
| count(*)             | any                                     |   bigint                                                                                |                                                            |
| count(expression)    | any                                     |   bigint                                                                                |                                                            |
| median(expression)   |                                         |                                                                                         |                                                            |
| distinct(expression) |                                         |                                                                                         |                                                            |
| stddev(expression)   |                                         |                                                                                         |                                                            |
| spread(expression)   |                                         |                                                                                         |                                                            |
| mode(expression)     |                                         |                                                                                         |                                                            |


## 示例
```SQL
-- 查询 sensor_info 记录的总行数
SELECT sum(*) FROM sensor_info;
-- 计算 sn = 20230629 最近7天的平均速度
SELECT avg(speed) FROM sensor_info WHERE sn = '20230629' and ts > NOW() - interval '7 day';
```