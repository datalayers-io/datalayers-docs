---
title: "File Encryption and Decryption"
description: "Encrypt Parquet data files with a table key, including table creation, writes, queries, column changes, and key handling."
---

# File Encryption and Decryption

Datalayers supports encryption for the Parquet data files of TimeSeries tables. Supply a key when creating a table, and Datalayers encrypts data as it writes files and decrypts it during queries.

You can configure a key for each table through the `ENCRYPTION_KEY` table option. The key applies to all ordinary columns, excluding primary-key, timestamp, and partition columns.

## Prepare a Key

`ENCRYPTION_KEY` takes the actual key used to encrypt and decrypt data. Supply a hexadecimal string.

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

## Configure a Table Key

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

In this table, `phone` and `reading` are ordinary data columns and use the table key. `device_id` is a primary-key and partition column, and `ts` is the timestamp column. Their column data is outside the scope of this encryption feature.

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

Normal ingestion does not require a manual flush. For this demonstration, run FLUSH to ensure that in-memory data is written to disk.

`SYNC` waits for this flush to finish. When querying file data, Datalayers retrieves the saved table key and decrypts automatically. The query does not need to supply the key again.

Run the following statements:

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

## Add and Drop Columns

Encrypted tables support ordinary `ADD COLUMN` and `DROP COLUMN` statements, subject to the existing TimeSeries rules for column changes. A new ordinary data column automatically uses the table key; you do not need to supply the key again:

```sql
ALTER TABLE encrypted_table_example ADD COLUMN voltage DOUBLE;
```

When the column is no longer needed, you can drop it:

```sql
ALTER TABLE encrypted_table_example DROP COLUMN voltage;
```

Note: The table key can only be set when creating the table and cannot be changed afterward. If all ordinary data columns are dropped, leaving only special columns such as timestamp and primary-key columns, newly written files are not encrypted. Adding an ordinary data column again causes subsequently written files to resume encrypting ordinary data columns with the table key.

## Encryption Scope

This feature applies to Parquet data files of TimeSeries tables. It does not encrypt the entire database directory.

| Content | Encrypted by this feature |
| --- | --- |
| Ordinary column data in Parquet files | Yes, with the table key |
| Parquet file footer | Encrypted with the table key when the file contains ordinary data columns; otherwise unencrypted |
| Timestamp, primary-key, and partition columns | No |
| WAL, database metadata, and separate index files (such as inverted and vector index files) | No |
| SQL query results and network traffic between clients and the server | No |

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

After a service restart or when a table is first accessed, the database needs to prepare information for reading its files. File encryption can add to this initial work. Even a row-count query can therefore take longer than its plaintext equivalent on first access.

### Write Performance

In the tested bulk-ingestion workloads, file encryption had no noticeable impact on write performance.

## Key Storage and Recovery

The table key is persisted with table metadata. Closing a client session, reconnecting, or restarting the service does not require you to register or set the key again. Datalayers continues to use the saved configuration to read and write files.

The current version does not support managing keys through a KMS. Keys are stored as recoverable hexadecimal values in database metadata. Restrict access to database metadata and backups.

Running `SHOW CREATE TABLE` from a client displays the actual key so you can check the configured value. Exports containing table creation statements also include the key. Handle these outputs as sensitive information. To recover encrypted data, retain the corresponding keys and table definitions. Encrypted files alone cannot recover the original data if the keys are lost.

Server SQL logs, including slow-query and audit logs, mask `ENCRYPTION_KEY` values as `[REDACTED]`; this does not change the executed SQL or results returned to clients.

## Current Limitations

- Only TimeSeries tables are supported. Parquet encryption is enabled for new files only when the table contains ordinary data columns.
- Only table keys are supported. Separate column keys are not currently supported, and you cannot disable encryption for an individual ordinary data column.
- Configure encryption when creating the table. You cannot use `ALTER TABLE ... MODIFY OPTIONS ENCRYPTION_KEY` to enable encryption for an existing table or to set or replace its table key, even with the same key value.

Table renaming and changes to unrelated options such as `FLUSH_INTERVAL` continue to follow their existing rules. Do not directly edit keys in persisted metadata, as existing files may become unreadable.

## Common Errors

| Error message fragment | Action |
| --- | --- |
| `expected 32 or 64 hexadecimal characters` | Check that the key contains exactly 32 or 64 hexadecimal characters. |
| `expected only hexadecimal characters` | Remove any `0x` prefix, spaces, or other non-hexadecimal characters. |
| `24-byte AES keys are not supported` | Use a 16-byte or 32-byte key. |
| `ALTER TABLE cannot set or replace the table ENCRYPTION_KEY` | Set keys when creating the table; changing them through ALTER is not supported. |
