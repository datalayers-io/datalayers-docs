# 数据类型说明
下表显示了所有Datalayer SQL内置的通用数据类型。对应列出的别名列也可以用于创建和引用这些类型。

## 数据类型
|  Name         | Aliases                                                          | Description                                                          |
|  -------------|--------------------------------------------------------------------- |--------------------------------------------------------------------- |
| HUGEINT     |                                          |有符号十六字节整数|
| BIGINT     | INT8, LONG                                         |有符号八字节整数|
| BIT     | BITSTRING                                        |1和0的字符串|
| BOOLEAN     | BOOL, LOGICAL                                       |逻辑布尔值(true/false)|
| BLOB     | BYTEA, BINARY, VARBINARY                                        |可变长度二进制数据|
| DOUBLE     | FLOAT8, NUMERIC, DECIMAL                                        |双精度浮点数(8字节)|
| DECIMAL(prec, scale)     |                                        |给定宽度(精度)和比例的固定精度数字|
| INTEGER     | INT4, INT, SIGNED                                        |有符号四字节整数|
| INTERVAL     |                                         |日期/时间 区间|
| REAL     | FLOAT4, FLOAT                                        |单精度浮点数(4字节)|
| SMALLINT     | INT2, SHORT                                        |有符号双字节整数|
| TIMESTAMP     | DATETIME                                        |时间戳(时间和日期的组合),精度为微秒(忽略时区)|
| TIMESTAMP_NS     |                                         |纳秒精度的时间戳(忽略时区)|
| TIMESTAMP_MS     |                                         |毫秒精度的时间戳(忽略时区)|
| TIMESTAMP_S     |                                        |秒精度的时间戳(忽略时区)|
| TIMESTAMPTZ     | TIMESTAMP WITH TIME ZONE                                        |使用当前时区(连接中的时区)的微秒精度的时间戳，读出会根据连接中时区的变化更改(更改为当前时区时间)|
| TINYINT     | INT1                                       |有符号一字节整数|
| UBIGINT     |                                        |无符号8字节整数|
| UINTEGER     |                                        |无符号四字节整数|
| USMALLINT     |                                         |无符号两字节整数|
| UTINYINT     |                                        |无符号一字节整数|
| VARCHAR     | CHAR, BPCHAR, TEXT, STRING                                        |可变长度的字符串|

		
		
		