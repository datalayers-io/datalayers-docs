# 运算符

## 算术运算符
|  <div style="width:45px">运算符</div>   | <div style="width:350px">支持的数据类型</div>  | 说明  |
|  ----                                  | ----                                         |----  |
| +                                      | +(TINYINT) -> TINYINT <br> +(SMALLINT) -> SMALLINT <br> +(INTEGER) -> INTEGER <br> +(BIGINT) -> BIGINT <br> +(FLOAT) -> FLOAT <br> +(DOUBLE) -> DOUBLE <br> +(UTINYINT) -> UTINYINT <br> +(USMALLINT) -> USMALLINT <br> +(UINTEGER) -> UINTEGER <br> +(UBIGINT) -> UBIGINT <br>                                       | 一元运算符，表示正数  |
| -                                      | -(TINYINT) -> TINYINT <br> -(SMALLINT) -> SMALLINT <br> -(INTEGER) -> INTEGER <br> -(BIGINT) -> BIGINT <br> -(FLOAT) -> FLOAT <br> -(DOUBLE) -> DOUBLE <br>  -(UTINYINT) -> UTINYINT <br> -(USMALLINT) -> USMALLINT <br> -(UINTEGER) -> UINTEGER <br> -(UBIGINT) -> UBIGINT <br> -(INTERVAL) -> INTERVAL                                       | 一元运算符，表示负数  |
| +                                      | +(TINYINT, TINYINT) -> TINYINT <br> +(SMALLINT, SMALLINT) -> SMALLINT <br> +(INTEGER, INTEGER) -> INTEGER <br> +(BIGINT, BIGINT) -> BIGINT <br> +(FLOAT, FLOAT) -> FLOAT <br> +(DOUBLE, DOUBLE) -> DOUBLE <br> +(UTINYINT, UTINYINT) -> UTINYINT <br> +(USMALLINT, USMALLINT) -> USMALLINT <br> +(UINTEGER, UINTEGER) -> UINTEGER <br> +(UBIGINT, UBIGINT) -> UBIGINT <br> +(INTERVAL, INTERVAL) -> INTERVAL <br> +(TIMESTAMP, INTERVAL) -> TIMESTAMP <br> +(INTERVAL, TIMESTAMP) -> TIMESTAMP <br> +(TIMESTAMP WITH TIME ZONE, INTERVAL) -> TIMESTAMP WITH TIME ZONE <br> +(INTERVAL, TIMESTAMP WITH TIME ZONE) -> TIMESTAMP WITH TIME ZONE                                       | 二元运算符，将两个数值相加。例如，column1 + column2将返回column1和column2相加的结果  |
| -                                      | -(TINYINT, TINYINT) -> TINYINT <br> -(SMALLINT, SMALLINT) -> SMALLINT <br> -(INTEGER, INTEGER) -> INTEGER <br> -(BIGINT, BIGINT) -> BIGINT <br> -(FLOAT, FLOAT) -> FLOAT <br> -(DOUBLE, DOUBLE) -> DOUBLE <br> -(UTINYINT, UTINYINT) -> UTINYINT <br> -(USMALLINT, USMALLINT) -> USMALLINT <br> -(UINTEGER, UINTEGER) -> UINTEGER <br> -(UBIGINT, UBIGINT) -> UBIGINT <br> -(TIMESTAMP, TIMESTAMP) -> INTERVAL <br> -(INTERVAL, INTERVAL) -> INTERVAL <br> -(TIMESTAMP, INTERVAL) -> TIMESTAMP <br> -(TIMESTAMP WITH TIME ZONE, INTERVAL) -> TIMESTAMP WITH TIME ZONE <br> -(TIMESTAMP WITH TIME ZONE, TIMESTAMP WITH TIME ZONE) -> INTERVAL                                       | 二元运算符，从一个数值中减去另一个数值。例如，column1 - column2将返回column1减去column2的结果  |
| *                                      | *(TINYINT, TINYINT) -> TINYINT <br> *(SMALLINT, SMALLINT) -> SMALLINT <br> *(INTEGER, INTEGER) -> INTEGER <br> *(BIGINT, BIGINT) -> BIGINT <br> *(FLOAT, FLOAT) -> FLOAT <br> *(DOUBLE, DOUBLE) -> DOUBLE <br> *(UTINYINT, UTINYINT) -> UTINYINT <br> *(USMALLINT, USMALLINT) -> USMALLINT <br> *(UINTEGER, UINTEGER) -> UINTEGER <br> *(UBIGINT, UBIGINT) -> UBIGINT <br> *(INTERVAL, BIGINT) -> INTERVAL <br> *(BIGINT, INTERVAL) -> INTERVAL                                      | 二元运算符，将两个数值相乘。例如，column1 * column2将返回column1和column2相乘的结果  |
| /                                      | /(FLOAT, FLOAT) -> FLOAT <br> /(DOUBLE, DOUBLE) -> DOUBLE <br> /(INTERVAL, BIGINT) -> INTERVAL                                      | 二元运算符，将一个数值除以另一个数值。例如，column1 / column2将返回column1除以column2的结果  |

::: tip
当不同的数据类型做算术运算并且两种类型直接可以转换时，会发生隐式强制转换。例如: -(INTEGER, DOUBLE) -> -(DOUBLE, DOUBLE) -> DOUBLE
:::


## 比较运算符
|  比较算符                   | <div style="width:115px">支持的数据类型</div>  | 说明  |
|  ----                       | ----                                           |----  |
| =                           | EVERY                                          | 用于检查两个值是否相等。示例：WHERE column = value |
| <> 或 !=                    | EVERY                                          | 用于检查两个值是否不相等。示例：WHERE column <> value或WHERE column != value |
| >                           | EVERY                                          | 用于检查一个值是否大于另一个值。示例：WHERE column > value |
| <                           | EVERY                                          | 用于检查一个值是否小于另一个值。示例：WHERE column < value |
| >=                          | EVERY                                          | 用于检查一个值是否大于或等于另一个值。示例：WHERE column >= value |
| <=                          | EVERY                                          | 用于检查一个值是否小于或等于另一个值。示例：WHERE column <= value |
| IS NULL / ISNULL            | EVERY                                          | 用于检查表达式是否为NULL，如果是则返回true，否则返回false。示例：WHERE column IS NULL |
| IS NOT NULL / NOTNULL       | EVERY                                          | 用于检查表达式是否为NULL，如果是则返回false，否则返回true。示例：WHERE column IS NOT NULL |

::: tip
我们支持的数据类型目前都支持比较运算。当两种不同类型的数据进行比较时，如果可以进行转换则进行隐式强制转换后比较。例如: =(INTEGER, DOUBLE) -> =(DOUBLE, DOUBLE) -> BOOLEAN
:::


## 逻辑运算符
| <div style="width:75px">逻辑运算符</div> | 说明        |
|  ----                                    | ----         |
| AND                                      | AND运算符要求所有条件都为真时才返回真。如果一个或多个条件为假，则整个表达式为假。示例：WHERE condition1 AND condition2  |
| OR                                       |  OR运算符要求至少一个条件为真时就返回真。只有所有条件都为假时才返回假。示例：WHERE condition1 OR condition2  |
| NOT                                      | NOT运算符用于取反条件的值，如果条件为真，则返回假；如果条件为假，则返回真。示例：WHERE NOT condition  |

::: tip
涉及NULL的逻辑操作符并不总是求值为NULL。例如，NULL和false的计算结果为false, NULL或true的计算结果为true。下面是完整的真值表:
:::

|<div style="width:120px">a</div>	|<div style="width:120px">b</div>	|<div style="width:120px">a AND b</div>	|<div style="width:120px">a OR b</div>|<div style="width:120px">NOT a</div>|
|----	|----	|----   |----|----  |
|true	|true	|true	|true|false	|
|true	|false	|false	|true|false	|
|true	|NULL	|NULL	|true|false	|
|false	|false	|false	|false|true	|
|false	|NULL	|false	|NULL|true	|
|NULL	|NULL	|NULL	|NULL|NULL	|




