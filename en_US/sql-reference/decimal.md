---
title: "DECIMAL"
description: "Syntax, precision, range, arithmetic, conversions, storage widths, and overflow behavior of the Datalayers DECIMAL fixed-point type."
---

# DECIMAL

## Description

`DECIMAL(P, S)` is an exact fixed-point numeric type. Use it for monetary values, measurements, and other data that must not incur binary floating-point error.

- `P` (precision) is the total number of significant decimal digits.
- `S` (scale) is the number of digits to the right of the decimal point.
- At most `P - S` digits can appear to the left of the decimal point.

`DECIMAL`, `DEC`, and `NUMERIC` are aliases for the same logical type. Schema output always uses `DECIMAL(P, S)`.

## Syntax

```sql
DECIMAL
DECIMAL(P)
DECIMAL(P, S)
```

The aliases can be used in the same way:

```sql
DEC(P, S)
NUMERIC(P, S)
```

The parameters must satisfy:

```text
1 <= P <= 76
0 <= S <= P
```

Omitted parameters use the following defaults:

| Declaration | Canonical type |
| --- | --- |
| `DECIMAL`, `DEC`, or `NUMERIC` | `DECIMAL(38, 10)` |
| `DECIMAL(P)` | `DECIMAL(P, 0)` |
| `DECIMAL(P, S)` | `DECIMAL(P, S)` |

::: tip
Databases use different defaults for an unparameterized `DECIMAL`. Always specify `P` and `S` when portability is important.
:::

## Value Range

The absolute value of a `DECIMAL(P, S)` must be less than `10^(P-S)`. Its smallest step is `10^(-S)`.

For example, the range of `DECIMAL(5, 2)` is `[-999.99, 999.99]`.

| Type | Minimum | Maximum |
| --- | ---: | ---: |
| `DECIMAL(3, 0)` | `-999` | `999` |
| `DECIMAL(5, 2)` | `-999.99` | `999.99` |
| `DECIMAL(9, 9)` | `-0.999999999` | `0.999999999` |

`NULL` is not subject to this range.

## Storage Width

Datalayers selects the smallest Arrow Decimal physical type for the declared precision. SQL users continue to declare only `DECIMAL(P, S)`.

| Precision | Internal physical type | Width per non-NULL value |
| ---: | --- | ---: |
| `1` to `9` | Decimal32 | 4 bytes |
| `10` to `18` | Decimal64 | 8 bytes |
| `19` to `38` | Decimal128 | 16 bytes |
| `39` to `76` | Decimal256 | 32 bytes |

The declared `P` determines the physical width for the entire column. It does not vary with the value in an individual row. A smaller precision therefore reduces value storage in memtables, query batches, and Parquet files.

## Conversion and Rounding

Regular writes and `CAST` use the same fixed-point quantization rules:

| Input condition | Behavior |
| --- | --- |
| Fewer than `S` fractional digits | Pad zeros on the right |
| More than `S` fractional digits | Round half away from zero |
| Quantized value has more than `P` digits | Return a numeric overflow error |
| Convert `NaN` or infinity to Decimal | Return an error |
| `NULL` | Preserve `NULL` |

Example:

```sql
SELECT
  CAST('1.235' AS DECIMAL(4, 2)),
  CAST('-1.235' AS DECIMAL(4, 2));
```

```text
1.24  -1.24
```

Text input is parsed exactly as a decimal value, including scientific notation. It is not converted through `FLOAT` or `DOUBLE` first:

```sql
SELECT
  CAST('123.4500' AS DECIMAL(10, 4)),
  CAST('1.23e5' AS DECIMAL(10, 2));
```

An untyped SQL numeric literal with a decimal point, such as `1.235`, is parsed as an exact Decimal and does not pass through binary floating point. Untyped scientific notation uses an exact-Decimal-first policy with a Float64 fallback:

| Literal | Inferred type | Explanation |
| --- | --- | --- |
| `1e2` | `DECIMAL(3, 0)` | Expands exactly to `100` |
| `2e38` | `DECIMAL(39, 0)` | The 39-digit integer fits Decimal76 |
| `1e-76` | `DECIMAL(76, 76)` | Scale 76 is the Decimal256 boundary |
| `1e76`, `1e-77`, `1e308` | `DOUBLE` | Fixed-point expansion needs more than 76 digits, so approximate floating-point semantics apply |
| `0e999` | `DECIMAL(1, 0)` | A zero exponent does not change the value's range |

This fallback applies only to untyped scientific-notation literals. An explicit `CAST('1e308' AS DECIMAL(P, S))` still follows the target Decimal contract and returns overflow when the value does not fit; it never silently becomes `DOUBLE`. Typed floating-point contexts, such as vector functions, coerce their inputs according to the function signature.

Converting Decimal to an integer truncates toward zero:

```sql
SELECT
  CAST(CAST(12.99 AS DECIMAL(9, 2)) AS BIGINT),
  CAST(CAST(-12.99 AS DECIMAL(9, 2)) AS BIGINT);
```

```text
12  -12
```

`CAST` returns an error for invalid text or overflow. `TRY_CAST` returns `NULL` for the same input:

```sql
SELECT TRY_CAST(99.95 AS DECIMAL(3, 1));
```

```text
NULL
```

## Arithmetic

Decimal supports `+`, `-`, `*`, `/`, and `%`. Datalayers widens the internal physical type before evaluation when necessary, so a result does not overflow merely because its inputs use Decimal32, Decimal64, or Decimal128.

For operands `DECIMAL(P1, S1)` and `DECIMAL(P2, S2)`, result precision and scale are derived as follows:

| Operation | Result precision | Result scale |
| --- | --- | --- |
| `+`, `-` | `max(P1-S1, P2-S2) + max(S1, S2) + 1` | `max(S1, S2)` |
| `*` | `P1 + P2 + 1` | `S1 + S2` |
| `/` | `P1 + result_scale - S1 + S2` | `min(S1 + 4, 76)` |
| `%` | `min(P1-S1, P2-S2) + max(S1, S2)` | `max(S1, S2)` |

The precision of the public result type is capped at 76. If a formula requires more than 76 digits, Datalayers uses a precision-76 result type and validates the actual value during execution. Operations on small values can therefore succeed, while an actual result wider than 76 digits returns numeric overflow.

```sql
SELECT
  CAST(9999999.99 AS DECIMAL(9, 2))
  + CAST(0.01 AS DECIMAL(9, 2));
```

```text
10000000.00
```

An integer in Decimal arithmetic is treated as an exact scale-zero value. Decimal arithmetic with `FLOAT` or `DOUBLE` follows the floating-point path and is no longer guaranteed to be decimal-exact. Cast the floating-point operand to Decimal first when an exact result is required.

## Aggregate Operations

`SUM` and `AVG` accumulate in exact decimal arithmetic and check for overflow. If the result exceeds the result type, the query returns numeric overflow rather than a silently incorrect value. Their result types are:

| Aggregate | Input | Result |
| --- | --- | --- |
| `SUM` | `DECIMAL(P, S)` | `DECIMAL(min(P+10, 76), S)` |
| `AVG` | `DECIMAL(P, S)` | `DECIMAL(min(P+4, 76), min(S+4, 76))` |
| `MIN`, `MAX` | `DECIMAL(P, S)` | `DECIMAL(P, S)` |

`SUM` and `AVG` ignore `NULL`. They return `NULL` for an empty or all-NULL input. Regular, `DISTINCT`, and window aggregates use the same overflow checks.

```sql
SELECT SUM(amount), AVG(amount)
FROM decimal_example;
```

If the final aggregate exceeds its result type, the query returns numeric overflow.

## Examples

### Create a Table

This example creates a time-series table containing all four precision ranges:

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

### Insert and Query Values

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

A Decimal column can also be an entity key in a TimeSeries table, but it cannot be the timestamp key.

## Overflow and Error Handling

The following conditions return an error:

- `P` is outside `[1, 76]`;
- `S` is outside `[0, P]`;
- a write, default value, or `CAST` produces more than `P` digits after quantization;
- an arithmetic or aggregate result exceeds the result type;
- text input is malformed;
- `NaN` or infinity is converted to Decimal;
- a Decimal column is declared as the timestamp key.

```sql
SELECT CAST('99.95' AS DECIMAL(3, 1));
```

This value rounds to `100.0`, which needs precision 4, so the query returns numeric overflow.

## Arrow Flight SQL Considerations

Arrow clients see the precision-selected `Decimal32`, `Decimal64`, `Decimal128`, or `Decimal256` type together with its `(P, S)` metadata.

- Prepared statement parameters may use any Arrow Decimal family. The server performs a checked conversion to the target column's `(P, S)` and physical family.
- TimeSeries Flight DoPut and direct `RecordBatch` ingestion currently require the input array's Decimal family, `P`, and `S` to match the table schema exactly. For example, a `DECIMAL(8, 2)` column expects `Decimal32(8, 2)`, not a logically equivalent `Decimal128(8, 2)` array.
- Query results retain the Arrow Decimal family selected for the column or expression. They are not unconditionally widened to Decimal128.
