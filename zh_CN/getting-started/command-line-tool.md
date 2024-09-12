# 通过命令行工具体验 Datalayers

dlsql 命令是 Datalayers 提供的一个交互式工具，可通过该工具进行数据库的管理。

## 连接数据库

默认情况下，使用以下命令可完成数据库连接。

``` bash
dlsql -u admin -p public
```

若需要更换主机地址、启动端口等参数，请使用以下命令执行：

``` bash
dlsql -h <host> -P <port> -u admin -p public
```

可通过 `dlsql --help` 命令查看全部参数。

## 创建数据库

连接数据库服务后，可执行以下命令创建一个数据库：

``` bash
create database demo;
```

执行完成后，可通过以下命令查看数据库情况：

``` bash
show databases;
```

## 创建表

选中要执行操作的数据库：

``` bash
use demo;
```

可通过以下命令，尝试创建数据表：

``` bash
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

> Datalayers 支持更多[数据类型](../sql-reference/data-type.md)、[表配置](../sql-reference/table-engine/timeseries.md)。

执行以下命令，写入一些示例数据：

``` bash
INSERT INTO sensor_info(sn, speed, temperature) VALUES('100', 22.12, 30.8), ('101', 34.12, 40.6), ('102', 56.12, 52.3);
```

## 查询表

选中要执行操作的数据库：

``` bash
use demo;
```

查询表中记录总条数：

``` bash
SELECT COUNT(*) FROM sensor_info;
```

查询表中 `speed` 平均值：

```bash
SELECT AVG(speed) FROM sensor_info;
```

将数据以 `1 day` 分割点进行聚合：

``` bash
SELECT date_bin('1 days', ts) as timepoint, count(*) as total from sensor_info group by timepoint;
```


## 其他常见操作

查看所有表：

``` bash
SHOW TABLES;
```

查看表定义：

``` bash
DESC TABLE sensor_info;
```

查看创建表信息：

``` bash
SHOW CREATE TABLE sensor_info;
```

删除表：

``` bash
DROP TABLE sensor_info;
```

删除数据库：

``` bash
DROP DATABASE demo;
```
**注：删除数据库，需要先删除所有表。**

## 退出交互

使用以下命令可退出交互：

``` bash
exit
```

::: tip
更多 SQL 相关的使用，可查看[SQL 参考](../sql-reference/data-type.md)章节。
:::
