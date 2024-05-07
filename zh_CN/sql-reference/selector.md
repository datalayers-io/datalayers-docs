# Selector Functions

Selector 用于从一组输入值中选择结果。


## 函数列表

|  Function                                 | Argument Type(s)      | Return Type         | Description                      |
|  -----------------                        |---------------------- |-------------------- |----------------------------------| 
| last_value(expr [ORDER BY expression])    | Any Type              | 与应用类型相同         | 返回表中某列最后写入的值。           |
| first_value(expr [ORDER BY expression])   | Any Type              | 与应用类型相同         | 返回表中某列最先写入的值。           |
| max(expr)                                 | Any Type              | 与应用类型相同         | 返回最大值                        |
| min(expr)                                 | Any Type              | 与应用类型相同         | 返回最小值                        |


## 示例
```SQL
-- 计算 sn = 20230629 最新 speed 的值
SELECT last(speed) FROM sensor_info WHERE sn = '20230629' ;
```
