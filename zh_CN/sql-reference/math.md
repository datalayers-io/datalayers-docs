# Math Functions

Selector 用于从一组输入值中选择结果。


## 函数列表

|  Function            | Argument Type(s)                        |  Return Type                                                                            |      Description                                           |
|  -----------------   |------------------------------------     |------------------------------------------------------------------------------           |------------------------------------------------------------|
| abs(expression)      | 数值类型|   输入类型  | 返回绝对值，例如：abs(-17.4) = 17.4                                               |
| acos(expression)     | 数值类型|   DOUBLE   | 反余弦函数，例如：acos(0.5) = 1.0471975511965976                                             |
| asin(expression)     | 数值类型|   DOUBLE   | 反正弦函数，例如：asin(0.5) = 0.5235987755982989                                                   |
| atan(expression)     | 数值类型|   DOUBLE   | 反正切函数，例如：atan(0.5) = 0.4636476090008061                                                  |
| ceil(expression)     | 数值类型|   DOUBLE   |  将数字向上舍入，例如：ceil(17.4) = 18                                                          |
| floor(expression)    | 数值类型|   DOUBLE   |  将数字向下舍入，例如：floor(17.4) = 17                                                          |
| cos(expression)      | 数值类型|   DOUBLE   |  余弦函数，例如：cos(90) = -0.4480736161291701                                                           |
| sin(expression)      | 数值类型|   DOUBLE   |  正弦函数，例如：sin(90) = 	0.8939966636005579                                                          |
| tan(expression)      | 数值类型|   DOUBLE   |   正切函数，例如：tan(90) = -1.995200412208242                                                          |
| round(v expression, s INT)    | 数值类型|   DOUBLE   |   四舍五入到小数点后 s 位，允许 s < 0，例如：round(42.4332, 2)，42.43  |
| sqrt(expression)     | 数值类型|   DOUBLE   |  返回数字的平方根，例如：sqrt(9) = 3                                                          |
| log(expression)      | 数值类型|   DOUBLE   |  计算 x 的 10 对数，例如：log(100) = 2                                                          |
| log10(expression)      | 数值类型|   DOUBLE   |   计算 x 的 10 对数，例如：log10(100) = 2                                                         |
| log2(expression)      | 数值类型|   DOUBLE   |    计算 x 的 2 对数，例如：log2(4) = 2                                                        |
| ln(expression)      | 数值类型|   DOUBLE   |    计算 x 的自然对数，例如：ln(2) = 0.693                                                        |
| exp(expression)      | 数值类型|   DOUBLE   |    计算e的expression次，例如：exp(0.693) = 2                                                        |


## 示例
```SQL
-- 计算 sn = 20230629 最近7天最大的speed
SELECT max(speed) FROM sensor_info WHERE sn = '20230629' and ts > NOW() - interval '7 day';
```


