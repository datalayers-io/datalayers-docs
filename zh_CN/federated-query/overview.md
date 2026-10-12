---
title: "Datalayers 联邦查询概述"
description: "介绍 Datalayers 联邦查询能力，通过 CATALOG 对 MySQL、PostgreSQL 等外部数据库进行关联查询，包含核心概念、支持的数据源、SQL 对象、MySQL 与 PostgreSQL 差异及使用限制。"
---
# Datalayers 联邦查询概述

联邦查询用于在 Datalayers 的 SQL 语句中直接 Join 外部数据库中的表，从而把外部数据源与本地数据关联起来，在不搬迁数据的前提下完成联合分析。它也可以理解为跨源查询或异构数据源关联查询。

通过该能力，可以在一条 SQL 中同时访问 Datalayers 内部表与 MySQL、PostgreSQL 等外部数据库的表，适用于数据分散在多个系统、又需要关联分析的场景。

## 核心概念

### Catalog

`CATALOG`（数据目录）用于描述一个外部数据库连接。创建 `CATALOG` 后，Datalayers 会按需建立到外部数据库的连接，并在 SQL 中通过三段式命名访问其表：

```text
catalog.database.table
```

例如，创建连接名为 `mysql` 的 catalog 后，可以使用 `mysql.demo.dict` 访问 MySQL 中 `demo` 库的 `dict` 表。

在 SQL 执行时，Datalayers 会尽可能将与外部 catalog 相关的扫描下推到外部数据库执行，在外部数据库完成过滤等操作后再取回结果，从而减少数据传输量。

## 支持的数据源

当前支持以下外部数据库类型：

| 类型 | `type` 取值 | 说明 |
| --- | --- | --- |
| MySQL | `mysql` | 通过 `catalog.<db>.<table>` 访问任意库下的表 |
| PostgreSQL | `postgres` | 连接后只能访问连接参数中指定 database 下任意 schema 的表 |

## 核心 SQL 对象

### CREATE CATALOG

创建外部数据目录。

```SQL
CREATE CATALOG [IF NOT EXISTS] <name> WITH (key=value, ...)
```

`WITH` 选项分为必填与可选两类。

必填选项：

| 选项 | 说明 |
| --- | --- |
| `type` | 外部数据库类型，支持 `mysql` / `postgres` |
| `addr` | 外部数据库地址，格式为 `ip:port` 或 `host:port` |
| `user` | 登录用户名 |
| `password` | 登录密码 |
| `db` | 默认连接的数据库 |

可选选项：

| 选项 | 说明 |
| --- | --- |
| `sslmode` | SSL 模式，MySQL 支持 `disable` / `require` / `prefer`；PostgreSQL 额外支持 `verify-ca` / `verify-full` |
| `ca` | SSL 根证书路径 |
| `pool_min` | 连接池最小连接数，默认 `1`，仅 MySQL 支持 |
| `pool_max` | 连接池最大连接数，默认 `100` |

示例：

```SQL
-- 创建 MySQL 数据目录
CREATE CATALOG mysql WITH (
  type=mysql, 
  addr='localhost:3306', 
  user='root', 
  password='123456', 
  db='demo'
);

-- 创建 PostgreSQL 数据目录
CREATE CATALOG pg WITH (
  type=postgres, 
  addr='localhost:5432', 
  user='root', 
  password='123456', 
  db='admin'
);
```

### 使用 Catalog 查询

创建 catalog 后，即可在 SQL 中通过三段式名称访问外部表，并与本地表进行 Join：

```SQL
-- 查询 catalog 默认数据库下的表
SELECT * FROM mysql.demo.dict;

-- 查询 MySQL 其他数据库下的表
SELECT * FROM mysql.other.dict;

-- 与本地表进行联邦 Join
SELECT *
FROM sx1
JOIN mysql.demo.dict AS dict ON sx1.sid = dict.sid;
```

::: tip
连接 PostgreSQL 时，由于 PostgreSQL 不支持在同一个连接中执行跨 database 的查询语句，因此一旦在 `WITH` 中指定了 `db`，就只能访问该 database 下任意 schema 的表，且不支持切换到其他 database。
:::

### 管理与运维

```SQL
-- 查看所有数据目录
SHOW CATALOGS;

-- 查看指定数据目录的定义 SQL
SHOW CREATE CATALOG mysql;

-- 重命名数据目录
ALTER CATALOG mysql RENAME TO mysql_new;

-- 修改数据目录的连接选项
ALTER CATALOG mysql MODIFY OPTIONS pool_max=200;

-- 删除数据目录
DROP CATALOG mysql;
```

## MySQL 与 PostgreSQL 的差异

| 维度 | MySQL | PostgreSQL |
| --- | --- | --- |
| `db` 语义 | 默认数据库，仍可在 SQL 中访问其他 db | 固定连接的 database，只能访问该 db 下的 schema |
| 三段式命名 | `catalog.<db>.<table>` | `catalog.<schema>.<table>` |
| 连接池参数 | 支持 `pool_min` / `pool_max` | 仅支持 `pool_max` |
| SSL 校验 | `disable` / `require` / `prefer` | 额外支持 `verify-ca` / `verify-full` |

## 使用限制

- 当前支持的外部数据源为 MySQL 与 PostgreSQL。
- 与外部表相关的算子会尽可能下推到外部数据库执行，具体下推能力受外部数据库支持情况限制。
- `ALTER CATALOG` 仅支持重命名与修改连接选项，不支持修改 `type`。

## 相关文档

- 了解如何快速体验一条联邦查询链路：[快速开始](./quick-start.md)
- 查看 Catalog 相关的 SQL 语法：[CREATE](../sql-reference/statements/create.md)、[ALTER](../sql-reference/statements/alter.md)、[DROP](../sql-reference/statements/drop.md)
- 查看 `catalogs` 系统表字段说明：[INFORMATION_SCHEMA](../sql-reference/information-schema.md)
