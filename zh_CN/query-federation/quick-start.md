---
title: "Datalayers 联邦查询快速开始"
description: "通过 MySQL 示例快速体验 Datalayers 联邦查询，从创建 Catalog、访问外部表到与本地表 Join 的完整链路。"
---
# Datalayers 联邦查询快速开始

本文通过一个最小可运行示例，演示 `创建 Catalog -> 访问外部表 -> 与本地表 Join` 的完整链路，帮助你快速验证 Datalayers 联邦查询的基本能力。

## 前提条件

- Datalayers 已启动，并暴露 Arrow Flight SQL 服务于 8360 端口
- 已安装 `dlsql` 命令行工具
- 本机已安装 Docker
- 可访问一个 MySQL 实例（本文使用 Docker 启动）

## 快速体验

### Step 1：启动 MySQL

使用 Docker 启动一个本地 MySQL 实例：

```bash
docker run -d --name dl-mysql \
  -e MYSQL_ROOT_PASSWORD=123456 \
  -e MYSQL_DATABASE=demo \
  -p 3306:3306 \
  mysql:8.0
```

进入容器，创建一张测试表并写入数据：

```bash
docker exec -it dl-mysql mysql -uroot -p123456 demo
```

```SQL
CREATE TABLE dict (
  sid INT PRIMARY KEY,
  name VARCHAR(64)
);

INSERT INTO dict (sid, name) VALUES (1, 'alice'), (2, 'bob'), (3, 'carol');
```

### Step 2：进入 dlsql

```bash
dlsql -h 127.0.0.1 -P 8360 -u admin -p public
```

### Step 3：创建数据库和本地表

```SQL
CREATE DATABASE fed_demo;
USE fed_demo;

CREATE TABLE sx1 (
  ts TIMESTAMP(9),
  sid INT32,
  value FLOAT64,
  TIMESTAMP KEY(ts)
) ENGINE=TimeSeries
PARTITION BY HASH(sid) PARTITIONS 1;
```

写入几条本地数据：

```SQL
INSERT INTO sx1 (ts, sid, value) VALUES
  ('2025-01-01T00:00:01Z', 1, 10.0),
  ('2025-01-01T00:00:02Z', 2, 20.0),
  ('2025-01-01T00:00:03Z', 3, 30.0);
```

### Step 4：创建 Catalog

创建一个指向 MySQL 的 catalog：

```SQL
CREATE CATALOG mysql WITH (
  type=mysql,
  addr='127.0.0.1:3306',
  user='root',
  password='123456',
  db='demo'
);
```

查看已创建的数据目录：

```SQL
SHOW CATALOGS;
SHOW CREATE CATALOG mysql;
```

### Step 5：访问外部表

直接通过三段式命名访问 MySQL 中的表：

```SQL
SELECT * FROM mysql.demo.dict ORDER BY sid;
```

### Step 6：执行联邦 Join

将本地时序表与 MySQL 表进行关联：

```SQL
SELECT s.ts, s.sid, d.name, s.value
FROM sx1 AS s
JOIN mysql.demo.dict AS d ON s.sid = d.sid
ORDER BY s.ts;
```

### Step 7：管理与清理

修改 catalog 的连接选项，或重命名 catalog：

```SQL
ALTER CATALOG mysql MODIFY OPTIONS pool_max=200;
ALTER CATALOG mysql RENAME TO mysql_demo;
```

清理资源：

```SQL
DROP CATALOG IF EXISTS mysql_demo;
DROP TABLE sx1;
DROP DATABASE fed_demo;
```

```bash
docker rm -f dl-mysql
```

## 相关文档

- 了解联邦查询的核心概念与使用限制：[联邦查询概述](./overview.md)
- 查看 Catalog 相关的 SQL 语法：[CREATE](../sql-reference/statements/create.md)、[ALTER](../sql-reference/statements/alter.md)、[DROP](../sql-reference/statements/drop.md)
