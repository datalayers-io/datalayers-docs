---
title: "数据类型参考手册"
description: "Datalayers SQL 数据类型参考，包括标量类型、向量类型，以及 ARRAY、STRUCT 等复杂类型的语法、示例和使用约束。"
---

# 数据类型参考手册

## 概述

Datalayers SQL 支持标量数据类型、嵌套数据类型、向量数据类型等。

## Numeric Types

| 类型名称 | 别名 | 备注 |
| --- | --- | --- |
| INT8 | TINYINT | 单字节整数，范围 `[-128, 127]` |
| INT16 | SMALLINT | 双字节整数，范围 `[-32768, 32767]` |
| INT32 | INT | 四字节整数，范围 `[-2^31, 2^31-1]` |
| INT64 | BIGINT | 八字节整数，范围 `[-2^63, 2^63-1]` |
| UINT8 | TINYINT UNSIGNED | 无符号单字节整数，范围 `[0, 255]` |
| UINT16 | SMALLINT UNSIGNED | 无符号双字节整数，范围 `[0, 2^16-1]` |
| UINT32 | INT UNSIGNED | 无符号四字节整数，范围 `[0, 2^32-1]` |
| UINT64 | BIGINT UNSIGNED | 无符号八字节整数，范围 `[0, 2^64-1]` |
| FLOAT16 | - | 半精度浮点数（2 字节） |
| FLOAT32 | FLOAT、REAL | 单精度浮点数（4 字节） |
| FLOAT64 | DOUBLE | 双精度浮点数（8 字节） |

## Date/Time Types

| 类型 | 说明 |
| --- | --- |
| TIMESTAMP | `TIMESTAMP(precision)`，`precision` 可选 `0`、`3`、`6`、`9`，分别表示秒、毫秒、微秒、纳秒。默认精度为毫秒。 |
| DATE | 32 位日期值 |
| TIME | 64 位时间值 |

## Boolean Types

| 类型 | 别名 | 说明 |
| --- | --- | --- |
| BOOLEAN | BOOL | 逻辑布尔值，`true` 或 `false` |

## Character and Binary Types

| 类型 | 说明 |
| --- | --- |
| STRING | UTF-8 字符串 |
| BINARY | 二进制数据，最大长度 4 MB |

## Vector Type

| 类型 | 说明 |
| --- | --- |
| VECTOR | `VECTOR(dim)`，其中 `dim` 表示向量维度，取值范围为 `[1, 16383]` |

## 嵌套数据类型

### ARRAY

语法：

```sql
ARRAY<element_type>
```

列定义示例：

```sql
scores ARRAY<INT32>
tags ARRAY<STRING>
payloads ARRAY<STRUCT<a INT32, b STRING>>
matrix ARRAY<ARRAY<INT32>>
```

数组字面量使用方括号：

```sql
[10, 20, 30]
['x', 'y']
[struct(10, 'x'), struct(20, 'y')]
[[1, 2], [3, 4]]
```

### STRUCT

语法：

```sql
STRUCT<field_name field_type, ...>
```

列定义示例：

```sql
payload STRUCT<a INT32, b STRING>
payload STRUCT<scores ARRAY<INT32>, tags ARRAY<STRING>>
payload STRUCT<inner STRUCT<a INT32, b STRING>, note STRING>
```

STRUCT 字面量使用 `struct(...)` 构造：

```sql
struct(10, 'x')
struct([10, 20, 30], ['x', 'y'])
struct(struct(10, 'x'), 'first')
```

## 嵌套数据类型使用示例

### CREATE TABLE

```sql
# 包含 ARRAY 类型的表
CREATE TABLE sx_array(
    ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sid INT32,
    scores ARRAY<INT32>,
    timestamp key(ts)
)
PARTITION BY HASH(sid) PARTITIONS 2
ENGINE=TimeSeries;

# 包含 STRUCT 类型的表
CREATE TABLE sx_struct(
    ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sid INT32,
    payload STRUCT<a INT32, b STRING>,
    timestamp key(ts)
)
PARTITION BY HASH(sid) PARTITIONS 2
ENGINE=TimeSeries;

# 包含嵌套 STRUCT 的 ARRAY 类型的表
CREATE TABLE sx_nested(
    ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sid INT32,
    payloads ARRAY<STRUCT<a INT32, b STRING>>,
    timestamp key(ts)
)
PARTITION BY HASH(sid) PARTITIONS 2
ENGINE=TimeSeries;
```

### INSERT

```sql
# 插入 ARRAY 类型数据
INSERT INTO sx_array (ts, sid, scores) VALUES
('2024-09-01 10:00:00', 1, [10, 20, 30]),
('2024-09-01 10:05:00', 2, [40, NULL, 60]);

# 插入 STRUCT 类型数据
INSERT INTO sx_struct (ts, sid, payload) VALUES
('2024-09-01 10:00:00', 1, struct(10, 'x')),
('2024-09-01 10:05:00', 2, struct(20, 'y'));

# 插入嵌套 STRUCT 的 ARRAY 类型数据
INSERT INTO sx_nested (ts, sid, payloads) VALUES
('2024-09-01 10:00:00', 1, [struct(10, 'x'), struct(20, 'y')]),
('2024-09-01 10:05:00', 2, [struct(NULL, 'z')]);
```

### 查询示例

嵌套字段访问：

```sql
SELECT sid, payload.a, payload.b
FROM sx_struct
ORDER BY sid;
```

数组元素访问：

```sql
SELECT sid, scores[1], scores[3]
FROM sx_array
ORDER BY sid;
```

数组中的结构体字段访问：

```sql
SELECT sid, payloads[1].a, payloads[1].b
FROM sx_nested
ORDER BY sid;
```

数组切片：

```sql
SELECT sid, scores[1:2], scores[1:3:2]
FROM sx_array
ORDER BY sid;
```

切片后继续访问嵌套字段：

```sql
SELECT sid, payloads[1:2][2].a, payloads[1:2][1].b
FROM sx_nested
ORDER BY sid;
```

## 约束与注意事项

- 数组下标从 `1` 开始。例如 `scores[1]` 表示第一个元素。
- 数组切片语法为 `array[lower:upper]` 或 `array[lower:upper:step]`，其中 `lower` 和 `upper` 是切片的起始和结束位置（包含 `lower`，不包含 `upper`），`step` 是步长，默认为 `1`。当前数组切片需要显式写出上下界，例如 `scores[1:2]`、`scores[1:3:2]`。
- 切片越界时不会报错，而是返回截断后的结果或空数组。
- `STRUCT` 字面量是按位置匹配的，`struct(...)` 中值的个数和顺序必须与类型定义一致。
- `ARRAY` 和 `STRUCT` 可以作为 `COUNT`、`ARRAY_AGG` 等聚合函数的输入。
- `ARRAY` 和 `STRUCT` 不能作为分区键列使用。
- `ARRAY` 和 `STRUCT` 的默认值必须是常量字面量，例如 `[10, 20, 30]` 或 `struct(10, 'x')`。
