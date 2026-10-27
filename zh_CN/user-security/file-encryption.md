---
title: "文件加解密"
description: "通过表级和列级密钥加密 Parquet 数据文件，了解建表、写入、查询和密钥保管方法。"
---

# 文件加解密

Datalayers 支持为 TimeSeries 表的 Parquet 数据文件配置加密。建表时提供密钥后，Datalayers 会在生成数据文件时加密，在查询时自动解密。应用仍然使用普通的 `INSERT` 和 `SELECT`，不需要调用加解密函数。

你可以为整张表设置默认密钥，也可以为指定的普通数据列设置不同的密钥。文件加密保护的是落盘后的部分数据内容；有查询权限的用户仍然会得到明文结果。

## 准备密钥

`ENCRYPTION_KEY` 接收直接用于数据加解密的密钥，也称为数据加密密钥（DEK）。传入的值必须是十六进制字符串，不是口令、密钥名称或 KMS 中的密钥 ID。

| 密钥字节数 | 十六进制字符数 | 加密方式 |
| --- | --- | --- |
| 16 字节 | 32 个字符 | AES-128-GCM |
| 32 字节 | 64 个字符 | AES-256-GCM |

每两个十六进制字符表示一个字节，因此 32 个字符表示 16 字节，而不是 32 字节。字符可以是 `0–9`、`a–f` 或 `A–F`，不要添加 `0x` 前缀或空格。当前不支持 24 字节密钥。

在安装了 OpenSSL 的终端中，可以生成一把 32 字节随机密钥：

```shell
openssl rand -hex 32
```

将输出的 64 个字符作为 `ENCRYPTION_KEY` 的值，并妥善保管。

::: warning
下面 SQL 中的密钥是公开演示值。生产环境请替换成自己生成的随机密钥，不要直接使用示例密钥。
:::

## 使用表级密钥(推荐)

在建表语句的 `WITH` 中设置 `ENCRYPTION_KEY`。下面的表使用一把 32 字节密钥：

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

在这个表中，`phone` 和 `reading` 是普通数据列，默认使用表级密钥加密。文件尾部元数据（footer，用于读取文件的元数据）也使用表级密钥加密。`device_id` 是主键和分区列，`ts` 是时间列，它们的列数据不在本功能的加密范围内。

### 写入和查询

直接写入原始值。下面的电话号码是业务数据，密钥已经在建表时设置：

```sql
INSERT INTO encrypted_table_example (device_id, ts, phone, reading)
VALUES
  ('device-1', 1735689600000, '13800138000', 10),
  ('device-2', 1735689601000, '13900139000', 20);

SELECT device_id, phone, reading
FROM encrypted_table_example
ORDER BY device_id;
```

结果：

```text
+-----------+-------------+---------+
| device_id | phone       | reading |
+-----------+-------------+---------+
| device-1  | 13800138000 | 10      |
| device-2  | 13900139000 | 20      |
+-----------+-------------+---------+
```

日常写入不需要手动 flush。如果希望等待当前内存数据写入文件后再查询，可以执行：

```sql
FLUSH TABLE encrypted_table_example SYNC;

SELECT COUNT(*) AS row_count, SUM(reading) AS total_reading
FROM encrypted_table_example;
```

结果：

```text
+-----------+---------------+
| row_count | total_reading |
+-----------+---------------+
| 2         | 30            |
+-----------+---------------+
```

`SYNC` 表示等待本次 flush 完成。查询文件中的数据时，Datalayers 会自动取得建表时保存的密钥并解密，SQL 不需要再次提供密钥。

## 为指定列使用不同密钥

在普通数据列的类型后添加 `ENCRYPTION_KEY '密钥'`，可以覆盖该列使用的表级密钥。列选项与表选项的写法不同：列选项不写等号，表选项写在 `WITH` 中。

下面让 `phone` 使用一把独立的 16 字节密钥，其他普通数据列继续使用表级密钥：

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

该表的密钥分配如下：

| 内容 | 使用的密钥 |
| --- | --- |
| `phone` 列数据 | `phone` 的列级密钥 |
| `reading` 列数据 | 表级密钥 |
| 文件 footer | 表级密钥 |
| `device_id`、`ts` 列数据 | 不通过本功能加密 |

列级密钥不会让其他普通数据列变成明文。目前必须同时提供表级密钥，不支持只设置列级密钥。

写入、筛选以及 `NULL` 值的使用方式保持不变：

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

结果：

```text
+-----------+---------+
| device_id | reading |
+-----------+---------+
| device-1  | 10      |
+-----------+---------+
```

## 加密范围

本功能针对 TimeSeries 表的 Parquet 数据文件，不是整个数据库目录的加密开关。

| 内容 | 是否通过本功能加密 |
| --- | --- |
| 普通数据列在 Parquet 文件中的列数据 | 是，使用列级密钥或表级密钥 |
| Parquet 文件 footer | 是，使用表级密钥 |
| 时间列、主键列、分区列及引擎内部列的列数据 | 否 |
| WAL、数据库元数据及独立索引文件 | 否 |
| SQL 查询结果、客户端与服务端之间的网络传输 | 否 |

文件加密不会限制有权限执行查询的用户查看明文数据，数据访问仍由数据库权限控制。

## 性能影响

启用文件加密后，SQL 的写法和返回结果保持不变，部分查询可能需要更长时间。影响主要取决于查询要检查多少数据、用到哪些列，以及是否为首次查询。

下面继续使用前面的 `encrypted_table_example` 表，其中 `phone` 和 `reading` 已加密，`device_id` 和 `ts` 未加密。

### 计算总量或平均值

```sql
SELECT SUM(reading) AS total_reading
FROM encrypted_table_example;
```

这条 SQL 汇总整张表的 `reading`，需要处理较多加密数据时，耗时可能比未加密表增加。`AVG(reading)`、按设备分组统计等查询也应关注这一影响。如果业务只需要某段时间的统计结果，应在 `WHERE` 中限定时间范围。

### 按手机号查找设备

```sql
SELECT device_id
FROM encrypted_table_example
WHERE phone = '13800138000';
```

虽然结果只返回未加密的 `device_id`，查询条件仍然使用了加密的 `phone`，因此可能增加耗时。即使最终只返回一个设备，也可能需要检查大量记录。已知设备或时间范围时，可以同时增加相应条件，缩小查找范围。

### 查询某台设备在指定时间段的数据

```sql
SELECT phone, reading
FROM encrypted_table_example
WHERE device_id = 'device-1'
  AND ts >= TIMESTAMP '2025-01-01 00:00:00'
  AND ts < TIMESTAMP '2025-01-01 00:00:01';
```

按设备和时间筛选仍然适用，通常有助于减少需要处理的数据。这条 SQL 返回加密的 `phone` 和 `reading`，仍可能比相同条件下的未加密表增加耗时。如果业务只需要设备编号和时间，就只选择 `device_id`、`ts`，避免额外读取电话号码和测量值。

### 统计表的总行数

```sql
SELECT COUNT(*) AS row_count
FROM encrypted_table_example;
```

服务重启后或首次访问表时，数据库需要先准备读取文件所需的信息，文件加密也可能增加这一步的耗时。因此，即使只统计行数，首次查询也可能比未加密表慢。重复执行时可能因缓存而更快，比较性能时应分别观察首次和多次执行的结果。

### 如何评估业务影响

使用实际业务 SQL 和数据，分别比较加密与未加密表的响应时间和并发查询吞吐。取出较少列、按设备和时间限制范围仍然是有效做法；不需要所有字段时，避免使用 `SELECT *`。不要仅根据返回行数判断查询工作量，也不要把某一条 SQL 的耗时变化当作所有查询的固定增幅。

写入与查询应分别评估。批量写入吞吐接近，不表示每条查询的耗时也接近。评估写入时，应包括最后一批数据落盘完成的时间；评估查询时，应覆盖常用统计、条件查找和时间范围查询，并区分首次查询与重复查询。

## 密钥保存与恢复

表级和列级密钥会随表元数据持久化。关闭客户端会话、重新连接或重启服务后，不需要再次注册或设置密钥；Datalayers 会继续使用表元数据中的配置读写文件。

当前版本由你提供实际 DEK，不会自动生成、轮换密钥，也不通过 KMS 托管密钥。密钥以可恢复的十六进制形式保存在数据库元数据中，并未由另一把主密钥加密。请限制数据库元数据和备份文件的访问权限。

`SHOW CREATE TABLE` 会显示真实密钥；包含建表语句的导出文件也可能携带密钥。请将这些输出作为敏感信息保管。恢复加密数据时，需要保留对应的密钥和表结构；如果密钥丢失，无法仅凭加密文件恢复原始数据。

## 当前使用限制

- 仅支持 TimeSeries 表，且至少包含一个普通数据列。
- 不支持给时间列、主键列、分区列或引擎内部列单独配置密钥。
- 不支持只设置列级密钥，也不支持只有 footer 需要加密、没有普通数据列的表。
- 加密配置必须在建表时确定，不支持通过 `ALTER` 为已有表启用加密、设置或更换密钥，包括重新设置同一把密钥。
- 加密表暂不支持 `ADD COLUMN` 和 `DROP COLUMN`；普通表也不能通过 `ADD COLUMN` 添加带密钥的列。

重命名表、修改 `FLUSH_INTERVAL` 等非加密选项仍遵循原有规则。不要直接修改持久化元数据中的密钥，否则已有文件可能无法解密。

## 常见错误

| 错误信息片段 | 处理方式 |
| --- | --- |
| `expected 32 or 64 hexadecimal characters` | 检查密钥是否恰好为 32 或 64 个十六进制字符。 |
| `expected only hexadecimal characters` | 移除 `0x` 前缀、空格或其他非十六进制字符。 |
| `24-byte AES keys are not supported` | 改用 16 字节或 32 字节密钥。 |
| `column ENCRYPTION_KEY requires a table ENCRYPTION_KEY` | 在 `WITH` 中同时配置表级密钥。 |
| `ENCRYPTION_KEY is not supported for` | 检查是否把列级密钥配置在时间列、主键列等特殊列上。 |
| `ENCRYPTION_KEY requires at least one ordinary value column` | 表中需要有普通数据列，不能只有时间列和主键等特殊列。 |
| `ALTER cannot set or replace ENCRYPTION_KEY` | 在建表时确定密钥，当前不支持通过 ALTER 修改。 |
| `Adding columns to a table with Parquet encryption is not supported` | 当前加密表不支持新增列。 |
| `Dropping columns from a table with Parquet encryption is not supported` | 当前加密表不支持删除列。 |
