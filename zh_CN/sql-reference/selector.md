# Selector Functions

Selector 用于从一组输入值中选择结果。


## 函数列表

|  Function            | Argument Type(s)                        |  Return Type                                                                            |      Description                                           |
|  -----------------   |------------------------------------     |------------------------------------------------------------------------------           |------------------------------------------------------------| 
| last(expression)     | Any Type                                     |     与应用类型相同                                                                                    | 返回表中某列最后写入的值(Unimplemented)。                                      |
| first(expression)    | Any Type                                     |   与应用类型相同                                                                          | 返回表中某列最先写入的值(Unimplemented)。                                     |
| max(expression)      | Any Type                                 |   与应用类型相同                                                                           | 返回最大值                                                   |
| min(expression)      | Any Type   |   与应用类型相同                  | 返回最小值   |                                    |


## 示例
```SQL
-- 计算 sn = 20230629 最新 speed 的值
SELECT last(speed) FROM sensor_info WHERE sn = '20230629' ;
```
