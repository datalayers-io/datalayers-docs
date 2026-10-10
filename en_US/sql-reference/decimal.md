---
title: "DECIMAL Data Type"
description: "Store exact decimals with DECIMAL, and the common rules for writes, calculations, and conversions."
---

# DECIMAL

Use `DECIMAL` for values that need exact base-10 representation, such as prices, money, and measurements. `FLOAT` and `DOUBLE` cover a wider range of approximate values, but cannot represent every decimal fraction exactly. In Datalayers, the following SQL returns `0.3` and `0.30000000000000004`, respectively:

```sql
SELECT
  CAST('0.1' AS DECIMAL(2, 1)) + CAST('0.2' AS DECIMAL(2, 1)) AS exact_value,
  CAST(0.1 AS DOUBLE) + CAST(0.2 AS DOUBLE) AS approximate_value;
```

Result:

```text
+-------------+---------------------+
| exact_value | approximate_value   |
+-------------+---------------------+
| 0.3         | 0.30000000000000004 |
+-------------+---------------------+
```

## Choose Precision and Scale

In `DECIMAL(P, S)`, `P` is the maximum total number of digits, excluding the minus sign and decimal point. `S` is the number of digits after the decimal point. For example, `DECIMAL(9, 2)` allows up to 7 whole-number digits and 2 decimal places, from `-9999999.99` to `9999999.99`. The following value is displayed as `123.40`:

```sql
SELECT CAST('123.4' AS DECIMAL(9, 2)) AS amount;
```

Result:

```text
+--------+
| amount |
+--------+
| 123.40 |
+--------+
```

Datalayers uses the defaults below when arguments are omitted. `DEC` and `NUMERIC` can also be used in place of `DECIMAL`.

| Declaration | Meaning |
| --- | --- |
| `DECIMAL(9, 2)` | Up to 9 digits in total, including 2 decimal places |
| `DECIMAL(9)` | Up to 9 whole-number digits, with no decimal places |
| `DECIMAL` | The same as `DECIMAL(38, 10)` |

These aliases work like `DECIMAL`. Both columns below return `1.00`:

```sql
SELECT
  CAST(1 AS DEC(9, 2)) AS dec_value,
  CAST(1 AS NUMERIC(9, 2)) AS numeric_value;
```

Result:

```text
+-----------+---------------+
| dec_value | numeric_value |
+-----------+---------------+
| 1.00      | 1.00          |
+-----------+---------------+
```

The next three results are `1.0000000000`, `1`, and `1.00`. Specify both `P` and `S` when creating tables.

```sql
SELECT
  CAST(1 AS DECIMAL) AS default_decimal,
  CAST(1 AS DECIMAL(9)) AS whole_number,
  CAST(1 AS DECIMAL(9, 2)) AS two_places;
```

Result:

```text
+-----------------+--------------+------------+
| default_decimal | whole_number | two_places |
+-----------------+--------------+------------+
| 1.0000000000    | 1            | 1.00       |
+-----------------+--------------+------------+
```

## Why Choose DECIMAL

`DECIMAL` supports up to 76 digits and is suitable when you need to avoid the approximation of `FLOAT` or `DOUBLE`. Datalayers chooses the in-memory representation from the declared `P`:

| Range of `P` | Memory per value (excluding other overhead) |
| --- | --- |
| 1–9 | 4 bytes |
| 10–18 | 8 bytes |
| 19–38 | 16 bytes |
| 39–76 | 32 bytes |

Choosing a smaller `P` when it meets your needs can reduce memory overhead to some extent. Both columns below have different precisions, but both display as `1.20`:

```sql
SELECT
  CAST('1.20' AS DECIMAL(9, 2)) AS smaller_precision,
  CAST('1.20' AS DECIMAL(38, 2)) AS larger_precision;
```

Result:

```text
+-------------------+------------------+
| smaller_precision | larger_precision |
+-------------------+------------------+
| 1.20              | 1.20             |
+-------------------+------------------+
```

## Create a Table, Insert, and Query

The following time-series table stores prices as `DECIMAL(9, 2)`.

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

After inserting data, query, filter, and sort these values like other numeric columns:

```sql
INSERT INTO decimal_example (device_id, price, ts)
VALUES (1, 12.34, 1000), (2, 1.20, 2000);

SELECT device_id, price FROM decimal_example ORDER BY device_id;
```

Result:

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

`DECIMAL` can be used in a primary key. For example, this table includes `amount` in its primary key and partitions by it:

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

Result:

```text
+--------+
| amount |
+--------+
| 1.10   |
+--------+
```

## Type Conversions

### Converting to DECIMAL

When `CAST` converts a value to `DECIMAL(P, S)`, extra decimal places are rounded to `S` places. For a negative value, the magnitude is rounded before the minus sign is restored. Thus `-1.235` rounded to two decimal places is `-1.24`, not `-1.23`:

```sql
SELECT
  CAST('1.235' AS DECIMAL(4, 2)) AS positive,
  CAST('-1.235' AS DECIMAL(4, 2)) AS negative,
  CAST('1.2' AS DECIMAL(4, 2)) AS padded;
```

Result:

```text
+----------+----------+--------+
| positive | negative | padded |
+----------+----------+--------+
| 1.24     | -1.24    | 1.20   |
+----------+----------+--------+
```

The same rounding rule applies when inserting into a table column. Continuing from the table above, this query returns `1.24`:

```sql
INSERT INTO decimal_example (device_id, price, ts)
VALUES (4, 1.235, 4000);

SELECT price FROM decimal_example WHERE device_id = 4;
```

Result:

```text
+-------+
| price |
+-------+
| 1.24  |
+-------+
```

The rounded result must still fit the declared type. The maximum for `DECIMAL(5, 2)` is `999.99`. Because `999.995` rounds to `1000.00`, a regular `CAST` fails:

```sql
SELECT CAST('999.995' AS DECIMAL(5, 2)) AS too_large;
```

Result: an error because `1000.00` is outside the representable range of `DECIMAL(5, 2)`.

Use `TRY_CAST` if you want a failed conversion to return `NULL`. The second and third columns below are `NULL`:

```sql
SELECT
  CAST('999.99' AS DECIMAL(5, 2)) AS largest_value,
  TRY_CAST('999.995' AS DECIMAL(5, 2)) AS overflow_value,
  TRY_CAST('not-a-number' AS DECIMAL(5, 2)) AS invalid_value;
```

Result:

```text
+---------------+----------------+---------------+
| largest_value | overflow_value | invalid_value |
+---------------+----------------+---------------+
| 999.99        | NULL           | NULL          |
+---------------+----------------+---------------+
```

### Avoid Converting Long Numbers to Floating Point First

An unquoted long number is parsed as a floating-point value before it is converted to `DECIMAL`. Digits lost in that floating-point conversion cannot be restored by a later `CAST`. To preserve all the digits, write the value as text and convert it to the intended type:

```sql
SELECT
  CAST('12345678901234567890.12' AS DECIMAL(22, 2)) AS exact_number,
  CAST(12345678901234567890.12 AS DECIMAL(22, 2)) AS converted_number;
```

Result:

```text
+-------------------------+-------------------------+
| exact_number            | converted_number        |
+-------------------------+-------------------------+
| 12345678901234567890.12 | 12345678901234567741.44 |
+-------------------------+-------------------------+
```

### Floating-Point Values That Cannot Be Converted

`NaN` and infinity cannot be converted to `DECIMAL`. With `TRY_CAST`, a failed conversion returns `NULL`:

```sql
SELECT
  TRY_CAST(CAST('NaN' AS DOUBLE) AS DECIMAL(9, 2)) AS nan_value,
  TRY_CAST(CAST('Infinity' AS DOUBLE) AS DECIMAL(9, 2)) AS infinity_value;
```

Result:

```text
+-----------+----------------+
| nan_value | infinity_value |
+-----------+----------------+
| NULL      | NULL           |
+-----------+----------------+
```

### Converting to an Integer

Converting `DECIMAL` to an integer drops the fractional part instead of rounding:

```sql
SELECT
  CAST(CAST('12.99' AS DECIMAL(9, 2)) AS BIGINT) AS positive,
  CAST(CAST('-12.99' AS DECIMAL(9, 2)) AS BIGINT) AS negative;
```

Result:

```text
+----------+----------+
| positive | negative |
+----------+----------+
| 12       | -12      |
+----------+----------+
```

## Arithmetic

`DECIMAL` supports addition, subtraction, multiplication, division, and remainder. In this example, `a` is `10.00` and `b` is `4.00`, both typed as `DECIMAL(9, 2)`:

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

Result:

```text
+-------+------------+------------+----------+-----------+
| added | subtracted | multiplied | divided  | remainder |
+-------+------------+------------+----------+-----------+
| 14.00 | 6.00       | 40.0000    | 2.500000 | 2.00      |
+-------+------------+------------+----------+-----------+
```

The operation determines the result's `P` and `S`, which need not match the inputs. `P` is the maximum number of digits the result can hold, not the number of digits used by the particular values below:

| Operation | Value above | Result type above |
| --- | --- | --- |
| `a + b` | `14.00` | `DECIMAL(9, 2)` |
| `a - b` | `6.00` | `DECIMAL(9, 2)` |
| `a * b` | `40.0000` | `DECIMAL(9, 4)` |
| `a / b` | `2.500000` | `DECIMAL(9, 6)` |
| `a % b` | `2.00` | `DECIMAL(9, 2)` |

For these two `DECIMAL(9, 2)` inputs, addition, subtraction, and remainder keep 2 decimal places, multiplication uses 4, and division uses 6. The arithmetic result keeps the input's storage width, so its `P` is capped at 9 in this example. It does not automatically widen to 10, 19, or 15 digits merely because of the operation.

### When a Calculation Exceeds Its Range

`DECIMAL(9, 2)` can hold at most `9999999.99`. The addition below should produce `10000000.00`, which is out of range. The current version does not report an error at this step, but displays `1000000.00` after execution:

```sql
SELECT CAST(9999999.99 AS DECIMAL(9,2))
     + CAST(0.01 AS DECIMAL(9,2)) AS result;
```

Current-version display:

```text
+------------+
| result     |
+------------+
| 1000000.00 |
+------------+
```

This out-of-range result is unreliable. Do not treat the displayed value as the correct answer.

If a value during calculation exceeds what the current computation can hold, the query reports an arithmetic overflow error. For example:

```sql
> SELECT CAST('9999999.99' AS DECIMAL(9,2)) * CAST('2.00' AS DECIMAL(9,2)) AS result;
Arrow error: Arithmetic overflow: Overflow happened on: 999999999 * 200
```

Result: an arithmetic overflow error.

When calculating near the limit, explicitly convert the operands to a wider precision before the operation, not afterward. This addition returns `10000000.00`:

```sql
SELECT CAST('9999999.99' AS DECIMAL(18, 2))
     + CAST('0.01' AS DECIMAL(18, 2)) AS result;
```

Result:

```text
+-------------+
| result      |
+-------------+
| 10000000.00 |
+-------------+
```

### Calculate with Integers and Floating-Point Values

An ordinary SQL literal with a decimal point is a `DOUBLE` value, not an exact `DECIMAL`. This query therefore returns the floating-point approximation:

```sql
SELECT 0.1 + 0.2 AS approximate_result;
```

Result:

```text
+---------------------+
| approximate_result  |
+---------------------+
| 0.30000000000000004 |
+---------------------+
```

For exact decimal arithmetic, explicitly give both operands a `DECIMAL` type. The first query returns `14.34`. In the second query, the current version converts both `DECIMAL(9, 2)` and `BIGINT` to integers, dropping the fractional part of `12.34`, so the result is `14`. The third query mixes `DECIMAL` with `DOUBLE` and produces the floating-point value `3.75`; other decimal fractions can still be approximate:

```sql
SELECT CAST('12.34' AS DECIMAL(9, 2))
     + CAST(2 AS DECIMAL(9, 2)) AS exact_result;

SELECT CAST('12.34' AS DECIMAL(9, 2))
     + CAST(2 AS BIGINT) AS bigint_result;

SELECT CAST('1.25' AS DECIMAL(9, 2)) + CAST(2.5 AS DOUBLE) AS approximate_result;
```

Result:

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

## Aggregation

`DECIMAL` works with `SUM`, `AVG`, `MIN`, and `MAX`. Two aggregate results in the current version deserve special attention.

### AVG May Show More Decimal Places

The inputs below have two decimal places, but the average is displayed with six:

```sql
SELECT AVG(amount) AS average
FROM (
  VALUES
    (CAST('1.00' AS DECIMAL(9, 2))),
    (CAST('2.00' AS DECIMAL(9, 2))),
    (CAST('2.00' AS DECIMAL(9, 2)))
) AS t(amount);
```

Result:

```text
+----------+
| average  |
+----------+
| 1.666666 |
+----------+
```

The average of these three values is `5.00 ÷ 3`. The current version drops digits beyond the sixth decimal place, giving `1.666666` instead of `1.666667`, which rounding to six places would produce.

### SUM May Display an Incorrect Out-of-Range Result

The correct sum of the two values below is `10000000.00`, which exceeds the range of the input type `DECIMAL(9, 2)`. The current version does not reliably report an error and instead displays `1000000.00`:

```sql
SELECT SUM(amount) AS total
FROM (
  VALUES
    (CAST('9999999.99' AS DECIMAL(9, 2))),
    (CAST('0.01' AS DECIMAL(9, 2)))
) AS t(amount);
```

Result:

```text
+------------+
| total      |
+------------+
| 1000000.00 |
+------------+
```

If the sum may exceed the column's range, convert the inputs to a sufficiently large precision before summing. For the same two values, the following query returns the correct `10000000.00`:

```sql
SELECT SUM(CAST(amount AS DECIMAL(18, 2))) AS total
FROM (
  VALUES
    (CAST('9999999.99' AS DECIMAL(9, 2))),
    (CAST('0.01' AS DECIMAL(9, 2)))
) AS t(amount);
```

Result:

```text
+-------------+
| total       |
+-------------+
| 10000000.00 |
+-------------+
```
