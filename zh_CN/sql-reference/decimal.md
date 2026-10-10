---
title: "DECIMAL 数据类型"
description: "用 DECIMAL 保存精确的小数，以及写入、计算和转换时的常见规则。"
---

# DECIMAL

`DECIMAL` 用来保存需要按十进制准确表示的数，例如价格、金额和计量值。`FLOAT` 和 `DOUBLE` 可以表示更大范围的近似值，但不保证每个十进制小数都准确。下面的 SQL 在 Datalayers 中分别返回 `0.3` 和 `0.30000000000000004`：

```sql
SELECT
  CAST('0.1' AS DECIMAL(2, 1)) + CAST('0.2' AS DECIMAL(2, 1)) AS exact_value,
  CAST(0.1 AS DOUBLE) + CAST(0.2 AS DOUBLE) AS approximate_value;
```

结果：

```text
+-------------+---------------------+
| exact_value | approximate_value   |
+-------------+---------------------+
| 0.3         | 0.30000000000000004 |
+-------------+---------------------+
```



## 选择精度和小数位

写成 `DECIMAL(P, S)` 时，`P` 是最多能保存的数字位数，不计算负号和小数点；`S` 是小数点后的位数。例如 `DECIMAL(9, 2)` 最多有 7 位整数和 2 位小数，可保存 `-9999999.99` 到 `9999999.99`。下面的值会显示为 `123.40`：

```sql
SELECT CAST('123.4' AS DECIMAL(9, 2)) AS amount;
```

结果：

```text
+--------+
| amount |
+--------+
| 123.40 |
+--------+
```

省略参数时，Datalayers 使用下表中的默认值。`DEC` 和 `NUMERIC` 也可以代替 `DECIMAL`。


| 写法              | 含义                    |
| --------------- | --------------------- |
| `DECIMAL(9, 2)` | 最多 9 位数字，其中 2 位是小数    |
| `DECIMAL(9)`    | 最多 9 位整数，没有小数         |
| `DECIMAL`       | 相当于 `DECIMAL(38, 10)` |


这两个别名与 `DECIMAL` 的用法相同，下面两列都返回 `1.00`：

```sql
SELECT
  CAST(1 AS DEC(9, 2)) AS dec_value,
  CAST(1 AS NUMERIC(9, 2)) AS numeric_value;
```

结果：

```text
+-----------+---------------+
| dec_value | numeric_value |
+-----------+---------------+
| 1.00      | 1.00          |
+-----------+---------------+
```

例如下面三个结果分别是 `1.0000000000`、`1` 和 `1.00`。建表时建议写明 `P` 和 `S`。

```sql
SELECT
  CAST(1 AS DECIMAL) AS default_decimal,
  CAST(1 AS DECIMAL(9)) AS whole_number,
  CAST(1 AS DECIMAL(9, 2)) AS two_places;
```

结果：

```text
+-----------------+--------------+------------+
| default_decimal | whole_number | two_places |
+-----------------+--------------+------------+
| 1.0000000000    | 1            | 1.00       |
+-----------------+--------------+------------+
```



## 为什么选择 DECIMAL

`DECIMAL` 最多支持 76 位数字，适合需要避免 `FLOAT`、`DOUBLE` 近似误差的数值。Datalayers 会根据声明的 `P` 选择内存中的表示方式：


| `P` 的范围 | 单个数值的内存占用（不含其他开销） |
| ------- | ----------------- |
| 1–9     | 4 字节              |
| 10–18   | 8 字节              |
| 19–38   | 16 字节             |
| 39–76   | 32 字节             |


按实际需要选择较小的 `P` 可以一定程度上节省内存开销。下面两列的精度不同，显示结果都是 `1.20`：

```sql
SELECT
  CAST('1.20' AS DECIMAL(9, 2)) AS smaller_precision,
  CAST('1.20' AS DECIMAL(38, 2)) AS larger_precision;
```

结果：

```text
+-------------------+------------------+
| smaller_precision | larger_precision |
+-------------------+------------------+
| 1.20              | 1.20             |
+-------------------+------------------+
```



## 创建表、写入和查询

下面的时间序列表用 `DECIMAL(9, 2)` 保存价格。

```sql
CREATE TABLE decimal_example (
  device_id INT32 NOT NULL,
  price DECIMAL(9, 2),
  ts TIMESTAMP NOT NULL,
  TIMESTAMP KEY(ts)
)
PARTITION BY HASH(device_id) PARTITIONS 1
ENGINE=TimeSeries;
```

写入后可像其他数值列一样查询、筛选和排序：

```sql
INSERT INTO decimal_example (device_id, price, ts)
VALUES (1, 12.34, 1000), (2, 1.20, 2000);

SELECT device_id, price FROM decimal_example ORDER BY device_id;
```

结果：

```text
+-----------+-------+
| device_id | price |
+-----------+-------+
| 1         | 12.34 |
| 2         | 1.20  |
+-----------+-------+
```

```sql
SELECT device_id, price
FROM decimal_example
WHERE price >= 1.20
ORDER BY price;
```

```text
+-----------+-------+
| device_id | price |
+-----------+-------+
| 2         | 1.20  |
| 1         | 12.34 |
+-----------+-------+
```

`DECIMAL` 可以用于主键。例如，下面把 `amount` 放入主键，并按它分区：

```sql
CREATE TABLE decimal_entity_key (
  amount DECIMAL(9, 2) NOT NULL,
  ts TIMESTAMP NOT NULL,
  TIMESTAMP KEY(ts),
  PRIMARY KEY (amount, ts)
)
PARTITION BY HASH(amount) PARTITIONS 2
ENGINE=TimeSeries
WITH (update_mode=overwrite);

INSERT INTO decimal_entity_key (amount, ts)
VALUES (1.10, 1000), (2.20, 2000);

SELECT amount FROM decimal_entity_key WHERE amount = 1.10;
```

结果：

```text
+--------+
| amount |
+--------+
| 1.10   |
+--------+
```



## 类型转换

### 转换为 DECIMAL

`CAST` 转换为 `DECIMAL(P, S)` 时，多出的小数位会四舍五入到 `S` 位。负数也是按绝对值进位后再加负号，所以 `-1.235` 保留两位小数是 `-1.24`，不是 `-1.23`：

```sql
SELECT
  CAST('1.235' AS DECIMAL(4, 2)) AS positive,
  CAST('-1.235' AS DECIMAL(4, 2)) AS negative,
  CAST('1.2' AS DECIMAL(4, 2)) AS padded;
```

结果：

```text
+----------+----------+--------+
| positive | negative | padded |
+----------+----------+--------+
| 1.24     | -1.24    | 1.20   |
+----------+----------+--------+
```

写入表列时也使用相同的舍入规则。接着前面的建表示例执行，查询结果为 `1.24`：

```sql
INSERT INTO decimal_example (device_id, price, ts)
VALUES (4, 1.235, 4000);

SELECT price FROM decimal_example WHERE device_id = 4;
```

结果：

```text
+-------+
| price |
+-------+
| 1.24  |
+-------+
```

舍入后仍必须落在声明的范围内。`DECIMAL(5, 2)` 最大是 `999.99`；`999.995` 舍入后成为 `1000.00`，因此普通 `CAST` 会报错：

```sql
SELECT CAST('999.995' AS DECIMAL(5, 2)) AS too_large;
```

结果：报错，因为 `1000.00` 超出 `DECIMAL(5, 2)` 的可表示范围。

希望转换失败时得到 `NULL`，可以用 `TRY_CAST`。下面第二列和第三列都是 `NULL`：

```sql
SELECT
  CAST('999.99' AS DECIMAL(5, 2)) AS largest_value,
  TRY_CAST('999.995' AS DECIMAL(5, 2)) AS overflow_value,
  TRY_CAST('not-a-number' AS DECIMAL(5, 2)) AS invalid_value;
```

结果：

```text
+---------------+----------------+---------------+
| largest_value | overflow_value | invalid_value |
+---------------+----------------+---------------+
| 999.99        | NULL           | NULL          |
+---------------+----------------+---------------+
```

### 长数字不要先转为浮点值

没有引号的长数字会先被解析为浮点值，再转换为 `DECIMAL`。浮点转换丢失的数字无法通过后续 `CAST` 恢复。需要保留全部数字时，先以文本写出，再转换为目标类型：

```sql
SELECT
  CAST('12345678901234567890.12' AS DECIMAL(22, 2)) AS exact_number,
  CAST(12345678901234567890.12 AS DECIMAL(22, 2)) AS converted_number;
```

结果：

```text
+-------------------------+-------------------------+
| exact_number            | converted_number        |
+-------------------------+-------------------------+
| 12345678901234567890.12 | 12345678901234567741.44 |
+-------------------------+-------------------------+
```

### 不能转换的浮点值

`NaN` 和无穷大不能转换为 `DECIMAL`。使用 `TRY_CAST` 时，转换失败会返回 `NULL`：

```sql
SELECT
  TRY_CAST(CAST('NaN' AS DOUBLE) AS DECIMAL(9, 2)) AS nan_value,
  TRY_CAST(CAST('Infinity' AS DOUBLE) AS DECIMAL(9, 2)) AS infinity_value;
```

结果：

```text
+-----------+----------------+
| nan_value | infinity_value |
+-----------+----------------+
| NULL      | NULL           |
+-----------+----------------+
```

### 转换为整数

`DECIMAL` 转为整数时会去掉小数部分，而不是四舍五入：

```sql
SELECT
  CAST(CAST('12.99' AS DECIMAL(9, 2)) AS BIGINT) AS positive,
  CAST(CAST('-12.99' AS DECIMAL(9, 2)) AS BIGINT) AS negative;
```

结果：

```text
+----------+----------+
| positive | negative |
+----------+----------+
| 12       | -12      |
+----------+----------+
```

## 算术计算

`DECIMAL` 支持加、减、乘、除和取余。下面 `a` 是 `10.00`，`b` 是 `4.00`，两者均为 `DECIMAL(9, 2)`：

```sql
WITH numbers AS (
  SELECT
    CAST('10.00' AS DECIMAL(9, 2)) AS a,
    CAST('4.00' AS DECIMAL(9, 2)) AS b
)
SELECT
  a + b AS added,
  a - b AS subtracted,
  a * b AS multiplied,
  a / b AS divided,
  a % b AS remainder
FROM numbers;
```

结果：

```text
+-------+------------+------------+----------+-----------+
| added | subtracted | multiplied | divided  | remainder |
+-------+------------+------------+----------+-----------+
| 14.00 | 6.00       | 40.0000    | 2.500000 | 2.00      |
+-------+------------+------------+----------+-----------+
```

计算结果的 `P` 和 `S` 由运算确定，不一定与输入相同。`P` 表示结果最多可有多少位数字，不是下面这些结果实际用了多少位：


| 运算      | 上例的值       | 上例的结果类型         |
| ------- | ---------- | --------------- |
| `a + b` | `14.00`    | `DECIMAL(9, 2)` |
| `a - b` | `6.00`     | `DECIMAL(9, 2)` |
| `a * b` | `40.0000`  | `DECIMAL(9, 4)` |
| `a / b` | `2.500000` | `DECIMAL(9, 6)` |
| `a % b` | `2.00`     | `DECIMAL(9, 2)` |


以这两个 `DECIMAL(9, 2)` 为例，加减法和取余保留 2 位小数，乘法得到 4 位，除法得到 6 位。运算结果仍使用输入的存储宽度，因此本例的 `P` 上限是 9；不会仅因运算就自动增加到 10、19 或 15。

### 计算结果超出范围

`DECIMAL(9, 2)` 最多保存 `9999999.99`。下面的加法实际应得到 `10000000.00`，已经超出范围。当前版本没有在这一步报错，但执行完显示为 `1000000.00`：

```sql
SELECT CAST(9999999.99 AS DECIMAL(9,2))
     + CAST(0.01 AS DECIMAL(9,2)) AS result;
```

当前版本的显示结果：

```text
+------------+
| result     |
+------------+
| 1000000.00 |
+------------+
```

这是越界后的不可靠结果，不能把显示值当作正确的计算结果。

如果运算过程中的数值超出当前计算所能容纳的范围，查询会报算术溢出错误。例如：

```sql
> SELECT CAST('9999999.99' AS DECIMAL(9,2)) * CAST('2.00' AS DECIMAL(9,2)) AS result;
Arrow error: Arithmetic overflow: Overflow happened on: 999999999 * 200
```

结果：算术溢出错误。

需要计算接近上限的值时，应在运算前把操作数明确转成更大精度，而不是等运算后再转换。下面的加法返回 `10000000.00`：

```sql
SELECT CAST('9999999.99' AS DECIMAL(18, 2))
     + CAST('0.01' AS DECIMAL(18, 2)) AS result;
```

结果：

```text
+-------------+
| result      |
+-------------+
| 10000000.00 |
+-------------+
```



### 与整数、浮点数一起计算

普通带小数点的 SQL 字面量是 `DOUBLE`，不是精确的 `DECIMAL`。所以下面的结果会带有浮点近似误差：

```sql
SELECT 0.1 + 0.2 AS approximate_result;
```

结果：

```text
+---------------------+
| approximate_result  |
+---------------------+
| 0.30000000000000004 |
+---------------------+
```

需要精确计算时，请为两边都明确指定 `DECIMAL` 类型。第一条 SQL 得到 `14.34`。第二条把 `DECIMAL(9, 2)` 与 `BIGINT` 一起计算时，当前版本会将两边转换为整数，`12.34` 的小数部分被去掉，因此结果是 `14`。第三条与 `DOUBLE` 混算，结果为浮点数 `3.75`；其他十进制小数仍会有近似误差：

```sql
SELECT CAST('12.34' AS DECIMAL(9, 2))
     + CAST(2 AS DECIMAL(9, 2)) AS exact_result;

SELECT CAST('12.34' AS DECIMAL(9, 2))
     + CAST(2 AS BIGINT) AS bigint_result;

SELECT CAST('1.25' AS DECIMAL(9, 2)) + CAST(2.5 AS DOUBLE) AS approximate_result;
```

结果：

```text
+--------------+
| exact_result |
+--------------+
| 14.34        |
+--------------+

+---------------+
| bigint_result |
+---------------+
| 14            |
+---------------+

+--------------------+
| approximate_result |
+--------------------+
| 3.75               |
+--------------------+
```



## 汇总计算

`DECIMAL` 可以用于 `SUM`、`AVG`、`MIN` 和 `MAX`。当前版本有两种汇总结果需要特别留意。

### AVG 会显示更多小数位

下面的输入都是两位小数，但平均值显示为六位小数：

```sql
SELECT AVG(amount) AS average
FROM (
  VALUES
    (CAST('1.00' AS DECIMAL(9, 2))),
    (CAST('2.00' AS DECIMAL(9, 2))),
    (CAST('2.00' AS DECIMAL(9, 2)))
) AS t(amount);
```

结果：

```text
+----------+
| average  |
+----------+
| 1.666666 |
+----------+
```

这三个值的平均值是 `5.00 ÷ 3`。当前版本显示六位小数时会截去后续数字，因此得到 `1.666666`，而不是按六位小数四舍五入的 `1.666667`。

### SUM 超出范围时可能显示错误结果

下面两个值的正确总和应为 `10000000.00`，但它超出了输入类型 `DECIMAL(9, 2)` 的范围。当前版本没有可靠地报错，而是显示 `1000000.00`：

```sql
SELECT SUM(amount) AS total
FROM (
  VALUES
    (CAST('9999999.99' AS DECIMAL(9, 2))),
    (CAST('0.01' AS DECIMAL(9, 2)))
) AS t(amount);
```

结果：

```text
+------------+
| total      |
+------------+
| 1000000.00 |
+------------+
```

如果总和可能超出列的范围，请在求和前把输入转换为足够大的精度。对同样的两个值，下面得到正确的 `10000000.00`：

```sql
SELECT SUM(CAST(amount AS DECIMAL(18, 2))) AS total
FROM (
  VALUES
    (CAST('9999999.99' AS DECIMAL(9, 2))),
    (CAST('0.01' AS DECIMAL(9, 2)))
) AS t(amount);
```

结果：

```text
+-------------+
| total       |
+-------------+
| 10000000.00 |
+-------------+
```
