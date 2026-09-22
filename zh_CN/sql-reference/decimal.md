---
title: "DECIMAL"
description: "Datalayers DECIMAL 定点数类型的语法、精度、取值范围、算术规则、类型转换、存储宽度和溢出行为。"
---

# DECIMAL

## 类型说明

`DECIMAL(P, S)` 是精确的定点数类型，适合保存货币、计量值以及其他不能接受二进制浮点误差的数据。

- `P`（precision）表示有效数字的总位数。
- `S`（scale）表示小数点右侧的位数。
- 小数点左侧最多有 `P - S` 位。

`DECIMAL`、`DEC` 和 `NUMERIC` 是同一种逻辑类型的别名。Schema 输出统一显示为 `DECIMAL(P, S)`。

## 语法

```sql
DECIMAL
DECIMAL(P)
DECIMAL(P, S)
```

也可以使用别名：

```sql
DEC(P, S)
NUMERIC(P, S)
```

参数约束如下：

```text
1 <= P <= 76
0 <= S <= P
```

省略参数时采用以下默认值：


| 声明                        | 规范化类型             |
| ------------------------- | ----------------- |
| `DECIMAL`、`DEC`、`NUMERIC` | `DECIMAL(38, 10)` |
| `DECIMAL(P)`              | `DECIMAL(P, 0)`   |
| `DECIMAL(P, S)`           | `DECIMAL(P, S)`   |


::: tip
不同数据库对裸 `DECIMAL` 的默认精度和小数位数可能不同。需要跨数据库迁移时，建议始终显式声明 `P` 和 `S`。
:::

## 取值范围

`DECIMAL(P, S)` 的绝对值必须小于 `10^(P-S)`，最小步长为 `10^(-S)`。

例如，`DECIMAL(5, 2)` 的取值范围是 `[-999.99, 999.99]`。


| 类型              | 最小值            | 最大值           |
| --------------- | -------------- | ------------- |
| `DECIMAL(3, 0)` | `-999`         | `999`         |
| `DECIMAL(5, 2)` | `-999.99`      | `999.99`      |
| `DECIMAL(9, 9)` | `-0.999999999` | `0.999999999` |


`NULL` 不受上述范围限制。

## 存储宽度

Datalayers 根据声明的 precision 自动选择最小的 Arrow Decimal 物理类型。用户仍然只需使用 SQL `DECIMAL(P, S)`。


| Precision   | 内部物理类型     | 每个非 NULL 值的宽度 |
| ----------- | ---------- | ------------- |
| `1` 到 `9`   | Decimal32  | 4 字节          |
| `10` 到 `18` | Decimal64  | 8 字节          |
| `19` 到 `38` | Decimal128 | 16 字节         |
| `39` 到 `76` | Decimal256 | 32 字节         |


同一列的物理宽度只由声明的 `P` 决定，不会随某一行的实际值变化。较小的 precision 因此能够减少 Memtable、查询批次和 Parquet 中的数值存储开销。

## 转换和舍入

普通写入和 `CAST` 使用一致的定点数量化规则：


| 输入情况                  | 处理方式                   |
| --------------------- | ---------------------- |
| 小数位少于 `S`             | 在右侧补零                  |
| 小数位多于 `S`             | 四舍五入，正负数均向远离零的方向处理中点   |
| 量化后的有效数字超过 `P`        | 返回 numeric overflow 错误 |
| `NaN` 或正负无穷转为 Decimal | 返回错误                   |
| `NULL`                | 保持 `NULL`              |


示例：

```sql
SELECT
  CAST('1.235' AS DECIMAL(4, 2)),
  CAST('-1.235' AS DECIMAL(4, 2));
```

```text
1.24  -1.24
```

字符串输入采用十进制精确解析，也支持科学计数法，不会先转换成 `FLOAT` 或 `DOUBLE`：

```sql
SELECT
  CAST('123.4500' AS DECIMAL(10, 4)),
  CAST('1.23e5' AS DECIMAL(10, 2));
```

带小数点的未定类型 SQL 数值字面量（例如 `1.235`）按精确 Decimal 解析，不会先转换成二进制浮点数。未定类型的科学计数法优先按精确 Decimal 解析；若无法精确表示，则回退为 `Float64`。


| 字面量                    | 推导类型              | 说明                        |
| ---------------------- | ----------------- | ------------------------- |
| `1e2`                  | `DECIMAL(3, 0)`   | 精确展开为 `100`               |
| `2e38`                 | `DECIMAL(39, 0)`  | 39 位整数仍在 Decimal76 范围内    |
| `1e-76`                | `DECIMAL(76, 76)` | scale 76 是 Decimal256 的边界 |
| `1e76`、`1e-77`、`1e308` | `DOUBLE`          | 定点展开需要超过 76 位，使用近似浮点语义    |
| `0e999`                | `DECIMAL(1, 0)`   | 零的指数不影响数值范围               |


上述回退仅适用于未定类型的科学计数法字面量。显式 `CAST('1e308' AS DECIMAL(P, S))` 仍严格按照目标 Decimal 类型转换，不能表示时返回 overflow，不会静默改成 `DOUBLE`。向量函数等明确的浮点上下文会按函数签名转换输入。

从 Decimal 转换到整数时会向零截断：

```sql
SELECT
  CAST(CAST(12.99 AS DECIMAL(9, 2)) AS BIGINT),
  CAST(CAST(-12.99 AS DECIMAL(9, 2)) AS BIGINT);
```

```text
12  -12
```

`CAST` 遇到非法文本或溢出时返回错误；`TRY_CAST` 在相同情况下返回 `NULL`：

```sql
SELECT TRY_CAST(99.95 AS DECIMAL(3, 1));
```

```text
NULL
```



## 算术运算

Decimal 支持 `+`、`-`、`*`、`/` 和 `%`。Datalayers 会在计算前自动扩大内部物理宽度，避免结果因停留在 Decimal32、Decimal64 或 Decimal128 而提前溢出。

设两个操作数分别为 `DECIMAL(P1, S1)` 和 `DECIMAL(P2, S2)`，结果精度和 scale 按以下规则推导：


| 运算      | 结果 precision                          | 结果 scale          |
| ------- | ------------------------------------- | ----------------- |
| `+`、`-` | `max(P1-S1, P2-S2) + max(S1, S2) + 1` | `max(S1, S2)`     |
| `*`     | `P1 + P2 + 1`                         | `S1 + S2`         |
| `/`     | `P1 + result_scale - S1 + S2`         | `min(S1 + 4, 76)` |
| `%`     | `min(P1-S1, P2-S2) + max(S1, S2)`     | `max(S1, S2)`     |


公开结果类型的 precision 最大为 76。当公式要求超过 76 位时，Datalayers 将结果类型限制为 precision 76，并在执行时校验实际值。因此，小值运算仍可成功，实际结果超过 76 位时返回 numeric overflow。

```sql
SELECT
  CAST(9999999.99 AS DECIMAL(9, 2))
  + CAST(0.01 AS DECIMAL(9, 2));
```

```text
10000000.00
```

Decimal 与整数运算时，整数作为 scale 为 0 的精确值参与计算。Decimal 与 `FLOAT` 或 `DOUBLE` 运算时使用浮点计算路径，结果不再保证十进制定点精确性；需要精确结果时应先显式转换为 Decimal。

## 聚合运算

`SUM` 和 `AVG` 以精确十进制累加，并对结果做溢出检查。若合计超出结果类型范围，查询返回 numeric overflow，而不会静默得到错误数值。结果类型规则如下：


| 聚合函数        | 输入              | 结果                                    |
| ----------- | --------------- | ------------------------------------- |
| `SUM`       | `DECIMAL(P, S)` | `DECIMAL(min(P+10, 76), S)`           |
| `AVG`       | `DECIMAL(P, S)` | `DECIMAL(min(P+4, 76), min(S+4, 76))` |
| `MIN`、`MAX` | `DECIMAL(P, S)` | `DECIMAL(P, S)`                       |


`SUM` 和 `AVG` 忽略 `NULL`；输入为空或全部为 `NULL` 时返回 `NULL`。普通聚合、`DISTINCT` 聚合和窗口聚合使用相同的溢出检查。

```sql
SELECT SUM(amount), AVG(amount)
FROM decimal_example;
```

如果最终聚合结果超出声明结果类型的范围，查询返回 numeric overflow。

## 使用示例



### 创建表

以下示例创建一个包含四个 precision 范围的时序表：

```sql
CREATE TABLE decimal_example (
  device_id INT32 NOT NULL,
  price DECIMAL(9, 2),
  energy NUMERIC(18, 4),
  total DEC(38, 6),
  scientific_value DECIMAL(76, 10),
  ts TIMESTAMP NOT NULL,
  TIMESTAMP KEY(ts)
)
PARTITION BY HASH(device_id) PARTITIONS 1
ENGINE=TimeSeries;
```



### 写入和查询

```sql
INSERT INTO decimal_example
  (device_id, price, energy, total, scientific_value, ts)
VALUES
  (1, 12.34, 100.1250, 123456789.123456,
   123456789012345678901234567890.1234567890, 1000);

SELECT price, energy, total, scientific_value
FROM decimal_example
WHERE device_id = 1;
```

Decimal 列也可以用作 TimeSeries 表的 entity key，但不能用作 timestamp key。

## 溢出和错误处理

以下情况会返回错误：

- `P` 不在 `[1, 76]` 范围内；
- `S` 不在 `[0, P]` 范围内；
- 写入、默认值或 `CAST` 的量化结果超过 `P` 位；
- 算术或聚合的实际结果超过结果类型范围；
- 字符串格式非法；
- 将 `NaN` 或正负无穷转换为 Decimal；
- 将 Decimal 列声明为 timestamp key。

```sql
SELECT CAST('99.95' AS DECIMAL(3, 1));
```

该值舍入为 `100.0`，需要 4 位 precision，因此返回 numeric overflow。

## Arrow Flight SQL 注意事项

Arrow 客户端会看到由 precision 选择的 `Decimal32`、`Decimal64`、`Decimal128` 或 `Decimal256` 及其 `(P, S)` 元数据。

- Prepared statement 参数可以使用任意 Arrow Decimal 物理类型；服务端会按目标列的 `(P, S)` 和物理类型执行带溢出检查的转换。
- TimeSeries Flight DoPut 和直接 `RecordBatch` 写入目前要求输入 array 的 Decimal 物理类型、`P` 和 `S` 与表 schema 完全一致。例如，`DECIMAL(8, 2)` 列应发送 `Decimal32(8, 2)`，不能发送逻辑精度相同的 `Decimal128(8, 2)`。
- 查询结果保留表列或表达式实际使用的 Arrow Decimal 物理类型，不会统一扩大为 Decimal128。

