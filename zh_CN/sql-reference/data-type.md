# 数据类型说明
下表显示了所有Datalayer SQL内置的通用数据类型。对应列出的别名列也可以用于创建和引用这些类型。

## Numeric Types
|  Name                             | Aliases                               |  Description                                         |
|  -------------                    |-------------------------------------  |---------------------------------------------------   |
| INT8                              | TINYINT                               |                                                      |
| INT16                             | SMALLINT                              |                                                      |
| INT32                             | INT                                   |                                                      |
| INT64                             | BIGINT                                |                                                      |
| UINT8                             | TINYINT UNSIGNED                      |                                                      |
| UINT16                            | SMALLINT UNSIGNED                     |                                                      |
| UINT32                            | INT UNSIGNED                          |                                                      |
| UINT64                            | BIGINT UNSIGNED                       |                                                      |
| REAL                              |                                       | single precision floating-point number (4 bytes)     |
| DOUBLE                            |                                       | double precision floating-point number (8 bytes)     |


## Date/Time Types
|  Name                             | Description                                                                         |
|  -------------                    |-----------------------------------------------------------------------------------  |
| TIMESTAMP                         | Int64, Timestamp(precision), 可选值为0、3、6、9， 代表秒、毫秒、纳秒、微秒, 缺省值: 毫秒     |

## Boolean Types
|  Name                             | Description                                                                         |
|  -------------                    |----------------------------------------------------------------------------------   |
| BOOLEAN                           | BOOL, 逻辑布尔值(true/false)                                                          |


## Character Types
|  Name                             | Description                                                                         |
|  -------------                    |----------------------------------------------------------------------------------   |
| STRING                            | Utf8                                                                                |

