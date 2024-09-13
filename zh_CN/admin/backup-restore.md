# 数据备份与恢复
Datalayers 提供数据转储工具 `dldump`（Datalayers Dump），用于对运行中的 Datalayers 实例执行在线备份与恢复。该工具对单机版和集群版均可用。

## 使用手册
`dldump` 工具提供了丰富的选项以供配置，您可以通过执行 `dldump help` 以查看 `dldump` 的所有子命令和选项。此处对一些重要的选项进行说明：
- `host`：指定 Datalayers 实例的地址，默认为 `127.0.0.1`。
- `port`：指定 Datalayers 实例的 SQL 服务端口，默认为 `8360`。
- `username`：指定用于鉴权的用户名，默认为 `admin`。
- `password`：指定用于鉴权的密码，默认为 `public`。
- `output`：指定备份时数据的存储路径。为了避免用户无意间覆盖之前的备份，我们要求导出时指定的 `path` 为空。如果该路径不存在，`dldump` 会尝试创建该路径。
- `input`：指定恢复时数据的加载路径。如果指定的 `path` 为空，`dldump` 会中止恢复操作。
- `meta`：指定备份时是否要包含元信息，即建库和建表语句、表的 schema 等，默认包含元信息。如果要求不备份元信息，您可以传入 `--meta false`。
- `data`：指定备份时是否要包含表数据，默认包含表数据。如果要求不备份表数据，您可以传入 `--data false`。
- `database`：指定备份或恢复的数据库。如果不显式设定该选项，`dldump` 默认转储所有数据库。
- `table`：指定备份或恢复的表。如果指定了 `table`，则必须指定 `database`。如果不显式设定该选项，`dldump` 默认转储 `database` 指定的数据库内的所有表。
- `max-file-size`：指定一个数据文件大小的最大值，默认为 8GiB。我们只支持整型作为合法的输入，且默认单位为 GiB。
- `start`：指定一个时间戳，时间戳大于或等于 `start` 的表数据才会被备份。合法的日期格式和整型均认为是合法的时间戳。
- `end`：指定一个时间戳，时间戳小于或等于 `end` 的表数据才会被备份。合法的日期格式和整型均认为是合法的时间戳。

接下来，让我们通过一个示例来介绍 `dldump` 工具的基础使用方式。这个示例首先为单机版 Datalayers 写入一些数据，然后使用 `dldump` 将数据导出到备份目录；再创建一个新的 Datalayers 实例，从备份目录加载数据并写入到新的 Datalayers 实例；最后使用我们的 `dlsql` 工具查询新的 Datalayers 实例，以验证我们成功执行了备份与恢复。

为方便叙述，我们将被备份的 Datalayers 实例称为 1 号节点，将被恢复的 Datalayers 实例称为 2 号节点。

### Step 1：准备工作
启动 1 号节点：
``` shell
datalayers standalone -c datalayers.toml
```

使用 `dlsql` 工具创建数据库 `test`、表 `device`、以及往 `device` 表写入一些数据，对应的 SQL 及输出如下：
``` sql
> CREATE DATABASE test; 
Query OK, 0 rows affected. (0.009 sec)

> CREATE TABLE test.device (
    ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sid INT32,
    value REAL,
    flag INT8,
    timestamp key(ts),
    )
PARTITION BY HASH(sid) PARTITIONS 2
ENGINE=TimeSeries;
Query OK, 0 rows affected. (0.009 sec)

> INSERT INTO test.device (ts, sid, value, flag) VALUES
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
执行数据备份：
``` shell
dldump export --path /tmp/datalayers/backup
```
该命令会使用 `dldump` 的 `export` 命令，将 1 号节点的数据导出到指定的 `/tmp/datalayers/backup` 目录。

备份完成后，`/tmp/datalayers/backup` 目录将会有如下的层次结构：
```
backup
  - test
    - create.sql
    - device_0.parquet
```
根据 `dldump` 工具的设计，每个数据库会有一个独立的备份目录，这个目录会以数据库的名称命名。例如，`test` 数据库对应一个同名的 `test` 目录。数据库目录下存在一个 `create.sql` 文件，它里面包含了这个数据库的建库语句和每个表的建表语句。数据库目录下的其他文件则为表数据文件。表数据文件的命名规则是 `<table_name>_<sequence>.parquet`，`table_name` 为表名，如示例中的 `device` 表；`sequence` 表示该数据文件为这张表的第几个数据文件，我们会根据数据导出时的顺序对数据文件进行排序。

> **注**：如果您开启了文件系统的“显示隐藏文件和目录”的选项，那么您还会在 `test` 目录下发现 `.schema` 文件。为了保证数据恢复时的 schema 与备份时的一致，我们在备份时会将所有表的 schema 统一编码到 `.schema` 文件中，在恢复时再从中解码出 schema。

### Step 3：执行数据恢复
启动 2 号节点：
``` shell
datalayers standalone -c datalayers.toml
```
请注意，您需要对配置文件 `datalayers.toml` 做必要的修改。一方面，2 号节点使用的数据目录 `storage.local.path` 必须与 1 号节点不同，否则会导致恢复失败。另一方面，如果 1 号节点没有关闭，那么您需要改动 2 号节点使用的 SQL 服务端口 `server.port` 和 HTTP 服务端口 `server.http_port`，以确保其能够成功启动。

执行数据恢复：
``` shell
dldump import --path /tmp/datalayers/backup
```
该命令会使用 `dldump` 的 `import` 命令，从 `/tmp/datalayers/backup` 路径加载备份文件，并将数据写入到 2 号节点中。待该命令执行完成后，我们便完成了数据恢复。

### Step 4：验证数据完整性
我们使用 `dlsql` 工具对 2 号节点执行查询，以验证恢复数据的完整性。

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

验证 `test` 数据库的 `device` 表被成功恢复：
``` sql
> USE test;
Database changed to `test`

test> SHOW TABLES;
+----------+-----------+------------+---------------------------+---------------------------+
| database | table     | engine     | created_time              | updated_time              |
+----------+-----------+------------+---------------------------+---------------------------+
| test     | device    | TimeSeries | 2024-09-12T23:48:21+08:00 | 2024-09-12T23:48:21+08:00 |
+----------+-----------+------------+---------------------------+---------------------------+
1 row in set (0.008 sec)
```

验证 `device` 表的所有数据被成功恢复：
``` sql
test> SELECT * FROM device; 
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
