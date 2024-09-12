# 数据备份与恢复
Datalayers 提供数据转储工具 `dlctl`（Datalayers Control）以实现数据备份与恢复。您可以从我们的 `dlctl` 安装包获取它，或者使用我们制作的 `dlctl` Docker 镜像。它是一个逻辑备份工具，用于对运行中的 Datalayers 实例执行在线备份与恢复。

> **注**：逻辑备份与物理备份：逻辑备份以数据库对象为单位执行备份与恢复，这些对象包括用户、数据库、表等，备份内容包括用户信息、元信息、表数据、索引、日志等。物理备份不识别数据库对象，而是在存储层面直接对数据库进行整体备份，例如将数据库的目录直接复制到另一个路径。相比于物理备份，逻辑备份支持细粒度的备份策略，灵活性更

## 使用手册
`dlctl` 工具提供了丰富的选项以供配置，您可以通过执行 `dlctl --help` 以查看 dlctl 的所有子命令和选项。此处对一些重要的选项进行说明：
- `path`：指定备份文件的存储路径。执行备份时，数据会导出到该路径；执行恢复时，我们会从该路径加载数据。为了避免用户无意间覆盖之前的备份，我们要求导出时指定的 `path` 为空。如果该路径不存在，`dlctl` 会尝试创建该路径。
- `target`：指定备份的对象，可选值包括 `schema` 和 `data`。前者只会备份建库、建表语句，用于恢复时创建数据库和表；后者只会备份表数据。如果该选项没有被显式指定，那么 `dlctl` 会默认导出建库、建表语句、以及表数据。
- `databases`：指定备份或恢复的数据库。用户可以传入单个数据库名，或传入由 `,` 分隔的多个数据库名，以要求 `dlctl` 仅转储指定的数据库。如果不显式设定该选项，`dlctl` 默认转储所有数据库。
- `tables`：指定备份或恢复的表。用户可以传入单个表名，或传入由 `,` 分隔的多个表名，以要求 `dlctl` 仅转储指定的表。如果不显式设定该选项，`dlctl` 默认转储所有表。请注意，如果指定了 `tables`，那么您必须同时指定 `databases`，并且 `databases` 仅包含单个数据库名。
- `file-size-limit`：指定一个数据文件大小的最大值。该参数的合法形式为 `<number><unit>`，其中 `number` 为一个整型，`unit` 则为 `G`、`M`、`K`、`B` 之一，分别表示 GiB、MiB、KiB、Bytes。例如 `1G` 表示数据文件最大为 1GiB。
- `start`：指定一个时间戳，时间戳大于或等于 `start` 的表数据才会被备份。合法的日期格式和整型均认为是合法的时间戳。
- `end`：指定一个时间戳，时间戳小于或等于 `end` 的表数据才会被备份。合法的日期格式和整型均认为是合法的时间戳。
- `object-store-provider`：除了本地文件系统，`dlctl` 还支持将数据导出到对象存储、以及从对象存储导入数据。目前支持的对象存储包括 `Amazon S3`、`Microsoft Azure` 等。强，针对 Datalayers 单机版与集群版均可用。

> **注**：对于以上选项，只有 `path`、`databases`、`tables` 对备份和恢复操作均生效，其他选项只对备份操作生效。

接下来，让我们通过一个示例来介绍 `dlctl` 工具的基础使用方式。这个示例首先为单机版 Datalayers 写入一些数据，然后使用 `dlctl` 将数据导出到备份目录；再创建一个新的 Datalayers 实例，从备份目录加载数据并写入到新的 Datalayers 实例；最后我们通过 `dlsql` 工具查询新的 Datalayers 实例，以验证我们成功执行了备份与恢复。

为方便叙述，我们以 `datalayers-backup` 表示被备份的 Datalayers 实例，以 `datalayers-restore` 表示被恢复的 Datalayers 实例。

### Step 1：准备工作
执行以下命令，以启动 `datalayers-backup`：
``` shell
datalayers standalone -c datalayers.toml
```

使用 Datalayers 的 `dlsql` 工具创建数据库、表、以及写入一些数据，对应的 SQL 及输出如下：
``` sql
> CREATE DATABASE test; 
Query OK, 0 rows affected. (0.009 sec)

> CREATE TABLE test.sx(
    ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sid INT32,
    value REAL,
    flag INT8,
    timestamp key(ts),
    )
PARTITION BY HASH(sid) PARTITIONS 2
ENGINE=TimeSeries;
Query OK, 0 rows affected. (0.009 sec)

> INSERT INTO test.sx (ts, sid, value, flag) VALUES
('2024-09-01 10:00:00', 1, 12.5, 0),
('2024-09-01 10:05:00', 2, 15.3, 1),
('2024-09-01 10:10:00', 3, 9.8, 0),
('2024-09-01 10:15:00', 4, 22.1, 1),
('2024-09-01 10:20:00', 5, 30.0, 0),
('2024-09-02 10:00:00', 6, 12.7, 0),
('2024-09-02 10:05:00', 7, 18.2, 1),
('2024-09-02 10:10:00', 8, 5.6, 0),
('2024-09-02 10:15:00', 9, 20.3, 1),
('2024-09-02 10:20:00', 10, 33.5, 0);
Query OK, 10 rows affected. (0.010 sec)
```

### Step 2：执行数据备份
执行以下命令以启动数据备份：
``` shell
dlctl export --path /tmp/datalayers/backup
```
该命令会使用 `dlctl` 的 `export` 命令，将 `datalayers-backup` 的数据导出到指定的 `/tmp/datalayers/backup` 目录。

> **注**： `dlctl` 默认连接位于 `127.0.0.1:8360` 地址的 Datalayers 实例。如果您的 Datalayers 实例的地址与默认的不一致，您可以通过 `dlctl` 工具的 `host` 和 `port` 选项进行配置。

备份完成后，`/tmp/datalayers/backup` 目录将会有如下的层次结构：
```
backup
  - test
    - create.sql
    - sx_0.parquet
```
根据 `dlctl` 工具的设计，每个数据库会有一个独立的备份目录，这个目录会以数据库的名称命名。例如，`test` 数据库对应一个同名的 `test` 目录。数据库目录下存在一个 `create.sql` 文件，它里面包含了这个数据库的建库语句和每个表的建表语句。数据库目录下的其他文件则为表数据文件。表数据文件的命名规则是 `<table_name>_<sequence>.parquet`，`table_name` 为表名，如示例中的 `sx` 表；`sequence` 表示该数据文件为这张表的第几个数据文件，我们会根据数据导出时的顺序对数据文件进行排序。

> **注**：如果您开启了文件系统的“显示隐藏文件和目录”的选项，那么您还会在 `test` 目录下发现 `.schema` 文件。为了保证数据恢复时的 schema 与备份时的一致，我们在备份时会将所有表的 schema 统一编码到 `.schema` 文件中，在恢复时再从中解码出 schema。

### Step 3：执行数据恢复
执行以下命令，以启动 `datalayers-restore`：
``` shell
datalayers standalone -c datalayers.toml
```
请注意，您需要对配置文件 `datalayers.toml` 做必要的修改。一方面，`datalayers-restore` 使用的数据目录 `storage.local.path` 必须与 `datalayers-backup`不同，否则会干扰数据恢复，导致恢复失败。另一方面，如果您的 `datalayers-backup` 实例没有关闭，那么您需要改动 `datalayers-restore` 使用的 SQL 服务端口 `server.port` 和 HTTP 服务端口 `server.http_port`，以确保其能够成功启动。

成功启动 `datalayers-restore` 实例后，执行以下命令以启动数据恢复：
``` shell
dlctl import --path /tmp/datalayers/backup
```
该命令会使用 `dlctl` 的 `import` 命令，从 `/tmp/datalayers/backup` 路径加载备份文件，并将数据写入到 `datalayers-restore` 中。待该命令执行完成后，我们便完成了数据恢复。

### Step 4：验证数据完整性
我们可以使用 `dlsql` 工具对 `datalayers-restore` 执行查询，以验证恢复数据的完整性。

验证 `test` 数据库被成功恢复：
``` sql
> SHOW DATABASES;
+--------------------+---------------------------+
| database           | created_time              |
+--------------------+---------------------------+
| information_schema |                           |
| test               | 2024-09-12T23:47:45+08:00 |
+--------------------+---------------------------+
2 rows in set (0.023 sec)
```
> **注**：`information_schema` 是每个 Datalayers 实例自动生成的系统表组成的数据库，我们默认不会备份和恢复它。

验证 `test` 数据库的 `sx` 表被成功恢复：
``` sql
> USE test;
Database changed to `test`

test> SHOW TABLES;
+----------+-------+------------+---------------------------+---------------------------+
| database | table | engine     | created_time              | updated_time              |
+----------+-------+------------+---------------------------+---------------------------+
| test     | sx    | TimeSeries | 2024-09-12T23:48:21+08:00 | 2024-09-12T23:48:21+08:00 |
+----------+-------+------------+---------------------------+---------------------------+
1 row in set (0.008 sec)
```

验证 `sx` 表的所有数据被成功恢复：
``` sql
test> SELECT * FROM sx; 
+---------------------------+-----+-------+------+
| ts                        | sid | value | flag |
+---------------------------+-----+-------+------+
| 2024-09-01T18:10:00+08:00 | 3   | 9.8   | 0    |
| 2024-09-01T18:00:00+08:00 | 1   | 12.5  | 0    |
| 2024-09-02T18:20:00+08:00 | 10  | 33.5  | 0    |
| 2024-09-01T18:05:00+08:00 | 2   | 15.3  | 1    |
| 2024-09-01T18:15:00+08:00 | 4   | 22.1  | 1    |
| 2024-09-01T18:20:00+08:00 | 5   | 30.0  | 0    |
| 2024-09-02T18:00:00+08:00 | 6   | 12.7  | 0    |
| 2024-09-02T18:05:00+08:00 | 7   | 18.2  | 1    |
| 2024-09-02T18:10:00+08:00 | 8   | 5.6   | 0    |
| 2024-09-02T18:15:00+08:00 | 9   | 20.3  | 1    |
+---------------------------+-----+-------+------+
10 rows in set (0.016 sec)
```
