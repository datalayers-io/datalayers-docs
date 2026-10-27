---
title: "File Encryption and Decryption"
description: "Encrypt Parquet data files with table and column keys, including table creation, writes, queries, and key handling."
---

# File Encryption and Decryption

Datalayers supports encryption for the Parquet data files of TimeSeries tables. Supply a key when creating a table, and Datalayers encrypts data as it writes files and decrypts it during queries. Applications continue to use ordinary `INSERT` and `SELECT` statements without calling encryption functions.

You can set a default key for a table and override it for individual ordinary data columns. File encryption protects selected contents of stored files. Users with query permission still receive plaintext results.

## Prepare a Key

`ENCRYPTION_KEY` takes the actual key used to encrypt and decrypt data, also called a data encryption key (DEK). Supply a hexadecimal string, rather than a password, a key name, or a key ID in a KMS.

| Key size | Hexadecimal characters | Encryption |
| --- | --- | --- |
| 16 bytes | 32 characters | AES-128-GCM |
| 32 bytes | 64 characters | AES-256-GCM |

Two hexadecimal characters represent one byte, so 32 characters represent 16 bytes, not 32 bytes. Use `0–9`, `a–f`, or `A–F`, without a `0x` prefix or spaces. The current version does not support 24-byte keys.

On a system with OpenSSL installed, generate a random 32-byte key with:

```shell
openssl rand -hex 32
```

Use the 64 characters in the output as the `ENCRYPTION_KEY` value and keep the key safe.

::: warning
The keys in the SQL examples below are public demonstration values. Replace them with your own randomly generated keys in production.
:::

## Use a Table Key(Recommend)

Set `ENCRYPTION_KEY` in the `WITH` clause of `CREATE TABLE`. The following table uses a 32-byte key:

```sql
CREATE TABLE encrypted_table_example (
  device_id STRING NOT NULL,
  ts TIMESTAMP(3) NOT NULL,
  phone STRING,
  reading BIGINT,
  PRIMARY KEY (device_id, ts),
  TIMESTAMP KEY(ts)
)
PARTITION BY HASH(device_id) PARTITIONS 1
ENGINE=TimeSeries
WITH (
  ENCRYPTION_KEY='00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff'
);
```

In this table, `phone` and `reading` are ordinary data columns and use the table key by default. The file footer, which contains metadata used to read the file, also uses the table key. `device_id` is a primary-key and partition column, and `ts` is the timestamp column. Their column data is outside the scope of this encryption feature.

### Insert and Query

Insert the original values directly. The phone numbers below are business data; the key was already configured when the table was created:

```sql
INSERT INTO encrypted_table_example (device_id, ts, phone, reading)
VALUES
  ('device-1', 1735689600000, '13800138000', 10),
  ('device-2', 1735689601000, '13900139000', 20);

SELECT device_id, phone, reading
FROM encrypted_table_example
ORDER BY device_id;
```

Result:

```text
+-----------+-------------+---------+
| device_id | phone       | reading |
+-----------+-------------+---------+
| device-1  | 13800138000 | 10      |
| device-2  | 13900139000 | 20      |
+-----------+-------------+---------+
```

Normal ingestion does not require a manual flush. To wait until the current in-memory data has been written to files before querying, run:

```sql
FLUSH TABLE encrypted_table_example SYNC;

SELECT COUNT(*) AS row_count, SUM(reading) AS total_reading
FROM encrypted_table_example;
```

Result:

```text
+-----------+---------------+
| row_count | total_reading |
+-----------+---------------+
| 2         | 30            |
+-----------+---------------+
```

`SYNC` waits for this flush to finish. When querying file data, Datalayers retrieves the saved table key and decrypts automatically. The query does not need to supply the key again.

## Use a Different Key for a Column

Add `ENCRYPTION_KEY 'key'` after the type of an ordinary data column to override its table key. Column options use no equals sign; table options belong in the `WITH` clause.

The following table gives `phone` a separate 16-byte key. Other ordinary data columns continue to use the table key:

```sql
CREATE TABLE encrypted_column_example (
  device_id STRING NOT NULL,
  ts TIMESTAMP(3) NOT NULL,
  phone STRING ENCRYPTION_KEY 'ffeeddccbbaa99887766554433221100',
  reading BIGINT,
  PRIMARY KEY (device_id, ts),
  TIMESTAMP KEY(ts)
)
PARTITION BY HASH(device_id) PARTITIONS 1
ENGINE=TimeSeries
WITH (
  ENCRYPTION_KEY='00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff'
);
```

The table uses keys as follows:

| Content | Key |
| --- | --- |
| `phone` column data | The key configured for `phone` |
| `reading` column data | The table key |
| File footer | The table key |
| `device_id` and `ts` column data | Not encrypted by this feature |

A column key does not leave other ordinary data columns in plaintext. A table key is also required; configuring column keys alone is not supported.

Writes, filters, and `NULL` values work as usual:

```sql
INSERT INTO encrypted_column_example (device_id, ts, phone, reading)
VALUES
  ('device-1', 1735689600000, '13800138000', 10),
  ('device-2', 1735689601000, NULL, 20);

FLUSH TABLE encrypted_column_example SYNC;

SELECT device_id, reading
FROM encrypted_column_example
WHERE phone = '13800138000'
ORDER BY device_id;
```

Result:

```text
+-----------+---------+
| device_id | reading |
+-----------+---------+
| device-1  | 10      |
+-----------+---------+
```

## Encryption Scope

This feature applies to Parquet data files of TimeSeries tables. It does not encrypt the entire database directory.

| Content | Encrypted by this feature |
| --- | --- |
| Ordinary column data in Parquet files | Yes, with the column key or table key |
| Parquet file footer | Yes, with the table key |
| Column data for timestamp, primary-key, partition, and engine-internal columns | No |
| WAL, database metadata, and separate index files | No |
| SQL query results and network traffic between clients and the server | No |

File encryption does not prevent authorized query users from reading plaintext data. Database privileges still control data access.

## Performance Impact

File encryption leaves SQL syntax and query results unchanged, but some queries may take longer. The impact mainly depends on how much data the query needs to check, which columns it uses, and whether it is the first query.

The examples below use the earlier `encrypted_table_example` table. Its `phone` and `reading` columns are encrypted; `device_id` and `ts` are not.

### Calculate a Total or Average

```sql
SELECT SUM(reading) AS total_reading
FROM encrypted_table_example;
```

This SQL sums `reading` across the entire table. When it needs to process a large amount of encrypted data, it may take longer than the same query on a plaintext table. Also consider this impact for `AVG(reading)` and queries that group results by device. If you only need statistics for a particular period, restrict the time range in `WHERE`.

### Find a Device by Phone Number

```sql
SELECT device_id
FROM encrypted_table_example
WHERE phone = '13800138000';
```

Although the result only returns the unencrypted `device_id`, the condition uses the encrypted `phone` column and can add latency. Returning one device can still require checking many records. If you know the device or time range, add those conditions to narrow the search.

### Query a Device Within a Time Range

```sql
SELECT phone, reading
FROM encrypted_table_example
WHERE device_id = 'device-1'
  AND ts >= TIMESTAMP '2025-01-01 00:00:00'
  AND ts < TIMESTAMP '2025-01-01 00:00:01';
```

Filtering by device and time still applies and can usually reduce the amount of data processed. This SQL returns the encrypted `phone` and `reading` columns, so it may still take longer than a plaintext query with the same conditions. If you only need device IDs and timestamps, select just `device_id` and `ts` to avoid fetching phone numbers and readings unnecessarily.

### Count All Rows in a Table

```sql
SELECT COUNT(*) AS row_count
FROM encrypted_table_example;
```

After a service restart or when a table is first accessed, the database needs to prepare information for reading its files. File encryption can add to this initial work. Even a row-count query can therefore take longer than its plaintext equivalent on first access. Repeated queries may be faster because of caching, so evaluate first and repeated executions separately.

### Write Performance

In the tested bulk-ingestion workloads, file encryption had no noticeable impact on write performance. 

## Key Storage and Recovery

Table and column keys are persisted with table metadata. Closing a client session, reconnecting, or restarting the service does not require you to register or set the keys again. Datalayers continues to use the saved configuration to read and write files.

In the current version, you supply the actual DEKs. Datalayers does not automatically generate or rotate them, or manage them through a KMS. Keys are stored as recoverable hexadecimal values in database metadata, without encryption by a separate master key. Restrict access to database metadata and backups.

`SHOW CREATE TABLE` displays the actual keys. Exports containing table creation statements may also contain keys, so handle these outputs as sensitive information. To recover encrypted data, retain the corresponding keys and table definitions. Encrypted files alone cannot recover the original data if the keys are lost.

## Current Limitations

- Only TimeSeries tables are supported, and a table must have at least one ordinary data column.
- You cannot configure an individual key for a timestamp, primary-key, partition, or engine-internal column.
- Column keys require a table key. Tables with no ordinary data columns, where only the footer would need encryption, are not supported.
- Configure encryption when creating the table. You cannot use `ALTER` to enable encryption for an existing table or to set or replace keys, even with the same key value.
- Encrypted tables do not support `ADD COLUMN` or `DROP COLUMN`. You also cannot use `ADD COLUMN` to add a column with a key to a plaintext table.

Table renaming and changes to unrelated options such as `FLUSH_INTERVAL` continue to follow their existing rules. Do not directly edit keys in persisted metadata, as existing files may become unreadable.

## Common Errors

| Error message fragment | Action |
| --- | --- |
| `expected 32 or 64 hexadecimal characters` | Check that the key contains exactly 32 or 64 hexadecimal characters. |
| `expected only hexadecimal characters` | Remove any `0x` prefix, spaces, or other non-hexadecimal characters. |
| `24-byte AES keys are not supported` | Use a 16-byte or 32-byte key. |
| `column ENCRYPTION_KEY requires a table ENCRYPTION_KEY` | Also configure a table key in `WITH`. |
| `ENCRYPTION_KEY is not supported for` | Check whether the column key was assigned to a timestamp, primary-key, or other special column. |
| `ENCRYPTION_KEY requires at least one ordinary value column` | Include an ordinary data column; a table containing only special columns is not supported. |
| `ALTER cannot set or replace ENCRYPTION_KEY` | Set keys when creating the table; changing them through ALTER is not supported. |
| `Adding columns to a table with Parquet encryption is not supported` | Adding columns to an encrypted table is not supported. |
| `Dropping columns from a table with Parquet encryption is not supported` | Dropping columns from an encrypted table is not supported. |
