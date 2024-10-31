# 通过命令行工具体验 Datalayers

dlsql 命令是 Datalayers 提供的一个交互式工具，借助该工具就能便捷地进行数据库的管理操作。

## 验证 Datalayers 安装
在成功安装 Datalayers 后，可以通过以下命令来验证其是否正常工作。
``` bash
dlsql --version
```
该命令将会输出如下结果：
```
Datalayers command line tools 2.2.3
built: 2024-10-29T07:00:06+0000
source version: 7b954d42cede7309ec8263fce902d73f80a50f63
```
倘若在执行上述命令后为输出任何信息，那么则说明你的 Datalayers 并未安装成功。



## 连接数据库
Datalayers 安装完成后，便可使用 dlsql 工具实现数据库的连接，其格式如下：
> Datalayers提供了一个默认账号，其用户名/密码为: `admin/public`
``` bash
dlsql -u your_username -p your_password
```
参数说明：
- `-u`参数用于指定用户名；
- `-p`参数用于指定用户对应的密码；

以下是使用 dlsql 来连接 Datalayers 数据库的简单实例：
``` bash
dlsql -u admin -p public
```

若需要更换主机地址、启动端口等参数，可使用以下命令执行：

``` bash
dlsql -h <host> -P <port> -u admin -p public
```

欲了解更多用法，可通过 `dlsql --help` 命令进行查看。

## 创建数据库

连接数据库服务后，可以执行以下命令创建一个数据库：

``` bash
create database demo;
```

执行完上述命令后，可通过以下命令查看数据库的情况：

``` bash
show databases;
```

## 创建表

首先选中要执行操作的数据库：

``` bash
use demo;
```

接着，可以通过以下命令尝试创建数据表：

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

> Datalayers 支持更多[数据类型](../sql-reference/data-type.md)以及[表配置](../sql-reference/table-engine/timeseries.md)。

可以执行以下命令写入一些示例数据：

``` bash
INSERT INTO sensor_info(sn, speed, temperature) VALUES('100', 22.12, 30.8), ('101', 34.12, 40.6), ('102', 56.12, 52.3);
```

## 查询表

首先，选中要执行操作的数据库：

``` bash
use demo;
```
以下是一些查询操作示例：
- 查询表中记录总条数：

``` bash
SELECT COUNT(*) FROM sensor_info;
```

- 查询表中 `speed` 平均值：

```bash
SELECT AVG(speed) FROM sensor_info;
```

- 将数据以 `1 day` 分割点进行聚合：

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
