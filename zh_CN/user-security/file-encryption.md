---
title: "文件加解密"
description: "通过表级密钥加密 Parquet 数据文件，了解建表、写入、查询、增删列和密钥保管方法。"
---

# 文件加解密

Datalayers 支持为 TimeSeries 表的 Parquet 数据文件配置加密。建表时提供密钥后，Datalayers 会在生成数据文件时加密，在查询时自动解密。

每张表可以通过 Table Option `ENCRYPTION_KEY` 配置密钥，该密钥作用于除主键列和时间列,分区列以外的所有普通列。

## 准备密钥

`ENCRYPTION_KEY` 接收直接用于数据加解密的密钥。传入的值必须是十六进制字符串。

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

## 配置表级密钥

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

在这个表中，`phone` 和 `reading` 是普通数据列，使用表级密钥加密。。`device_id` 是主键和分区列，`ts` 是时间列，它们的列数据不在本功能的加密范围内。

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

日常写入不需要手动 flush。这里为了演示，执行 FLUSH 确保内存数据写入磁盘。

`SYNC` 表示等待本次 flush 完成。查询文件中的数据时，Datalayers 会自动取得建表时保存的密钥并解密，SQL 不需要再次提供密钥。

可以执行：

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

## 新增和删除列

加密表可以使用普通的 `ADD COLUMN` 和 `DROP COLUMN`，仍遵循 TimeSeries 表原有的列变更限制。新增普通数据列会自动使用表级密钥，不需要再次提供密钥：

```sql
ALTER TABLE encrypted_table_example ADD COLUMN voltage DOUBLE;
```

不再需要该列时，可以删除：

```sql
ALTER TABLE encrypted_table_example DROP COLUMN voltage;
```
注意: 表级密钥只能在建表时设置，设置后不支持更改, 全部普通数据列已删除，只剩时间列、主键列等特殊列，新写的文件不会再加密，之后再次新增普通数据列，再次新写的文件将恢复使用表级密钥加密普通数据列。

## 加密范围

本功能针对 TimeSeries 表的 Parquet 数据文件，不是整个数据库目录的加密开关。

| 内容 | 是否通过本功能加密 |
| --- | --- |
| 普通数据列在 Parquet 文件中的列数据 | 是，使用表级密钥 |
| Parquet 文件 footer | 文件中有普通数据列时，使用表级密钥加密；否则不加密 |
| 时间列、主键列、分区列 | 否 |
| WAL、数据库元数据及独立索引文件（如倒排索引、向量索引文件） | 否 |
| SQL 查询结果、客户端与服务端之间的网络传输 | 否 |

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

服务重启后或首次访问表时，数据库需要先准备读取文件所需的信息，文件加密也可能增加这一步的耗时。因此，即使只统计行数，首次查询也可能比未加密表慢。

### 写入性能

在已验证的批量写入场景中，文件加密对写入性能没有明显影响。

## 密钥保存与恢复

表级密钥会随表元数据持久化。关闭客户端会话、重新连接或重启服务后，不需要再次注册或设置密钥；Datalayers 会继续使用表元数据中的配置读写文件。

当前版本暂时不支持通过 KMS 托管密钥。密钥以可恢复的十六进制形式保存在数据库元数据中，请限制数据库元数据和备份文件的访问权限。

客户端执行 `SHOW CREATE TABLE` 会显示真实密钥，可供查看设置的密钥；包含建表语句的导出文件也会携带密钥。请将这些输出作为敏感信息保管。恢复加密数据时，需要保留对应的密钥和表结构；如果密钥丢失，无法仅凭加密文件恢复原始数据。

服务端 SQL 日志（包括慢查询日志、审计日志）中的 `ENCRYPTION_KEY` 值会脱敏为 `[REDACTED]`，不改变实际执行的 SQL 或客户端查询结果。

## 当前使用限制

- 仅支持 TimeSeries 表中包含普通数据列时，生成的 Parquet 文件才启用加密。
- 只支持表级密钥，暂不支持列级密钥，也不能为单个普通数据列关闭加密。
- 加密配置必须在建表时确定，不支持通过 `ALTER TABLE ... MODIFY OPTIONS ENCRYPTION_KEY` 为已有表启用加密、设置或更换表级密钥，包括重新设置同一把密钥。

重命名表、修改 `FLUSH_INTERVAL` 等非加密选项仍遵循原有规则。不要直接修改持久化元数据中的密钥，否则已有文件可能无法解密。

## 常见错误

| 错误信息片段 | 处理方式 |
| --- | --- |
| `expected 32 or 64 hexadecimal characters` | 检查密钥是否恰好为 32 或 64 个十六进制字符。 |
| `expected only hexadecimal characters` | 移除 `0x` 前缀、空格或其他非十六进制字符。 |
| `24-byte AES keys are not supported` | 改用 16 字节或 32 字节密钥。 |
| `ALTER TABLE cannot set or replace the table ENCRYPTION_KEY` | 在建表时确定密钥，当前不支持通过 ALTER 修改。 |
