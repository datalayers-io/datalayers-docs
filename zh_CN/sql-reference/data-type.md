# 数据类型说明
下表显示了所有Datalayer SQL内置的通用数据类型。对应列出的别名列也可以用于创建和引用这些类型。

## Numeric Types
|  Name                             | Description                                                             |
|  -------------                    |------------------------------------------------------------------------ |
| TINYINT                           | Int8                                                                    |
| SMALLINT                          | Int6                                                                    |
| INT / INTEGER                     | Int32                                                                   |
| BIGINT                            | Int64                                                                   |
| TINYINT UNSIGNED                  | UInt8                                                                   |
| SMALLINT UNSIGNED                 | UInt6                                                                   |
| INT UNSIGNED / INTEGER UNSIGNED   | UInt32                                                                  |
| BIGINT UNSIGNED                   | UInt64                                                                  |
| FLOAT / REAL                      | Float32                                                                 |
| DOUBLE                            | Float64                                                                 |

## Date/Time Types
|  Name                             | Description                                                             |
|  -------------                    |-----------------------------------------                                |
| TIMESTAMP                         | Int64, Timestamp(precision), 可选值为0、3、6、9， 代表秒、毫秒、纳秒、微秒     |

## Boolean Types
|  Name                             | Description                                                             |
|  -------------                    |-----------------------------------------------------------------------  |
| BOOLEAN                           | BOOL, 逻辑布尔值(true/false)                                              |


## Character Types
|  Name                             | Description                                                             |
|  -------------                    |-----------------------------------------------------------------------  |
| CHAR                              | Utf8                                                                    |
| VARCHAR                           | Utf8                                                                    |
| STRING                            | Utf8                                                                    |
| TEXT                              | Utf8                                                                    |

