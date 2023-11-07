# 数据类型说明
下表显示了所有内置的通用数据类型。

## 数据类型
|  Name         | Description                                                          |
|  -------------|--------------------------------------------------------------------- |
| TIMESTAMP     | combination of time and date                                         |
| TIMESTAMPZ    | combination of time and date that uses the current time zone         |
| TINYINT       | signed one-byte integer [-128, 127]                                  |
| UTINYINT      | unsigned one-byte integer [0, 255]                                   |
| SMALLINT      | signed two-byte integer [-32768, 32767]                              |
| USMALLINT     | unsigned two-byte integer  [0, 65535]                                |
| INTEGER       | signed four-byte integer [-2^31, 2^31-1]                             |
| UINTEGER      | unsigned four-byte integer  [0, 2^32-1]                              |
| BIGINT        | signed eight-byte integer  [-2^63, 2^63-1]                           |
| UBIGINT       | unsigned eight-byte integer [0, 2^64-1]                              |
| REAL          | single-precision floating-point number (4 bytes)                     |
| DOUBLE        | double-precision floating-point number (8 bytes)                     |
| BOOLEAN       | logical boolean (true/false)                                         |
| BIT           | string of 1’s and 0’s                                                |
| BLOB          | variable-length binary data                                          |
| VARCHAR       | variable-length character string                                     |
