# Math Functions

Selector 用于从一组输入值中选择结果。


## 函数列表

|  Function            | Argument Type(s)                        |  Return Type                                                                            |      Description                                           |
|  -----------------   |------------------------------------     |------------------------------------------------------------------------------           |------------------------------------------------------------|
| abs(expression)      | 值类型                                   |                                                                                         | 返回最新的值                                                 |
| acos(expression)     | any                                     |   bigint                                                                                | 返回最旧的值                                                 |
| asin(expression)     | any                                     |   bigint                                                                                | 返回最大值                                                   |
| atan(expression)     |                                         |                                                                                         | 返回最小值                                                   |
| ceil(expression)     |                                         |                                                                                         |                                                            |
| cos(expression)      |                                         |                                                                                         |                                                            |
| pos(expression)      |                                         |                                                                                         |                                                            |
| sin(expression)      |                                         |                                                                                         |                                                            |
| round(expression)    |                                         |                                                                                         |                                                            |
| sqrt(expression)     |                                         |                                                                                         |                                                            |
| log(expression)      |                                         |                                                                                         |                                                            |
| floor(expression)    |                                         |                                                                                         |                                                            |


## 示例
```SQL
-- 计算 sn = 20230629 最近7天最大的speed
SELECT max(speed) FROM sensor_info WHERE sn = '20230629' and ts > NOW() - interval '7 day';
```


