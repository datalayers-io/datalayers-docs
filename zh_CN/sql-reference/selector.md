# Selector Functions

Selector 用于从一组输入值中选择结果。


## 函数列表

|  Function            | Argument Type(s)                        |  Return Type                                                                            |      Description                                           |
|  -----------------   |------------------------------------     |------------------------------------------------------------------------------           |------------------------------------------------------------|
| last(expression)     | any                                     |                                                                                         | 返回表中某列最后写入的值。                                      |
| first(expression)    | any                                     |   与应用类型相同                                                                          | 返回表中某列最先写入的值。                                     |
| max(expression)      | 数值类型                                 |   与应用类型相同                                                                           | 返回最大值                                                   |
| min(expression)      | 数值类型                                 |   与应用类型相同                                                                           | 返回最小值                                                   |
| bottom(expression)   |                                         |   与应用类型相同                                                                           |                                                            |
| top(expression)      |                                         |   与应用类型相同                                                                           |                                                            |


## 示例
```SQL
-- 计算 sn = 20230629 最新 speed 的值
SELECT last(speed) FROM sensor_info WHERE sn = '20230629' ;
```
