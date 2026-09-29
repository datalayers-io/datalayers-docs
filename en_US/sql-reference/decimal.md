---
title: "DECIMAL"
description: "Learn how to store exact decimals with DECIMAL, and the common rules for writes, calculations, and conversions."
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

The next three results are `1.0000000000`, `1`, and `1.00`. Specify both `P` and `S` when creating tables to avoid confusion with defaults in other databases.

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

1. Wider representable range. The supported ranges for precision and scale have been significantly expanded.
2. Better performance. DECIMAL adapts storage by `P` (see the table below). Datalayers chooses the smallest footprint (memory/disk) for the declared `P`.

| Range of `P` | Footprint (memory/disk) |
| --- | --- |
| 1–9 | 4 bytes |
| 10–18 | 8 bytes |
| 19–38 | 16 bytes |
| 39–76 | 32 bytes |

3. More complete precision inference. Different expressions apply different precision-derivation rules to determine the result precision.

## Create a Table, Insert, and Query

The following time-series table stores prices as `DECIMAL(9, 2)`. The timestamp key must still use a timestamp type; `DECIMAL` cannot be used as the timestamp key.

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

`DECIMAL` can also be an entity key. For example, this table includes `amount` in its primary key and partitions by it:

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

Filter and sort these values like other numeric columns. Because `price` is not marked `NOT NULL`, it also accepts `NULL`:

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

## Rounding and Values That Do Not Fit

When an input has more decimal places than `S`, Datalayers rounds it to the declared number of decimal places. The following results are `1.24`, `-1.24`, and `1.20`:

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

> SELECT CAST('999.995' AS DECIMAL(5, 2)) AS too_large;
Invalid argument error: 1000.00 is too large to store in a Decimal32 of precision 5. Max is 999.99
```

Error: `1000.00` is outside the representable range of `DECIMAL(5, 2)`.

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
| `a + b` | `14.00` | `DECIMAL(10, 2)` |
| `a - b` | `6.00` | `DECIMAL(10, 2)` |
| `a * b` | `40.0000` | `DECIMAL(19, 4)` |
| `a / b` | `2.500000` | `DECIMAL(15, 6)` |
| `a % b` | `2.00` | `DECIMAL(9, 2)` |

For these two `DECIMAL(9, 2)` inputs:

- Addition and subtraction keep 2 decimal places and reserve one more digit for a possible carry, giving `DECIMAL(10, 2)`.
- Multiplication combines the operands' decimal places, so `S` becomes 4. It also reserves more whole-number digits for larger products, giving `DECIMAL(19, 4)`.
- Division reserves four more decimal places for the quotient, so `S` becomes 6 and the result is `DECIMAL(15, 6)`.
- Remainder keeps 2 decimal places and returns `DECIMAL(9, 2)`.

The result's `P` is capped at 76. Even when a calculation rule would reserve more digits, a value that actually fits can still succeed. The query below returns `3`. An actual result that does not fit causes an error rather than being truncated:

```sql
SELECT CAST(1 AS DECIMAL(76, 0)) + CAST(2 AS DECIMAL(76, 0)) AS result;
```

Result:

```text
+--------+
| result |
+--------+
| 3      |
+--------+
```

### Calculate with Integers and Floating-Point Values

Datalayers treats an ordinary SQL literal with a decimal point as an exact decimal value. This query directly returns `0.3`; you do not need to rewrite `0.1` and `0.2` as text first:

```sql
SELECT 0.1 + 0.2 AS exact_result;
```

Result:

```text
+--------------+
| exact_result |
+--------------+
| 0.3          |
+--------------+
```

An integer can take part in a `DECIMAL` calculation as an exact value; the first query returns `14.34`. Explicitly mixing `DECIMAL` with `DOUBLE` uses approximate floating-point calculation. The second query returns `3.75`, but exact representation of every decimal fraction is no longer guaranteed:

```sql
SELECT CAST('12.34' AS DECIMAL(9, 2)) + CAST(2 AS BIGINT) AS exact_result;

SELECT CAST('1.25' AS DECIMAL(9, 2)) + CAST(2.5 AS DOUBLE) AS approximate_result;
```

Result:

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

## Aggregation

Use `SUM`, `AVG`, `MIN`, and `MAX` with `DECIMAL`. For the three rows below, the sum is `5.00`, the average is `1.666667`, and the minimum and maximum are `1.00` and `2.00`:

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

Result:

```text
+-------+----------+---------+---------+
| total | average  | minimum | maximum |
+-------+----------+---------+---------+
| 5.00  | 1.666667 | 1.00    | 2.00    |
+-------+----------+---------+---------+
```

- `SUM` adds values from multiple rows, so the total can be larger than any single input. It reserves more whole-number digits but keeps the same number of decimal places. Here, `DECIMAL(9, 2)` produces a `DECIMAL(19, 2)` result of `5.00`.
- `AVG` calculates a mean that may need more decimal places. Here, `5.00 / 3` rounds to six decimal places, giving `1.666667` with result type `DECIMAL(13, 6)`.
- `MIN` and `MAX` only select existing values, so they retain `DECIMAL(9, 2)`.

For other `DECIMAL(P, S)` inputs, `SUM` keeps `S` and reserves 10 more total digits. `AVG` reserves 4 more total digits and 4 more decimal places. Total precision is capped at 76; an actual aggregate result that does not fit causes an error.

You can also aggregate distinct values. The repeated `1.25` is counted once, so `SUM(DISTINCT amount)` returns `4.00`:

```sql
SELECT SUM(DISTINCT amount) AS distinct_total
FROM (
  VALUES
    (CAST('1.25' AS DECIMAL(9, 2))),
    (CAST('1.25' AS DECIMAL(9, 2))),
    (CAST('2.75' AS DECIMAL(9, 2)))
) AS t(amount);
```

Result:

```text
+----------------+
| distinct_total |
+----------------+
| 4.00           |
+----------------+
```

With no non-`NULL` values, `SUM` and `AVG` return `NULL`, not zero:

```sql
SELECT SUM(amount) AS total, AVG(amount) AS average
FROM (VALUES (CAST(NULL AS DECIMAL(9, 2)))) AS t(amount);
```

Result:

```text
+-------+---------+
| total | average |
+-------+---------+
| NULL  | NULL    |
+-------+---------+
```

## Conversions and Client Parameters

For a long decimal value, send the digits as text and explicitly convert them to the intended `DECIMAL` type. This avoids an approximate floating-point conversion in the client. The following result keeps all 22 digits:

```sql
SELECT CAST('12345678901234567890.12' AS DECIMAL(22, 2)) AS exact_number;
```

Result:

```text
+-------------------------+
| exact_number            |
+-------------------------+
| 12345678901234567890.12 |
+-------------------------+
```

Converting `DECIMAL` to an integer drops the decimal part; it does not round. The following results are `12` and `-12`:

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

`NaN` and infinity are not fixed-point decimal values and cannot be converted to `DECIMAL`. Use `TRY_CAST` to turn these failed conversions into `NULL`. Both columns below return `NULL`:

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

Converting to `DOUBLE` and back cannot restore digits already lost. The `0.1 + 0.2` SQL at the start shows this approximation. For Flight SQL prepared statements, bind values according to the parameter types returned by the server.
