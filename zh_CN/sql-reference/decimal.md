---
title: "DECIMAL"
description: "了解如何用 DECIMAL 保存精确的小数，以及写入、计算和转换时的常见规则。"
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

| 写法 | 含义 |
| --- | --- |
| `DECIMAL(9, 2)` | 最多 9 位数字，其中 2 位是小数 |
| `DECIMAL(9)` | 最多 9 位整数，没有小数 |
| `DECIMAL` | 相当于 `DECIMAL(38, 10)` |

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

例如下面三个结果分别是 `1.0000000000`、`1` 和 `1.00`。建表时建议写明 `P` 和 `S`，避免与其他数据库的默认值混淆。

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
1. 可表示范围更大。DECIMAL 中 precision 和 scale 的取值范围都进行了明显扩充。
2. 性能更高。而 DECIMAL 进行了自适应调整（如下表格）, Datalayers 按 `P` 自适应最少的占用空间（内存/磁盘）

| `P` 的范围 | 占用空间（内存/磁盘）|
| --- | --- |
| 1–9 | 4 字节 |
| 10–18 | 8 字节 |
| 19–38 | 16 字节 |
| 39–76 | 32 字节 |

3. 更完备的精度推演。对于不同的表达式，应用不同的精度推演规则对结果的精度进行推演。

## 创建表、写入和查询

下面的时间序列表用 `DECIMAL(9, 2)` 保存价格。时间键仍须使用时间类型，不能用 `DECIMAL`。

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

`DECIMAL` 也可以用于实体键。例如，下面把 `amount` 放入主键，并按它分区：

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

写入后可像其他数值列一样筛选和排序。`price` 没有声明 `NOT NULL`，因此也可以写入 `NULL`：

```sql
INSERT INTO decimal_example (device_id, price, ts)
VALUES (1, 12.34, 1000), (2, 1.20, 2000), (3, NULL, 3000);

SELECT device_id, price FROM decimal_example ORDER BY device_id;
```
```text
+-----------+-------+
| device_id | price |
+-----------+-------+
| 1         | 12.34 |
| 2         | 1.20  |
| 3         | NULL  |
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

## 舍入与超出范围

当输入的小数位多于 `S` 时，Datalayers 会四舍五入到指定的小数位数。下面分别得到 `1.24`、`-1.24` 和 `1.20`：

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

> SELECT CAST('999.995' AS DECIMAL(5, 2)) AS too_large;
Invalid argument error: 1000.00 is too large to store in a Decimal32 of precision 5. Max is 999.99
```
报错：`1000.00` 超出 `DECIMAL(5, 2)` 的可表示范围。

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

| 运算 | 上例的值 | 上例的结果类型 |
| --- | --- | --- |
| `a + b` | `14.00` | `DECIMAL(10, 2)` |
| `a - b` | `6.00` | `DECIMAL(10, 2)` |
| `a * b` | `40.0000` | `DECIMAL(19, 4)` |
| `a / b` | `2.500000` | `DECIMAL(15, 6)` |
| `a % b` | `2.00` | `DECIMAL(9, 2)` |

以这两个 `DECIMAL(9, 2)` 为例：

- 加减法保留 2 位小数，并为可能的进位多留 1 位，因此结果是 `DECIMAL(10, 2)`。
- 乘法把两边的小数位相加，`S` 变为 4；同时为大数相乘预留更多整数位，结果是 `DECIMAL(19, 4)`。
- 除法为商多留 4 位小数，`S` 变为 6，结果是 `DECIMAL(15, 6)`。
- 取余仍保留 2 位小数，结果是 `DECIMAL(9, 2)`。

结果的 `P` 最多为 76。即使运算规则要求预留更多位数，只要实际结果放得下，查询仍可成功。下面得到 `3`；实际结果超出范围时则报错，不会截断：

```sql
SELECT CAST(1 AS DECIMAL(76, 0)) + CAST(2 AS DECIMAL(76, 0)) AS result;
```

结果：

```text
+--------+
| result |
+--------+
| 3      |
+--------+
```

### 与整数、浮点数一起计算

Datalayers 把普通带小数点的 SQL 字面量当作精确十进制数处理。下面直接计算得到 `0.3`，不必先把 `0.1` 和 `0.2` 改写为文本：

```sql
SELECT 0.1 + 0.2 AS exact_result;
```

结果：

```text
+--------------+
| exact_result |
+--------------+
| 0.3          |
+--------------+
```

`DECIMAL` 与整数一起计算时，整数仍可作为精确值参与；下面得到 `14.34`。如果明确与 `DOUBLE` 一起计算，则走近似浮点计算，下面得到 `3.75`，但不再保证每个十进制小数都准确：

```sql
SELECT CAST('12.34' AS DECIMAL(9, 2)) + CAST(2 AS BIGINT) AS exact_result;

SELECT CAST('1.25' AS DECIMAL(9, 2)) + CAST(2.5 AS DOUBLE) AS approximate_result;
```

结果：

```text
+--------------+
| exact_result |
+--------------+
| 14.34        |
+--------------+

+--------------------+
| approximate_result |
+--------------------+
| 3.75               |
+--------------------+
```

## 汇总计算

`SUM`、`AVG`、`MIN` 和 `MAX` 可以直接用于 `DECIMAL`。下面三行数据的和是 `5.00`，平均值是 `1.666667`，最小值和最大值分别是 `1.00`、`2.00`：

```sql
SELECT
  SUM(amount) AS total,
  AVG(amount) AS average,
  MIN(amount) AS minimum,
  MAX(amount) AS maximum
FROM (
  VALUES
    (CAST('1.00' AS DECIMAL(9, 2))),
    (CAST('2.00' AS DECIMAL(9, 2))),
    (CAST('2.00' AS DECIMAL(9, 2)))
) AS t(amount);
```

结果：

```text
+-------+----------+---------+---------+
| total | average  | minimum | maximum |
+-------+----------+---------+---------+
| 5.00  | 1.666667 | 1.00    | 2.00    |
+-------+----------+---------+---------+
```

- `SUM` 把多行数相加，结果可能比任何单行都大，因此会为整数部分预留更多位数，但小数位数不变。本例从 `DECIMAL(9, 2)` 得到 `DECIMAL(19, 2)`，结果是 `5.00`。
- `AVG` 要计算平均值，可能出现更多小数位。本例的 `5.00 / 3` 四舍五入到 6 位小数，得到 `1.666667`，结果类型是 `DECIMAL(13, 6)`。
- `MIN` 和 `MAX` 只是选出原有数值，结果类型仍是 `DECIMAL(9, 2)`。

对其他 `DECIMAL(P, S)` 输入，`SUM` 保持 `S`，为总位数多预留 10 位；`AVG` 为总位数和小数位数各多预留 4 位。总位数最多为 76，实际汇总结果放不下时会报错。

也可以去重后汇总。下面重复的 `1.25` 只计一次，所以 `SUM(DISTINCT amount)` 是 `4.00`：

```sql
SELECT SUM(DISTINCT amount) AS distinct_total
FROM (
  VALUES
    (CAST('1.25' AS DECIMAL(9, 2))),
    (CAST('1.25' AS DECIMAL(9, 2))),
    (CAST('2.75' AS DECIMAL(9, 2)))
) AS t(amount);
```

结果：

```text
+----------------+
| distinct_total |
+----------------+
| 4.00           |
+----------------+
```

如果没有非 `NULL` 值，`SUM` 和 `AVG` 返回 `NULL`，不是零：

```sql
SELECT SUM(amount) AS total, AVG(amount) AS average
FROM (VALUES (CAST(NULL AS DECIMAL(9, 2)))) AS t(amount);
```

结果：

```text
+-------+---------+
| total | average |
+-------+---------+
| NULL  | NULL    |
+-------+---------+
```

## 类型转换和客户端传值

很长的十进制数建议先以文本传入，再明确转换为目标 `DECIMAL`。这样不会在客户端先变成近似的浮点数；下面的结果保持全部 22 位数字：

```sql
SELECT CAST('12345678901234567890.12' AS DECIMAL(22, 2)) AS exact_number;
```

结果：

```text
+-------------------------+
| exact_number            |
+-------------------------+
| 12345678901234567890.12 |
+-------------------------+
```

`DECIMAL` 转为整数时会去掉小数部分，而不是四舍五入。下面分别得到 `12` 和 `-12`：

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

`NaN` 和无穷大不是十进制定点数，不能转为 `DECIMAL`。如果需要把这类转换失败的输入留作 `NULL`，可以用 `TRY_CAST`；下面两列都是 `NULL`：

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

若先转为 `DOUBLE` 再转回 `DECIMAL`，已丢失的精度无法恢复；开头 `0.1 + 0.2` 的 SQL 展示了这种近似误差。Flight SQL 预处理语句则应按服务端返回的参数类型绑定数值