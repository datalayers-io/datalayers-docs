# 使用命令行工具操作 Datalayers

## 工具简介

dlsql 是 Datalayers 内置的一个 通过 SQL 交互的命令行管理工具，为用户提供高效、便捷的数据库操作与管理。

详细用法参考 [命令行工具](../admin/datalayers-cli.md)。

## 连接数据库

Datalayers 安装完成后，便可使用 dlsql 工具实现数据库的连接，其格式如下：
> 在静态认证的模式下（默认为静态认证），Datalayers 提供了一个默认账号，其用户名/密码为: `admin/public`

``` bash
dlsql -h 127.0.0.1 -u admin -p public
```

参数说明：

- `-h`参数用于指定服务器地址；
- `-u`参数用于指定用户名；
- `-p`参数用于指定用户对应的密码；

以下是使用 dlsql 来连接 Datalayers 数据库的简单实例：

``` bash
dlsql -h 127.0.0.1 -u admin -p public
```

若需要更换主机地址、启动端口等参数，可使用以下命令执行：

``` bash
dlsql -h <host> -P <port> -u admin -p public
```

可以通过 `dlsql --help` 命令查看更多用法。

## 创建数据库

连接数据库服务后，可以执行以下命令创建一个数据库：

``` sql
> create database demo;
```

可通过以下命令查看当前帐户下所有数据库：

``` sql
> show databases;
```

## 创建表

首先选中要执行操作的数据库：

``` sql
> use demo;
```

接着，可以通过以下命令尝试创建数据表：

``` sql
CREATE TABLE sensor_info (
  ts TIMESTAMP(9) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  sn STRING,
  speed DOUBLE,
  temperature DOUBLE,
  timestamp KEY (ts))
  PARTITION BY HASH(sn) PARTITIONS 8
  ENGINE=TimeSeries
  with (ttl='10d');
```

> Datalayers 支持更多[数据类型](../sql-reference/data-type.md)以及[表配置](../sql-reference/table-engine/timeseries.md)。

## 写入数据

可以执行以下命令写入一些示例数据：

``` sql
INSERT INTO sensor_info(sn, speed, temperature) VALUES('100', 22.12, 30.8), ('101', 34.12, 40.6), ('102', 56.12, 52.3);
```

## 查询数据

首先，选中要执行操作的数据库：

``` sql
use demo;
```

以下是一些查询操作示例：

- 查询表中记录总条数：

``` sql
SELECT COUNT(*) FROM sensor_info;
```

- 查询表中 `speed` 平均值：

``` sql
SELECT AVG(speed) FROM sensor_info;
```

- 将数据以 `1 day` 分割点进行聚合：

``` sql
SELECT date_bin('1 days', ts) as timepoint, count(*) as total from sensor_info group by timepoint;
```

## 其他常见操作

查看所有表：

``` sql
SHOW TABLES;
```

查看表定义：

``` sql
DESC TABLE sensor_info;
```

查看创建表信息：

``` sql
SHOW CREATE TABLE sensor_info;
```

删除表：

``` sql
DROP TABLE sensor_info;
```

删除数据库：

``` sql
DROP DATABASE demo;
```

**注**：删除数据库前，必须先行删除其包含的所有表。若数据库中存在表，为确保数据安全，删除操作将被系统禁止。

## 退出

使用 `exit` 或者 `quit` 命令可退出交互终端。

更多 SQL 相关的使用，可查看 [SQL 参考](../sql-reference/data-type.md) 章节。
