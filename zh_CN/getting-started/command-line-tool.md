---
title: "Datalayers 命令行工具 dlsql 使用指南"
description: "介绍如何使用 Datalayers 命令行工具 dlsql 连接数据库、创建数据库与表、写入和查询数据，并执行常见管理操作。"
---
# Datalayers 命令行工具 dlsql 使用指南

`dlsql` 是 Datalayers 提供的命令行 SQL 客户端，适合用于数据库连接验证、日常查询、对象管理和运维排查。

## 工具简介

`dlsql` 是 Datalayers 提供的命令行 SQL 交互工具，可用于连接数据库、执行 SQL、查看对象定义以及进行基础运维管理。

详细用法参考 [命令行工具](../admin/datalayers-cli.md)。

## 连接数据库

Datalayers 安装完成后，即可使用 `dlsql` 连接数据库。

> 在静态认证模式下（默认配置），系统提供默认账号 `admin/public`。

``` bash
dlsql -h 127.0.0.1 -u admin -p public
```

参数说明：

- `-h`参数用于指定服务器地址；
- `-u`参数用于指定用户名；
- `-p`参数用于指定用户对应的密码；

以下是一个最基本的连接示例：

``` bash
dlsql -h 127.0.0.1 -u admin -p public
```

如需指定不同的主机地址或端口，可使用以下命令：

``` bash
dlsql -h <host> -P <port> -u admin -p public
```

可以通过 `dlsql --help` 查看完整参数说明。

## 创建数据库

连接成功后，可以先创建一个数据库：

``` sql
> create database demo;
```

可通过以下命令查看当前账户下的所有数据库：

``` sql
> show databases;
```

## 创建表

首先选中要执行操作的数据库：

``` sql
> use demo;
```

接着可以创建一张时序表示例：

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

然后写入一些示例数据：

``` sql
INSERT INTO sensor_info(sn, speed, temperature) VALUES('100', 22.12, 30.8), ('101', 34.12, 40.6), ('102', 56.12, 52.3);
```

## 查询数据

首先，选中要执行操作的数据库：

``` sql
use demo;
```

以下是一些常见查询示例：

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

你也可以结合聚合函数、过滤条件和时间窗口语法构造更复杂的分析查询。

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

## 下一步

- 了解更多命令参数和管理命令，请参考 [命令行工具](../admin/datalayers-cli.md)
- 了解完整 SQL 能力，请参考 [SQL 参考](../sql-reference/data-type.md)
- 如果你希望通过图形化工具连接实例，请参考 [Datalayers 集成 DBeaver 指南](../integration/datalayers-with-dbeaver.md)
