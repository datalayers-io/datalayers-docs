# 运算符

## 算术运算符
|  <div style="width:45px">运算符</div>   | <div style="width:115px">支持的数据类型</div>  | 说明  |
|  ----                                  | ----                                         |----  |
| +                                      | 数值类型                                      | 一元运算符，表示正数  |
| -                                      | 数值类型                                      | 一元运算符，表示负数  |
| +                                      | 数值类型                                      | 二元运算符，将两个数值相加。例如，column1 + column2将返回column1和column2相加的结果  |
| -                                      | 数值类型                                      | 二元运算符，从一个数值中减去另一个数值。例如，column1 - column2将返回column1减去column2的结果  |
| *                                      | 数值类型                                      | 二元运算符，将两个数值相乘。例如，column1 * column2将返回column1和column2相乘的结果  |
| /                                      | 数值类型                                      | 二元运算符，将一个数值除以另一个数值。例如，column1 / column2将返回column1除以column2的结果  |
| %                                      | 数值类型                                      | 二元运算符，计算两个数值相除后的余数。例如，column1 % column2将返回column1除以column2后的余数  |


## 比较运算符
|  比较算符   | <div style="width:115px">支持的数据类型</div>  | 说明  |
|  ----     | ----                                         |----  |
| =         | todo                                         | 用于检查两个值是否相等。示例：WHERE column = value |
| <> 或 !=  | todo                                          | 用于检查两个值是否不相等。示例：WHERE column <> value或WHERE column != value |
| >         | todo                                         | 用于检查一个值是否大于另一个值。示例：WHERE column > value |
| <         | todo                                         | 用于检查一个值是否小于另一个值。示例：WHERE column < value |
| >=        | todo                                         | 用于检查一个值是否大于或等于另一个值。示例：WHERE column >= value |
| <=        | todo                                         | 用于检查一个值是否小于或等于另一个值。示例：WHERE column <= value |
| BETWEEN   | todo                                         |  用于检查一个值是否在指定的范围内。示例：WHERE column BETWEEN value1 AND value2 |
| IN        | todo                                         | 用于检查一个值是否匹配一组值中的任何一个。示例：WHERE column IN (value1, value2, value3) |
| LIKE      | todo                                         | 用于检查一个值是否与指定的模式匹配，通常与通配符（例如%和_）一起使用。示例：WHERE column LIKE 'value%' |


## 逻辑运算符
| <div style="width:75px">逻辑运算符</div> | <div style="width:115px">支持的数据类型</div>  | 说明        |
|  ----                                  | ----                                         |----         |
| AND                                    | todo                                         | AND运算符要求所有条件都为真时才返回真。如果一个或多个条件为假，则整个表达式为假。示例：WHERE condition1 AND condition2  |
| OR                                     | todo                                         | OR运算符要求至少一个条件为真时就返回真。只有所有条件都为假时才返回假。示例：WHERE condition1 OR condition2  |
| NOT                                    | todo                                         | NOT运算符用于取反条件的值，如果条件为真，则返回假；如果条件为假，则返回真。示例：WHERE NOT condition  |

## 位运算符
|  <div style="width:50px">运算符</div>   | <div style="width:115px">支持的数据类型</div>  | 说明  |
|  ----                                  | ----                                         |----  |
| &                                      |                                              | 执行二进制位与操作，如果两个操作数的相应位都是1，则结果位也为1，否则为0。示例：column1 & column2  |
| \|                                     |                                              | 执行二进制位或操作，如果两个操作数的相应位中有一个或两个位是1，则结果位为1，否则为0。示例：column1 \| column2  |
| ^                                      |                                              | 执行二进制位异或操作，如果两个操作数的相应位不相同（一个为1，一个为0），则结果位为1，否则为0。示例：column1 ^ column2  |
| ~                                      |                                              | 执行二进制位非操作，将操作数的每个位取反。示例：~column1 |
