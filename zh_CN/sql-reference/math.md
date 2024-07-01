# Math Functions

数学函数用于对数值进行计算和处理。


## 函数列表

|  Function            | Argument Type(s)                        |  Return Type                                                                            |      Description                                           |
|  -----------------   |------------------------------------     |------------------------------------------------------------------------------           |------------------------------------------------------------|
| abs(expression)      | 数值类型 | 输入类型 | 返回绝对值，例如：abs(-17.4) = 17.4 |
| acos(expression)     | 数值类型 | DOUBLE | 反余弦函数 |
| acosh(expression)    | 数值类型 | DOUBLE | 双曲余弦或反双曲余弦函数 |
| asin(expression)     | 数值类型 | DOUBLE | 反正弦函数 |
| asinh(expression)    | 数值类型 | DOUBLE | 双曲正弦或反正弦函数 |
| atan(expression)     | 数值类型 | DOUBLE | 反正切函数 |
| atahh(expression)    | 数值类型 | DOUBLE | 双曲正切或反正切函数 |
| atan2(expression\_y, expression\_x) | DOUBLE | 反正切函数，expression\_y 是要操作的第一个数值表达式，expression\_x 是要操作的第二个数值表达式 |
| cbrt(expression)     | 数值类型 | DOUBLE | 返回立方根 |
| ceil(expression)     | 数值类型 | DOUBLE |  将数字向上舍入，例如：ceil(17.4) = 18 |
| cos(expression)      | 数值类型 | DOUBLE | 余弦函数 |
| cosh(expression)     | 数值类型 | DOUBLE | 双曲余弦函数 |
| degrees(expression)  | 数值类型 | DOUBLE | 弧度转换成度数 |
| exp(expression)      | 数值类型 | DOUBLE | 计算e的expression次 |
| factorial(expression)| 数值类型 | DOUBLE | 阶乘函数 |
| floor(expression)    | 数值类型 | DOUBLE | 将数字向下舍入，例如：floor(17.4) = 17 |
| gcd(expression\_x, expression\_y) | 数值类型 | DOUBLE | 最大公约数函数，如果两个输入都为0，则返回0 |
| isnan(expression)    | 数值类型 | BOOL | 判断数值是否为 +NaN 或 -NaN |
| iszero(expression)   | 数值类型 | BOOL | 判断数值是否为 +0.0 或 -0.0 |
| lcm(expression\_x, expression\_y) | 数值类型 | DOUBLE | 最小公倍数函数，如果任一个输入为0，则返回0 |
| ln(expression)       | 数值类型 | DOUBLE | 自然对数函数 |
| log(base, expression)| 数值类型 | DOUBLE | 计算以 base 为底的对数 |
| log(expression)      | 数值类型 | DOUBLE | 计算以 10 为底的对数 |
| log10(expression)    | 数值类型 | DOUBLE | 计算以 10 为底的对数 |
| log2(expression)     | 数值类型 | DOUBLE | 计算以 2 为底的对数 |
| nanvl(expression\_x, expression\_y) | 数值类型 | 输入类型 | 如果第一个参数不是 NaN 则返回第一个参数，否则返回第二个参数 |
| pi()                 | - | DOUBLE | 返回 \pi 的近似值 |
| power(base, exponent) | 数值类型 | DOUBLE | 计算 base 的 exponent 次幂 |
| pow(base, exponent)  | 数值类型 | DOUBLE | 计算 base 的 exponent 次幂 |
| radians(expression)  | 数值类型 | DOUBLE | 度数转换成弧度 |
| random()             | - | DOUBLE | 返回 [0,1) 范围内的随机浮点数 |
| round(v expression, s INT) | 数值类型 | DOUBLE | 四舍五入到小数点后 s 位，s 可选默认为 0 |
| signum(expression)   | 数值类型 | INT | 返回数值的符号，负数返回 -1，零和正数返回 1 |
| sin(expression)      | 数值类型 | DOUBLE | 正弦函数 |
| sinh(expression)     | 数值类型 | DOUBLE | 双曲正弦函数 |
| sqrt(expression)     | 数值类型 | DOUBLE | 返回平方根 |
| tan(expression)      | 数值类型 | DOUBLE | 正切函数 |
| tanh(expression)     | 数值类型 | DOUBLE | 双曲正切函数 |
| trunc(v expression, s INT) | 数值类型 | DOUBLE | 截断数字到小数点后 s 位，s 可选默认为 0 截断为整数 |


## 示例
```SQL
-- 计算 sn = 20230629 最近7天 speed 的向上取整
SELECT ceil(speed) FROM sensor_info WHERE sn = '20230629' and ts > NOW() - interval '7 day';
```

